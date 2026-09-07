//
//  FollowUpsView.swift
//  You
//

import SwiftUI

/// Everything the patient still needs to act on: referrals with their expiry dates,
/// and follow-up tasks sorted by due date. Tapping a task's circle marks it done.
struct FollowUpsView: View {
    @ObservedObject var viewModel: FollowUpsViewModel

    @State private var isAddingReferral = false

    var body: some View {
        NavigationStack {
            List {
                Section("Your referrals") {
                    if viewModel.referrals.isEmpty {
                        Text("No referrals tracked yet. Add one and the app will remind you before it expires.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(viewModel.referrals) { referral in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(referral.purpose)
                                .font(.headline)
                            Text("From \(referral.issuedBy)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if referral.isExpired() {
                                Text("Expired \(referral.expiresOn.formatted(date: .abbreviated, time: .omitted)) — ask your GP for a new one")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                            } else {
                                Text("Use by \(referral.expiresOn.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("To do") {
                    if viewModel.openTasks.isEmpty {
                        Text("Nothing waiting — you're up to date.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(viewModel.openTasks) { task in
                        taskRow(task)
                    }
                }

                if !viewModel.completedTasks.isEmpty {
                    Section("Done") {
                        ForEach(viewModel.completedTasks) { task in
                            taskRow(task)
                        }
                    }
                }
            }
            .navigationTitle("Follow-ups")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingReferral = true
                    } label: {
                        Label("Track a referral", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingReferral) {
                AddReferralView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.load()
            }
        }
    }

    @ViewBuilder
    private func taskRow(_ task: FollowUpTask) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                viewModel.toggleCompletion(of: task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
            .accessibilityLabel(task.isCompleted ? "Mark \(task.title) as not done" : "Mark \(task.title) as done")

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(task.isCompleted ? Color.secondary : Color.primary)
                if let detail = task.detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let completedOn = task.completedOn {
                    Text("Done \(completedOn.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if task.isOverdue() {
                    Text("Was due \(task.dueOn.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Text("Due \(task.dueOn.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    FollowUpsView(viewModel: FollowUpsViewModel(repository: InMemoryHealthRecordRepository()))
}
