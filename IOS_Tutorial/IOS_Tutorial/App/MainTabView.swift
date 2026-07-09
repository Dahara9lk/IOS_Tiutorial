//
//  MainTabView.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI

struct MainTabView: View {
    // vIEW Models
    @StateObject private var statsVM = StatsViewModel()
    @StateObject private var locationService = LocationService()
    
    var body: some View {
        TabView {
                    // Tab 1: Home
                    HomeTab()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    // Tab 2: Stats
                    StatsTab()
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar.fill")
                        }
                    
                    // Tab 3: Map
                    MapTab()
                        .tabItem {
                            Label("Map", systemImage: "map.fill")
                        }
                    
                    // Tab 4: Settings
                    SettingsTab()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .tint(.blue)
                .environmentObject(statsVM)
                .environmentObject(locationService)
                .onAppear {
                    // Request permissions
                    locationService.requestPermission()
                    
                    // Request notification permission
                    let notificationService = NotificationService()
                    notificationService.requestPermission()
                }
            }
        }

        #Preview {
            MainTabView()
        }
        
    

