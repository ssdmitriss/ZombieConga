//
//  GameViewController.swift
//  ZombieConga
//
//  Created by Селезнев Дмитрий on 18.09.2021.
//

import UIKit
import SpriteKit
import SnapKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene(size: CGSize(width: 2048, height: 1536))
        scene.scaleMode = .aspectFill

        let skView = SKView()
        view.addSubview(skView)
        skView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
}

