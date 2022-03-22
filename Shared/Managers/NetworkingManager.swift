//
//  NetworkingManager.swift
//  FinTune
//
//  Created by Jack Caulfield on 2/7/22.
//

import Foundation
import JellyfinAPI
import CoreData
import Combine
import UIKit

class NetworkingManager : ObservableObject {
    
    static let shared = NetworkingManager()
    
    var cancellables = Set<AnyCancellable>()
    
	let processingQueue = DispatchQueue(label: "JellifyProcessingQueue", qos: .userInitiated, attributes: .concurrent)
    
	let imageQueue = DispatchQueue(label: "JellifyImageQueue", qos: .background)
	
	let persistenceController = PersistenceController.shared
        
    let context : NSManagedObjectContext = PersistenceController.shared.container.viewContext
        
    let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
	    
    let sessionId : UUID = UUID()
	
	var songDispatchGroup = DispatchGroup()
    
    @Published
    var loadingPhase : LoadingPhase? = nil {
        didSet {
            switch loadingPhase {
            case .artists:
                loadArtists(complete: {

                })
                
                case .albums:
                loadAlbums(complete: {
                    
                })
                    
            case .songs:
				loadSongs(complete: {
                    self.loadPlaylists(complete: {
												
						// Specify we need to be on a background context
						let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
						
						let playlists = self.retrieveAllPlaylistsFromCore(context: backgroundContext)
						
						let songs = self.retrieveAllSongsFromCore(context: backgroundContext, ids: nil)
						
						backgroundContext.performAndWait {

							var completedPlaylistAdditions : [Bool] = []

							playlists.forEach({ playlist in

								
								self.loadPlaylistItems(playlist: playlist, context: backgroundContext, songs: songs, complete: {
									
									completedPlaylistAdditions.append(true)
									
									if completedPlaylistAdditions.count == playlists.count {
										do {
											try backgroundContext.save()
											
											// Retrieve current sync
											let sync = self.retrieveCurrentSync()
											sync?.timeFinished = Date.now
											sync?.wasSuccess = true

											self.saveContext()
											
											print("Loading complete!")
											
											DispatchQueue.main.async {
												self.loadingPhase = nil
												self.libraryIsPopulated = true
											}
											self.processDownloadQueue()
											
										} catch {
											
											// Retrieve current sync
											let sync = self.retrieveCurrentSync()
											sync?.timeFinished = Date.now
											sync?.wasSuccess = false
											
											self.saveContext()
											
											print("Loading complete!")
											
											DispatchQueue.main.async {
												self.loadingPhase = nil
												self.libraryIsPopulated = true
											}
											self.processDownloadQueue()
										}

									}
								})
							})
						}
                    })
                }, startIndex: 0, retrievedSongIds: [])
                    
//            case .playlists:
//                loadPlaylists(complete: {
//
//                })
            default:
                print("Sync finished")
            }
        }
    }
    
    @Published
    var libraryIsPopulated = false
    
    @Published
    var userIsLoggedIn = false
    
    init() {
        privateContext.parent = context
        
        JellyfinAPI.basePath = server
        
        if (userId != "") {
            setCustomHeaders()
            userIsLoggedIn = true
        }
        
        libraryIsPopulated = libraryIsPopulatedWithAtLeastSomething()
    }
    
    var user: User? {
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        
        return try! self.context.fetch(userRequest).first ?? nil
    }
    
    public var _server: String = ""
    
