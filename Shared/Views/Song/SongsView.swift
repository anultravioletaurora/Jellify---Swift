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
            .navigationTitle("Songs")
            .toolbar(content: {
                ToolbarItem(content: {
                    
                    SyncLibraryButton()

                })
            })
        }
    }
}
