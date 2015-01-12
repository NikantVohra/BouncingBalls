import UIKit
import SpriteKit

let player = Player(name: "")


class GameViewController: UIViewController {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupGoogleAds()
        let scene = GameLaunchScene(size: view.bounds.size)
        let skView = view as SKView
        
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    
    func setupGoogleAds() {
        self.bannerView.adUnitID = "ca-app-pub-6295134805178687/9172495413"
        self.bannerView.rootViewController = self
        
        let request = GADRequest()
        // Enable test ads on simulators.
        request.testDevices = [ GAD_SIMULATOR_ID ]
        self.bannerView.loadRequest(request)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}