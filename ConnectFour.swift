//
//  ConnectFour.swift
//
//  Created by Atri Sarker
//  Created on 2025-10-06
//  Version 1.0
//  Copyright (c) 2025 Atri Sarker. All rights reserved.
//
// Connect Four Game.
// The user plays against an ai that picks random moves.

import Foundation

// Constant for the number of columns.
let numColumns: Int = 7
// Constant for the number for rows.
let numRows: Int = 6
// Number of pieces in a row to win.
let numToWin: Int = 4
// Marker for the user.
let userMarker: String = "O"
// Marker for the AI.
let aiMarker: String = "X"
// Variable to hold the game's grid
var gameGrid: [String] = [String]()

// Helper function to get the nth character of a string
// https://stackoverflow.com/questions/24092884/
// get-nth-character-of-a-string-in-swift
func getNthChar(_ targetString: String, _ targetIndex: Int) -> String {
    let stringIndex = targetString.index(targetString.startIndex, offsetBy: targetIndex)
    let char = String(targetString[stringIndex])
    return char
}

// Extra function to reduce cyclomatic complexity.
// Purely for the linter
// Function that checks for diagonal wins.
func checkForDiagonalWins(_ marker: String) -> Bool {
    // Arrangement that results in a win
    let winString: String = String(repeating: marker, count: numToWin)
    // Check for forward slash [/] diagonal wins.
    // Go through every square that can be considered a starting point.
    // No starting point can be in the last {numToWin - 1} columns or rows.
    // Starting point is the bottom left of the forward slash [/] diagonal.
    for colNum in 0...(numColumns - numToWin) {
        for rowNum in 0...(numRows - numToWin) {
            // Set variable to hold the diagonal string.
            var diagonal: String = ""
            // Create the diagonal string.
            for squareNum in 0..<numToWin {
                diagonal += getNthChar(gameGrid[colNum+squareNum], rowNum + squareNum)
            }
            // Check if the diagonal is a win.
            if diagonal == winString {
                return true
            }
        }
    }
    // Do the exact same thing for backslash [\] diagonals.
    // Starting point is the top left of the backslash [\] diagonal.
    for colNum in 0...(numColumns - numToWin) {
        for rowNum in (numRows - (numToWin - 1))..<numRows {
            // Set variable to hold the diagonal string.
            var diagonal: String = ""
            // Create the diagonal string.
            for squareNum in 0..<numToWin {
                diagonal += getNthChar(gameGrid[colNum+squareNum], rowNum - squareNum)
            }
            // Check if the diagonal is a win.
            if diagonal == winString {
                return true
            }
        }
    }
    // If no wins were found, return false.
    return false
}

/* Function that checks if a marker has won
* Looks for any matches of markers {numToWin} in a row.
* Orthogonally or diagonally.
* [param] marker the marker to check for a win.
* [return] true if the marker has won, false otherwise.
*/
func checkForWin(_ marker: String) -> Bool {
    // Arrangement that results in a win
    let winString: String = String(repeating: marker, count: numToWin)
    // Check for vertical wins.
    // Go through each column
    for colNum in 0..<numColumns where gameGrid[colNum].contains(winString) {
        // Return true if the column contains a win.
        return true
    }
    // Check for horizontal wins.
    // Go through each row.
    for rowNum in 0..<numRows {
        // Set variable to hold the row string.
        var row: String = ""
        // Create the row string by iterating through each column
        for colNum in 0..<numColumns {
            row += getNthChar(gameGrid[colNum], rowNum)
        }
        // Check if the row contains a win.
        if row.contains(winString) {
            return true
        }
    }
    // Check for diagonal wins.
    if checkForDiagonalWins(marker) {
        return true
    }
    // If no wins were found, return false.
    return false
}

// Color for the player's marker [Blue].
let userColor: String = "\u{001B}[34m"

// Color for the AI's marker [Green].
let aiColor: String = "\u{001B}[32m"

// Color for resetting the color.
let resetColor: String = "\u{001B}[0m"

// Function that displays the game grid.
func displayGameGrid() {
    // Reset color
    print(resetColor, terminator: "")
    // Print the column numbers
    for colNum in 0..<numColumns {
        print(" \(colNum + 1)", terminator: "")
    }
    // Newline after printing column numbers.
    print()
    // Go through every row [starting from the top].
    for rowNum in (0..<numRows).reversed() {
        for colNum in 0..<numColumns {
            let marker = getNthChar(gameGrid[colNum], rowNum)
            // Match the marker with the correct color.
            // If it's not a user or ai marker, it just prints a hashtag.
            if marker == userMarker {
                print(" \(userColor)\(marker)\(resetColor)", terminator: "")
            } else if marker == aiMarker {
                print(" \(aiColor)\(marker)\(resetColor)", terminator: "")
            } else {
                print(" #", terminator: "")
            }
        }
        // Print a new line after every the end of every row,
        // to start a new row.
        print(resetColor)
    }
}

