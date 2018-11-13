//
//  Created by Pierluigi Cifani on 02/03/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation

public class APIClient {
    
    let environment: Environment
    let urlSession: URLSession
    let jsonDecoder = JSONDecoder()
    
    public init(environment: Environment) {
        self.environment = environment
        self.urlSession = URLSession(configuration: .default)
    }
    
    public func performRequest(forEndpoint endpoint: Endpoint, handler: @escaping (Data?, Swift.Error?) -> ()) {
        
        let urlRequest: URLRequest
        do {
            urlRequest = try URLRequest(fromEndpoint: endpoint, andEnvironment: environment)
        } catch let error {
            handler(nil, error)
            return
        }
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
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
            
            handler(data, nil)
        }
        task.resume()
    }
    
    func parseResponse<T: Decodable>(data: Data) throws -> T {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw Error.malformedJSONResponse
        }
    }
    
    enum Error: Swift.Error {
        case malformedURL
        case malformedParameters
        case malformedJSONResponse
        case httpError
        case unknown
    }
}

public extension URLRequest {
    init(fromEndpoint endpoint: Endpoint, andEnvironment environment: Environment) throws {
        guard let url = URL(string: endpoint.path, relativeTo: environment.baseURL) else {
            throw APIClient.Error.malformedURL
        }
        
        self.init(url: url)
        
        httpMethod = endpoint.method.rawValue
        allHTTPHeaderFields = endpoint.httpHeaderFields
        
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
