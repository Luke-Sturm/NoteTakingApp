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
    }
    
    func updateNote(id: UUID, title: String, content: String, isCompleted: Bool){
        if let index = notesList.firstIndex(where: { $0.id == id }) {
            notesList[index].title = title
            notesList[index].content = content
        }
    }
    
    func toggleCompletion(id: UUID){
        if let index = notesList.firstIndex(where: { $0.id == id }) {
            notesList[index].isCompleted.toggle()
        }
    }
    
    func deleteNote(at offsets: IndexSet) {
        notesList.remove(atOffsets: offsets)
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
                ForEach(viewModel.notesList){note in
                    Text(note.title)
                }
                .onDelete(perform: viewModel.deleteNote)
                
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addNote(title: "New Note", content: "")
                    } label: {
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
                
            }
        }
    }
}

#Preview {
    ContentView()
}
