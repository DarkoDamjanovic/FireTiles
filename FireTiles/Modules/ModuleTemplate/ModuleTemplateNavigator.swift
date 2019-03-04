//
//  ModuleTemplateNavigator.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation

protocol ModuleTemplateNavigatorProtocol {
}

class ModuleTemplateNavigator {
    private let log = Logger()
    private unowned let view: Navigatable
    private let dependencyContainer: DependencyContainerProtocol
    
    init(view: Navigatable, dependencyContainer: DependencyContainerProtocol) {
        self.view = view
        self.dependencyContainer = dependencyContainer
    }
    
    deinit {
        log.info("")
    }
}

extension ModuleTemplateNavigator: ModuleTemplateNavigatorProtocol {
}
