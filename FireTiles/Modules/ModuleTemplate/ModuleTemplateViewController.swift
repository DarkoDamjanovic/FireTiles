//
//  ModuleTemplateViewController.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import UIKit

protocol ModuleTemplateViewControllerProtocol: AnyObject {
}

class ModuleTemplateViewController: UIViewController {
    private let log = Logger()
    var presenter: ModuleTemplatePresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
    }
    
    deinit {
        log.info("")
    }
}

extension ModuleTemplateViewController: ModuleTemplateViewControllerProtocol {
}
