//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Селезнев Дмитрий on 20.09.2021.
//

import SpriteKit

final class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        setupBackgroundNode()
    }

    private func setupBackgroundNode() {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame()
    }

    private func startGame() {
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(scene, transition: reveal)
    }
}
