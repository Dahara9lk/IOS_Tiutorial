//
//  MapTab.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        NavigationStack {
            Map {
                ForEach(statsVM.sessions) { session in
                    if let coordinate = session.locationCoordinate {
                        Marker(coordinate: coordinate) {
                            Label("\(session.mode.rawValue): \(session.score)", systemImage: "gamecontroller.fill")
                        }
                        .tint(session.mode == .tapFrenzy ? .blue : session.mode == .lightItUp ? .orange : .purple)
                    }
                }
            }
            .navigationTitle("Game Locations")
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
        }
    }
}

#Preview {
    MapTab()
        .environmentObject(StatsViewModel())
        .environmentObject(LocationService())
}
