//
//  SongHelper.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 1/29/22.
//

import Foundation
import CoreData

class SongHelper {
    static let shared = SongHelper()
    
    func associatePlaylistSongWithSong(song: Song, songResult: SongResult, playlistSong: PlaylistSong, playlist: Playlist, album: Album, artist: Artist) -> Void {
        // Create the song and store it
        song.jellyfinId = songResult.id
        song.name = songResult.name
        playlistSong.song = song
                
        song.album = album
        
        song.addToArtists(artist)
        
        playlistSong.song = song
        
        playlist.addToSongs(playlistSong)
        
        if playlistSong.song == nil || playlistSong.song!.album == nil {
            print("WTF")
        }
        
        if playlistSong.playlist == nil {
            print("WTF")
        }
        
//        // TODO: Make album optional on song so that we can save here
//        do {
//            try JellyfinService.context.save()
//        } catch {
//            print(error)
//        }
    }
}
