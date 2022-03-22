//
//  ImageManager.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 3/7/22.
//

import Foundation
import JellyfinAPI

public class ImageManager {
	
	// Singleton
	static let shared = ImageManager()
	
	public func download(itemId: String, complete: @escaping (Data?) -> Data?) -> Void? {
		ImageAPI.getItemImage(itemId: itemId, imageType: .primary)
			.sink(receiveCompletion: { completion in
				print("Image received completion: \(completion)")
			}, receiveValue: { url in
				do {
					let fileManager = FileManager.default
									
					let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

					let imageUrl = documentDirectory.appendingPathComponent("\(itemId).png")
					
					let image = try! Data(contentsOf: url)
									
					try! image.write(to: imageUrl)

					if imageUrl.isFileURL {
						print("Image downloaded successfully")
						complete(image)
					} else {
						throw NSError()
					}
				} catch {
					print("Error opening documents directory for storing image. \(error)")
					complete(nil)
				}
			})
			.store(in: &NetworkingManager.shared.cancellables)
	}
	
	public func imageFor(itemId: String) -> Data? {
		do {
			// Read song from file
			let fileManager = FileManager.default
			let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

			let imageUrl = documentDirectory.appendingPathComponent("\(itemId).png")
			
			return try Data(contentsOf: imageUrl)
		} catch {
			print("There was an error loading the downloaded image \(itemId), attemping to download. Error is: \(error)")
						
			self.download(itemId: itemId, complete: { data in

				return data
			})
			
			return nil
		}
	}
}
