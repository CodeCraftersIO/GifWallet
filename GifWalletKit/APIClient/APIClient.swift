//
//  Created by Pierluigi Cifani on 02/03/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation
import Deferred

public struct Signature {
    let name: String
    let value: String
}

private let queue = DispatchQueue(label: "apiclient")

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

    public func perform<T: Decodable>(_ request: Request<T>) -> Task<T> {
        let createRequestTask = URLRequest.createURLRequest(request: request)
        let fetchDataTask = createRequestTask.andThen(upon: queue) { (urlRequest) in
            return self.urlSession.fetchData(with: urlRequest)
        }
        return fetchDataTask.andThen(upon: queue) { (data) in
            return self.parseResponse(data: data)
        }
    }
    
    public func perform<T: Decodable>(_ request: Request<T>, handler: @escaping (T?, Swift.Error?) -> Void) {
        self.perform(request).upon(.main) { (result) in
            switch result {
            case .success(let object):
                handler(object, nil)
            case .failure(let error):
                handler(nil, error)
            }
        }
    }

    func parseResponse<T: Decodable>(data: Data) -> Task<T> {
        return Task.async(upon: queue, onCancel: Error.canceled, execute: {
            return try self.parseResponse(data: data)
        })
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
        case canceled
        case unknown
    }

}

//MARK: URLSession

public extension URLSession {
    func fetchData(with request: URLRequest) -> Task<Data> {
        let deferred = Deferred<TaskResult<Data>>()
        let dataTask = self.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                deferred.fill(with: TaskResult<Data>(failure: error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 399) else {
                    deferred.fill(with: TaskResult<Data>(failure: APIClient.Error.httpError))
                    return
            }
            
            guard let data = data else {
                deferred.fill(with: TaskResult<Data>(failure: APIClient.Error.unknown))
                return
            }
            deferred.fill(with: TaskResult<Data>(success: data))
        }
        dataTask.resume()
        return Task(deferred)
    }
}

//MARK: URLRequest

public extension URLRequest {
    static func createURLRequest<T>(request: Request<T>) -> Task<URLRequest> {
        return Task.async(upon: queue, onCancel: APIClient.Error.canceled, execute: {
            return try URLRequest(fromRequest: request)
        })
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
