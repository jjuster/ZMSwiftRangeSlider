import UIKit

@IBDesignable
open class RangeSlider: UIControl {

    fileprivate let trackLayer = TrackLayer()
    fileprivate let minValueThumbLayer = ThumbLayer()
    fileprivate let minValueDisplayLayer = TextLayer()
    fileprivate let maxValueThumbLayer = ThumbLayer()
    fileprivate let maxValueDisplayLayer = TextLayer()

    fileprivate var beginTrackLocation = CGPoint.zero
    fileprivate var rangeValues = Array(0...100)

    var minValue: Int
    var maxValue: Int
    var thumbRadius: CGFloat

    open var delegate: RangeSliderDelegate?

    open override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var trackHeight: CGFloat = 6.0 {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable open var thumbTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable open var trackHighlightTintColor: UIColor = UIColor(red: 2.0 / 255, green: 192.0 / 255, blue: 92.0 / 255, alpha: 1.0) {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var thumbSize: CGFloat = 32.0 {
        didSet {
            thumbRadius = thumbSize / 2.0
            updateLayerFrames()
        }
    }

    @IBInspectable open var thumbOutlineSize: CGFloat = 2.0 {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable open var displayTextFontSize: CGFloat = 14.0 {
        didSet {
            updateLayerFrames()
        }
    }

    public override init(frame: CGRect) {
        minValue = rangeValues[0]
        maxValue = rangeValues[rangeValues.count - 1]
        thumbRadius = thumbSize / 2.0
        super.init(frame: frame)
        setupLayers()
    }

    public required init?(coder aDecoder: NSCoder) {
        minValue = rangeValues[0]
        maxValue = rangeValues[rangeValues.count - 1]
        thumbRadius = thumbSize / 2.0
        super.init(coder: aDecoder)
        setupLayers()
    }

    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerFrames()
    }

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        beginTrackLocation = touch.location(in: self)
        if minValueThumbLayer.frame.contains(beginTrackLocation) {
            minValueThumbLayer.isHighlight = true
        } else if maxValueThumbLayer.frame.contains(beginTrackLocation) {
            maxValueThumbLayer.isHighlight = true
        }

        return minValueThumbLayer.isHighlight || maxValueThumbLayer.isHighlight
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let count = rangeValues.count
        var index = Int(location.x * CGFloat(count) / (bounds.width - thumbSize))

        let maxV = maxValue == -1 ? rangeValues[rangeValues.count - 1] : maxValue
        
        if maxV == minValue && location.x > beginTrackLocation.x && !maxValueThumbLayer.isHighlight {
            maxValueThumbLayer.isHighlight = true
            minValueThumbLayer.isHighlight = false
        }

        if index < 0 {
            index = 0
        } else if index > count - 1 {
            index = count - 1
        }

        if minValueThumbLayer.isHighlight {
            if index > rangeValues.index(of: maxV)! {
                minValue = maxV
            } else {
                minValue = rangeValues[index]
            }
        } else if maxValue != -1 && maxValueThumbLayer.isHighlight {
            if index < rangeValues.index(of: minValue)! {
                maxValue = minValue
            } else {
                maxValue = rangeValues[index]
            }
        }
        updateLayerFrames()
        
        return true
    }
    
    open func minRange() -> Int {
        return rangeValues[0]
    }
    
    open func maxRange() -> Int {
        return rangeValues[rangeValues.count - 1]
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        minValueThumbLayer.isHighlight = false
        maxValueThumbLayer.isHighlight = false
        delegate?.rangeSliderValueChanged(self, minValue: minValue, maxValue: maxValue)        
    }

    @nonobjc
    open func setRangeValues(_ rangeValues: [Int]) {
        self.rangeValues = rangeValues
        setMinAndMaxValue(rangeValues[0], maxValue: rangeValues[rangeValues.count - 1])
    }

    open func setMinAndMaxValue(_ minValue: Int, maxValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        
        if maxValue == -1 {
            maxValueThumbLayer.isHidden = true
            maxValueDisplayLayer.isHidden = true
        }
        
        updateLayerFrames()
    }

    func setupLayers() {
        layer.backgroundColor = UIColor.clear.cgColor

        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)

        minValueThumbLayer.rangeSlider = self
        minValueThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(minValueThumbLayer)

        minValueDisplayLayer.rangeSlider = self
        minValueDisplayLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(minValueDisplayLayer)

        maxValueThumbLayer.rangeSlider = self
        maxValueThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(maxValueThumbLayer)

        maxValueDisplayLayer.rangeSlider = self
        maxValueDisplayLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(maxValueDisplayLayer)
    }

    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        trackLayer.frame = CGRect(x: 0,
                                  y: (bounds.height - trackHeight + 1) / 2,
                                  width: bounds.width,
                                  height: trackHeight)
        trackLayer.setNeedsDisplay()

        let offsetY = (bounds.height - thumbSize) / 2.0
        let displayLayerOffsetY = offsetY - thumbRadius - 6

        let minValuePosition = position(minValue) - thumbRadius
        minValueThumbLayer.frame = CGRect(x: minValuePosition,
                                          y: offsetY,
                                          width: thumbSize,
                                          height: thumbSize)
        minValueThumbLayer.setNeedsDisplay()

        minValueDisplayLayer.frame = CGRect(x: minValuePosition - thumbRadius,
                                            y: displayLayerOffsetY,
                                            width: thumbSize * 2.0,
                                            height: displayTextFontSize * 1.5)

        if let minValueDisplayText = delegate?.rangeSliderMinValueDisplayText(self, minValue: minValue) {
            minValueDisplayLayer.string = minValueDisplayText
        } else {
            minValueDisplayLayer.string = "\(minValue)"
        }

        minValueDisplayLayer.setNeedsDisplay()

        if maxValue != -1 {
            let maxValuePosition = position(maxValue) - thumbRadius
            maxValueThumbLayer.frame = CGRect(x: maxValuePosition,
                                              y: offsetY,
                                              width: thumbSize,
                                              height: thumbSize)
            maxValueThumbLayer.setNeedsDisplay()

            maxValueDisplayLayer.frame = CGRect(x: maxValuePosition - thumbRadius,
                                                y: displayLayerOffsetY,
                                                width: thumbSize * 2.0,
                                                height: displayTextFontSize * 1.5)

            if let maxValueDisplayText = delegate?.rangeSliderMaxValueDisplayText(self, maxValue: maxValue) {
                maxValueDisplayLayer.string = maxValueDisplayText
            } else {
                maxValueDisplayLayer.string = "\(maxValue)"
            }

            maxValueDisplayLayer.setNeedsDisplay()
        }
        
        CATransaction.commit()
    }

    func position(_ value: Int) -> CGFloat {
        let index = rangeValues.index(of: value)!
        let count = rangeValues.count
        if index == 0 {
            return thumbRadius
        } else if index == count - 1 {
            return bounds.width - thumbRadius
        }

        return (bounds.width - thumbSize) * CGFloat(index) / CGFloat(count) + thumbRadius
    }
}
