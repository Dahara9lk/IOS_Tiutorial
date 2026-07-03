//
//  SettingsSheet.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

struct SettingsSheet: View {
    @Binding var selectedDuration: Int
    @Environment(\.dismiss) private var dismiss
    
    let options = [30, 60, 90]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Round Duration") {
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(options, id: \.self) { option in
                            Text("\(option)s")
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
