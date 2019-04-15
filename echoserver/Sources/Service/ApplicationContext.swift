//
//  ApplicationContext.swift
//  Services
//
//  Created by Van Simmons on 2/7/19.
//

import Foundation
import SmokeOperationsHTTP1

public struct ApplicationContext {
    public static let allowedErrors = [
        (ServiceError.generic(reason: "A Generic Error"), 400)
    ]

    public static let operationDelegate = JSONPayloadHTTP1OperationDelegate();

    public init() {}
}
