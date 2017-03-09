//
//  HelpViewController.swift
//  Reversi
//
//  Created by bill harper on 3/8/17.
//  Copyright © 2017 bill harper. All rights reserved.
//

import UIKit


/// The help view controller displays help as a UIWebView for easy formatting 
/// (since I'm not very good with visual stuff...) and the ability to open a
/// reversi rules page (which won't fit in one screen) in-app
class HelpViewController: UIViewController {

    /// the webview
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //load a file
        let url = Bundle.main.url(forResource: "rules", withExtension: "html")
        let request = NSURLRequest(url: url!)
        webView.loadRequest(request as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {});
    }

}
