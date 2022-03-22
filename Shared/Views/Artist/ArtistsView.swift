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
    
    @EnvironmentObject
    var settings : Settings
    
    init() {
                
        self.fetchRequest = FetchRequest(
            entity: Artist.entity(),
            sortDescriptors: [
				NSSortDescriptor(key: #keyPath(Artist.favorite), ascending: false),
				NSSortDescriptor(key: #keyPath(Artist.sortName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
			]
//			predicate: NSPredicate(format: "albums.@count != 0")
        )
    }
    
    var body: some View {
        NavigationView {
                       
            VStack {
                if settings.displayAsGallery {
                    ArtistsGalleryView(artists: artists)
                } else {
                    ArtistsListView(artists: artists)
                }
            }
            
            // This overlay prevents list content from appearing behind the tab view when dismissing the player
            .overlay(content: {
                BlurView()
                    .offset(y: UIScreen.main.bounds.height - 150)
            })
            .navigationTitle("Artists")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            settings.displayAsGallery.toggle()
                        }
                    }, label: {
                        if settings.displayAsGallery {
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
		.navigationViewStyle(.stack) 
    }
}

class SearchBarViewModel : ObservableObject {
    @Published var search : String = ""
}
