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
            ZStack {
                LinearGradient.mainGradient
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Duration", selection: $selectedDuration) {
                            ForEach(options, id: \.self) { option in
                                Text("\(option)s")
                                    .tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(.orange)
                    } header: {
                        Text("ROUND DURATION")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("⚙️ SETTINGS")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 5)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
            .environment(\.colorScheme, .dark)
        }
        .presentationDetents([.medium])
    }
}
