//
//  Game.swift
//  Reversi
//
//  Created by bill harper on 3/7/17.
//  Copyright © 2017 bill harper. All rights reserved.
//

import Foundation

/// class representing the game of reversi
/// holds pieces, piece checking logic, etc.
/// This is *not* a singleton because the AI needs to make copies of the game state for its strategy

class Game {
    /// the array holding the grid of pieces (true game state)
    var realBoard = Array<Array<Int>>()
    
    /// current player
    var curPlayer = Constants.EMPTY
    
    init() {
        initializePieces()
    }
    
    /// constructor with existing board, player
    init(board: Array<Array<Int>>, player: Int) {
        realBoard = board
        curPlayer = player
    }
    
    /// iniitalizePieces: create the the array of pieces
    func initializePieces() {
        for _ in 0..<Constants.NUM_ROWS {
            realBoard.append(Array(repeating: 0, count:Constants.NUM_COLS))
        }
    }
	
    /// newGame: setup a new game
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
    
    /// opponent: quick function to get opposite player to prevent constantly writing the same ternary
    /// - Returns: int of the opposite player
    func opponent(player: Int) -> Int {
        return (player==Constants.PLAYER_1) ? Constants.PLAYER_2 : Constants.PLAYER_1
    }
    
    /// checkMove: check a given move in a given direction and if so return the last piece to be flipped
    /// - Parameter row: row for attempted move
    /// - Paremeter col: col for attempted move
    /// - Parameter player: player moving (int)
    /// - Parameter direction: tuple for direction
    /// - Returns: (Int, Int) tuple of move (Constants.INVALID_MOVE if invalid)
    func checkMove(row: Int, col: Int, player: Int, direction: (Int, Int)) -> (Int, Int){
        var x = col
        var y = row
        // Automatically return invalid if first move is wrong
        if (realBoard[y][x] != Constants.EMPTY) {
                return Constants.INVALID_MOVE
        }
  
        x = col + direction.1
        y = row + direction.0
        if !((x>=0) && (x<8) && (y>=0) && (y<8)) {
            return Constants.INVALID_MOVE
        }
        
        if(realBoard[y][x] == player) {
            return Constants.INVALID_MOVE
        }
        
        let opp = opponent(player: player)
        while((x>=0) && (x<8) && (y>=0) && (y<8) && (realBoard[y][x]==opp)) {
            x = x + direction.1
            y = y + direction.0
        }
        // if we haven't hit the edge, and it's empty, valid move
        return ((x>=0) && (x<8) && (y>=0) && (y<8) && (realBoard[y][x] == player)) ? (y,x) : Constants.INVALID_MOVE

    }
    
    /// isValid: check if a move is valid (in any direction). Note that isValid is separate from getMoves for AI purposes
    /// - Parameter row: row for attempted move
    /// - Paremeter col: col for attempted move
    /// - Parameter player: player moving (int)
    /// - Returns: boolean of move validity
    func isValid(row: Int, col: Int, player: Int) -> Bool {
        // quick check to make sure in bounds and empty square
        if !((col>=0) && (col<8) && (row>=0) && (row<8) && (realBoard[row][col]==Constants.EMPTY)) {
            return false
        }
        for direction in Constants.MOVES {
            let move = checkMove(row: row, col: col, player: player, direction: direction)
            if (move != Constants.INVALID_MOVE) {
                return true
            }
        }
        return false
    }
    
    
    /// makeMove: make a move (which we already know is valid). When using manually, set curGame = makeMove(...)
    /// - Parameter row: row of the move
    /// - Parameter col: col of the move
    /// - Parameter player: player id
    /// - Returns: the Game state after moving and the player is switched (used for AI which needs deep copies)
    func makeMove(row: Int, col: Int, player: Int, board: Array<Array<Int>>) -> Game {
        var boardcopy = board
        for direction in Constants.MOVES {
            let end = checkMove(row: row, col: col, player: player, direction: direction)
            if (end != Constants.INVALID_MOVE) {
                var pos = (row,col)
                while (pos != end) {
                    boardcopy[pos.0][pos.1] = player
                    pos = (pos.0+direction.0, pos.1+direction.1)
                }
            }
        }
        boardcopy[row][col] = player
        return Game(board: boardcopy, player: player)
    }
    
    /// getMoves: get all legal moves for a player (human or AI)
    /// - Paremeter player: the player to check moves for
    /// - Parameter board: the game board
    /// - Returns: a list of tuples representing all moves
    func getMoves(player: Int) -> [(Int, Int)] {
        var movelist = [(Int, Int)]()
        for y in 0..<Constants.NUM_ROWS {
            for x in 0..<Constants.NUM_COLS {
                let move = isValid(row: y, col: x, player: player)
                if(move) {
                    movelist.append((y,x))
                }
            }
        }
        return movelist
    }
    
    /// nextPlayer: get the next player to move (one person may have no moves so someone goes twice)
    /// - Parameter board: the game board
    /// - Parameter player: the player who has just moved
    /// - Returns: ID (int) of player to move next (or EMPTY if no moves/game over)
    func nextPlayer(player: Int) -> Int {
        let opp = opponent(player: player)
        if(getMoves(player: opp).count != 0) {
            return opp
        }
        
        else if(getMoves(player: player).count != 0) {
            print("player ", opp, " has no moves")
            return player
        }
        else {
            print("game over")
            return Constants.EMPTY
        }
    }
    
