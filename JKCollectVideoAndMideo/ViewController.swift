//
//  ViewController.swift
//  JKCollectVideoAndMideo
//
//  Created by jackey_gjt on 16/11/11.
//  Copyright © 2016年 Jackey. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private lazy var videoConnection = AVCaptureConnection()
    private lazy var session : AVCaptureSession? = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer()
    private var movieFileOutput : AVCaptureMovieFileOutput?
    private var videoInput : AVCaptureDeviceInput?
    private lazy var fileUrl : NSURL? = {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/test.mp4"
        let url = NSURL(fileURLWithPath: path)
        
        return url
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

extension ViewController {
    
    @IBAction func startCapture(sender: AnyObject) {
        
        if session == nil {
            session = AVCaptureSession()
        }
        setupVideoSoure()
        setupAudioSoure()
        setupPreviewLayer()
        session!.startRunning()
        setupMoiveWriteToFile()
        
        
    }
    
    @IBAction func stopCapture(sender: AnyObject) {
        self.previewLayer.removeFromSuperlayer()
        movieFileOutput?.stopRecording()
        session!.stopRunning()
        session = nil
        
        
    }
    
    // MARK: - 切换摄像头
    @IBAction func switchCapture(sender: AnyObject) {
        
        let rotaionAnim = CATransition()
        rotaionAnim.type = "oglFlip"
        rotaionAnim.subtype = "formLeft"
        view.layer.addAnimation(rotaionAnim, forKey: nil)
        
        guard let videoInput = videoInput else{ return }
        
        let position : AVCaptureDevicePosition = videoInput.device.position == .Front ? .Back : .Front
        guard let devices  = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] else { return }
        
        
        guard let newDevice = devices.filter( {$0.position == position }).first else { return }
        
        self.videoInput = try? AVCaptureDeviceInput(device: newDevice)
        
        session!.beginConfiguration()
        session!.removeInput(videoInput)
        session!.addInput(self.videoInput)
        session!.commitConfiguration()
        
        
    }
    
    func setupPreviewLayer(){
        guard let previewLayer =  AVCaptureVideoPreviewLayer(session: session) else { return }
        self.previewLayer = previewLayer
        previewLayer.frame = view.frame
        view.layer.insertSublayer(previewLayer, atIndex: 0)
    }
    
    // MARK: - 写入视频
    func setupMoiveWriteToFile(){
        guard let session = session else{return}
        let  movieFileOutput = AVCaptureMovieFileOutput()
        self.movieFileOutput = movieFileOutput
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
        let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
        connection.preferredVideoStabilizationMode = .Auto
        guard let url = fileUrl else{return}
        movieFileOutput.startRecordingToOutputFileURL(url, recordingDelegate: self)
        
        
    }
    // MARK: - 视频
    func setupVideoSoure(){
        
        guard let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] else{ return }
        //把数组里面的条件过滤再返回
        guard let device = devices.filter( {return $0.position == .Front} ).first else{return}
        //        let device = devices.first!
        
        //通过前置设备创建输入设备
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else {return}
        self.videoInput = videoInput
        //创建输出源
        let videoOutPut = AVCaptureVideoDataOutput()
        
        let queue = dispatch_get_global_queue(0, 0)
        
        videoOutPut.setSampleBufferDelegate(self, queue: queue)
        guard let session = session else{return}
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        if session.canAddOutput(videoOutPut) {
            session.addOutput(videoOutPut)
        }
        videoConnection = videoOutPut.connectionWithMediaType(AVMediaTypeVideo)
        
        
    }
    // MARK: - 音频
    func setupAudioSoure(){
        
        guard let devices = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio) else{return}
        guard let audio = try? AVCaptureDeviceInput(device: devices) else {return}
        
        let audioOutput = AVCaptureAudioDataOutput()
        let queue = dispatch_get_global_queue(0, 0)
        
        audioOutput.setSampleBufferDelegate(self, queue: queue)
        
        if session!.canAddInput(audio) {
            session!.addInput(audio)
        }
        if session!.canAddOutput(audioOutput) {
            session!.addOutput(audioOutput)
        }
        
    }
    
}
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController  : AVCaptureVideoDataOutputSampleBufferDelegate , AVCaptureAudioDataOutputSampleBufferDelegate{
    
    //        func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
    //            <#code#>
    //        }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if connection == videoConnection {
            print("采集视频")
        }else{
            print("采集音频")
        }
        
    }
    
    
}
// MARK: - AVCaptureFileOutputRecordingDelegate
extension ViewController : AVCaptureFileOutputRecordingDelegate{
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print(fileURL.absoluteString)
        print("开始录制")
        
    }
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        print("停止录制")
    }
}

