//
//  GameSelectLevelScene.swift
//  BouncingBalls
//
//  Created by Vohra, Nikant on 1/8/15.
//  Copyright (c) 2015 Vohra, Nikant. All rights reserved.
//

import Foundation
import SpriteKit

class GameSelectLevelScene : SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor(red: 239/255.0, green: 208/255.0, blue: 112/255.0, alpha: 1)
        let initialX : CGFloat = 20.0
        let initialY : CGFloat = 80.0
        for var level = 0; level < maxLevels; level++ {
            addLevelLabel(initialX + CGFloat(level) * 40, y: size.height - initialY , level: level)
        }
    }

    func addLevelLabel(x:CGFloat, y:CGFloat, level : Int){
        let label = SKLabelNode(fontNamed: "Helvetica Neue")
        label.text = String(level)
        label.fontSize = 40
        label.fontColor = SKColor.whiteColor()
        label.position = CGPoint(x: x, y: y)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

