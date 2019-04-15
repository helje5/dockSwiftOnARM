import Foundation
import SmokeOperations

public struct EchoInput: Codable, Validatable {
    public let input: String
    
    public init(input: String) {
        self.input = input
    }
    
    public func validate() throws {
        return
    }
}

extension EchoInput : Equatable {
    public static func ==(lhs: EchoInput, rhs: EchoInput) -> Bool {
        return lhs.input == rhs.input
    }
}

extension EchoInput: CustomStringConvertible {
    public var description: String { return "EchoInput(input: \"\(input)\")" }
}
