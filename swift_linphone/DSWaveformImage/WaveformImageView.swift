import Foundation
import AVFoundation
import UIKit

public class WaveformImageView: UIImageView {
    private let waveformImageDrawer: WaveformImageDrawer
    private var waveformAnalyzer: WaveformAnalyzer?

    public var waveformStyle: WaveformStyle {
        didSet { updateWaveform() }
    }

    public var waveformPosition: WaveformPosition {
        didSet { updateWaveform() }
    }

    public var waveformAudioURL: URL? {
        didSet { updateWaveform() }
    }
    
    public var dragEnable: Bool? {
        didSet {
            self.isUserInteractionEnabled = true
            // 自己来个拖动条
            
            // 添加拖动手势

        }
    }

    override public init(frame: CGRect) {
        waveformStyle = .gradient([UIColor.black, UIColor.darkGray])
        waveformPosition = .middle
        waveformImageDrawer = WaveformImageDrawer()
        
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
    }
    
//    @objc func handlePanGesture(p: UIPanGestureRecognizer) {
//        let panPoint = p.location(in: self)
//        
//        if p.state == .began {
////            self.alpha = 1
//        } else if p.state == .changed {
////            self.center = CGPoint(x: panPoint.x, y: panPoint.y)
//            
//            print(panPoint.x)
//        } else if (p.state == .ended || p.state == .cancelled) {
//            
//        }
//    }

    required public init?(coder aDecoder: NSCoder) {
        waveformStyle = .gradient([UIColor.black, UIColor.darkGray])
        waveformPosition = .middle
        waveformImageDrawer = WaveformImageDrawer()
        super.init(coder: aDecoder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateWaveform()
    }
}

private extension WaveformImageView {
    func updateWaveform() {
        guard let audioURL = waveformAudioURL else { return }
        waveformImageDrawer.waveformImage(fromAudioAt: audioURL, size: bounds.size,
                                          style: waveformStyle, position: waveformPosition,
                                          scale: UIScreen.main.scale, qos: .userInitiated) { image in
                                            DispatchQueue.main.async {
                                                self.image = image
                                            }
        }
    }
}
