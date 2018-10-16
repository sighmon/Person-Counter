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
        
        // Hide the Volume UI
        hideVolumeUI()
        
        // Set ourselves to observe for volume button presses
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
        // Volume buttons observer
        if keyPath == "outputVolume"{
            let audioSession = AVAudioSession.sharedInstance()
            print("System volume before: \(audioLevel)")
            
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
                setMPVolumeSlider(volume: 0.9375)
                audioLevel = 0.9375
            }
            
            // Avoid minimum system volume
            if audioSession.outputVolume < 0.001 {
                setMPVolumeSlider(volume: 0.0625)
                audioLevel = 0.0625
            }
            
            // Send count to MuseumOS
            sendToMuseumOS()
            
            print("System volume after: \(audioLevel)")
        }
    }
    
    func setMPVolumeSlider(volume: Float) {
        // TOFIX: This doesn't work in iOS 12 - investigate private APIs?
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(volume, animated: false)
    }
    
    func increaseCounter() {
        currentCount += 1
        personCount.text = String(currentCount)
    }
    
    func decreaseCounter() {
        currentCount -= 1
        personCount.text = String(currentCount)
    }
    
    func sendToMuseumOS() {
        // TODO: post to MuseumOS
        // currentCount
        // location
        // appID?
    }
    
    func hideVolumeUI() {
        let volumeView = MPVolumeView(frame: CGRect.zero)
        for subview in volumeView.subviews {
            if let button = subview as? UIButton {
                button.setImage(nil, for: .normal)
                button.isEnabled = false
                button.sizeToFit()
            }
        }
        UIApplication.shared.windows.first?.addSubview(volumeView)
        UIApplication.shared.windows.first?.sendSubviewToBack(volumeView)
    }
}

