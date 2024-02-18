import Foundation
import GameKit
import Combine

class GameCenterManager {
    @Published private(set) var isGameCenterEnabled : Bool = false
    @Published private(set) var highScore : Int = .zero
    @Published private(set) var rank : Int = .zero
    private var leaderboards : [GKLeaderboard] = []
        
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.addSubscriptions()
        self.authenticateUser()
    }
    
    func addSubscriptions() {
        subscribeToGameCenterEnabled()
    }
}

// MARK: - Subscribers
private extension GameCenterManager {
    func subscribeToGameCenterEnabled() {
        self.$isGameCenterEnabled
            .dropFirst()
            .sink { [weak self] newIsGameCenterEnabled in
                guard let self else { return }
                guard newIsGameCenterEnabled else {
                    self.highScore = self.getHighScoreFromAppStorage()
                    return
                }
                self.getLeaderboards()
                self.getClassicHighScore()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Load all leaderboards
private extension GameCenterManager {
    func getLeaderboards() {
        Task {
            let loadedLeaderbaords = try? await GKLeaderboard.loadLeaderboards(IDs: [Constants.GameCenter.classicLeaderboard])
            guard let loadedLeaderbaords else { return }
            self.leaderboards = loadedLeaderbaords
        }
    }
}

// MARK: - Get classic high score
extension GameCenterManager {
    func getClassicHighScore() {
        let classicLeaderboard = self.leaderboards.first(where: { $0.baseLeaderboardID == Constants.GameCenter.classicLeaderboard })
        guard let classicLeaderboard else {
            self.highScore = self.getHighScoreFromAppStorage()
            print("Classic leaderboard not found")
            return
        }
        self.setSavedHighScore(classicLeaderboard)
    }
}

// MARK: - Get user highscore
extension GameCenterManager {
    func setSavedHighScore(_ leaderboard : GKLeaderboard?) {
        let appStorageHighScore = self.getHighScoreFromAppStorage()
        Task {
            let leaderboardHighScore = await self.getHighScoreFromLeaderboard(leaderboard)
            // Sync the high scores
            self.syncHighScores(appStorageHighScore, leaderboardHighScore)
            
            // Publish the high score
            self.highScore = max(leaderboardHighScore, appStorageHighScore)
        }
    }
    
    // MARK: - Leaderboard High Score
    func getHighScoreFromLeaderboard(_ leaderboard : GKLeaderboard?) async -> Int {
        guard let leaderboard else { return 0 }
        /*
         entries.0 --> Local player leaderboard entry
         entries.1 --> List of player entries
         entries.2 --> Returns the total amount of entries in the leaderboard for the corresponding parameters (playerScope, timeScope, etc...)
         */
        let entries = try? await leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 10))
        return entries?.0?.score ?? 0
    }
    
    // MARK: - App Storage High Score
    func getHighScoreFromAppStorage() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.UserDefaults.highScore)
    }
}

// MARK: - Sync high scores
private extension GameCenterManager {
    func syncHighScores(_ appStorageHighScore : Int, _ leaderboardHighScore : Int) {
        // If player played with no connection, the app storage high score may be higher than the leaderboard score
        if appStorageHighScore > leaderboardHighScore {
            self.saveHighScoreToGameCenterLeaderboard(appStorageHighScore)
        }
        // If it is first launch, the app storage value will be 0, but the game center leaderboard may have a score for this player already
        //So set the leaderboard score in the app storage
        else if leaderboardHighScore > appStorageHighScore {
            self.saveHighScoreToAppStorage(leaderboardHighScore)
        }
    }
}

// MARK: - Save new high score
extension GameCenterManager {
    func saveNewHighScore(_ score : Int) {
        self.highScore = score
        self.saveHighScoreToAppStorage(score)
        self.saveHighScoreToGameCenterLeaderboard(score)
    }
    
    private func saveHighScoreToAppStorage(_ score : Int) {
        UserDefaults.standard.setValue(score, forKey: Constants.UserDefaults.highScore)
    }
    
    private func saveHighScoreToGameCenterLeaderboard(_ score : Int) {
        guard isGameCenterEnabled else { return }
        Task {
            try? await GKLeaderboard.submitScore(score,
                                                 context: 0,
                                                 player: GKLocalPlayer.local,
                                                 leaderboardIDs: [Constants.GameCenter.classicLeaderboard])
            /*
             If the high score couldn't be saved to the game center leaderboard,
             it has been saved to the app storage and can be attempted to be saved
             to the leaderboard again when a new high score has been set
             */
        }
    }
}

// MARK: - Authenticate User
extension GameCenterManager {
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { _, error in
            guard error == nil else {
                // TODO: Handle error case
                print(error?.localizedDescription ?? "")
                self.isGameCenterEnabled = false
                return
            }
            self.isGameCenterEnabled = true
        }
    }
}
