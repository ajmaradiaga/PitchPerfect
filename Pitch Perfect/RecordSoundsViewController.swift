//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Antonio Maradiaga on 13/02/2015.
//  Copyright (c) 2015 Antonio Maradiaga. All rights reserved.
//

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var recordedAudio: RecordedAudio!
    var audioRecorder:AVAudioRecorder!
    var audioFilePath:NSURL!
    
    enum recordingState: Int {
        case notRecording = 1, recording, paused, stop
    }
    
    var currentState: recordingState!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        audioFilePath = NSURL()
        currentState = .notRecording
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        recordButton.enabled = true
        recordingLabel.text = "Tap to Record"
        pauseButton.setTitle("Pause", forState: UIControlState.Normal)
        setHiddenState(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordAudio(sender: UIButton) {
        currentState = .recording
        pauseButton.setTitle("Pause", forState: UIControlState.Normal)
        
        println("in recordAudio function")
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let audioFilePath = NSURL.fileURLWithPathComponents(pathArray)
        
        println(audioFilePath)
        
        var audioSession = AVAudioSession.sharedInstance()
        //audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: audioFilePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        recordingLabel.text = "Recording in Progress"
        recordButton.enabled = false
        setHiddenState(false)
    }
    
    @IBAction func pauseRecording(sender:UIButton) {
        if(audioRecorder.recording) {
            audioRecorder.pause()
            recordingLabel.text = "Tap Mic to restart."
            pauseButton.setTitle("Continue Recording...", forState: UIControlState.Normal)
            recordButton.enabled = true
            currentState = .paused
        } else {
            //It is paused, set to continue recording
            audioRecorder.record()
            recordingLabel.text = "Recording in Progress"
            pauseButton.setTitle("Pause", forState: UIControlState.Normal)
            currentState = .recording
        }
    }

    @IBAction func stopRecording(sender: UIButton) {
        currentState = .stop
        audioRecorder.stop()
        
        //Inactivate AVAudioSession
        var audioSession = AVAudioSession.sharedInstance()
            
        audioSession.setActive(false, error: nil)
        
        setHiddenState(true)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("An error has occured :-S")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(_filePathURL: recorder.url, _title: recorder.url.lastPathComponent!)
            //recordedAudio.filePathUrl = recorder.url
            //recordedAudio.title = recorder.url.lastPathComponent
            
            self.performSegueWithIdentifier("stopRecordingSegue", sender: recordedAudio);
        } else {
            println("Recording was not successful")
            recordButton.enabled = false
            setHiddenState(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecordingSegue"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController
             as PlaySoundsViewController
            
            playSoundsVC.receivedAudio = sender as RecordedAudio
        }
    }
    
    func setHiddenState(b: Bool){
        //recordingLabel.hidden = b
        pauseButton.hidden = b
        stopButton.hidden = b
    }
    
    
}

