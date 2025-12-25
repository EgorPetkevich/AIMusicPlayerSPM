//
//  FullCoverLoadingView.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI

struct FullCoverLoadingView: View {

    let title: String
    @State private var rotate = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.45))
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.2)

                    Circle()
                        .trim(from: 0.15, to: 0.85)
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(rotate ? 360 : 0))
                        .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotate)
                }
                .frame(width: 64, height: 64)
                .scaleEffect(pulse ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Please wait…")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(22)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 28)
        }
        .onAppear {
            rotate = true
            pulse = true
        }
    }
}




