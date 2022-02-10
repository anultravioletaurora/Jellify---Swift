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
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
        
    @StateObject
    var searchBar = SearchBarViewModel()
        
    @FocusState
    var isSearchFocused : Bool
    
    init() {
                
        self.fetchRequest = FetchRequest(
            entity: Artist.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Artist.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        )
    }
    
    func getSongCount(artist : Artist) -> Int{
        
        var songCount : Int = 0
        
        if (artist.albums != nil) {
            for album in artist.albums! {
                songCount += (album as! Album).songs!.count
            }
        }
        
        return songCount
    }
    
//    func viewDidLoad() {
//        artistService.retrieveArtist(complete: { result in
//            storeArtists(items: result.items)
//        })
//    }
//
    var body: some View {
        NavigationView {

                                
            // Artists List
            List(artists) { artist in
                ArtistRow(artist: artist)
                    .padding(.bottom, artists.last! == artist ? 65 : 0)
                    .listRowSeparator(artists.last! == artist ? .hidden : .visible)
            }
            .searchable(text: $searchBar.search, prompt: "Search artists")
            .disableAutocorrection(true)
            .onReceive(
                        
                searchBar.$search.debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            ) {
                guard !$0.isEmpty else {
                    artists.nsPredicate = nil
                    return
                }
                artists.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Artist.name), searchBar.search.trimmingCharacters(in: .whitespaces))
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Artists")
            .toolbar(content: {
                ToolbarItem(content: {
                    Button(action: {
                        print("syncing library")
                    }, label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    })
                        .buttonStyle(PlainButtonStyle())

                })
            })
        }
    }
}

class SearchBarViewModel : ObservableObject {
    @Published var search : String = ""
}
