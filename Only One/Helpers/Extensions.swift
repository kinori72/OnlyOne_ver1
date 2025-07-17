import Foundation
import SwiftUI

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        let calendar = Calendar.current
        let startOfDay = self.startOfDay()
        return calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }
    
    func isInSameMonth(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .month)
    }
    
    func isInSameWeek(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
}

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
}
