//
//  Extensions.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 11.11.18.
//  Copyright © 2018 SolidRock. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func storyboardInstance() -> Self {
        let bundle = Bundle(for: self)
        let storyboardName = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        return storyboard.initialViewController()
    }
}

extension UIStoryboard {
    func initialViewController<T: UIViewController>() -> T {
        // The force cast would fail on the first test. We want it to fail here early.
        // swiftlint:disable:next force_cast
        return self.instantiateInitialViewController() as! T
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

