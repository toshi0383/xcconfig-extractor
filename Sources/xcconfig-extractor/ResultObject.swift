import Foundation
import PathKit

final class ResultObject: Equatable {
    let path: Path
    var settings: [String]
    let targetName: String?
    let configurationName: String?
    var includes: [String]
    init(path: Path, settings: [String], targetName: String? = nil, configurationName: String? = nil, includes: [String] = []) {
        self.path = path
        self.settings = settings
        self.targetName = targetName
        self.configurationName = configurationName
        self.includes = includes
    }
}
func ==(lhs: ResultObject, rhs: ResultObject) -> Bool {
    guard lhs.path == rhs.path else { return false }
    guard lhs.settings == rhs.settings else { return false }
    guard lhs.targetName == rhs.targetName else { return false }
    guard lhs.configurationName == rhs.configurationName else { return false }
    guard lhs.includes == rhs.includes else { return false }
    return true
}
