//
//  LibrarySelectionView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import SwiftUI

struct LibrarySelectionView: View {
    
    var librarySelectionService = LibrarySelectionService.shared

    @State
    var selectedLibrary : LibraryResult = LibraryResult(id: "", name: "", collectionType: "")
    
    @State
    var libraries : [LibraryResult] = []
        
    var body: some View {
        NavigationView {
            
            VStack {
                Picker("Select Music Library", selection: $selectedLibrary, content: {
                    ForEach(libraries) { library in
                        Text(library.name)
                    }
                })
                    .pickerStyle(.wheel)
            
                Button(action: {
                    librarySelectionService.saveLibrary(selectedLibrary: selectedLibrary)
                }, label: {
                    Text("Start Listening")
                })
            }
            .navigationTitle("Select Your Library")
            .onAppear(perform: {
                librarySelectionService.retrieveLibraries(complete: { libraries in
                    self.libraries = libraries.items
                    selectedLibrary = libraries.items[0]
                })
            })

        }
    }
}
