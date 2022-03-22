//
//  FinTuneApp.swift
//  Shared
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import MediaPlayer
import StoreKit

@main
struct JellifyApp: App {
    
    /**
     Shared instance of the PersistenceController for storing to CoreData
     */
    let persistenceController = PersistenceController.shared
    
    let networkingManager = NetworkingManager.shared
                
//    /**
//     Watches the scene phase of the app, so we can perform a save when the user
//     navigates away
//     */
    @Environment(\.scenePhase)
    var scenePhase

    var body: some Scene {
        WindowGroup {
                ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(Settings())
                .environmentObject(Player.shared)
				.environmentObject(ViewControls())
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

class ViewControls : ObservableObject, Equatable {
	static func == (lhs: ViewControls, rhs: ViewControls) -> Bool {
		return lhs.showArtistView == rhs.showArtistView
	}
	
	@Published
	var showArtistView = false {
		didSet {
			print("Show artist view changed: \(showArtistView)")
		}
	}
	
	@Published
	var currentView : CurrentView? {
		didSet {
			print("Current view changed: \(currentView!)")
		}
	}
}

enum CurrentView {
	case Playlist
	case PlaylistDetail
	case Artist
	case ArtistDetail
	case NowPlayingArtistDetail
	case Album
	case AlbumDetail
	case Home
}
