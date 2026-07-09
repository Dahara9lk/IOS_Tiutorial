//
//  SettingsTab.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI

struct SettingsTab: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dailyChallengeTime") private var dailyTimeData = Date()
    @State private var dailyTime = Date()
    @State private var showingResetAlert = false
    
    @EnvironmentObject var statsVM: StatsViewModel
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                notificationService.requestPermission()
                                notificationService.scheduleDailyNotification(at: dailyTime)
                            } else {
                                notificationService.cancelAllNotifications()
                            }
                        }
                    
                    DatePicker("Daily Challenge Time", selection: $dailyTime, displayedComponents: .hourAndMinute)
                        .onChange(of: dailyTime) { newTime in
                            dailyTimeData = newTime
                            if notificationsEnabled {
                                notificationService.scheduleDailyNotification(at: newTime)
                            }
                        }
                }
                
                Section("Data") {
                    Button("Reset All Stats", role: .destructive) {
                        showingResetAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Stats", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    statsVM.resetStats()
                }
            } message: {
                Text("This will delete all game sessions and cannot be undone.")
            }
        }
        .onAppear {
            dailyTime = dailyTimeData
            if notificationsEnabled {
                notificationService.requestPermission()
                notificationService.scheduleDailyNotification(at: dailyTime)
            }
        }
    }
}
