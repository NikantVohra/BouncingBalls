//
//  GameScene.swift
//  BouncingBalls
//
//  Created by Vohra, Nikant on 12/26/14.
//  Copyright (c) 2014 Vohra, Nikant. All rights reserved.
//

import SpriteKit
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}



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
    var scale : CGFloat = 1.0
    
    init(size: CGSize, level : Int) {
        super.init(size: size)
        self.sceneWidth = size.width
        self.sceneHeight = size.height
        self.backgroundColor = UIColor(red: 239/255.0, green: 208/255.0, blue: 112/255.0, alpha: 1)
        configureScene()
        createLevelJSON(level)
      //  playBackgroundMusic("background-music.wav")
    }
    
    func createLevelJSON(level : Int) {
        DataManager.getAppDataFromFileWithSuccess{ (data) -> Void in
            self.json = JSON(data: data)
            self.createLevel(level)
        }
    }
    
    
    
    func configureScene() {
        configurePhysicsWorld()
        configurBorder()
        addBall()
        configureRightWall()
        addBallPositioningLine()
        addBorder()
        addMenuButton()
        addReplayButton()
        addLevelLabel()
    }
    
    func addMovingTile() {
        
    }
    
    func configurePhysicsWorld() {
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        self.physicsWorld.contactDelegate = self
    }
    
    func addMenuButton(){
        let menuButton = SKSpriteNode(texture: SKTexture(imageNamed: "MenuIcon"), size: CGSizeMake(30.0,30.0))
        menuButton.name = menuButtonIdentifier
        menuButton.zPosition = 10
        menuButton.position = CGPoint(x: size.width - 40, y: 40)
        self.addChild(menuButton)
    }
    
    func addReplayButton(){
        let replayButton = SKSpriteNode(texture: SKTexture(imageNamed: "ReplayIcon"), size: CGSizeMake(35.0,35.0))
        replayButton.name = replayButtonIdentifier
        replayButton.zPosition = 10
        replayButton.position = CGPoint(x: size.width - 40, y: 85)
        self.addChild(replayButton)
    }
    
    func addLevelLabel(){
        let label = SKLabelNode(fontNamed: "Helvetica Neue")
        label.text = String(player.currentLevel)
        label.fontSize = 40
        label.fontColor = SKColor.whiteColor()
        label.position = CGPoint(x: size.width - 40, y: 115)
        addChild(label)
    }
    
    func addBorder(){
        addTile(0, y: 0, height: 10, width: sceneWidth, active: true, state: "STATIC", sX: 0, sY: 0, eX: 0, eY: 0)
        addTile(0, y: sceneHeight - 10, height: 10, width: sceneWidth, active: true, state: "STATIC", sX: 0, sY: 0, eX: 0, eY: 0)
        addTile(0, y: 0, height: sceneHeight, width: 20, active: true, state: "STATIC", sX: 0, sY: 0, eX: 0, eY: 0)
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
        ball.fillColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        ball.strokeColor = UIColor.clearColor()
        ball.position = CGPointMake(20, self.frame.size.height/2)
        ball.configurePhysicsBody()
        self.addChild(ball)
    }
    
    func addBallPositioningLine() {
        let line = SKShapeNode(rect: CGRectMake(10, 0, 1, sceneHeight))
        line.strokeColor = SKColor.clearColor()
        line.fillColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        line.position = CGPointMake(10, 0)
        self.addChild(line)
    }
    
    func addTile(x: CGFloat, y: CGFloat, height: CGFloat, width: CGFloat, active: Bool, state: String, sX: CGFloat, sY: CGFloat, eX: CGFloat, eY: CGFloat) {
        let tile = Tile(path: CGPathCreateWithRoundedRect(CGRectMake(x, y, width, height), 4, 4, nil), centered: true)
        
        tile.configurePhysicsBody()
        tile.zPosition = 10
        tile.isActive = active
        tile.strokeColor = SKColor.clearColor()
        tile.position = CGPointMake(x + width/2, y + height/2 )
        if (tile.isActive) {
            tile.fillColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        } else {
            tile.fillColor = UIColor(red: 80/255.0, green: 80/255.0, blue: 80/255.0, alpha: 1)
        }
        
        self.addChild(tile)
        let shadow = Tile(path: CGPathCreateWithRoundedRect(CGRectMake(x - 2, y - 2, width, height), 4, 4, nil), centered: true)
        shadow.fillColor = UIColor(red: 80/255.0, green: 80/255.0, blue: 80/255.0, alpha: 1)
        shadow.position = CGPointMake(x + width/2 - 2, y + height/2 - 2 )
        shadow.strokeColor = SKColor.clearColor()
        shadow.blendMode = SKBlendMode.Alpha
        shadow.alpha = 0.25
        
        self.addChild(shadow)
        
        // tile movement 
        
        if (state != "STATIC" ) {
            var path: CGMutablePathRef = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, 0, 0) // From point x , y
            CGPathAddLineToPoint(path, nil, eX-sX, eY-sY); // To Point x, y
            var followline: SKAction = SKAction.followPath(path, asOffset: true, orientToPath: false, duration: 1.0)
            var reversedline: SKAction = followline.reversedAction()
            var oscillate: SKAction = SKAction.sequence([followline,reversedline])
            tile.runAction(SKAction.repeatActionForever(oscillate))
            shadow.runAction(SKAction.repeatActionForever(oscillate))
        }
        
        // tile hide-show
        
        if (state == "BLINK") {
            var hide: SKAction = SKAction.hide()
            var disable: SKAction = SKAction.runBlock({ () -> Void in
                tile.disablePhysicsBody()
            })
            var wait: SKAction = SKAction.waitForDuration(1.5)
            var show: SKAction = SKAction.unhide()
            var enable: SKAction = SKAction.runBlock({ () -> Void in
                tile.configurePhysicsBody()
            })
            var blink: SKAction = SKAction.sequence([wait, disable, hide, wait, show, enable])
            shadow.runAction(SKAction.repeatActionForever(blink))
            tile.runAction(SKAction.repeatActionForever(blink))
        }
    }
    
    func createLevel(level : Int){
        let levelJson = json["screens"][level]
        println(levelJson)
        for (index: String, tile: JSON) in levelJson["tiles"] {
            let tX = tile["start"]["x"].doubleValue
            let tY = tile["start"]["y"].doubleValue
            let tHeight = tile["height"].doubleValue
            let tWidth = tile["width"].doubleValue
            let tActive = tile["active"].boolValue
            let tState = tile["move"].stringValue
            let sX = tile["movingFrom"]["x"].doubleValue
            let sY = tile["movingFrom"]["y"].doubleValue
            let eX = tile["movingTo"]["x"].doubleValue
            let eY = tile["movingTo"]["y"].doubleValue
            addTile(CGFloat(tX)/800 * sceneWidth, y: CGFloat(tY)/450 * sceneHeight, height: CGFloat(tHeight)/450 * sceneHeight, width: CGFloat(tWidth)/800 * sceneWidth, active: tActive, state: tState, sX: CGFloat(sX), sY: CGFloat(sY), eX: CGFloat(eX), eY: CGFloat(eY))
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
                let reveal = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                let youWinScene = GameOverScene(size: self.frame.size, won: false)
                self.view?.presentScene(youWinScene, transition: reveal)
            }
            runAction(SKAction.playSoundFileNamed("bounce.mp3", waitForCompletion: false))
            
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.RightSide {
            //firstBody.node?.removeFromParent()
            //firstBody.node?.physicsBody?.velocity.dy = firstBody.node?.physicsBody
            let reveal = SKTransition.doorsCloseHorizontalWithDuration(0.5)
            let youWinScene = GameOverScene(size: self.frame.size, won: true)
            self.view?.presentScene(youWinScene, transition: reveal)
            
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        //let body:SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        let body:SKNode = self.nodeAtPoint(touchLocation)
        if body.name == ballCategoryName && !ball.isMoving {
            ball.isFingerOnBall = true
        }
        else if body.name == replayButtonIdentifier {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: size, level : player.currentLevel)
            self.view?.presentScene(scene, transition:reveal)
        }
        else if body.name == menuButtonIdentifier {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameSelectLevelScene(size: size)
            self.view?.presentScene(scene, transition:reveal)
        }
        
        let button:SKNode = self.nodeAtPoint(touchLocation)
        
        if button.name == replayButtonIdentifier {
            //let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: size, level : player.currentLevel)
            self.view?.presentScene(scene, transition:nil)
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
        
       let body:SKNode = self.nodeAtPoint(touchLocation)
        if !ball.isMoving {
            if body.name == ballCategoryName || ball.isFingerOnBall{
                ball.isFingerOnBall = false
            }
            
            else {
                let offset = touchLocation - ball.position
                if (offset.x < 0) {
                    return
                }
                ball.isMoving = true
                let direction = offset.normalized()
                let shootAmount = direction * 4
                
                // 8 - Add the shoot amount to the current position
                ball.launch(CGVectorMake(shootAmount.x, shootAmount.y))
            }
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}
