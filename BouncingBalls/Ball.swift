//
//  Ball.swift
//  BouncingBalls
//
//  Created by Vohra, Nikant on 12/26/14.
//  Copyright (c) 2014 Vohra, Nikant. All rights reserved.
//

import Foundation
import SpriteKit

let ballCategoryName = "ball"
let ballRadius:CGFloat = 10.0

class Ball : SKShapeNode {
    
    var isFingerOnBall = false
    var isMoving = false
    
    
    func configurePhysicsBody() {
        self.name = ballCategoryName;
        physicsBody = SKPhysicsBody(circleOfRadius: frame.size.width/2)
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 1.0
        physicsBody?.linearDamping = 0.0
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Ball
        physicsBody?.contactTestBitMask = PhysicsCategory.Tile | PhysicsCategory.RightSide
    }
    
    func launch(direction : CGVector) {
        physicsBody?.applyImpulse(direction)
    }
}