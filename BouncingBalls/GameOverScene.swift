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
        backgroundColor = UIColor(red: 239/255.0, green: 208/255.0, blue: 112/255.0, alpha: 1)
        
        // 2
        var message = won ? "You Won!" : "Try Again"
        
        // 3
        let label = SKLabelNode(fontNamed: "Helvetica Neue")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.whiteColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let playAgainButton = SKSpriteNode(texture: SKTexture(imageNamed: "ReplayIcon"), size: CGSizeMake(40.0,40.0))
        playAgainButton.name = playAgainButtonIdentifier
        playAgainButton.zPosition = 10
        if(won) {
            playAgainButton.position = CGPoint(x: size.width/2 - 40, y: size.height/3)
        }
        else {
            playAgainButton.position = CGPoint(x: size.width/2, y: size.height/3)
        }
        
        let nextLevelButton = SKSpriteNode(texture: SKTexture(imageNamed: "NextIcon"), size: CGSizeMake(30.0,30.0))
        nextLevelButton.name = nextLevelButtonIdentifier
        nextLevelButton.zPosition = 10
        nextLevelButton.position = CGPoint(x: size.width/2 + 40, y: size.height/3)
        
        addChild(playAgainButton)
        if(won){
            addChild(nextLevelButton)
        }
        
        // 4
        
    }
    
   
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKNode = self.nodeAtPoint(touchLocation)
        
        if body.name == playAgainButtonIdentifier {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: size, level : player.currentLevel)
            self.view?.presentScene(scene, transition:reveal)
        }
        
        if body.name == nextLevelButtonIdentifier {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            if(player.currentLevel + 1 != maxLevels) {
                player.currentLevel = player.currentLevel + 1
            }
            else {
                player.currentLevel = 0
            }
            
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
