//
//  MusicNetworkService.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation


final class MusicNetworkService {

    private let session = NetworkSessionProvider()
    private let polling = MusicPollingService()

    func generateMusic(
        _ model: GenerateMusicModel,
        completion: @escaping (MusicStatusResponse.Track?, String?) -> Void
    ) {
        let bodyModel = GenerateMusicRequestModel(model: model)
        let request = GenerateMusicRequest(model: bodyModel)

        session.send(request: request) { (response: GenerateMusicResponseModel?) in
            guard let response else {
                completion(nil, MusicServiceError.emptyResponse.localizedDescription)
                return
            }

            guard response.msg.lowercased().contains("success") else {
                completion(nil, MusicServiceError.apiFailed(response.msg).localizedDescription)
                return
            }

            self.polling.startPolling(taskId: response.data.taskId) { track, error in
                completion(track, error)
            }
        }
    }
}

