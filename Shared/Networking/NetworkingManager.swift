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

class NetworkingManager : ObservableObject {
    
    static let shared = NetworkingManager()
    
    var cancellables = Set<AnyCancellable>()
    
    let processingQueue = DispatchQueue(label: "JellyTunerrocessingQueue", qos: .userInteractive, attributes: .concurrent)
    
    let songsQueue = DispatchQueue(label: "LoadSongsProcessingQueue", qos: .userInteractive, attributes: .concurrent)
    
    let context : NSManagedObjectContext = PersistenceController.shared.container.viewContext
        
    let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    let playlistsContainer = NSPersistentContainer(name: "Playlists")
    
    var loadingPhase : LoadingPhase? = nil
    
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
    
    public func saveContext() {
        do {
            try self.privateContext.save()
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    fatalError("Failure to save main context: \(error)")
                }
            }
        } catch {
            fatalError("Error saving private context: \(error)")
        }
    }
    
    public func syncing() -> Bool {
        return loadingPhase != nil
    }
    
    public func syncLibrary() -> Void {
        
        print("Loading Artists")
        
        self.loadingPhase = .artists
        loadArtists(complete: {
            
            print("Artists Loaded")
            print("Loading Albums")
            
            self.loadingPhase = .albums
            self.loadAlbums(complete: {

                print("Albums Loaded")
                print("Loading Songs")
                
                self.loadingPhase = .songs
                self.loadSongs(complete: {

                    print("Songs Loaded")
                    print("Loading Playlists")
                    
                    self.loadingPhase = .playlists
                    self.loadPlaylists(complete: {
                        
                        print("Loading Images in the background")
                        self.loadImages()
                        self.loadingPhase = nil
                    })
                })
            })
        })
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
                    
                        DispatchQueue.concurrentPerform(iterations: response.items!.count) { index in

                            let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                            
                            privateContext.parent = self.privateContext

                            let albumResult = response.items![index]
                            
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
                                    album.albumArtist = artist!.jellyfinId!
                                    album.addToAlbumArtists(artist!)
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
        
        private func loadSongs(complete: @escaping () -> Void) -> Void {
            ItemsAPI.getItemsByUserId(userId: self.userId, maxOfficialRating: nil, hasThemeSong: nil, hasThemeVideo: nil, hasSubtitles: nil, hasSpecialFeature: nil, hasTrailer: nil, adjacentTo: nil, parentIndexNumber: nil, hasParentalRating: nil, isHd: nil, is4K: nil, locationTypes: nil, excludeLocationTypes: nil, isMissing: nil, isUnaired: nil, minCommunityRating: nil, minCriticRating: nil, minPremiereDate: nil, minDateLastSaved: nil, minDateLastSavedForUser: nil, maxPremiereDate: nil, hasOverview: nil, hasImdbId: nil, hasTmdbId: nil, hasTvdbId: nil, excludeItemIds: nil, startIndex: nil, limit: nil, recursive: true, searchTerm: nil, sortOrder: nil, parentId: nil, fields: nil, excludeItemTypes: nil, includeItemTypes: ["Audio"], filters: nil, isFavorite: nil, mediaTypes: nil, imageTypes: nil, sortBy: nil, isPlayed: nil, genres: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, artists: nil, excludeArtistIds: nil, artistIds: nil, albumArtistIds: nil, contributingArtistIds: nil, albums: nil, albumIds: nil, ids: nil, videoTypes: nil, minOfficialRating: nil, isLocked: nil, isPlaceHolder: nil, hasOfficialRating: nil, collapseBoxSetItems: nil, minWidth: nil, minHeight: nil, maxWidth: nil, maxHeight: nil, is3D: nil, seriesStatus: nil, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, studioIds: nil, genreIds: nil, enableTotalRecordCount: nil, enableImages: false, apiResponseQueue: processingQueue)
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { response in

                    
                    if response.items != nil {
                        
                        var songIds = Set(response.items!.map { $0.id})
                        
                        songIds.subtract(Set(self.retrieveAllSongsFromCore().map { $0.jellyfinId}))
                                                    
                        let newSongs = response.items!.filter { songIds.contains($0.id)}
                        
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
                                        song.artists = album!.albumArtists
                                    }
                                    
                                    try! privateContext.save()
                                }
                            }
                            
                            if (songResult == newSongs.last!) {
                                self.saveContext()
                            }
                        }
                        
                        complete()

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
                    let dispatchGroup = DispatchGroup()
                    
                    dispatchGroup.enter()
                    
                    var loadingStatus : [Bool] = []
                                     
                    DispatchQueue.concurrentPerform(iterations: response.items!.count, execute: { index in
                        
                        let playlistResult = response.items![index]
                                            
                        print("Processing playlist: \(playlistResult.name!)")
                        
                        if (self.retrievePlaylistFromCore(playlistId: playlistResult.id!) == nil) {
                                
                            let playlist : Playlist = Playlist(context: self.privateContext)
                            
                            playlist.jellyfinId = playlistResult.id!
                            playlist.name = playlistResult.name!
                            
                            PlaylistsAPI.getPlaylistItems(playlistId: playlistResult.id!, userId: self.userId, apiResponseQueue: self.processingQueue)
                            .sink(receiveCompletion: { complete in
                                print("Playlist song retrieval for playlist \(playlist.name): \(complete)")
                            }, receiveValue: { playlistItems in
                                if playlistItems.items != nil {
                                    playlistItems.items!.forEach({ playlistItem in
                                        let playlistSong = PlaylistSong(context: self.privateContext)
                                        
                                        playlistSong.jellyfinId = playlistItem.playlistItemId
                                        
                                        playlistSong.playlist = playlist
                                        
                                        let song: Song = self.privateContext.object(with: self.retrieveSongFromCore(songId: playlistItem.id!)!) as! Song
                                        playlistSong.song = song
                                        song.addToPlaylists(playlistSong)
                                    })
                                }
                                
                                loadingStatus.append(true)
                                
                                if loadingStatus.count == response.items!.count {
                                    self.saveContext()
                                    complete()
                                }
                            })
                            .store(in: &self.cancellables)
                        } else {
                            let privateContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

                            privateContext.parent = self.privateContext

                            let playlist = privateContext.object(with: self.retrievePlaylistFromCore(playlistId: playlistResult.id!)!) as! Playlist
                            
                            print("Fetching songs in \(playlist.name!)")
                                                        
                            PlaylistsAPI.getPlaylistItems(playlistId: playlistResult.id!, userId: self.userId, apiResponseQueue: self.processingQueue)
                            .sink(receiveCompletion: { complete in
                                print("Playlist song retrieval for playlist \(playlist.name): \(complete)")
                            }, receiveValue: { playlistItems in
                                
                                print(playlistItems.items!.map { $0.id! })
                                
                                if playlistItems.items != nil {
                                                                    
                                    var playlistSongIds = Set(playlistItems.items!.map { $0.id! })
                                    
                                    var newSongs : [BaseItemDto]
                                    
                                    
                                    do {
                                        
                                        print(playlist.songs!.count)
                                        if playlist.songs != nil {
                                            
                                            var currentPlaylistSongs : [PlaylistSong] = []
                                            
                                            playlist.songs!.forEach({ currentPlaylistSong in
                                                currentPlaylistSongs.append(currentPlaylistSong as! PlaylistSong)
                                            })
                                            
                                            playlistSongIds.subtract(currentPlaylistSongs.map({ ($0 as! PlaylistSong).song!.jellyfinId! }))
                                                                        
                                            newSongs = playlistItems.items!.filter { playlistSongIds.contains($0.id!)}
                                        } else {
                                        newSongs = playlistItems.items!
                                        }
                                    } catch {
                                        print("\(error)")
                                    }
                                    
                                    print("Adding \(newSongs.count) songs to playlist \(playlist.name!)")

                                    newSongs.forEach({ playlistItem in
                                        
                                        let playlistSong = PlaylistSong(context: privateContext)
                                        
                                        playlistSong.jellyfinId = playlistItem.playlistItemId
                                        
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
        
        complete()
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
    
    private func retrieveAlbumFromCore(albumId: String) -> NSManagedObjectID? {
        let fetchRequest = Album.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", albumId)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self.context
        
        do {
            return try self.context.fetch(fetchRequest).first?.objectID
        } catch {
            print("Error retrieving album from CoreData: \(error)")
            
            return nil
        }
    }
    
    private func retrieveSongFromCore(songId: String) -> NSManagedObjectID? {
        let fetchRequest = Song.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "jellyfinId == %@", songId)
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.privateContext
        
        do {
            return try self.context.fetch(fetchRequest).first?.objectID
        } catch let error as NSError {
            print("Error retrieving song from CoreData: \(error)")
            
            return nil
        }
    }
    
    private func retrieveAllSongsFromCore() -> [Song] {
        let fetchRequest = Song.fetchRequest()
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateContext.parent = self.privateContext
        
        do {
            return try self.context.fetch(fetchRequest)
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
}

enum LoadingPhase {
    case artists
    case albums
    case songs
    case playlists
    case artwork
}
