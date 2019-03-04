//
//  FirebaseConfig.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 03.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation

import Firebase

/// This class initializes Firebase.
/// All other Firebase Services depend on this config, in this way
/// it is guaranteed that the initialization happened before usage of any Firebase service.
class FirebaseConfig {
    init() {
        let firebaseConfig = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        guard let options = FirebaseOptions(contentsOfFile: firebaseConfig) else {
            fatalError("Invalid Firebase configuration file.")
        }
        
        FirebaseApp.configure(options: options)
    }
}
