//
//  MetronomeSelectorTabBarController.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import UIKit

class MetronomeSelectorTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // tempo view controller
        let tempo = TempoMetronomeViewController()
        tempo.tabBarItem = UITabBarItem(title: "Tempo", image: nil, selectedImage: nil)
        
        // meter view controller
        let meter = MeterMetronomeViewController()
        meter.tabBarItem = UITabBarItem(title: "Meter", image: nil, selectedImage: nil)

        // score view controller
        let score = ScoreMetronomeViewController()
        score.tabBarItem = UITabBarItem(title: "Score", image: nil, selectedImage: nil)
        
        self.viewControllers = [tempo, meter, score]
    }
}
