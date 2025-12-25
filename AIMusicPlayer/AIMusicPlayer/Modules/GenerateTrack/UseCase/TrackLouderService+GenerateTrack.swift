//
//  TrackLouderService+GenerateTrack.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

struct GenerateTrackLoaderUseCase: GenerateTrackLoaderUseCaseProtocol {
    
    let service: TrackLoaderService
    
    init(service: TrackLoaderService) {
        self.service = service
    }
    
    func load(
        track: MusicStatusResponse.Track,
        completion: @escaping (TrackModel?, String?) -> Void
    ) {
        service.load(track: track, completion: completion)
    }
    
}
