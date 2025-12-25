//
//  AppDelegate.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import SwiftUI
import FirebaseCore
import AppMetricaCore
import AppsFlyerLib
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        setup()
        return true
    }
    
    private func setup() {
        MobileAds.shared.start()
        
        FirebaseApp.configure()
        
        if let reporterConfiguration = MutableReporterConfiguration(apiKey: AppConfig.appMetricaKey) {
            reporterConfiguration.areLogsEnabled = true
            AppMetrica.activateReporter(with: reporterConfiguration)
        }
        
        AppsFlyerLib.shared().appsFlyerDevKey = AppConfig.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = AppConfig.appleAppID
        AppsFlyerLib.shared().isDebug = AppConfig.isDebugBuild
    }
}
