import Foundation

struct Config {
    static let version = "0.6.1"
    let isIncludeExisting: Bool
    init(isIncludeExisting: Bool) {
        self.isIncludeExisting = isIncludeExisting
    }
}
