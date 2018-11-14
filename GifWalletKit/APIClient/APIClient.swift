//
//  Created by Pierluigi Cifani on 02/03/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation

public struct Signature {
    let name: String
    let value: String
}

public class APIClient {
    
    let environment: Environment
    let signature: Signature?
    let urlSession: URLSession
    let jsonDecoder = JSONDecoder()
    
    public init(environment: Environment, signature: Signature? = nil) {
        self.environment = environment
        self.signature = signature
        self.urlSession = URLSession(configuration: .default)
    }
    
    public func perform<T: Decodable>(_ request: Request<T>, handler: @escaping (T?, Swift.Error?) -> Void) {
        URLRequest.createURLRequest(request: request) { (urlRequest, error) in
            guard error == nil, let urlRequest = urlRequest else {
                handler(nil, error)
                return
            }

            let task = self.urlSession.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else {
                    handler(nil, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                    (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 399) else {
                        handler(nil, Error.httpError)
                        return
                }
                
                guard let data = data else {
                    handler(nil, Error.unknown)
                    return
                }
                
                self.parseResponse(data: data, handler: { (object: T?, error: Swift.Error?) in
                    guard error == nil, let object = object else {
                        handler(nil, error)
                        return
                    }

                    handler(object, nil)
                })
            }
            task.resume()
        }
    }
    
    func parseResponse<T: Decodable>(data: Data, handler: @escaping (T?, Swift.Error?) -> Void) {
        do {
            let parsedResponse: T = try parseResponse(data: data)
            handler(parsedResponse, nil)
        } catch let error {
            handler(nil, error)
        }
    }
    
    func parseResponse<T: Decodable>(data: Data) throws -> T {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw Error.malformedJSONResponse
        }
    }
    
    func requestForEndpoint<T>(_ endpoint: Endpoint) -> Request<T> {
        return Request<T>(
            endpoint: endpoint,
            environment: environment,
            signature: signature
        )
    }
    
    public enum Error: Swift.Error {
        case malformedURL
        case malformedParameters
        case malformedJSONResponse
        case httpError
        case unknown
    }

}

public extension URLRequest {
    static func createURLRequest<T>(request: Request<T>, handler: @escaping (URLRequest?, Swift.Error?) -> Void) {
        do {
            let request = try URLRequest.init(fromRequest: request)
            handler(request, nil)
        } catch let error {
            handler(nil, error)
        }
    }

    init<T>(fromRequest request: Request<T>) throws {
        let endpoint = request.endpoint
        let environment = request.environment
        guard let url = URL(string: endpoint.path, relativeTo: environment.baseURL) else {
            throw APIClient.Error.malformedURL
        }
        
        self.init(url: url)
        
        httpMethod = endpoint.method.rawValue
        allHTTPHeaderFields = endpoint.httpHeaderFields
        setValue("GifWallet - iOS", forHTTPHeaderField: "User-Agent")
        if let signature = request.signature {
            setValue(
                signature.value,
                forHTTPHeaderField: signature.name
            )
        }
        
        //TODO: account for the parameter encoding.
        if let parameters = endpoint.parameters {
            do {
                let requestData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                httpBody = requestData
                setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIClient.Error.malformedParameters
            }
        }
    }
}
