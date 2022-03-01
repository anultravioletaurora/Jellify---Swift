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
            
    @State
    var progress : Double = 0.0
    
    @State
    var timeElapsed : String = "0:00"
    
    @State
    var timeRemaining : String = "-0:00"
    
    var body: some View {
        
        VStack {
            Slider(value: $progress, onEditingChanged: { (scrubStarted) in
                
                print("Seeking")
                
                if scrubStarted {
                    self.player.seeking = true
                } else {
                    guard self.player.player?.currentItem != nil else {
                        return
                    }
                    
                    self.player.seek(progress: progress)
                }
            })

            HStack {
                Text(timeElapsed)
                    .font(.subheadline)
                
                Spacer()
                
                Text(timeRemaining)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 25)
        .onAppear(perform: {
            _ = Timer.scheduledTimer(withTimeInterval: Globals.playProgressRefresh,
                                             repeats: true,
                                             block: { timer in

                // Only perform progress updates if we aren't seeking
                if !player.seeking {
                    
                    // Use the AVQueuePlayer from the Player, as using published properties on the
                    // player itself causing graphics hitching when dismissing the nowplayingview
                    if let queuePlayer = player.player {
                    
                        if let currentItem = queuePlayer.currentItem {
                            
                            let duration = currentItem.duration.seconds
                            
                            // If the duration isn't a number, we need to pump the brakes otherwise we'll crash
                            guard !duration.isNaN else {
                                return
                            }

                            self.progress = queuePlayer.currentTime().seconds / duration
                                                
                            let playItemPosition = Int(queuePlayer.currentTime().seconds)
                            let playTimeSeconds = Int(playItemPosition % 3600) % 60
                            let playTimeMinutes = Int(playItemPosition % 3600) / 60
                            let timeElapsedString = "\(playTimeMinutes):\(String(format: "%02d", playTimeSeconds))"
                            self.timeElapsed = timeElapsedString
                            
                            let remainingTimeSecs = Int(duration) - playItemPosition
                            let remainingTimeSeconds = Int(remainingTimeSecs % 3600) % 60
                            let remainingTimeMinutes = Int(remainingTimeSecs % 3600) / 60
                            let remainingTimeString = "-\(remainingTimeMinutes):\(String(format: "%02d", remainingTimeSeconds))"
                            self.timeRemaining = remainingTimeString
                            
                            // Refresh the player's state, which will in turn update the NowPlayingMenu at the system
                            // level
                            player.refreshPlayingInfo()
                        }
                    }
                }
            })

        })
    }
}
