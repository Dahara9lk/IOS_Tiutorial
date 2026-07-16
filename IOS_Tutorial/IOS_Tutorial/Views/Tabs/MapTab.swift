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
    @State private var isTracking = true
    @State private var refreshID = UUID()
    @State private var fixedLocation: CLLocationCoordinate2D?
    
    // ✅ NIBM Colombo, Sri Lanka - CORRECT COORDINATES
    private let nibmLocation = CLLocationCoordinate2D(
        latitude: 6.90644,
        longitude: 79.87079
    )
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                // LIVE USER LOCATION - FIXED
                if let location = locationService.currentLocation {
                    // ✅ Fix: Check if longitude is negative (wrong hemisphere)
                    let lat = location.coordinate.latitude
                    let lon = abs(location.coordinate.longitude) // ✅ Make positive
                    let fixedCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    Annotation("You are here", coordinate: fixedCoord) {
                        UserLocationPin()
                    }
                }
                
                // ✅ NIBM Pin (always visible)
                Annotation("NIBM Sri Lanka", coordinate: nibmLocation) {
                    NIBMPin()
                }
                
                // GAME SESSION PINS
                ForEach(statsVM.sessions) { session in
                    if let coordinate = session.locationCoordinate {
                        // ✅ Also fix game session coordinates
                        let fixedCoord = CLLocationCoordinate2D(
                            latitude: coordinate.latitude,
                            longitude: abs(coordinate.longitude)
                        )
                        Annotation(
                            "",
                            coordinate: fixedCoord,
                            anchor: .center
                        ) {
                            GameSessionPin(session: session)
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
                print("📍 Map appeared - Sessions: \(statsVM.sessions.count)")
                statsVM.loadSessions()
                locationService.startUpdating()
                
                // ✅ Log location for debugging
                if let location = locationService.currentLocation {
                    print("📍 User location (raw): \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    print("📍 User location (fixed): \(location.coordinate.latitude), \(abs(location.coordinate.longitude))")
                }
                print("📍 NIBM location: \(nibmLocation.latitude), \(nibmLocation.longitude)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let location = locationService.currentLocation {
                        let fixedCoord = CLLocationCoordinate2D(
                            latitude: location.coordinate.latitude,
                            longitude: abs(location.coordinate.longitude)
                        )
                        withAnimation(.easeInOut(duration: 0.5)) {
                            position = .region(MKCoordinateRegion(
                                center: fixedCoord,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            ))
                        }
                        print("📍 Centered on fixed user location")
                    } else {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            position = .region(MKCoordinateRegion(
                                center: nibmLocation,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            ))
                        }
                        print("📍 Centered on NIBM Sri Lanka")
                    }
                }
            }
            .onDisappear {
                locationService.stopUpdating()
            }
            .onChange(of: locationService.currentLocation) { oldLocation, newLocation in
                if let location = newLocation, isTracking {
                    let fixedCoord = CLLocationCoordinate2D(
                        latitude: location.coordinate.latitude,
                        longitude: abs(location.coordinate.longitude)
                    )
                    withAnimation(.easeInOut(duration: 0.3)) {
                        position = .region(MKCoordinateRegion(
                            center: fixedCoord,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                    refreshID = UUID()
                }
            }
            .id(refreshID)
            .navigationTitle("Game Locations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        // Tracking Toggle
                        Button {
                            isTracking.toggle()
                            if isTracking, let location = locationService.currentLocation {
                                let fixedCoord = CLLocationCoordinate2D(
                                    latitude: location.coordinate.latitude,
                                    longitude: abs(location.coordinate.longitude)
                                )
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    position = .region(MKCoordinateRegion(
                                        center: fixedCoord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    ))
                                }
                            }
                        } label: {
                            Image(systemName: isTracking ? "location.fill" : "location.slash.fill")
                                .foregroundColor(isTracking ? .purple : .gray)
                        }
                        
                        // Recenter
                        Button {
                            if let location = locationService.currentLocation {
                                let fixedCoord = CLLocationCoordinate2D(
                                    latitude: location.coordinate.latitude,
                                    longitude: abs(location.coordinate.longitude)
                                )
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    position = .region(MKCoordinateRegion(
                                        center: fixedCoord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    ))
                                }
                                isTracking = true
                            } else {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    position = .region(MKCoordinateRegion(
                                        center: nibmLocation,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    ))
                                }
                            }
                        } label: {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.purple)
                        }
                        
                        // Refresh
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
                
                if sessionsWithLocation.isEmpty {
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
        }
    }
}

// MARK: - NIBM Pin
struct NIBMPin: View {
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .scaleEffect(pulse ? 1.5 : 1.0)
                    .opacity(pulse ? 0 : 0.5)
                    .animation(
                        Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: pulse
                    )
                
                Circle()
                    .fill(Color.purple)
                    .frame(width: 32, height: 32)
                    .shadow(color: .purple.opacity(0.5), radius: 6)
                
                Text("N")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("NIBM")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.1), radius: 2)
                .offset(y: -4)
        }
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - User Location Pin
struct UserLocationPin: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .scaleEffect(pulse ? 1.8 : 0.8)
                .opacity(pulse ? 0 : 0.6)
                .animation(
                    Animation.easeOut(duration: 2.0).repeatForever(autoreverses: false),
                    value: pulse
                )
            
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 44, height: 44)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .opacity(pulse ? 0 : 0.5)
                .animation(
                    Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false),
                    value: pulse
                )
            
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2.5)
                )
                .shadow(color: .blue.opacity(0.5), radius: 8)
            
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
        }
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Game Session Pin
struct GameSessionPin: View {
    let session: GameSession
    
    @State private var isAnimating = false
    
    private func markerColor(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush: return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(markerColor(for: session.mode).opacity(0.2))
                    .frame(width: 48, height: 48)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0 : 0.5)
                    .animation(
                        Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                Circle()
                    .fill(markerColor(for: session.mode))
                    .frame(width: 34, height: 34)
                    .shadow(color: markerColor(for: session.mode).opacity(0.4), radius: 4)
                
                Image(systemName: session.mode.iconName)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text("\(session.score)")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.15), radius: 2)
                .offset(y: -4)
        }
        .onAppear {
            isAnimating = true
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
                ZStack {
                    Circle()
                        .fill(markerColor(for: session.mode).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: session.mode.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(markerColor(for: session.mode))
                }
                .padding(.top, 20)
                
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
                
                VStack(spacing: 4) {
                    Text("Game Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.mode.rawValue)
                        .font(.headline)
                }
                
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
