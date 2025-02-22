//
//  ContentView.swift
//  Dice_Game
//
//  Created by Nishanth Vaidya on 11/02/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DiceViewModel()
    @State private var showingRules = false
    @State private var showAboutUs = false
    @State private var showExitAlert = false
    @State private var linkToOpen: URL?

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                Color.orange.ignoresSafeArea(.all)

                if isLandscape {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            TitleView(geometry: geometry)
                                .layoutPriority(1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            BettingTextView(geometry: geometry)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // ✅ Move SliderView below betting text in landscape mode
                            SliderView(viewModel: viewModel, geometry: geometry)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: geometry.size.width * 0.4)

                        VStack(spacing: 10) {
                            DiceImageView(viewModel: viewModel, geometry: geometry)
                                .frame(width: min(geometry.size.width * 0.3, 200), height: min(geometry.size.height * 0.6, 200))
                                .clipped()

                            StartButtonView(geometry: geometry, viewModel: viewModel)
                                .frame(maxWidth: .infinity)

                            BottomButtonsView(geometry: geometry, showingRules: $showingRules, showAboutUs: $showAboutUs, showExitAlert: $showExitAlert, linkToOpen: $linkToOpen)
                        }
                        .frame(maxWidth: geometry.size.width * 0.5)
                    }
                    .padding(.horizontal, 10)
                } else {
                    VStack(spacing: 10) {
                        TitleView(geometry: geometry)
                        BettingTextView(geometry: geometry)
                        SliderView(viewModel: viewModel, geometry: geometry) // ✅ Stays in original position for portrait mode
                        DiceImageView(viewModel: viewModel, geometry: geometry)
                        StartButtonView(geometry: geometry, viewModel: viewModel)
                        BottomButtonsView(geometry: geometry, showingRules: $showingRules, showAboutUs: $showAboutUs, showExitAlert: $showExitAlert, linkToOpen: $linkToOpen)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.easeInOut, value: isLandscape)
        }
        .fullScreenCover(isPresented: $showingRules) {
            RulesView()
        }
        .ignoresSafeArea()
    }
}






#Preview {
    ContentView()
}


struct TitleView: View {
    let geometry: GeometryProxy

    var body: some View {
        Text("A DICEY SITUATION!!")
            .font(.system(size: 28))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 5)
                    .fill(Color.orange)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .frame(width: geometry.size.width * 0.9)
    }
}




struct SliderView: View {
    @ObservedObject var viewModel: DiceViewModel
    let geometry: GeometryProxy

    var body: some View {
        ZStack {
            // Background
           
            // Slider Track
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
                .frame(width: 200, height: 10)
                .offset(y: -5)

            // Slider Thumb
            Circle()
                .fill(Color.white)
                .frame(width: 30, height: 30)
                .offset(x: CGFloat(viewModel.sliderValue / 100 * 200 - 100), y: -5)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newValue = min(max(0, value.location.x / 200 * 100), 100)
                            viewModel.sliderValue = newValue
                        }
                )

            // Value Label
            Text("\(Int(viewModel.sliderValue)) $")
                .foregroundColor(.orange)
                .fontWeight(.bold)
                .padding(6)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(y: 20)
                .frame(width: geometry.size.width * 0.9)

        }
        .frame(width: geometry.size.width * 0.9)
        .padding(.bottom, 20)
    }
}


struct BettingTextView : View{
    let geometry: GeometryProxy

    var body: some View {
        Text("How much will you bet today?")
            .font(.system(size: 21))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: geometry.size.width * 0.9)
            .padding(.top, 20)
    }
}

struct DiceImageView: View {
    @ObservedObject var viewModel: DiceViewModel
    let geometry: GeometryProxy

    var body: some View {
        let isLandscape = geometry.size.width > geometry.size.height
        let diceSize = isLandscape ? geometry.size.width / 10 : geometry.size.width / 4  // ✅ Scale down in landscape

        VStack(spacing: isLandscape ? 10 : 20) { // ✅ Reduce spacing in landscape
            HStack(spacing: isLandscape ? 10 : 20) {
                DiceImage(imageName: "Dice\(viewModel.openingDice[0])", size: diceSize)
                DiceImage(imageName: "Dice\(viewModel.openingDice[1])", size: diceSize)
            }

            HStack(spacing: isLandscape ? 10 : 20) {
                DiceImage(imageName: "Dice\(viewModel.openingDice[2])", size: diceSize)
                DiceImage(imageName: "Dice\(viewModel.openingDice[3])", size: diceSize)
            }
        }
    }
}

