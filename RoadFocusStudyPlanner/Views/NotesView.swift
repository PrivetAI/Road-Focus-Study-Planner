import SwiftUI

struct NotesView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var editingNote: StudyNote?
    @State private var showPrivacyPolicy = false
    
    var filteredNotes: [StudyNote] {
        if searchText.isEmpty {
            return store.notes.sorted { $0.dateCreated > $1.dateCreated }
        }
        return store.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.body.localizedCaseInsensitiveContains(searchText) ||
            $0.subject.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    HStack(spacing: 8) {
                        PencilIcon()
                            .stroke(AppColors.darkGray.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .frame(width: 16, height: 16)
                        TextField("Search notes...", text: $searchText)
                            .foregroundColor(AppColors.darkGray)
                    }
                    .padding(10)
                    .background(AppColors.lightGray)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if filteredNotes.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        PencilIcon()
                            .stroke(AppColors.lightGray, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: 60, height: 60)
                        Text("No notes yet")
                            .foregroundColor(AppColors.darkGray.opacity(0.6))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            Button(action: { editingNote = note }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(note.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.darkGray)
                                        Spacer()
                                        Text(note.subject)
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(store.colorForSubject(note.subject))
                                            .cornerRadius(4)
                                    }
                                    
                                    Text(note.body)
                                        .font(.caption)
                                        .foregroundColor(AppColors.darkGray.opacity(0.6))
                                        .lineLimit(2)
                                    
                                    Text(note.dateCreated, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(AppColors.darkGray.opacity(0.4))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { idx in
                            let toDelete = idx.map { filteredNotes[$0] }
                            for n in toDelete {
                                store.notes.removeAll { $0.id == n.id }
                            }
                        }
                        
                        // Privacy Policy link
                        Section {
                            Button(action: { showPrivacyPolicy = true }) {
                                Text("Privacy Policy")
                                    .foregroundColor(AppColors.gold)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color.white)
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        PlusIcon()
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                NoteEditorSheet(store: store, note: nil)
            }
            .sheet(item: $editingNote) { note in
                NoteEditorSheet(store: store, note: note)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                NavigationView {
                    FocusWebDisplay(url: URL(string: "https://example.com")!)
                        .navigationTitle("Privacy Policy")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { showPrivacyPolicy = false }
                            }
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NoteEditorSheet: View {
    @ObservedObject var store: DataStore
    var note: StudyNote?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var body_ = ""
    @State private var subject = ""
    @State private var newSubjectName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Note title", text: $title)
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
                
                Section(header: Text("Content")) {
                    TextEditor(text: $body_)
                        .frame(minHeight: 150)
                        .foregroundColor(AppColors.darkGray)
                }
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || subject.isEmpty)
                }
            }
            .onAppear {
                if let n = note {
                    title = n.title
                    body_ = n.body
                    subject = n.subject
                }
            }
        }
    }
    
    func saveNote() {
        guard !title.isEmpty, !subject.isEmpty else { return }
        if let existing = note {
            if let idx = store.notes.firstIndex(where: { $0.id == existing.id }) {
                store.notes[idx].title = title
                store.notes[idx].body = body_
                store.notes[idx].subject = subject
            }
        } else {
            store.notes.append(StudyNote(
                title: title, body: body_, subject: subject, dateCreated: Date()
            ))
        }
    }
}
