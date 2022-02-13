//
//  PlayerViewOffset.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import SwiftUI

struct PlayerViewOffset: View {
    var body: some View {
        Rectangle().frame(width: 1, height: 60, alignment: .bottom).foregroundColor(Color.clear)
            .listRowSeparator(.hidden)
    }
}
