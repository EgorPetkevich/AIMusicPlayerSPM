//
//  MusicPlayerService.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI
import Foundation
import AVFoundation
import MediaPlayer


@Observable
final class MusicPlayerService: NSObject, ObservableObject, AVAudioPlayerDelegate {
 
    static let shared = MusicPlayerService()
    
    var queue: [TrackModel] = []
        
    var currentTrack: TrackModel?
    
    var isPresenting: Bool { currentTrack != nil }

    var currentTime: TimeInterval = 0
    var duration: TimeInterval { audioPlayer?.duration ?? 0 }
    
    private(set) var isPlaying: Bool = false
    private(set) var volume: Float = 1.0  // 0...1
    
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    
    private let analytics: AnalyticsServiceProtocol
    
    private override init() {
        self.analytics = AnalyticsService()
        super.init()
        configureAudioSession()
        setupRemoteTransportControls()
        observeSystemVolume()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try session.setActive(true)

            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    private func observeSystemVolume() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemVolumeChanged),
            name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
    }

    @objc private func systemVolumeChanged(_ notification: Notification) {
        let systemVolume = AVAudioSession.sharedInstance().outputVolume
        print("Device system volume:", systemVolume)
        self.setVolume(systemVolume)
    }
    
    func onTrackDelete(_ track: TrackModel) {
        if track.id == currentTrack?.id {
            currentTrack = nil
            stop()
        }
        queue.removeAll(where: { $0.id == track.id })
    }
  
    // MARK: - Public API для UI
    
    func setQueue(_ tracks: [TrackModel]) {
        self.queue = tracks
    }
    
    func play(track: TrackModel) {
        do {
            let player = try AVAudioPlayer(data: track.audioData)
            player.delegate = self
            player.volume = volume
            player.prepareToPlay()

            audioPlayer = player
            currentTrack = track
            currentTime = 0

            player.play()
            isPlaying = true
            
            analytics.track(.playbackStart(track: track, source: .player))

            updateNowPlayingInfo()

            MPNowPlayingInfoCenter.default().playbackState = .playing
            startProgressTimer()
        } catch {
            print("Play error: \(error)")
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
        updateNowPlayingPlaybackState()
        MPNowPlayingInfoCenter.default().playbackState = .paused
    }

    func resume() {
        guard let player = audioPlayer else { return }
        player.play()
        isPlaying = true
        startProgressTimer()
        updateNowPlayingPlaybackState()
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func togglePlayPause() {
        isPlaying ? pause() : resume()
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        currentTrack = nil
        audioPlayer = nil
        currentTime = 0
        stopProgressTimer()
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // След / пред трек (для UI)
    func playNext() {
        forward()
    }
    
    func playPrevious() {
        backward()
    }
    
    // Перемотка слайдером
    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        let clamped = max(0, min(time, player.duration))
        player.currentTime = clamped
        currentTime = clamped
        updateNowPlayingPlaybackState()
    }
    
    // Громкость слайдером
    func setVolume(_ value: Float) {
        let clamped = max(0, min(value, 1))
        volume = clamped
        audioPlayer?.volume = clamped
    }
    
    // MARK: - Навигация по очереди
    
    func forward() {
        guard !queue.isEmpty else { return }
        
        guard let current = currentTrack,
              let currentIndex = queue.firstIndex(where: { $0._id == current._id }) else {
            if let first = queue.first {
                play(track: first)
            }
            return
        }
        
        let nextIndex = queue.index(after: currentIndex)
        
        if nextIndex < queue.count {
            let nextTrack = queue[nextIndex]
            play(track: nextTrack)
        } else if let first = queue.first {
            play(track: first)
        }
    }
    
    func backward() {
        guard !queue.isEmpty else { return }
        
        if let current = currentTrack,
           let currentIndex = queue.firstIndex(where: { $0._id == current._id }) {
            
            if currentIndex > queue.startIndex {
                let prevIndex = queue.index(before: currentIndex)
                let prevTrack = queue[prevIndex]
                play(track: prevTrack)
            } else if let last = queue.last {
                play(track: last)
            }
        } else if let last = queue.last {
            play(track: last)
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        forward()
    }
    
    // MARK: - Прогресс (таймер)
    
    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true,
            block: { [weak self] _ in
                guard let self, let player = self.audioPlayer else { return }
                self.currentTime = player.currentTime
            }
        )
        RunLoop.main.add(progressTimer!, forMode: .common)
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    

    
    private func updateNowPlayingInfo() {
        guard let track = currentTrack,
              let player = audioPlayer else { return }
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.subtitleText,
            MPMediaItemPropertyPlaybackDuration: player.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        
        if let data = track.cover,
           let image = UIImage(data: data) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateNowPlayingPlaybackState() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo,
              let player = audioPlayer else { return }
        
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    // MARK: - Remote controls
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.forward()
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.backward()
            return .success
        }
        
        // MARK: - Перемотка ползунком (самое главное)
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard
                let self,
                let event = event as? MPChangePlaybackPositionCommandEvent
            else { return .commandFailed }
            
            self.seek(to: event.positionTime)   // позиция в секундах
            return .success
        }
        
    }
    
    
}
