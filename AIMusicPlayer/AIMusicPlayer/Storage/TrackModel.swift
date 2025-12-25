//
//  TrackModek.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation
import RealmSwift

final class TrackModel: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var uuid: String
    
    @Persisted var audioData: Data
    @Persisted var cover: Data?
    
    @Persisted var title: String
    @Persisted var tags: String
    @Persisted var prompt: String?
    @Persisted var modelName: String?
    @Persisted var createdAt: Date
    @Persisted var duration: Double?
    
    var subtitleText: String {
        
        if !tags.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return tags
        }

        if let duration {
            return duration.asTimeString
        }

        if let modelName, !modelName.isEmpty {
            return modelName
        }

        return "\(audioData.count / 1024) KB"
    }
    
    convenience init(
        uuid: String,
        audioData: Data,
        cover: Data? = nil,
        title: String,
        tags: String,
        prompt: String? = nil,
        modelName: String? = nil,
        createdAt: Date,
        duration: Double? = nil
    ) {
        self.init()
        self.uuid = uuid
        self.audioData = audioData
        self.cover = cover
        self.title = title
        self.tags = tags
        self.prompt = prompt
        self.modelName = modelName
        self.createdAt = createdAt
        self.duration = duration
    }
    
}
