//
//  TruDepthScannerView.swift
//  JawbreakSimple
//
//  Created by Arian Kharazmi on 4/8/26.
// (week 11 of 13)


import SwiftUI
import ARKit
import SceneKit

struct TruDepthScannerView: View {
    let onCapture: (FaceMetrics) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var latestMetrics: FaceMetrics?
    @State private var faceDetected = false

    var body: some View {
        ZStack {
            if ARFaceTrackingConfiguration.isSupported {
                TruDepthARView(
                    latestMetrics: $latestMetrics,
                    faceDetected: $faceDetected
                )
                .ignoresSafeArea()
            } else {
                unsupportedView
            }

            VStack {
                scannerHeader

                Spacer()

                metricsCard
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var scannerHeader: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .fontWeight(.semibold)

            Spacer()

            Text("TrueDepth Scan")
                .font(.headline)

            Spacer()

            Button("Use") {
                if let latestMetrics {
                    onCapture(latestMetrics)
                    dismiss()
                }
            }
            .fontWeight(.semibold)
            .disabled(latestMetrics == nil)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var metricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: faceDetected ? "faceid" : "faceid")
                    .foregroundStyle(faceDetected ? .green : .orange)

                Text(faceDetected ? "Face detected" : "Scanning for face")
                    .fontWeight(.semibold)
            }

            if let latestMetrics {
                Divider()

                metricLine("Face Width", latestMetrics.faceWidth)
                metricLine("Face Height", latestMetrics.faceHeight)
                metricLine("Face Depth", latestMetrics.faceDepth)
                metricLine("Mid-Face Width", latestMetrics.midFaceWidth)
                metricLine("Lower-Face Width", latestMetrics.lowerFaceWidth)
                metricLine("Lower-Face Height", latestMetrics.lowerFaceHeight)
                metricLine("Asymmetry", latestMetrics.asymmetryScore)

                Text("Hold your face neutral and keep distance consistent between Jawbreak scans.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            } else {
                Text("Center your face in the TruDepth camera. Metrics will appear when ARKit detects your face mesh.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var unsupportedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("TruDepth Not Supported")
                .font(.title2)
                .fontWeight(.bold)

            Text("ARKit face tracking requires an iPhone or iPad with a TruDepth front camera.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }

    private func metricLine(_ title: String, _ value: Float) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "%.1f mm", value * 1000))
                .fontWeight(.semibold)
        }
        .font(.caption)
    }
}

struct TruDepthARView: UIViewRepresentable {
    @Binding var latestMetrics: FaceMetrics?
    @Binding var faceDetected: Bool

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.session.delegate = context.coordinator
        view.automaticallyUpdatesLighting = true
        view.scene = SCNScene()

        if ARFaceTrackingConfiguration.isSupported {
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true

            view.session.run(
                configuration,
                options: [.resetTracking, .removeExistingAnchors]
            )
        }

        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, ARSessionDelegate {
        private let parent: TruDepthARView

        init(parent: TruDepthARView) {
            self.parent = parent
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else {
                DispatchQueue.main.async {
                    self.parent.faceDetected = false
                }
                return
            }

            let metrics = Self.computeMetrics(from: faceAnchor.geometry.vertices)

            DispatchQueue.main.async {
                self.parent.faceDetected = true
                self.parent.latestMetrics = metrics
            }
        }

        private static func computeMetrics(from vertices: [simd_float3]) -> FaceMetrics {
            guard !vertices.isEmpty else {
                return FaceMetrics(
                    faceWidth: 0,
                    faceHeight: 0,
                    faceDepth: 0,
                    midFaceWidth: 0,
                    lowerFaceWidth: 0,
                    lowerFaceHeight: 0,
                    asymmetryScore: 0
                )
            }

            let minX = vertices.map(\.x).min() ?? 0
            let maxX = vertices.map(\.x).max() ?? 0
            let minY = vertices.map(\.y).min() ?? 0
            let maxY = vertices.map(\.y).max() ?? 0
            let minZ = vertices.map(\.z).min() ?? 0
            let maxZ = vertices.map(\.z).max() ?? 0

            let faceWidth = maxX - minX
            let faceHeight = maxY - minY
            let faceDepth = maxZ - minZ

            let midFaceWidth = widthForVerticalBand(
                vertices: vertices,
                minY: minY,
                maxY: maxY,
                lowerRatio: 0.42,
                upperRatio: 0.68
            )

            let lowerFaceWidth = widthForVerticalBand(
                vertices: vertices,
                minY: minY,
                maxY: maxY,
                lowerRatio: 0.12,
                upperRatio: 0.42
            )

            let lowerFaceHeight = faceHeight * 0.42

            // Simple symmetry proxy:
            // Compare left and right horizontal extents from the local face center.
            let leftExtent = abs(minX)
            let rightExtent = abs(maxX)
            let asymmetryScore = abs(leftExtent - rightExtent)

            return FaceMetrics(
                faceWidth: faceWidth,
                faceHeight: faceHeight,
                faceDepth: faceDepth,
                midFaceWidth: midFaceWidth,
                lowerFaceWidth: lowerFaceWidth,
                lowerFaceHeight: lowerFaceHeight,
                asymmetryScore: asymmetryScore
            )
        }

        private static func widthForVerticalBand(
            vertices: [simd_float3],
            minY: Float,
            maxY: Float,
            lowerRatio: Float,
            upperRatio: Float
        ) -> Float {
            let height = maxY - minY

            guard height > 0 else {
                return 0
            }

            let lowerY = minY + height * lowerRatio
            let upperY = minY + height * upperRatio

            let bandVertices = vertices.filter { vertex in
                vertex.y >= lowerY && vertex.y <= upperY
            }

            guard !bandVertices.isEmpty else {
                return 0
            }

            let bandMinX = bandVertices.map(\.x).min() ?? 0
            let bandMaxX = bandVertices.map(\.x).max() ?? 0

            return bandMaxX - bandMinX
        }
    }
}

#Preview {
    TruDepthScannerView { _ in }
}
