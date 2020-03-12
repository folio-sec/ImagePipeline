import XCTest
import SQLite3
@testable import ImagePipeline

class StorageTests: XCTestCase {

    func testCloseDatabase() {
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("temp-\(UUID().uuidString).sqlite")
        do {
            let cache = DiskCache(storage: SQLiteStorage(fileProvider: TemporaryFileProvider(tempFile: path)))

            let key = URL(string: "https://example.com/test.png")!
            let entry = CacheEntry(url: URL(string: "https://example.com/test.png")!, data: Data(count: 1), contentType: "", timeToLive: 0, creationDate: Date(), modificationDate: Date())

            cache.store(entry, for: key)
            XCTAssertEqual(cache.load(for: key), entry)
        }

        try! FileManager().removeItem(atPath: path)
    }

    func testSchemaChange() {
        var database: OpaquePointer?
        var statement: OpaquePointer?

        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("temp-\(UUID().uuidString).sqlite")

        if sqlite3_open_v2(path, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK {
            XCTFail("faled to create database")
        }
        sqlite3_prepare_v2(database,
                           """
                           PRAGMA user_version = 1;
                           """,
                           -1,
                           &statement,
                           nil)
        if sqlite3_step(statement) != SQLITE_DONE { XCTFail("faled to execute SQL statement") }

        if sqlite3_finalize(statement) != SQLITE_OK {
            XCTFail("faled to finalize statement")
        }
        if sqlite3_close_v2(database) != SQLITE_OK {
            XCTFail("faled to close database")
        }

        do {
            let cache = DiskCache(storage: SQLiteStorage(fileProvider: TemporaryFileProvider(tempFile: path)))

            let key = URL(string: "https://example.com/test.png")!
            let entry = CacheEntry(url: URL(string: "https://example.com/test.png")!, data: Data(count: 1), contentType: "", timeToLive: 0, creationDate: Date(), modificationDate: Date())

            cache.store(entry, for: key)
            XCTAssertEqual(cache.load(for: key), entry)
        }

        try! FileManager().removeItem(atPath: path)
    }
}
