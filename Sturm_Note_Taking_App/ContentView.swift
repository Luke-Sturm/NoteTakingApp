//
//  ContentView.swift
//  Sturm_Note_Taking_App
//
//  Created by Luke Sturm on 2/13/26.
//

import SwiftUI
import Combine

/*Pseudocode:
// Define a structure to hold note data
Create a struct named `Note`
Add a property `id` of type `UUID` (generate automatically)
Add a property `title` of type `String`
Add a property `content` of type `String`
Add a property `isCompleted` of type `Bool`
*/
class NotesViewModel: ObservableObject{
    
    @Published var notesList: [Note] = []
    
    init(){
        loadData()
    }
    
    
    /**
    Add Note Function
        get note title, content and isCompleted values.
        Append notesList Array to add new note to the end
     
    Update Notes Function
        Button specifying changing the title or content
        Specify the note that is being updated by the UUID value
     
    Toggle Completion Function
        Function that toggles isComplete on and off using UUID value
        Apply the update to the viewModel object in ContentView
    
    Delete Function
        Removes items from array + removes all variables attached (UUID, title, content, isCompleted)
        Uses .remove() method
     **/
    
    func addNote(title: String, content: String){
        let newNote = Note(title: title, content: content, isCompleted: false)
        notesList.append(newNote)
        saveData()
    }
    
    func updateNote(id: UUID, title: String, content: String, isCompleted: Bool){
        if let index = notesList.firstIndex(where: { $0.id == id }) {
            notesList[index].title = title
            notesList[index].content = content
            notesList[index].isCompleted = isCompleted
        }
        saveData()
    }
    
    func toggleCompletion(id: UUID){
        if let index = notesList.firstIndex(where: { $0.id == id }) {
            notesList[index].isCompleted.toggle()
        }
        saveData()
    }
    
    func deleteNote(at offsets: IndexSet) {
        notesList.remove(atOffsets: offsets)
        saveData()
    }
    
    func saveData(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(notesList){
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
    }
    
    func loadData(){
        if let savedNotes = UserDefaults.standard.data(forKey: "notes"){
            let decoder = JSONDecoder()
            if let loadedNotes = try? decoder.decode([Note].self, from: savedNotes){
                notesList = loadedNotes
            }
        }
    }
}
    

struct Note: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var isCompleted: Bool
}

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()

    var body: some View {
        NavigationStack {
            List{
                Section(header: Text("My Tasks").foregroundColor(.blue)){
                    ForEach(viewModel.notesList){note in
                        NavigationLink(destination: DisplayNoteView(NotePassed: note, viewModel: viewModel)){
                            HStack{
                                if note.isCompleted{
                                    Image(systemName: "checkmark.circle.fill")
                                        .onTapGesture { viewModel.toggleCompletion(id: note.id) }
                                }
                                else{
                                    Image(systemName: "circle")
                                        .onTapGesture { viewModel.toggleCompletion(id: note.id) }
                                }
                                Text(note.title)
                                    .strikethrough(note.isCompleted)
                                    .foregroundColor(note.isCompleted ? .gray : .primary)
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteNote)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=3000&auto=format&fit=crop")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.4)
                } placeholder: {
                    ProgressView() // Shows a loading spinner while the image fetches
                }
            )
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AddNoteView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct AddNoteView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextEditor(text: $content)
                .padding()
            
            Button("Add Note"){
                viewModel.addNote(title: title, content: content)
                dismiss()
            }
        }
    }
}
struct DisplayNoteView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    var NotePassed: Note
    
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            TextField("Title", text: $title)
                .strikethrough(NotePassed.isCompleted)
                .foregroundColor(NotePassed.isCompleted ? .gray : .primary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextEditor(text: $content)
                .scrollContentBackground(.hidden)
                .background(
                    LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .padding()
        
            Button("Done"){
                viewModel.updateNote(id: NotePassed.id,title: title, content: content, isCompleted: NotePassed.isCompleted)
                dismiss()
            }
            
        }
        .onAppear(){
            title = NotePassed.title
            content = NotePassed.content
        }
    }
}

#Preview {
    ContentView()
}
