//
//  ContentView.swift
//  JawbreakSimple
//

import SwiftUI

struct ContentView: View {
    @State private var scans: [FaceScan] = []
    @State private var showingCamera = false
    @State private var showingEvolution = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Jawbreak")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Track jaw recovery over time.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    Button {
                        showingCamera = true
                    } label: {
                        Text("New Scan")
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
                            .background(.gray.opacity(0.15))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 32)

                Text("\(scans.count) scan\(scans.count == 1 ? "" : "s") saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingCamera) {
                CameraView(scans: $scans)
            }
            .sheet(isPresented: $showingEvolution) {
                EvolutionViewer(scans: scans)
            }
        }
    }
}

#Preview {
    ContentView()
}
