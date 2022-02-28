//
//  CarPlaySceneDelegateName.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/28/22.
//

import Foundation
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    // CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        // Creating Tab Sections
        
        let item = CPListItem(text: "Rubber Soul", detailText: "The Beatles")
        
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Albums", sections: [section])
        self.interfaceController!.pushTemplate(listTemplate, animated: true)

    }
    // CarPlay disconnected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
 } }
