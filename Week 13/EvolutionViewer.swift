//
//  EvolutionViewer.swift
//  JawbreakSimple
//

import SwiftUI
import UIKit

struct EvolutionViewer: View {
    let scans: [FaceScan]

    private var sortedScans: [FaceScan] {
        scans.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sortedScans.isEmpty {
                    ContentUnavailableView(
                        "No snapshots yet",
                        systemImage: "face.smiling",
                        description: Text("Take your first snapshot to start tracking recovery.")
                    )
                } else {
                    evolutionContent
                }
            }
            .navigationTitle("Evolution")
        }
    }

    private var evolutionContent: some View {
        let first = sortedScans.first!
        let latest = sortedScans.last!

        return List {
            Section("Symptom Change Since First Snapshot") {
                changeRow(
                    title: "Swelling",
                    firstValue: first.swellingScore,
                    latestValue: latest.swellingScore
                )

                changeRow(
                    title: "Tightness",
                    firstValue: first.tightnessScore,
                    latestValue: latest.tightnessScore
                )

                changeRow(
                    title: "Numbness",
                    firstValue: first.numbnessScore,
                    latestValue: latest.numbnessScore
                )
            }

            Section("TruDepth Metric Change") {
                metricChangeRow(
                    title: "Face Width",
                    firstValue: first.faceWidth,
                    latestValue: latest.faceWidth
                )

                metricChangeRow(
                    title: "Cheek Width",
                    firstValue: first.cheekWidth,
                    latestValue: latest.cheekWidth
                )

                metricChangeRow(
                    title: "Jaw Width",
                    firstValue: first.jawWidth,
                    latestValue: latest.jawWidth
                )

                metricChangeRow(
                    title: "Lower Face Height",
                    firstValue: first.lowerFaceHeight,
                    latestValue: latest.lowerFaceHeight
                )

                metricChangeRow(
                    title: "Asymmetry",
                    firstValue: first.asymmetryScore,
                    latestValue: latest.asymmetryScore
                )
            }

            Section("Snapshot History") {
                ForEach(sortedScans) { scan in
                    VStack(alignment: .leading, spacing: 10) {
                        if let imageData = scan.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .clipped()
                        }

                        Text(scan.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Swelling: \(scan.swellingScore)/10")
                            Text("Tightness: \(scan.tightnessScore)/10")
                            Text("Numbness: \(scan.numbnessScore)/10")
                        }

                        if hasTrueDepthMetrics(scan) {
                            Divider()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("TruDepth Metrics")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                optionalMetricText("Face Width", value: scan.faceWidth)
                                optionalMetricText("Cheek Width", value: scan.cheekWidth)
                                optionalMetricText("Jaw Width", value: scan.jawWidth)
                                optionalMetricText("Lower Face Height", value: scan.lowerFaceHeight)
                                optionalMetricText("Asymmetry", value: scan.asymmetryScore)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        if !scan.notes.isEmpty {
                            Divider()

                            Text(scan.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func changeRow(title: String, firstValue: Int, latestValue: Int) -> some View {
        let change = latestValue - firstValue

        return HStack {
            Text(title)
            Spacer()

            Text(changeText(change))
                .foregroundStyle(change <= 0 ? .green : .orange)
                .fontWeight(.semibold)
        }
    }

    private func metricChangeRow(title: String, firstValue: Float?, latestValue: Float?) -> some View {
        HStack {
            Text(title)
            Spacer()

            if let firstValue, let latestValue {
                let change = latestValue - firstValue
                Text(String(format: "%+.3f m", change))
                    .foregroundStyle(change <= 0 ? .green : .orange)
                    .fontWeight(.semibold)
            } else {
                Text("No data")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func optionalMetricText(_ title: String, value: Float?) -> some View {
        Group {
            if let value {
                Text("\(title): \(String(format: "%.3f", value)) m")
            }
        }
    }

    private func hasTrueDepthMetrics(_ scan: FaceScan) -> Bool {
        scan.faceWidth != nil ||
        scan.cheekWidth != nil ||
        scan.jawWidth != nil ||
        scan.lowerFaceHeight != nil ||
        scan.asymmetryScore != nil
    }

    private func changeText(_ change: Int) -> String {
        if change > 0 {
            return "+\(change)"
        } else {
            return "\(change)"
        }
    }
}



// Sample Snapshot Metrics
#Preview {
    EvolutionViewer(scans: [
        FaceScan(
            swellingScore: 8,
            tightnessScore: 7,
            numbnessScore: 6,
            notes: "Early recovery",
            faceWidth: 0.150,
            cheekWidth: 0.140,
            jawWidth: 0.128,
            lowerFaceHeight: 0.100,
            asymmetryScore: 0.025
        ),
        FaceScan(
            swellingScore: 5,
            tightnessScore: 4,
            numbnessScore: 3,
            notes: "Feeling better",
            faceWidth: 0.144,
            cheekWidth: 0.132,
            jawWidth: 0.119,
            lowerFaceHeight: 0.092,
            asymmetryScore: 0.012
        )
    ])
}
