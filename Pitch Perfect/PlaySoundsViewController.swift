//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Antonio Maradiaga on 15/02/2015.
//  Copyright (c) 2015 Antonio Maradiaga. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioBuffer: AVAudioPCMBuffer!
    var errorAudio:NSError?
    
    var audioEngine: AVAudioEngine!
    var audioFile:AVAudioFile!
    
    var receivedAudio: RecordedAudio!
    
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //var soundFilePath: String = NSBundle.mainBundle().pathForResource("movie_quote", ofType: "mp3")!
        
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: &errorAudio)
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error:&errorAudio)
        
        audioBuffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
        audioFile.readIntoBuffer(audioBuffer, error: nil)
        
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowSoundEffect(sender: UIButton) {
        audioPlayer.rate = 0.6
        playAudio()
    }

    @IBAction func playFastSoundEffect(sender: UIButton) {
        audioPlayer.rate = 1.6
        playAudio()
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        var pitchEffect = AVAudioUnitTimePitch(); pitchEffect.pitch = -1000
        playAudioWithEffect(pitchEffect)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        var pitchEffect = AVAudioUnitTimePitch(); pitchEffect.pitch = 1000
        playAudioWithEffect(pitchEffect)
    }
    
    @IBAction func playReverb(sender:UIButton) {
        var reverb = AVAudioUnitReverb(); reverb.wetDryMix = 50
        playAudioWithEffect(reverb)
    }
    
    func playAudioWithEffect(effect: AVAudioUnit){
        resetAudioComponents()
        
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(effect)
        
        audioEngine.connect(audioPlayerNode, to: effect, format: audioFile.processingFormat)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
        audioPlayerNode.scheduleBuffer(audioBuffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.InterruptsAtLoop, completionHandler: playerCompletionHandler)
        
        audioEngine.startAndReturnError(&errorAudio)
        
        audioPlayerNode.play()
        
        stopButton.hidden = false
    }
    
    
    func playAudio() {
        if(errorAudio == nil){
            resetAudioComponents()
            audioPlayer.currentTime = 0.0
            audioPlayer.play()
            stopButton.hidden = false
        } else {
            println(errorAudio?.description)
        }
        
    }
    
    func playerCompletionHandler() -> Void {
        //Ignore the interrupted audioPlayerNode -> audioPlayerNode.playing == false
        if audioPlayerNode.playing {
            stopAudioPlayback(UIButton())
        }
    }
    
    @IBAction func stopAudioPlayback(sender: UIButton) {
        resetAudioComponents()
        dispatch_async(dispatch_get_main_queue(), {self.stopButton.hidden = true})
    }
    
    func resetAudioComponents() {
        if audioPlayer.playing {
            audioPlayer.stop()
        }
        
        if (audioPlayerNode.playing){
            audioPlayerNode.stop()
        }
        
        if(audioEngine.running) {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!,
        successfully: Bool) {
    
            if(successfully) {
                stopButton.hidden = true
            }
    }

}
