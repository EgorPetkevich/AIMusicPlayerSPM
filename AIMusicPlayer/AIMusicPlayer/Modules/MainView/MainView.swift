//
//  MainView.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation
import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var musicPlayer: MusicPlayerService
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                GenerateTrackAssembler.make()
                    .padding(.bottom, musicPlayer.isPresenting ? 64.0 + 30.0 : 0)

                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // mini player
                        if let track = musicPlayer.currentTrack {
                            MiniPlayerView(track: track)
                                .padding(.bottom, 30.0)
                                
                        }
                    
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            
        }
    }
}
