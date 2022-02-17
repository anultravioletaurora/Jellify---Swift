//
//  AlbumsView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import SwiftUI

struct AlbumsView: View {
    
    @State
    var limit = 1000
    var body: some View {
        NavigationView {
            AlbumsListView(limit: $limit)
                .navigationTitle("Albums")
                .toolbar(content: {
                    ToolbarItem(content: {
                        
                        SyncLibraryButton()

                    })
                })
        }
    }
}
