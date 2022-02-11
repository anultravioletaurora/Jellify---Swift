//
//  AirPlayView.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/11/22.
//

import SwiftUI
import AVKit

struct AirPlayView: UIViewRepresentable {
    
    private let routePickerView = AVRoutePickerView()

    func makeUIView(context: UIViewRepresentableContext<AirPlayView>) -> UIView {
        UIView()
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AirPlayView>) {
        routePickerView.tintColor = .white
        routePickerView.activeTintColor = .systemPink
        routePickerView.backgroundColor = .clear
        
        routePickerView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(routePickerView)

        NSLayoutConstraint.activate([
            routePickerView.topAnchor.constraint(equalTo: uiView.topAnchor),
            routePickerView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
            routePickerView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
            routePickerView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor)
        ])
    }
    
    func showAirPlayMenu() {
        for view: UIView in routePickerView.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
    }
}
