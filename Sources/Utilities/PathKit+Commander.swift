import Commander
import Foundation
import PathKit

// MARK: ArgumentConvertible

extension Path: ArgumentConvertible {

    public init(parser: ArgumentParser) throws {

        guard let path = parser.shift() else {
            throw ArgumentError.missingValue(argument: nil)
        }

        self = Path(path)
    }

}
