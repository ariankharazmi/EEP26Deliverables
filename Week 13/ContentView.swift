//
//  ContentView.swift
//  JawbreakSimple
//

import SwiftUI

struct ContentView: View {
    @State private var scans: [FaceScan] = []
    @State private var showingCamera = false
    @State private var showingEvolution = false
    @State private var hasLoadedScans = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "faceid")
                        .font(.system(size: 64, weight: .regular))
                        .foregroundStyle(.blue)

                    VStack(spacing: 8) {
                        Text("Jawbreak")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)

                        Text("Track facial / jaw recovery over time.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .foregroundStyle(.black)
                    }

                    VStack(spacing: 16) {
                        Button {
                            showingCamera = true
                        } label: {
                            Text("New Snapshot")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button {
                            showingEvolution = true
                        } label: {
                            Text("Evolution Viewer")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.12))
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 32)

                    Text("\(scans.count) snapshots\(scans.count == 1 ? "" : "s") saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .foregroundStyle(.black)

                    VStack(spacing: 8) {
                        Text("Disclaimer")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text("Jawbreak is for recovery logging and personal progress tracking only. It is not a medical diagnostic tool.")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 24)
                            .foregroundStyle(.black)
                    }
                    .padding(.top, 4)

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !hasLoadedScans {
                    loadScans()
                    hasLoadedScans = true
                }
            }
            .sheet(isPresented: $showingCamera, onDismiss: {
                saveScans()
            }) {
                CameraView(scans: $scans)
            }
            .sheet(isPresented: $showingEvolution) {
                EvolutionViewer(scans: scans)
            }
        }
    }

    private func saveScans() {
        do {
            let data = try JSONEncoder().encode(scans)
            try data.write(to: scansFileURL, options: [.atomic])
            print("Saved \(scans.count) snapshot(s)")
        } catch {
            print("Failed to save snapshot: \(error)")
        }
    }

    private func loadScans() {
        guard FileManager.default.fileExists(atPath: scansFileURL.path) else {
            scans = []
            return
        }

        do {
            let data = try Data(contentsOf: scansFileURL)
            scans = try JSONDecoder().decode([FaceScan].self, from: data)
            print("Loaded \(scans.count) snapshot(s)")
        } catch {
            print("Failed to load snapshot: \(error)")
            scans = []
        }
    }

    private var scansFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("jawbreak_scans.json")
    }
}

#Preview {
    ContentView()
}
