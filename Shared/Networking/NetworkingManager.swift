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
    
    let processingQueue = DispatchQueue(label: "JellifyProcessingQueue", attributes: .concurrent)
        
    let context : NSManagedObjectContext = PersistenceController.shared.container.viewContext
        
    let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    let sessionId : UUID = UUID()
    
    @Published
    var loadingPhase : LoadingPhase? = nil
    
    @Published
    var libraryIsPopulated = false
    
    @Published
    var userIsLoggedIn = false
    
//
//    static var accessToken = UserDefaults.standard.string(forKey: "AccessToken") {
//        didSet {
//            UserDefaults.standard.set(accessToken, forKey: "AccessToken")
//        }
//    }
//
//    static var userId = UserDefaults.standard.string(forKey: "UserId") {
//        didSet {
//            UserDefaults.standard.set(userId, forKey: "UserId")
//        }
//    }
//
//    static var libraryId = UserDefaults.standard.string(forKey: "LibraryId") {
//        didSet {
//            UserDefaults.standard.set(libraryId, forKey: "LibraryId")
//        }
//    }
//
//    static var playlistsId = UserDefaults.standard.string(forKey: "PlaylistsId") {
//        didSet {
//            UserDefaults.standard.set(playlistsId, forKey: "PlaylistsId")
//        }
//    }
//
//    static var quality: Double = UserDefaults.standard.double(forKey: "Quality") {
//        didSet{
//            UserDefaults.standard.set(quality, forKey: "Quality")
//        }
//    }
    
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
        self.retrieveAllSongsFromCore().count > 0
    }
    
    public func addToPlaylist(playlist: Playlist, song: Song, complete: @escaping () -> Void) -> Void {
        
        print("Adding \(song.name!) to playlist \(playlist.name!)")

        PlaylistsAPI.addToPlaylist(playlistId: playlist.jellyfinId!, ids: [song.jellyfinId!], userId: self.userId, apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { completion in
                print("Call to add song to playlist complete: \(completion)")
            }, receiveValue: { response in
                print("Playlist addition response: \(response)")
                
                if playlist.songs != nil {
                    
                    playlist.songs!.forEach({ playlistSong in
                        self.context.delete(playlistSong as! NSManagedObject)
                    })
                    
                }
                self.loadPlaylistItems(playlist: playlist, complete: { playlistItems in
                    print("Playlist addition and refresh")
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
                
                let newPlaylist = Playlist(context: self.context)
                
                newPlaylist.jellyfinId = response.id
                newPlaylist.name = name
                                
                self.loadPlaylistItems(playlist: newPlaylist, complete: { playlistSongs in
                    
                    playlistSongs.forEach({ playlistSong in
                        newPlaylist.addToSongs(playlistSong)
                    })
                    
                    self.saveContext()
                    
                    complete()
                })
            })
            .store(in: &self.cancellables)
    }
    
    public func deleteFromPlaylist(playlist: Playlist, playlistSong: PlaylistSong) -> Void {

        print("Removing \(playlistSong.song!.name!) - \(playlistSong.jellyfinId!) from playlist \(playlist.name!) - \(playlist.jellyfinId!)")
                
        PlaylistsAPI.removeFromPlaylist(playlistId: playlist.jellyfinId!, entryIds: [playlistSong.jellyfinId!], apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { completion in
                print("Call to remove song from playlist complete: \(completion)")
            }, receiveValue: { response in

                print("Playlist removal response: \(response)")
                self.privateContext.delete(playlistSong)
                
                self.saveContext()
            })
            .store(in: &cancellables)
    }
    
    public func retrieveArtistByJellyfinId(jellyfinId: String) -> Artist? {
        return self.context.object(with: self.retrieveArtistFromCoreById(jellyfinId: jellyfinId)!) as? Artist
    }
    
    public func retrieveArtistByName(name: String) -> Artist? {
        return self.context.object(with: self.retrieveArtistFromCore(artistName: name)!) as? Artist
    }

    public func loadAlbumArtwork(album: Album) -> Void {
        ImageAPI.getItemImage(itemId: album.jellyfinId!, imageType: .primary)
            .sink(receiveCompletion: { completion in
                print("Image receive completion: \(completion)")
            }, receiveValue: { url in
                      
                do {
                    album.artwork = try Data(contentsOf: url)
                    album.thumbnail = try Data(contentsOf: url)
                    
                    // self.saveContext()
                } catch {
                    print("Error setting artwork for album: \(album.name!)")
                }                
            })
            .store(in: &self.cancellables)

    }
    
    public func loadArtistImage(artist: Artist) -> Void {
        ImageAPI.getItemImage(itemId: artist.jellyfinId!, imageType: .primary)
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
        ImageAPI.getItemImage(itemId: playlist.jellyfinId!, imageType: .primary)
            .sink(receiveCompletion: { completion in
                print("Artist image receive completion: \(completion)")
            }, receiveValue: { url in
                                
                playlist.thumbnail = try! Data(contentsOf: url)
                
                // self.saveContext()
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
        
        UserAPI.authenticateUserByName(authenticateUserByName: dto, apiResponseQueue: DispatchQueue.main)
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
                
                self.deleteAllOfEntity(entityName: "User")
                self.deleteAllOfEntity(entityName: "Album")
                self.deleteAllOfEntity(entityName: "Song")
                self.deleteAllOfEntity(entityName: "PlaylistSong")
                self.deleteAllOfEntity(entityName: "Artist")
                self.deleteAllOfEntity(entityName: "Playlist")
                self.deleteAllOfEntity(entityName: "Genre")
                self._server = ""
                self._userId = ""
                self._accessToken = ""
                self._playlistId = ""
                self._libraryId = ""
                
                self.saveContext()
                
                self.userIsLoggedIn = false
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

    public func syncLibrary() -> Void {
                
        print("Loading Artists")
        
        self.loadingPhase = .artists
        loadArtists(complete: {
            
            DispatchQueue.main.sync {
                print("Artists Loaded")
                print("Loading Albums")
                
                self.loadingPhase = .albums
            }
            
            self.loadAlbums(complete: {

                DispatchQueue.main.sync {
                    print("Albums Loaded")
                    print("Loading Songs")
                    
                    self.loadingPhase = .songs
                }
                
                self.loadSongs(complete: {

                    DispatchQueue.main.sync {
                        print("Songs Loaded")
                        print("Loading Playlists")
                        
                        self.loadingPhase = .playlists
                    }
                    
                    self.loadPlaylists(complete: {

                        DispatchQueue.main.sync {
                            print("Loading complete!")
                            self.loadingPhase = nil
                            self.libraryIsPopulated = true
                        }
                    })
                }, startIndex: nil)
            })
        })
    }
    
    private func deleteAllEntities() -> Void {
        
        deleteAllOfEntity(entityName: "PlaylistSong")
        deleteAllOfEntity(entityName: "Song")
        deleteAllOfEntity(entityName: "Album")
        deleteAllOfEntity(entityName: "Playlist")
        deleteAllOfEntity(entityName: "Artist")
        
        saveContext()
    }
    
    private func deleteAllOfEntity(entityName: String)-> Void{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print(error)
        }
    }

    
    private func loadArtists(complete: @escaping () -> Void) -> Void {
        ArtistsAPI.getAlbumArtists(minCommunityRating: nil, startIndex: nil, limit: nil, searchTerm: nil, parentId: nil, fields: [ItemFields.primaryImageAspectRatio, ItemFields.sortName, ItemFields.basicSyncInfo], excludeItemTypes: nil, includeItemTypes: nil, filters: nil, isFavorite: nil, mediaTypes: nil, genres: nil, genreIds: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, studioIds: nil, userId: self.userId, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, enableImages: true, enableTotalRecordCount: nil, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { error in
                print(error)
                
            }, receiveValue: { response in

                if response.items != nil {
                    
                    self.privateContext.perform {
                        
                        response.items!.forEach({ artistResult in
                            
                            var artist : Artist? = nil
                            
                            if (self.retrieveArtistFromCore(artistName: artistResult.name!) != nil) {
                                artist = self.privateContext.object(with: self.retrieveArtistFromCore(artistName: artistResult.name!)!) as! Artist?
                            }
                                // Check if artist already exists in store
                            if artist == nil {
                                let artist = Artist(context: self.privateContext)
                                
                                artist.jellyfinId = artistResult.id!
                                artist.name = artistResult.name ?? "Unknown Artist"
                                artist.dateCreated = artistResult.dateCreated?.formatted() ?? ""
                                artist.overview = artistResult.overview
                            }
                                                    
                            if response.items!.last == artistResult {

                                self.saveContext()
                                complete()
                            }
                        })
                    }
                }
            })
        .store(in: &cancellables)

    }
    
    private func loadAlbums(complete: @escaping () -> Void) -> Void {
        ItemsAPI.getItemsByUserId(userId: self.userId, maxOfficialRating: nil, hasThemeSong: nil, hasThemeVideo: nil, hasSubtitles: nil, hasSpecialFeature: nil, hasTrailer: nil, adjacentTo: nil, parentIndexNumber: nil, hasParentalRating: nil, isHd: nil, is4K: nil, locationTypes: nil, excludeLocationTypes: nil, isMissing: nil, isUnaired: nil, minCommunityRating: nil, minCriticRating: nil, minPremiereDate: nil, minDateLastSaved: nil, minDateLastSavedForUser: nil, maxPremiereDate: nil, hasOverview: nil, hasImdbId: nil, hasTmdbId: nil, hasTvdbId: nil, excludeItemIds: nil, startIndex: nil, limit: nil, recursive: true, searchTerm: nil, sortOrder: nil, parentId: nil, fields: nil, excludeItemTypes: nil, includeItemTypes: ["MusicAlbum"], filters: nil, isFavorite: nil, mediaTypes: nil, imageTypes: nil, sortBy: nil, isPlayed: nil, genres: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, artists: nil, excludeArtistIds: nil, artistIds: nil, albumArtistIds: nil, contributingArtistIds: nil, albums: nil, albumIds: nil, ids: nil, videoTypes: nil, minOfficialRating: nil, isLocked: nil, isPlaceHolder: nil, hasOfficialRating: nil, collapseBoxSetItems: nil, minWidth: nil, minHeight: nil, maxWidth: nil, maxHeight: nil, is3D: nil, seriesStatus: nil, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, studioIds: nil, genreIds: nil, enableTotalRecordCount: nil, enableImages: nil, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { response in
                if response.items != nil {
                    
                    var albumIds = Set(response.items!.map { $0.id})
                    
                    albumIds.subtract(Set(self.retrieveAllAlbumsFromCore().map { $0.jellyfinId}))
                                                
                    let newAlbums = response.items!.filter { albumIds.contains($0.id)}

                    
                    DispatchQueue.concurrentPerform(iterations: newAlbums.count) { index in

                        let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        
                        privateContext.parent = self.privateContext

                        let albumResult = newAlbums[index]
                        
                        print("Album \(index) of \(response.items!.count)")
                        
                        if (self.retrieveAlbumFromCore(albumId: albumResult.id!) == nil) {
                            
                            let album = Album(context: privateContext)
                            
                            album.jellyfinId = albumResult.id!
                            album.name = albumResult.name!
                            album.productionYear = Int16(albumResult.productionYear ?? 0)
                            
                            var artist : Artist? = nil
                            
                            if (albumResult.albumArtist != nil) {
                                
                                if (self.retrieveArtistFromCore(artistName: albumResult.albumArtist!) != nil) {
                                    artist = privateContext.object(with: self.retrieveArtistFromCore(artistName: albumResult.albumArtist!)!) as! Artist?
                                }
                            }
                            
                            if (artist != nil) {
                                album.albumArtistName = artist!.name!
                                
                                self.retrieveArtistsFromCoreByJellyfinIds(jellyfinIds: albumResult.albumArtists!.map { $0.id! }).forEach({ artistObjectId in
                                    album.addToAlbumArtists(privateContext.object(with: artistObjectId) as! Artist)
                                })
                            }
                        }
                        
                        try! privateContext.save()
                    }
                    
                    self.saveContext()
                    complete()
                } else {
                    complete()
                }
            })
            .store(in: &self.cancellables)
        }
        
    private func loadSongs(complete: @escaping () -> Void, startIndex: Int?) -> Void {
            ItemsAPI.getItemsByUserId(userId: self.userId, maxOfficialRating: nil, hasThemeSong: nil, hasThemeVideo: nil, hasSubtitles: nil, hasSpecialFeature: nil, hasTrailer: nil, adjacentTo: nil, parentIndexNumber: nil, hasParentalRating: nil, isHd: nil, is4K: nil, locationTypes: nil, excludeLocationTypes: nil, isMissing: nil, isUnaired: nil, minCommunityRating: nil, minCriticRating: nil, minPremiereDate: nil, minDateLastSaved: nil, minDateLastSavedForUser: nil, maxPremiereDate: nil, hasOverview: nil, hasImdbId: nil, hasTmdbId: nil, hasTvdbId: nil, excludeItemIds: nil, startIndex: startIndex, limit: 10000, recursive: true, searchTerm: nil, sortOrder: nil, parentId: nil, fields: nil, excludeItemTypes: nil, includeItemTypes: ["Audio"], filters: nil, isFavorite: nil, mediaTypes: nil, imageTypes: nil, sortBy: nil, isPlayed: nil, genres: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, artists: nil, excludeArtistIds: nil, artistIds: nil, albumArtistIds: nil, contributingArtistIds: nil, albums: nil, albumIds: nil, ids: nil, videoTypes: nil, minOfficialRating: nil, isLocked: nil, isPlaceHolder: nil, hasOfficialRating: nil, collapseBoxSetItems: nil, minWidth: nil, minHeight: nil, maxWidth: nil, maxHeight: nil, is3D: nil, seriesStatus: nil, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, studioIds: nil, genreIds: nil, enableTotalRecordCount: nil, enableImages: false, apiResponseQueue: processingQueue)
                .sink(receiveCompletion: { completion in
                    print("Finished song call at index \(startIndex)")
                    
                    self.saveContext()
                    
                }, receiveValue: { response in

                    
                    if response.items != nil {
                        
                        var songIds = Set(response.items!.map { $0.id})
                        
                        songIds.subtract(Set(self.retrieveAllSongsFromCore().map { $0.jellyfinId}))
                                                    
                        let newSongs = response.items!.filter { songIds.contains($0.id)}
                        
                        if !newSongs.isEmpty {
                            DispatchQueue.concurrentPerform(iterations: newSongs.count) { index in
                                                                
                                let songResult = newSongs[index]
                                
                                print("Song \(index) of \(newSongs.count)")
                                                                                                
                                if (self.retrieveSongFromCore(songId: songResult.id!) == nil) {
                                    
                                    self.processingQueue.sync {
                                        let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

                                        privateContext.parent = self.privateContext
                                        
                                        let song = Song(context: privateContext)
                                        
                                        song.jellyfinId = songResult.id!
                                        song.name = songResult.name!
                                        song.indexNumber = Int16(songResult.indexNumber!)
                                        
                                        var album : Album?
                                        
                                        if (songResult.albumId != nil) {
                                                                                    
                                            album = privateContext.object(with: self.retrieveAlbumFromCore(albumId: songResult.albumId!)!) as! Album?
                                        }
                                        
                                        if (album != nil) {
                                            song.album = album!
                                            self.retrieveArtistsFromCoreByJellyfinIds(jellyfinIds: songResult.artistItems!.map { $0.id! }).forEach({ artistObjectId in
                                                song.addToArtists(privateContext.object(with: artistObjectId) as! Artist)
                                            })
                                        }
                                        
                                        try! privateContext.save()
                                    }
                                }
                                
                                // Check if we've gone through everything the server has to offer
                                if (songResult == newSongs.last!) {
                                    
                                    // If this response is less than the configured fetch amount, it means the server doesn't
                                    // have more to give and we should complete
                                    if (response.items!.count < 10000) {
                                        self.saveContext()
                                        complete()
                                    }
                                    
                                    // Else it means there may be more songs on the server, let's go again!
                                    else {
                                        
                                        var index = 10000
                                        
                                        if startIndex != nil {
                                            index += startIndex!
                                        }
                                        
                                        self.saveContext()
                                        
                                        self.loadSongs(complete: {
                                            self.saveContext()
                                            complete()
                                        }, startIndex: index)
                                    }
                                }
                            }
                        } else {
                                
                            // If this response is less than the configured fetch amount, it means the server doesn't
                            // have more to give and we should complete
                            if (response.items!.count < 10000) {
                                self.saveContext()
                                complete()
                            }
                            
                            // Else it means there may be more songs on the server, let's go again!
                            else {
                                
                                var index = 10000
                                
                                if startIndex != nil {
                                    index += startIndex!
                                }
                                                                
                                self.loadSongs(complete: {
                                    complete()
                                }, startIndex: index)
                            }
                        }
                        
//                        complete()

                    } else {
                        complete()
                    }
                })
                .store(in: &self.cancellables)
    }
    
    private func loadPlaylists(complete: @escaping () -> Void) -> Void {
        
        ItemsAPI.getItemsByUserId(userId: self.userId, maxOfficialRating: nil, hasThemeSong: nil, hasThemeVideo: nil, hasSubtitles: nil, hasSpecialFeature: nil, hasTrailer: nil, adjacentTo: nil, parentIndexNumber: nil, hasParentalRating: nil, isHd: nil, is4K: nil, locationTypes: nil, excludeLocationTypes: nil, isMissing: nil, isUnaired: nil, minCommunityRating: nil, minCriticRating: nil, minPremiereDate: nil, minDateLastSaved: nil, minDateLastSavedForUser: nil, maxPremiereDate: nil, hasOverview: nil, hasImdbId: nil, hasTmdbId: nil, hasTvdbId: nil, excludeItemIds: nil, startIndex: nil, limit: nil, recursive: true, searchTerm: nil, sortOrder: nil, parentId: self.playlistId, fields: nil, excludeItemTypes: nil, includeItemTypes: ["Playlist"], filters: nil, isFavorite: nil, mediaTypes: nil, imageTypes: nil, sortBy: ["SortName"], isPlayed: nil, genres: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, artists: nil, excludeArtistIds: nil, artistIds: nil, albumArtistIds: nil, contributingArtistIds: nil, albums: nil, albumIds: nil, ids: nil, videoTypes: nil, minOfficialRating: nil, isLocked: nil, isPlaceHolder: nil, hasOfficialRating: nil, collapseBoxSetItems: nil, minWidth: nil, minHeight: nil, maxWidth: nil, maxHeight: nil, is3D: nil, seriesStatus: nil, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, studioIds: nil, genreIds: nil, enableTotalRecordCount: nil, enableImages: nil, apiResponseQueue: processingQueue)
            .sink(receiveCompletion: { completion in
                print("Playlist retrieval: \(completion)")
            }, receiveValue: { response in
                
                if response.items != nil {
                    
                    var loadingStatus : [Bool] = []
                                     
                    DispatchQueue.concurrentPerform(iterations: response.items!.count, execute: { index in
                        
                        let playlistResult = response.items![index]
                        
                        let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

                        privateContext.parent = self.privateContext
                        
                        print("Processing playlist: \(playlistResult.name!)")
                        
                        if (self.retrievePlaylistFromCore(playlistId: playlistResult.id!) == nil) {
                                
                            let playlist : Playlist = Playlist(context: privateContext)
                            
                            playlist.jellyfinId = playlistResult.id!
                            playlist.name = playlistResult.name!
                            
                            PlaylistsAPI.getPlaylistItems(playlistId: playlistResult.id!, userId: self.userId, apiResponseQueue: self.processingQueue)
                            .sink(receiveCompletion: { complete in
                                print("Playlist song retrieval for playlist \(playlist.name): \(complete)")
                            }, receiveValue: { playlistItems in
                                if playlistItems.items != nil {
                                    
                                    print("Adding \(playlistItems.items!.count) songs to playlist \(playlist.name!)")
                                    
                                    playlistItems.items!.forEach({ playlistItem in
                                        let playlistSong = PlaylistSong(context: privateContext)
                                        
                                        playlistSong.jellyfinId = playlistItem.playlistItemId
                                        
                                        playlistSong.playlist = playlist
                                        playlistSong.indexNumber = Int16(playlistItems.items!.firstIndex(of: playlistItem) ?? 0)
                                        
                                        let song: Song = privateContext.object(with: self.retrieveSongFromCore(songId: playlistItem.id!)!) as! Song
                                        playlistSong.song = song
                                        song.addToPlaylists(playlistSong)
                                        
                                        playlist.addToSongs(playlistSong)
                                    })
                                }
                                
                                try! privateContext.save()
                                
                                loadingStatus.append(true)
                                
                                if playlistResult == response.items!.last {
                                    print("Playlist import complete")
                                    self.saveContext()
                                    complete()
                                } else {
                                    print("Preparing for next new playlist")
                                }
                            })
                            .store(in: &self.cancellables)
                        } else {
                            let playlist = privateContext.object(with: self.retrievePlaylistFromCore(playlistId: playlistResult.id!)!) as! Playlist
                            
                            print("Fetching songs in \(playlist.name!)")
                                                                                    
                            PlaylistsAPI.getPlaylistItems(playlistId: playlistResult.id!, userId: self.userId, apiResponseQueue: self.processingQueue)
                            .sink(receiveCompletion: { complete in
                                print("Playlist song retrieval for playlist \(playlist.name): \(complete)")
                            }, receiveValue: { playlistItems in
                                
//                                print(playlistItems.items!.map { $0.id! })
                                
                                if playlistItems.items != nil {
                                                                    
                                    var playlistSongIds = Set(playlistItems.items!.map { $0.playlistItemId! })
                                    
                                    var newSongs : [BaseItemDto]
                                                                            
                                    print(playlist.songs!.count)
                                    
                                    if playlist.songs != nil {
                                        
                                        var currentPlaylistSongs : [PlaylistSong] = []
                                        
                                        playlist.songs!.forEach({ currentPlaylistSong in
                                            currentPlaylistSongs.append(currentPlaylistSong as! PlaylistSong)
                                        })
                                        
                                        if !currentPlaylistSongs.isEmpty {
                                            playlistSongIds.subtract(currentPlaylistSongs.filter { $0.jellyfinId != nil }.map { $0.jellyfinId! })
                                        }
                                                                    
                                        newSongs = playlistItems.items!.filter { playlistSongIds.contains($0.playlistItemId!)}
                                    } else {
                                        newSongs = playlistItems.items!
                                    }
                                    
                                    print("Adding \(newSongs.count) songs to playlist \(playlist.name!)")

                                    newSongs.forEach({ playlistItem in
                                        
                                        let playlistSong = PlaylistSong(context: privateContext)
                                        
                                        playlistSong.jellyfinId = playlistItem.playlistItemId
                                        playlistSong.indexNumber = Int16(playlistItems.items!.firstIndex(of: playlistItem) ?? 0)
                                        
                                        playlistSong.playlist = playlist
                                        playlistSong.song = privateContext.object(with: self.retrieveSongFromCore(songId: playlistItem.id!)!) as? Song
                                        
                                        try! privateContext.save()
                                    })
                                } else {
                                    print("Not doing shit to playlist \(playlist.name!)")
                                }
    
                                loadingStatus.append(true)
                                
                                if loadingStatus.count == response.items!.count {
                                    
                                    try! privateContext.save()
                                    print("Playlist import complete")
                                    self.saveContext()
                                    complete()
                                } else {
                                    print("Preparing for next playlist")
                                }
                            })
                            .store(in: &self.cancellables)
                        }
                    })
                } else {
                    complete()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func loadPlaylistItems(playlist: Playlist, complete: @escaping ([PlaylistSong]) -> Void) -> Void {
        PlaylistsAPI.getPlaylistItems(playlistId: playlist.jellyfinId!, userId: self.userId, apiResponseQueue: self.processingQueue)
        .sink(receiveCompletion: { complete in
            print("Playlist song retrieval for playlist \(playlist.name): \(complete)")
        }, receiveValue: { playlistItems in
            if playlistItems.items != nil {
                
                var playlistSongs : [PlaylistSong] = []
                
                var index = 0
                
                playlistItems.items!.forEach({ playlistItem in
                    
                    if (self.retrievePlaylistSongFromCore(playlistSongId: playlistItem.playlistItemId!) == nil) {
                        let playlistSong = PlaylistSong(context: self.context)
                        
                        playlistSong.jellyfinId = playlistItem.playlistItemId
                        
                        playlistSong.playlist = playlist
                        playlistSong.indexNumber = Int16(index)
                        
                        let song: Song = self.context.object(with: self.retrieveSongFromCore(songId: playlistItem.id!)!) as! Song
                        playlistSong.song = song
                        song.addToPlaylists(playlistSong)
                        
                        playlistSongs.append(playlistSong)
                    } else {
                        
                        let playlistSong = self.context.object(with: self.retrievePlaylistSongFromCore(playlistSongId: playlistItem.playlistItemId!)!) as! PlaylistSong
                        
                        playlistSong.indexNumber = Int16(index)
                        
                        playlistSongs.insert(playlistSong, at: index)
                    }
                    
                    index += 1
                })
                
                complete(playlistSongs)
            }
        })
        .store(in: &self.cancellables)

    }
    
    private func loadImages() -> Void {
        
    }
    
    private func retrieveArtistFromCore(artistName: String) -> NSManagedObjectID? {
        let fetchRequest = Artist.fetchRequest()

        // TODO: Fix this since it isn't retrieving the artist
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", artistName)
                
        do {
            return try self.context.fetch(fetchRequest).first?.objectID
        } catch {
            // TODO: handle the error
             print(error)
            
            return nil
        }
    }
    
    private func retrieveArtistFromCoreById(jellyfinId: String) -> NSManagedObjectID? {
        let fetchRequest = Artist.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", jellyfinId)
        
        do {
            return try self.context.fetch(fetchRequest).first?.objectID
        } catch {
            print("Error retrieving artist from CoreData: \(error)")
            
            return nil
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
 
    private func retrieveAlbumFromCore(albumId: String) -> NSManagedObjectID? {
        let fetchRequest = Album.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", albumId)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self.context
        
        do {
            return try privateContext.fetch(fetchRequest).first?.objectID
        } catch {
            print("Error retrieving album from CoreData: \(error)")
            
            return nil
        }
    }
    
    private func retrieveAllAlbumsFromCore() -> [Album] {
        let fetchRequest = Album.fetchRequest()
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        do {
            return try privateContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error retrieving all albums from CoreData: \(error)")
            
            return []
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
    
    private func retrieveAllSongsFromCore() -> [Song] {
        let fetchRequest = Song.fetchRequest()
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.context
        
        do {
            return try privateContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error retrieving all songs from CoreData: \(error)")
            
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
    
    private func retrievePlaylistSongFromCore(playlistSongId: String) -> NSManagedObjectID? {
        let fetchRequest = PlaylistSong.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", playlistSongId)
        
        do {
            return try self.context.fetch(fetchRequest).first?.objectID
        } catch let error as NSError {
            print("Error retrieving playlist song from CoreData: \(error)")
            
            return nil
        }
    }
    
    private func retrievePlaylistSongsFromCore(playlistId: String) -> [NSManagedObjectID]? {
        let fetchRequest = PlaylistSong.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", playlistId)
        
        do {
            return try self.context.fetch(fetchRequest).map({ $0.objectID })
        } catch let error as NSError {
            print("Error retrieving songs from playlist \(playlistId): \(error)")
            
            return nil
        }
    }
    
    private func saveContext() {
        
        do {
            try self.privateContext.save()
            self.context.perform {
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
            
    private func setAuthHeaders() -> Void {
        
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        var deviceName = UIDevice.current.name
        deviceName = deviceName.folding(options: .diacriticInsensitive, locale: .current)
        deviceName = String(deviceName.unicodeScalars.filter { CharacterSet.urlQueryAllowed.contains($0) })
        
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        
        let header = "MediaBrowser Client=\"\(appName ?? "JellyTuner")\", Device=\"\(deviceName)\", DeviceId=\"\(deviceId)\", Version=\"\(appVersion)\""
        
        JellyfinAPI.customHeaders["X-Emby-Authorization"] = header
    }
    
    private func setCustomHeaders() -> Void {
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
        header.append("Client=\"JellyTuner\", ")
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
