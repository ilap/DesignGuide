//
//  ApplicationDefaultsConfiguration.swift
//  DesignGuide
//
//  Created by Pal Dorogi on 5/05/2016.
//
//

import Foundation

import SwiftCLI

extension DefaultsKeys {
    // Defaults
    static let databasePath = DefaultsKey<String?>("databasePath")
    static let databaseFile = DefaultsKey<String?>("databaseFile")
    static let blobFilesPath = DefaultsKey<String?>("blobFilesPath")
    
}

class ApplicatioinDefaultsConfiguration {
    static let sharedInstance = ApplicatioinDefaultsConfiguration()
    
    private init() {
        // TODO: fix for Linux
        if var path = NSBundle.mainBundle().resourcePath {
            
            path +=  "/database"
            let nameDatabase = "design_guide.sqlite"
            
            Defaults[.databasePath] = path
            Defaults[.databaseFile] = nameDatabase
            
            path = "sequences"
            Defaults[.blobFilesPath] = path
            //print ("Database is set on:  \(Defaults[.databasePath])/\(Defaults[.databaseFile])")
        }
    }
}