    public var server: String {
        if _server != ""{
            return _server
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try self.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _server = users[0].server!
                return users[0].server!
            }
        }catch{
            return ""
        }
    }
    
    public var _accessToken: String = ""
    
    public var accessToken: String {
        if _accessToken != ""{
            return _accessToken
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try self.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _accessToken = users[0].authToken!
                return users[0].authToken!
            }
        }catch{
            return ""
        }
    }
    
    public var _userId: String = ""
    public var userId: String {
        if _userId != "" {
            return _userId
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try self.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _userId = users[0].userId!
                return users[0].userId!
            }
        }catch{
            return ""
        }
    }
    
    public var _libraryId: String = ""
    public var libraryId:String {
        if _libraryId != "" {
            return _libraryId
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try self.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _libraryId = users[0].musicLibraryId ?? ""
                return users[0].musicLibraryId ?? ""
            }
        }catch{
            return ""
        }
    }
    
    public var _playlistId: String = ""
    public var playlistId: String {
        if _playlistId != ""{
            return _playlistId
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try self.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _playlistId = users[0].playlistLibraryId ?? ""
                return users[0].playlistLibraryId ?? ""
            }
        }catch{
            return ""
        }
    }
    
    public func syncing() -> Bool {
        return loadingPhase != nil
    }
    
    public func libraryIsPopulatedWithAtLeastSomething() -> Bool {
		self.retrieveAllSongsFromCore(context: nil, ids: nil).count > 0
    }
    
    public func addToPlaylist(playlist: Playlist, song: Song, complete: @escaping () -> Void) -> Void {
        
        print("Adding \(song.name!) to playlist \(playlist.name!)")
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        let privatePlaylist = privateContext.object(with: self.retrievePlaylistFromCore(playlistId: playlist.jellyfinId!)!) as! Playlist

        PlaylistsAPI.addToPlaylist(playlistId: playlist.jellyfinId!, ids: [song.jellyfinId!], userId: self.userId, apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { completion in
                print("Call to add song to playlist complete: \(completion)")
            }, receiveValue: { response in
                print("Playlist addition response: \(response)")
                
                if playlist.songs != nil {

                    privatePlaylist.songs!.forEach({ playlistSong in
                        privateContext.delete(playlistSong as! NSManagedObject)
                        try! privateContext.save()
                    })

                }
				
				let songs = self.retrieveAllSongsFromCore(context: privateContext, ids: nil)
				
				self.loadPlaylistItems(playlist: privatePlaylist, context: privateContext, songs: songs, complete: {
                    print("Playlist addition and refresh")

					if privatePlaylist.downloaded && !song.downloaded {
						DownloadManager.shared.download(song: song)
					}
					
                    try! privateContext.save()

                    self.saveContext()
					
                    complete()
                })
            })
            .store(in: &cancellables)
    }

    public func createPlaylist(name: String, songs: [Song], complete: @escaping () -> Void) -> Void {
                
        var dto = CreatePlaylistDto()
        
        dto.userId = self.userId
        dto.name = name
        dto.ids = songs.map { $0.jellyfinId! }
        dto.mediaType = "Audio"
        
        PlaylistsAPI.createPlaylist(createPlaylistDto: dto, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { completion in
                print("Creating playlist receive completion: \(completion)")
            }, receiveValue: { response in
				
				self.loadPlaylists(complete: {
						// Specify we need to be on a background context
						let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
						
						let playlists = self.retrieveAllPlaylistsFromCore(context: backgroundContext)
						
						let songs = self.retrieveAllSongsFromCore(context: backgroundContext, ids: nil)
						
						backgroundContext.performAndWait {

							var completedPlaylistAdditions : [Bool] = []

							playlists.forEach({ playlist in

								
								self.loadPlaylistItems(playlist: playlist, context: backgroundContext, songs: songs, complete: {
									
									completedPlaylistAdditions.append(true)
									
									if completedPlaylistAdditions.count == playlists.count {
										do {
											try backgroundContext.save()
											
											// Retrieve current sync
											let sync = self.retrieveCurrentSync()
											sync?.timeFinished = Date.now
											sync?.wasSuccess = true

											self.saveContext()
											
											print("Loading complete!")
											
											DispatchQueue.main.async {
												self.loadingPhase = nil
												self.libraryIsPopulated = true
											}
											self.processDownloadQueue()
											
										} catch {
											
											// Retrieve current sync
											let sync = self.retrieveCurrentSync()
											sync?.timeFinished = Date.now
											sync?.wasSuccess = false
											
											self.saveContext()
											
											print("Loading complete!")
											
											DispatchQueue.main.async {
												self.loadingPhase = nil
												self.libraryIsPopulated = true
											}
											self.processDownloadQueue()
										}

									}
								})
							})
						}
					})
			})
            .store(in: &self.cancellables)
    }
    
    public func deletePlaylist(playlist: Playlist) -> Void {
        print("Deleting playlist \(playlist.name!)")
        
        LibraryAPI.deleteItem(itemId: playlist.jellyfinId!, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished :
                    
                    self.deletePlaylists(playlistsToDelete: [playlist])
                    
                    self.saveContext()
                case .failure:
                    print("Error deleting playlist: \(completion)")
                }

            }, receiveValue: { response in
                
            })
            .store(in: &cancellables)
    }
    
    public func deleteFromPlaylist(playlist: Playlist, indexSet: IndexSet) -> Void {
        
		// For some reason pulling the index out of the index set is always off by one
		let indexToRemove = playlist.songs?.count == indexSet.last! + 1 ? indexSet.last! : indexSet.last!
        
        if var playlistSongs = playlist.songs?.allObjects as? [PlaylistSong]{
            let remainingPlaylistSongIds = playlistSongs.filter { indexToRemove != $0.indexNumber }.map { $0.jellyfinId! }
            
                                
            let playlistSongIdsToRemove = (playlist.songs!.allObjects as! [PlaylistSong]).map { $0.jellyfinId! }.filter { !remainingPlaylistSongIds.contains($0)}
			
			var deletedSongs : [PlaylistSong] = []
			
			playlistSongIdsToRemove.forEach({ playlistSongId in
								
				let playlistSong : PlaylistSong = self.context.object(with: self.retrievePlaylistSongFromCore(playlistSongId: playlistSongId)!) as! PlaylistSong
				
				deletedSongs.append(playlistSong)
				self.deletePlaylistSongByJellyfinId(playlistSongId: playlistSongId, context: self.context)
			})
			
			print("Removing songs \((playlist.songs!.allObjects as! [PlaylistSong]).filter({ playlistSongIdsToRemove.contains($0.jellyfinId!)}).map({ $0.song!.name!}).joined(separator: ", "))")
                    
            PlaylistsAPI.removeFromPlaylist(playlistId: playlist.jellyfinId!, entryIds: playlistSongIdsToRemove, apiResponseQueue: JellyfinAPI.apiResponseQueue)
                .sink(receiveCompletion: { completion in
					
					switch completion {
					case .failure:
						deletedSongs.forEach({ playlistSong in
							playlist.addToSongs(playlistSong)
						})
						
					default:
						return
					}
                    print("Call to remove song from playlist complete: \(completion)")
                }, receiveValue: { response in
					
					// We've deleted the playlist item(s) pre-emptively, so no need to delete here
//					playlistSongIdsToRemove.forEach({ playlistSongId in
//						self.deletePlaylistSongByJellyfinId(playlistSongId: playlistSongId, context: self.context)
//					})
					
					for case let playlistSong as PlaylistSong in playlist.songs! {
						if playlistSong.indexNumber > indexToRemove {
							playlistSong.indexNumber -= 1
						}
					}
                })
                .store(in: &cancellables)
        }
    }
    
    public func favoriteItem(jellyfinId: String, originalValue: Bool?, complete: @escaping (Bool) -> Void) -> Void {
        UserLibraryAPI.markFavoriteItem(userId: self.userId, itemId: jellyfinId)
            .sink(receiveCompletion: { complete in
                print("Favorite item: \(complete)")
            }, receiveValue: { response in
                complete(response.isFavorite ?? originalValue ?? false)
            })
            .store(in: &self.cancellables)
    }
    
    public func unfavorite(jellyfinId: String, originalValue: Bool?, complete: @escaping (Bool) -> Void) -> Void {
        UserLibraryAPI.unmarkFavoriteItem(userId: self.userId, itemId: jellyfinId)
            .sink(receiveCompletion: { complete in
                print("Unfavorite item: \(complete)")
            }, receiveValue: { response in
                complete(response.isFavorite ?? originalValue ?? false)
            })
            .store(in: &self.cancellables)
    }
    
    public func moveInPlaylist(playlist: Playlist, indexSet: IndexSet, newIndex: Int) {
    
        let oldIndex = indexSet.first!
        let updatedIndex = newIndex == 0 || newIndex <= oldIndex ? newIndex : newIndex - 1
                
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        let privatePlaylist = privateContext.object(with: self.retrievePlaylistFromCore(playlistId: playlist.jellyfinId!)!) as! Playlist
        
        let playlistSong = playlist.songs?.sortedArray(using: [NSSortDescriptor(key: #keyPath(PlaylistSong.indexNumber), ascending: true)])[oldIndex] as? PlaylistSong
        
        for index in indexSet {
            print(index)
            print(updatedIndex)
        }
        
        print("Moving song \(playlistSong!.song!.name!) to index \(updatedIndex) from \(oldIndex)")
        
        if let playlistSongs : [PlaylistSong] = playlist.songs?.map({ $0 as! PlaylistSong }) {

            playlistSongs.forEach({ song in
                
                if song.jellyfinId! != playlistSong!.jellyfinId! {
                    
                    let songToShift = privateContext.object(with: self.retrievePlaylistSongFromCore(playlistSongId: song.jellyfinId!)!) as! PlaylistSong

                    // If moving song forward in playlist...
                    if updatedIndex < oldIndex {

                        // Bump the index number of each song that will come after the playlist song's new position,
                        // and fill up the gap to where the playlist song used to be
                        if songToShift.indexNumber >= updatedIndex && songToShift.indexNumber < oldIndex {
                            
                            songToShift.indexNumber += 1
                        }
                    }

                    // Else we're moving the song back...
                    else {
                        if songToShift.indexNumber <= updatedIndex && songToShift.indexNumber > oldIndex {
                            songToShift.indexNumber -= 1
                        }
                    }
                } else {
                    playlistSong?.indexNumber = Int16(updatedIndex)
                }
            })
        }
        
        PlaylistsAPI.moveItem(playlistId: playlist.jellyfinId!, itemId: playlistSong!.jellyfinId!, newIndex: updatedIndex)
            .sink(receiveCompletion: { completion in
				print(completion)
                switch completion {
                case .finished:
                    print("Playlist item moved")
					try! privateContext.save()
                    self.saveContext()
                case .failure:
                    print("Playlist item move failed")
					privateContext.rollback()
					self.saveContext()
                }
            }, receiveValue: { response in
//                if playlist.songs != nil {
//
//                    privatePlaylist.songs!.forEach({ playlistSong in
//                        privateContext.delete(playlistSong as! NSManagedObject)
//                        try! privateContext.save()
//                    })
//
//                }
//                self.loadPlaylistItems(playlist: privatePlaylist, context: privateContext, complete: { playlistSongs in
//                    print("Playlist addition and refresh")
//
//                    playlistSongs.forEach({ playlistSong in
//                        privatePlaylist.addToSongs(playlistSong)
//                    })
//
//                    try! privateContext.save()
//
//                    self.saveContext()
//                })
				print(response)
            })
            .store(in: &self.cancellables)
    }
    
//    public func retrieveArtistByJellyfinId(jellyfinId: String) -> Artist? {
//        return self.context.object(with: self.retrieveArtistFromCoreById(jellyfinId: jellyfinId)!) as? Artist
//    }
    
	public func retrieveArtistByName(name: String, context: NSManagedObjectContext) -> Artist? {
		return self.retrieveArtistFromCore(artistName: name, context: context)
    }

    public func loadAlbumArtwork(album: Album) -> Void {
                
		ImageAPI.getItemImage(itemId: album.jellyfinId!, imageType: .primary, apiResponseQueue: DispatchQueue.global(qos: .utility))
            .sink(receiveCompletion: { completion in
                print("Image receive completion: \(completion)")
            }, receiveValue: { url in
                      
                do {

                    album.artwork = try Data(contentsOf: url)
                    album.thumbnail = try Data(contentsOf: url)
                                        
                    self.saveContext()
                } catch {
                    print("Error setting artwork for album: \(album.name!)")
                }                
            })
            .store(in: &self.cancellables)

    }
    
    public func loadArtistImage(artist: Artist) -> Void {
                
        ImageAPI.getItemImage(itemId: artist.jellyfinId!, imageType: .primary, apiResponseQueue: imageQueue)
            .sink(receiveCompletion: { completion in
                print("Artist image receive completion: \(completion)")
            }, receiveValue: { url in
                               
                do {
                    artist.thumbnail = try Data(contentsOf: url)
                    
                     self.saveContext()
                } catch {
                    print("Error setting thumbnail for artist: \(artist.name!)")
                    
                    artist.thumbnail = nil
                }
            })
            .store(in: &self.cancellables)
    }
    
    public func loadPlaylistImage(playlist: Playlist) -> Void {
        ImageAPI.getItemImage(itemId: playlist.jellyfinId!, imageType: .primary, apiResponseQueue: imageQueue)
            .sink(receiveCompletion: { completion in
                print("Artist image receive completion: \(completion)")
            }, receiveValue: { url in
                                
                let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                
                privateContext.parent = self.privateContext
                
                let privatePlaylist = privateContext.object(with: playlist.objectID) as! Playlist

                privatePlaylist.thumbnail = try! Data(contentsOf: url)
                
                try! privateContext.save()
                 
                self.saveContext()
            })
            .store(in: &self.cancellables)
    }
    
    // TODO: Hash password to SHA-1
    public func login(serverUrl: String, userId: String, password: String, complete: @escaping () -> Void) -> Void {
        
        print("logging in")
        JellyfinAPI.basePath = serverUrl
        setAuthHeaders()
        
        var dto = AuthenticateUserByName()
        
        dto.username = userId
        dto.pw = password
        
        UserAPI.authenticateUserByName(authenticateUserByName: dto, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { complete in
                print("Login completion: \(complete)")
            }, receiveValue: { response in
                let user : User = User(context: self.privateContext)
                
                user.userId = response.user!.id!
                user.server = serverUrl
                user.authToken = response.accessToken
                user.serverId = response.serverId
                
                self.saveContext()
                
                self.setCustomHeaders()
                
                self.userIsLoggedIn = true
                
                complete()
            })
            .store(in: &cancellables)
    }
    
    public func logOut() -> Void {
        
        SessionAPI.reportSessionEnded()
            .sink(receiveCompletion: { complete in
                print("Logout request: \(complete)")
            }, receiveValue: {
                
                DispatchQueue.main.async {
                    Player.shared.isPlaying = false
                    Player.shared.songs.removeAll()
                }
                
                self.cancellables.forEach({ cancellable in
                    cancellable.cancel()
                })
                
                self.loadingPhase = nil
                
                self.deleteAllOfEntity(entityName: "User")
                self.deleteAllOfEntity(entityName: "PlaylistSong")
                self.deleteAllOfEntity(entityName: "Song")
                self.deleteAllOfEntity(entityName: "Album")
                self.deleteAllOfEntity(entityName: "Artist")
                self.deleteAllOfEntity(entityName: "Playlist")
                self.deleteAllOfEntity(entityName: "Genre")
                self._server = ""
                self._userId = ""
                self._accessToken = ""
                self._playlistId = ""
                self._libraryId = ""
                                
                self.userIsLoggedIn = false
                
                self.saveContext()
            })
            .store(in: &self.cancellables)
    }
    
    public func openSession() -> Void {
                        
        SessionAPI.getSessions(controllableByUserId: self.userId, deviceId: UIDevice.current.identifierForVendor!.uuidString, apiResponseQueue: self.processingQueue)
            .sink(receiveCompletion: { complete in
                print("Session started: \(complete)")
            }, receiveValue: { response in
                print("Started session for user successfully")
            })
            .store(in: &self.cancellables)
    }
    
    public func processDownloadQueue() -> Void {
        
        self.retrievePlaylistsToDownload().forEach({ playlist in
			
			DownloadManager.shared.download(playlist: playlist)
            
        })
		
		self.retrieveAlbumsToDownload().forEach({ album in
			DownloadManager.shared.download(album: album)
		})
        
		DownloadManager.shared.download(songs: self.retrieveSongsToDownload())
    }

    public func syncLibrary() -> Void {
                
        print("Starting Sync")
		
		let sync = Sync(context: self.context)
		sync.timeStarted = Date.now
		
		self.saveContext()
        
        // By setting the loading phase to artists, this will cascade a sync of all items
        self.loadingPhase = .artists
    }
    
    private func deleteAllEntities() -> Void {
        
        deleteAllOfEntity(entityName: "PlaylistSong")
        deleteAllOfEntity(entityName: "Song")
        deleteAllOfEntity(entityName: "Album")
        deleteAllOfEntity(entityName: "Playlist")
        deleteAllOfEntity(entityName: "Artist")
        
        saveContext()
    }
    
    private func deleteAllOfEntity(entityName: String) -> Void {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.privateContext.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print(error)
        }
    }
    
    private func deletePlaylists(playlistsToDelete: [Playlist]) -> Void {
        playlistsToDelete.forEach({ playlist in
            
            if let playlistSongs = playlist.songs?.allObjects as? [PlaylistSong] {

                playlistSongs.forEach({ playlistSong in
                    self.privateContext.delete(self.privateContext.object(with: self.retrievePlaylistSongFromCore(playlistSongId: playlistSong.jellyfinId!)!))
                })
            }
                        
            self.privateContext.delete(self.privateContext.object(with: self.retrievePlaylistFromCore(playlistId: playlist.jellyfinId!)!))
            self.saveContext()
        })
    }

    
    private func loadArtists(complete: @escaping () -> Void) -> Void {
		ArtistsAPI.getArtists(minCommunityRating: nil, startIndex: nil, limit: nil, searchTerm: nil, parentId: nil, fields: [ItemFields.primaryImageAspectRatio, ItemFields.sortName, ItemFields.basicSyncInfo], excludeItemTypes: nil, includeItemTypes: nil, filters: nil, isFavorite: nil, mediaTypes: nil, genres: nil, genreIds: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, studioIds: nil, userId: self.userId, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, enableImages: true, enableTotalRecordCount: nil, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { error in
                switch error {
                case .finished :
                    			
					print("Finished loading artists")
					self.saveContext()
                    DispatchQueue.main.sync {
                        self.loadingPhase = .albums
                    }
                case .failure:
                    print("Error retrieving artists: \(error)")
                    
					let sync = self.retrieveCurrentSync()
					sync?.timeFinished = Date.now
					sync?.wasSuccess = false
					
                    DispatchQueue.main.sync {
                        self.loadingPhase = nil
                    }
                }
                
            }, receiveValue: { response in

				// Check that we have a response and there are items, complete if else
				guard response.items != nil else {
					return
				}
				
				// Specify we need to be on a background context
				let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
								
				backgroundContext.performAndWait {

					let existingArtists = self.retrieveAllArtistsFromCore(context: backgroundContext)
					
					let existingArtistIds = Set(existingArtists.map({ $0.jellyfinId! }))
					
					let artistResponseIds = response.items!.map({ $0.id! })
					
					// Delete missing albums
					self.deleteMissingArtists(retrievedArtistIds: artistResponseIds, context: backgroundContext)
					
					// Determine new albums
					let newArtistIds = Set(artistResponseIds).subtracting(existingArtistIds)
					
					let newArtists = response.items!.filter({ newArtistIds.contains($0.id!) })
					
					let existingArtistsResponse = response.items!.filter({ !newArtistIds.contains($0.id! ) })
					
					
					
				// Create new artists concurrently
					for artistResult in newArtists {
							
						print("Creating artist \(newArtists.firstIndex(of: artistResult)!) of \(newArtistIds.count)")
							
//							let artistResult = newArtists[index]
							
							let newArtist = Artist(context: backgroundContext)
							
							newArtist.jellyfinId = artistResult.id
							newArtist.name = artistResult.name
							newArtist.sortName = artistResult.sortName
							newArtist.favorite = artistResult.userData?.isFavorite ?? false
							
							backgroundContext.insert(newArtist)
					}
					
					var artistResponseComparables = Set(existingArtistsResponse.map({ ArtistComparable(artistResult: $0)}))
					
					var existingArtistComparables = Set(existingArtists.map({ ArtistComparable(artist: $0 )}))
					
					let updatedArtists = Array(existingArtistComparables.subtracting(artistResponseComparables))
				
					// Check the rest of the artists for updates
					DispatchQueue.concurrentPerform(iterations: updatedArtists.count, execute: { index in
						
						print("Checking artist \(index) of \(updatedArtists.count) for updates")
						
						let existingArtist = existingArtists.first(where: { $0.jellyfinId! == updatedArtists[index].jellyfinId })!
						
						let artistResult = response.items!.first(where: { $0.id! == existingArtist.jellyfinId })!
						
						if self.artistContainsDifference(artist: existingArtist, artistResult: artistResult) {
							
							print("Updating artist \(index) of \(existingArtists.count)")

							existingArtist.name = artistResult.name!
							existingArtist.sortName = artistResult.sortName!
							existingArtist.favorite = artistResult.userData?.isFavorite ?? false
						}
					})
					

					do {
						try backgroundContext.save()
					} catch {
						print("Error saving artists' private context: \(error)")
					}
					
					// Finally, save off the changes
					self.saveContext()
                }
            })
            .store(in: &cancellables)

    }
    
    private func loadAlbums(complete: @escaping () -> Void) -> Void {
        ItemsAPI.getItemsByUserId(userId: self.userId, maxOfficialRating: nil, hasThemeSong: nil, hasThemeVideo: nil, hasSubtitles: nil, hasSpecialFeature: nil, hasTrailer: nil, adjacentTo: nil, parentIndexNumber: nil, hasParentalRating: nil, isHd: nil, is4K: nil, locationTypes: nil, excludeLocationTypes: nil, isMissing: nil, isUnaired: nil, minCommunityRating: nil, minCriticRating: nil, minPremiereDate: nil, minDateLastSaved: nil, minDateLastSavedForUser: nil, maxPremiereDate: nil, hasOverview: nil, hasImdbId: nil, hasTmdbId: nil, hasTvdbId: nil, excludeItemIds: nil, startIndex: nil, limit: nil, recursive: true, searchTerm: nil, sortOrder: nil, parentId: nil, fields: [ItemFields.sortName], excludeItemTypes: nil, includeItemTypes: ["MusicAlbum"], filters: nil, isFavorite: nil, mediaTypes: nil, imageTypes: nil, sortBy: nil, isPlayed: nil, genres: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, artists: nil, excludeArtistIds: nil, artistIds: nil, albumArtistIds: nil, contributingArtistIds: nil, albums: nil, albumIds: nil, ids: nil, videoTypes: nil, minOfficialRating: nil, isLocked: nil, isPlaceHolder: nil, hasOfficialRating: nil, collapseBoxSetItems: nil, minWidth: nil, minHeight: nil, maxWidth: nil, maxHeight: nil, is3D: nil, seriesStatus: nil, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, studioIds: nil, genreIds: nil, enableTotalRecordCount: nil, enableImages: nil, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished :
                    print("Finished album retrieval")
					self.saveContext()
                    DispatchQueue.main.sync {
                        self.loadingPhase = .songs
                    }
                case .failure:
                    print("Error retrieving artists: \(completion)")
                    
					let sync = self.retrieveCurrentSync()
					sync?.timeFinished = Date.now
					sync?.wasSuccess = false
					
                    DispatchQueue.main.sync {
                        self.loadingPhase = nil
                    }
                }
            }, receiveValue: { response in
				
				// Check that we have a response and there are items, complete if else
				guard response.items != nil else {
					return
				}
				
				// Specify we need to be on a background context
				let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
				
				let artists = self.retrieveAllArtistsFromCore(context: backgroundContext)
				
				backgroundContext.performAndWait {
					
					let existingAlbums = self.retrieveAllAlbumsFromCore(context: backgroundContext)
					
					let existingAlbumIds = Set(existingAlbums.map({ $0.jellyfinId! }))
					
					let albumResponseIds = response.items!.map({ $0.id! })
					
					// Delete missing albums
					self.deleteMissingAlbums(retrievedAlbumIds: albumResponseIds, context: backgroundContext)
					
					// Determine new albums
					let newAlbumIds = Set(albumResponseIds).subtracting(existingAlbumIds)
					
					let newAlbums = response.items!.filter({ newAlbumIds.contains($0.id!) })
					
					let existingAlbumsResponse = response.items!.filter({ !newAlbumIds.contains($0.id!) })
					
					var insertIndex = 0
					let total = newAlbums.count
					
					let batchInsert = NSBatchInsertRequest(entity: Album.entity()) { (managedObject: NSManagedObject) -> Bool in
						guard insertIndex < total else { return true }
						
						if let newAlbum = managedObject as? Album {
							
							let albumResult = newAlbums[insertIndex]
							
							newAlbum.jellyfinId = albumResult.id
							newAlbum.name = albumResult.name
							newAlbum.sortName = albumResult.sortName
							newAlbum.albumArtistName = albumResult.albumArtist
							newAlbum.favorite = albumResult.userData?.isFavorite ?? false
							newAlbum.productionYear = Int16(albumResult.productionYear ?? 0)
							
							self.refreshAlbumArtists(album: newAlbum, albumResult: albumResult, artists: artists)

						}
						
						insertIndex += 1
						return false
					}
					
					try! backgroundContext.execute(batchInsert)
					
					// Create new albums concurrently
//					for albumResult in newAlbums {
//						
//						print("Creating album \(newAlbums.firstIndex(of: albumResult)) of \(newAlbumIds.count)")
//													
//						let newAlbum = Album(context: backgroundContext)
//						
//						newAlbum.jellyfinId = albumResult.id
//						newAlbum.name = albumResult.name
//						newAlbum.sortName = albumResult.sortName
//						newAlbum.albumArtistName = albumResult.albumArtist
//						newAlbum.favorite = albumResult.userData?.isFavorite ?? false
//						newAlbum.productionYear = Int16(albumResult.productionYear ?? 0)
//						
//						self.refreshAlbumArtists(album: newAlbum, albumResult: albumResult, artists: artists)
//					}
					
					var albumResponseComparables = Set(existingAlbumsResponse.map({ AlbumComparable(albumResult: $0 )}))
									
					var existingAlbumComparables = Set(existingAlbums.map({ AlbumComparable(album: $0 )}))
					
					let updatedAlbums = Array(existingAlbumComparables.subtracting(albumResponseComparables))
										
					// Check the rest of the albums for updates
					DispatchQueue.concurrentPerform(iterations: updatedAlbums.count, execute: { index in
						
						print("Checking album \(index) of \(updatedAlbums.count) for updates")
						
						let existingAlbum = existingAlbums.first(where: { $0.jellyfinId! == updatedAlbums[index].jellyfinId })!
						
						let albumResult = response.items!.first(where: { $0.id! == existingAlbum.jellyfinId })
						
						if self.albumContainsDifference(album: existingAlbum, albumResult: albumResult) {
							
							print("Updating album \(index) of \(existingAlbums.count)")

							existingAlbum.name = albumResult!.name
							existingAlbum.sortName = albumResult!.sortName
							existingAlbum.albumArtistName = albumResult!.albumArtist
							existingAlbum.favorite = albumResult!.userData?.isFavorite ?? false
							existingAlbum.productionYear = Int16(albumResult!.productionYear ?? 0)
							
							self.refreshAlbumArtists(album: existingAlbum, albumResult: albumResult!, artists: artists)
						}
					})
								
					do {
						try backgroundContext.save()
					} catch {
						print("Unable to save albums' background context: \(error)")
					}
				}
            })
            .store(in: &self.cancellables)
        }
        
	private func loadSongs(complete: @escaping () -> Void, startIndex: Int?, retrievedSongIds: [String]?) -> Void {
				
		ItemsAPI.getItemsByUserId(userId: self.userId, maxOfficialRating: nil, hasThemeSong: nil, hasThemeVideo: nil, hasSubtitles: nil, hasSpecialFeature: nil, hasTrailer: nil, adjacentTo: nil, parentIndexNumber: nil, hasParentalRating: nil, isHd: nil, is4K: nil, locationTypes: nil, excludeLocationTypes: nil, isMissing: nil, isUnaired: nil, minCommunityRating: nil, minCriticRating: nil, minPremiereDate: nil, minDateLastSaved: nil, minDateLastSavedForUser: nil, maxPremiereDate: nil, hasOverview: nil, hasImdbId: nil, hasTmdbId: nil, hasTvdbId: nil, excludeItemIds: nil, startIndex: startIndex, limit: Globals.API_FETCH_PAGE_SIZE, recursive: true, searchTerm: nil, sortOrder: nil, parentId: nil, fields: [ItemFields.sortName, ItemFields.mediaSources], excludeItemTypes: nil, includeItemTypes: ["Audio"], filters: nil, isFavorite: nil, mediaTypes: nil, imageTypes: nil, sortBy: nil, isPlayed: nil, genres: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, artists: nil, excludeArtistIds: nil, artistIds: nil, albumArtistIds: nil, contributingArtistIds: nil, albums: nil, albumIds: nil, ids: nil, videoTypes: nil, minOfficialRating: nil, isLocked: nil, isPlaceHolder: nil, hasOfficialRating: nil, collapseBoxSetItems: nil, minWidth: nil, minHeight: nil, maxWidth: nil, maxHeight: nil, is3D: nil, seriesStatus: nil, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, studioIds: nil, genreIds: nil, enableTotalRecordCount: nil, enableImages: false, apiResponseQueue: processingQueue)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished :
                        print("Finished song retrieval at \(startIndex ?? 0)")
                        self.saveContext()
                    case .failure:
                        print("Error retrieving songs: \(completion)")
                        
						let sync = self.retrieveCurrentSync()
						sync?.timeFinished = Date.now
						sync?.wasSuccess = false
						
                        DispatchQueue.main.sync {
                            self.loadingPhase = nil
                        }
                    }
                    
				}, receiveValue: { response in
                    
					guard response.items != nil && !response.items!.isEmpty else {
						
						self.deleteMissingSongs(retrievedSongIds: retrievedSongIds ?? [])

						complete()
						
						return
					}
					// Specify we need to be on a background context
					let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
																				
					backgroundContext.performAndWait {
												
						let existingArtists = self.retrieveAllArtistsFromCore(context: backgroundContext)
						
						let existingAlbums = self.retrieveAllAlbumsFromCore(context: backgroundContext)
						
						let existingSongs = self.retrieveAllSongsFromCore(context: backgroundContext, ids: response.items!.map({ $0.id! }))
						
						// Determine new songs
						let newSongIds = Set(response.items!.map({ $0.id })).subtracting(existingSongs.map({ $0.jellyfinId }))
						
						let newResponseSongs = response.items!.filter({ newSongIds.contains($0.id!) })
						
						let existingSongIds = existingSongs.map({ $0.jellyfinId! })
												
						let existingResponseSongs = response.items!.filter({ !newSongIds.contains($0.id!) })
						
						var insertIndex = 0
						let total = newResponseSongs.count
						
						let result = try! backgroundContext.execute(NSBatchInsertRequest(entity: Song.entity()) { (managedObject: NSManagedObject) -> Bool in
							guard insertIndex < total else { return true }
														
							if let song = managedObject as? Song {
								
								let songResult = newResponseSongs[insertIndex]
								
								song.jellyfinId = songResult.id!
								song.name = songResult.name!
								song.sortName = songResult.sortName ?? songResult.name!
								song.container = songResult.mediaSources![0].container
								song.favorite = songResult.userData?.isFavorite ?? false

								// Run Time?
								song.runTimeTicks = songResult.runTimeTicks!

								// Check that index number exists so we can unwrap it's value safely
								if songResult.indexNumber != nil {
									song.indexNumber = Int16(songResult.indexNumber!)
								}

								// Check that the disk number exists so we can unwrap it's value safely
								if songResult.parentIndexNumber != nil {
									song.diskNumber = Int16(songResult.parentIndexNumber!)
								}

								if let artistIds = songResult.artistItems?.map({ $0.id! }) {

									artistIds.forEach({ artistId in
										if let artist = existingArtists.first(where: {$0.jellyfinId == artistId}) {
											song.addToArtists(artist)
										}
									})
								}
							}
							
							insertIndex += 1
							return false
						})
									
						let songsToAddAlbumsTo = self.retrieveSongsMissingAlbums(context: backgroundContext, songIds: Array(response.items!.map({ $0.id! })))
						
						print("Adding albums to \(songsToAddAlbumsTo.count) songs")
						
						for song in songsToAddAlbumsTo {
													
							let songResult = response.items!.first(where: { $0.id == song.jellyfinId })!
							
							if let albumId = songResult.albumId {
								if let album = existingAlbums.first(where: { $0.jellyfinId == albumId}) {
									song.album = album
								} else {
									// fatalError("Unable to associate song with album: \(song.name!)")
								}
							} else if let albumName = songResult.album {
								if let album = existingAlbums.first(where: { $0.name == albumName }) {
									song.album = album
								} else {
									// fatalError("Unable to associate song \(song.name!) with album: \(albumName)")
								}
								
							}else {
								 fatalError("Unable to associate song with album: \(song.name!)")
							}

						}
						
						try! backgroundContext.save()
						
						var songResponseComparables = Set(existingResponseSongs.map({ SongComparable(songResult: $0 )}))
						
						var existingSongComparables = Set(existingSongs.map({ SongComparable(song: $0 )}))
						
						let updatedSongs = Array(existingSongComparables.subtracting(songResponseComparables))
												
						print("Updating \(updatedSongs.count) songs")

						
						for updatedSong in updatedSongs {

							let existingSong = existingSongs.first(where: { $0.jellyfinId == updatedSong.jellyfinId })!
							
							guard response.items!.first(where: { $0.id! == existingSong.jellyfinId }) != nil else {
								return
							}
							
							let songResult = response.items!.first(where: { $0.id! == existingSong.jellyfinId })!
							
							print("Song \(existingSongs.firstIndex(of: existingSong)! + (startIndex ?? 0)) of \(updatedSongs.count + (startIndex ?? 0))")

							existingSong.jellyfinId = songResult.id!
							existingSong.name = songResult.name!
							existingSong.sortName = songResult.sortName ?? songResult.name!
							existingSong.container = songResult.mediaSources![0].container
							existingSong.favorite = songResult.userData?.isFavorite ?? false

							// Run Time?
							existingSong.runTimeTicks = songResult.runTimeTicks!

							// Check that index number exists so we can unwrap it's value safely
							if songResult.indexNumber != nil {
								existingSong.indexNumber = Int16(songResult.indexNumber!)
							}

							// Check that the disk number exists so we can unwrap it's value safely
							if songResult.parentIndexNumber != nil {
								existingSong.diskNumber = Int16(songResult.parentIndexNumber!)
							}
							if let albumId = songResult.albumId {

								existingSong.album = existingAlbums.first(where: { $0.jellyfinId == albumId})
							}

							let songResultArtistIds = Set(songResult.artistItems!.map({ $0.id! }))
							let existingSongArtistIds = Set((existingSong.artists?.allObjects as! [Artist]).map({ $0.jellyfinId! }))
							
							let artistIds = songResultArtistIds.subtracting(existingSongArtistIds)

							artistIds.forEach({ artistId in
								if let artist = existingArtists.first(where: {$0.jellyfinId == artistId}) {
									existingSong.addToArtists(artist)
								}
							})
						}
						
						
						do {
							try backgroundContext.save()
						} catch {
							print("Unable to save songs' background context: \(error)")
						}
					}
					
                        
//                        var songIds = Set(response.items!.map { $0.id})
//
//                        songIds.subtract(Set(self.retrieveAllSongsFromCore().map { $0.jellyfinId}))
//
//                        let newSongs = response.items!.filter { songIds.contains($0.id)}
																				
//						songQueue.async {
//							DispatchQueue.concurrentPerform(iterations: response.items!.count, execute: { index in
//
//								let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//
//								privateContext.parent = self.context
//
//								let songResult = response.items![index]
//
//								print("Song \(response.items!.firstIndex(of: songResult)! + (startIndex ?? 0)) of \(response.items!.count + (startIndex ?? 0))")
//
//								let song : Song?
//
//									// If we don't currently have the song we're iterating through...
//								if self.retrieveSongFromCore(songId: songResult.id!) == nil {
//
//									// We'll get it created
//									song = Song(context: privateContext)
//								} else {
//									song = privateContext.object(with: self.retrieveSongFromCore(songId: songResult.id!)!) as? Song
//								}
//
//
//								song!.jellyfinId = songResult.id!
//								song!.name = songResult.name!
//								song!.sortName = songResult.sortName ?? songResult.name!
//								song!.container = songResult.mediaSources![0].container
//								song!.favorite = songResult.userData?.isFavorite ?? false
//
//								// Run Time?
//								song!.runTimeTicks = songResult.runTimeTicks!
//
//								// Check that index number exists so we can unwrap it's value safely
//								if songResult.indexNumber != nil {
//									song!.indexNumber = Int16(songResult.indexNumber!)
//								}
//
//								// Check that the disk number exists so we can unwrap it's value safely
//								if songResult.parentIndexNumber != nil {
//									song!.diskNumber = Int16(songResult.parentIndexNumber!)
//								}
//								if let albumId = songResult.albumId {
//
//									song!.album = privateContext.object(with: self.retrieveAlbumFromCore(albumId: albumId)!) as? Album
//								}
//
//								if let artistIds = songResult.artistItems?.map({ $0.id! }) {
//
//									artistIds.forEach({ artistId in
//										if let artistObjectId = self.retrieveArtistFromCoreById(jellyfinId: artistId) {
//											song!.addToArtists(privateContext.object(with: artistObjectId) as! Artist)
//										}
//									})
//								}
//
//								if song!.hasChanges {
//									try! privateContext.save()
//								}
//							})
//						}
						let index = Globals.API_FETCH_PAGE_SIZE + (startIndex != nil ? startIndex! : 0)

					self.loadSongs(complete: {
							complete()
						}, startIndex: index, retrievedSongIds: (retrievedSongIds ?? []) + response.items!.map({ $0.id! }))
					})
                .store(in: &self.cancellables)
    }
    
    private func loadPlaylists(complete: @escaping () -> Void) -> Void {
        
        ItemsAPI.getItemsByUserId(userId: self.userId, maxOfficialRating: nil, hasThemeSong: nil, hasThemeVideo: nil, hasSubtitles: nil, hasSpecialFeature: nil, hasTrailer: nil, adjacentTo: nil, parentIndexNumber: nil, hasParentalRating: nil, isHd: nil, is4K: nil, locationTypes: nil, excludeLocationTypes: nil, isMissing: nil, isUnaired: nil, minCommunityRating: nil, minCriticRating: nil, minPremiereDate: nil, minDateLastSaved: nil, minDateLastSavedForUser: nil, maxPremiereDate: nil, hasOverview: nil, hasImdbId: nil, hasTmdbId: nil, hasTvdbId: nil, excludeItemIds: nil, startIndex: nil, limit: nil, recursive: true, searchTerm: nil, sortOrder: nil, parentId: self.playlistId, fields: [ItemFields.sortName], excludeItemTypes: nil, includeItemTypes: ["Playlist"], filters: nil, isFavorite: nil, mediaTypes: nil, imageTypes: nil, sortBy: ["SortName"], isPlayed: nil, genres: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, artists: nil, excludeArtistIds: nil, artistIds: nil, albumArtistIds: nil, contributingArtistIds: nil, albums: nil, albumIds: nil, ids: nil, videoTypes: nil, minOfficialRating: nil, isLocked: nil, isPlaceHolder: nil, hasOfficialRating: nil, collapseBoxSetItems: nil, minWidth: nil, minHeight: nil, maxWidth: nil, maxHeight: nil, is3D: nil, seriesStatus: nil, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, studioIds: nil, genreIds: nil, enableTotalRecordCount: nil, enableImages: nil, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { completion in
                print("Playlist retrieval: \(completion)")
            }, receiveValue: { response in
                
                if response.items != nil {
                    
                    // Remove old items that don't exist on the server anymore
                    let jellyfinPlaylistIds = response.items!.map { $0.id! }
                    
					let playlistsToDelete = self.retrieveAllPlaylistsFromCore(context: self.privateContext).filter { !jellyfinPlaylistIds.contains($0.jellyfinId!) }
                    
                    self.deletePlaylists(playlistsToDelete: playlistsToDelete)
                    
                    DispatchQueue.concurrentPerform(iterations: response.items!.count, execute: { index in
                        
                        let playlistResult = response.items![index]
                        
                        let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

                        privateContext.parent = self.privateContext
                        
                        print("Processing playlist: \(playlistResult.name!)")
                                                
                        if (self.retrievePlaylistFromCore(playlistId: playlistResult.id!) == nil) {
                                
                            let playlist = Playlist(context: privateContext)
                            
                            playlist.jellyfinId = playlistResult.id!
                            playlist.name = playlistResult.name!
                            playlist.sortName = playlistResult.sortName ?? playlist.name!
                            playlist.favorite = playlistResult.userData?.isFavorite ?? false
                            
                            try! privateContext.save()
                        } else {
                            
                            let playlist = privateContext.object(with: self.retrievePlaylistFromCore(playlistId: playlistResult.id!)!) as! Playlist
                            
                            // Update the name if it's changed
                            playlist.name = playlistResult.name!
                            playlist.sortName = playlistResult.sortName ?? playlist.name!
                            playlist.favorite = playlistResult.userData?.isFavorite ?? playlist.favorite
                        }
                                                
                        try! privateContext.save()
                        
                        if playlistResult == response.items!.last {
                            print("Playlist import complete")
                            self.saveContext()
                            complete()
                        } else {
                            print("Preparing for next new playlist")
                        }
                    })
                } else {
                    complete()
                }
            })
            .store(in: &self.cancellables)
    }
    
    /**
     Loads a playlist's tracks from the API and associates them with the playlist, adding new tracks, removing old tracks, and updating index numbers
     */
	private func loadPlaylistItems(playlist: Playlist, context: NSManagedObjectContext, songs: [Song], complete: @escaping () -> Void) -> Void {
        PlaylistsAPI.getPlaylistItems(playlistId: playlist.jellyfinId!, userId: self.userId, apiResponseQueue: self.processingQueue)
        .sink(receiveCompletion: { complete in
            print("Playlist song retrieval for playlist \(playlist.name): \(complete)")
        }, receiveValue: { playlistItems in
            if playlistItems.items != nil {
                
                // Build dictionary of playlist items and their index numbers
                // var playlistItemDictionary : [Int: String] = Dictionary(uniqueKeysWithValues: playlistItems.items!.map { ($0.indexNumber!, $0.id!) })
                
                
                                
                var index = 0
				                
                // Clear out all songs to repopulate with new data
                if playlist.songs != nil {
                    
                    self.deleteAllPlaylistSongsFromPlaylist(playlist: playlist, context: context)
                }
                
				// Go through each of the response items and turn them into playlist songs
                playlistItems.items!.forEach({ playlistItem in
                    
					// We can only add a song to the playlist if we have the song stored
					if let song = songs.first(where: { $0.jellyfinId == playlistItem.id }) {
						let playlistSong = PlaylistSong(context: context)
						
						playlistSong.jellyfinId = playlistItem.playlistItemId
						
						playlistSong.playlist = playlist
						playlistSong.indexNumber = Int16(index)
						
						playlistSong.song = song
						
						playlist.addToSongs(playlistSong)
					}
                    
                    index += 1
                })
                      
                complete()
            } else {
                complete()
            }
        })
        .store(in: &self.cancellables)

    }
    
    private func loadImages() -> Void {
        
    }
	
	private func artistContainsDifference(artist: Artist?, artistResult: BaseItemDto) -> Bool {
		
		// If we didn't even have this artist before, then you bet your bottom dollar there's a difference
		guard artist != nil else {
			return true
		}
		
		return artist!.name != artistResult.name || artist!.favorite != artistResult.userData?.isFavorite || artist!.sortName != artistResult.sortName
	}
	
	private func refreshAlbumArtists(album: Album, albumResult: BaseItemDto, artists: [Artist]) -> Void {
				
		// Check counts first, if one exists on the result but not on what we have, then you best believe they're different
		guard album.albumArtists != nil && albumResult.albumArtists != nil else {
			return
		}
		
		album.albumArtistName = albumResult.albumArtist
		
		let existingAlbumArtists : [Artist] = album.albumArtists!.allObjects as! [Artist]
		
		let existingAlbumArtistIds : [String] = existingAlbumArtists.map({ $0.jellyfinId! })
		
		let newAlbumArtistIds : [String] = albumResult.artistItems!.map({ $0.id! })
				
		// Check that everything we got is still there, remove as necessary
		for albumArtistId in existingAlbumArtistIds {
			
			if !newAlbumArtistIds.contains(where: { $0 == albumArtistId}) {
				
				// The list from the server has been retrieved and this artist has been voted off the island
				album.removeFromAlbumArtists(existingAlbumArtists.first(where: { $0.jellyfinId == albumArtistId })!)
			}
		}
		
		// Check if there are any of them we're missing, add as necessary
		for albumArtistId in newAlbumArtistIds {
			
			if !existingAlbumArtistIds.contains(where: { $0 == albumArtistId }) {
								
				let albumResultArtist = albumResult.artistItems!.first(where: { $0.id! == albumArtistId })!
				
				if let byId = artists.first(where: { $0.jellyfinId == albumArtistId }) {
					album.addToAlbumArtists(byId)
				}
		
				// Else we found a case where the artist IDs don't line up, so we'll do a fuzzy search on name to see if we can get alignment
				else if let byName = artists.first(where: { $0.name!.lowercased().contains(albumResultArtist.name!.lowercased())}) {
					album.addToAlbumArtists(byName)
				}
				
				else {
					fatalError("Unable to associate album with artist")
				}
			}
		}
	}
	
	private func albumContainsDifference(album: Album?, albumResult: BaseItemDto?) -> Bool {
		
		// If we didn't even have this album before or it doesn't exist in the response, then we'll return false
		guard album != nil && albumResult != nil else {
			return false
		}
		
		return album!.name != albumResult!.name! || album!.sortName != albumResult!.sortName ?? albumResult!.name! || album!.productionYear != Int16(albumResult!.productionYear ?? 0) ||
		album!.favorite != albumResult!.userData?.isFavorite ?? album?.favorite ?? false

	}
    
	private func deleteMissingAlbums(retrievedAlbumIds: [String], context: NSManagedObjectContext) -> Void {
        
        guard !retrievedAlbumIds.isEmpty else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        
        fetchRequest.predicate = NSPredicate(format: "NOT (jellyfinId IN %@)", retrievedAlbumIds)
                
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
			
            let albumsToDelete = try context.fetch(fetchRequest) as! [Album]
            
			self.deleteMissingSongs(albums: albumsToDelete, context: context)
                        
            try context.execute(deleteRequest)
			
			try context.save()
			
			self.saveContext()
        } catch {
            print("Error deleting old albums: \(error)")
        }
    }
    
    private func deleteMissingAlbums(artists: [Artist]) -> Void {
        
        guard !artists.isEmpty else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        
        let predicates = artists.map {
            NSPredicate(format: "artists CONTAINS %@", $0)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
			let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			privateContext.parent = self.context

            let albumsToDelete = try privateContext.fetch(fetchRequest) as! [Album]
            
			self.deleteMissingSongs(albums: albumsToDelete, context: privateContext)
                        
            try privateContext.execute(deleteRequest)
        } catch {
            print("Error deleting old albums: \(error)")
        }
    }
    
	private func deleteMissingArtists(retrievedArtistIds: [String], context: NSManagedObjectContext) -> Void {
        
        guard !retrievedArtistIds.isEmpty else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
        
        fetchRequest.predicate = NSPredicate(format: "NOT (jellyfinId IN %@)", retrievedArtistIds)
                
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            let artistsToDelete = try context.fetch(fetchRequest) as! [Artist]
            
//            self.deleteMissingAlbums(artists: artistsToDelete)
//            
//            self.deleteMissingSongs(artists: artistsToDelete)
                        
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting old artists: \(error)")
        }
    }
    
    private func deleteMissingSongs(artists: [Artist]) -> Void {
        
        guard !artists.isEmpty else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")

        let predicates = artists.map {
            NSPredicate(format: "artists CONTAINS %@", $0)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
			let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			privateContext.parent = self.context

            let songsToDelete = try privateContext.fetch(fetchRequest) as! [Song]
			
			songsToDelete.filter({ $0.downloaded }).forEach({ song in
				DownloadManager.shared.delete(song: song)
			})
            
			self.deleteMissingPlaylistSongs(songs: songsToDelete, context: privateContext)
            
            try privateContext.execute(deleteRequest)
        } catch {
            print("Error deleting old songs: \(error)")
        }
    }
    
	private func deleteMissingSongs(albums: [Album], context: NSManagedObjectContext) -> Void {
        
        guard !albums.isEmpty else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        
        fetchRequest.predicate = NSPredicate(format: "album in %@", albums)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            let songsToDelete = try context.fetch(fetchRequest) as! [Song]
			
			songsToDelete.filter({ $0.downloaded }).forEach({ song in
				DownloadManager.shared.delete(song: song)
			})
            
			self.deleteMissingPlaylistSongs(songs: songsToDelete, context: context)
            
            try self.privateContext.execute(deleteRequest)
        } catch {
            print("Error deleting old songs: \(error)")
        }
    }
    
    private func deleteMissingSongs(retrievedSongIds: [String]) -> Void {
        
        guard !retrievedSongIds.isEmpty else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        
        fetchRequest.predicate = NSPredicate(format: "NOT (jellyfinId IN %@)", retrievedSongIds)
                
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
			let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			privateContext.parent = self.context

            let songsToDelete = try privateContext.fetch(fetchRequest) as! [Song]
			
			songsToDelete.filter({ $0.downloaded }).forEach({ song in
				DownloadManager.shared.delete(song: song)
			})
            
			self.deleteMissingPlaylistSongs(songs: songsToDelete, context: privateContext)
                        
            try privateContext.execute(deleteRequest)
        } catch {
            print("Error deleting old songs: \(error)")
        }
    }
    
    private func deleteAllPlaylistSongsFromPlaylist(playlist: Playlist, context: NSManagedObjectContext) -> Void {
        (playlist.songs!.allObjects as! [PlaylistSong]).forEach({ song in
            self.deletePlaylistSongByJellyfinId(playlistSongId: song.jellyfinId!, context: context)
        })
    }
    
	private func deleteMissingPlaylistSongs(songs: [Song], context: NSManagedObjectContext) -> Void {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaylistSong")
        
        fetchRequest.predicate = NSPredicate(format: "song in %@", songs)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            let songsToDelete = try context.fetch(fetchRequest) as! [PlaylistSong]
            
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting old playlist songs: \(error)")
        }
    }
    
    private func deletePlaylistSongByJellyfinId(playlistSongId: String, context: NSManagedObjectContext) -> Void {
        do {
            let playlistSongObjectId = self.retrievePlaylistSongFromCore(playlistSongId: playlistSongId)
            
            let playlistSong = context.object(with: playlistSongObjectId!)
            
            context.delete(playlistSong)
        } catch {
            print("Error deleting playlist song by it's Jellyfin ID: \(error)")
        }
    }
    
	private func retrieveArtistFromCore(artistName: String, context: NSManagedObjectContext?) -> Artist? {
        let fetchRequest = Artist.fetchRequest()

        // TODO: Fix this since it isn't retrieving the artist
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", artistName)
                
        do {
			return context != nil ? try context!.fetch(fetchRequest).first : try self.privateContext.fetch(fetchRequest).first
        } catch {
            // TODO: handle the error
             print(error)
            
            return nil
        }
    }
    
	private func retrieveArtistFromCoreById(jellyfinId: String, context: NSManagedObjectContext) -> NSManagedObjectID? {
        let fetchRequest = Artist.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", jellyfinId)
        
        do {
            return try context.fetch(fetchRequest).first?.objectID
        } catch {
            print("Error retrieving artist from CoreData: \(error)")
            
            return nil
        }
    }
    
	public func retrieveAllArtistsFromCore(context: NSManagedObjectContext) -> [Artist] {
        let fetchRequest = Artist.fetchRequest()
        
        do {
			return try context.fetch(fetchRequest)
        } catch {
            print("Error retrieving all artists from CoreData: \(error)")
            
            return []
        }
    }
    
    private func retrieveArtistsFromCoreByJellyfinIds(jellyfinIds: [String]) -> [NSManagedObjectID] {
        let fetchRequest = Artist.fetchRequest()

        let predicates = jellyfinIds.map {
            NSPredicate(format: "jellyfinId == %@", $0)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self.context
                
        do {
            return try privateContext.fetch(fetchRequest).map { $0.objectID }
        } catch {
            // TODO: handle the error
             print(error)
            
            return []
        }

    }
    
    private func retrieveArtistsFromCoreByNames(names: [String]) -> [Artist] {
        let fetchRequest = Artist.fetchRequest()

        let predicates = names.map {
            NSPredicate(format: "name ==[c] %@", $0)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                
        do {
            return try self.context.fetch(fetchRequest)
        } catch {
            // TODO: handle the error
             print(error)
            
            return []
        }
    }
 
	private func retrieveAlbumFromCore(albumId: String, context: NSManagedObjectContext) -> NSManagedObjectID? {
        let fetchRequest = Album.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", albumId)
                
        do {
            return try context.fetch(fetchRequest).first?.objectID
        } catch {
            print("Error retrieving album from CoreData: \(error)")
            
            return nil
        }
    }
    
    public func retrieveAlbumsFromCore(albumArtistName: String) -> [NSManagedObjectID] {
        let fetchRequest = Album.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "albumArtistName == %@", albumArtistName)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        do {
            return try privateContext.fetch(fetchRequest).map({ $0.objectID })
        } catch let error as NSError {
            print("Error retrieving all albums from CoreData: \(error)")
            
            return []
        }
    }
	
	private func retrieveAlbumsToDownload() -> [Album] {
		let fetchRequest = Album.fetchRequest()
		
		fetchRequest.predicate = NSPredicate(format: "downloaded == true")
		
		do {
			return try self.context.fetch(fetchRequest)
		} catch let error as NSError {
			print("Error retrieving all albums marked for download. \(error)")
			
			return []
		}
	}
    
	public func retrieveAllAlbumsFromCore(context: NSManagedObjectContext) -> [Album] {
        let fetchRequest = Album.fetchRequest()
                        
        do {
			return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error retrieving all albums from CoreData: \(error)")
            
            return []
        }
    }
	
	/**
	 Retrieves songs associated with a given album sorted by disk number, then index number
	 */
	public func retrieveAlbumSongsFromCore(albumId: String) -> [NSManagedObjectID]? {
		let fetchRequest = Song.fetchRequest()
		
		fetchRequest.predicate = NSPredicate(format: "album.jellyfinId == %@", albumId)
		
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(Song.diskNumber), ascending: true),
			NSSortDescriptor(key: #keyPath(Song.indexNumber), ascending: true)
		]
		
		do {
			return try self.context.fetch(fetchRequest).map({ $0.objectID })
		} catch let error as NSError {
			print("Error retrieving songs from album \(albumId): \(error)")
			
			return nil
		}
	}
    
    private func retrieveSongFromCore(songId: String) -> NSManagedObjectID? {
        let fetchRequest = Song.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", songId)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        do {
            return try privateContext.fetch(fetchRequest).first?.objectID
        } catch let error as NSError {
            print("Error retrieving song from CoreData: \(error)")
            
            return nil
        }
    }
    
    public func retrieveSongsFromCore(albumId: String) -> [NSManagedObjectID] {
        let fetchRequest = Song.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "album.jellyfinId == %@", albumId)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        do {
            return try privateContext.fetch(fetchRequest).map({ $0.objectID })
        } catch let error as NSError {
            print("Error retrieving songs from CoreData: \(error)")
            
            return []
        }
    }
    
	private func retrieveAllSongsFromCore(context: NSManagedObjectContext?, ids: [String]?) -> [Song] {
        let fetchRequest = Song.fetchRequest()
		
		if ids != nil {
			fetchRequest.predicate = NSPredicate(format: "jellyfinId IN %@", ids!)
		}
                        
        do {
			return context != nil ? try context!.fetch(fetchRequest) : try self.privateContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error retrieving all songs from CoreData: \(error)")
            
            return []
        }
    }
	
	private func retrieveSongsMissingAlbums(context: NSManagedObjectContext, songIds: [String?]) -> [Song] {
		let fetchRequest = Song.fetchRequest()
		
		let predicates = [
			NSPredicate(format: "album == nil"),
			NSPredicate(format: "jellyfinId IN %@", songIds)
		]
		
		fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
		
		do {
			return try context.fetch(fetchRequest)
		} catch let error as NSError {
			print("Error retrieving songs with missing albums: \(error)")
			
			return []
		}
	}
    
