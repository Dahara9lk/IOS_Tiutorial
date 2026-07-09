//
//  NotificationService.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import UserNotifications
import UIKit
import Combine


class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    @Published var isAuthorized = false
    
    private override init() {  // private init ensures singleton
        super.init()
        center.delegate = self
    }
    
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    func scheduleDailyNotification(at time: Date) {
        cancelAllNotifications()
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Come back and play a game! Beat your high score."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "dailyChallenge", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error { print("Notification error: \(error)") }
        }
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
