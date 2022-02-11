//
//  SongsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct SongsView: View {
    
    var songs: FetchedResults<Song> {
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Song>
    
    init() {
        self.fetchRequest = FetchRequest(
            entity: Song.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Song.name), ascending: true, selector:
                                #selector(NSString.caseInsensitiveCompare))]
        )
    }
    
    var body: some View {
        NavigationView {
            Text("Do this work?").navigationTitle("Songs")
        }
    }
}

struct SongsView_Previews: PreviewProvider {
    static var previews: some View {
        SongsView()
    }
}
