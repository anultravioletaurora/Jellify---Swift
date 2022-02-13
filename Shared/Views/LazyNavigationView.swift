//
//  LazyNavigationView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import SwiftUI

struct LazyNavigationView<Content: View>: View {
    
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
