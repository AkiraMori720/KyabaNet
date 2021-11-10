//
//  DottedProgressBar.swift
//  Pods
//
//  Created by Nikola Corlija on 4/16/17.
//
//

import Foundation
import UIKit

// swiftlint:disable function_body_length

open class DottedProgressBar: UIView {

    public struct DottedProgressAppearance {
        let dotRadius: CGFloat
        let dotsColor: UIColor
        let dotsProgressColor: UIColor
        let backColor: UIColor

        public init(dotRadius: CGFloat = 8.0,
                    dotsColor: UIColor = UIColor.orange.withAlphaComponent(0.4),
                    dotsProgressColor: UIColor = UIColor.red,
                    backColor: UIColor = UIColor.clear) {
            self.dotRadius = dotRadius
            self.dotsColor = UIColor(hexString: "#33000000")!
            self.dotsProgressColor = dotsProgressColor
            self.backColor = backColor
        }
    }

    open var progressAppearance: DottedProgressAppearance!

    /// Zoom increase of walking dot while animating progress.
    open var zoomIncreaseValueOnProgressAnimation: CGFloat = 1.5

    fileprivate var numberOfDots: Int = 0
    fileprivate var previousProgress: Int = 0
    fileprivate var currentProgress: Int = 0

    fileprivate var isAnimatingCurrently: Bool = false
    fileprivate lazy var walkingDot = UIView()
    
    fileprivate var timer: Timer? = nil
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(frame: CGRect) {
        progressAppearance = DottedProgressAppearance()
        super.init(frame: frame)
        setup()
    }

    public init(frame: CGRect, numberOfDots: Int, initialProgress: Int) {
        progressAppearance = DottedProgressAppearance()
        super.init(frame: frame)
        self.numberOfDots = numberOfDots
        self.currentProgress = initialProgress
        setup()
    }

    public init(appearance: DottedProgressAppearance) {
        self.progressAppearance = appearance
        super.init(frame: CGRect.zero)
        setup()
    }

    open func setNumberOfDots(_ count: Int) {
        self.numberOfDots = count
        self.currentProgress = 0
        setup()
    }

    open func startAnimate() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    open func stopAnimate() {
        self.timer?.invalidate()
    }
    open func setProgress(value: Int){
        for i in 0..<numberOfDots {
            let dot = self.subviews[i]
            dot.backgroundColor = progressAppearance.dotsColor
        }
        currentProgress = value
        for i in 0..<currentProgress {
            let dot = self.subviews[i]
            dot.backgroundColor = progressAppearance.dotsProgressColor
        }

    }
    @objc func update(){
        
        if(currentProgress>=numberOfDots){
            for i in 0..<currentProgress {
                let dot = self.subviews[i]
                dot.backgroundColor = progressAppearance.dotsColor
            }
            currentProgress = 0
        }
        self.subviews[currentProgress].backgroundColor = progressAppearance.dotsProgressColor
        currentProgress = currentProgress + 1

    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

}

// MARK: - Private functions

private extension DottedProgressBar {

    func setup() {
        backgroundColor = progressAppearance.backColor

        for i in 0..<numberOfDots {
            let dot = UIView()
            dot.backgroundColor = i < currentProgress ? progressAppearance.dotsProgressColor :
                progressAppearance.dotsColor
            dot.layer.cornerRadius = progressAppearance.dotRadius
            dot.frame = dotFrame(forIndex: i)
            addSubview(dot)
        }
    }

    func layout() {
        for (index, dot) in subviews.enumerated() where dot != walkingDot {
            dot.layer.cornerRadius = progressAppearance.dotRadius
            dot.frame = dotFrame(forIndex: index)
        }
    }

    /// Calculating frame for given index of dot, supports vertical and horizontal alignment.
    ///
    /// - Parameter index: Index of dot (including 0).
    /// - Returns: Frame rectangle for given dot index
    func dotFrame(forIndex index: Int) -> CGRect {
        guard index >= 0 else {
            return dotFrame(forIndex: 0)
        }
        if frame.size.width > frame.size.height {
            let externalFrameWidth: CGFloat = frame.size.width / CGFloat(numberOfDots)
            let externalFrame = CGRect(x: CGFloat(index) * externalFrameWidth,
                                       y: 0, width: externalFrameWidth,
                                       height: frame.size.height)
            return CGRect(x: externalFrame.midX - progressAppearance.dotRadius,
                          y: externalFrame.midY - progressAppearance.dotRadius,
                          width: progressAppearance.dotRadius * 2,
                          height: progressAppearance.dotRadius * 2)
        } else {
            let externalFrameHeight: CGFloat = frame.size.height / CGFloat(numberOfDots)
            let externalFrame = CGRect(x: 0,
                                       y: CGFloat(index) * externalFrameHeight,
                                       width: frame.size.width,
                                       height: externalFrameHeight)
            return CGRect(x: externalFrame.midX - progressAppearance.dotRadius,
                          y: externalFrame.midY - progressAppearance.dotRadius,
                          width: progressAppearance.dotRadius * 2,
                          height: progressAppearance.dotRadius * 2)
        }
    }


}
