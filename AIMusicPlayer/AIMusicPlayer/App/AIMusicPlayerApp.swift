//
//  AIMusicPlayerApp.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI
import GoogleMobileAds

@main
struct AIMusicPlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var musicPlayer = MusicPlayerService.shared
    
    @State private var wasInBackground = false
    
    private let adManagerService = AdManagerService.shared
    private let analyticsService = AnalyticsService()
    
    var body: some Scene {
        WindowGroup {
            contentView
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    switch newPhase {
                    case .background:
                        wasInBackground = true
                    case .active:
                        guard wasInBackground else { return }
                        wasInBackground = false
                        coverAd()
                    default:
                        break
                    }
                }
                .onAppear {
                    checkIsFirstLaunch()
                }
            
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        MainView()
            .environment(musicPlayer)
    }
    
    init() {}
    
    private func coverAd() {
        adManagerService.showAppOpenAd()
    }
    
    private func checkIsFirstLaunch() {
        let isFirstLaunch = !UDManager.get(.didLaunchBefore)
        UDManager.set(.didLaunchBefore, value: true)
        analyticsService.track(.appLaunched(isFirstLaunch: isFirstLaunch))
    }
    
}
