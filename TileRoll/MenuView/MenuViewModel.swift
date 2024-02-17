import Foundation
import Combine
import SwiftUI

class MenuViewModel : ObservableObject {
    @Published private(set) var gameState : GameState = .menu
    @Published private(set) var score : Int = .zero
    @Published private(set) var highScore : Int = .zero
    @Published private(set) var isGameOver : Bool = false
    
    // Player Cube
    @Published var selectedPlayerCube : PlayerCube    
    // Cubelets
    @Published private(set) var totalCubelets : Int = .zero
    // Cubes
    @Published private(set) var cubes : [PlayerCube] = []
    
    // Dependencies
    let gameManager : GameManager
    let cubeletsManager: CubeletsManager
    let cubesManager: CubesManager
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(gameManager: GameManager, cubeletsManager: CubeletsManager, cubesManager: CubesManager) {
        self.gameManager = gameManager
        self.cubeletsManager = cubeletsManager
        self.cubesManager = cubesManager
        self.selectedPlayerCube = gameManager.selectedPlayerCube
        self.addSubscriptions()
        self.selectedPlayerCube = cubesManager.selectedCube
    }
    
    private func addSubscriptions() {
        subscribeToScore()
        subscribeToGameState()
        subscribeToHighScore()
        subscribeToCubes()
        subscribeToSelectedPlayerCube()
        subscribeToTotalCubelets()
    }
}

// MARK: - Subscribers
private extension MenuViewModel {
    func subscribeToScore() {
        self.gameManager.$score
            .sink { [weak self] newScore in
                guard let self else { return }
                self.score = newScore
            }
            .store(in: &cancellables)
    }
    
    func subscribeToGameState() {
        self.gameManager.$gameState
            .sink { [weak self] newGameState in
                guard let self else { return }
                self.gameState = newGameState
                self.isGameOver = ((newGameState == .over(timerEnded: true)) || (newGameState == .over(timerEnded: false)))
            }
            .store(in: &cancellables)
    }
    
    func subscribeToHighScore() {
        self.gameManager.$highScore
            .sink { [weak self] newHighScore in
                guard let self else { return }
                self.highScore = newHighScore
            }
            .store(in: &cancellables)
    }
    
    func subscribeToSelectedPlayerCube() {
        self.$selectedPlayerCube
            .dropFirst()
            .sink { [weak self] newSelectedPlayerCube in
                guard let self else { return }
                self.cubesManager.saveSelectedCubeId(newSelectedPlayerCube.id)
                self.gameManager.setPlayerCube(newSelectedPlayerCube)
            }
            .store(in: &cancellables)
    }
    
    func subscribeToCubes() {
        self.cubesManager.$cubes
            .sink { [weak self] newCubes in
                guard let self else { return }
                self.cubes = newCubes
            }
            .store(in: &cancellables)
    }
    
    func subscribeToTotalCubelets() {
        self.cubeletsManager.$totalCubelets
            .sink { [weak self] newTotalCubelets in
                guard let self else { return }
                self.totalCubelets = newTotalCubelets
            }
            .store(in: &cancellables)
    }
}

// MARK: - Restart game
extension MenuViewModel {
    func startGame() {
        withAnimation {
            self.gameManager.startGame()
        }
    }
}

// MARK: - Return to menu
extension MenuViewModel {
    func returnToMenu() {
        withAnimation {
            self.gameManager.returnToMenu()
        }
    }
}

// MARK: - Unlock player cube
extension MenuViewModel {
    func canUnlockCube(_ playerCube : PlayerCube) -> Bool {
        return (self.totalCubelets >= playerCube.cost)
    }
    
    func unlockPlayerCube(_ playerCube : PlayerCube) {
        self.cubesManager.unlockCube(playerCube)
    }
}
