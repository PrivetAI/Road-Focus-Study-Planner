import SwiftUI

struct TasksView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingAddTask = false
    @State private var filterSubject = "All"
    @State private var filterStatus = "All"
    
    var filteredTasks: [StudyTask] {
        store.tasks.filter { task in
            (filterSubject == "All" || task.subject == filterSubject) &&
            (filterStatus == "All" || task.status.rawValue == filterStatus)
        }
        .sorted { $0.deadline < $1.deadline }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Subject filter
                        Menu {
                            Button("All") { filterSubject = "All" }
                            ForEach(store.subjects) { s in
                                Button(s.name) { filterSubject = s.name }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Subject: \(filterSubject)")
                                    .font(.caption)
                                    .foregroundColor(AppColors.darkGray)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.lightGray)
                            .cornerRadius(12)
                        }
                        
                        // Status filter
                        Menu {
                            Button("All") { filterStatus = "All" }
                            ForEach(TaskStatus.allCases, id: \.rawValue) { s in
                                Button(s.rawValue) { filterStatus = s.rawValue }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Status: \(filterStatus)")
                                    .font(.caption)
                                    .foregroundColor(AppColors.darkGray)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.lightGray)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.white)
                
                if filteredTasks.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        ChecklistIcon()
                            .stroke(AppColors.lightGray, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: 60, height: 60)
                        Text("No tasks yet")
                            .foregroundColor(AppColors.darkGray.opacity(0.6))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRow(task: task, store: store)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color.white)
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        PlusIcon()
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet(store: store)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func deleteTasks(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { filteredTasks[$0] }
        for t in tasksToDelete {
            store.tasks.removeAll { $0.id == t.id }
        }
    }
}

struct TaskRow: View {
    let task: StudyTask
    @ObservedObject var store: DataStore
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            Rectangle()
                .fill(task.priority.color)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.status == .done ? AppColors.darkGray.opacity(0.5) : AppColors.darkGray)
                    .strikethrough(task.status == .done)
                
                HStack(spacing: 8) {
                    Text(task.subject)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(store.colorForSubject(task.subject))
                        .cornerRadius(4)
                    
                    Text(task.deadline, style: .date)
                        .font(.caption)
                        .foregroundColor(AppColors.darkGray.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Status button
            Menu {
                ForEach(TaskStatus.allCases, id: \.rawValue) { status in
                    Button(status.rawValue) {
                        if let idx = store.tasks.firstIndex(where: { $0.id == task.id }) {
                            store.tasks[idx].status = status
                        }
                    }
                }
            } label: {
                Text(task.status.rawValue)
                    .font(.caption2)
                    .foregroundColor(AppColors.darkGray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.lightGray)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                store.tasks.removeAll { $0.id == task.id }
            } label: {
                Text("Delete")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                if let idx = store.tasks.firstIndex(where: { $0.id == task.id }) {
                    store.tasks[idx].status = .done
                }
            } label: {
                Text("Done")
            }
            .tint(.green)
        }
    }
}

struct AddTaskSheet: View {
    @ObservedObject var store: DataStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var subject = ""
    @State private var deadline = Date()
    @State private var priority: TaskPriority = .medium
    @State private var newSubjectName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    TextField("Title", text: $title)
                }
                
                Section(header: Text("Subject")) {
                    Picker("Subject", selection: $subject) {
                        Text("Select...").tag("")
                        ForEach(store.subjects) { s in
                            Text(s.name).tag(s.name)
                        }
                    }
                    HStack {
                        TextField("Or add new", text: $newSubjectName)
                        Button("Add") {
                            if !newSubjectName.isEmpty {
                                store.addSubject(name: newSubjectName)
                                subject = newSubjectName
                                newSubjectName = ""
                            }
                        }
                        .foregroundColor(AppColors.gold)
                    }
                }
                
                Section(header: Text("Details")) {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.rawValue) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard !title.isEmpty, !subject.isEmpty else { return }
                        store.tasks.append(StudyTask(
                            title: title, subject: subject, deadline: deadline,
                            priority: priority, status: .notStarted
                        ))
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || subject.isEmpty)
                }
            }
        }
    }
}
