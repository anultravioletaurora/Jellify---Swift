//
//  NowPlayingIndicator.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/23/22.
//

import SwiftUI

struct NowPlayingIndicator: View {
    
    @ObservedObject
    var player = Player.shared
    
    var body: some View {
                
        ZStack {
            Circle().fill(Color.accentColor).frame(width: 30, height: 30)
            
            Image(systemName: "speaker.wave.3")
                .font(.body)
                .foregroundColor(.white)
        }
    }
}
