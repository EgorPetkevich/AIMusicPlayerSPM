//
//  GetMusicStatusRequest.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

struct GetMusicStatusRequest: NetworkRequest {

    typealias ResponseModel = MusicStatusResponse

    let taskId: String

    var url: URL {
        var comps = URLComponents(string: ApiPaths.musicStatus)!
        comps.queryItems = [
            URLQueryItem(name: "taskId", value: taskId)
        ]
        return comps.url!
    }

    var method: NetworkHTTPMethod { .get }

    var headers: [String : String] {
        ["Authorization": "Bearer \(AppConfig.kieToken)"]
    }

    var body: Data? { nil }
}
