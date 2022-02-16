//
//  VolumeObserver.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/16/22.
//

import Foundation
import MediaPlayer

class VolumeObserver: ObservableObject {

    static let shared = VolumeObserver()
    
    let volumeView = MPVolumeView(frame: .zero)
    
    @Published var volume: Float = AVAudioSession.sharedInstance().outputVolume

    // Audio session object
    private let session = AVAudioSession.sharedInstance()

    // Observer
    private var progressObserver: NSKeyValueObservation!

    func subscribe() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("cannot activate session")
        }

        progressObserver = session.observe(\.outputVolume) { [self] (session, value) in
            DispatchQueue.main.async {
                self.volume = session.outputVolume
            }
        }
    }

    func unsubscribe() {
        self.progressObserver.invalidate()
    }
    
    func setVolume(volume : Float) -> Void {
        volumeView.setVolume(volume)
    }

    init() {
        subscribe()
    }
}
