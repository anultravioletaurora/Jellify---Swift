//
//  DownloadManager.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/19/22.
//

import Foundation
import CoreData
import SwiftUI
import HLSion

public class DownloadManager {
    
    static let shared: DownloadManager = DownloadManager()
    let networkingManager : NetworkingManager = NetworkingManager.shared
    
    static func getDownloadUrl(song: Song) -> URL {
        let container = "opus,mp3,aac,m4a,flac,webma,webm,wav,ogg,mpa,wma"
        
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let url = "\(NetworkingManager.shared.server)/Audio/\(song.jellyfinId!)/main.m3u8?UserId=\(NetworkingManager.shared.userId)&DeviceId=\(deviceId)&Container=\(container)&TranscodingProtocol=hls&AudioCodec=aac"
        
        return URL(string: url)!
    }
    
    public func download(song: Song){
        withAnimation{
            song.downloading = true
        }
            print("Starting")
        let item = HLSion(url: DownloadManager.getDownloadUrl(song: song), options: [ "AVURLAssetHTTPHeaderFieldsKey" : ["X-Emby-Token": NetworkingManager.shared.accessToken] ], name: song.jellyfinId!)
            try? item.deleteAsset()
            if item.localUrl == nil {
                item.download { (progressPercentage) in
                    withAnimation{
//                         song.progress = CGFloat(progressPercentage)
                        song.downloading = true
                        song.downloaded = false
                        try? self.networkingManager.context.save()
                    }
                }
                .finish { (relativePath) in
                    withAnimation{
                        song.downloaded = true
                        song.downloading = false
                        song.downloadUrl = item.localUrl!
                    }
                    try? self.networkingManager.context.save()
//                    song.album?.checkDownload()
                }.onError { (error) in
                    withAnimation{
                        song.downloading = false
                    }
                    print(error)
                }
            }else{
                withAnimation{
                    song.downloaded = true
                    song.downloading = false
                    song.downloadUrl = item.localUrl!
                }
                try? networkingManager.context.save()
//                song.album?.checkDownload()
            }
    }
    
    public func deleteDownload(song: Song){
            print("Starting")
            let item = HLSion(url: DownloadManager.getDownloadUrl(song: song), options: [ "AVURLAssetHTTPHeaderFieldsKey" : ["X-Emby-Token": NetworkingManager.shared.accessToken] ], name: song.jellyfinId!)

            if item.localUrl != nil {
                
                if ((try? item.deleteAsset()) != nil){
                    withAnimation{
                        song.downloaded = false
                        song.downloading = false
                    }
                    try? self.networkingManager.context.save()
//                    song.album?.checkDownload()
                }
                
            }
    }
}
