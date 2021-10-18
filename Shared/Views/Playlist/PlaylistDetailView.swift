//
//  PlaylistDetailView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/15/21.
//

import SwiftUI

struct PlaylistDetailView: View {
    
    var playlist : Playlist
    
    var fetchRequest: FetchRequest<Song>
    
    var playlistSongs: FetchedResults<Song>{
        fetchRequest.wrappedValue
    }

    @State
    var songs : [Song] = []
    
    init(playlist: Playlist) {
        self.playlist = playlist
        
        self.fetchRequest = FetchRequest(
            entity: Song.entity(),
            sortDescriptors: [NSSortDescriptor(key: "indexNumber", ascending: true)],
            predicate: NSPredicate(format: "(playlist == %@)", playlist)
        )
    }
    
    var body: some View {
        List(playlistSongs) { playlistSong in
                
                Button(action: {
                    print("Playing \(playlistSong.name ?? "Unknown Song")")
                    
                    Player.shared.loadSongs(Array(playlistSongs), songId: playlistSong.jellyfinId!)
                    Player.shared.isPlaying = true
                                    
                    print("Playing!")
                }, label: {
                    HStack(alignment: .center, content: {
                        
                        VStack(alignment: .center, spacing: 10, content: {
                            Text(String(playlistSong.indexNumber))
                                .font(.subheadline)
                                .padding(.trailing, 5)
                        }).padding(.trailing, 5)
                                                
                        VStack(alignment: .leading, spacing: 10) {
                            Text(playlistSong.name ?? "Unknown Song")
                                .padding(.leading, 5)
                        }
                        
                        Spacer()
                    })
                })
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .buttonStyle(PlainButtonStyle())

        }
        .listStyle(PlainListStyle())
        .navigationTitle(playlist.name ?? "Unknown Playlist")

    }
}
