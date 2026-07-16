//
//  MainTabView.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var statsVM = StatsViewModel()
    @StateObject private var locationService = LocationService()
    
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller.fill")
                }
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.purple)
        .environmentObject(statsVM)
        .environmentObject(locationService)
        .onAppear {
            locationService.requestPermission()
            print("📍 Sessions count: \(statsVM.sessions.count)")
        }
    }
}

#Preview {
    MainTabView()
}
