import Foundation

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low:
            return "低"
        case .medium:
            return "中"
        case .high:
            return "高"
        }
    }
}

struct Task: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var notes: String
    var date: Date
    var priority: TaskPriority
    var isCompleted: Bool
    
    init(title: String, notes: String = "", date: Date, priority: TaskPriority = .medium, isCompleted: Bool = false) {
        self.title = title
        self.notes = notes
        self.date = date
        self.priority = priority
        self.isCompleted = isCompleted
    }
}
