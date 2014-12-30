//
//  Player.swift
//  BouncingBalls
//
//  Created by Vohra, Nikant on 12/29/14.
//  Copyright (c) 2014 Vohra, Nikant. All rights reserved.
//

import Foundation

class Player {

    var name : String
    
    var currentLevel: Int {
        set {
            
            NSUserDefaults.standardUserDefaults().setInteger(newValue , forKey: currentLevelIdentifier)
            
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(currentLevelIdentifier)
        }
    }
    
    var description : String {
        get {
            return "\(name) is on level \(currentLevel)"
        }
    }
    
    init (name : String) {
        self.name = name
        
    }
    
    
    
    
    
    
    
}