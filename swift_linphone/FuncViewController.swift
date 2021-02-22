//
//  FuncViewController.swift
//  swift_linphone
//
//  Created by zouran on 2021/2/19.
//

import UIKit
import Alamofire
import AVFoundation
//import DSWaveformImage


let kAudioFilePath = "test.amr"

class FuncViewController: UIViewController {
    
    var isRecording = false
    
//    var recordingAudioPlot = EZAudioPlotGL()
    
    var recordingAudioPlot = UIView()
//
//    var microphone: EZMicrophone?
//
////    var player: EZAudioPlayer?
//
//    var recorder: EZRecorder?
    
//    var playingAudioPlot: EZAudioPlot?
    
//    var audioPlot = EZAudioPlot()
//    var audioFile: EZAudioFile?
    
    var bottomWaveformView = UIImageView()

    var maskImageView: WaveformImageView?
    
    var lastFrameX = 0.0
    
    let maskLayer = CAShapeLayer()
    
    // MARK: AVAudio properties
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var rateEffect = AVAudioUnitTimePitch()

    var audioFile: AVAudioFile? {
      didSet {
        if let audioFile = audioFile {
          audioLengthSamples = audioFile.length
          audioFormat = audioFile.processingFormat
          audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
          audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
        }
      }
    }
    var audioFileURL: URL? {
      didSet {
        if let audioFileURL = audioFileURL {
          audioFile = try? AVAudioFile(forReading: audioFileURL)
        }
      }
    }
    var audioBuffer: AVAudioPCMBuffer?

    // MARK: other properties
    var audioFormat: AVAudioFormat?
    var audioSampleRate: Float = 0
    var audioLengthSeconds: Float = 0
    var audioLengthSamples: AVAudioFramePosition = 0
    var needsFileScheduled = true
    let rateSliderValues: [Float] = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
    var rateValue: Float = 1.0 {
      didSet {
        rateEffect.rate = rateValue
      }
    }
    var updater: CADisplayLink?
    var currentFrame: AVAudioFramePosition {
      guard let lastRenderTime = player.lastRenderTime,
        let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
          return 0
      }

