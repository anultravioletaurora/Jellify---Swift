//
//  AlbumExtensions.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 3/9/22.
//

import Foundation
import JellyfinAPI
import CoreData

extension Album {
	public static func buildFromResponseObject(albumResult: BaseItemDto, artists: [Artist], context: NSManagedObjectContext) {
		
		let newAlbum = Album(context: context)
		
		newAlbum.jellyfinId = albumResult.id
		newAlbum.name = albumResult.name
		newAlbum.sortName = albumResult.sortName
		newAlbum.albumArtistName = albumResult.albumArtist
		newAlbum.favorite = albumResult.userData?.isFavorite ?? false
		newAlbum.productionYear = Int16(albumResult.productionYear ?? 0)
		
		Album.refreshAlbumArtists(album: newAlbum, albumResult: albumResult, artists: artists)
	}
	
	private static func refreshAlbumArtists(album: Album, albumResult: BaseItemDto, artists: [Artist]) -> Void {
				
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
				
				print("Fetching artists for \(album.name!)")
				
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
}
