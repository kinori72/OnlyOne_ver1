import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("通知の許可が得られました")
            } else {
                print("通知の許可が得られませんでした")
            }
        }
    }
    
    func scheduleEventNotification(for event: Event) {
        let content = UNMutableNotificationContent()
        content.title = "予定のお知らせ"
        content.body = event.title
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: event.startTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleTaskNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "タスクのお知らせ"
        content.body = task.title
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
