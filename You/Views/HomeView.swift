//
//  HomeView.swift
//  You
//

import SwiftUI

/// The first screen: a short "needs your attention" summary, then the patient's
/// pathology results newest first. Reads from SampleData until the repository exists.
struct HomeView: View {
    @State private var isAddingResult = false

    private let results = SampleData.results
    private let followUpTasks = SampleData.followUpTasks

    /// Flagged markers from the most recent report.
    private var attentionMarkers: [MarkerReading] {
        results.first?.flaggedMarkers ?? []
    }

    private var openTaskCount: Int {
        followUpTasks.filter { !$0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            List {
                if !attentionMarkers.isEmpty || openTaskCount > 0 {
                    Section("Needs your attention") {
                        ForEach(attentionMarkers) { reading in
                            Label {
                                Text("\(reading.markerName) is outside the healthy range")
                            } icon: {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                        if openTaskCount > 0 {
                            Label {
                                Text("^[\(openTaskCount) follow-up](inflect: true) waiting in Follow-ups")
                            } icon: {
                                Image(systemName: "checklist")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                Section("Your results") {
                    ForEach(results) { result in
                        NavigationLink(value: result) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.collectedOn.formatted(date: .abbreviated, time: .omitted))
                                    .font(.headline)
                                Text(summaryLine(for: result))
                                    .font(.subheadline)
                                    .foregroundStyle(result.flaggedMarkers.isEmpty ? Color.secondary : Color.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("You.")
            .navigationDestination(for: PathologyResult.self) { result in
                ResultDetailView(result: result)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingResult = true
                    } label: {
                        Label("Add a result", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingResult) {
                RecordResultView()
            }
        }
    }

    private func summaryLine(for result: PathologyResult) -> String {
        let flagged = result.flaggedMarkers
        if flagged.isEmpty {
            return "All \(result.markers.count) markers within healthy range"
        }
        let names = flagged.map(\.markerName).joined(separator: ", ")
        return "\(names) outside healthy range"
    }
}

#Preview {
    HomeView()
}
