import UIKit
import SpriteKit


class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as SKView
        
//        DataManager.getAppDataFromFileWithSuccess{ (data) -> Void in
//            let json = JSON(data: data)
//            scene.json = json;
//            scene.createLevel();
//            skView.ignoresSiblingOrder = true
//            scene.scaleMode = .AspectFill
//            skView.presentScene(scene)
//        }
        scene.createLevel()
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}