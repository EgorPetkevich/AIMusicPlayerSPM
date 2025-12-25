//
//  NativeAdBlock.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import SwiftUI
import GoogleMobileAds

struct NativeAdBlock: View {

    @State private var nativeAd: NativeAd?

    var body: some View {
        Group {
            if let nativeAd {
                NativeAdViewContainer(nativeAd: nativeAd)
                    .frame(height: 150)
            } else {
                ProgressView()
                    .frame(height: 150)
                    .onAppear {
                        AdManagerService.shared.loadNativeAd { ad in
                            self.nativeAd = ad
                        }
                    }
            }
        }
    }
}
