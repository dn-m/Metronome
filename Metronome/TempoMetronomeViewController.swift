//
//  TempoMetronomeViewController.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import UIKit
import Rhythm
import Timeline
import MetronomeController

class TempoMetronomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timeline = Timeline.metronome(tempo: Tempo(78)) {
            self.blink()
        }
        
        timeline.start()
    }
    
    func blink() {
        
        on()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.off()
        }
    }
    
    func on() {
        DispatchQueue.main.async {
            self.view.layer.backgroundColor = UIColor.black.cgColor
        }
    }
    
    func off() {
        DispatchQueue.main.async {
            self.view.layer.backgroundColor = UIColor.white.cgColor
        }
    }
}
