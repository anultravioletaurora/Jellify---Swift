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
    
    @EnvironmentObject
    var player : Player
            
    var body: some View {
        
        VStack {
            Slider(value: $player.playProgress, onEditingChanged: { (scrubStarted) in
                
                print("Seeking")
                
                if scrubStarted {
                    self.player.seeking = true
                } else {
                    guard self.player.player?.currentItem != nil else {
                        return
                    }
                    
                    self.player.seek(progress: player.playProgress)
                }
            })

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
