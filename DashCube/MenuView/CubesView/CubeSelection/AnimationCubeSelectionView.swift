import SwiftUI

struct AnimationCubeSelectionView: View {
    @ObservedObject var viewModel : CubeSelectionViewModel
    private let columns : [GridItem] = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        content
    }
}

private extension AnimationCubeSelectionView {
    var content : some View {
        VStack(alignment: .leading, spacing: 15) {
            title
            grid
        }
    }
    
    var title : some View {
        Text("select_cube_animation".localizedString)
            .font(.title)
            .foregroundStyle(.white)
            .fontDesign(.rounded)
            .fontWeight(.bold)
    }
    
    var grid : some View {
        LazyVGrid(columns: columns) {
            ForEach(viewModel.animationCubes) { animationCube in
                CubeView(basicCube: animationCube)
                    .scaledToFit()
                    .overlay {
                        RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                            .stroke(viewModel.selectedPlayerCube.animation.rawValue == animationCube.animation.rawValue ? .white : (.white.opacity(0.2)))
                    }
                    .contentShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
                    .onTapGesture {
                        withAnimation {
                            self.viewModel.changeSelectedAnimation(to: animationCube.animation)
                        }
                    }
            }
        }
    }
}