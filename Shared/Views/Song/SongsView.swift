//
//  SongsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import CoreData

struct SongsView: View {
    
    @State
    var selectedSong: Song?
    
    @State
    var showPlaylistSheet: Bool = false
    
    var songs: FetchedResults<Song> {
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Song>
        
    @StateObject
    var searchBar = SearchBarViewModel()
            
    let networkingManager : NetworkingManager = NetworkingManager.shared
    
    let searchQueue : DispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    init() {
                
        self.fetchRequest = FetchRequest(
            entity: Song.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Song.name), ascending: true, selector:
                                #selector(NSString.caseInsensitiveCompare))]
        )
                        
        print("Song view rendered")
    }
    
    var body: some View {
        NavigationView {
            
            // TODO: Turn this into a sectioned list with alphabetical separators
            List(songs, id: \.jellyfinId) { song in
                SongRow(song: song, selectedSong: $selectedSong, songs: Array(songs), showPlaylistSheet: $showPlaylistSheet, type: .songs)
                    .onAppear {
                        
                        if song == songs.last! {
                        }
                    }
            }
            .animation(nil, value: UUID())
            .sheet(isPresented: $showPlaylistSheet, content: {
                PlaylistSelectionSheet(song: $selectedSong, showPlaylistSheet: $showPlaylistSheet)
            })
            .padding(.bottom, 66)
            .searchable(text: $searchBar.search, prompt: "Search songs")
            .disableAutocorrection(true)
            .onReceive(searchBar.$search.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main))
            {
                guard !$0.isEmpty else {
                    songs.nsPredicate = nil
                    return
                }
                songs.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K beginswith[c] %@", #keyPath(Song.name), searchBar.search.trimmingCharacters(in: .whitespaces))
                
                
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Songs")
        }
    }
}
