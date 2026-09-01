//
//  RecordResultView.swift
//  You
//

import SwiftUI

/// The form for typing in one marker from a paper pathology report.
/// Saving is not wired up yet — `RecordPathologyResultUseCase` will take over
/// the validation and saving when the use case layer is built.
struct RecordResultView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var markerName: String = ""
    @State private var valueText: String = ""
    @State private var unit: String = ""
    @State private var collectedOn: Date = Date()
    @State private var orderingClinician: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("From your report") {
                    TextField("Marker, e.g. Ferritin", text: $markerName)
                    TextField("Value, e.g. 9", text: $valueText)
                        .keyboardType(.decimalPad)
                    TextField("Unit, e.g. µg/L", text: $unit)
                }

                Section("About the test") {
                    DatePicker("Collected on", selection: $collectedOn, displayedComponents: .date)
                    TextField("Ordered by, e.g. Dr Tran", text: $orderingClinician)
                }

                Section {
                    Text("Copy the numbers exactly as they appear on your report. You'll be asked to confirm before anything is saved.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add a result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save result") {
                        // Use case wiring comes in the inner-workings step.
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecordResultView()
}
