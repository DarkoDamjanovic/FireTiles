//
//  MapBuilder.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import UIKit

class MapBuilder {
    private let log = Logger()
    private let dependencyContainer: DependencyContainerProtocol
    
    init(dependencyContainer: DependencyContainerProtocol) {
        self.dependencyContainer = dependencyContainer
    }
    
    func build() -> UIViewController {
        let view = MapViewController.storyboardInstance()
        let navigator = MapNavigator(view: view, dependencyContainer: self.dependencyContainer)
        let presenter = MapPresenter(view: view, navigator: navigator, firestoreService: self.dependencyContainer.firestoreService)
        view.presenter = presenter
        return view
    }
    
    deinit {
        log.info("")
    }
}
