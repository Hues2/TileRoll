import Foundation
import SceneKit

class TileManager {
    // Scene
    let scene : SCNScene
    
    // Tiles
    var tileNodes : [TileNode] = []
    var tileCoordinates = TileCoordinates()
    
    init(scene : SCNScene) {
        self.scene = scene
        setUpInitialTileNodes()
    }
}

// MARK: - Add Tile Node
extension TileManager {
    func addNewTile() {
        guard let firstTileNode = tileNodes.first else { return }
        removeTileNode(firstTileNode)
        addTileNode()
    }
    
    private func addTileNode() {
        guard let tilePosition = TilePosition.allCases.randomElement() else { return }
        let tileNode = TileNode(tilePosition: tilePosition)
        self.tileNodes.append(tileNode)
        setTilePosition(tileNode)
        Utils.addNodeToScene(scene, tileNode)
    }
    
    private func setTilePosition(_ tileNode : TileNode) {
        tileNode.position = SCNVector3(tileCoordinates.xPosition, tileCoordinates.yPosition, tileCoordinates.zPosition)
        tileCoordinates.yPosition -= 2 // Next block should always be place below current block
        tileCoordinates.xPosition = tileNode.tilePosition == .right ? (tileCoordinates.xPosition + 2) : tileCoordinates.xPosition
        tileCoordinates.zPosition = tileNode.tilePosition == .right ? tileCoordinates.zPosition : (tileCoordinates.zPosition + 2)
    }
    
    private func removeTileNode(_ tileNode : TileNode) {
        if self.tileNodes.count > 15 {
            tileNode.removeFromParentNode()
            tileNodes.removeFirst()
        }
    }
}

// MARK: - Set up initial tile nodes
private extension TileManager {
    private func setUpInitialTileNodes() {
        for _ in 0...9 {
            addTileNode()
        }
    }
}

enum TilePosition : CaseIterable {
    case left, right
}
