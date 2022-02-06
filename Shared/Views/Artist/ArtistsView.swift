//
//  ArtistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct ArtistsView: View {
    
    let artistService = ArtistService.shared
    
    var artists: FetchedResults<Artist>{
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Artist>
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
        
    @State
    var search : String = ""
    
    @State
    var loading : Bool = true
    
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
        
            // Display spinner if we're loading
            if loading {
                ProgressView("Loading Artists")
            }
            
            // Else display artists
            else {
                    
                    // Artists List
                List(artists) { artist in
                    ArtistRow(artist: artist)
                }
                .searchable(text: $search, prompt: "Search artists")
                .disableAutocorrection(true)
                .onChange(of: search, perform: { newSearch in
                                                        
                    artists.nsPredicate = newSearch.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Artist.name), newSearch.trimmingCharacters(in: .whitespaces))
                })
                .listStyle(PlainListStyle())
                .navigationTitle("Artists")
                .refreshable {
                    
                    if !loading {
                        self.forceFetchArtists()
                    }
                }
            }
        }
        .onAppear(perform: {
            
            if self.artists.isEmpty {
                
                loading = true

                artistService.retrieveArtists(complete: {
                    loading = false
                })
            } else {
                loading = false
            }
        })
    }
    
    func forceFetchArtists() -> Void {
        
        loading = true
        
        artistService.deleteAllEntities()
        
        artistService.retrieveArtists(complete: {
            loading = false
        })
        
        loading = false
    }
}
