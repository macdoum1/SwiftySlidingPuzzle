//
//  SSPBoard.swift
//  SwiftySlidingPuzzle
//
//  Created by Mike MacDougall on 1/7/16.
//  Copyright © 2016 Michael MacDougall. All rights reserved.
//

import UIKit

enum SSPDirection : Int {
    case None = 0
    case Up
    case Down
    case Left
    case Right
}

class SSPBoard: NSObject {
    var tiles : [[SSPTile]] = [[SSPTile]]()
    var size : Int = 0
    var children : [SSPBoard] = [SSPBoard]()
    var lastDirection : SSPDirection = SSPDirection.None
    
    func setupWithSize(size : Int) {
        for x in 0..<size {
            var xArray = [SSPTile]()
            for y in 0..<size {
                xArray.append(SSPTile(x: x, y: y))
            }
            tiles.append(xArray)
        }
        self.size = size
    }
    
    func printBoard() {
        for var y = 0; y < tiles.count; y++ {
            var line = ""
            for var x = 0; x < tiles[y].count; x++ {
                line += String(tiles[x][y].value(size))
                line += " "
            }
            print(line)
        }
        
    }
    
    func shuffleBoard() {
        for x in 0..<tiles.count {
            tiles[x].shuffleInPlace()
        }
        
        if(!isSolvable()) {
            swapTiles(0, y1: 0, x2: 1, y2: 0)
        }
    }
    
    func swapTiles(x1 : Int, y1 : Int, x2 : Int, y2 : Int) {
        swap(&tiles[x1][y1], &tiles[x2][y2])
    }
    
    func countInversions(x : Int, y : Int) -> Int {
        var inversions = 0
        let tileNum = y * size + x
        let lastTile = size * size
        let tileValue = tiles[x][y].value(size)
        for var q = tileNum + 1; q < lastTile; q++ {
            let k = q % size
            let l = q / size
            let compValue = tiles[k][l].value(size)
            if(tileValue > compValue && tileValue != (lastTile - 1)) {
                inversions++
            }
        }
        return inversions
    }
    
    func sumInversions() -> Int {
        var inversions = 0
        for y in 0..<size {
            for x in 0..<size {
                inversions += countInversions(x, y: y)
            }
        }
        return inversions
    }
    
    func isSolvable() -> Bool {
        var solvable = false
        if (size % 2 == 1) {
            solvable = sumInversions() % 2 == 0
        } else {
            solvable = ((sumInversions() + size - emptyTilePos().y) % 2 == 0)
        }
        return solvable
    }
    
    func emptyTilePos() -> SSPIntPosition {
        for var x = 0; x < tiles.count; x++ {
            for var y = 0; y < tiles[x].count; y++ {
                if(tiles[x][y].isEmpty(size)) {
                    return SSPIntPosition(x: x, y: y);
                }
            }
        }
        
        return SSPIntPosition(x: 0, y: 0)
    }
    
    func solvePuzzle(){
        var moves = [SSPBoard]()
        
        if(isSolved()) {
            print("Solved")
            return
        }
        
        let directions = possibleDirections()
        if(directions.contains(SSPDirection.Up) && self.lastDirection != SSPDirection.Down) {
            let upBoard = SSPBoard()
            upBoard.tiles = tiles
            upBoard.size = tiles.count
            upBoard.applyDirection(SSPDirection.Up)
            upBoard.lastDirection = SSPDirection.Up
            moves.append(upBoard)
//            print("Up")
        }
        if(directions.contains(SSPDirection.Down) && self.lastDirection != SSPDirection.Up) {
            let downBoard = SSPBoard()
            downBoard.tiles = tiles
            downBoard.size = size
            downBoard.applyDirection(SSPDirection.Down)
            downBoard.lastDirection = SSPDirection.Down
            moves.append(downBoard)
//            print("Down")
        }
        if(directions.contains(SSPDirection.Left) && self.lastDirection != SSPDirection.Right) {
            let leftBoard = SSPBoard()
            leftBoard.tiles = tiles
            leftBoard.size = size
            leftBoard.applyDirection(SSPDirection.Left)
            leftBoard.lastDirection = SSPDirection.Left
            moves.append(leftBoard)
//            print("Left")
        }
        if(directions.contains(SSPDirection.Right) && self.lastDirection != SSPDirection.Left) {
            let rightBoard = SSPBoard()
            rightBoard.tiles = tiles
            rightBoard.size = size
            rightBoard.applyDirection(SSPDirection.Right)
            rightBoard.lastDirection = SSPDirection.Right
            moves.append(rightBoard)
//            print("Right")
        }
        children = moves
        print("---Start Level---")
        for child in children {
            child.printBoard()
            print("\n")
            return child.solvePuzzle()
        }
        
    }
    
    func isSolved() -> Bool {
        for var x = 0; x < tiles.count; x++ {
            for var y = 0; y < tiles[x].count; y++ {
                let tile = tiles[x][y]
                if(tile.x != x || tile.y != y) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func possibleDirections() -> [SSPDirection] {
        var possibleDirections = [SSPDirection]()
        if(emptyTilePos().y < size - 1) {
            possibleDirections.append(SSPDirection.Up)
        }
        if(emptyTilePos().y > 0) {
            possibleDirections.append(SSPDirection.Down)
        }
        if(emptyTilePos().x < size - 1) {
            possibleDirections.append(SSPDirection.Left)
        }
        if(emptyTilePos().x > 0) {
            possibleDirections.append(SSPDirection.Right)
        }
        return possibleDirections
    }
    
    func applyDirection(direction : SSPDirection) {
        let emptyTilePosition = emptyTilePos()
        switch direction {
        case .Up:
            swapTiles(emptyTilePosition.x, y1: emptyTilePosition.y, x2: emptyTilePosition.x, y2: emptyTilePosition.y + 1)
            break
        case .Down:
            swapTiles(emptyTilePosition.x, y1: emptyTilePosition.y, x2: emptyTilePosition.x, y2: emptyTilePosition.y - 1)
            break
        case .Left:
            swapTiles(emptyTilePosition.x, y1: emptyTilePosition.y, x2: emptyTilePosition.x + 1, y2: emptyTilePosition.y)
            break
        case .Right:
            swapTiles(emptyTilePosition.x, y1: emptyTilePosition.y, x2: emptyTilePosition.x - 1, y2: emptyTilePosition.y)
            break
        default:
            break
        }
    }

}

struct SSPTile {
    var x : Int = 0
    var y : Int = 0
    func value(width : Int) -> Int {
        return y * width + x
    }
    func isEmpty(width : Int) -> Bool {
        return value(width) == 0
    }
}

struct SSPIntPosition {
    var x : Int = 0
    var y : Int = 0
}
