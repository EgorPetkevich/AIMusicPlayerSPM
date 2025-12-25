//
//  MiniPlayerView.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI

struct MiniPlayerView: View {
    
    let track: TrackModel
    @EnvironmentObject private var musicPlayer: MusicPlayerService
    
    private enum Const {
        static let height: CGFloat = 64
        static let imageSize: CGFloat = 48
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let data = track.cover,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Const.imageSize, height: Const.imageSize)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: Const.imageSize, height: Const.imageSize)
                    .foregroundStyle(.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "music.note")
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                Text(track.subtitleText)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                Button(action: { musicPlayer.togglePlayPause() }) {
                    Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: { musicPlayer.forward() }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
        .frame(height: Const.height)
    }
}
