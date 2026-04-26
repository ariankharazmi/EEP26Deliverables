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

    @State private var capturedMetrics: FaceMetrics?
    @State private var showingTruDepthScanner = false

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
                        showingTruDepthScanner = true
                    } label: {
                        HStack {
                            Image(systemName: capturedMetrics == nil ? "faceid" : "checkmark.circle.fill")
                            Text(capturedMetrics == nil ? "Open TruDepth Scanner" : "TruDepth Metrics Captured")
                        }
                    }

                    if let capturedMetrics {
                        VStack(alignment: .leading, spacing: 6) {
                            metricText("Face Width", value: capturedMetrics.faceWidth)
                            metricText("Face Height", value: capturedMetrics.faceHeight)
                            metricText("Face Depth", value: capturedMetrics.faceDepth)
                            metricText("Mid-Face Width", value: capturedMetrics.midFaceWidth)
                            metricText("Lower-Face Width", value: capturedMetrics.lowerFaceWidth)
                            metricText("Lower-Face Height", value: capturedMetrics.lowerFaceHeight)
                            metricText("Asymmetry", value: capturedMetrics.asymmetryScore)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    } else {
                        Text("Use the TrueDepth camera to capture real ARKit face-geometry measurements.")
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
            .sheet(isPresented: $showingTruDepthScanner) {
                NavigationStack {
                    TruDepthScannerView { metrics in
                        capturedMetrics = metrics
                    }
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
        Text("\(title): \(String(format: "%.1f", value * 1000)) mm")
    }

    private func saveScan() {
        let scan = FaceScan(
            swellingScore: swellingScore,
            tightnessScore: tightnessScore,
            numbnessScore: numbnessScore,
            notes: notes,
            imageData: selectedImageData,
            metrics: capturedMetrics
        )

        scans.append(scan)
        dismiss()
    }
}

#Preview {
    CameraView(scans: .constant([FaceScan.sample]))
}
