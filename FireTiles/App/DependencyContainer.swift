//
//  DependencyContainer.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 11.11.18.
//  Copyright © 2018 SolidRock. All rights reserved.
//

import Foundation

protocol DependencyContainerProtocol {
    var firestoreService: FirestoreServiceProtocol { get }
}

/// Holds all shared dependencies for the Application.
/// The Swift lazy feature is used here to create a correct dependency injection tree with only single instances.
/// It doesn't matter which dependency is loaded first, it will automatically create all
/// it's needed dependencies here and they will be injected.
class DependencyContainer: DependencyContainerProtocol {
    /// FirebaseConfig is instantiated here only once as lazy and passed to all other Firebase Services.
    private(set) lazy var firebaseConfig = FirebaseConfig()
    private(set) lazy var firestoreService: FirestoreServiceProtocol = FirestoreService(config: self.firebaseConfig)
    
    /// Using own user defaults instead of UserDefaults.standards enabled unit testing of UserDefaults.
    /// In the corresponding unit test another user default is created and so we have isolated tests.
    private(set) lazy var userDefaults = UserDefaults(suiteName: "solutions.solidrock.firetiles.ios.userdefaults")!
}
