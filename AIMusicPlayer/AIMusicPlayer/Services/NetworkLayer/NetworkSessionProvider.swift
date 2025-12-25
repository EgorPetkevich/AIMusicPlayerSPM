//
//  NetworkSessionProvider.swift
//  CalendarProject
//
//  Created by George Popkich on 16.12.25.
//

import Foundation

final class NetworkSessionProvider {

    func send<Request: NetworkRequest>(
        request: Request,
        complition: @escaping (Request.ResponseModel?) -> Void
    ) {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body

        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            guard
                error == nil,
                let data,
                let model = try? JSONDecoder().decode(Request.ResponseModel.self, from: data)
            else {
                print("[Network]: live error")
                complition(nil)
                return
            }

            DispatchQueue.main.async {
                complition(model)
            }
        }.resume()
    
    }
}
