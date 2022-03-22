//
//  ViewExtensions.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 3/17/22.
//

import SwiftUI

extension View {
		
	/// Navigate to a new view.
	/// - Parameters:
	///   - view: View to navigate to.
	///   - binding: Only navigates when this condition is `true`.
	func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
		NavigationView {
			ZStack {

				NavigationLink(
					destination: view,
					isActive: binding
				) {
					EmptyView()
				}
			}
		}
		.navigationViewStyle(.stack)
	}
}
