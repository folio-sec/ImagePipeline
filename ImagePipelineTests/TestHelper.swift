import Foundation
@testable import ImagePipeline

struct InMemoryFileProvider: FileProvider {
    var path: String { return ":memory:" }
}

struct TemporaryFileProvider: FileProvider {
    let tempFile: String
    var path: String { return tempFile }
}
