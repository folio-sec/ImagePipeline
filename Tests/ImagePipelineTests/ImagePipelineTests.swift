import XCTest
import SnapshotTesting
@testable import ImagePipeline

class ImagePipelineTests: XCTestCase {
    func testImagePipelineSuccess() {
        let imageView = UIImageView()
        XCTAssertNil(imageView.image)

        let defaultImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let failureImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!

        let pipeline = ImagePipeline()
        pipeline.load(URL(string: "https://satyr.io/80x60?flag=svk&type=webp&delay=1000")!, into: imageView, transition: .none, defaultImage: defaultImage, failureImage: failureImage)

        XCTAssertEqual(imageView.image, defaultImage)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3))

        assertSnapshot(matching: imageView.image!, as: .image)
    }

    func testImagePipelineFailure() {
        do {
            let imageView = UIImageView()
            XCTAssertNil(imageView.image)

            let defaultImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
            let failureImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!

            let pipeline = ImagePipeline()
            pipeline.load(URL(string: "https://example.com/80x60?flag=svk&type=webp&delay=1000")!, into: imageView, transition: .none, defaultImage: defaultImage, failureImage: failureImage)

            XCTAssertEqual(imageView.image, defaultImage)

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 3))

            XCTAssertEqual(imageView.image, failureImage)
        }
        do {
            let imageView = UIImageView()
            XCTAssertNil(imageView.image)

            let defaultImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
            let failureImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!

            let pipeline = ImagePipeline()
            pipeline.load(URL(string: "https://httpbin.org/status/400")!, into: imageView, transition: .none, defaultImage: defaultImage, failureImage: failureImage)

            XCTAssertEqual(imageView.image, defaultImage)

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

            XCTAssertEqual(imageView.image, failureImage)
        }
        do {
            let imageView = UIImageView()
            XCTAssertNil(imageView.image)

            let defaultImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
            let failureImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!

            let pipeline = ImagePipeline()
            pipeline.load(URL(string: "https://httpbin.org/status/500")!, into: imageView, transition: .none, defaultImage: defaultImage, failureImage: failureImage)

            XCTAssertEqual(imageView.image, defaultImage)

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

            XCTAssertEqual(imageView.image, failureImage)
        }
    }

    func testImagePipelineCallbackSuccess() {
        let ex = expectation(description: "")

        let pipeline = ImagePipeline()
        pipeline.load(URL(string: "https://satyr.io/80x60?flag=svk&type=webp&delay=1000")!, processors: []) { (image: UIImage?) in
            if let image = image {
                assertSnapshot(matching: image, as: .image)
            } else {
                XCTFail()
            }
            ex.fulfill()
        }

        wait(for: [ex], timeout: 5)
    }

    func testImagePipelineCallbackFailure() {
        let ex = expectation(description: "")

        let pipeline = ImagePipeline()
        pipeline.load(URL(string: "https://httpbin.org/status/400")!, processors: []) { (image: UIImage?) in
            if let _ = image {
                XCTFail()
            }
            ex.fulfill()
        }

        wait(for: [ex], timeout: 2)
    }

    func testImagePipelineTTL() {
        let imageView = UIImageView()
        XCTAssertNil(imageView.image)

        let diskCache = DiskCache(storage: SQLiteStorage(fileProvider: InMemoryFileProvider()))
        let memoryCache = NullCache()
        let fetcher = SpyFetcher()
        let pipeline = ImagePipeline(fetcher: fetcher, diskCache: diskCache, memoryCache: memoryCache)

        var isCalled = false
        fetcher.called = {
            isCalled = true
        }
        pipeline.load(URL(string: "https://example.com/1")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(isCalled)

        isCalled = false
        fetcher.called = {
            isCalled = true
        }
        pipeline.load(URL(string: "https://example.com/2")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(isCalled)

        fetcher.called = {
            XCTFail("should load from cache")
        }
        pipeline.load(URL(string: "https://example.com/1")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        fetcher.called = {
            XCTFail("should load from cache")
        }
        pipeline.load(URL(string: "https://example.com/2")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))

        isCalled = false
        fetcher.called = {
            isCalled = true
        }
        pipeline.load(URL(string: "https://example.com/1")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(isCalled)

        isCalled = false
        fetcher.called = {
            isCalled = true
        }
        pipeline.load(URL(string: "https://example.com/2")!, into: imageView, transition: .none)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertTrue(isCalled)
    }

    func testImagepipelineDeallocatedBeforeFinished() {
        weak var weakPipeline: ImagePipeline?

        do {
            let pipeline = ImagePipeline()
            weakPipeline = pipeline

            XCTAssertNotNil(weakPipeline)

            let imageView = UIImageView()

            for _ in 0..<100 {
                pipeline.load(URL(string: "https://satyr.io/200x150?type=webp&delay=1000")!, into: imageView)
            }

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        }

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        XCTAssertNil(weakPipeline)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertNil(weakPipeline)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertNil(weakPipeline)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertNil(weakPipeline)
    }

    class SpyFetcher: Fetching {
        var called: (() -> Void)?

        func fetch(_ url: URL, completion: @escaping (CacheEntry) -> Void, cancellation: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
            let data = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!)
            let now = Date()
            completion(CacheEntry(url: url, data: data, contentType: "image/png", timeToLive: 6, creationDate: now, modificationDate: now))
            called?()
        }

        func cancel(_ url: URL) {}
        func cancelAll() {}
    }

    class NullCache: ImageCaching {
        func store(_ image: UIImage, for url: URL) {}
        func load(for url: URL) -> UIImage? { return nil }
        func remove(for url: URL) {}
        func removeAll() {}
    }
}
