//
//  GameOverScene.swift
//  SpriteKitSampleGame
//
//  Created by Vohra, Nikant on 12/26/14.
//  Copyright (c) 2014 Vohra, Nikant. All rights reserved.
//

import Foundation
import SpriteKit

class GameLaunchScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        
        var background : SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed:"LandingImage"), size:size)
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.addChild(background)
        
        let playButton = SKSpriteNode(color: SKColor.clearColor(), size : CGSizeMake(60.0, 60.0))
        playButton.name = playButtonIdentifier
        playButton.zPosition = 10
        playButton.position = CGPoint(x: 5 * size.width/6, y: size.height/3)
        self.addChild(playButton)
        
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKNode = self.nodeAtPoint(touchLocation)
        
        if body.name == playButtonIdentifier {
            let reveal = SKTransition.doorsOpenHorizontalWithDuration(0.5)
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
