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
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: statsVM.sessions.filter { $0.latitude != nil && $0.longitude != nil }) { session in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: session.latitude!, longitude: session.longitude!), tint: .red)
            }
            .onAppear {
                if let loc = locationService.currentLocation {
                    region.center = loc.coordinate
                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                }
            }
            .navigationTitle("Game Map")
            .toolbar {
                Button("Center") {
                    if let loc = locationService.currentLocation {
                        withAnimation {
                            region.center = loc.coordinate
                        }
                    }
                }
            }
        }
    }
}

// Conform GameSession to MapAnnotationProtocol (if needed)
extension GameSession: Identifiable { } // already
extension GameSession {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
    }
}
