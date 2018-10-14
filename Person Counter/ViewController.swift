//
//  ViewController.swift
//  Person Counter
//
//  Created by Simon Loffler on 14/10/18.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    
    private var audioLevel: Float = 0.0
    private var currentCount: Int = 0
    
    // MARK: Properties
    @IBOutlet weak var personCount: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen for volume button presses
        listenForVolumeButtonPresses()
    }
    
    func listenForVolumeButtonPresses() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume",
                                     options: NSKeyValueObservingOptions.new,
                                     context: nil)
            audioLevel = audioSession.outputVolume
        } catch {
            print("Error")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.outputVolume > audioLevel {
                print("Volume up pressed")
                increaseCounter()
                audioLevel = audioSession.outputVolume
            }
            
            if audioSession.outputVolume < audioLevel {
                print("Volume down pressed")
                decreaseCounter()
                audioLevel = audioSession.outputVolume
            }
            
            // Avoid maximum system volume
            if audioSession.outputVolume > 0.999 {
                (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(0.9375, animated: false)
                audioLevel = 0.9375
            }
            
            // Avoid minimum system volume
            if audioSession.outputVolume < 0.001 {
                (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(0.0625, animated: false)
                audioLevel = 0.0625
            }
        }
    }
    
    func increaseCounter() {
        currentCount += 1
        personCount.text = String(currentCount)
    }
    
    func decreaseCounter() {
        currentCount -= 1
        personCount.text = String(currentCount)
    }
}

