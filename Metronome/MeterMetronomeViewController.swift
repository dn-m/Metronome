//
//  MeterMetronomeViewController.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import UIKit
import Rhythm
import Timeline
import MetronomeController

class MeterMetronomeViewController: UIViewController {
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(didUpdateTempoSlider), for: .valueChanged)
        slider.value = 0.5
        return slider
    }()
    
    lazy var tempoValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 48)
        label.text = "60"
        return label
    }()
    
    lazy var beatsButton: UIButton = {
        let button = UIButton()
        button.setTitle("4", for: .normal)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    lazy var subdivisionButton: UIButton = {
        let button = UIButton()
        button.setTitle("4", for: .normal)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    lazy var startStopButton: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(didUpdateSwitch), for: .valueChanged)
        return toggle
    }()
    
    var meter = Meter(4,4)
    var timeline = Timeline()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeline = Timeline.metronome(
            meter: meter,
            tempo: Tempo(60),
            performingOnDownbeat: { _ in self.onDownbeat() },
            performingOnUpbeat: { _ in self.onUpbeat() }
        )
        //timeline = Timeline.metronome(tempo: Tempo(60), performing: self.blink)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLayout()
    }
    
    func configureLayout() {
        
        let stackView = UIStackView(frame: view.frame)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10
        
        stackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(tempoValueLabel)
        stackView.addArrangedSubview(beatsButton)
        stackView.addArrangedSubview(subdivisionButton)
        stackView.addArrangedSubview(startStopButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        tempoValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let sliderLeadingConstraint = NSLayoutConstraint(
            item: slider,
            attribute: .leading,
            relatedBy: .equal,
            toItem: stackView,
            attribute: .leading,
            multiplier: 1.0,
            constant: 20
        )
        
        let sliderTrailingConstraint = NSLayoutConstraint(
            item: slider,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: stackView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: -20
        )
        
        stackView.addConstraint(sliderLeadingConstraint)
        stackView.addConstraint(sliderTrailingConstraint)
        
        let stackViewTopConstraint = NSLayoutConstraint(
            item: stackView,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .top,
            multiplier: 1.0,
            constant: 20
        )
        
        let stackViewLeadingConstraint = NSLayoutConstraint(
            item: stackView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1.0,
            constant: 20
        )
        
        let stackViewTrailingConstraint = NSLayoutConstraint(
            item: stackView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1.0,
            constant: -20
        )
        
        view.addConstraint(stackViewTopConstraint)
        view.addConstraint(stackViewLeadingConstraint)
        view.addConstraint(stackViewTrailingConstraint)
    }
    
    func didUpdateSwitch(_ toggle: UISwitch) {
        toggle.isOn ? timeline.resume() : timeline.pause()
    }
    
    func didUpdateTempoSlider(_ slider: UISlider) {
        
        // 24 -> 240 bpm
        let playbackRate = slider.value.scaled(from: 0...1, to: 0.4...4)
        timeline.playbackRate = Double(playbackRate)
        tempoValueLabel.text = (playbackRate * 60).formatted(digits: 2)
    }
    
    func onDownbeat() {
        blink(color: UIColor(white: 1, alpha: 0.66))
    }
    
    func onUpbeat() {
        blink(color: UIColor(white: 1, alpha: 0.33))
    }
    
    func blink(color: UIColor) {
        
        on(color: color)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.off()
        }
    }
    
    func on(color: UIColor) {
        DispatchQueue.main.async {
            self.view.layer.borderWidth = 4
            self.view.layer.borderColor = color.cgColor
        }
    }
    
    func off() {
        DispatchQueue.main.async {
            self.view.layer.borderWidth = 0
        }
    }
}
