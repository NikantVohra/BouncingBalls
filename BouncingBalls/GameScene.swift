//
//  GameScene.swift
//  BouncingBalls
//
//  Created by Vohra, Nikant on 12/26/14.
//  Copyright (c) 2014 Vohra, Nikant. All rights reserved.
//

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(#min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Tile   : UInt32 = 0b1       // 1
    static let Ball: UInt32 = 0b10      // 2
}


class GameScene: SKScene, SKPhysicsContactDelegate {

    
    let ball = SKShapeNode(circleOfRadius: 15.0)
    

    
    override func didMoveToView(view: SKView) {
        // 2
        
        backgroundColor = SKColor.whiteColor()
        
        
        ball.lineWidth = 1
        ball.antialiased = true
        ball.fillColor = SKColor.redColor()
        // 3
        ball.position = CGPoint(x: size.width * 0.05, y: size.height * 0.5)
        // 4
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
        ball.physicsBody?.dynamic = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Tile
        ball.physicsBody?.collisionBitMask = PhysicsCategory.None
        ball.physicsBody?.usesPreciseCollisionDetection = true

        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        addChild(ball)
        addTile()

    }
    
    func addTile() {
        
        // Create sprite
        let tile = SKShapeNode(rect: CGRectMake(100, 40, 80, 40))
        tile.fillColor = SKColor.grayColor()
        
        tile.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(80, 40)) // 1
        tile.physicsBody?.dynamic = false // 2
        tile.physicsBody?.categoryBitMask = PhysicsCategory.Tile // 3
        tile.physicsBody?.contactTestBitMask = PhysicsCategory.Ball // 4/        
        tile.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the tile along the Y axis
        //let actualY = random(min: tile.size.height/2, max: size.height - tile.size.height/2)
        
        // Position the tile slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        tile.position = CGPoint(x: 100,y: 240)
        
        // Add the tile to the scene
        addChild(tile)
        
        // Determine speed of the tile
        //let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile

        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - ball.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + ball.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        ball.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
}
