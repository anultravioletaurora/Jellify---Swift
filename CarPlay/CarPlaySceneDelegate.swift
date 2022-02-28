//
//  CarPlaySceneDelegateName.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/28/22.
//

import Foundation
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    let networkingManager = NetworkingManager.shared
    
    var player = Player.shared
    
    var interfaceController: CPInterfaceController?
    // CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        // Creating Tab Sections
        let homeItem = CPListItem(text: "Home", detailText: "Home")
        homeItem.handler = { item, completion in
            self.interfaceController?.pushTemplate(CPNowPlayingTemplate.shared, animated: true)
            completion()
        }
        
        let homeSection = CPListSection(items: [homeItem])
        
        let homeListTemplate = CPListTemplate(title: "Home", sections: [homeSection])
                                          
        let tabHome: CPListTemplate = homeListTemplate
        tabHome.tabSystemItem = .featured
    
        // Create Playlist Tab
        let playlistButtons = networkingManager.retrieveAllPlaylistsFromCore().sorted(by: {
            $0.sortName! < $1.sortName!
        }).map({ playlist -> CPListItem in
            
//            self.networkingManager.loadPlaylistImage(playlist: playlist)
            
            self.networkingManager.retrievePlaylistSongsFromCore(playlistId: playlist.jellyfinId!)!.forEach({ objectId in
                
                let playlistSong = self.networkingManager.privateContext.object(with: objectId) as! PlaylistSong
                
                self.networkingManager.loadAlbumArtwork(album: playlistSong.song!.album!)
            })
            
            let listItem = CPListItem(text: playlist.name!, detailText: "", image: playlist.thumbnail != nil ? UIImage(data: playlist.thumbnail!) : nil)
                        
            listItem.userInfo = playlist.jellyfinId!

            listItem.handler = { item, completion in
                
                print(item.userInfo)
                
                var playlistSongListItems : [CPListTemplateItem] = []
                                
                let playlistSongIds = self.networkingManager.retrievePlaylistSongsFromCore(playlistId: item.userInfo as! String)
                                
                let playlistSongs = playlistSongIds?.map { id in
                    self.networkingManager.context.object(with: id)} as? [PlaylistSong]
                
                if let songs = playlistSongs?.sorted(by: {
                    $0.indexNumber < $1.indexNumber
                }) {
                    
                    playlistSongListItems = songs.map({ $0.song! }).map { (song: Song) -> CPListItem in
                                                    
                        let playlistSongItem = CPListItem(text: song.name, detailText: Builders.artistName(song: song), image: song.album?.thumbnail != nil ? UIImage(data: (song.album?.thumbnail)!) : nil, accessoryImage: song.downloaded ? UIImage(systemName: "arrow.down.circle.fill") : UIImage(systemName: "icloud"), accessoryType: song.downloaded ? .none : .cloud)
                        
                        playlistSongItem.handler = {item, completion in
                            
                            self.player.loadSongs(songs.map { $0.song! }, songId: song.jellyfinId!)
                            
                            self.player.isPlaying = true
                            
                            self.interfaceController?.pushTemplate(CPNowPlayingTemplate.shared, animated: true)
                            
                            completion()
                        }
                        
                        return playlistSongItem
                    }
                }
                
                let playlistListSection = CPListSection(items: playlistSongListItems)
                
                let playlistListTemplate = CPListTemplate(title: playlist.name ?? "", sections: [playlistListSection])
                
                self.interfaceController?.pushTemplate(playlistListTemplate, animated: true)
                
                completion()
            }
            
            return listItem
        })
        
        let playlistsSection = CPListSection(items: playlistButtons)

        let playlistsListTemplate = CPListTemplate(title: "Playlists", sections: [playlistsSection])
//        let playlistsGridTemplate = CPGridTemplate(title: "Playlists", gridButtons: playlistButtons)
        
        let tabPlaylists: CPListTemplate = playlistsListTemplate
        tabPlaylists.tabSystemItem = .recents
        
        // Create Artists Tab
                    
        let tabBarTemplate = CPTabBarTemplate(templates: [tabHome, tabPlaylists])
        self.interfaceController!.setRootTemplate(tabBarTemplate, animated: true)

    }
    // CarPlay disconnected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
 } }
