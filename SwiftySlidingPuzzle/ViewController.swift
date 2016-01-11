//
//  ViewController.swift
//  SwiftySlidingPuzzle
//
//  Created by Mike MacDougall on 12/17/15.
//  Copyright © 2015 Michael MacDougall. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var board = SSPBoard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        board.setupWithSize(3)
        board.shuffleBoard()
        if(!board.isSolvable()) {
            print(board.printBoard())
            print("Inversions" + String(board.sumInversions()) + "\n")
            print("---")
        }
        board.printBoard()
        board.solvePuzzle()
        board.printBoard()
    }
}



