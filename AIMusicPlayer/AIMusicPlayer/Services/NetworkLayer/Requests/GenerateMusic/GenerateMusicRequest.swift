//
//  GenerateMusicRequest.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

struct GenerateMusicRequest: NetworkRequest {

    typealias ResponseModel = GenerateMusicResponseModel

    var url: URL {
        URL(string: ApiPaths.generateMusic)!
    }

    var method: NetworkHTTPMethod { .post }

    var headers: [String: String] {
        [
            "Authorization": "Bearer \(AppConfig.kieToken)",
            "Content-Type": "application/json"
        ]
    }

    var body: Data? {
        try? JSONEncoder().encode(model)
    }

    let model: GenerateMusicRequestModel
}
