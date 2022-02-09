//
//  PlaylistDetailView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/15/21.
//

import SwiftUI

struct PlaylistDetailView: View {
    
    @ObservedObject
    var playlist : Playlist
        
    var fetchRequest: FetchRequest<PlaylistSong>
    
    var playlistSongs: FetchedResults<PlaylistSong>{
        fetchRequest.wrappedValue
    }
    
    let networkingManager : NetworkingManager = NetworkingManager.shared

    @State
    var songs : [Song] = []
    
    init(playlist: Playlist) {
        self.playlist = playlist
        
        self.fetchRequest = FetchRequest(
            entity: PlaylistSong.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "(playlist == %@)", playlist)
        )
    }
    
    var body: some View {
        List(playlistSongs) { (playlistSong : PlaylistSong) in
                
                Button(action: {
                    print("Playing \(playlistSong.song?.name ?? "Unknown Song") from \(playlistSong.song?.album?.name ?? "Unknown Album")")
                    
                    Player.shared.loadSongs(playlistSongs.map { song in
                        return song.song!
                    }, songId: playlistSong.song!.jellyfinId!)
                    Player.shared.isPlaying = true
                                    
                    print("Playing!")
                }, label: {
                    HStack(alignment: .center, content: {
                        
                        AlbumThumbnail(album: playlistSong.song!.album!)
                                                           
                        VStack(alignment: .leading, spacing: 10) {
                            Text(playlistSong.song?.name! ?? "Unknown Song")
                            
                            HStack {
//                                Text(playlistSong.song?.album?.name! ?? "Unknown Album")
//                                    .font(.subheadline)
                                Text(getArtistNameArray(playlistSong: playlistSong))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.leading, 5)
                        
                        Spacer()
                    })
                })
                .onAppear(perform: {
                    if playlistSong.song!.album != nil && playlistSong.song!.album!.thumbnail == nil {
                        networkingManager.loadAlbumArtwork(album: playlistSong.song!.album!)
                    }
                })
                .swipeActions(allowsFullSwipe: true, content: {
                    Button(action: {
                        print("Playlist Item Swiped to delete")
                        
                        networkingManager.deleteFromPlaylist(playlist: playlist, playlistSong: playlistSong)
                    }) {
                        Image(systemName: "trash")
                            .background(.red)
                    }
                    .tint(.red)

                })
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .buttonStyle(PlainButtonStyle())

        }
        .padding(.bottom, 69)
        .listStyle(PlainListStyle())
        .navigationTitle(playlist.name ?? "Unknown Playlist")
        .navigationBarTitleDisplayMode(.inline)

    }
    
    func getArtistNameArray(playlistSong: PlaylistSong) -> String {
        var artistNameArray : [String] = []

        playlistSong.song?.artists?.forEach({ artist in
            artistNameArray.append((artist as! Artist).name ?? "")
        })

        return artistNameArray.joined(separator: ", ")
    }
}
