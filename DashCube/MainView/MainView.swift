import SwiftUI

struct MainView: View {
    @StateObject private var viewModel : MainViewModel
    @StateObject private var menuViewModel : MenuViewModel
    @Namespace private var namespace
    
    init(_ gameManager : GameManager,
         _ cubesManager: CubesManager,
         _ gameCenterManager : GameCenterManager,
         _ statsManager : StatsManager) {
        self._viewModel = StateObject(wrappedValue: MainViewModel(gameManager: gameManager))
        self._menuViewModel = StateObject(wrappedValue: MenuViewModel(gameManager,
                                                                      cubesManager,
                                                                      gameCenterManager,
                                                                      statsManager))
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            gameView
                .blur(radius: (viewModel.gameState == .playing) ? 0 : 7.5)
            
            VStack {
                switch viewModel.gameState {
                case .menu:
                    menuTopHalf
                case .over(timerEnded: true), .over(timerEnded: false):
                    gameOverView
                default:
                    EmptyView()
                }
                
                // This allows us to animate the bottom half of the menu, independently of the top half
                if viewModel.gameState == .menu {
                    menuBottomHalf
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(Color.customBackground)
    }
}

// MARK: - Game View
private extension MainView {
    var gameView : some View {
        GameView(gameManager: viewModel.gameManager,
                 cubesManager: menuViewModel.cubesManager,
                 gameCenterManager: menuViewModel.gameCenterManager,
                 namespace: namespace,
                 mainGameState: $viewModel.gameState)
    }
}

// MARK: - Menu - Top Half
private extension MainView {
    var menuTopHalf : some View {
        MenuTopHalfView(viewModel: self.menuViewModel)
            .matchedGeometryEffect(id: Constants.GeometryEffectName.card, in: namespace)
    }
}

// MARK: - Menu - Bottom Half
private extension MainView {
    var menuBottomHalf : some View {
        MenuBottomHalfView(viewModel: self.menuViewModel)            
    }
}

// MARK: - Game Over UI
private extension MainView {
    var gameOverView : some View {
        GameOverView(viewModel: menuViewModel)
            .matchedGeometryEffect(id: Constants.GeometryEffectName.card, in: namespace)
    }
}
