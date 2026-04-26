//
//  CameraView.swift
//  JawbreakSimple
//

import SwiftUI

struct CameraView: View {
    @Binding var scans: [FaceScan]

    @State private var swellingScore = 5
    @State private var tightnessScore = 5
    @State private var numbnessScore = 5
    @State private var notes = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
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

    private func saveScan() {
        let scan = FaceScan(
            swellingScore: swellingScore,
            tightnessScore: tightnessScore,
            numbnessScore: numbnessScore,
            notes: notes
        )

        scans.append(scan)
        dismiss()
    }
}

#Preview {
    CameraView(scans: .constant([FaceScan.sample]))
}
