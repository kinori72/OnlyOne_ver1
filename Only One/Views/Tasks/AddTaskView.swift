import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var notes = ""
    @State private var date: Date
    @State private var priority = TaskPriority.medium
    @State private var isCompleted = false
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        self._date = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("タスク名", text: $title)
                    DatePicker("日付", selection: $date, displayedComponents: .date)
                    
                    Picker("優先度", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    
                    Toggle("完了済み", isOn: $isCompleted)
                }
                
                Section(header: Text("詳細")) {
                    TextField("メモ（任意）", text: $notes, axis: .vertical)
                        .lineLimit(5)
                }
            }
            .navigationTitle("タスクを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        let task = Task(
            title: title,
            notes: notes,
            date: date,
            priority: priority,
            isCompleted: isCompleted
        )
        
        appState.addTask(task)
        dismiss()
    }
}

#Preview {
    AddTaskView(selectedDate: Date())
        .environmentObject(AppState())
}
