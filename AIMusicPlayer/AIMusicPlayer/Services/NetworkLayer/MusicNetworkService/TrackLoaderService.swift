//
//  TrackLoader.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation
import SwiftUI

final class TrackLoaderService: GenerateTrackLoaderUseCaseProtocol {

    private let session: URLSession
    private let retry: RetryPolicy

    init(
        session: URLSession = .shared,
        retry: RetryPolicy = .default
    ) {
        self.session = session
        self.retry = retry
    }

    func load(
        track: MusicStatusResponse.Track,
        completion: @escaping (TrackModel?, String?) -> Void
    ) {
        guard let audioURL = makeAudioURL(from: track) else {
            return finish(nil, MusicServiceError.invalidURL.localizedDescription, completion)
        }

        let group = DispatchGroup()
        var audioData: Data?
        var cover: Data?

        var audioError: String?
        var coverError: String?

        fetchDataWithRetry(from: audioURL, group: group) { data, error in
            audioData = data
            audioError = error
        }

        if let imageURL = makeImageURL(from: track) {
            fetchDataWithRetry(from: imageURL, group: group) { data, error in
                cover = data
                coverError = error
            }
        }

        group.notify(queue: .global(qos: .userInitiated)) {
            guard let audioData else {
                return self.finish(nil,
                                   MusicServiceError.audioLoadFailed(audioError ?? "Unknown").localizedDescription,
                                   completion)
            }

            if let coverError {
                print("[Cover warning]: \(coverError)")
            }

            let model = self.makeTrackModel(from: track, audioData: audioData, cover: cover)
            self.finish(model, nil, completion)
        }
    }
}

// MARK: - Private helpers

private extension TrackLoaderService {

    func makeAudioURL(from track: MusicStatusResponse.Track) -> URL? {
        let audioString = (track.audioUrl?.isEmpty == false) ? track.audioUrl : track.streamAudioUrl
        guard let s = audioString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !s.isEmpty,
              let url = URL(string: s)
        else { return nil }
        return url
    }

    func makeImageURL(from track: MusicStatusResponse.Track) -> URL? {
        guard let s = track.imageUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              !s.isEmpty,
              let url = URL(string: s)
        else { return nil }
        return url
    }

    func fetchDataWithRetry(
        from url: URL,
        group: DispatchGroup,
        completion: @escaping (Data?, String?) -> Void
    ) {
        group.enter()
        attemptFetch(url: url, attempt: 0) { data, error in
            completion(data, error)
            group.leave()
        }
    }

    func attemptFetch(
        url: URL,
        attempt: Int,
        completion: @escaping (Data?, String?) -> Void
    ) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 30

        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

            // HTTP status check
            if
                let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode)
            {
                retryOrFinish(
                    attempt: attempt,
                    message: "HTTP \(http.statusCode)",
                    url: url,
                    completion: completion
                )
                return
            }

            if let error {
                retryOrFinish(
                    attempt: attempt,
                    message: error.localizedDescription,
                    url: url,
                    completion: completion
                )
                return
            }

            guard let data, !data.isEmpty else {
                self.retryOrFinish(
                    attempt: attempt,
                    message: "Empty data",
                    url: url,
                    completion: completion
                )
                return
            }

            completion(data, nil)
        }.resume()
    }

    func retryOrFinish(
        attempt: Int,
        message: String,
        url: URL,
        completion: @escaping (Data?, String?) -> Void
    ) {
        if attempt < retry.maxRetries {
            let delay = retry.delay(for: attempt)
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
                self.attemptFetch(url: url, attempt: attempt + 1, completion: completion)
            }
        } else {
            completion(nil, message)
        }
    }

    func makeTrackModel(
        from track: MusicStatusResponse.Track,
        audioData: Data,
        cover: Data?
    ) -> TrackModel {
        TrackModel(
            uuid: track.id,
            audioData: audioData,
            cover: cover,
            title: track.title ?? "Untitled",
            tags: track.tags ?? "",
            prompt: track.prompt,
            modelName: track.modelName,
            createdAt: makeDate(from: track.createTime) ?? .now,
            duration: track.duration
        )
    }

    func makeDate(from createTime: Int64?) -> Date? {
        guard let createTime else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(createTime))
    }

    func finish(_ model: TrackModel?, _ error: String?, _ completion: @escaping (TrackModel?, String?) -> Void) {
        DispatchQueue.main.async { completion(model, error) }
    }
}
