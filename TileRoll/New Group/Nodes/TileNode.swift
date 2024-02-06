import SceneKit

class TileNode: SCNNode, Identifiable {
    let id = UUID()
    var contactHandled : Bool = false
    let tilePosition : TilePosition
    var isFirstTile : Bool
    let isSpikeNode : Bool
    private var deadZoneNode : DeadZoneNode!
    
    init(tilePosition : TilePosition, isFirstTile : Bool, isSpikeNode : Bool) {
        self.tilePosition = tilePosition
        self.isFirstTile = isFirstTile
        self.isSpikeNode = isSpikeNode
        super.init()
        self.name = isSpikeNode ? Constants.spikeTileNodeName : Constants.tileNodeName
        setUpTile()
        if !isFirstTile && !isSpikeNode {
            addDeadZone()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpTile() {
        // Create a box geometry
        let boxGeometry = SCNBox(width: Constants.tileSize,
                                 height: Constants.tileSize,
                                 length: Constants.tileSize,
                                 chamferRadius: 0.0)
        
        // Create a material for the box
        let material = SCNMaterial()
        material.diffuse.contents = isSpikeNode ? UIColor.blue : UIColor.black
        
        // Apply the material to the box
        boxGeometry.materials = [material]
        
        // Create a node with the box geometry
        self.geometry = boxGeometry
        
        setUpPhysicsBody()
    }
    
    private func setUpPhysicsBody() {
        guard let geometry else { return }
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: geometry))
        self.physicsBody?.categoryBitMask = Constants.tileCategoryBitMask
        self.physicsBody?.collisionBitMask = Constants.playerCubeCategoryBitMask
        self.physicsBody?.contactTestBitMask = Constants.playerCubeCategoryBitMask
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.friction = 1
    }
    
    func updatePosition(position : SCNVector3) {
        self.position = position
    }
}

// MARK: - Dead Zone
extension TileNode {
    private func addDeadZone() {
        deadZoneNode = DeadZoneNode()
        deadZoneNode.position = self.position
        deadZoneNode.position.y = self.position.y - 1
        self.addChildNode(deadZoneNode)
    }
    
    func removeDeadZone() {
        self.deadZoneNode.removeFromParentNode()
    }
}
