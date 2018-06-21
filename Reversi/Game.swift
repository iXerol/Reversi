import Foundation

// 黑白棋游戏本身
// 棋子状态以及游戏逻辑

class Game {
	// 棋盘状态
	var realBoard = Array<Array<Int>>()
	
	// 当前玩家
	var curPlayer = Constants.EMPTY
	
	init() {
		initializePieces()
	}
	
	// 使用棋盘与当前玩家构造游戏
	init(board: Array<Array<Int>>, player: Int) {
		realBoard = board
		curPlayer = player
	}
	
	// 初始化棋盘
	func initializePieces() {
		for _ in 0..<Constants.NUM_ROWS {
			realBoard.append(Array(repeating: 0, count: Constants.NUM_COLS))
		}
	}
	
	// 开始新游戏
	func newGame() {
		curPlayer = Constants.PLAYER_1
		for y in 0..<Constants.NUM_ROWS {
			for x in 0..<Constants.NUM_COLS {
				realBoard[y][x] = Constants.EMPTY
			}
		}
		realBoard[3][3] = Constants.PLAYER_1
		realBoard[3][4] = Constants.PLAYER_2
		realBoard[4][3] = Constants.PLAYER_2
		realBoard[4][4] = Constants.PLAYER_1
	}
	
	// opponent: 返回另一个玩家
	// - Returns: 代表另一个玩家的 Int
	func opponent(player: Int) -> Int {
		return (player == Constants.PLAYER_1) ? Constants.PLAYER_2 : Constants.PLAYER_1
	}
	
	// checkMove: 判断落子在该方向是否构成同色封闭区间
	// - Parameter row: 落子位置的行
	// - Paremeter col: 落子位置的列
	// - Parameter player: 落子玩家
	// - Parameter direction: 检查方向
	// - Returns: 落子位置或不可行位置
	func checkMove(row: Int, col: Int, player: Int, direction: (Int, Int)) -> (Int, Int) {
		var x = col
		var y = row
		
		if realBoard[y][x] != Constants.EMPTY {
			return Constants.INVALID_MOVE
		}
		
		x = col + direction.1
		y = row + direction.0
		if !(x >= 0 && x < 8 && y >= 0 && y < 8) {
			return Constants.INVALID_MOVE
		}
		
		if (realBoard[y][x] == player) {
			return Constants.INVALID_MOVE
		}
		
		let opp = opponent(player: player)
		while (x >= 0 && x < 8 && y >= 0 && y < 8 && realBoard[y][x] == opp) {
			x = x + direction.1
			y = y + direction.0
		}
		
		return ((x >= 0) && (x < 8) && (y >= 0) && (y < 8) && (realBoard[y][x] == player)) ? (y, x) : Constants.INVALID_MOVE
		
	}
	
	// isValid: 检查落子是否有效
	// - Parameter row: 落子位置的行
	// - Paremeter col: 落子位置的列
	// - Parameter player: 落子玩家
	// - Returns: 有效/无效的布尔值
	func isValid(row: Int, col: Int, player: Int) -> Bool {
		if !(col >= 0 && col < 8 && row >= 0 && row < 8 && realBoard[row][col] == Constants.EMPTY) {
			return false
		}
		for direction in Constants.MOVES {
			let move = checkMove(row: row, col: col, player: player, direction: direction)
			if (move != Constants.INVALID_MOVE) {
				return true
			}
		}
		realBoard[row][col] = Constants.EMPTY
		return false
	}
	
	
	// makeMove: 落子（已知落子合法）
	// - Parameter row: 落子位置的行
	// - Paremeter col: 落子位置的列
	// - Parameter player: 落子玩家
	// - Returns: 落子后的棋局
	func makeMove(row: Int, col: Int, player: Int, board: Array<Array<Int>>) -> Game {
		var boardcopy = board
		for direction in Constants.MOVES {
			let end = checkMove(row: row, col: col, player: player, direction: direction)
			if (end != Constants.INVALID_MOVE) {
				var pos = (row, col)
				while (pos != end) {
					boardcopy[pos.0][pos.1] = player
					pos = (pos.0 + direction.0, pos.1 + direction.1)
				}
			}
		}
		boardcopy[row][col] = player
		return Game(board: boardcopy, player: player)
	}
	
	// getMoves: 获取所有可落子点
	// - Paremeter player: 落子玩家
	// - Parameter board: 当前棋局
	// - Returns: 所有可落子点位置组成的数组
	func getMoves(player: Int) -> [(Int, Int)] {
		var movelist = [(Int, Int)]()
		for y in 0..<Constants.NUM_ROWS {
			for x in 0..<Constants.NUM_COLS {
				let move = isValid(row: y, col: x, player: player)
				if (move) {
					movelist.append((y, x))
				}
			}
		}
		return movelist
	}
	
	// nextPlayer: 获取下一个落子玩家
	// - Parameter board: 当前棋局
	// - Parameter player: 刚落子的玩家
	// - Returns: 下一个落子玩家（若一方无子可下则另一方连下，若两方均无子可下则游戏结束）
	func nextPlayer(player: Int) -> Int {
		let opp = opponent(player: player)
		if (getMoves(player: opp).count != 0) {
			return opp
		} else if (getMoves(player: player).count != 0) {
			print("player ", opp, " has no moves")
			return player
		} else {
			print("game over")
			return Constants.EMPTY
		}
	}
	
