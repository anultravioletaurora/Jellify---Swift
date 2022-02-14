//
//  SongsListView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/12/22.
//

import SwiftUI
import CoreData

struct SongsListView: View {
    
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
    
    @Binding
    var limit: Int
                
    let networkingManager : NetworkingManager = NetworkingManager.shared
    
    let searchQueue : DispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    let INITIAL_PAGE_SIZE : Int = 1000

    init(limit: Binding<Int>) {
        
        self._limit = limit
                        
        let request = NSFetchRequest<Song>(entityName: "Song")
        
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Song.name), ascending: true, selector:
                                                    #selector(NSString.caseInsensitiveCompare))]
                
        request.fetchLimit = limit.wrappedValue
        
//        self.fetchRequest = FetchRequest(
//            entity: Song.entity(),
//            sortDescriptors: [NSSortDescriptor(key: #keyPath(Song.name), ascending: true, selector:
//                                #selector(NSString.caseInsensitiveCompare))]
//        )
        
        self.fetchRequest = FetchRequest(fetchRequest: request, animation: nil)
                        
        print("Song view rendered")
    }
    
    var body: some View {
                
        // TODO: Turn this into a sectioned list with alphabetical separators
        List(songs, id: \.jellyfinId) { song in
            SongRow(song: song, selectedSong: $selectedSong, songs: Array(songs), showPlaylistSheet: $showPlaylistSheet, type: .songs)
                .onAppear {
                    
                    if song == songs.last! && songs.count >= limit {
                        print("Last song of total: \(songs.count), increasing limit")
                        self.limit += INITIAL_PAGE_SIZE
                        print("New Limit: \(self.limit)")
                    } else if song == songs.last! {
                        print("Last song of total: \(songs.count)")
                        self.limit = INITIAL_PAGE_SIZE
                        print("New Limit: \(self.limit)")
                    }
                }
        }
        .animation(nil, value: UUID())
        .sheet(isPresented: $showPlaylistSheet, content: {
            PlaylistSelectionSheet(song: $selectedSong, showPlaylistSheet: $showPlaylistSheet)
        })
        .searchable(text: $searchBar.search, prompt: "Search songs")
        .disableAutocorrection(true)
        .onReceive(searchBar.$search.debounce(for: .seconds(0.5), scheduler: RunLoop.main))
        {
            print("Searching with \(searchBar.search)")
                        
            guard !$0.isEmpty else {
                songs.nsPredicate = nil
                return
            }
                    
            songs.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K beginswith[c] %@", #keyPath(Song.name), searchBar.search.trimmingCharacters(in: .whitespaces))
            
        }
        .listStyle(PlainListStyle())
        .onAppear(perform: {
            
        })

    }
}
