import Foundation

class CubesManager {
    @Published var cubes : [PlayerCube] = []
    @Published var selectedCube : PlayerCube = PlayerCube(color: .white,
                                                          animation: .basic,
                                                          requiredHighScore: .zero,
                                                          isUnlocked: false,
                                                          isSelected: false)
    
    // Dependencies
    let gameCenterManager : GameCenterManager
    
    init(gameCenterManager : GameCenterManager) {
        self.gameCenterManager = gameCenterManager
        self.setUpCubes()
        self.setSelectedCube()
    }
}

// MARK: - Cubes Setup
private extension CubesManager {
    func setUpCubes() {
        // High score
        let highScore = UserDefaults.standard.value(forKey: Constants.UserDefaults.highScore) as? Int ?? 0
        // Saved selected cube ID
        let savedSelectedCubeId = UserDefaults.standard.value(forKey: Constants.UserDefaults.selectedCubeId) as? String ?? ""
        // Set the cube values
        self.cubes = Constants.PlayerCubeValues.playerCubeOptions.map { cube in
            return PlayerCube(color: cube.color,
                              animation: cube.animation,
                              requiredHighScore: cube.requiredHighScore,
                              isUnlocked: (highScore >= cube.requiredHighScore),
                              isSelected: (savedSelectedCubeId == cube.id))
        }        
    }
}

// MARK: - Unlock cube
extension CubesManager {
    func unlockCubes(_ highScore : Int) {
        self.cubes = self.cubes.map { cube in
            return PlayerCube(color: cube.color,
                              animation: cube.animation,
                              requiredHighScore: cube.requiredHighScore,
                              isUnlocked: (highScore >= cube.requiredHighScore),
                              isSelected: cube.isSelected)
        }
    }
}

// MARK: - Selected cube
extension CubesManager {
    private func setSelectedCube() {
        let savedSelectedCube = self.cubes.first(where: { $0.isSelected })
        guard let savedSelectedCube = savedSelectedCube else {
            guard let firstCube = Constants.PlayerCubeValues.playerCubeOptions.first else { return }
            self.selectedCube = firstCube
            return
        }
        self.selectedCube = savedSelectedCube
    }
    
    func saveSelectedCube(_ id : String) {
        self.cubes = self.cubes.map { cube in
            return PlayerCube(color: cube.color,
                              animation: cube.animation,
                              requiredHighScore: cube.requiredHighScore,
                              isUnlocked: cube.isUnlocked,
                              isSelected: (id == cube.id))
        }
        self.setSelectedCube()
        UserDefaults.standard.setValue(id, forKey: Constants.UserDefaults.selectedCubeId)
    }
}
