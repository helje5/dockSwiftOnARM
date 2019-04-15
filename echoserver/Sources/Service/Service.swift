//
//  Service.swift
//  Services
//
//  Created by Van Simmons on 2/7/19.
//

import Foundation
import SmokeHTTP1
import SmokeOperations
import SmokeOperationsHTTP1
import LoggerAPI

public protocol Service {
    associatedtype InputType: Codable, Validatable, Equatable
    associatedtype OutputType: Codable, Validatable, Equatable
    
    typealias ResultHandlerType = (SmokeResult<OutputType>) -> Void
    
    typealias InputDecoderType = (SmokeHTTP1RequestHead, Data?) throws -> InputType
    typealias TransformType = (InputType, ApplicationContext) -> OutputType
    typealias OutputEncoderType =  (SmokeHTTP1RequestHead, OutputType, HTTP1ResponseHandler)  -> Void
    
    static var inputDecoder: InputDecoderType { get }
    static var transform: TransformType { get }
    static var outputEncoder: OutputEncoderType { get }
}
