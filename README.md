#  PlayHub - iOS Multi-Game App

[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0-blue.svg)](https://developer.apple.com/ios/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)](https://developer.apple.com/documentation/swiftui)

> A polished iOS portfolio project featuring three distinct mini-games, statistics tracking, map integration, and notifications - all built with SwiftUI and modern iOS development practices.

---

##  App Overview

PlayHub is a complete iOS application that demonstrates mastery of modern iOS development through three engaging mini-games:

1. Tap Frenzy - Classic speed-tapping challenge
2. Light It Up- Whack-a-mole style memory game with level progression
3. Quiz Rush - Live trivia powered by Open Trivia Database API

###  Key Features

- Four-Tab Navigation - Home, Stats, Map, and Settings
- Game Session Tracking- Every game is recorded with score, mode, timestamp, and location
- Interactive Statistics- Bar charts and metrics using Swift Charts
- Location-Based Map - Pins showing where each game was played using MapKit
- Daily Notifications - Customizable daily reminders
- Dark/Light Mode - Full theme support with manual toggle
- Share Results - Share scores via ShareLink
- Persistent Storage - High scores and game history saved locally

---

## Architecture

Model-View-ViewModel (MVVM) architecture pattern


Folder Structure

📁 PlayHub/
│
├── 📁 App/                              # App entry point
│   └── PlayHubApp.swift                 # @main app structure
│
├── 📁 Models/                           # Data Models
│   ├── Card.swift                       # Light It Up card
│   ├── GameMode.swift                   # Game modes enum
│   ├── GameSession.swift                # Game session with Codable
│   ├── Level.swift                      # Level progression
│   ├── ThemeManager.swift               # Theme management
│   └── TriviaQuestion.swift             # Quiz question with Codable
│
├── 📁 ViewModels/                       # Business Logic
│   ├── QuizRushVM.swift                 # Quiz game logic
│   └── StatsVM.swift                    # Statistics logic
│
├── 📁 Services/                         # System Services
│   ├── LocationService.swift            # Core Location wrapper
│   ├── NotificationService.swift        # User Notifications wrapper
│   └── TriviaAPI.swift                  # Network layer
│
├── 📁 Views/                            # UI Layer
│   ├── 📁 Games/                        # Game screens
│   │   ├── TapFrenzyView.swift
│   │   ├── LightItUpView.swift
│   │   └── QuizRushView.swift
│   ├── 📁 Shared/                       # Reusable components
│   │   ├── ResultView.swift
│   │   └── ScoreBadge.swift
│   └── 📁 Tabs/                         # Tab screens
│       ├── HomeTab.swift
│       ├── StatsTab.swift
│       ├── MapTab.swift
│       └── SettingsTab.swift
│
├── 📁 Extensions/                       # Swift Extensions
│   ├── Color+Theme.swift                # Theme colors
│   └── View+Extensions.swift            # Reusable modifiers
│
└── 📁 Resources/                        # Assets
    └── Assets.xcassets                  # Images, colors, app icon
