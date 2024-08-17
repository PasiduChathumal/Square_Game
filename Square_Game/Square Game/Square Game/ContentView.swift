//
//  ContentView.swift
//  Square Game
//
//  Created by COBSCCOMPY4231P-032 on 2024-08-15.
//

import SwiftUI

enum ColorOption: CaseIterable {
    case red, yellow, blue
}

struct ButtonState: Identifiable {
    let id = UUID()
    var color: ColorOption
}

class GameState: ObservableObject {
    @Published var buttons: [ButtonState] = Array(repeating: ButtonState(color: .red), count: 9)
    @Published var selectedButtons: [Int] = []
    @Published var score: Int = 0
    @Published var gameOver: Bool = false
    @Published var showHighScore: Bool = false
    @Published var showGuide: Bool = false
    @Published var gameStarted: Bool = false
    @Published var highScore: Int = 0
    
    init() {
        resetButtons()
    }
    
    func resetButtons() {
        buttons = buttons.map { _ in ButtonState(color: ColorOption.allCases.randomElement()!) }
    }
    
    func buttonTapped(index: Int) {
        guard !gameOver else { return }
        guard !selectedButtons.contains(index) else { return }
        
        selectedButtons.append(index)
        
        if selectedButtons.count == 2 {
            let firstIndex = selectedButtons[0]
            let secondIndex = selectedButtons[1]
            
            if buttons[firstIndex].color == buttons[secondIndex].color {
                score += 1
                highScore = max(highScore, score)
                // Change colors after clicking both
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.buttons[firstIndex].color = ColorOption.allCases.randomElement()!
                    self.buttons[secondIndex].color = ColorOption.allCases.randomElement()!
                }
            } else {
                // Game over if not matching
                gameOver = true
            }
            
            // Clear selection
            selectedButtons.removeAll()
        }
    }
    
    func restartGame() {
        gameStarted = true
        gameOver = false
        score = 0
        resetButtons()
    }
    
    func startNewGame() {
        gameStarted = true
        gameOver = false
        score = 0
        resetButtons()
    }
    
    func backToMenu() {
        gameStarted = false
        gameOver = false
        selectedButtons.removeAll()
        score = 0
        resetButtons()
    }
}

struct ContentView: View {
    @StateObject private var gameState = GameState()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            Image(systemName: "gamecontroller.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            
            if gameState.gameStarted {
                VStack {
                    Text("Square Game")
                    Text("Score: \(gameState.score)")
                        .font(.largeTitle)
                        .padding()
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(gameState.buttons.indices, id: \.self) { index in
                            Button(action: {
                                gameState.buttonTapped(index: index)
                            }) {
                                Rectangle()
                                    .fill(colorForOption(gameState.buttons[index].color))
                                    .frame(width: 100, height: 100)
                                    .border(Color.black, width: 1)
                                    .cornerRadius(5)
                                    .opacity(gameState.selectedButtons.contains(index) ? 0.5 : 1.0)
                            }
                        }
                    }
                    .padding()
                    
                    if gameState.gameOver {
                        Text("Game Over! Score: \(gameState.score)")
                            .font(.title)
                            .padding()
                        VStack {
                            Button("Restart") {
                                gameState.restartGame()
                            }
                            .padding()
                            
                            Button("Back to Menu") {
                                gameState.backToMenu()
                            }
                            .padding()
                        }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Button("Start") {
                        gameState.startNewGame()
                    }
                    .font(.title2)
                    .padding()
                    
                    Button("High Score") {
                        gameState.showHighScore.toggle()
                    }
                    .font(.title2)
                    .padding()
                    .sheet(isPresented: $gameState.showHighScore) {
                        HighScoreView(highScore: gameState.highScore) {
                            gameState.showHighScore = false
                        }
                    }
                    
                    Button("Guide") {
                        gameState.showGuide.toggle()
                    }
                    .font(.title2)
                    .padding()
                    .sheet(isPresented: $gameState.showGuide) {
                        GuideView {
                            gameState.showGuide = false
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func colorForOption(_ option: ColorOption) -> Color {
        switch option {
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .blue:
            return .blue
        }
    }
}

struct HighScoreView: View {
    let highScore: Int
    let onClose: () -> Void
    
    var body: some View {
        VStack {
            Text("High Score")
                .font(.largeTitle)
                .padding()
            Text("\(highScore)")
                .font(.system(size: 100))
                .bold()
                .padding()
            Spacer()
            Button("Back to Menu") {
                onClose()
            }
            .padding()
        }
    }
}

struct GuideView: View {
    let onClose: () -> Void
    
    var body: some View {
        VStack {
            Text("Guide")
                .font(.largeTitle)
                .padding()
            Text("Match two squares of the same color to increase your score.")
                .font(.title2)
                .padding()
            Text("If you match incorrectly, the game is over!")
                .font(.title3)
                .padding()
            Spacer()
            Button("Back to Menu") {
                onClose()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
