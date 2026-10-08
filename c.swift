import CryptoKit
import Foundation

let a = CommandLine.arguments
guard a.count == 4, let k = ProcessInfo.processInfo.environment["K"], let kd = Data(base64Encoded: k), kd.count == 32 else { exit(2) }
let key = SymmetricKey(data: kd)
let input = try Data(contentsOf: URL(fileURLWithPath: a[2]))
let output: Data
if a[1] == "e" {
    output = try AES.GCM.seal(input, using: key).combined!
} else {
    output = try AES.GCM.open(AES.GCM.SealedBox(combined: input), using: key)
}
try output.write(to: URL(fileURLWithPath: a[3]))
