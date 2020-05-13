import UIKit


class ViewControllerLaunch: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AppManager.shared.appContainer = self
        AppManager.shared.showApp()
        
    }
}
