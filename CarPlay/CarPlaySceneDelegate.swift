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
        // SECTION - ARTISTS
        let artists = networkingManager.retrieveAllArtistsFromCore().sorted(by: {
            
            if $0.favorite && !$1.favorite {
                return true
            } else if !$0.favorite && $1.favorite {
                return false
            } else {
                return $0.sortName ?? $1.name! < $1.sortName ?? $1.name!
            }
        })
        
        artists.forEach({ artist in
            if artist.thumbnail == nil {
                self.networkingManager.loadArtistImage(artist: artist)
            }
        })
        
        let artistListItems = artists.map({ artist -> CPListItem in
            
            let listItem = CPListItem(text: artist.name!, detailText: "", image: artist.thumbnail != nil ? UIImage(data: artist.thumbnail!) : nil)
            
            listItem.userInfo = artist.name!
            
            listItem.handler = { item, completion in
                print(item.userInfo)
                
                var artistAlbumListItems : [CPListTemplateItem] = []
                
                let artistAlbumIds = self.networkingManager.retrieveAlbumsFromCore(albumArtistName: item.userInfo as! String)
                
                let artistAlbums = artistAlbumIds.map { id in
                    self.networkingManager.context.object(with: id)
                } as? [Album]
                
                if let albums = artistAlbums?.sorted(by: {
                    if $0.favorite && !$1.favorite {
                        return true
                    } else if !$0.favorite && $1.favorite {
                        return false
                    } else {
                        return $0.sortName ?? $1.name! < $1.sortName ?? $1.name!
                    }
                }) {
                    
                    artistAlbumListItems = albums.map({ (album: Album) -> CPListItem in
                        
                        let albumItem = CPListItem(text: album.name!, detailText: album.albumArtistName, image: album.thumbnail != nil ? UIImage(data: album.thumbnail!) : nil)
                        
                        albumItem.userInfo = album.jellyfinId!
                        
                        albumItem.handler = { albumListItem, albumItemCompletion in
                            var albumSongItems : [CPListTemplateItem] = []
                            
                            let albumSongIds = self.networkingManager.retrieveSongsFromCore(albumId: albumListItem.userInfo as! String)
                            
                            let albumSongs = albumSongIds.map { id in
                                self.networkingManager.context.object(with: id)
                                
                            } as! [Song]

                                                                     
                            albumSongItems = albumSongs.map({ (song: Song) -> CPListItem in
                                let albumSongItem = CPListItem(text: song.name, detailText: Builders.artistName(song: song), image: album.thumbnail != nil ? UIImage(data: (album.thumbnail)!) : nil, accessoryImage: song.downloaded ? UIImage(systemName: "arrow.down.circle.fill") : UIImage(systemName: "icloud"), accessoryType: song.downloaded ? .none : .cloud)
                                
                                albumSongItem.handler = { subItem, subCompletion in
                                    
                                    self.player.loadSongs(albumSongs, songId: song.jellyfinId!)
                                    
                                    self.player.isPlaying = true
                                    
                                    self.interfaceController?.pushTemplate(CPNowPlayingTemplate.shared, animated: true)
                                    
                                    subCompletion()
                                }
                                
                                return albumSongItem
                            })
                            
                            let albumSongsSection = CPListSection(items: albumSongItems)
                            
                            let albumSongsTemplate = CPListTemplate(title: album.name!, sections: [albumSongsSection])
                            
                            self.interfaceController?.pushTemplate(albumSongsTemplate, animated: true)
                                                        
                            albumItemCompletion()
                        }
                        
                        return albumItem
                    })
                    
                    let artistAlbumsSection = CPListSection(items: artistAlbumListItems)
                    
                    let artistAlbumsTemplate = CPListTemplate(title: item.userInfo as! String, sections: [artistAlbumsSection])
                    
                    self.interfaceController?.pushTemplate(artistAlbumsTemplate, animated: true)
                }
    
                completion()
            }
            
            return listItem
        })
        
        let artistsSection = CPListSection(items: artistListItems)
        
        let artistsTemplate = CPListTemplate(title: "Artists", sections: [artistsSection])
                                          
        let tabArtists: CPListTemplate = artistsTemplate
        tabArtists.tabTitle = "Artists"
        tabArtists.tabImage = UIImage(systemName: "music.mic")
    
        // SECTION - PLAYLISTS
        let playlists = networkingManager.retrieveAllPlaylistsFromCore().sorted(by: {
            $0.sortName! < $1.sortName!
        })
        
        playlists.forEach({ playlist in
            if playlist.thumbnail == nil {
                self.networkingManager.loadPlaylistImage(playlist: playlist)
            }
        })
        
        let playlistButtons = playlists.map({ playlist -> CPListItem in
                        
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
        
        let tabPlaylists: CPListTemplate = playlistsListTemplate
        tabPlaylists.tabTitle = "Playlists"
        tabPlaylists.tabImage = UIImage(systemName: "music.note.list")
        
        // Build tab bar template and set as root template
        let tabBarTemplate = CPTabBarTemplate(templates: [tabArtists, tabPlaylists])
        self.interfaceController!.setRootTemplate(tabBarTemplate, animated: true)

    }
    // CarPlay disconnected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
 } }
