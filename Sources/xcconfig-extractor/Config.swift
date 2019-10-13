import Foundation

struct Config {
    static let version = "0.6.0"
    let isIncludeExisting: Bool
    init(isIncludeExisting: Bool) {
        self.isIncludeExisting = isIncludeExisting
    }
}
