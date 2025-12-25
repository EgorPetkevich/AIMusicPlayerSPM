//
//  NetworkRequest.swift
//  CalendarProject
//
//  Created by George Popkich on 16.12.25.
//

import Foundation

enum NetworkHTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol NetworkRequest {
    associatedtype ResponseModel: Decodable
    
    var url: URL { get }
    var method: NetworkHTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }

}
