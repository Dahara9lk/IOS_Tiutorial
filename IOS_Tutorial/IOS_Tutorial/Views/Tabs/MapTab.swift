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
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedSession: GameSession?
    @State private var showUserLocation = true
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                // ✅ Show user location with blue dot
                UserAnnotation()
                
                // ✅ Show all game session pins
                ForEach(statsVM.sessions) { session in
                    if let coordinate = session.locationCoordinate {
                        Annotation(
                            "",
                            coordinate: coordinate,
                            anchor: .center
                        ) {
                            // Custom pin with score
                            VStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .fill(markerColor(for: session.mode))
                                        .frame(width: 36, height: 36)
                                        .shadow(color: markerColor(for: session.mode).opacity(0.4), radius: 4)
                                    
                                    Image(systemName: session.mode.iconName)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                
                                Text("\(session.score)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.1), radius: 2)
                                    .offset(y: -2)
                            }
                            .onTapGesture {
                                selectedSession = session
                            }
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .mapStyle(.standard)
            .onAppear {
                print("📍 Map appeared - Sessions count: \(statsVM.sessions.count)")
                statsVM.loadSessions()
                
                // Start location updates
                locationService.startUpdating()
                
                // Center map on user location
                if let location = locationService.currentLocation {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        position = .region(MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    }
                }
            }
            .onDisappear {
                locationService.stopUpdating()
            }
            .onChange(of: locationService.currentLocation) { oldLocation, newLocation in
                if let location = newLocation {
                    // Update position to follow user
                    withAnimation(.easeInOut(duration: 0.5)) {
                        position = .region(MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    }
                }
            }
            .navigationTitle("Game Locations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        // Recenter button
                        Button {
                            if let location = locationService.currentLocation {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    position = .region(MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    ))
                                }
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .foregroundColor(locationService.currentLocation != nil ? .purple : .gray)
                        }
                        
                        // Refresh button
                        Button {
                            statsVM.loadSessions()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.purple)
                        }
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailSheet(session: session)
            }
            .overlay {
                let sessionsWithLocation = statsVM.sessions.filter { $0.locationCoordinate != nil }
                
                if sessionsWithLocation.isEmpty && locationService.currentLocation == nil {
                    // No location and no sessions
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Location Not Available")
                            .font(.headline)
                        Text("Enable location services to see your position and game pins")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(16)
                } else if sessionsWithLocation.isEmpty {
                    // Location available but no game sessions
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No Game Locations Yet")
                            .font(.headline)
                        Text("Play a game to see pins on the map")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(16)
                }
            }
            .alert("Location Error", isPresented: .constant(locationService.lastError != nil)) {
                Button("OK") {
                    locationService.lastError = nil
                }
            } message: {
                Text(locationService.lastError?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func markerColor(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush: return .purple
        }
    }
}

// MARK: - Session Detail Sheet
struct SessionDetailSheet: View {
    let session: GameSession
    @Environment(\.dismiss) private var dismiss
    
    private func markerColor(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush: return .purple
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Game Icon
                ZStack {
                    Circle()
                        .fill(markerColor(for: session.mode).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: session.mode.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(markerColor(for: session.mode))
                }
                .padding(.top, 20)
                
                // Score
                VStack(spacing: 4) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(session.score)")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(markerColor(for: session.mode))
                }
                
                Divider()
                    .padding(.horizontal, 40)
                
                // Mode
                VStack(spacing: 4) {
                    Text("Game Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.mode.rawValue)
                        .font(.headline)
                }
                
                // Date & Time
                VStack(spacing: 4) {
                    Text("Date & Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.timestamp, format: .dateTime.day().month().year())
                        .font(.subheadline)
                    Text(session.timestamp, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Location
                if let coordinate = session.locationCoordinate {
                    VStack(spacing: 4) {
                        Text("Location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Lat: \(String(format: "%.6f", coordinate.latitude))")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("Lon: \(String(format: "%.6f", coordinate.longitude))")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    MapTab()
        .environmentObject(StatsViewModel())
        .environmentObject(LocationService())
}
