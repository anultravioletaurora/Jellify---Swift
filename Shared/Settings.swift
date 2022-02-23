//
//  Settings.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/23/22.
//

import Foundation

class Settings : ObservableObject {
    
    @Published
    var syncOnStartup : Bool = UserDefaults.standard.bool(forKey: "syncOnStartup") {
        didSet {
            UserDefaults.standard.set(syncOnStartup, forKey: "syncOnStartup")
        }
    }
    
    @Published
    var displayAsGallery : Bool = UserDefaults.standard.bool(forKey: "displayAsGallery") {
        didSet {
            UserDefaults.standard.set(displayAsGallery, forKey: "displayAsGallery")
        }
    }
}