	// getScore: 获取棋子个数
	// - Parameter player: 玩家
	// - Returns: 该玩家的棋子个数
	func getScore(player: Int) -> Int {
		var playerscore = 0
		for y in 0..<Constants.NUM_ROWS {
			for x in 0..<Constants.NUM_COLS {
				switch realBoard[y][x] {
				case player:
					playerscore += 1
				default: break
				}
			}
		}
		return playerscore
	}
	
	/// weightedScore: 获取带权成绩
	// - Parameter board: 当前棋局
	// - Parameter player: 落子玩家
	// - Returns: 带权成绩
	func weightedScore(player: Int, board: Array<Array<Int>>) -> Int {
		var weightedscore = 0
		let opp = opponent(player: player)
		for y in 0..<Constants.NUM_ROWS {
			for x in 0..<Constants.NUM_COLS {
				switch board[y][x] {
				case player:
					weightedscore += Constants.BOARD_WEIGHTS[y][x]
				case opp:
					weightedscore -= Constants.BOARD_WEIGHTS[y][x]
				default: break
				}
			}
		}
		return weightedscore
	}
	
	// getWinner: 获取获胜者
	// Returns: 代表获胜者的玩家 Int
	func getWinner() -> Int {
		let playerscore = getScore(player: Constants.PLAYER_1)
		let compscore = getScore(player: Constants.PLAYER_2)
		if (playerscore == compscore) {
			return Constants.EMPTY
		}
		return (playerscore > compscore) ? Constants.PLAYER_1 : Constants.PLAYER_2
	}
	
	
	// Strategy: 以合适策略落子并返回 ViewController
	// - Parameter depth: 递归搜索深度 (若为 0 则随机落子)
	// - Returns: 落子后棋局
	func strategy(depth: Int) -> Game {
		let move: (Int, Int)
		if (depth > 0) {
			move = miniMax(player: curPlayer, depth: depth, alpha: Constants.MIN_WEIGHT, beta: Constants.MAX_WEIGHT, game: self).1
		} else {
			move = randomStrat(player: curPlayer)
		}
		let game = makeMove(row: move.0, col: move.1, player: curPlayer, board: realBoard)
		return game
	}
	
	
	// miniMax: minimax AI 实现（Alpha-Beta 剪枝）
	// - Parameter player: 落子玩家
	// - Parameter depth: 搜索深度
	// - Paraemeter game: 当前棋局
	// - Returns: (Int, (Int, Int)) -- 评估价值和落子位置
	func miniMax(player: Int, depth: Int, alpha: Int, beta: Int, game: Game) -> (Int, (Int, Int)) {
		var alpha = alpha
		// 若搜索深度为 0 则直接返回评估值
		if (depth == 0) {
			return (weightedScore(player: player, board: game.realBoard), Constants.INVALID_MOVE)
		}
		let moves = getMoves(player: player)
		// 若当前玩家无可落子位置
		if (moves.count == 0) {
			let oppmoves = getMoves(player: opponent(player: player))
			// 若对方也无可落子位置，游戏结束，返回评估值（非加权）
			if (oppmoves.count == 0) {
				let score = getScore(player: player)
				if (score == 0) {
					return (score, Constants.INVALID_MOVE)
				} else {
					let returnVal = (score > 0) ? Constants.MAX_WEIGHT : Constants.MIN_WEIGHT
					return (returnVal, Constants.INVALID_MOVE)
				}
			}
			// 若对方有可落子，返回对方的 miniMax
			let returnVal = -miniMax(player: opponent(player: player), depth: depth - 1, alpha: -beta, beta: -alpha, game: game).0
			return (returnVal, Constants.INVALID_MOVE)
		}
		// 否则返回最好落子
		
		var best_move = moves[0]
		for move in moves {
			// 若下界高于上界，说明此时此分枝的最优状况也不可能超过其他分枝，进行剪枝
			if alpha >= beta {
				break;
			}
			let newgame = game.makeMove(row: move.0, col: move.1, player: player, board: game.realBoard)
			// 模拟对方落子时递归调用自身新建棋局，深度减一，上下界（alpha, beta）取负
			let minireturn = miniMax(player: opponent(player: player), depth: depth - 1, alpha: -beta, beta: -alpha, game: newgame)
			// 若新棋局比当前下界状况更优则更新下界与最优落子
			if ((minireturn.0 * -1) > alpha) {
				alpha = -minireturn.0
				best_move = move
			}
		}
		return (alpha, best_move)
	}
	
	
	// randomStrat: 随机落子
	// - Parameter player: 落子玩家
	// - Returns: 随机落子位置
	func randomStrat(player: Int) -> (Int, Int) {
		let moves = getMoves(player: player)
		let randomIndex = Int(arc4random_uniform(UInt32(moves.count)))
		return moves[randomIndex]
	}
}