//    private func retrieveAllSongsIdsFromCore() -> [String] {
//        let fetchRequest = Song.fetchRequest()
//        
//        fetchRequest.propertiesToFetch = [#keyPath(Song.jellyfinId)]
//        
//        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        
//        privateContext.parent = self.context
//        
//        do {
//            return try privateContext.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("Error retrieving all songs from CoreData: \(error)")
//            
//            return []
//        }
//    }
    
    private func retrieveSongsToDownload() -> [Song] {
        
        let fetchRequest = Song.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "downloading == true")
        
        do {
            return try self.privateContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error retrieving songs currently downloading from CoreData: \(error)")
            
            return []
        }
    }
    
    private func retrievePlaylistFromCore(playlistId: String) -> NSManagedObjectID? {
        let fetchRequest = Playlist.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", playlistId)
        
        do {
            return try self.context.fetch(fetchRequest).first?.objectID
        } catch let error as NSError {
            print("Error retrieving playlist from CoreData: \(error)")
            
            return nil
        }
    }
    
	public func retrieveAllPlaylistsFromCore(context: NSManagedObjectContext) -> [Playlist] {
        let fetchRequest = Playlist.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Playlist.sortName), ascending: true)]
                
        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error retrieving all playlists from CoreData: \(error)")
            
            return []
        }
    }
    
    private func retrievePlaylistsToDownload() -> [Playlist] {
        
        let fetchRequest = Playlist.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "downloaded == true")
        
        do {
            return try self.privateContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error retrieving playlists queued to download from CoreData: \(error)")
            
            return []
        }
    }
    
    private func retrievePlaylistSongFromCore(playlistSongId: String) -> NSManagedObjectID? {
        let fetchRequest = PlaylistSong.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", playlistSongId)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        do {
            return try privateContext.fetch(fetchRequest).first?.objectID
        } catch let error as NSError {
            print("Error retrieving playlist song from CoreData: \(error)")
            
            return nil
        }
    }
    
    private func retrievePlaylistSongFromCore(indexNumber: Int) -> PlaylistSong? {
        let fetchRequest = PlaylistSong.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "indexNumber == %@", indexNumber)
        
        do {
            return try self.privateContext.fetch(fetchRequest).first
        } catch let error as NSError {
            print("Error retrieving playlist song by index number from CoreData: \(error)")
            
            return nil
        }
    }
    
    public func retrievePlaylistSongsFromCore(playlistId: String) -> [NSManagedObjectID]? {
        let fetchRequest = PlaylistSong.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "playlist.jellyfinId == %@", playlistId)
        
        do {
            return try self.context.fetch(fetchRequest).map({ $0.objectID })
        } catch let error as NSError {
            print("Error retrieving songs from playlist \(playlistId): \(error)")
            
            return nil
        }
    }
	
	private func retrieveCurrentSync() -> Sync? {
		let fetchRequest = Sync.fetchRequest()
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Sync.timeStarted), ascending: false)]
		fetchRequest.predicate = NSPredicate(format: "timeFinished == nil")
		
		do {
			return try self.context.fetch(fetchRequest).first
		} catch let error as NSError {
			print("Error retrieving sync from coredata: \(error)")
			
			return nil
		}
	}
	
	private func retrieveLastSync() -> Sync? {
		let fetchRequest = Sync.fetchRequest()
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Sync.timeFinished), ascending: false)]
		fetchRequest.predicate = NSPredicate(format: "wasSuccess == true")
		
		do {
			return try self.context.fetch(fetchRequest).first
		} catch let error as NSError {
			print("Error retrieving sync from coredata: \(error)")
			
			return nil
		}
	}
    
    public func saveContext() {
        
		self.privateContext.performAndWait {
			do {
				try self.privateContext.save()
				self.context.performAndWait {
					do {
						try self.context.save()
					} catch {
						fatalError("Failure to save main context: \(error)")
					}
				}
			} catch {
				fatalError("Error saving private context: \(error)")
			}
		}
    }
            
    private func setAuthHeaders() -> Void {
        
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        var deviceName = UIDevice.current.name
        deviceName = deviceName.folding(options: .diacriticInsensitive, locale: .current)
        deviceName = String(deviceName.unicodeScalars.filter { CharacterSet.urlQueryAllowed.contains($0) })
        
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        
        let header = "MediaBrowser Client=\"\(appName ?? "Jellify")\", Device=\"\(deviceName)\", DeviceId=\"\(deviceId)\", Version=\"\(appVersion)\""
        
        JellyfinAPI.customHeaders["X-Emby-Authorization"] = header
    }
    
    private func setCustomHeaders() -> Void {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        var deviceName = UIDevice.current.name
        deviceName = deviceName.folding(options: .diacriticInsensitive, locale: .current)
        deviceName = String(deviceName.unicodeScalars.filter { CharacterSet.urlQueryAllowed.contains($0) })
        
        let platform: String
        #if os(tvOS)
        platform = "tvOS"
        #else
        platform = "iOS"
        #endif
        
        var header = "MediaBrowser "
        header.append("Client=\"\(appName ?? "Jellify")\", ")
        header.append("Device=\"\(deviceName)\", ")
        header.append("DeviceId=\"\(UIDevice.current.identifierForVendor!)\", ")
        header.append("Version=\"\(appVersion)\", ")
        header.append("Token=\"\(accessToken)\"")
        
        JellyfinAPI.customHeaders["X-Emby-Authorization"] = header
    }
}

