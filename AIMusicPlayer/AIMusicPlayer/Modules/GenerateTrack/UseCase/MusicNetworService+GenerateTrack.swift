//
//  MusicNetworService+GenerateTrack.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

struct GenerateMusicNetworkServiceUseCase: GenerateMusicNetworkServiceUseCaseProtocol {
    
    private let service: MusicNetworkService
    
    init(service: MusicNetworkService) {
        self.service = service
    }
    
    func generateMusic(
        _ model: GenerateMusicModel,
        completion: @escaping (MusicStatusResponse.Track?, String?) -> Void
    ) {
        service.generateMusic(model, completion: completion)
    }
    
}
