//
//  GameScene.swift
//  ZombieConga
//
//  Created by Селезнев Дмитрий on 18.09.2021.
//

import SpriteKit

final class GameScene: SKScene {

    /// Время последнего обновления
    private var lastUpdateTime: TimeInterval = 0
    /// Сколько прошло времени с полследнего цикла обновлений
    private var diffLastUpdateTime: TimeInterval = 0
    /// Место последнего тапа по экрану
    private var lastTouchLocation: CGPoint?

    /// Направление
    private var velocity = CGPoint.zero
    private var playableRect: CGRect

    /// Анимация шагов зомби
    private var zombieAnimation: SKAction

    /// Флаг того, что зомби неуязвим
    private var isZombieInvulnerable = false
    /// Количество жизней
    private var lives = 5
    private var isGameOver = false

    private lazy var zombie: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "zombie1")
        node.position = CGPoint(x: 400, y: 400)
        node.zPosition = 100

        return node
    }()

    // MARK: - Initialization

    override init(size: CGSize) {
        let maxAspectRation: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRation
        let playableMargin = (size.height - playableHeight) / 2

        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)

        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])

        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)

        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifcycle

    override func didMove(to view: SKView) {
        backgroundColor = .red
        setupBackgroundNode()
        setupZombieOneNode()
        generateEnemies()
        generateCats()
        playBackgroundMusic(filename: "backgroundMusic.mp3")
//        debugDrawPlaylableArea()
    }

    override func update(_ currentTime: TimeInterval) {
        diffLastUpdateTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime

        if shouldStopSprite(zombie) {
            velocity = .zero
            stopZombieAnimation()
        } else {
            move(sprite: zombie, velocity: velocity)
            rotate(sprite: zombie, direction: velocity)
        }

        boundsCheckZombie()
        moveTrain()
        checkGameOver()
    }

    override func didEvaluateActions() {
        checkCollisions()
    }

    // MARK: - Private Methods

    private func setupBackgroundNode() {
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }

    private func setupZombieOneNode() {
        addChild(zombie)
    }

    private func startZombieAnimation() {
        guard zombie.action(forKey: Constatnts.zombieAnimationKey) == nil else { return }
        zombie.run(SKAction.repeatForever(zombieAnimation), withKey: Constatnts.zombieAnimationKey)
    }

    private func stopZombieAnimation() {
        zombie.removeAction(forKey: Constatnts.zombieAnimationKey)
    }

    private func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                min: playableRect.minY + enemy.size.height / 2,
                max: playableRect.maxY - enemy.size.height / 2
            )
        )
        addChild(enemy)

        let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([actionMove, removeAction])
        enemy.run(sequence)
    }

    private func generateEnemies() {
        let spawnBlock = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let wait = SKAction.wait(forDuration: 2.0)
        let sequence = SKAction.sequence([spawnBlock, wait])
        let repeatForever = SKAction.repeatForever(sequence)

        run(repeatForever)
    }

    private func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: playableRect.minX,
                              max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY,
                              max: playableRect.maxY))
        cat.setScale(0)
        cat.zRotation = -.pi / 16
        addChild(cat)

        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()

        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])

        let leftWiggle = SKAction.rotate(byAngle: .pi / 8, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])

        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let actions = [appear, groupWait, disappear, removeFromParent]

        cat.run(SKAction.sequence(actions))
    }

    private func generateCats() {
        let spawnBlock = SKAction.run { [weak self] in
            self?.spawnCat()
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let sequence = SKAction.sequence([spawnBlock, wait])
        let repeatForever = SKAction.repeatForever(sequence)

        run(repeatForever)
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
        startZombieAnimation()

        let offset = CGPoint(
            x: location.x - zombie.position.x,
            y: location.y - zombie.position.y
        )

        let length = CGFloat(sqrt(Double(pow(offset.x, 2) + pow(offset.y, 2))))
        let direction = CGPoint(x: offset.x / length, y: offset.y / length)

        velocity = CGPoint(
            x: direction.x * Constatnts.zombieMovedPointsPerSecond,
            y: direction.y * Constatnts.zombieMovedPointsPerSecond
        )
    }

    private func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        let shortestAngel = shortestAngleBetween(angle1: sprite.zRotation, angle2: direction.angle)
        let amountToRotate = min(
            Constatnts.zombieRotatedRadiansPerSecond * CGFloat(diffLastUpdateTime),
            abs(shortestAngel)
        )

        sprite.zRotation += amountToRotate * shortestAngel.sign()
    }

    private func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)

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

    private func debugDrawPlaylableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = .red
        shape.lineWidth = 4
        addChild(shape)
    }

    private func shouldStopSprite(_ sprite: SKSpriteNode) -> Bool {
        guard let lastPosition = lastTouchLocation else { return false }

        let distanceToTouch = (lastPosition - sprite.position).length()
        let nextMoveDistance = Constatnts.zombieMovedPointsPerSecond * CGFloat(diffLastUpdateTime)
        
        return distanceToTouch <= nextMoveDistance
    }

    private func zombieHit(cat: SKSpriteNode) {
        cat.removeAllActions()
        cat.name = "train"
        cat.setScale(1)
        cat.zRotation = .zero

        let greenAction = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.2)
        cat.run(greenAction)

        run(Constatnts.catCollisionSound)
    }

    private func moveTrain() {
        var trainCount = 0
        var targetPosition = zombie.position

        enumerateChildNodes(withName: "train") { node, stop in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * Constatnts.catMovedPointsPerSecond
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
                self.checkGameWin(withTrainCount: trainCount)
            }
            targetPosition = node.position
        }
    }

    private func zombieHit(enemy: SKSpriteNode) {
        guard !isZombieInvulnerable else { return }

        isZombieInvulnerable = true
        startInvulnerableAnimation()
        run(Constatnts.enemyCollisionSound)

        loseCats()
        lives -= 1
    }

    private func startInvulnerableAnimation() {
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }

        let finishAnimationAction = SKAction.run { [weak self]  in
            self?.isZombieInvulnerable = false
        }

        let fullAction = SKAction.sequence([blinkAction, finishAnimationAction])
        zombie.run(fullAction)
    }

    private func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            guard let cat = node as? SKSpriteNode else { return }
            if cat.frame.intersects(self.zombie.frame.insetBy(dx: 100, dy: 100)) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }

        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            guard let enemy = node as? SKSpriteNode else { return }
            if enemy.frame.insetBy(dx: 100, dy: 100).intersects(self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }

    private func loseCats() {
        var loseCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            // 3
            node.name = ""
            node.run(SKAction.sequence(
                [
                    SKAction.group([
                    SKAction.rotate(byAngle: π*4, duration: 1.0),
                    SKAction.move(to: randomSpot, duration: 1.0),
                    SKAction.scale(to: 0, duration: 1.0)
                    ]),
                    SKAction.removeFromParent()
                ]
            ))
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }

    private func checkGameOver() {
        guard lives <= 0 && !isGameOver else { return }
        isGameOver = true
        showGameOverScene(isLose: true)
        backgroundMusicPlayer.stop()
    }

    private func checkGameWin(withTrainCount count: Int) {
        guard count >= 15 && !isGameOver else { return }
        backgroundMusicPlayer.stop()
        showGameOverScene(isLose: false)
    }

    private func showGameOverScene(isLose: Bool) {
        let gameOverScene = GameOverScene(size: size, won: !isLose)
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
}

extension GameScene {
    private func setTouched(touchLocation: CGPoint) {
        let availableMoveLocation = playableRect.contains(touchLocation)
            ? touchLocation
            : CGPoint(x: touchLocation.x, y: calculateYPosition(touchLocation: touchLocation))

        moveZombieToward(location: availableMoveLocation)
        lastTouchLocation = availableMoveLocation
    }

    private func calculateYPosition(touchLocation: CGPoint) -> CGFloat {
        if touchLocation.y < playableRect.minY {
            return playableRect.minY
        } else if touchLocation.y > playableRect.maxY {
            return playableRect.maxY
        } else {
            return touchLocation.y
        }
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
        static let zombieMovedPointsPerSecond: CGFloat = 480
        static let catMovedPointsPerSecond: CGFloat = 480
        static let zombieRotatedRadiansPerSecond: CGFloat = 4 * .pi
        static let zombieAnimationKey = "zombieAnimation"
        static let catCollisionSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
        static let enemyCollisionSound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    }
}
