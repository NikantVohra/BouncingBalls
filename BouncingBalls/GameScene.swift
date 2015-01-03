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
    let ball = Ball(circleOfRadius: ballRadius)
    
    var level = 1
    var json: JSON = ""
    
    var sceneHeight : CGFloat = 0.0
    var sceneWidth : CGFloat = 0.0
    
    init(size: CGSize, level : Int) {
        super.init(size: size)
        self.sceneWidth = size.width
        self.sceneHeight = size.height
        self.backgroundColor = UIColor.whiteColor()

        configurePhysicsWorld()
        configurBorder()
        addBall()
        configureRightWall()
        addBallPositioningLine()
        
        DataManager.getAppDataFromFileWithSuccess{ (data) -> Void in
            self.json = JSON(data: data)
            self.createLevel(level)
        }
    }
    
    func configurePhysicsWorld() {
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        self.physicsWorld.contactDelegate = self
    }
    
    func configurBorder() {
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody = borderBody
    }
    
    func configureRightWall() {
        let rightSideRect = CGRectMake(self.frame.size.width, self.frame.origin.y, 1, self.frame.size.height)
        let right = SKNode()
        right.physicsBody = SKPhysicsBody(edgeLoopFromRect: rightSideRect)
        
        self.addChild(right)
        
        right.physicsBody?.categoryBitMask = PhysicsCategory.RightSide
    }
    
    func addBall() {
        ball.fillColor = SKColor.blackColor()
        ball.position = CGPointMake(20, self.frame.size.height/2)
        ball.configurePhysicsBody()
        self.addChild(ball)
    }
    
    func addBallPositioningLine() {
        let line = SKShapeNode(rect: CGRectMake(10, 0, 1, sceneHeight))
        line.strokeColor = SKColor.blackColor()
        line.fillColor = SKColor.blackColor()
        line.position = CGPointMake(10, 0)
        self.addChild(line)
    }
    
    func addTile(x: CGFloat, y: CGFloat, height: CGFloat, width: CGFloat, active: Bool) {
        let tile = Tile(rectOfSize: CGSizeMake(width, height))
        tile.configurePhysicsBody()
        tile.zPosition = 10
        tile.isActive = active
        tile.position = CGPointMake(x + width/2, y + height/2 )
        if (tile.isActive) {
            tile.fillColor = SKColor.blackColor()
        } else {
            tile.fillColor = SKColor.grayColor()
        }
        
        self.addChild(tile)
    }
    
    func createLevel(level : Int){
        let levelJson = json["levels"][level]
        for (index: String, tile: JSON) in levelJson["tiles"] {
            let tX = tile["start"]["x"].doubleValue;
            let tY = tile["start"]["y"].doubleValue;
            let tHeight = tile["height"].doubleValue;
            let tWidth = tile["width"].doubleValue;
            let tActive = tile["active"].boolValue;
            addTile( CGFloat(tX)/800 * sceneWidth, y: CGFloat(tY)/450 * sceneHeight, height: CGFloat(tHeight)/450 * sceneHeight, width: CGFloat(tWidth)/800 * sceneWidth, active: tActive)
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
        
        if body?.node?.name == ballCategoryName && !ball.isMoving {
            ball.isFingerOnBall = true
        }
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if ball.isFingerOnBall {
            let touch = touches.anyObject() as UITouch
            let touchLoc = touch.locationInNode(self)
            let prevTouchLoc = touch.previousLocationInNode(self)
            
            let ball = self.childNodeWithName(ballCategoryName) as SKShapeNode
            
            var newYPos = ball.position.y + (touchLoc.y - prevTouchLoc.y)
            
            newYPos = max(ballRadius / 2, newYPos)
            newYPos = min(self.size.width - ballRadius / 2, newYPos)
            
            ball.position = CGPointMake(ball.position.x, newYPos)
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        if !ball.isMoving {
            if body?.node?.name == ballCategoryName {
                ball.isFingerOnBall = false
            }
            
            else {
                let offset = touchLocation - ball.position
                if (offset.x < 0) {
                    return
                }
                ball.isMoving = true
                let direction = offset.normalized()
                let shootAmount = direction * 5
                
                // 8 - Add the shoot amount to the current position
                ball.launch(CGVectorMake(shootAmount.x, shootAmount.y))
            }
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}
