//
//  ViewController.swift
//  Example
//
//  Created by leven on 2023/2/7.
//

import UIKit
import litSwift
class ViewController: UIViewController {

    lazy var litClient = LitClient()
    
    lazy var statusLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let connectNodeButton = UIButton(type: .custom)
        connectNodeButton.setTitle("Connect Node", for: .normal)
        connectNodeButton.setTitleColor(UIColor.black, for: .normal)
        connectNodeButton.addTarget(self, action: #selector(clickConnecntNode), for: .touchUpInside)
        self.view.addSubview(connectNodeButton)
        connectNodeButton.frame = CGRect(x: 20, y: 100, width: 300, height: 40)
        
        
        statusLabel.text = "ready to connect to lit node"
        statusLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        statusLabel.frame = CGRect(x: 20, y: 160, width: 300, height: 30)
        statusLabel.textAlignment = .center
        self.view.addSubview(statusLabel)
    }
    
    
    @objc func clickConnecntNode() {
        self.statusLabel.text = "Connecting..."
        let _ = litClient.connect().done { [weak self]_ in
            guard let self = self else { return }
            self.statusLabel.text = "Lit Connected"
            print("Lit Connected!")
        }
    }

}