struct DiceImage: View {
    let imageName: String
    let size: CGFloat // ✅ Pass dynamic size

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size) // ✅ Dynamic sizing
            .animation(.easeInOut, value: imageName)
    }
}





struct StartButtonView: View {
    let geometry: GeometryProxy
    @ObservedObject var viewModel: DiceViewModel

    var body: some View {
        Button(action: {
            viewModel.showPlayerInput = true // Show the player name input modal
        }) {
            Text("Start!")
                .font(.system(size: 35))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(width: geometry.size.width * 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .stroke(Color.white, lineWidth: 1)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $viewModel.showPlayerInput) {
            PlayerInputView(viewModel: viewModel)
        }

        .fullScreenCover(isPresented: $viewModel.navigateToGame) {
            GameView(viewModel: viewModel)
        }
    }
}




struct BottomButtonsView: View {
    let geometry: GeometryProxy
    @Binding var showingRules: Bool
    @Binding var showAboutUs: Bool
    @Binding var showExitAlert: Bool
    @Binding var linkToOpen: URL?

    var body: some View {
        HStack {
            // Left Button
            Button(action: {
                showingRules = true
            }) {
                Text("Rules for the game")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 5)
                            .fill(Color.orange)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 1, y: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            // Right Button
            Button(action: {
                showAboutUs = true
            }) {
                Text("About Us")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 5)
                            .fill(Color.orange)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 1, y: 1)
                    )
            }
            .fullScreenCover(isPresented: $showAboutUs) {
                AboutUsView(showExitAlert: $showExitAlert, linkToOpen: $linkToOpen)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
    }
}

struct AboutUsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showExitAlert: Bool
    @Binding var linkToOpen: URL?

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                Color.orange.ignoresSafeArea()

                VStack(spacing: isLandscape ? 10 : 20) { // ✅ Reduce spacing in landscape
                    Text("Nishanth Vaidya")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, isLandscape ? 75 : 20) // ✅ Reduce top padding in landscape

                    Image("Profile Photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: isLandscape ? 120 : 220, height: isLandscape ? 140 : 200) // ✅ Smaller in landscape
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .shadow(radius: 5)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) { // ✅ Reduce spacing in landscape
                            // 📌 Education Section
                            Text("📍 **Education**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("• **M.S. in Computer Engineering**, Syracuse University (2024-2026)")
                            Text("• **B.E. in Computer Science**, Sambhram Institute of Technology (2016-2020)")

                            // 🛠 Summary Section
                            Text("🛠 **Summary**")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("I am a software engineer with experience at Deloitte, Oracle, and Tech Mahindra, specializing in AI-driven solutions and cloud computing. Proficient in Python, C++, JavaScript, and SQL, I have developed scalable applications using technologies like React.js, Node.js, and AWS. Passionate about innovation, I thrive in solving complex problems and optimizing systems for efficiency.")

                            // 🔗 Links Section
                            Text("🔗 **Links**")
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack(spacing: 5) { // ✅ Reduce spacing in landscape
                                LinkButton(title: "LinkedIn", url: "https://www.linkedin.com/in/nv2/", showExitAlert: $showExitAlert, linkToOpen: $linkToOpen)
                                LinkButton(title: "Portfolio", url: "https://www.nishanthvaidya.com/", showExitAlert: $showExitAlert, linkToOpen: $linkToOpen)
                                LinkButton(title: "GitHub", url: "https://github.com/NishanthVaidya", showExitAlert: $showExitAlert, linkToOpen: $linkToOpen)
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading) // ✅ Ensures proper alignment
                    }
                    .frame(height: isLandscape ? geometry.size.height * 0.30 : nil) // ✅ Restrict height in landscape

                    // Back to Game Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back to Game")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue)
                                    .stroke(Color.white, lineWidth: 2)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                    }
                    .padding(.bottom, isLandscape ? 45 : 20) // ✅ Reduce bottom padding in landscape
                }
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .alert(isPresented: $showExitAlert) {
            Alert(
                title: Text("Leaving the Game"),
                message: Text("You are about to leave the game to visit an external site."),
                primaryButton: .default(Text("Continue"), action: {
                    if let url = linkToOpen {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel(Text("Stay Here"))
            )
        }
    }
}



struct LinkButton: View {
    let title: String
    let url: String
    @Binding var showExitAlert: Bool
    @Binding var linkToOpen: URL?

    var body: some View {
        Button(action: {
            linkToOpen = URL(string: url)
            showExitAlert = true
        }) {
            Text(title)
                .foregroundColor(.white)
                .font(.body)
                .underline()
        }
    }
}


struct RulesView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.orange.ignoresSafeArea(.all)

                VStack {
                    Text("Rules of the Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                    VStack(alignment: .leading, spacing: 18) {
                        Text("1. This is a two-player dice-based BlackJack game.")
                        Text("2. Before rolling the dice, players place bets using the slider.")
                        Text("3. Each player can roll a minimum of 2 and a maximum of 4 dice.")
                        Text("4. The goal is to get as close to 16 as possible without going over (busting).")
                        Text("5. The player closest to 16 wins.")
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back to Game")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height) // ✅ Full screen coverage
        }
    }
}





