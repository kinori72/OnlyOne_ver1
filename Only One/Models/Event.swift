import Foundation

struct Event: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var notes: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var isAllDay: Bool
    
    init(title: String, notes: String = "", date: Date, startTime: Date, endTime: Date, isAllDay: Bool = false) {
        self.title = title
        self.notes = notes
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isAllDay = isAllDay
    }
}
