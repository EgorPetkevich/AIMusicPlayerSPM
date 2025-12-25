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

    // MARK: - Ad Unit IDs (TEST)

    /// App Open (launch)
    private let appOpenUnitID = "ca-app-pub-3940256099942544/5575463023"
    /// Interstitial
    private let interstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
    /// Native
    private let nativeUnitID = "ca-app-pub-3940256099942544/3986624511"

    // MARK: - State

    private var appOpenAd: AppOpenAd?
    private var interstitialAd: InterstitialAd?
    private var nativeAd: NativeAd?
    private var nativeLoader: AdLoader?
    private var nativeCompletion: ((NativeAd) -> Void)?

    private var isLoading = false
    private var isShowing = false

    // MARK: - App Open (launch)

    func showAppOpenAd() {
        DispatchQueue.main.async {
            guard !self.isShowing else { return }

            self.loadAppOpenAd { [weak self] ad in
                self?.present(ad)
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
                    print("[AppOpen] load error:", error)
                    return
                }

                guard let ad else {
                    print("[AppOpen] ad is nil")
                    return
                }

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

            if let ad = self.interstitialAd {
                self.present(ad)
            } else {
                self.loadInterstitialAd { [weak self] ad in
                    self?.present(ad)
                }
            }
        }
    }

    private func loadInterstitialAd(completion: @escaping (InterstitialAd) -> Void) {
        guard !isLoading else { return }
        isLoading = true

        InterstitialAd.load(with: interstitialUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    print("[Interstitial] load error:", error)
                    return
                }

                guard let ad else {
                    print("[Interstitial] ad is nil")
                    return
                }

                self.interstitialAd = ad
                self.interstitialAd?.fullScreenContentDelegate = self
                completion(ad)
            }
        }
    }
    
    // MARK: - Native
    
    func loadNativeAd(completion: @escaping (NativeAd) -> Void) {
        DispatchQueue.main.async {
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

    private func present(_ ad: AppOpenAd) {
        guard let rootVC = UIApplication.shared.firstKeyWindowRootVC else {
            print("[Ads] rootVC not found")
            return
        }
        isShowing = true
        ad.present(from: rootVC)
    }

    private func present(_ ad: InterstitialAd) {
        guard let rootVC = UIApplication.shared.firstKeyWindowRootVC else {
            print("[Ads] rootVC not found")
            return
        }
        isShowing = true
        ad.present(from: rootVC)
    }
    
}

// MARK: - FullScreenContentDelegate

extension AdManagerService: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        DispatchQueue.main.async {
            self.isShowing = false
            self.appOpenAd = nil
            self.interstitialAd = nil
        }
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        DispatchQueue.main.async {
            print("[Ads] failed to present:", error)
            self.isShowing = false
            self.appOpenAd = nil
            self.interstitialAd = nil
        }
    }
}

// MARK: - NativeAdLoaderDelegate

extension AdManagerService: NativeAdLoaderDelegate {

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        DispatchQueue.main.async {
            self.nativeAd = nativeAd
            self.nativeCompletion?(nativeAd)
            self.nativeCompletion = nil
        }
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async {
            print("[Native] load error:", error)
            self.nativeCompletion = nil
        }
    }
}
