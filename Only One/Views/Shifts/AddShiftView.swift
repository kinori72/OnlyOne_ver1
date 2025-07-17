import SwiftUI

struct AddShiftView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var workplaceManager: WorkplaceManager // NEW
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    
    @State private var date: Date
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var selectedWorkplaceId: UUID? // MOD
    @State private var breakMinutes = 0
    @State private var notes = ""
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        self._date = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    DatePicker("日付", selection: $date, displayedComponents: .date)
                    
                    Picker("勤務先", selection: $selectedWorkplaceId) { // MOD
                        Text("選択してください").tag(UUID?.none)
                        ForEach(workplaceManager.workplaces) { workplace in
                            HStack {
                                Circle()
                                    .fill(workplace.color.color)
                                    .frame(width: 16, height: 16)
                                Text(workplace.name)
                            }
                            .tag(UUID?.some(workplace.id))
                        }
                    }
                }
                
                Section(header: Text("時間")) {
                    DatePicker("開始時刻", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("終了時刻", selection: $endTime, displayedComponents: .hourAndMinute)
                    
                    Stepper("休憩時間: \(breakMinutes)分", value: $breakMinutes, in: 0...300, step: 15)
                }
                
                Section(header: Text("詳細")) {
                    // 勤務時間と給与の計算表示 // NEW
                    if let workplaceId = selectedWorkplaceId,
                       let workplace = workplaceManager.getWorkplace(by: workplaceId) {
                        let duration = endTime.timeIntervalSince(startTime) - TimeInterval(breakMinutes * 60)
                        let workingHours = max(0, duration / 3600.0)
                        let wage = workingHours * workplace.hourlyRate
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("労働時間: \(String(format: "%.1f", workingHours))時間")
                                .font(.subheadline)
                            Text("時給: ¥\(Int(workplace.hourlyRate))")
                                .font(.subheadline)
                            Text("給与: ¥\(Int(wage))")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    TextField("メモ（任意）", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("シフトを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addShift()
                    }
                    .disabled(selectedWorkplaceId == nil) // MOD
                }
            }
        }
        .onAppear {
            // デフォルトの勤務先を選択 // NEW
            if let firstWorkplace = workplaceManager.workplaces.first {
                selectedWorkplaceId = firstWorkplace.id
            }
            
            // デフォルトの時間を設定
            let calendar = Calendar.current
            if let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date) {
                startTime = start
            }
            if let end = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: date) {
                endTime = end
            }
        }
    }
    
    private func addShift() {
        guard let workplaceId = selectedWorkplaceId else { return } // MOD
        
        let shift = Shift(
            date: date,
            startTime: startTime,
            endTime: endTime,
            workplaceId: workplaceId, // MOD
            breakMinutes: breakMinutes,
            notes: notes
        )
        
        appState.addShift(shift)
        dismiss()
    }
}

#Preview {
    AddShiftView(selectedDate: Date())
        .environmentObject(AppState())
        .environmentObject(WorkplaceManager()) // NEW
}
