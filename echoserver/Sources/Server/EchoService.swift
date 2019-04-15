//
//  EchoService.swift
//  Services
//
//  Created by Van Simmons on 2/7/19.
//

import Foundation
import SmokeHTTP1
import SmokeOperations
import SmokeOperationsHTTP1
import LoggerAPI
import NIOHTTP1
import Service
import EchoService

struct EchoService: Service {
    typealias InputType = EchoInput
    typealias OutputType = EchoOutput
    
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    
    // decode the input stream from the request
    static let inputDecoder = { (request: SmokeHTTP1RequestHead, data: Data?) throws -> EchoInput in
        Log.debug("Handling EchoService request: \(request)")
        guard let data = data, let decoded = String(data: data, encoding: .utf8) else {
            Log.error("No request body for request \(request)")
            throw ApplicationContext.allowedErrors[0].0
        }
        return EchoInput(input: decoded)
    }
    
    // transform the input into the output
    typealias EchoResultHandler = (SmokeResult<EchoOutput>) -> Void
    static let transform = { (input: EchoInput, context: ApplicationContext) -> EchoOutput in
        let output = EchoOutput(output: input.input)
        Log.debug("Transforming EchoService Input: \(input) to Output: \(output)")
        return output
    }
    
    // encode the output into the response
    static let outputEncoder = { (request: SmokeHTTP1RequestHead, output: EchoOutput, responseHandler: HTTP1ResponseHandler) in
        var body = ( contentType: "application/json", data: Data() )
        var responseCode = HTTPResponseStatus.ok
        if let encoded = output.output.data(using: .utf8)  {
            body = ( contentType: "application/json", data: encoded )
        } else {
            responseCode = HTTPResponseStatus.internalServerError
            body = ( contentType: "application/json", data: try! jsonEncoder.encode(["message": "output failure"]) )
        }
        let response = HTTP1ServerResponseComponents(
            additionalHeaders: [],
            body: body
        )
        Log.debug("Encoding EchoService Output: \(response)")
        responseHandler.completeInEventLoop(status: responseCode, responseComponents: response)
    }
    
    static let serviceHandler = OperationHandler<ApplicationContext, SmokeHTTP1RequestHead, HTTP1ResponseHandler>(
        inputProvider: EchoService.inputDecoder,
        operation: EchoService.transform,
        outputHandler: EchoService.outputEncoder,
        allowedErrors: ApplicationContext.allowedErrors,
        operationDelegate: ApplicationContext.operationDelegate
    )
}
