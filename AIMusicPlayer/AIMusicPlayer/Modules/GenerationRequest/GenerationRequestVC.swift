//
//  GenerationRequestVC.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import SwiftUI

struct GenerationRequestVC: View {

    // MARK: - Input state (local)

    @State private var prompt: String
    @State private var title: String
    @State private var style: String

    @State private var instrumental: Bool
    @State private var model: GenerateMusicModel.Models

    @State private var negativeTags: String
    @State private var vocalGender: GenerateMusicModel.Gender?

    @State private var styleWeight: GenerateMusicModel.Value?
    @State private var weirdness: GenerateMusicModel.Value?
    @State private var audioWeight: GenerateMusicModel.Value?

    @State private var personaId: String

    // MARK: - Callbacks

    private let onCancel: (() -> Void)?
    private let onGenerate: ((GenerateMusicModel) -> Void)?

    // MARK: - Validation

    private var canGenerate: Bool {
        !prompt.trimmed.isEmpty && !title.trimmed.isEmpty
    }

    // MARK: - Init

    init(
        generateMusicModel: GenerateMusicModel? = nil,
        onCancel: (() -> Void)? = nil,
        onGenerate: ((GenerateMusicModel) -> Void)? = nil
    ) {
        let m = generateMusicModel

        _prompt = State(initialValue: m?.prompt ?? "")
        _title  = State(initialValue: m?.title ?? "")
        _style  = State(initialValue: m?.style ?? "")

        _instrumental = State(initialValue: m?.instrumental ?? false)
        _model        = State(initialValue: m?.model ?? .V5)

        _negativeTags = State(initialValue: m?.negativeTags ?? "")
        _vocalGender  = State(initialValue: m?.vocalGender)

        _styleWeight  = State(initialValue: m?.styleWeight)
        _weirdness    = State(initialValue: m?.weirdnessConstraint)
        _audioWeight  = State(initialValue: m?.audioWeight)

        _personaId    = State(initialValue: m?.personaId ?? "")

        self.onCancel = onCancel
        self.onGenerate = onGenerate
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Base") {
                    TextField("Title", text: $title)

                    TextField("Prompt", text: $prompt, axis: .vertical)
                        .lineLimit(3...8)

                    TextField("Style / Tags", text: $style)
                }

                Section("Model") {
                    Picker("Model version", selection: $model) {
                        Text("V5").tag(GenerateMusicModel.Models.V5)
                        Text("V4.5").tag(GenerateMusicModel.Models.V4_5)
                        Text("V4").tag(GenerateMusicModel.Models.V4)
                    }

                    Toggle("Instrumental", isOn: $instrumental)

                    if !instrumental {
                        Picker("Vocal gender", selection: $vocalGender) {
                            Text("Any").tag(GenerateMusicModel.Gender?.none)
                            Text("Male").tag(GenerateMusicModel.Gender?.some(.m))
                            Text("Female").tag(GenerateMusicModel.Gender?.some(.f))
                        }
                    }
                }

                Section("Advanced") {
                    TextField("Negative tags", text: $negativeTags)

                    valuePicker("Style weight", selection: $styleWeight)
                    valuePicker("Weirdness", selection: $weirdness)
                    valuePicker("Audio weight", selection: $audioWeight)

                    TextField("Persona ID", text: $personaId)
                }
            }
            .navigationTitle("Generation Request")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel?() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Generate") {
                        onGenerate?(makeModel())
                    }
                    .disabled(!canGenerate)
                }
            }
        }
    }

    // MARK: - Factory

    private func makeModel() -> GenerateMusicModel {
        GenerateMusicModel(
            prompt: prompt.trimmed,
            instrumental: instrumental,
            model: model,
            style: style.trimmed,
            title: title.trimmed,
            negativeTags: negativeTags.trimmed.nilIfEmpty,
            vocalGender: instrumental ? nil : vocalGender,
            styleWeight: styleWeight,
            weirdnessConstraint: weirdness,
            audioWeight: audioWeight,
            personaId: personaId.trimmed.nilIfEmpty
        )
    }

    private func valuePicker(
        _ title: String,
        selection: Binding<GenerateMusicModel.Value?>
    ) -> some View {
        Picker(title, selection: selection) {
            Text("None").tag(GenerateMusicModel.Value?.none)
            Text("Low").tag(GenerateMusicModel.Value?.some(.low))
            Text("Medium").tag(GenerateMusicModel.Value?.some(.medium))
            Text("High").tag(GenerateMusicModel.Value?.some(.high))
        }
    }
}

