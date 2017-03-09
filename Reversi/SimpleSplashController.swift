//
//  SimpleSplashController.swift
//  Reversi
//
//  Created by bill harper on 3/9/17.
//  Copyright © 2017 bill harper. All rights reserved.
//

import UIKit

/// A very simple splash screen to show using the non-default launch screen
class SimpleSplashController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(SimpleSplashController.showmainmenu), with: nil, afterDelay: 2)
    }
    
    func showmainmenu(){
        performSegue(withIdentifier: "displayMain", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
