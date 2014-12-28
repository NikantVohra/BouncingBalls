//
//  GameOverScene.swift
//  SpriteKitSampleGame
//
//  Created by Vohra, Nikant on 12/26/14.
//  Copyright (c) 2014 Vohra, Nikant. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let playAgainButtonIdentifier = "playAgain"
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.whiteColor()
        
        // 2
        var message = won ? "You Won!" : "You Lose :["
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let playAgainButton = SKSpriteNode(imageNamed: "replay.png")
        playAgainButton.name = playAgainButtonIdentifier
        playAgainButton.zPosition = 10
        playAgainButton.position = CGPoint(x: size.width/2, y: size.height/3)
        
        addChild(playAgainButton)
        // 4
 
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKNode = self.nodeAtPoint(touchLocation)
        
        if body.name == playAgainButtonIdentifier {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: size)
            
            scene.createLevel();
            self.view?.presentScene(scene, transition:reveal)
        }
        
    }
    
    
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
