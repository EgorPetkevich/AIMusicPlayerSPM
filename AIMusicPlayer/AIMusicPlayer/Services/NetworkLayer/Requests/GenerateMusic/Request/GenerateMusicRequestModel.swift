//
//  GenerateMusicRequest.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

///{
///   "prompt": "A calm and relaxing piano track with soft melodies",
///   "customMode": true,
///   "instrumental": true,
///   "model": "V4",
///   "callBackUrl": "https://api.example.com/callback",
///   "style": "Classical",
///   "title": "Peaceful Piano Meditation",
///   "negativeTags": "Heavy Metal, Upbeat Drums",
///   "vocalGender": "m",
///   "styleWeight": 0.65,
///   "weirdnessConstraint": 0.65,
///   "audioWeight": 0.65,
///   "personaId": "persona_123"
///}

struct GenerateMusicRequestModel: Encodable {
    let prompt: String
    let customMode: Bool
    let instrumental: Bool
    let model: String
    let callBackUrl: String
    let style: String
    let title: String
    let negativeTags: String?
    let vocalGender: String?
    let styleWeight: Double?
    let weirdnessConstraint: Double?
    let audioWeight: Double?
    let personaId: String?
}

extension GenerateMusicRequestModel {
    init(model: GenerateMusicModel) {
        self.init(
            prompt: model.prompt,
            customMode: model.customMode,
            instrumental: model.instrumental,
            model: model.model.rawValue,
            callBackUrl: model.callBackUrl,
            style: model.style,
            title: model.title,
            negativeTags: model.negativeTags,
            vocalGender: model.vocalGender?.rawValue,
            styleWeight: model.styleWeight?.rawValue,
            weirdnessConstraint: model.weirdnessConstraint?.rawValue,
            audioWeight: model.audioWeight?.rawValue,
            personaId: model.personaId
        )
    }
}
