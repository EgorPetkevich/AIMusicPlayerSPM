//
//  GenerateTrackAssembler.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI

final class GenerateTrackAssembler {
    
    private init() {}
    
    static func make() -> some View {
        let networkService = GenerateMusicNetworkServiceUseCase(service: MusicNetworkService())
        let loaderService = GenerateTrackLoaderUseCase(service: TrackLoaderService())
        let vm = GenerateTrackVM(networkService: networkService,
                                 loadService: loaderService,
                                 analytics: AnalyticsService(),
                                 adManagerService: AdManagerService.shared)
        let vc = GenerateTrackVC(vm: vm)
        return vc
    }
    
}
