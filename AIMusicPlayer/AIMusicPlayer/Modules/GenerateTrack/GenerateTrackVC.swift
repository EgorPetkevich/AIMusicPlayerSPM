//
//  GenerateTrackVC.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI
import RealmSwift

struct GenerateTrackVC: View {
    
    @ObservedResults(
        TrackModel.self,
        sortDescriptor: .createdAt
    )
    private var tracks

    @EnvironmentObject private var musicPlayer: MusicPlayerService
    @StateObject private var vm: GenerateTrackVM

    init(vm: GenerateTrackVM) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            content
                .blur(radius: vm.isLoading ? 2 : 0)

            if vm.isLoading {
                FullCoverLoadingView(title: vm.loadingTitle)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(999)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isLoading)
        .sheet(isPresented: $vm.showRequestSheet) {
            GenerationRequestVC(
                generateMusicModel: vm.generateMusicModel,
                onCancel: {
                    vm.showRequestSheet = false
                },
                onGenerate: { model in
                    vm.generateMusicModel = model
                    vm.generateTapped()
                    vm.showRequestSheet = false
                    
                }
            )
        }
        .sheet(isPresented: $vm.showTracksSheet) {
            TracksVC(
                onSelect: { track in
                    musicPlayer.play(track: track)
                    musicPlayer.setQueue(Array(tracks))
                    vm.showTracksSheet = false
                }
            )
            .presentationDetents([.medium, .large])
        }
        .alert("Error", isPresented: $vm.showErrorAlert) {
            Button("Retry") {
                vm.generateTapped()
            }
            .disabled(vm.isLoading || !vm.canGenerate)

            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
    }

    private var content: some View {
        VStack(spacing: 24) {
            topBar

            NativeAdBlock()
            
            Spacer(minLength: 0)

            VStack(spacing: 12) {
                Text("Generate Track")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text(vm.subtitleText)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button {
                vm.generateTapped()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Generate track")
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .disabled(vm.isLoading || !vm.canGenerate)

            if let track = tracks.first {
                selectedTrackCard(track)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture {
                        musicPlayer.play(track: track)
                        musicPlayer.setQueue(Array(tracks))
                    }
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 12)
    }

    private var topBar: some View {
        HStack {
            Button { vm.showRequestSheet = true } label: {
                Label("Generation Request", systemImage: "slider.horizontal.3")
            }

            Spacer()

            Button { vm.showTracksSheet = true } label: {
                Label("Tracks", systemImage: "music.note.list")
            }
        }
        .padding(.horizontal, 16)
        .font(.system(size: 14, weight: .semibold))
    }

    private func selectedTrackCard(_ track: TrackModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last generated")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                if
                    let cover = track.cover,
                    let uiImage = UIImage(data: cover)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.thinMaterial)
                        .frame(width: 56, height: 56)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(.secondary)
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(2)

                    if !track.tags.isEmpty {
                        Text(track.tags)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }

            HStack {
                Text("\(track.audioData.count / 1024) KB")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Spacer()

                
                Text(track.createdAt, style: .time)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
