import SwiftUI
import Combine

class DiceViewModel: ObservableObject {
    @Published var player1Dice = [1, 1, 1, 1]
    @Published var openingDice = [1, 3, 4, 6]
    @Published var player2Dice = [1, 1, 1, 1]
    @Published var player1RollingDice = [false, false, false, false]
    @Published var player2RollingDice = [false, false, false, false]

    @Published var player1Total = 0
    @Published var player2Total = 0
    @Published var player1TotalRolls = 0
    @Published var player2TotalRolls = 0
    @Published var currentPlayer = ""
    @Published var gameOver = false
    @Published var winner = ""
    @Published var totalRounds = 0
    @Published var player1TotalMoney = 0
    @Published var player2TotalMoney = 0
    @Published var sliderValue: Double = 0
    @Published var player1Name: String = ""
    @Published var player2Name: String = ""
    @Published var showPlayerInput: Bool = false
    @Published var navigateToGame: Bool = false
    @Published var showRollAgainPrompt: Bool = false
    @Published var wantsToRollAgain: Bool = false
    @Published var wantsExtraRoll: Bool = false
    @Published var player1WantsExtraRoll = false
    @Published var player2WantsExtraRoll = false
    @Published var Player1Money: Double = 0
    @Published var Player2Money: Double = 0
    // 🔥 NEW FLAGS to track if players finalized their roll
    @Published var player1Finalized = false
    @Published var player2Finalized = false
    @Published var showAboutUs = false
    init() {
        currentPlayer = player1Name
    }

    
    
    func rollDie() -> Int {
        return Int.random(in: 1...6)
    }

    func rollDice() {
        let isPlayer1Turn = currentPlayer == player1Name
        
        // If player has already finalized, they cannot roll
        if gameOver { return }
        if (isPlayer1Turn && player1Finalized) || (!isPlayer1Turn && player2Finalized) {
            return
        }
        
        if isPlayer1Turn {
            if player1TotalRolls >= 4 { return }
        } else {
            if player2TotalRolls >= 4 { return }
        }
        
        // Determine which dice should roll
        let diceToRoll = isPlayer1Turn ? player1TotalRolls : player2TotalRolls
        if diceToRoll >= 2 && wantsExtraRoll == false { return } // Max 2 rounds of rolling
        if diceToRoll >= 4 && wantsExtraRoll == true { return } // Max 2 rounds of rolling

        // Determine which dice should roll
        var diceIndexes: [Int] = []

        if isPlayer1Turn {
            if player1TotalRolls == 0 {
                diceIndexes = [0]  // Roll first die
            } else if player1TotalRolls == 1 {
                diceIndexes = [1]  // Roll second die
            } else if player1TotalRolls == 2 {
                diceIndexes = [2]  // Roll third die (if extra roll allowed)
            } else if player1TotalRolls == 3 {
                diceIndexes = [3]  // Roll fourth die (if extra roll allowed)
            }
        } else {
            if player2TotalRolls == 0 {
                diceIndexes = [0]
            } else if player2TotalRolls == 1 {
                diceIndexes = [1]
            } else if player2TotalRolls == 2 {
                diceIndexes = [2]
            } else if player2TotalRolls == 3 {
                diceIndexes = [3]
            }
        }

        
        var timerCount = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                for index in diceIndexes {
                    let newRoll = self.rollDie()
                    if isPlayer1Turn {
                        self.player1Dice[index] = newRoll
                        self.player1RollingDice[index] = true
                    } else {
                        self.player2Dice[index] = newRoll
                        self.player2RollingDice[index] = true

                    }
                }
            }
            timerCount += 1
            
