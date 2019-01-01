import Foundation

public protocol Fetching {
    func fetch(_ url: URL, completion: @escaping (CacheEntry?) -> Void, failure: @escaping (Error?) -> Void)
    func cancel(_ url: URL)
    func cancelAll()
}

public final class Fetcher: Fetching {
    private let session: URLSession
    private var tasks = [URL: URLSessionTask]()
    private var canceled = [URL]()

    private let queue = DispatchQueue.init(label: "com.folio-sec.image-pipeline.fetcher", qos: .userInitiated)

    public init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpShouldUsePipelining = true
        configuration.httpMaximumConnectionsPerHost = 4
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }

    public func fetch(_ url: URL, completion: @escaping (CacheEntry?) -> Void, failure: @escaping (Error?) -> Void) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {
                fatalError("Fetcher has been released")
            }

            self.queue.sync {
                self.tasks[url] = nil
            }

            if let error = error as NSError?, error.code == NSURLErrorCancelled {
                completion(nil)
                return
            }

            guard let data = data, !data.isEmpty else {
                failure(error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                failure(error)
                return
            }

            let headers = response.allHeaderFields
            var timeToLive: TimeInterval? = nil
            if let cacheControl = headers["Cache-Control"] as? String {
                let directives = parseCacheControlHeader(cacheControl)
                if let maxAge = directives["max-age"], let ttl = TimeInterval(maxAge) {
                    timeToLive = ttl
                }
            }

            let contentType = headers["Content-Type"] as? String

            let now = Date()
            let entry = CacheEntry(url: url, data: data, contentType: contentType, timeToLive: timeToLive, creationDate: now, modificationDate: now)
            completion(entry)
        }

        queue.sync {
            if let t = tasks[url] {
                switch t.state {
                case .running:
                    break
                case .suspended:
                    t.cancel()
                    tasks[url] = task
                case .canceling, .completed:
                    tasks[url] = task
                }
            }
            task.resume()
            tasks[url] = task
        }
    }

    public func cancel(_ url: URL) {
        tasks[url]?.cancel()
    }

    public func cancelAll() {
        tasks.values.forEach { $0.cancel() }
    }
}

private let regex = try! NSRegularExpression(pattern:
    """
    ([a-zA-Z][a-zA-Z_-]*)\\s*(?:=(?:"([^"]*)"|([^ \t",;]*)))?
    """, options: [])
private func parseCacheControlHeader(_ cacheControl: String) -> [String: String] {
    var directives = [String: String]()
    let matches = regex.matches(in: cacheControl, options: [], range: NSRange(location: 0, length: cacheControl.utf16.count))
    for result in matches {
        if let range = Range(result.range, in: cacheControl) {
            let directive = cacheControl[range]
            let pair = directive.split(separator: "=")
            if pair.count == 2 {
                directives[String(pair[0])] = String(pair[1])
            }
        }
    }
    return directives
}