struct PlayerInputView: View {
    @ObservedObject var viewModel: DiceViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.orange
                .edgesIgnoringSafeArea(.all) // Ensures full coverage, including the notch area
                .ignoresSafeArea() // ✅ Ensures full-screen coverage, including the notch area

            VStack(spacing: 20) {
                Text("Enter Player Names")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                VStack(spacing: 15) {
                    TextField("Player 1 Name", text: $viewModel.player1Name)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 5)
                                .fill(Color.orange)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 1, y: 1)
                        )

                    TextField("Player 2 Name", text: $viewModel.player2Name)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 5)
                                .fill(Color.orange)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 1, y: 1)
                        )
                }
                .padding(.horizontal, 30)

                Button(action: {
                    if viewModel.player1Name.trimmingCharacters(in: .whitespaces).isEmpty {
                        viewModel.player1Name = "Player 1"
                    }
                    if viewModel.player2Name.trimmingCharacters(in: .whitespaces).isEmpty {
                        viewModel.player2Name = "Player 2"
                    }
                    viewModel.currentPlayer = viewModel.player1Name
                    viewModel.showPlayerInput = false // Dismiss the sheet
                    viewModel.navigateToGame = true // Start game
                }) {
                    Text("Start Game")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                                .fill(Color.blue)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                }
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures full coverage
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all) // Ensures full-screen coverage
    }
    
}


struct GameView: View {
    @ObservedObject var viewModel: DiceViewModel
    @State private var showEndRoundAlert = false

