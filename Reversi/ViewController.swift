import UIKit

class ViewController: UIViewController, DetailDifficultyDelegate, UIPopoverPresentationControllerDelegate {
	
	// http://www.dundjinni.com/forums/uploads/Bogie/8x8_Grid_bg.png
	@IBOutlet var imgGrid: UIImageView!
	// player 1 成績
	@IBOutlet weak var p1score: UILabel!
	// player 2 成績
	@IBOutlet weak var p2score: UILabel!
	// AI level
	@IBOutlet weak var aiLevel: UILabel!
	
	@IBAction func dismiss(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: {});
	}
	
	var game = Game()
	
	// 落子后停顿，给渲染、AI 落子时间
	var timer = Timer()
	let delay = 0.5
	
	var realBoard = [Int: UIImageView]()
	
	// player 1 img
	let p1img = #imageLiteral(resourceName: "Black Circle.png")
	// player 2 img
	let p2img = #imageLiteral(resourceName: "White Circle.png")
	// valid move img
	let validMoveImg = #imageLiteral(resourceName: "Available.png")
	
	// AI 计算时显示
	var activityView: CustomActivityView!
	
	// difficulty (缺省 easy)
	var difficulty = 0
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.boardTouch(_:)))
		activityView = CustomActivityView(frame: CGRect(x: Constants.BOARD_DIM / 8 * 3, y: Constants.BOARD_DIM / 8 * 3, width: Constants.BOARD_DIM / 4, height: Constants.BOARD_DIM / 4))
		imgGrid.isUserInteractionEnabled = true
		imgGrid.addGestureRecognizer(tapGesture)
		game.newGame()
		initializeImges()
		paintBoard()
		imgGrid.addSubview(activityView)
		activityView.isHidden = true;		
	}
	
	// boardTouch: 处理点击操作
	@objc func boardTouch(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			// 当 AI 落子时，忽略点击
			if (game.curPlayer == Constants.PLAYER_2) {
				return
			}
			timer.invalidate()
			let place = sender.location(in: imgGrid)
			let col = Int(place.x / CGFloat(Constants.GRID_SIZE))
			let row = Int(place.y / CGFloat(Constants.GRID_SIZE))
			let move = game.isValid(row: row, col: col, player: game.curPlayer)
			if (move) {
				processMove(row: row, col: col)
			}
		}
	}
	
	// processMove: 处理落子
	// - Parameter row: 落子行
	// - Parameter col: 落子列
	func processMove(row: Int, col: Int) {
		game = game.makeMove(row: row, col: col, player: game.curPlayer, board: game.realBoard)
		game.curPlayer = game.nextPlayer(player: game.curPlayer)
		paintBoard()
		if (game.curPlayer == Constants.EMPTY) {    // game over
			gameOver(player: game.getWinner())
			return
		}
		timer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(AIMove), userInfo: nil, repeats: false)
	}
	
	// AIMove: 处理 AI 落子
	@objc func AIMove() {
		if (game.curPlayer == Constants.PLAYER_1) {
			return
		} else if (game.curPlayer == Constants.EMPTY) {    // game over
			gameOver(player: game.getWinner())
			return
		}
		activityView.showActivityView()
		// 后台线程处理计算
		DispatchQueue.global(qos: .userInitiated).async {
			self.game = self.game.strategy(depth: self.difficulty)
			self.game.curPlayer = self.game.nextPlayer(player: self.game.curPlayer)
			DispatchQueue.main.async {
				self.activityView.hideActivityView()
				self.paintBoard()
				if (self.game.curPlayer == Constants.PLAYER_2) {
					self.AIMove()
				} else if (self.game.curPlayer == Constants.EMPTY) {    // game over
					self.gameOver(player: self.game.getWinner())
				}
			}
		}
	}
	
	// gameOver: 显示成绩
	// - Parameter player: 胜者 ID
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
		// 显示对话框
		let alert = UIAlertController(title: title,
									  message: message,
									  preferredStyle: UIAlertControllerStyle.alert)
		
		let restartAction = UIAlertAction(title: "Play Again",
										  style: .default,
										  handler: { _ in self.restart() })
		
		let cancelAction = UIAlertAction(title: "Cancel",
										 style: .cancel,
										 handler: nil)
		
		
		alert.addAction(cancelAction)
		alert.addAction(restartAction)
		self.present(alert, animated: true)
	}
	
	// restart: 重新开始游戏
	func restart() {
		game.newGame()
		paintBoard()
		switch difficulty {
		case 0:
			aiLevel.text = "Easy"
		case 2:
			aiLevel.text = "Medium"
		case 6:
			aiLevel.text = "Hard"
		default:
			aiLevel.text = "Error"
		}
		
	}
	
	// 初始化所有 UIImageView
	func initializeImges() {
		for y in 0..<Constants.NUM_ROWS {
			for x in 0..<Constants.NUM_COLS {
				realBoard[y * 8 + x] = UIImageView(image: p1img)
				realBoard[y * 8 + x]?.frame = CGRect(x: CGFloat(x * Constants.GRID_SIZE),
													 y: CGFloat(y * Constants.GRID_SIZE),
													 width: CGFloat(Constants.GRID_SIZE),
													 height: CGFloat(Constants.GRID_SIZE))
				// hide by default
				realBoard[y * 8 + x]?.isHidden = true
				imgGrid.addSubview(realBoard[y * 8 + x]!)
			}
		}
	}
	
	// paintBoard: 落子后绘制棋盘
	func paintBoard() {
		p1score.text = String(game.getScore(player: Constants.PLAYER_1))
		p2score.text = String(game.getScore(player: Constants.PLAYER_2))
		let board = game.realBoard
		for y in 0..<Constants.NUM_ROWS {
			for x in 0..<Constants.NUM_COLS {
				if (board[y][x] == Constants.EMPTY) {
					realBoard[y * 8 + x]?.isHidden = true
					continue
				}
				let img = (board[y][x] == Constants.PLAYER_1) ? p1img : p2img
				realBoard[y * 8 + x]?.image = img
				realBoard[y * 8 + x]?.isHidden = false
			}
		}
		if game.curPlayer == Constants.PLAYER_1 {
			let validMoves = game.getMoves(player: game.curPlayer)
			for (y, x) in validMoves {
				realBoard[y * 8 + x]?.image = validMoveImg
				realBoard[y * 8 + x]?.isHidden = false
			}
		}
	}
	
	// -http://stackoverflow.com/questions/39972979/popover-in-swift-3-on-iphone-ios
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		// return UIModalPresentationStyle.FullScreen
		return UIModalPresentationStyle.none
	}
	
	// 重载 prepare
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
	
	// passedDifficulty: 更新 difficulty
	func passedDifficulty(difficulty: Int) {
		self.difficulty = difficulty
		restart()
	}
}

