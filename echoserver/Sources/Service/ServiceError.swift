
import Foundation

public enum ServiceError: Swift.Error {
    case generic(reason: String)
    
    enum CodingKeys: String, CodingKey {
        case reason = "Reason"
    }
}

extension ServiceError: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .generic(reason: let reason):
            try container.encode(reason, forKey: .reason)
        }
    }
}

extension ServiceError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .generic(reason: let reason):
            return "Services generic error: \(reason)"
        }
    }
}
