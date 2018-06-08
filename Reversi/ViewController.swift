//
//  ViewController.swift
//  Reversi
//
//  Created by bill harper on 3/7/17.
//  Copyright © 2017 bill harper. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DetailDifficultyDelegate, UIPopoverPresentationControllerDelegate {

    // - Grid image attribution: http://www.dundjinni.com/forums/uploads/Bogie/8x8_Grid_bg.png
    /// imgview for the grid
    @IBOutlet var imgGrid: UIImageView!
    /// player 1 score
    @IBOutlet weak var p1score: UILabel!
    /// player 2 score
    @IBOutlet weak var p2score: UILabel!
    /// ai level
    @IBOutlet weak var aiLevel: UILabel!

    /// game representation
    var game = Game()
    
    /// timer for pauses after moves. To allow a bit of intermediate drawing time when using very vast AI (e.g. rand choice)
    var timer = Timer()
    let delay = 0.5
    
    /// imageviews for all of the pieces. Dictionary with key as int=board position (y*8 + x)
    var realBoard = [Int: UIImageView]()
    
    // - Attribution: piece images are icons from icons8.com
    /// player 1 img
    let p1img = #imageLiteral(resourceName: "White Circle.png")
    /// player 2 img
    let p2img = #imageLiteral(resourceName: "Black Circle.png")
	/// available move img
	let validMoveImg = #imageLiteral(resourceName: "Available.png")
    
    /// custom activity view to display when computer is moving
    var activityView: CustomActivityView!
    
    /// difficulty (braindead by default)
    var difficulty = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.boardTouch(_:)))
        // setup the activity view
        activityView = CustomActivityView(frame: CGRect(x: imgGrid.frame.size.width/2, y: imgGrid.frame.size.width/2, width: view.frame.size.width/6, height: view.frame.size.width/6))
        imgGrid.addSubview(activityView)
        // begin with it hidden
        activityView.isHidden = true;
        imgGrid.isUserInteractionEnabled = true
        imgGrid.addGestureRecognizer(tapGesture)
        game.newGame()
        initializeImges()
        paintBoard()
        
    }

    /// boardTouch: handle a tap on the reversi board
    func boardTouch(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // AI's move, ignore
            if(game.curPlayer == Constants.PLAYER_2) {
                return
            }
            // stop the timer in case of multiple taps
            timer.invalidate()
            let place = sender.location(in: imgGrid)
            let col = Int(place.x/CGFloat(Constants.GRID_SIZE))
            let row = Int(place.y/CGFloat(Constants.GRID_SIZE))
            let move = game.isValid(row: row, col: col, player: game.curPlayer)
            if(move) {
                processMove(row: row, col: col)
            }
        }
    }

    /// processMove: process a valid move for the player
    /// - Parameter row: row of move
    /// - Parameter col: col of move
    /// - Returns: void
    func processMove(row: Int, col: Int) {
        game = game.makeMove(row: row, col: col, player: game.curPlayer, board: game.realBoard)
        game.curPlayer = game.nextPlayer(player: game.curPlayer)
        paintBoard()
        if(game.curPlayer == Constants.EMPTY) {    // game is over
            gameOver(player: game.getWinner())
            return
        }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(AIMove), userInfo: nil, repeats: false)
    }
    
    /// AIMove: process a move for the AI.
    func AIMove() {
        // Our move, ignore
        if(game.curPlayer == Constants.PLAYER_1) {
            return
        }
        else if(game.curPlayer == Constants.EMPTY) {    // game is over
            gameOver(player: game.getWinner())
            return
        }
        activityView.showActivityView()
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            self.game = self.game.strategy(depth: self.difficulty)
            self.game.curPlayer = self.game.nextPlayer(player: self.game.curPlayer)
            DispatchQueue.main.async {
                self.activityView.hideActivityView()
                self.paintBoard()
                // we need to check if the current player has moves
                if(self.game.curPlayer == Constants.PLAYER_2) {
                    self.AIMove()
                }
                else if(self.game.curPlayer == Constants.EMPTY) {    // game is over
                    self.gameOver(player: self.game.getWinner())
                }
            }
        }
    }
    
    /// gameOver: present the winning player and start a new game upon dismissal
    /// - Parameter player: int of the player ID that won
    func gameOver(player: Int) {
        let message: String
		let title: String
        switch player {
        case Constants.PLAYER_1:
			title = "You won!"
            message = "Your score: \(p1score.text!)"
        case Constants.PLAYER_2:
			title = "You lost!"
			message = "Your score: \(p1score.text!)"
        default:
			title = "Game is draw!"
			message = "Your score: \(p1score.text!)"
        }
        // display the alert box
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Play Again",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true) {
            self.restart()
        }
    }
    
    /// restart: start a new game
    func restart() {
        game.newGame()
        paintBoard()
        switch difficulty {
        case 0:
            aiLevel.text = "Braindead"
        case 1:
            aiLevel.text = "Easy"
        case 4:
            aiLevel.text = "Medium"
        case 6:
            aiLevel.text = "Hard"
        default:
            aiLevel.text = "Error"
        }
        
    }
    /// initialize all the UIImageViews to be added programmatically
    func initializeImges() {
        for y in 0..<Constants.NUM_ROWS {
            for x in 0..<Constants.NUM_COLS {
                realBoard[y*8+x] = UIImageView(image: p1img)
                realBoard[y*8+x]?.frame = CGRect(x: CGFloat(x*Constants.GRID_SIZE),
                                                 y: CGFloat(y*Constants.GRID_SIZE),
                                                 width: CGFloat(Constants.GRID_SIZE),
                                                 height: CGFloat(Constants.GRID_SIZE))
                // hide by default
                realBoard[y*8+x]?.isHidden = true
                imgGrid.addSubview(realBoard[y*8+x]!)
            }
        }
    }
    
    /// paintBoard: draw all the images on the board after a move
	func paintBoard() {
		p1score.text = String(game.getScore(player: Constants.PLAYER_1))
		p2score.text = String(game.getScore(player: Constants.PLAYER_2))
		let board = game.realBoard
		for y in 0..<Constants.NUM_ROWS {
			for x in 0..<Constants.NUM_COLS {
				if(board[y][x] == Constants.EMPTY) {
					realBoard[y*8+x]?.isHidden = true
					continue
				}
				/// - Attribution: board piece images from icons8.com
				let img: UIImage
				if board[y][x] == Constants.PLAYER_1 {
					img = p1img
				} else if board[y][x] == Constants.PLAYER_2 {
					img = p2img
				} else /*if board[y][x] == Constants.VALID_POSITION */{
					img = validMoveImg
				}
					realBoard[y*8+x]?.image = img
					realBoard[y*8+x]?.isHidden = false
			}
		}
    }
	
    // Attribution (I spent way too much time on this):
    // -http://stackoverflow.com/questions/39972979/popover-in-swift-3-on-iphone-ios
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
    
    /// prepare for the segue to the bookmark view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewGameSegue" {
            let destination = segue.destination as? NewGameViewController
            destination?.modalPresentationStyle = UIModalPresentationStyle.popover
            destination?.popoverPresentationController?.delegate = self
            destination?.difficultyDelegate = self
            destination?.popoverPresentationController?.sourceView = sender as? UIView
//            destination?.popoverPresentationController?.sourceRect = sender.bounds
        }
    }
    
    /// passedDifficulty: implementation of DifficultykDelegate
    func passedDifficulty(difficulty: Int) {
        print("updated difficulty : ", difficulty)
        self.difficulty = difficulty
        restart()
    }
}

