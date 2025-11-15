//
//  ViewController.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 20/10/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        getStartedButton.layer.cornerRadius = 10.0
    }

}

