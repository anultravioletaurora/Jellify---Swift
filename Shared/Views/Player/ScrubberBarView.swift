//
//  ScrubberBarView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/14/22.
//

import SwiftUI
import AVFoundation
import MediaPlayer


struct ScrubberBarView: View {
    
    @ObservedObject
    var player = Player.shared
    
    @State
    var seekPos = 0.0
    
    var body: some View {
        
        VStack {
            Slider(value: $player.playProgressAhead, onEditingChanged: { (scrubStarted) in
                
                if scrubStarted {
                    self.player.seeking = true
                } else {
                    guard let item = self.player.player?.currentItem else {
                        return
                    }
                    
                    self.player.seek(progress: Double(player.playProgressAhead))
                }
            })
                .foregroundColor(.accentColor)
            
            HStack {
                Text(player.timeElasped)
                    .font(.subheadline)
                
                Spacer()
                
                Text(player.timeRemaining)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 25)
    }
}