enum LoadingPhase {
    case artists
    case albums
    case songs
    case playlists
    case artwork
}

struct ArtistComparable : Hashable {
	
	var jellyfinId : String
	var favorite : Bool
	var name : String
	var sortName : String
	
	init(artist: Artist) {
		jellyfinId = artist.jellyfinId!
		name = artist.name!
		sortName = artist.sortName!
		favorite = artist.favorite
	}
	
	init(artistResult: BaseItemDto) {
		jellyfinId = artistResult.id!
		name = artistResult.name!
		sortName = artistResult.sortName!
		favorite = artistResult.userData?.isFavorite ?? false
	}
	
	static func == (a: ArtistComparable, b: ArtistComparable) -> Bool {
		return a.favorite == b.favorite && a.sortName == b.sortName && a.name == b.name && a.jellyfinId == b.jellyfinId
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(jellyfinId)
		hasher.combine(favorite)
		hasher.combine(name)
		hasher.combine(sortName)
	}
}

struct AlbumComparable : Hashable {
	
	var jellyfinId : String
	var favorite : Bool
	var name : String
	var sortName : String
	var productionYear : Int16
	
	var albumArtists : [String?]
	
	init(album: Album) {
		
		jellyfinId = album.jellyfinId!
		favorite = album.favorite
		name = album.name!
		sortName = album.sortName!
		productionYear = album.productionYear
		
		albumArtists = [album.albumArtistName]
	}
	
