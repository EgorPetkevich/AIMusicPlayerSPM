//
//  TracksVC.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI
import RealmSwift

struct TracksVC: View {
    
    @ObservedResults(
        TrackModel.self,
        sortDescriptor: .createdAt
    )
    var tracks

    let onSelect: (TrackModel) -> Void

    var body: some View {
        NavigationStack {
            List(tracks) { track in
                Button {
                    onSelect(track)
                } label: {
                    HStack(spacing: 12) {

                        // Cover
                        if let cover = track.cover,
                           let uiIMage = UIImage(data: cover) {
                            Image(uiImage: uiIMage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: "music.note")
                                        .foregroundStyle(.secondary)
                                }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.title)
                                .font(.system(size: 16, weight: .semibold))
                                .lineLimit(1)

                            HStack(spacing: 8) {
                                Text(track.subtitleText)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)

                                Spacer()
                                
                                Text(track.createdAt, style: .date)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            .navigationTitle("Tracks")
        }
    }
}