            if timerCount >= 20 {
                timer.invalidate()
                DispatchQueue.main.async {

                    self.applyDiceRoll()
                }
            }
        }
    }

    func applyDiceRoll() {
        if currentPlayer == player1Name {
            //print("Before Update - Player 1 Total: \(player1Total)")
            player1Total += player1Dice[player1TotalRolls] // Sum all dice values
            player1TotalRolls += 1
            //print("After Update - Player 1 Total: \(player1Total)")
        } else {
           // print("Before Update - Player 2 Total: \(player2Total)")
            player2Total += player2Dice[player2TotalRolls] // Sum all dice values
            player2TotalRolls += 1
           // print("After Update - Player 2 Total: \(player2Total)")
        }
               checkGameState()

    }
    func resetPlayer(){
        if(player1TotalRolls<3){
            currentPlayer = player1Name
        }else{
            currentPlayer = player2Name
        }
    }

    func wantsExtraRoll(_ decision: Bool) {
        if currentPlayer == player1Name {
            player1WantsExtraRoll = decision
        } else {
            player2WantsExtraRoll = decision
        }

        // ✅ If the player wants an extra roll and hasn't reached 4 rolls, allow them to continue
        if decision {
            if currentPlayer == player1Name && player1TotalRolls < 4 {
                rollDice()
                return  // 🔥 Prevents further execution to avoid skipping Player 2's turn
            } else if currentPlayer == player2Name && player2TotalRolls < 4 {
                rollDice()
                return
            }
        }

        // ✅ If the current player stops, check if the other player still wants to roll
        if currentPlayer == player1Name {
            if !decision && player2TotalRolls < 4 {
                currentPlayer = player2Name  // ✅ Switch to Player 2 so they can continue
                return
            }
        }

        // ✅ Only end the game if **both players have stopped** OR **both players reached 4 rolls**
        if(!player2WantsExtraRoll || player2TotalRolls == 4) {
            determineWinner()
        }
    }
    func player1StopsPlaying() {
        if player1Total < player2Total {
            // ✅ Player 2 already has a higher score → Auto Win
            determineWinner()
        } else {
            // ✅ Player 2 is behind → Give them a chance to roll again
            showRollAgainPrompt = true
            determineWinner()
        }
    }



    func player2StopsPlaying() {
        determineWinner()
    }




    func checkGameState() {
        if player1TotalRolls == 4 && player2TotalRolls == 4 {
            determineWinner()  // ✅ Make sure the winner is determined
            gameOver = true     // ✅ Set gameOver to true
            return
        }

        if currentPlayer == player1Name {
            if player1Total > 16 {
                winner = "\(player2Name) Wins! \(player1Name) Busted!"
                gameOver = true
                return
            }

            if player1TotalRolls == 2 && player2TotalRolls < 2 {
                currentPlayer = player2Name
            }

            if player1TotalRolls == 2 && player2TotalRolls == 2 {
                currentPlayer = player1Name
                showRollAgainPrompt = true
                return
            }

            if player1TotalRolls >= 4 {
                currentPlayer = player2Name
            }

        } else { // Player 2's turn
            if player2Total > 16 {
                winner = "\(player1Name) Wins! \(player2Name) Busted!"
                gameOver = true
                return
            }

            if player2TotalRolls == 2 {
                showRollAgainPrompt = true
                return
            }

            if player2TotalRolls >= 4 {
                determineWinner()  // ✅ Make sure the game ends if both players rolled 4 times
                gameOver = true
            }
        }
    }





    func finalizeTurn() {
        if currentPlayer == player1Name {
            player1Finalized = true
            currentPlayer = player2Name // Switch turn
        } else {
            player2Finalized = true
        }

        if player1Finalized && player2Finalized {
            determineWinner()
        }
    }

    func determineWinner() {
        if player1Total > 16 {
            winner = "\(player2Name) Wins! \(player1Name) Busted!"
            updateScores()
        } else if player2Total > 16 {
            winner = "\(player1Name) Wins! \(player2Name) Busted!"
            updateScores()
        } else if player1Total == player2Total {
            winner = "It's a Tie!"
        } else if abs(16 - player1Total) < abs(16 - player2Total) {
            winner = "\(player1Name) Wins!"
           // Player1Money += sliderValue

        } else {
            winner = "\(player2Name) Wins!"
          //  Player2Money += sliderValue

        }

        gameOver = true
        updateScores()
    }

    func updateScores() {
        totalRounds += 1

        if winner.contains(player1Name) {
            player1TotalMoney += Int(sliderValue)
            player2TotalMoney -= Int(sliderValue)
        } else if winner.contains(player2Name) {
            player2TotalMoney += Int(sliderValue)
            player1TotalMoney -= Int(sliderValue)
        }
            return
    }

    func resetGame() {
        player1TotalRolls = 0
        player2TotalRolls = 0
        player1Total = 0
        player2Total = 0
        currentPlayer = player1Name
        gameOver = false
        winner = ""
        player1Dice = [1, 1, 1, 1]
        player2Dice = [1, 1, 1, 1]
        player1Finalized = false
        player2Finalized = false
        sliderValue = 0
    }
    
}
