//
//  HomeView.swift
//  You
//

import SwiftUI
import Lottie

/// The first screen: a short "needs your attention" summary, then the patient's
/// pathology results newest first.
struct HomeView: View {
    @ObservedObject var resultsViewModel: ResultsViewModel
    @ObservedObject var followUpsViewModel: FollowUpsViewModel

    @State private var isAddingResult = false

    /// Flagged markers from the most recent report.
    private var attentionMarkers: [MarkerReading] {
        resultsViewModel.results.first?.flaggedMarkers ?? []
    }

    private var openTaskCount: Int {
        followUpsViewModel.openTasks.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 14) {
                            LottieView(animation: .named("Waving"))
                                .looping()
                                .frame(width: 116, height: 100)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Here's where your health is at today.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 20))
                }

                if !attentionMarkers.isEmpty || openTaskCount > 0 {
                    Section("Needs your attention") {
                        if let next = followUpsViewModel.mostUrgentAction {
                            Label {
                                Text("Next: \(next.patientAction), by \(next.actBy.formatted(date: .abbreviated, time: .omitted))")
                            } icon: {
                                Image(systemName: "arrow.forward.circle.fill")
                                    .foregroundStyle(AppColours.teal)
                            }
                        }
                        ForEach(attentionMarkers) { reading in
                            Label {
                                Text("\(reading.markerName) is outside the healthy range")
                            } icon: {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(AppColours.coral)
                            }
                        }
                        if openTaskCount > 0 {
                            Label {
                                Text(openTaskCount == 1
                                    ? "1 follow-up waiting in Follow-ups"
                                    : "\(openTaskCount) follow-ups waiting in Follow-ups")
                            } icon: {
                                Image(systemName: "checklist")
                                    .foregroundStyle(AppColours.teal)
                            }
                        }
                    }
                }

                Section("Your results") {
                    ForEach(resultsViewModel.results) { result in
                        NavigationLink(value: result) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.collectedOn.formatted(date: .abbreviated, time: .omitted))
                                    .font(.headline)
                                Text(summaryLine(for: result))
                                    .font(.subheadline)
                                    .foregroundStyle(result.flaggedMarkers.isEmpty ? Color.secondary : AppColours.coral)
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(AppColours.paleTeal)
            .contentMargins(.top, 0, for: .scrollContent)
            .navigationDestination(for: PathologyResult.self) { result in
                ResultDetailView(result: result)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("You.")
                        .font(.title)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingResult = true
                    } label: {
                        Label("Add a result", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingResult) {
                RecordResultView(viewModel: resultsViewModel)
            }
            .onAppear {
                resultsViewModel.load()
                followUpsViewModel.load()
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
    let repository = InMemoryHealthRecordRepository()
    return HomeView(
        resultsViewModel: ResultsViewModel(repository: repository),
        followUpsViewModel: FollowUpsViewModel(repository: repository)
    )
}
