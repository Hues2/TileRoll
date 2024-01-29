import SceneKit

class GameControllerManager {
    let sceneView : SCNView
    let ballNode : BallNode
    let playerCube : PlayerCubeNode
    
    init(sceneView: SCNView, ballNode : BallNode, playerCube : PlayerCubeNode) {
        self.sceneView = sceneView
        self.ballNode = ballNode
        self.playerCube = playerCube
        addSwipeGestureRecognizer()
    }
    
    func addSwipeGestureRecognizer() {
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipeGesture.direction = .right
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipeGesture.direction = .left
        self.sceneView.addGestureRecognizer(rightSwipeGesture)
        self.sceneView.addGestureRecognizer(leftSwipeGesture)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard gesture.state == .ended else { return }
        self.enableSwipeGestureRecognizers(false)
        self.ballNode.move(gesture.direction) {
            self.enableSwipeGestureRecognizers(true)
        }
        self.playerCube.move(gesture.direction) {
            self.enableSwipeGestureRecognizers(true)
        }
    }
    
    func enableSwipeGestureRecognizers(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            guard let gestures = self.sceneView.gestureRecognizers else { return }
            for gesture in gestures {
                gesture.isEnabled = isEnabled
            }
        }
    }
}
