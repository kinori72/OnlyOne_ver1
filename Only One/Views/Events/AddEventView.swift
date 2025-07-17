import SwiftUI

struct AddEventView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var notes = ""
    @State private var date: Date
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var isAllDay = false
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        self._date = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("予定名", text: $title)
                    DatePicker("日付", selection: $date, displayedComponents: .date)
                    
                    Toggle("終日", isOn: $isAllDay)
                    
                    if !isAllDay {
                        DatePicker("開始時刻", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("終了時刻", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("詳細")) {
                    TextField("メモ（任意）", text: $notes, axis: .vertical)
                        .lineLimit(5)
                }
            }
            .navigationTitle("予定を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            // デフォルトの時間を設定
            let calendar = Calendar.current
            if let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date) {
                startTime = start
            }
            if let end = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date) {
                endTime = end
            }
        }
    }
    
    private func addEvent() {
        let event = Event(
            title: title,
            notes: notes,
            date: date,
            startTime: startTime,
            endTime: endTime,
            isAllDay: isAllDay
        )
        
        appState.addEvent(event)
        dismiss()
    }
}

#Preview {
    AddEventView(selectedDate: Date())
        .environmentObject(AppState())
}
