import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel : MenuViewModel
    @State private var isGameCenterPresented = false
    let namespace : Namespace.ID
    
    var body: some View {
        content
            .sheet(isPresented: $isGameCenterPresented) {
                GameCenterView(leaderboardID: Constants.GameCenter.classicLeaderboard)
            }
    }
}

// MARK: - Content
private extension MenuView {
    var content : some View {
        mainMenu
            .onAppear {
                self.viewModel.fetchOverallRank()
            }
    }
}

// MARK: - Main Menu
private extension MenuView {
    var mainMenu : some View {
        VStack {
            VStack {
                appTitle
                    .padding(.top, 25)
                scoreAndRank
            }
            VStack {
                playerCubesView
                playButton
            }
            .withCardStyle(outerPadding: Constants.UI.outerMenuPadding)
        }
    }
}

// MARK: - App Title
private extension MenuView {
    var appTitle : some View {
        Text("app_title".localizedString)
            .font(.largeTitle)
            .fontWeight(.black)
            .fontDesign(.rounded)
            .foregroundStyle(.white)
        
    }
}

// MARK: - Values
private extension MenuView {
    var scoreAndRank : some View {
        VStack(spacing: 5) {
            // High Score
            row("high_score".localizedString, viewModel.highscore)
            // Overall Rank
            row("overall_rank".localizedString, viewModel.overallRank, true)
            // Leaderboard button
            showLeaderboardButton
        }
        .withCardStyle(outerPadding: Constants.UI.outerMenuPadding)
        .matchedGeometryEffect(id: Constants.GeometryEffectName.card, in: namespace)
    }
    
    func row(_ title : String, _ value : Int?, _ isRank : Bool = false) -> some View {
        HStack(spacing: 7.5) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
            HStack(spacing: 5) {
                Group {
                    if let value {
                        Text("\(isRank ? "#" : "")\(value)")
                    } else {
                        Text("-")
                    }
                }
                .font(.title)
                .fontWeight(.light)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                
                if isRank, value == 1 {
                    Image(systemName: "trophy")
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
}

// MARK: - Play game button
private extension MenuView {
    var playButton : some View {
        CustomButton(title: "play_button_title".localizedString) {
            self.viewModel.startGame()
        }
        .padding(.top, 20)
    }
}

// MARK: - Player Cubes
private extension MenuView {
    var playerCubesView : some View {
        PlayerCubesView(viewModel: viewModel)
            .padding(.top, 20)
        
    }
}

// MARK: - Game Center Button
private extension MenuView {
    var showLeaderboardButton : some View {
        Button {
            self.isGameCenterPresented.toggle()
        } label: {
            Text("view_leaderboard".localizedString)
                .font(.title3)
                .fontWeight(.light)
                .foregroundStyle(.white)
                .padding(2.5)
                .overlay(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Color.customAqua, Color.customStrawberry]), startPoint: .leading, endPoint: .trailing)
                        .frame(height: 1.5, alignment: .bottom)
                        .clipShape(.rect(cornerRadius: 8))
                }
        }
    }
}
