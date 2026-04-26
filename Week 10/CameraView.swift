//
//  CameraView.swift
//  JawbreakSimple
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @Binding var scans: [FaceScan]

    @State private var swellingScore = 5
    @State private var tightnessScore = 5
    @State private var numbnessScore = 5
    @State private var notes = ""

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    @State private var faceWidth: Float?
    @State private var cheekWidth: Float?
    @State private var jawWidth: Float?
    @State private var lowerFaceHeight: Float?
    @State private var asymmetryScore: Float?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Face Snapshot") {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: selectedImageData == nil ? "camera.fill" : "checkmark.circle.fill")
                            Text(selectedImageData == nil ? "Select Face Photo" : "Face Photo Selected")
                        }
                    }

                    if selectedImageData != nil {
                        Text("Your snapshot will be saved with this scan.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Take a photo in Camera.app, then select it here.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("TrueDepth Face Metrics") {
                    Button {
                        captureSimulatedTrueDepthMetrics()
                    } label: {
                        HStack {
                            Image(systemName: faceWidth == nil ? "faceid" : "checkmark.circle.fill")
                            Text(faceWidth == nil ? "Capture TrueDepth Metrics" : "Metrics Captured!")
                        }
                    }

                    if let faceWidth,
                       let cheekWidth,
                       let jawWidth,
                       let lowerFaceHeight,
                       let asymmetryScore {
                        VStack(alignment: .leading, spacing: 6) {
                            metricText("Face Width", value: faceWidth)
                            metricText("Cheek Width", value: cheekWidth)
                            metricText("Jaw Width", value: jawWidth)
                            metricText("Lower Face Height", value: lowerFaceHeight)
                            metricText("Asymmetry", value: asymmetryScore)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    } else {
                        Text("This is a placeholder. Stand by for future changes!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Recovery Scores") {
                    sliderRow("Swelling", value: $swellingScore)
                    sliderRow("Tightness", value: $tightnessScore)
                    sliderRow("Numbness", value: $numbnessScore)
                }

                Section("Notes") {
                    TextField("How does your jaw feel today?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button {
                        saveScan()
                    } label: {
                        Text("Save Scan")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("New Scan")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
                }
            }
        }
    }

    private func sliderRow(_ title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue)/10")
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = Int($0.rounded()) }
                ),
                in: 0...10,
                step: 1
            )
        }
        .padding(.vertical, 4)
    }

    private func metricText(_ title: String, value: Float) -> some View {
        Text("\(title): \(String(format: "%.3f", value)) m")
    }

    //Stub
    private func captureSimulatedTrueDepthMetrics() {
        faceWidth = Float.random(in: 0.135...0.155)
        cheekWidth = Float.random(in: 0.120...0.145)
        jawWidth = Float.random(in: 0.105...0.130)
        lowerFaceHeight = Float.random(in: 0.080...0.105)
        asymmetryScore = Float.random(in: 0.005...0.030)
    }

    private func saveScan() {
        let scan = FaceScan(
            swellingScore: swellingScore,
            tightnessScore: tightnessScore,
            numbnessScore: numbnessScore,
            notes: notes,
            imageData: selectedImageData,
            faceWidth: faceWidth,
            cheekWidth: cheekWidth,
            jawWidth: jawWidth,
            lowerFaceHeight: lowerFaceHeight,
            asymmetryScore: asymmetryScore
        )

        scans.append(scan)
        dismiss()
    }
}

#Preview {
    CameraView(scans: .constant([FaceScan.sample]))
}
