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
    static let RightSide : UInt32 = 0b100
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    let ball = Ball(imageNamed: "ball.png")
    var fingerIsOnBall = false
    var level = 1
    var json: JSON = ""
    
    override init(size: CGSize) {
        super.init(size: size)
        self.physicsWorld.contactDelegate = self
        let background = SKSpriteNode(imageNamed: "bg.png")
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.addChild(background)
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody = borderBody
        // 3 Set the friction of that physicsBody to 0
        addBall()
        self.configureRightWall()
        
        DataManager.getAppDataFromFileWithSuccess{ (data) -> Void in
            self.json = JSON(data: data)
            self.createLevel()
        }
    }
    
    func configureRightWall() {
        let rightSideRect = CGRectMake(self.frame.size.width, self.frame.origin.y, 1, self.frame.size.height)
        let right = SKNode()
        right.physicsBody = SKPhysicsBody(edgeLoopFromRect: rightSideRect)
        
        self.addChild(right)
        
        right.physicsBody?.categoryBitMask = PhysicsCategory.RightSide
    }
    
    func addBall() {
        ball.position = CGPointMake(self.frame.size.width/10, self.frame.size.height/2)
        ball.configurePhysicsBody()
        self.addChild(ball)
    }
    
    func addTile(x: CGFloat, y: CGFloat, height: CGFloat, width: CGFloat, active: Bool) {
        let tile = Tile(rectOfSize: CGSizeMake(width, height))
        tile.configurePhysicsBody()
        tile.zPosition = 10
        tile.isActive = active
        tile.position = CGPointMake(x + 100, y + 10)
        if (tile.isActive) {
            tile.fillColor = SKColor.blackColor()
        } else {
            tile.fillColor = SKColor.grayColor()
        }
        
        self.addChild(tile)
    }
    
    func createLevel(){
        for (index: String, tile: JSON) in json["tiles"] {
            let tX = tile["start"]["x"].doubleValue;
            let tY = tile["start"]["y"].doubleValue;
            let tHeight = tile["height"].doubleValue;
            let tWidth = tile["width"].doubleValue;
            let tActive = tile["active"].boolValue;
            addTile( CGFloat(tX), y: CGFloat(tY), height: CGFloat(tHeight), width: CGFloat(tWidth), active: tActive)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Tile && secondBody.categoryBitMask == PhysicsCategory.Ball {
            //firstBody.node?.removeFromParent()
            //firstBody.node?.physicsBody?.velocity.dy = firstBody.node?.physicsBody
            let collisionTile  = firstBody.node? as? Tile
            
            if (collisionTile?.isActive != true){
                let youWinScene = GameOverScene(size: self.frame.size, won: false)
                self.view?.presentScene(youWinScene)
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.RightSide {
            //firstBody.node?.removeFromParent()
            //firstBody.node?.physicsBody?.velocity.dy = firstBody.node?.physicsBody
            let youWinScene = GameOverScene(size: self.frame.size, won: true)
            self.view?.presentScene(youWinScene)
            
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        
        if body?.node?.name == ballCategoryName {
            fingerIsOnBall = true
        }
        
    }
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if fingerIsOnBall {
            let touch = touches.anyObject() as UITouch
            let touchLoc = touch.locationInNode(self)
            let prevTouchLoc = touch.previousLocationInNode(self)
            
            let ball = self.childNodeWithName(ballCategoryName) as SKSpriteNode
            
            var newYPos = ball.position.y + (touchLoc.y - prevTouchLoc.y)
            
            newYPos = max(ball.size.width / 2, newYPos)
            newYPos = min(self.size.width - ball.size.width / 2, newYPos)
            
            ball.position = CGPointMake(ball.position.x, newYPos)
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        if body?.node?.name == ballCategoryName {
            fingerIsOnBall = false
        }
            
        else {
            let offset = touchLocation - ball.position
            if (offset.x < 0) { return }
            let direction = offset.normalized()
            let shootAmount = direction * 10
            
            // 8 - Add the shoot amount to the current position
            ball.physicsBody?.applyImpulse(CGVectorMake(shootAmount.x, shootAmount.y))
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}
