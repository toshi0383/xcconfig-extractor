import Foundation
import Commander
import PathKit

let main = command(
    Argument<Path>("PATH", description: "pbxproj file", validator: fileExists),
    Argument<Path>("DIR", description: "output directory")
) { pbxprojPath, dirPath in
    print(pbxprojPath)
    print(dirPath)
}

main.run()
