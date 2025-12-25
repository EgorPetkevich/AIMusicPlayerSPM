//
//  AnalyticsService.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import Foundation
import FirebaseAnalytics
import AppMetricaCore
import AppsFlyerLib

protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent)
}

final class AnalyticsService: AnalyticsServiceProtocol {

    func track(_ event: AnalyticsEvent) {
        // Firebase
        Analytics.logEvent(event.name, parameters: event.parameters)

        // AppMetrica
        guard let reporter = AppMetrica.reporter(for: AppConfig.appMetricaKey) else {
            print("REPORT ERROR: Failed to create AppMetrica reporter")
            return
        }
        reporter.resumeSession()
        reporter.reportEvent(
            name: event.name,
            parameters: event.parameters
        )
        
        // AppsFlyerLib
        AppsFlyerLib.shared().logEvent(event.name, withValues: event.parameters)
    }
}


