//
//  ModuleTemplatePresenter.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation

protocol ModuleTemplatePresenterProtocol {
}

class ModuleTemplatePresenter {
    private let log = Logger()
    private unowned let view: ModuleTemplateViewControllerProtocol
    private let navigator: ModuleTemplateNavigatorProtocol
    
    init(view: ModuleTemplateViewControllerProtocol,
         navigator: ModuleTemplateNavigatorProtocol) {
        self.view = view
        self.navigator = navigator
    }
    
    deinit {
        log.info("")
    }
}

extension ModuleTemplatePresenter: ModuleTemplatePresenterProtocol {
}
