import SwiftUI

enum TaskSortOption: String, CaseIterable {
    case addedOrder = "追加順"
    case priority = "優先度順"
    case dueDate = "期限順"
    
    var displayName: String {
        return self.rawValue
    }
}

struct TaskListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddTask = false
    @State private var selectedDate = Date()
    @State private var sortOption: TaskSortOption = .addedOrder
    
    private var sortedIncompleteTasks: [Task] {
        let tasks = appState.tasks.filter { !$0.isCompleted }
        return sortTasks(tasks)
    }
    
    private var sortedCompletedTasks: [Task] {
        let tasks = appState.tasks.filter { $0.isCompleted }
        return sortTasks(tasks)
    }
    
    private func sortTasks(_ tasks: [Task]) -> [Task] {
        switch sortOption {
        case .addedOrder:
            return tasks // IDで自然順序
        case .priority:
            return tasks.sorted { task1, task2 in
                let priority1Value = priorityValue(task1.priority)
                let priority2Value = priorityValue(task2.priority)
                if priority1Value != priority2Value {
                    return priority1Value > priority2Value // 高優先度が上
                }
                return task1.date < task2.date // 同じ優先度なら日付順
            }
        case .dueDate:
            return tasks.sorted { $0.date < $1.date }
        }
    }
    
    private func priorityValue(_ priority: TaskPriority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 並び替えピッカー
                Picker("並び替え", selection: $sortOption) {
                    ForEach(TaskSortOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    if !sortedIncompleteTasks.isEmpty {
                        Section(header: Text("未完了")) {
                            ForEach(sortedIncompleteTasks) { task in
                                TaskRowView(task: task)
                            }
                            .onDelete(perform: deleteIncompleteTask)
                        }
                    }
                    
                    if !sortedCompletedTasks.isEmpty {
                        Section(header: Text("完了済み")) {
                            ForEach(sortedCompletedTasks) { task in
                                TaskRowView(task: task)
                            }
                            .onDelete(perform: deleteCompletedTask)
                        }
                    }
                    
                    if sortedIncompleteTasks.isEmpty && sortedCompletedTasks.isEmpty {
                        Text("タスクはありません")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            .navigationTitle("タスク")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(selectedDate: selectedDate)
                .environmentObject(appState)
        }
    }
    
    private func deleteIncompleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = sortedIncompleteTasks[index]
            appState.deleteTask(task)
        }
    }
    
    private func deleteCompletedTask(at offsets: IndexSet) {
        for index in offsets {
            let task = sortedCompletedTasks[index]
            appState.deleteTask(task)
        }
    }
}

struct TaskRowView: View {
    @EnvironmentObject var appState: AppState
    let task: Task
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Button(action: {
                appState.toggleTaskCompletion(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                HStack {
                    Text(dateFormatter.string(from: task.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(task.priority.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityColor(task.priority).opacity(0.2))
                        .foregroundColor(priorityColor(task.priority))
                        .cornerRadius(4)
                }
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .blue
        }
    }
}

#Preview {
    TaskListView()
        .environmentObject(AppState())
}
