import Foundation
import SwiftUI

enum Semester: String, CaseIterable, Codable {
    case first = "前学期"
    case second = "後学期"
    
    var displayName: String {
        return self.rawValue
    }
}

struct Course: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var professor: String
    var room: String
    var weekday: String
    var period: Int
    var color: CourseColor
    var notes: String
    var year: Int // NEW
    var semester: Semester // NEW
    
    init(title: String, professor: String = "", room: String = "", weekday: String, period: Int, color: CourseColor = .blue, notes: String = "", year: Int, semester: Semester) {
        self.title = title
        self.professor = professor
        self.room = room
        self.weekday = weekday
        self.period = period
        self.color = color
        self.notes = notes
        self.year = year
        self.semester = semester
    }
}

enum CourseColor: String, CaseIterable, Codable {
    case red = "red"
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    case pink = "pink"
    case yellow = "yellow"
    case gray = "gray"
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .orange:
            return .orange
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .yellow:
            return .yellow
        case .gray:
            return .gray
        }
    }
    
    var displayName: String {
        switch self {
        case .red:
            return "赤"
        case .blue:
            return "青"
        case .green:
            return "緑"
        case .orange:
            return "オレンジ"
        case .purple:
            return "紫"
        case .pink:
            return "ピンク"
        case .yellow:
            return "黄"
        case .gray:
            return "グレー"
        }
    }
}
