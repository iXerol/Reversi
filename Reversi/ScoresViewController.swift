//
//  ScoresViewController.swift
//  Reversi
//
//  Created by bill harper on 3/8/17.
//  Copyright © 2017 bill harper. All rights reserved.
//

import UIKit

/// A simple tableview controller to display a list of top scores
/// This could easily be customized to look prettier (but I'm terrible at design), so it's flexible for 
/// When I improve it as a personal project
class ScoresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// list of top scores
    var scoreList: [Int] = []
    /// each cell
    @IBOutlet weak var cell: UITableViewCell!
    /// tableview
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults:UserDefaults = UserDefaults.standard
        scoreList = userDefaults.array(forKey: "scores") as! [Int]
        scoreList = scoreList.sorted()
        // only display the top 15
        if(scoreList.count > 15) {
            let slice = scoreList[0...14]
            scoreList = Array<Int>(slice)
        }
        tableView.dataSource = self
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Getting the right element
        let element = scoreList[indexPath.row]
        // Instantiate a cell
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ScoreCell")
        cell.textLabel?.text = String(element)
        // Returning the cell
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// - dismiss: use back button to close the view
    @IBAction func dismiss(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {});
    }
}
