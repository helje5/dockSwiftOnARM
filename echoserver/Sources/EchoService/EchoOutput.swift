import Foundation
import SmokeOperations

public struct EchoOutput: Codable, Validatable {
    public let output: String
    
    public init(output: String) {
        self.output = output
    }
    
    public func validate() throws { }
}

extension EchoOutput : Equatable {
    public static func ==(lhs: EchoOutput, rhs: EchoOutput) -> Bool {
        return lhs.output == rhs.output
    }
}

extension EchoOutput: CustomStringConvertible {
    public var description: String { return "EchoOutput(output: \"\(output)\")" }
}
