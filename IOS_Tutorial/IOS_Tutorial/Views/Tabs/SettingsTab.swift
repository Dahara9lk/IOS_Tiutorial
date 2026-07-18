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
            ZStack {
                // ✅ Theme Background
                LinearGradient.mainGradient
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        Toggle("🔔 Enable Notifications", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { oldValue, newValue in
                                if newValue {
                                    notificationService.requestPermission()
                                    notificationService.scheduleDailyNotification(at: dailyTime)
                                } else {
                                    notificationService.cancelAllNotifications()
                                }
                            }
                            .tint(.purple)
                            .foregroundColor(.white)
                        
                        DatePicker("⏰ Daily Challenge Time", selection: $dailyTime, displayedComponents: .hourAndMinute)
                            .onChange(of: dailyTime) { oldValue, newValue in
                                dailyTimeData = newValue
                                if notificationsEnabled {
                                    notificationService.scheduleDailyNotification(at: newValue)
                                }
                            }
                            .tint(.purple)
                            .foregroundColor(.white)
                    } header: {
                        Text("NOTIFICATIONS")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section {
                        Button("🗑️ Reset All Stats", role: .destructive) {
                            showingResetAlert = true
                        }
                        .tint(.red)
                    } header: {
                        Text("DATA")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.white.opacity(0.3))
                        }
                    } header: {
                        Text("ABOUT")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .environment(\.colorScheme, .dark)
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
            }
            .alert("Reset Stats", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    statsVM.resetStats()
                }
            } message: {
                Text("This will delete all game sessions and cannot be undone.")
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
}
