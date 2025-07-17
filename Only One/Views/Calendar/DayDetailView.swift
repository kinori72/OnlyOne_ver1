import SwiftUI

struct DayDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var workplaceManager: WorkplaceManager
    @Environment(\.dismiss) private var dismiss
    let date: Date
    
    @State private var showingAddEvent = false
    @State private var showingAddTask = false
    @State private var showingAddShift = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日(E)"
        return formatter
    }()
    
    private var dayEvents: [Event] {
        appState.events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private var dayTasks: [Task] {
        appState.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private var dayShifts: [Shift] {
        appState.shifts.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 予定セクション
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("予定")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                showingAddEvent = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        if dayEvents.isEmpty {
                            Text("予定はありません")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(dayEvents.sorted(by: { $0.startTime < $1.startTime })) { event in
                                DayDetailEventRowView(event: event)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // タスクセクション
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("タスク")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                showingAddTask = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        if dayTasks.isEmpty {
                            Text("タスクはありません")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(dayTasks.sorted(by: { $0.title < $1.title })) { task in
                                DayDetailTaskRowView(task: task)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // シフトセクション
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("シフト")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                showingAddShift = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        if dayShifts.isEmpty {
                            Text("シフトはありません")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(dayShifts.sorted(by: { $0.startTime < $1.startTime })) { shift in
                                DayDetailShiftRowView(shift: shift, workplace: workplaceManager.getWorkplace(by: shift.workplaceId))
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(dateFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(selectedDate: date)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(selectedDate: date)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showingAddShift) {
            AddShiftView(selectedDate: date)
                .environmentObject(appState)
                .environmentObject(workplaceManager)
        }
    }
}

struct DayDetailEventRowView: View {
    let event: Event
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !event.isAllDay {
                    Text("\(timeFormatter.string(from: event.startTime)) - \(timeFormatter.string(from: event.endTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("終日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
}

struct DayDetailTaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
            Circle()
                .fill(task.isCompleted ? Color.green : Color.blue)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
}

struct DayDetailShiftRowView: View {
    let shift: Shift
    let workplace: Workplace?
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workplace?.name ?? "不明な勤務先")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(timeFormatter.string(from: shift.startTime)) - \(timeFormatter.string(from: shift.endTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let workplace = workplace {
                    Text("時給: ¥\(Int(workplace.hourlyRate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Circle()
                .fill(workplace?.color.color ?? Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DayDetailView(date: Date())
        .environmentObject(AppState())
        .environmentObject(WorkplaceManager())
}
