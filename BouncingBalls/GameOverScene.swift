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
        playAgainButton.position = CGPoint(x: size.width/2 - 40, y: size.height/3)
        
        let nextLevelButton = SKSpriteNode(imageNamed: "next.png")
        nextLevelButton.name = nextLevelButtonIdentifier
        nextLevelButton.zPosition = 10
        nextLevelButton.position = CGPoint(x: size.width/2 + 40, y: size.height/3)
        
        addChild(playAgainButton)
        
        addChild(nextLevelButton)
        
        
        // 4
        
    }
    
   
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKNode = self.nodeAtPoint(touchLocation)
        
        if body.name == playAgainButtonIdentifier {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: size, level : 0)
            
           // scene.createLevel(0);
            self.view?.presentScene(scene, transition:reveal)
        }
        
        if body.name == nextLevelButtonIdentifier {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            println(player.description)
            player.currentLevel = player.currentLevel + 1
            println(player.description)
            let scene = GameScene(size: size, level : player.currentLevel)
            
            // scene.createLevel(0);
            self.view?.presentScene(scene, transition:reveal)
        }
        
    }
    
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