	init(albumResult: BaseItemDto) {
		
		jellyfinId = albumResult.id!
		name = albumResult.name!
		sortName = albumResult.sortName ?? albumResult.name!
		favorite = albumResult.userData?.isFavorite ?? false
		productionYear = Int16(albumResult.productionYear ?? 0)

		albumArtists = [albumResult.albumArtist]
	}
	
	static func == (a: AlbumComparable, b: AlbumComparable) -> Bool {
		return a.jellyfinId == b.jellyfinId && a.favorite == b.favorite && a.albumArtists.elementsEqual(b.albumArtists) && a.productionYear == b.productionYear && a.sortName == b.sortName && a.name == b.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(jellyfinId)
		hasher.combine(favorite)
		hasher.combine(name)
		hasher.combine(sortName)
		hasher.combine(productionYear)
		hasher.combine(albumArtists)
	}
}

struct SongComparable : Hashable {
	
	var jellyfinId : String
	var favorite : Bool
	var name : String
	var sortName : String
	var indexNumber : Int16?
	var diskNumber : Int16?
	
	var artists : [String]
	
	init(song: Song) {
		
		jellyfinId = song.jellyfinId!
		favorite = song.favorite
		name = song.name!
		sortName = song.sortName!
		indexNumber = song.indexNumber
		diskNumber = song.diskNumber
		
		artists = (song.artists?.allObjects as [Artist]).map({ $0.jellyfinId! })
	}
	
	init(songResult: BaseItemDto) {
		
		jellyfinId = songResult.id!
		name = songResult.name!
		sortName = songResult.sortName ?? songResult.name!
		favorite = songResult.userData?.isFavorite ?? false
		indexNumber = songResult.indexNumber != nil ? Int16(songResult.indexNumber!) : nil
		diskNumber = songResult.parentIndexNumber != nil ? Int16(songResult.parentIndexNumber!) : nil

		artists = songResult.artistItems!.map({ $0.id! })
	}
	
	static func == (a: SongComparable, b: SongComparable) -> Bool {
		return a.jellyfinId == b.jellyfinId && a.favorite == b.favorite && a.name == b.name && a.indexNumber == b.indexNumber && a.diskNumber == b.diskNumber
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(jellyfinId)
		hasher.combine(favorite)
		hasher.combine(name)
		hasher.combine(indexNumber)
		hasher.combine(diskNumber)
	}

}
