//
//  AudioRecordViewController.swift
//  AudioRecord
//
//  Created by Brendan Krekeler on 11/8/18.
//  Copyright © 2018 Brendan Krekeler. All rights reserved.
//

import UIKit
import AVFoundation

var recordButton: UIButton!
var recordingSession: AVAudioSession!
var audioRecorder: AVAudioRecorder!

class AudioRecordViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("recording successfull")
                        //self.loadRecordingUI()
                    } else {
                        print("failed to record")
                    }
                }
            }
        } catch {
            print("failed to record")
        }
    }
    
//    func loadRecordingUI() {
//        recordButton = UIBarButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
//        recordButton.setTitle("Tap to Record", for: .normal)
//        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
//        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
//        view.addSubview(recordButton)
//    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self as? AVAudioRecorderDelegate
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        let alertSuccess = UIAlertController(title: "Recording Status", message: "Recording was Successful", preferredStyle: .alert)
        alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        let alertFailure = UIAlertController(title: "Recording Status", message: "Recording was unsuccessful, Please Try Again", preferredStyle: .alert)
        alertFailure.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            self.present(alertSuccess, animated: true)
        } else {
            self.present(alertFailure, animated: true)
            // recording failed
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
