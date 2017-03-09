//
//  Constants.swift
//  Reversi
//
//  Created by bill harper on 3/7/17.
//  Copyright © 2017 bill harper. All rights reserved.
//

import Foundation
import UIKit

/// A simple class to hold some constants used in the game

struct Constants {
    /// number of rows
    static let NUM_ROWS = 8
    /// number of columns
    static let NUM_COLS = 8
    /// player 1 id
    static let PLAYER_1 = 1
    /// player 2 id
    static let PLAYER_2 = 2
    /// empty slot id
    static let EMPTY = 0
    /// board width/height
    static let BOARD_DIM = 272
    /// size of each grid piece
    static let GRID_SIZE = BOARD_DIM/8
    /// list of move tuples -- row, col format
    static let MOVES = [(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (-1, 1), (1,1), (1,-1)]
    /// tuple representing an invalid move
    static let INVALID_MOVE = (999,999)
    /// board weights for minimax
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
