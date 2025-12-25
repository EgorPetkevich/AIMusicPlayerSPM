//
//  NativeAdViewContainer.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import SwiftUI
import GoogleMobileAds

struct NativeAdViewContainer: UIViewRepresentable {

    let nativeAd: NativeAd

    func makeUIView(context: Context) -> NativeAdView {
        let view = NativeAdView()
        
        let headline = UILabel()
        headline.numberOfLines = 2
        view.headlineView = headline
        view.addSubview(headline)

        let body = UILabel()
        body.numberOfLines = 2
        view.bodyView = body
        view.addSubview(body)

        let cta = UIButton(type: .system)
        view.callToActionView = cta
        view.addSubview(cta)

        headline.translatesAutoresizingMaskIntoConstraints = false
        body.translatesAutoresizingMaskIntoConstraints = false
        cta.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headline.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            headline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            headline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            cta.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 12),
            cta.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            cta.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])

        return view
    }

    func updateUIView(_ view: NativeAdView, context: Context) {
        (view.headlineView as? UILabel)?.text = nativeAd.headline
        (view.bodyView as? UILabel)?.text = nativeAd.body
        (view.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)

        view.nativeAd = nativeAd
    }
}
