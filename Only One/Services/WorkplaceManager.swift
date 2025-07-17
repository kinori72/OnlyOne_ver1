// NEW FILE
import Foundation
import Combine

class WorkplaceManager: ObservableObject {
    @Published var workplaces: [Workplace] = []
    private let userDefaults = UserDefaults.standard
    private let workplacesKey = "workplaces"
    
    init() {
        loadWorkplaces()
    }
    
    func loadWorkplaces() {
        if let data = userDefaults.data(forKey: workplacesKey),
           let decoded = try? JSONDecoder().decode([Workplace].self, from: data) {
            workplaces = decoded
        } else {
            // デフォルトの勤務先を追加
            workplaces = [
                Workplace(name: "アルバイト", color: .blue, hourlyRate: 1000.0),
                Workplace(name: "パート", color: .green, hourlyRate: 1200.0)
            ]
            saveWorkplaces()
        }
    }
    
    func saveWorkplaces() {
        if let encoded = try? JSONEncoder().encode(workplaces) {
            userDefaults.set(encoded, forKey: workplacesKey)
        }
    }
    
    func addWorkplace(_ workplace: Workplace) {
        workplaces.append(workplace)
        saveWorkplaces()
    }
    
    func updateWorkplace(_ workplace: Workplace) {
        if let index = workplaces.firstIndex(where: { $0.id == workplace.id }) {
            workplaces[index] = workplace
            saveWorkplaces()
        }
    }
    
    func deleteWorkplace(_ workplace: Workplace) {
        workplaces.removeAll { $0.id == workplace.id }
        saveWorkplaces()
    }
    
    func getWorkplace(by id: UUID) -> Workplace? {
        return workplaces.first { $0.id == id }
    }
}
