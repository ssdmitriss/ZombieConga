//
//  GameScene.swift
//  ZombieConga
//
//  Created by Селезнев Дмитрий on 18.09.2021.
//

import SpriteKit

final class GameScene: SKScene {

    private var lastUpdateTime: TimeInterval = 0
    private var diffLastUpdateTime: TimeInterval = 0

    private var velocity = CGPoint.zero
    private var playableRect: CGRect

    private lazy var zombie: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "zombie1")
        node.position = CGPoint(x: frame.minX + 400, y: frame.minY + 400)

        return node
    }()

    override init(size: CGSize) {
        let maxAspectRation: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRation
        let playableMargin = (size.height - playableHeight) / 2

        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .red
        setupBackgroundNode()
        setupZombieOneNode()

    }

    override func update(_ currentTime: TimeInterval) {
        diffLastUpdateTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime
        print(diffLastUpdateTime * 1000)
        move(sprite: zombie, velocity: velocity)
        boundsCheckZombie()
    }

    private func setupBackgroundNode() {
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }

    private func setupZombieOneNode() {
        addChild(zombie)
    }

    private func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(
            x: velocity.x * CGFloat(diffLastUpdateTime),
            y: velocity.y * CGFloat(diffLastUpdateTime)
        )

        sprite.position = CGPoint(
            x: sprite.position.x + amountToMove.x,
            y: sprite.position.y + amountToMove.y
        )
    }

    private func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(
            x: location.x - zombie.position.x,
            y: location.y - zombie.position.y
        )

        let length = CGFloat(sqrt(Double(pow(offset.x, 2) + pow(offset.y, 2))))
        let direction = CGPoint(x: offset.x / length, y: offset.y / length)

        velocity = CGPoint(
            x: direction.x * Constatnts.zombieMovePointsPerSecond,
            y: direction.y * Constatnts.zombieMovePointsPerSecond
        )
    }

    private func boundsCheckZombie() {
        let bottomLeft = CGPoint.zero
        let topRight = CGPoint(x: size.width, y: size.height)

        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }

        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }

        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }

        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
}

extension GameScene {
    private func setTouched(touchLocation: CGPoint) {
        moveZombieToward(location: touchLocation)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        setTouched(touchLocation: touchLocation)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        setTouched(touchLocation: touchLocation)
    }
}

extension GameScene {
    private enum Constatnts {
        static let zombieMovePointsPerSecond: CGFloat = 480
    }
}
