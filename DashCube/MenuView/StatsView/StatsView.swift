import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel : StatsViewModel
    
    init(_ statsManager : StatsManager) {
        self._viewModel = StateObject(wrappedValue: StatsViewModel(statsManager))
    }
    
    var body: some View {
        content
    }
}

// MARK: - Values
private extension StatsView {
    var content : some View {
        VStack {
            title
            Spacer()
            progressValues
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Values
private extension StatsView {
    var title : some View {
        Text("stats_title".localizedString)
            .font(.title)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundStyle(.white)
    }
}

// MARK: - Values
private extension StatsView {
    var progressValues : some View {
        List {
            row("high_score".localizedString, viewModel.highScore)
                .listRowBackground(Color.clear)
            row("games_played".localizedString, viewModel.gamesPlayed)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(Color.clear)
        .listRowInsets(.none)
    }
    
    func row(_ title : String, _ value : Int?) -> some View {
        HStack(spacing: 7.5) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
            
            Spacer()
            
            Group {
                if let value {
                    Text("\(value)")
                } else {
                    Text("-")
                }
            }
            .font(.title)
            .fontWeight(.ultraLight)
            .fontDesign(.rounded)
            .foregroundStyle(.white)
        }
    }
}