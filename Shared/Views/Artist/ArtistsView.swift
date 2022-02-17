//
//  ArtistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import Combine

struct ArtistsView: View {
        
    
    var artists: FetchedResults<Artist>{
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Artist>
        
    @ObservedObject
    var networkingManager = NetworkingManager.shared
    
    @State
    var galleryView : Bool = UserDefaults.standard.bool(forKey: "artistGalleryView")
    
    init() {
                
        self.fetchRequest = FetchRequest(
            entity: Artist.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Artist.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        )
    }
    
    var body: some View {
        NavigationView {
                       
            VStack {
                if galleryView {
                    ArtistsGalleryView(artists: artists)
                } else {
                    ArtistsListView(artists: artists)
                }
            }
            .navigationTitle("Artists")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            galleryView.toggle()
                            UserDefaults.standard.set(self.galleryView, forKey: "artistGalleryView")
                        }
                    }, label: {
                        if galleryView {
                            Image(systemName: "list.bullet")
                        } else {
                            Image(systemName: "circle.grid.2x2")
                        }
                    })
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    SyncLibraryButton()
                }
            }
        }
    }
}

class SearchBarViewModel : ObservableObject {
    @Published var search : String = ""
}
