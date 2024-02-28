import SwiftUI

struct MenuTopHalfView: View {
    @ObservedObject var viewModel : MenuViewModel
    
    var body: some View {
        VStack {
            appTitle
            
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    cubesView
                    
                    rankView
                    
                    // TODO: Add the stats view here
                    rankView
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.center)
            .scrollClipDisabled()
        }
        .padding(.top)
    }
}

// MARK: - App Title
private extension MenuTopHalfView {
    var appTitle : some View {
        Text("app_title".localizedString)
            .font(.largeTitle)
            .fontWeight(.black)
            .fontDesign(.rounded)
            .foregroundStyle(.white)
        
    }
}

// MARK: - Cubes View
private extension MenuTopHalfView {
    var cubesView : some View {
        PlayerCubesView(viewModel: self.viewModel)
            .withMenuScrollViewAnimation()
    }
}

// MARK: - Rank View
private extension MenuTopHalfView {
    var rankView : some View {
        UserProgressView(viewModel: self.viewModel)
            .frame(maxHeight: .infinity)
            .withMenuScrollViewAnimation()
    }
}
