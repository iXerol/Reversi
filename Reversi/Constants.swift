import Foundation
import UIKit

// A simple class to hold some constants used in the game

struct Constants {
	// 行数
	static let NUM_ROWS = 8
	// 列数
	static let NUM_COLS = 8
	// 玩家 1 id
	static let PLAYER_1 = 1
	// 玩家 2 id
	static let PLAYER_2 = 2
	// 空位 id
	static let EMPTY = 0
	// 棋盘大小
	static let BOARD_DIM = 272
	// 每格大小
	static let GRID_SIZE = BOARD_DIM/8
	// 表示方向的元组数组
	static let MOVES = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, 1), (1, -1)]
	// 无效落子
	static let INVALID_MOVE = (999,999)
	// 棋盘权值
	static let BOARD_WEIGHTS = [
		[120, -20,  20,   5,   5,  20, -20, 120],
		[-20, -40,  -5,  -5,  -5,  -5, -40, -20],
		[20,  -5,  15,   3,   3,  15,  -5,  20],
		[5,  -5,   3,   3,   3,   3,  -5,   5],
		[5,  -5,   3,   3,   3,   3,  -5,   5],
		[20,  -5,  15,   3,   3,  15,  -5,  20],
		[-20, -40,  -5,  -5,  -5,  -5, -40, -20],
		[120, -20,  20,   5,   5,  20, -20, 120]
	]
	
	static let MAX_WEIGHT =  BOARD_WEIGHTS.flatMap{$0}.reduce(0, +)
	static let MIN_WEIGHT = -MAX_WEIGHT
}
