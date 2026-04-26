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
                        "No scans yet",
                        systemImage: "face.smiling",
                        description: Text("Take your first scan to start tracking recovery.")
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
            Section("Change Since First Scan") {
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
            
            

            Section("Scan History") {
                ForEach(sortedScans) { scan in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(scan.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)

                        Text("Swelling: \(scan.swellingScore)/10")
                        Text("Tightness: \(scan.tightnessScore)/10")
                        Text("Numbness: \(scan.numbnessScore)/10")

                        if !scan.notes.isEmpty {
                            Text(scan.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
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

    private func changeText(_ change: Int) -> String {
        if change > 0 {
            return "+\(change)"
        } else {
            return "\(change)"
        }
    }
}

#Preview {
    EvolutionViewer(scans: [
        FaceScan(swellingScore: 8, tightnessScore: 7, numbnessScore: 6, notes: "Early recovery"),
        FaceScan(swellingScore: 5, tightnessScore: 4, numbnessScore: 3, notes: "Feeling better")
    ])
    
    

}

