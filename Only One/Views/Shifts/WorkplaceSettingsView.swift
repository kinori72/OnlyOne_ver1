// NEW FILE
import SwiftUI

struct WorkplaceSettingsView: View {
    @EnvironmentObject var workplaceManager: WorkplaceManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddWorkplace = false
    @State private var editingWorkplace: Workplace?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workplaceManager.workplaces) { workplace in
                    WorkplaceRowView(
                        workplace: workplace,
                        onEdit: { editingWorkplace = workplace }
                    )
                }
                .onDelete(perform: deleteWorkplace)
            }
            .navigationTitle("勤務先管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完了") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWorkplace = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddWorkplace) {
            AddWorkplaceView()
                .environmentObject(workplaceManager)
        }
        .sheet(item: $editingWorkplace) { workplace in
            EditWorkplaceView(workplace: workplace)
                .environmentObject(workplaceManager)
        }
    }
    
    private func deleteWorkplace(at offsets: IndexSet) {
        for index in offsets {
            let workplace = workplaceManager.workplaces[index]
            workplaceManager.deleteWorkplace(workplace)
        }
    }
}

struct WorkplaceRowView: View {
    let workplace: Workplace
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack {
                Rectangle()
                    .fill(workplace.color.color)
                    .frame(width: 4, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workplace.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("時給: ¥\(Int(workplace.hourlyRate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(workplace.color.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(workplace.color.color.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    if !workplace.notes.isEmpty {
                        Text(workplace.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddWorkplaceView: View {
    @EnvironmentObject var workplaceManager: WorkplaceManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedColor = WorkplaceColor.blue
    @State private var hourlyRate = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("勤務先名", text: $name)
                    
                    Picker("カラー", selection: $selectedColor) {
                        ForEach(WorkplaceColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color.displayName)
                            }
                            .tag(color)
                        }
                    }
                    
                    HStack {
                        Text("時給")
                        TextField("1000", text: $hourlyRate)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("円")
                    }
                }
                
                Section(header: Text("メモ")) {
                    TextField("メモ（任意）", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("勤務先を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addWorkplace()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addWorkplace() {
        let rate = Double(hourlyRate) ?? 0.0
        let workplace = Workplace(
            name: name,
            color: selectedColor,
            hourlyRate: rate,
            notes: notes
        )
        workplaceManager.addWorkplace(workplace)
        dismiss()
    }
}

struct EditWorkplaceView: View {
    @EnvironmentObject var workplaceManager: WorkplaceManager
    @Environment(\.dismiss) private var dismiss
    
    let workplace: Workplace
    
    @State private var name: String
    @State private var selectedColor: WorkplaceColor
    @State private var hourlyRate: String
    @State private var notes: String
    
    init(workplace: Workplace) {
        self.workplace = workplace
        self._name = State(initialValue: workplace.name)
        self._selectedColor = State(initialValue: workplace.color)
        self._hourlyRate = State(initialValue: String(Int(workplace.hourlyRate)))
        self._notes = State(initialValue: workplace.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("勤務先名", text: $name)
                    
                    Picker("カラー", selection: $selectedColor) {
                        ForEach(WorkplaceColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color.displayName)
                            }
                            .tag(color)
                        }
                    }
                    
                    HStack {
                        Text("時給")
                        TextField("1000", text: $hourlyRate)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("円")
                    }
                }
                
                Section(header: Text("メモ")) {
                    TextField("メモ（任意）", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("勤務先を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        updateWorkplace()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func updateWorkplace() {
        let rate = Double(hourlyRate) ?? 0.0
        var updatedWorkplace = workplace
        updatedWorkplace.name = name
        updatedWorkplace.color = selectedColor
        updatedWorkplace.hourlyRate = rate
        updatedWorkplace.notes = notes
        
        workplaceManager.updateWorkplace(updatedWorkplace)
        dismiss()
    }
}

#Preview {
    WorkplaceSettingsView()
        .environmentObject(WorkplaceManager())
}
