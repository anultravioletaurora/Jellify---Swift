//
//  SongsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct SongsView: View {
    
    @State
    var limit = 1000
    
    var body: some View {
        NavigationView {
            
            SongsListView(limit: $limit)
            // This overlay prevents list content from appearing behind the tab view when dismissing the player
            .overlay(content: {
                BlurView()
                    .offset(y: UIScreen.main.bounds.height - 150)
            })
            .navigationTitle("Songs")
            .toolbar(content: {
                ToolbarItem(content: {
                    
                    SyncLibraryButton()

                })
            })
        }
		.navigationViewStyle(.stack) 
    }
}
