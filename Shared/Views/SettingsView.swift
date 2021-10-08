//
//  SettingsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(1...10, id: \.self) {
                    Text("Item \($0)")
                }
            }
            .navigationTitle("Settings")
        }    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
