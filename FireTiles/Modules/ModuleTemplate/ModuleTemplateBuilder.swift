//
//  ModuleTemplateBuilder.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import UIKit

class ModuleTemplateBuilder {
    private let log = Logger()
    private let dependencyContainer: DependencyContainerProtocol
    
    init(dependencyContainer: DependencyContainerProtocol) {
        self.dependencyContainer = dependencyContainer
    }
    
    func build() -> UIViewController {
        let view = ModuleTemplateViewController.storyboardInstance()
        let navigator = ModuleTemplateNavigator(view: view, dependencyContainer: self.dependencyContainer)
        let presenter = ModuleTemplatePresenter(view: view, navigator: navigator)
        view.presenter = presenter
        return view
    }
    
    deinit {
        log.info("")
    }
}
