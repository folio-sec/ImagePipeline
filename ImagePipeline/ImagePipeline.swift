import Foundation

public final class ImagePipeline {
    public static let shared = ImagePipeline()

    private let fetcher: Fetching
    private let decoder: Decoding
    private let diskCache: DataCaching
    private let memoryCache: ImageCaching

    private let queue = DispatchQueue.init(label: "com.folio-sec.image-pipeline", qos: .userInitiated)
    private var downloadTasks = [ImageViewReference: DownloadTask]()

    private class DownloadTask {
        weak var imageView: UIImageView?
        let url: URL

        init(imageView: UIImageView, url: URL) {
            self.imageView = imageView
            self.url = url
        }
    }

    public init(fetcher: Fetching = Fetcher(), decoder: Decoding = Decoder(), diskCache: DataCaching = DiskCache(), memoryCache: ImageCaching = MemoryCache()) {
        self.fetcher = fetcher
        self.decoder = decoder
        self.diskCache = diskCache
        self.memoryCache = memoryCache
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning(notification:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    public func load(_ url: URL, into imageView: UIImageView, transition: Transition = .none, defaultImage: UIImage? = nil, failureImage: UIImage? = nil) {
        imageView.image = defaultImage

        if let image = self.memoryCache.load(for: url) {
            imageView.image = image
            return
        }
        if let entry = self.diskCache.load(for: url) {
            if let ttl = entry.timeToLive {
                let expirationDate = entry.modificationDate.addingTimeInterval(ttl)
                if expirationDate  > Date(), let image = self.decoder.decode(data: entry.data) {
                    self.memoryCache.store(image, for: url)
                    imageView.image = image
                    return
                }
            } else if let image = self.decoder.decode(data: entry.data) {
                self.memoryCache.store(image, for: url)
                imageView.image = image
                return
            }
        }

        queue.async { [weak self] in
            guard let self = self else {
                fatalError("Image pipeline has been released")
            }

            let reference = ImageViewReference(imageView)
            let downloadTask = self.downloadTasks[reference]
            if let downloadTask = downloadTask {
                self.fetcher.cancel(downloadTask.url)
            }

            self.downloadTasks[reference] = DownloadTask(imageView: imageView, url: url)
            
            self.fetcher.fetch(url, completion: {
                guard let entry = $0 else {
                    return
                }
                guard let image = self.decoder.decode(data: entry.data) else {
                    DispatchQueue.main.async {
                        self.setImage(failureImage, for: url, into: imageView, transition: transition)
                    }
                    return
                }

                self.diskCache.store(entry, for: url)
                self.memoryCache.store(image, for: url)

                DispatchQueue.main.async {
                    self.setImage(image, for: url, into: imageView, transition: transition)
                }
            }, failure: { _ in
                DispatchQueue.main.async {
                    self.setImage(failureImage, for: url, into: imageView, transition: transition)
                }
            })
        }
    }

    private func setImage(_ image: UIImage?, for url: URL, into imageView: UIImageView, transition: Transition) {
        if let downloadTask = downloadTasks[ImageViewReference(imageView)], downloadTask.url == url {
            if let imageView = downloadTask.imageView {
                switch transition.style {
                case .none:
                    imageView.image = image
                case .fadeIn(let duration):
                    UIView.transition(with: imageView, duration: duration, options: [.transitionCrossDissolve], animations: {
                        imageView.image = image
                    })
                }
            }
        }
    }

    @objc
    private func didReceiveMemoryWarning(notification: Notification) {
        memoryCache.removeAll()
    }

    private class ImageViewReference: Hashable {
        weak var imageView: UIImageView?
        let objectIdentifier: ObjectIdentifier

        init(_ imageView: UIImageView) {
            self.imageView = imageView
            objectIdentifier = ObjectIdentifier(imageView)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(objectIdentifier)
        }

        static func == (lhs: ImagePipeline.ImageViewReference, rhs: ImagePipeline.ImageViewReference) -> Bool {
            return lhs.objectIdentifier == rhs.objectIdentifier
        }
    }
}
