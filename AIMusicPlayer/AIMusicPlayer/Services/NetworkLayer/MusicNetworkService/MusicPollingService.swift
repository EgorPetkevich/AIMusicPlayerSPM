//
//  MusicPollingService.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

final class MusicPollingService {

    private let session = NetworkSessionProvider()
    private var timer: Timer?
    private let maxAttempts = 20
    private let interval: TimeInterval = 5

    func startPolling(
        taskId: String,
        completion: @escaping (
            _ track: MusicStatusResponse.Track?,
            _ error: String?
        ) -> Void
    ) {
        stop()

        var attempts = 0
        var nilResponsesStreak = 0
        let maxNilResponsesStreak = 3

        timer = Timer.scheduledTimer(withTimeInterval: interval,
                                     repeats: true)
        { [weak self] timer in
            guard let self else { return }
            attempts += 1

            if attempts >= self.maxAttempts {
                timer.invalidate()
                completion(nil, MusicServiceError.pollingTimeout.localizedDescription)
                return
            }

            let request = GetMusicStatusRequest(taskId: taskId)

            self.session.send(request: request) { [weak self] (response: MusicStatusResponse?) in
                guard let self else { return }

                guard let response else {
                    nilResponsesStreak += 1
                    if nilResponsesStreak >= maxNilResponsesStreak {
                        self.stop()
                        DispatchQueue.main.async {
                            completion(nil, "Network error while polling. Please try again.")
                        }
                    }
                    return
                }

                nilResponsesStreak = 0

                if let status = response.statusCode,
                   status.isTerminal, status != .success {
                    self.stop()
                    DispatchQueue.main.async {
                        completion(nil, MusicServiceError.pollingTerminal(status.userMessage).localizedDescription)
                    }
                    return
                }

                let tracks = response.data.response?.sunoData ?? []
                if let track = tracks.first, !(track.streamAudioUrl ?? "").isEmpty {
                    self.stop()
                    DispatchQueue.main.async {
                        completion(track, nil)
                    }
                    return
                }

                print("[Polling]: response=\(response.code) status=\(response.statusCode?.userMessage ?? "nil") ⏳")
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