// Function that returns a list of unfilled column numbers.
func getUnfilledColumns() -> [Int] {
    // Create a list to hold unfilled column numbers.
    var unfilledColumns = [Int]()
    // Go through every column
    for colNum in 0..<numColumns where getNthChar(gameGrid[colNum], numRows - 1) == " " {
        // If the column is not full, add it to the list.
        unfilledColumns.append(colNum)
    }
    // Return the list of unfilled column numbers.
    return unfilledColumns
}

/*
* Number that defines the current turn number.
* Starts at 1, increments by 1 every turn.
*/
var turnNumber: Int = 1

/*
* Number that represents the total amount of grid spaces.
* Can be used as the maximum limit number of turns.
*/
let totalGridSpaces = numColumns * numRows

// Fill up the game grid with empty spaces.
for _ in 0..<numColumns {
    gameGrid.append(String(repeating: " ", count: numRows))
}

// LOOP
while turnNumber <= totalGridSpaces + 1 {
    // Display the game grid.
    displayGameGrid()
    // USER TURN
    if turnNumber % 2 != 0 {
        // Prompt for user input for the column number.
        print("Enter a column number [1-\(numColumns)]: ", terminator: "")
        // Get user input for the column number as a string.
        let chosenColumnAsString = readLine() ?? ""
        // Convert string input to an integer.
        if var chosenColumn = Int(chosenColumnAsString) {
            // 1 is subtracted to make it match with the actual array indexes.
            chosenColumn -= 1
            // Check if the input is valid.
            if chosenColumn < 0 || chosenColumn >= numColumns {
                // If it isn't, give an error message [IN RED]
                print("\u{001B}[0;31mERROR: INPUT OUT OF BOUNDS.")
                continue
            } else if getNthChar(gameGrid[chosenColumn], numRows-1) != " " {
                // If the column is full, give an error message [IN RED]
                print("\u{001B}[0;31mERROR: COLUMN IS FULL.")
            } else {
                // If it is, place the user's marker in the chosen column.
                // Find the lowest empty space in the column.
                for rowNum in 0...numRows where getNthChar(gameGrid[chosenColumn], rowNum) == " " {
                    // Place the user's marker in the empty space.
                    var column = gameGrid[chosenColumn]
                    column = column.prefix(rowNum) + userMarker + column.suffix(numRows - rowNum - 1)
                    gameGrid[chosenColumn] = column
                    break
                }
                // Increment the turn number.
                turnNumber += 1
            }
        } else {
            // If the input isn't an integer, give an error message [IN RED]
            print("\u{001B}[0;31mERROR: INPUT MUST BE AN INTEGER.")
            continue
        }
    } else {
        // AI TURN
        // Get a list of unfilled columns.
        let unfilledColumns = getUnfilledColumns()
        // Pick a random column from the list of unfilled columns.
        let chosenColumn = unfilledColumns.randomElement() ?? 0
        // Place the ai's marker in the chosen column.
        // Find the lowest empty space in the column.
        for rowNum in 0...numRows where getNthChar(gameGrid[chosenColumn], rowNum) == " " {
            // Place the ai's marker in the empty space.
            var column = gameGrid[chosenColumn]
            column = column.prefix(rowNum) + aiMarker + column.suffix(numRows - rowNum - 1)
            gameGrid[chosenColumn] = column
            break
        }
        // Print the ai's chosen column.
        print("\(aiColor)AI chose column \(chosenColumn + 1)\(resetColor)")
        // Increment the turn number.
        turnNumber += 1
    }
    // Check if the user has won.
    if checkForWin(userMarker) {
        break
    }
    // Check if the AI has won.
    if checkForWin(aiMarker) {
        break
    }
}

// Display the game grid one last time.
displayGameGrid()

// Check if the user has won.
if checkForWin(userMarker) {
    // WINNING MESSAGE [IN YELLOW]
    print("\u{001B}[33mYOU WIN! CONGRATULATIONS!")
} else if checkForWin(aiMarker) {
     // LOSING MESSAGE [IN RED]
    print("\u{001B}[31mAI WINS! BETTER LUCK NEXT TIME!")
} else {
    // TIE MESSAGE
    print("IT'S A TIE! NO ONE WINS!")
}
