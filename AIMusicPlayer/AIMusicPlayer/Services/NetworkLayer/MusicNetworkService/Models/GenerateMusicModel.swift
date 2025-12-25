//
//  GenerateMusicModel.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

struct GenerateMusicModel {
    enum Gender: String { case m, f }
    enum Models: String { case V5, V4, V4_5 }

    enum Value: Double {
        case low = 0.3
        case medium = 0.6
        case high = 0.9
    }

    let prompt: String
    let customMode: Bool = false
    let instrumental: Bool
    let model: Models
    let callBackUrl: String = ApiPaths.callBack
    let style: String
    let title: String
    let negativeTags: String?
    let vocalGender: Gender?
    let styleWeight: Value?
    let weirdnessConstraint: Value?
    let audioWeight: Value?
    let personaId: String?
    
    init(prompt: String,
         instrumental: Bool,
         model: Models,
         style: String,
         title: String,
         negativeTags: String? = nil,
         vocalGender: Gender? = nil,
         styleWeight: Value? = nil,
         weirdnessConstraint: Value? = nil,
         audioWeight: Value? = nil,
         personaId: String? = nil
    ) {
        self.prompt = prompt
        self.instrumental = instrumental
        self.model = model
        self.style = style
        self.title = title
        self.negativeTags = negativeTags
        self.vocalGender = vocalGender
        self.styleWeight = styleWeight
        self.weirdnessConstraint = weirdnessConstraint
        self.audioWeight = audioWeight
        self.personaId = personaId
    }
}
