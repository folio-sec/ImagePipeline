import XCTest
@testable import ImagePipeline

class FetcherTests: XCTestCase {
    func testFetchPNG() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=png")!, completion: {
            XCTAssertEqual($0.contentType, "image/png")
            XCTAssertFalse($0.data.isEmpty)
            ex.fulfill()
        }, cancellation: {
            XCTFail("canceled")
        }, failure: { error in
            XCTFail("failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testFetchJPEG() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=jpg")!, completion: {
            XCTAssertEqual($0.contentType, "image/jpeg")
            XCTAssertFalse($0.data.isEmpty)
            ex.fulfill()
        }, cancellation: {
            XCTFail("canceled")
        }, failure: { error in
            XCTFail("failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testFetchGIF() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=gif")!, completion: {
            XCTAssertEqual($0.contentType, "image/gif")
            XCTAssertFalse($0.data.isEmpty)
            ex.fulfill()
        }, cancellation: {
            XCTFail("canceled")
        }, failure: { error in
            XCTFail("download failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testFetchWebP() {
        let ex = expectation(description: "fetch")

        let fetcher = Fetcher()
        fetcher.fetch(URL(string: "https://satyr.io/200x150?type=webp")!, completion: {
            XCTAssertEqual($0.contentType, "image/webp")
            XCTAssertFalse($0.data.isEmpty)
            ex.fulfill()
        }, cancellation: {
            XCTFail("canceled")
        }, failure: { error in
            XCTFail("download failed: \(error?.localizedDescription ?? "")")
        })

        waitForExpectations(timeout: 10)
    }

    func testDeallocatingWhileFetching() {
        weak var weakFetcher: Fetcher?

        do {
            let fetcher = Fetcher()
            weakFetcher = fetcher

            XCTAssertNotNil(weakFetcher)

            for _ in 0..<100 {
                fetcher.fetch(URL(string: "https://satyr.io/200x150?type=webp&delay=1000")!, completion: {
                    XCTAssertEqual($0.contentType, "image/webp")
                    XCTAssertFalse($0.data.isEmpty)
                }, cancellation: {
                    /* Some outstanding tasks are canceled */
                }, failure: { error in
                    XCTFail("failed: \(error?.localizedDescription ?? "")")
                })
            }

            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        }

        XCTAssertNil(weakFetcher)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertNil(weakFetcher)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertNil(weakFetcher)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertNil(weakFetcher)
    }
    
    func testParseCacheControlHeader() {
        let maxAgeDirective = "max-age=86000"
        let directives1 = parseCacheControlHeader(maxAgeDirective)
        XCTAssertEqual(1, directives1.count)
        XCTAssertTrue(directives1.keys.contains("max-age"))
        XCTAssertEqual("86000", directives1["max-age"])
        
        let noCacheDirective = "no-cache"
        let directives2 = parseCacheControlHeader(noCacheDirective)
        XCTAssertEqual(0, directives2.count)
        
        let publicMaxCacheDirective = "public, max-age=86000"
        let directives3 = parseCacheControlHeader(publicMaxCacheDirective)
        XCTAssertEqual(1, directives3.count)
        XCTAssertTrue(directives3.keys.contains("max-age"))
        XCTAssertEqual("86000", directives3["max-age"])
        
        let sMaxAgeDirective = "s-maxage=86000"
        let directives4 = parseCacheControlHeader(sMaxAgeDirective)
        XCTAssertEqual(1, directives4.count)
        XCTAssertTrue(directives4.keys.contains("s-maxage"))
        XCTAssertEqual("86000", directives4["s-maxage"])
        
        let publicMaxAgeDirectives = "public, max-age=86000, s-maxage=86000"
        let directives5 = parseCacheControlHeader(publicMaxAgeDirectives)
        XCTAssertEqual(2, directives5.count)
        XCTAssertTrue(directives5.keys.contains("s-maxage"))
        XCTAssertEqual("86000", directives5["s-maxage"])
        XCTAssertTrue(directives5.keys.contains("max-age"))
        XCTAssertEqual("86000", directives5["max-age"])
    }
}
