//
//  AdManagerService.swift
//  AIMusicPlayer
//

import UIKit
import GoogleMobileAds

protocol AdManagerServiceProtocol {
    func showAppOpenAd()
    func showInterstitialAd()
    func loadNativeAd(completion: @escaping (NativeAd) -> Void)
}

final class AdManagerService: NSObject, AdManagerServiceProtocol {

    static let shared = AdManagerService()

    private let analytics: AnalyticsServiceProtocol = AnalyticsService()

    // MARK: - Ad Unit IDs (TEST)
    private let appOpenUnitID = "ca-app-pub-3940256099942544/5575463023"
    private let interstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
    private let nativeUnitID = "ca-app-pub-3940256099942544/3986624511"

    // MARK: - State
    private var appOpenAd: AppOpenAd?
    private var interstitialAd: InterstitialAd?
    private var nativeAd: NativeAd?
    private var nativeLoader: AdLoader?
    private var nativeCompletion: ((NativeAd) -> Void)?

    private var isLoading = false
    private var isShowing = false

    private var currentFullScreenPlacement: AnalyticsEvent.AdPlacement?
    private var currentFullScreenFormat: AnalyticsEvent.AdFormat?

    // MARK: - App Open

    func showAppOpenAd() {
        DispatchQueue.main.async {
            guard !self.isShowing else { return }

            self.analytics.track(.adRequest(format: .app_open, placement: .app_open_resume))

            self.loadAppOpenAd { [weak self] ad in
                self?.present(ad, placement: .app_open_resume, format: .app_open)
            }
        }
    }

    private func loadAppOpenAd(completion: @escaping (AppOpenAd) -> Void) {
        guard !isLoading else { return }
        isLoading = true

        AppOpenAd.load(with: appOpenUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.analytics.track(.adLoadFailed(
                        format: .app_open,
                        placement: .app_open_resume,
                        error: error.localizedDescription
                    ))
                    print("[AppOpen] load error:", error)
                    return
                }

                guard let ad else {
                    self.analytics.track(.adLoadFailed(
                        format: .app_open,
                        placement: .app_open_resume,
                        error: "ad_is_nil"
                    ))
                    print("[AppOpen] ad is nil")
                    return
                }

                self.analytics.track(.adLoaded(format: .app_open, placement: .app_open_resume))

                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                completion(ad)
            }
        }
    }

    // MARK: - Interstitial

    func showInterstitialAd() {
        DispatchQueue.main.async {
            guard !self.isShowing else { return }

            let placement: AnalyticsEvent.AdPlacement = .track_loaded_interstitial

            if let ad = self.interstitialAd {
                self.present(ad, placement: placement, format: .interstitial)
            } else {
                self.analytics.track(.adRequest(format: .interstitial, placement: placement))
                self.loadInterstitialAd { [weak self] ad in
                    self?.present(ad, placement: placement, format: .interstitial)
                }
            }
        }
    }

    private func loadInterstitialAd(completion: @escaping (InterstitialAd) -> Void) {
        guard !isLoading else { return }
        isLoading = true

        let placement: AnalyticsEvent.AdPlacement = .track_loaded_interstitial

        InterstitialAd.load(with: interstitialUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.analytics.track(.adLoadFailed(
                        format: .interstitial,
                        placement: placement,
                        error: error.localizedDescription
                    ))
                    print("[Interstitial] load error:", error)
                    return
                }

                guard let ad else {
                    self.analytics.track(.adLoadFailed(
                        format: .interstitial,
                        placement: placement,
                        error: "ad_is_nil"
                    ))
                    print("[Interstitial] ad is nil")
                    return
                }

                self.analytics.track(.adLoaded(format: .interstitial, placement: placement))

                self.interstitialAd = ad
                self.interstitialAd?.fullScreenContentDelegate = self
                completion(ad)
            }
        }
    }

    // MARK: - Native

    func loadNativeAd(completion: @escaping (NativeAd) -> Void) {
        DispatchQueue.main.async {
            let placement: AnalyticsEvent.AdPlacement = .generate_native

            self.analytics.track(.adRequest(format: .native, placement: placement))

            let options = [NativeAdMediaAdLoaderOptions()]

            let loader = AdLoader(
                adUnitID: self.nativeUnitID,
                rootViewController: UIApplication.shared.firstKeyWindowRootVC,
                adTypes: [.native],
                options: options
            )

            self.nativeLoader = loader
            loader.delegate = self

            self.nativeCompletion = completion
            loader.load(Request())
        }
    }

    // MARK: - Present

    private func present(_ ad: AppOpenAd,
                         placement: AnalyticsEvent.AdPlacement,
                         format: AnalyticsEvent.AdFormat) {
        guard let rootVC = UIApplication.shared.firstKeyWindowRootVC else {
            print("[Ads] rootVC not found")
            return
        }

        currentFullScreenPlacement = placement
        currentFullScreenFormat = format

        isShowing = true
        analytics.track(.adShown(format: format, placement: placement))
        ad.present(from: rootVC)
    }

    private func present(_ ad: InterstitialAd,
                         placement: AnalyticsEvent.AdPlacement,
                         format: AnalyticsEvent.AdFormat) {
        guard let rootVC = UIApplication.shared.firstKeyWindowRootVC else {
            print("[Ads] rootVC not found")
            return
        }

        currentFullScreenPlacement = placement
        currentFullScreenFormat = format

        isShowing = true
        analytics.track(.adShown(format: format, placement: placement))
        ad.present(from: rootVC)
    }
}

// MARK: - FullScreenContentDelegate

extension AdManagerService: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        DispatchQueue.main.async {
            if let f = self.currentFullScreenFormat, let p = self.currentFullScreenPlacement {
                self.analytics.track(.adDismissed(format: f, placement: p))
            }

            self.isShowing = false
            self.appOpenAd = nil
            self.interstitialAd = nil
            self.currentFullScreenPlacement = nil
            self.currentFullScreenFormat = nil
        }
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        DispatchQueue.main.async {
            if let f = self.currentFullScreenFormat, let p = self.currentFullScreenPlacement {
                self.analytics.track(.adShowFailed(
                    format: f,
                    placement: p,
                    error: error.localizedDescription
                ))
            }

            print("[Ads] failed to present:", error)
            self.isShowing = false
            self.appOpenAd = nil
            self.interstitialAd = nil
            self.currentFullScreenPlacement = nil
            self.currentFullScreenFormat = nil
        }
    }
}

// MARK: - NativeAdLoaderDelegate

extension AdManagerService: NativeAdLoaderDelegate {

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        DispatchQueue.main.async {
            let placement: AnalyticsEvent.AdPlacement = .generate_native

            self.analytics.track(.adLoaded(format: .native, placement: placement))

            self.nativeAd = nativeAd
            self.nativeCompletion?(nativeAd)
            self.nativeCompletion = nil
        }
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async {
            let placement: AnalyticsEvent.AdPlacement = .generate_native

            self.analytics.track(.adLoadFailed(
                format: .native,
                placement: placement,
                error: error.localizedDescription
            ))

            print("[Native] load error:", error)
            self.nativeCompletion = nil
        }
    }
}
