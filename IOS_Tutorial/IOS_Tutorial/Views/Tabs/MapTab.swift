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
    
    // NIBM Colombo, Sri Lanka - Correct Coordinates
    private let nibmLocation = CLLocationCoordinate2D(
        latitude: 6.90644,
        longitude: 79.87079
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    // LIVE USER LOCATION
                    if let location = locationService.currentLocation {
                        Annotation("You are here", coordinate: location.coordinate) {
                            UserLocationPin()
                        }
                    }
                    
                    // NIBM Pin
                    Annotation("NIBM Sri Lanka", coordinate: nibmLocation) {
                        NIBMPin()
                    }
                    
                    // GAME SESSION PINS
                    ForEach(statsVM.sessions) { session in
                        if let coordinate = session.locationCoordinate {
                            Annotation(
                                "",
                                coordinate: coordinate,
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let location = locationService.currentLocation {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                position = .region(MKCoordinateRegion(
                                    center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                ))
                            }
                            print("📍 Centered on user location")
                        } else {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                position = .region(MKCoordinateRegion(
                                    center: nibmLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
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
                        withAnimation(.easeInOut(duration: 0.3)) {
                            position = .region(MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            ))
                        }
                        refreshID = UUID()
                    }
                }
                .id(refreshID)
                .navigationTitle("Game Locations")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("🗺️ MAP")
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: .purple.opacity(0.5), radius: 5)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 16) {
                            // Tracking Toggle
                            Button {
                                isTracking.toggle()
                                if isTracking, let location = locationService.currentLocation {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        position = .region(MKCoordinateRegion(
                                            center: location.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                        ))
                                    }
                                }
                            } label: {
                                Image(systemName: isTracking ? "location.fill" : "location.slash.fill")
                                    .foregroundColor(isTracking ? .cyan : .gray)
                            }
                            
                            // Recenter
                            Button {
                                if let location = locationService.currentLocation {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        position = .region(MKCoordinateRegion(
                                            center: location.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                        ))
                                    }
                                    isTracking = true
                                } else {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        position = .region(MKCoordinateRegion(
                                            center: nibmLocation,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                        ))
                                    }
                                }
                            } label: {
                                Image(systemName: "location.circle.fill")
                                    .foregroundColor(.cyan)
                            }
                            
                            // Refresh
                            Button {
                                statsVM.loadSessions()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.cyan)
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
                                .foregroundColor(.white)
                            Text("Play a game to see pins on the map")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .background(LinearGradient.mainGradient)
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
        case .tapFrenzy: return .tapFrenzyColor
        case .lightItUp: return .lightItUpColor
        case .quizRush: return .quizRushColor
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
        case .tapFrenzy: return .tapFrenzyColor
        case .lightItUp: return .lightItUpColor
        case .quizRush: return .quizRushColor
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.mainGradient
                    .ignoresSafeArea()
                
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
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(session.score)")
                            .font(.system(size: 52, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.3), radius: 5)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 4) {
                        Text("Game Mode")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text(session.mode.rawValue)
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Date & Time")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text(session.timestamp, format: .dateTime.day().month().year())
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.white)
                        Text(session.timestamp, format: .dateTime.hour().minute())
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    if let coordinate = session.locationCoordinate {
                        VStack(spacing: 4) {
                            Text("Location")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            Text("Lat: \(String(format: "%.6f", coordinate.latitude))")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            Text("Lon: \(String(format: "%.6f", coordinate.longitude))")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("📌 SESSION")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 5)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
