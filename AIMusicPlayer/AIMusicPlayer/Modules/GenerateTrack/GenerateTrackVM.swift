//
//  GenerateTrackVM.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation
import RealmSwift
import Combine
import FirebaseAnalytics

protocol GenerateMusicNetworkServiceUseCaseProtocol {
    func generateMusic(
        _ model: GenerateMusicModel,
        completion: @escaping (
            _ track: MusicStatusResponse.Track?,
            _ error: String?
        ) -> Void
    )
}

protocol GenerateTrackLoaderUseCaseProtocol {
    func load(
        track: MusicStatusResponse.Track,
        completion: @escaping (_ model: TrackModel?, _ error: String?) -> Void
    )
}

final class GenerateTrackVM: ObservableObject {
    
    @ObservedResults(
        TrackModel.self,
        sortDescriptor: .createdAt
    )
    private var tracks

    // UI
    @Published var showRequestSheet = false
    @Published var showTracksSheet = false

    @Published private(set) var isLoading = false
    @Published private(set) var loadingTitle: String = "Loading…"

    @Published var generateMusicModel: GenerateMusicModel?
    
    @Published private(set) var selectedTrack: TrackModel?

    @Published var showErrorAlert = false
    @Published var errorMessage: String?

    // Services
    private let networkService: GenerateMusicNetworkServiceUseCaseProtocol
    private let loadService: GenerateTrackLoaderUseCaseProtocol
    private let analytics: AnalyticsServiceProtocol
    private let adManagerService: AdManagerServiceProtocol

    private var isCancelled = false

    init(
        networkService: GenerateMusicNetworkServiceUseCaseProtocol,
        loadService: GenerateTrackLoaderUseCaseProtocol,
        analytics: AnalyticsServiceProtocol,
        adManagerService: AdManagerServiceProtocol
    ) {
        self.networkService = networkService
        self.loadService = loadService
        self.analytics = analytics
        self.adManagerService = adManagerService
    }

    var canGenerate: Bool {
        generateMusicModel != nil
    }

    var subtitleText: String {
        canGenerate
        ? "Tap the button to start generation.\nWe’ll create a track, then load audio & cover."
        : "Open “Generation Request” and fill prompt or lyrics."
    }
    
    func generateTapped() {
        guard canGenerate, let generateMusicModel else { return }
        
        analytics.track(.generateTapped(model: generateMusicModel))
        
        isCancelled = true
        isCancelled = false
        
        setLoading(true, title: "Generating track…")
        
        networkService.generateMusic(generateMusicModel) { [weak self] apiTrack, error in
            guard let self else { return }
            guard !isCancelled else { return }
            
            if let error {
                setLoading(false)
                analytics.track(.generateNetworkFailed(code: nil, message: error))
                fail(error)
                return
            }
            
            guard let apiTrack else {
                setLoading(false)
                analytics.track(.generateNetworkFailed(code: nil, message: "Empty track from service"))
                fail("Empty track from service.")
                return
            }
            
            analytics.track(.generateNetworkSucceeded(trackId: apiTrack.id))
            
            setLoading(true, title: "Loading audio & cover…")
            
            loadService.load(track: apiTrack) { [weak self] trackModel, loadError in
                guard let self else { return }
                guard !isCancelled else { return }
                
                setLoading(false)
                
                if let loadError {
                    fail(loadError)
                    return
                }
                
                guard let trackModel else {
                    fail("Failed to load track data.")
                    return
                }
                analytics.track(.loadTrackSucceeded(trackId: apiTrack.id))
                
                saveTrack(track: trackModel)
                selectedTrack = trackModel
                adManagerService.showInterstitialAd()
            }
        }
    }
    
    private func saveTrack(track: TrackModel) {
        DispatchQueue.main.async { [weak self] in
            self?.$tracks.append(track)
        }
    }

    // MARK: - Helpers

    private func setLoading(_ isLoading: Bool, title: String = "Loading…") {
        DispatchQueue.main.async {
            self.loadingTitle = title
            self.isLoading = isLoading
        }
        
    }

    private func fail(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showErrorAlert = true
        }
    }
}
