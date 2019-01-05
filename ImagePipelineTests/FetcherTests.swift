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
}
