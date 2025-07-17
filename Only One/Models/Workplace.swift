// NEW FILE
import Foundation
import SwiftUI

struct Workplace: Identifiable, Codable, Equatable {
    let id = UUID()
    var name: String
    var color: WorkplaceColor
    var hourlyRate: Double
    var notes: String
    
    init(name: String, color: WorkplaceColor = .blue, hourlyRate: Double = 0.0, notes: String = "") {
        self.name = name
        self.color = color
        self.hourlyRate = hourlyRate
        self.notes = notes
    }
}

enum WorkplaceColor: String, CaseIterable, Codable {
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