    var body: some View {
        ScrollView{
            Color.orange.ignoresSafeArea(.all)
            ZStack {
                Color.orange.ignoresSafeArea(.all)
                
                VStack(spacing: 30) {
                    
                    // 🎲 Player 1 UI
                    VStack {
                        Text("\(viewModel.player1Name)'s Turn")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        DiceRollingView(diceValues: viewModel.player1Dice, rolling: viewModel.player1RollingDice)
                        
                        Text("Total: \(viewModel.player1Total)")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        if viewModel.currentPlayer == viewModel.player1Name && !viewModel.gameOver {
                            Button(action: { viewModel.rollDice() }) {
                                Text("Roll Dice")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white, lineWidth: 2)
                                            .fill(Color.blue)
                                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    )
                            }
                            
                        }
                    }
                    
                    .opacity(viewModel.currentPlayer == viewModel.player1Name ? 1 : 0.5)
                    
                    Spacer()
                    
                    // 🎲 Player 2 UI
                    VStack {
                        Text("\(viewModel.player2Name)'s Turn")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        DiceRollingView(diceValues: viewModel.player2Dice, rolling: viewModel.player2RollingDice)
                        
                        Text("Total: \(viewModel.player2Total)")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        if viewModel.currentPlayer == viewModel.player2Name && !viewModel.gameOver {
                            
                            // ✅ Show "Roll Dice" button ONLY IF player has rolled less than 2 times AND extra roll buttons are not shown
                            if viewModel.player2TotalRolls < 2 || (viewModel.player2TotalRolls <= 4 && viewModel.player1TotalRolls != 2 && viewModel.player1TotalRolls != 4)
                            {
                                Button(action: { viewModel.rollDice()
                                    if(viewModel.player2TotalRolls > 3){
                                        viewModel.gameOver = true
                                        viewModel.determineWinner()
                                    }}) {
                                        Text("Roll Dice")
                                            .font(.system(size: 25))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .fill(Color.blue)
                                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                            )
                                    }
                            }
                            
                            // ✅ Show "Play Another Round?" and "Stop Playing" buttons only after both players have rolled twice
                            else if viewModel.player2TotalRolls == 2 && (viewModel.player1TotalRolls == 2 || viewModel.player1TotalRolls == 4) {
                                HStack {
                                    // "Play Another Round?" Button
                                    Button(action: {
                                        if viewModel.player1TotalRolls == 4 {
                                            viewModel.player1TotalRolls += 1
                                        }
                                        viewModel.wantsExtraRoll = true
                                        viewModel.resetPlayer()
                                    }) {
                                        Text("Play Another Round?")
                                            .font(.system(size: 16))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .fill(Color.orange)
                                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                            )
                                    }
                                    
                                    // "Stop Playing" Button
                                    // Player 1 - Stop button appears only after rolling at least twice
                                    if viewModel.player1TotalRolls <= 2 {
                                        Button(action: {
                                            if(viewModel.player1Total < viewModel.player2Total){
                                                viewModel.gameOver = true
                                            }
                                            viewModel.determineWinner() }) {
                                                Text("Stop Playing")
                                                    .font(.system(size: 16))
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                    .padding()
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white, lineWidth: 2)
                                                            .fill(Color.blue)
                                                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                                    )
                                            }
                                    }
                                    
                                    // Player 2 - Stop button appears only after Player 1 stops
                                    if viewModel.player1TotalRolls >= 3 && !viewModel.gameOver {
                                        Button(action: { viewModel.player2StopsPlaying()
                                            viewModel.determineWinner()
                                        }
                                        ) {
                                            Text("Stop Playing")
                                                .font(.system(size: 16))
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white, lineWidth: 2)
                                                        .fill(Color.blue)
                                                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                                )
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    
                    .opacity(viewModel.currentPlayer == viewModel.player2Name ? 1 : 0.5)
                    
                    // 🏆 End Game Buttons
                    VStack {
                        // 🔹 Display Player Money
                        HStack {
                            VStack {
                                Text("\(viewModel.player1Name)'s Money: $\(viewModel.player1TotalMoney)")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            
                            VStack {
                                Text("\(viewModel.player2Name)'s Money: $\(viewModel.player2TotalMoney)")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        HStack{
                            
                            VStack {
                                Text(" Total Rounds: \(viewModel.totalRounds)")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        
                        // 🔹 Betting Slider to Add More Money
                        VStack {
                            Text("💰 Adjust Your Bet")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 10)
                            
                            Slider(value: $viewModel.sliderValue, in: 0...100, step: 5)
                                .padding(.horizontal, 40)
                                .accentColor(.yellow)
                            
                            Text("Bet Amount: $\(Int(viewModel.sliderValue))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.2))
                                .padding(.horizontal, 20)
                        )
                    }
                    
                    if viewModel.gameOver || (viewModel.player2TotalRolls >= 4 && viewModel.player1TotalRolls >= 4) {
                        Button(action: {
                            showEndRoundAlert = true
                        }) {
                            Text("View Results")
                                .font(.title)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .alert(isPresented: $showEndRoundAlert) {
                Alert(
                    title: Text("Game Over")
                        .font(.headline)
                        .foregroundColor(.white), // This won't change the actual Alert's title color
                    message: Text(viewModel.winner)
                        .font(.body)
                        .foregroundColor(.white), // This also won't affect Alert's message text
                    primaryButton: .default(
                        Text("Play Again")
                            .fontWeight(.bold)
                            .foregroundColor(.white), // This will change the button text color
                        action: {
                            viewModel.resetGame()
                            showEndRoundAlert = false
                        }
                    ),
                    secondaryButton: .destructive(
                        Text("Exit to Main Menu")
                            .fontWeight(.bold)
                            .foregroundColor(.orange), // This will change the button text color
                        action: {
                            viewModel.navigateToGame = false
                        }
                    )
                )
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures full-screen coverage
        }  //.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.orange.ignoresSafeArea()) // 🔥 Fix: Background applies to entire screen

    }
}


struct DiceRollingView: View {
    let diceValues: [Int]  // Array storing the values of rolled dice
    let rolling: [Bool]    // Array storing which dice are currently rolling (for animation)

    var body: some View {
        HStack {
            ForEach(0..<4, id: \.self) { index in
                Image("Dice\(diceValues[index])")  // Selects the correct dice image
                    .resizable()
                    .frame(width: 80, height: 80)
                    .opacity(rolling[index] ? 0.5 : 1.0)  // Dim dice while rolling
                    .animation(.easeInOut, value: diceValues[index])  // Smooth animation
            }
        }
    }
}

