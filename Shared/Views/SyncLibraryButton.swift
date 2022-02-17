//
//  SyncLibraryButton.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/17/22.
//

import SwiftUI

struct SyncLibraryButton: View {
    
    @ObservedObject
    var networkingManager = NetworkingManager.shared
    
    var body: some View {
        if networkingManager.loadingPhase != nil {
            ProgressView()
        } else {
            Button(action: {
                print("syncing library")
                networkingManager.syncLibrary()
            }, label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            })
                .buttonStyle(PlainButtonStyle())
        }
    }
}