      return playerTime.sampleTime
    }
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    let pauseImageHeight: Float = 26.0
    let minDb: Float = -80.0

    enum TimeConstant {
      static let secsPerMin = 60
      static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    
//    let engine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
//        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)

//        AF.download("https://httpbin.org/image/png", to: destination)
        
//        AF.download("http://aod.cos.tx.xmcdn.com/group31/M0B/BB/58/wKgJSVmSRjvCZ4wwAAugz-tllHw858.m4a")
//            .downloadProgress { progress in
//                print("Download Progress: \(progress.fractionCompleted)")
//            }
//            .responseData { response in
//
//            }
        
        

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white

        self.navigationItem.title = "语音功能"

        let recordBtn = UIButton()
        recordBtn.addTarget(self, action: #selector(beginRecord), for: .touchUpInside)
        recordBtn.setTitle("录制", for: .normal)
        recordBtn.backgroundColor = .yellow


        self.view.addSubview(recordingAudioPlot)
        recordingAudioPlot.backgroundColor = .red
        recordingAudioPlot.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().inset(100)
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }


        let session = AVAudioSession.sharedInstance()
        let audioError: Error?
        do {
            try session.setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            try session.overrideOutputAudioPort(.speaker)
        } catch {
            print(error)
        }

//        recordingAudioPlot.color = .white
//        recordingAudioPlot.plotType = .rolling
//        recordingAudioPlot.shouldFill = false
//        recordingAudioPlot.shouldMirror = false
//
//
//        microphone = EZMicrophone(delegate: self)
//        microphone?.startFetchingAudio()
        
        self.view.addSubview(recordBtn)
        recordBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(recordingAudioPlot)
            make.right.equalToSuperview()
            make.left.equalTo(recordingAudioPlot.snp.right)
        }

        let playButton = UIButton()
        self.view.addSubview(playButton)
        playButton.setTitle("播放", for: .normal)
        playButton.backgroundColor = .green
        playButton.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.top.equalTo(recordBtn.snp.bottom)
            make.left.equalTo(recordBtn)
        }
        playButton.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        
        maskImageView = WaveformImageView(frame: CGRect.zero)
        self.view.addSubview(maskImageView!)
        maskImageView?.snp.makeConstraints({ (make) in
            make.left.equalToSuperview()
            make.top.equalTo(recordingAudioPlot.snp.bottom)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        
        self.view.addSubview(bottomWaveformView)
        bottomWaveformView.backgroundColor = .blue
        bottomWaveformView.snp.makeConstraints({ (make) in
            make.left.equalToSuperview()
            make.top.equalTo(recordingAudioPlot.snp.bottom)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        
        
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        
//        return
        
        // 拖动播放
        let waveformImageDrawer = WaveformImageDrawer()

        let audioURL = Bundle.main.url(forResource: "_group31_M0B_BB_58_wKgJSVmSRjvCZ4wwAAugz-tllHw858", withExtension: "m4a")!

        let configuration = WaveformConfiguration(
            size: bottomWaveformView.bounds.size,
            style: .striped(.gray),
            position: .bottom,
            paddingFactor: 0.5,
            stripeWidth: 25,
            stripeSpacing: 5
        )

        let configuration2 = WaveformConfiguration(
            size: bottomWaveformView.bounds.size,
            style: .striped(.white),
            position: .bottom,
            paddingFactor: 0.5,
            stripeWidth: 25,
            stripeSpacing: 5
        )

        waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: configuration2) { image in
            DispatchQueue.main.async {
                self.maskImageView!.image = image;
                self.maskImageView!.isUserInteractionEnabled = true
                self.maskImageView!.backgroundColor = .red
            }
        }


        waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: configuration) { image in
            DispatchQueue.main.async {
                self.bottomWaveformView.image = image
                self.bottomWaveformView.backgroundColor = .red
                self.bottomWaveformView.isUserInteractionEnabled = true
            }
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        pan.delaysTouchesBegan = true
        self.bottomWaveformView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.bottomWaveformView.addGestureRecognizer(tap)

//        // get access to the raw, normalized amplitude samples
//        let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: audioURL)
//        waveformAnalyzer?.samples(count: 10) { samples in
//            print("sampled down to 10, results are \(samples ?? [])")
//        }
        
        let fullRect = self.bottomWaveformView.bounds
        let newWidth = Double(fullRect.size.width)

        
//        maskLayer.opacity = 0.5
        let maskRect = CGRect(x: Double(0), y: 0.0, width: newWidth, height: Double(fullRect.size.height))

        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path

        self.bottomWaveformView.layer.mask = maskLayer
        
        
        setupAudio()

        updater = CADisplayLink(target: self, selector: #selector(updateUI))
        updater?.add(to: .current, forMode: .default)
        updater?.isPaused = true
        

        
        
    }
    

    
    @objc func playAction(sender: UIButton) {
        sender.isHidden = true
        
//        isRecording = false
//
//        microphone?.stopFetchingAudio()
//
//        self.recorder?.closeAudioFile()
//
//        let audioFile = EZAudioFile(url: self.testFilePathURL())
//        player?.playAudioFile(audioFile)
    }
    
    @objc func beginRecord(sender: UIButton) {
        sender.isHidden = true

        isRecording = true
        
//        microphone?.startFetchingAudio()
        
//        recorder = EZRecorder(url: testFilePathURL(), clientFormat: self.microphone!.audioStreamBasicDescription(), fileType: .M4A, delegate: self)
    }
    
    func testFilePathURL() -> URL {
        return URL(fileURLWithPath: applicationDocumentsDirectory()! + "/" + kAudioFilePath)
    }
    
    func applicationDocumentsDirectory() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let basePath = paths.count > 0 ? paths[0] : nil
        return basePath
    }
    
    
    @objc func handleTapGesture() {
        if currentPosition >= audioLengthSamples {
          updateUI()
        }

        if player.isPlaying {
          disconnectVolumeTap()
          updater?.isPaused = true
          player.pause()
        } else {
          updater?.isPaused = false
          connectVolumeTap()
          if needsFileScheduled {
            needsFileScheduled = false
            scheduleAudioFile()
          }
          player.play()
        }
    }
    
    @objc func updateUI() {
      currentPosition = currentFrame + seekFrame
      currentPosition = max(currentPosition, 0)
      currentPosition = min(currentPosition, audioLengthSamples)

        
//      print(audioLengthSeconds)
        let fullRect = self.bottomWaveformView.bounds
        let newWidth = Double(fullRect.size.width)
//
//        maskLayer.opacity = 0.5
        let maskRect = CGRect(x: Double(Float(currentPosition) / Float(audioLengthSamples))*newWidth, y: 0.0, width: newWidth, height: Double(fullRect.size.height))

        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path

        self.bottomWaveformView.layer.mask = maskLayer
      // 比例
//      print(Double(Float(currentPosition) / Float(audioLengthSamples))*newWidth)
        
        lastFrameX = Double(Float(currentPosition) / Float(audioLengthSamples))*newWidth
        
//      let time = Float(currentPosition) / audioSampleRate

      if currentPosition >= audioLengthSamples {
        player.stop()
        updater?.isPaused = true
        disconnectVolumeTap()
      }
    }
    
    
    @objc func handlePanGesture(p: UIPanGestureRecognizer) {
        let panPoint = p.location(in: self.bottomWaveformView)
        var endPoint = 0.0
        if p.state == .began {
            updater?.isPaused = true
//            self.alpha = 1
            print("启动",panPoint.x)
        } else if p.state == .changed {
//            self.center = CGPoint(x: panPoint.x, y: panPoint.y)
            
            let fullRect = self.bottomWaveformView.bounds
            let newWidth = Double(fullRect.size.width)

    //        maskLayer.opacity = 0.5
            let maskRect = CGRect(x: Double(panPoint.x), y: 0.0, width: newWidth, height: Double(fullRect.size.height))

            let path = CGPath(rect: maskRect, transform: nil)
            maskLayer.path = path

            self.bottomWaveformView.layer.mask = maskLayer
            
            endPoint = Double(panPoint.x)
//            print("结束",panPoint.x)
        } else if (p.state == .ended || p.state == .cancelled) {
            updater?.isPaused = false
            // 计算长度
            print("最终",(Double(panPoint.x) - Double(lastFrameX)) / Double(self.bottomWaveformView.frame.size.width) * Double(audioLengthSeconds))
//            let duration = panLength / Double(self.maskImageView.frame.size.width) * Double(audioLengthSeconds)
//            print(duration)
            seek(to: Float((Double(panPoint.x) - Double(lastFrameX)) / Double(self.bottomWaveformView.frame.size.width) * Double(audioLengthSeconds)))
        }
    }

}

//extension FuncViewController: EZAudioPlayerDelegate, EZMicrophoneDelegate, EZRecorderDelegate {
//    func microphone(_ microphone: EZMicrophone!, changedPlayingState isPlaying: Bool) {
//
//    }
//
//    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
//
//        DispatchQueue.main.async {
//            self.recordingAudioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
//        }
//    }
//
//    func microphone(_ microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
//        if isRecording {
//            recorder?.appendData(from: bufferList, withBufferSize: bufferSize)
//        }
//    }
//}

extension FuncViewController {
  func setupAudio() {
    audioFileURL  = Bundle.main.url(forResource: "_group31_M0B_BB_58_wKgJSVmSRjvCZ4wwAAugz-tllHw858", withExtension: "m4a")
//    audioFileURL = URL(string: "http://aod.cos.tx.xmcdn.com/group31/M0B/BB/58/wKgJSVmSRjvCZ4wwAAugz-tllHw858.m4a")

    engine.attach(player)
    engine.attach(rateEffect)
    engine.connect(player, to: rateEffect, format: audioFormat)
    engine.connect(rateEffect, to: engine.mainMixerNode, format: audioFormat)

    engine.prepare()

    do {
      try engine.start()
    } catch let error {
      print(error.localizedDescription)
    }
  }

  func scheduleAudioFile() {
    guard let audioFile = audioFile else { return }

    seekFrame = 0
    player.scheduleFile(audioFile, at: nil) { [weak self] in
      self?.needsFileScheduled = true
    }
  }

  func connectVolumeTap() {
    let format = engine.mainMixerNode.outputFormat(forBus: 0)
    engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in

      guard let channelData = buffer.floatChannelData,
        let updater = self.updater else {
          return
      }

      let channelDataValue = channelData.pointee
      let channelDataValueArray = stride(from: 0,
                                         to: Int(buffer.frameLength),
                                         by: buffer.stride).map{ channelDataValue[$0] }
      let rms = sqrt(channelDataValueArray.map{ $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
      let avgPower = 20 * log10(rms)
      let meterLevel = self.scaledPower(power: avgPower)

      DispatchQueue.main.async {
//        self.volumeMeterHeight.constant = !updater.isPaused ? CGFloat(min((meterLevel * self.pauseImageHeight),
//                                                                          self.pauseImageHeight)) : 0.0
      }
    }
  }

  func scaledPower(power: Float) -> Float {
    guard power.isFinite else { return 0.0 }

    if power < minDb {
      return 0.0
    } else if power >= 1.0 {
      return 1.0
    } else {
      return (fabs(minDb) - fabs(power)) / fabs(minDb)
    }
  }

  func disconnectVolumeTap() {
    engine.mainMixerNode.removeTap(onBus: 0)
  }

  func seek(to time: Float) {
    guard let audioFile = audioFile,
      let updater = updater else {
      return
    }

    seekFrame = currentPosition + AVAudioFramePosition(time * audioSampleRate)
    seekFrame = max(seekFrame, 0)
    seekFrame = min(seekFrame, audioLengthSamples)
    currentPosition = seekFrame

    player.stop()

    if currentPosition < audioLengthSamples {
      updateUI()
      needsFileScheduled = false

      player.scheduleSegment(audioFile, startingFrame: seekFrame, frameCount: AVAudioFrameCount(audioLengthSamples - seekFrame), at: nil) { [weak self] in
        self?.needsFileScheduled = true
      }

      if !updater.isPaused {
        player.play()
      }
    }
  }

}
