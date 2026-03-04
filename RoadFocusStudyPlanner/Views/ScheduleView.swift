import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingAddSheet = false
    @State private var selectedEntry: ScheduleEntry?
    @State private var showingSubjectManager = false
    
    private var todayIndex: Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Day headers
                    HStack(spacing: 0) {
                        Text("Time")
                            .font(.caption.bold())
                            .foregroundColor(AppColors.darkGray)
                            .frame(width: 50)
                        
                        ForEach(0..<7, id: \.self) { dayIdx in
                            Text(dayNames[dayIdx])
                                .font(.caption.bold())
                                .foregroundColor(dayIdx == todayIndex ? .white : AppColors.darkGray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(dayIdx == todayIndex ? AppColors.gold : Color.clear)
                                )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    // Time slots (6AM - 10PM)
                    ForEach(6..<23, id: \.self) { hour in
                        HStack(spacing: 0) {
                            Text("\(hour):00")
                                .font(.caption2)
                                .foregroundColor(AppColors.darkGray)
                                .frame(width: 50)
                            
                            ForEach(0..<7, id: \.self) { dayIdx in
                                let entries = entriesFor(day: dayIdx, hour: hour)
                                ZStack {
                                    Rectangle()
                                        .fill(dayIdx == todayIndex ? AppColors.gold.opacity(0.05) : Color.clear)
                                    Rectangle()
                                        .stroke(AppColors.lightGray, lineWidth: 0.5)
                                    
                                    if let entry = entries.first {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(store.colorForSubject(entry.subject).opacity(0.3))
                                            .overlay(
                                                Text(entry.subject)
                                                    .font(.system(size: 8))
                                                    .foregroundColor(AppColors.darkGray)
                                                    .lineLimit(1)
                                                    .padding(2)
                                            )
                                            .padding(1)
                                            .onTapGesture {
                                                selectedEntry = entry
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .onTapGesture {
                                    if entries.isEmpty {
                                        selectedEntry = ScheduleEntry(
                                            subject: "",
                                            dayOfWeek: dayIdx,
                                            startHour: hour,
                                            startMinute: 0,
                                            endHour: hour + 1,
                                            endMinute: 0,
                                            colorIndex: 0
                                        )
                                        showingAddSheet = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
            .background(Color.white)
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSubjectManager = true }) {
                        Text("Subjects")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        PlusIcon()
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddScheduleEntrySheet(entry: selectedEntry, store: store) {
                    showingAddSheet = false
                    selectedEntry = nil
                }
            }
            .sheet(isPresented: $showingSubjectManager) {
                SubjectManagerSheet(store: store)
            }
            .onChange(of: showingAddSheet) { newVal in
                if !newVal { selectedEntry = nil }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func entriesFor(day: Int, hour: Int) -> [ScheduleEntry] {
        store.scheduleEntries.filter { $0.dayOfWeek == day && $0.startHour <= hour && $0.endHour > hour }
    }
}

// MARK: - Add/Edit Schedule Entry
struct AddScheduleEntrySheet: View {
    var entry: ScheduleEntry?
    @ObservedObject var store: DataStore
    var onDismiss: () -> Void
    
    @State private var subject = ""
    @State private var dayOfWeek = 1
    @State private var startHour = 8
    @State private var endHour = 9
    @State private var newSubjectName = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Subject")) {
                    if store.subjects.isEmpty {
                        HStack {
                            TextField("New subject name", text: $newSubjectName)
                            Button("Add") {
                                if !newSubjectName.isEmpty {
                                    store.addSubject(name: newSubjectName)
                                    subject = newSubjectName
                                    newSubjectName = ""
                                }
                            }
                            .foregroundColor(AppColors.gold)
                        }
                    } else {
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
                }
                
                Section(header: Text("Day")) {
                    Picker("Day", selection: $dayOfWeek) {
                        ForEach(0..<7, id: \.self) { i in
                            Text(fullDayNames[i]).tag(i)
                        }
                    }
                }
                
                Section(header: Text("Time")) {
                    Picker("Start", selection: $startHour) {
                        ForEach(6..<23, id: \.self) { h in
                            Text("\(h):00").tag(h)
                        }
                    }
                    Picker("End", selection: $endHour) {
                        ForEach(7..<24, id: \.self) { h in
                            Text("\(h):00").tag(h)
                        }
                    }
                }
                
                if let existing = entry, !existing.subject.isEmpty {
                    Section {
                        Button("Delete Entry") {
                            store.scheduleEntries.removeAll { $0.id == existing.id }
                            presentationMode.wrappedValue.dismiss()
                            onDismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(entry?.subject.isEmpty == false ? "Edit Entry" : "Add Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        presentationMode.wrappedValue.dismiss()
                        onDismiss()
                    }
                    .disabled(subject.isEmpty)
                }
            }
            .onAppear {
                if let e = entry, !e.subject.isEmpty {
                    subject = e.subject
                    dayOfWeek = e.dayOfWeek
                    startHour = e.startHour
                    endHour = e.endHour
                } else if let e = entry {
                    dayOfWeek = e.dayOfWeek
                    startHour = e.startHour
                    endHour = e.endHour
                }
            }
        }
    }
    
    func saveEntry() {
        guard !subject.isEmpty else { return }
        let colorIdx = store.subjects.first(where: { $0.name == subject })?.colorIndex ?? 0
        
        if let existing = entry, !existing.subject.isEmpty {
            if let idx = store.scheduleEntries.firstIndex(where: { $0.id == existing.id }) {
                store.scheduleEntries[idx] = ScheduleEntry(
                    id: existing.id, subject: subject, dayOfWeek: dayOfWeek,
                    startHour: startHour, startMinute: 0, endHour: endHour, endMinute: 0, colorIndex: colorIdx
                )
            }
        } else {
            store.scheduleEntries.append(ScheduleEntry(
                subject: subject, dayOfWeek: dayOfWeek,
                startHour: startHour, startMinute: 0, endHour: endHour, endMinute: 0, colorIndex: colorIdx
            ))
        }
    }
}

// MARK: - Subject Manager
struct SubjectManagerSheet: View {
    @ObservedObject var store: DataStore
    @State private var newName = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add Subject")) {
                    HStack {
                        TextField("Subject name", text: $newName)
                        Button("Add") {
                            if !newName.isEmpty {
                                store.addSubject(name: newName)
                                newName = ""
                            }
                        }
                        .foregroundColor(AppColors.gold)
                    }
                }
                Section(header: Text("Subjects")) {
                    ForEach(store.subjects) { s in
                        HStack {
                            Circle()
                                .fill(AppColors.subjectColors[s.colorIndex % AppColors.subjectColors.count])
                                .frame(width: 12, height: 12)
                            Text(s.name)
                                .foregroundColor(AppColors.darkGray)
                        }
                    }
                    .onDelete { idx in
                        store.subjects.remove(atOffsets: idx)
                    }
                }
            }
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}
