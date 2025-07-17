import Foundation

struct Shift: Identifiable, Codable, Equatable {
    let id = UUID()
    var date: Date
    var startTime: Date
    var endTime: Date
    var workplaceId: UUID // MOD
    var breakMinutes: Int
    var notes: String
    
    init(date: Date, startTime: Date, endTime: Date, workplaceId: UUID, breakMinutes: Int = 0, notes: String = "") { // MOD
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.workplaceId = workplaceId // MOD
        self.breakMinutes = breakMinutes
        self.notes = notes
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime) - TimeInterval(breakMinutes * 60)
    }
    
    var workingHours: Double {
        return duration / 3600.0
    }
    
    func calculateWage(hourlyRate: Double) -> Double { // MOD
        return workingHours * hourlyRate
    }
}
