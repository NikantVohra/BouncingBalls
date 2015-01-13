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

//class Ball : SKShapeNode {
//    
//    var isFingerOnBall = false
//    var isMoving = false
//    
//    func configurePhysicsBody() {
//        self.name = ballCategoryName;
//        physicsBody = SKPhysicsBody(circleOfRadius: frame.size.width/2)
//        physicsBody?.friction = 0.0
//        physicsBody?.restitution = 1.0
//        physicsBody?.linearDamping = 0.0
//        physicsBody?.allowsRotation = false
//        physicsBody?.categoryBitMask = PhysicsCategory.Ball
//        physicsBody?.contactTestBitMask = PhysicsCategory.Tile | PhysicsCategory.RightSide
//    }
//    
//    func launch(direction : CGVector) {
//        physicsBody?.applyImpulse(direction)
//    }
//}

class Ball: SKShapeNode {
    
    var isFingerOnBall = false
    var isMoving = false
    
    var radius: Double {
        didSet {
            self.path = Ball.path(self.radius)
        }
    }
    
    init(radius: Double, position: CGPoint) {
        self.radius = radius
        
        super.init()
        
        self.path = Ball.path(self.radius)
        self.position = position
    }
    
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func path(radius: Double) -> CGMutablePathRef {
        var path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0.0, 0.0, CGFloat(radius), 0.0, CGFloat(2.0 * M_PI), true)
        return path
    }
    
    func launch(direction : CGVector) {
        physicsBody?.applyImpulse(direction)
    }
    
}