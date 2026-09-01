//
//  FollowUpsView.swift
//  You
//

import SwiftUI

/// Everything the patient still needs to act on: referrals with their expiry dates,
/// and follow-up tasks sorted by due date. Reads from SampleData until the repository exists.
struct FollowUpsView: View {
    private let referrals = SampleData.referrals
    private let tasks = SampleData.followUpTasks

    private var openTasks: [FollowUpTask] {
        tasks.filter { !$0.isCompleted }.sorted { $0.dueOn < $1.dueOn }
    }

    private var completedTasks: [FollowUpTask] {
        tasks.filter(\.isCompleted)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Your referrals") {
                    ForEach(referrals) { referral in
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
                    ForEach(openTasks) { task in
                        taskRow(task)
                    }
                }

                if !completedTasks.isEmpty {
                    Section("Done") {
                        ForEach(completedTasks) { task in
                            taskRow(task)
                        }
                    }
                }
            }
            .navigationTitle("Follow-ups")
        }
    }

    @ViewBuilder
    private func taskRow(_ task: FollowUpTask) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : .secondary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
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
    FollowUpsView()
}
