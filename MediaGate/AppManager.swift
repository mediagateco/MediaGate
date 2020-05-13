import UIKit
import Firebase

class AppManager {
    
    static let shared = AppManager()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var appContainer : ViewControllerLaunch!
    
    private init() {}
    
    //Setup auto-login for users.
    func showApp() {
        
        var viewController: UIViewController

        if Auth.auth().currentUser == nil {
            viewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
        } else {
            
            viewController = storyboard.instantiateViewController(withIdentifier: "tabBar")
        }
        
        appContainer.present(viewController, animated: true, completion: nil)
    }
    
}

