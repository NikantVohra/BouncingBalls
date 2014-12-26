//
//  Tile.swift
//  BouncingBalls
//
//  Created by Vohra, Nikant on 12/26/14.
//  Copyright (c) 2014 Vohra, Nikant. All rights reserved.
//

import Foundation
import SpriteKit

let tileCategoryName = "tile"

class Tile : SKSpriteNode{

    
    func configurePhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOfSize: frame.size)
        physicsBody?.friction = 0.4
        physicsBody?.restitution = 0.1
        physicsBody?.dynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.Tile
        //physicsBody?.contactTestBitMask = PhysicsCategory.Ball
    }
    
}