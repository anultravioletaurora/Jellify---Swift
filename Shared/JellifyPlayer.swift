//
//  JellifyPlayer.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/19/22.
//

import Foundation
import SwiftAudioPlayer
import UIKit

// TODO: Finish conversion to SwiftAudioPlayer
class JellifyPlayer {
    
    let saplayer = SAPlayer.shared
    
    @Published
    var songs : [Song] {
        didSet {
            
            saplayer.clearAllQueuedAudio()
            
            songs.forEach({ song in
                
                var lockScreenInfo = SALockScreenInfo.init(title: song.name ?? "", artist: Builders.artistName(song: song), albumTitle: song.album!.name ?? "", artwork: getAlbumUiImage(data: song.album!.artwork), releaseDate: 0)
                
                if song.downloaded {
                    saplayer.queueSavedAudio(withSavedUrl: song.downloadUrl!, mediaInfo: lockScreenInfo)
                } else {
                     saplayer.queueRemoteAudio(withRemoteUrl: Builders.streamUrl(song: song), mediaInfo: lockScreenInfo)
                }
            })            
        }
    }
    
    init(songs: [Song]) {
        self.songs = songs
    }
    
    private func getAlbumUiImage(data: Data?) -> UIImage? {
        var image: UIImage?

        if data != nil {
            image = UIImage(data: data!)
        }

        return image
    }
}
