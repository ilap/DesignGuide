//
//  ParametersType.swift
//  DesignGuide
//
//  Created by Pal Dorogi on 7/05/2016.
//
//

import Foundation


class DesignGuideCommand {
    var parameters: DesignGuideParameters
    var errorMessage: String? = nil
    
    var guideManager: DesignGuideManager {
        get {
            let gm = DesignGuideManager.sharedInstance
            
            return gm
        }
    }
    
    init() {
        parameters = RuntimeParameters.sharedInstance
    }
    
    internal func initialiseAndExecute() throws {
        debugPrint("\(__FILE__):\(__LINE__): invoked")
        try guideManager.initialiseFromParameters(parameters)
        
        guideManager.design()
    }
    
}