    /// getScore: get the raw score for a given player.
    /// - Parameter player: player to get score for
    /// - Returns: Score (int) -- # of player pieces on the board
    func getScore(player: Int) -> Int{
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
    
    // The board weights are used because certain potential moves are much better than others--the outermst
    // corners/sides are best, inside is pretty good, and ring in the middle is suboptimal
    // scoring mechanism is a bit different because we don't need the raw score, but also subtract opponent's pieces
    /// weightedScore: get weighted score for a board for AI
    /// - Parameter board: the game board
    /// - Parameter player: player to move
    /// - Returns: the weighted score (int)
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
    
    /// getWinner: get the winner from a board
    /// Returns: int of winner id
    func getWinner() -> Int {
        let playerscore = getScore(player: Constants.PLAYER_1)
        let compscore = getScore(player: Constants.PLAYER_2)
        if(playerscore == compscore) {
            return Constants.EMPTY
        }
        return (playerscore > compscore) ? Constants.PLAYER_1 : Constants.PLAYER_2
    }
    

    
    /// Strategy -- a function which selects the appropriate strategy for use in the ViewController
    /// - Parameter depth: recursion depth for minimax (note: 0 = uses random choice instead)
    /// - Returns: game state after moving
    func strategy(depth: Int) -> Game {
        let move: (Int, Int)
        if(depth > 0) {
            move = miniMax(player: curPlayer, depth: depth, alpha: Constants.MIN_WEIGHT, beta: Constants.MAX_WEIGHT,  game: self).1
        }
        else {
            move = randomStrat(player: curPlayer)
        }
        let game = makeMove(row: move.0, col: move.1, player: curPlayer, board: realBoard)
        return game
    }
    
    // MARK: MiniMax AI (with alphabeta pruning, to the extent it helps)
    
    // one (of many) explanations: https://www.cs.cornell.edu/courses/cs312/2002sp/lectures/rec21.htm
    /// miniMax: minimax AI inplementation
    /// - Parameter player: the player to figure moves for
    /// - Parameter depth: depth to recurse
    /// - Paraemeter game: game copy beign evaluated
    /// - Returns: (Int, (Int, Int)) -- value and move
    func miniMax(player: Int, depth: Int, alpha: Int, beta: Int, game: Game) -> (Int, (Int, Int)){
        var alpha = alpha
        if(depth == 0) {
            return (weightedScore(player: player, board: game.realBoard), Constants.INVALID_MOVE)
        }
        let moves = getMoves(player: player)
        // if the current player has no moves
        if(moves.count == 0) {
            // first check of the opponent does
            let oppmoves = getMoves(player: opponent(player: player))
            // if he has no moves, the game is over. get the final value
            // here use the absolute score, which is all that matters--e.g. if it's <0 (loss), return the minimum value
            if(oppmoves.count == 0) {
                let score = getScore(player: player)
                if(score==0) {
                    return (score, Constants.INVALID_MOVE)
                }
                else {
                    let retval = (score > 0) ? Constants.MAX_WEIGHT : Constants.MIN_WEIGHT
                    return (retval, Constants.INVALID_MOVE)
                }
            }
            // opponent has moves, return his minimax val.
            // Always swap/negate beta and alpha as our best is the opponent's worse (and vice versa)
            let retval = -miniMax(player: opponent(player: player), depth: depth-1, alpha: -beta, beta: -alpha, game: game).0
            return (retval, Constants.INVALID_MOVE)
        }
        // otherwise, return the max of all the possible moves
        var best_move = moves[0]
        for move in moves {
            // don't bother using this move. the opponent will not choose a branch with worse outcome
            if alpha >= beta {
                break;
            }
            let newgame = game.makeMove(row: move.0, col: move.1, player: player, board: game.realBoard)
            let minireturn =  miniMax(player: opponent(player: player), depth: depth-1, alpha: -beta, beta: -alpha, game: newgame)
            if((minireturn.0 * -1)>alpha) {
                alpha = -minireturn.0
                best_move = move
            }
        }
        return (alpha, best_move)
    }
    
    
    // MARK: Other strategies
    
    /// randomStrat: simple random choice AI
    /// - Parameter player: the player to move (int)
    /// - Returns: int tuple representing random move
    func randomStrat(player: Int) -> (Int, Int) {
        let moves = getMoves(player: player)
        let randomIndex = Int(arc4random_uniform(UInt32(moves.count)))
        return moves[randomIndex]
    }
    
    /// simpleMax: -- for testing only--- simple best immediate move for AI (no depth)
    /// - Parameter player: the player to move (int)
    /// - Returns: int tuple representing chosen move
    
    func simpleMax(player: Int) -> (Int, Int) {
        let moves = getMoves(player: player)
        // the minimum weight is -240 so this is safe
        var max = Constants.MIN_WEIGHT
        var choice = moves[0]
        for elem in moves {
            let gamecpy = makeMove(row: elem.0, col: elem.1, player: player, board: realBoard)
            let score = weightedScore(player: player, board: gamecpy.realBoard)
            if(score > max) {
                max = score
                choice = elem
            }
        }
        return choice
    }
}
