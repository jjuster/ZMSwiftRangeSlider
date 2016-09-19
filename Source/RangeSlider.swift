import UIKit

@IBDesignable
public class RangeSlider: UIControl {

    private let trackLayer = TrackLayer()
    private let minValueThumbLayer = ThumbLayer()
    private let minValueDisplayLayer = TextLayer()
    private let maxValueThumbLayer = ThumbLayer()
    private let maxValueDisplayLayer = TextLayer()

    private var beginTrackLocation = CGPointZero
    private var rangeValues = Array(0...100)

    var minValue: Int
    var maxValue: Int
    var thumbRadius: CGFloat

    public var delegate: RangeSliderDelegate?

    public override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable public var trackHeight: CGFloat = 6.0 {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable public var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable public var trackHighlightTintColor: UIColor = UIColor(red: 2.0 / 255, green: 192.0 / 255, blue: 92.0 / 255, alpha: 1.0) {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable public var thumbSize: CGFloat = 32.0 {
        didSet {
            thumbRadius = thumbSize / 2.0
            updateLayerFrames()
        }
    }

    @IBInspectable public var thumbOutlineSize: CGFloat = 2.0 {
        didSet {
            updateLayerFrames()
        }
    }

    @IBInspectable public var displayTextFontSize: CGFloat = 14.0 {
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

    public override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        updateLayerFrames()
    }

    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        beginTrackLocation = touch.locationInView(self)
        if minValueThumbLayer.frame.contains(beginTrackLocation) {
            minValueThumbLayer.isHighlight = true
        } else if maxValueThumbLayer.frame.contains(beginTrackLocation) {
            maxValueThumbLayer.isHighlight = true
        }

        return minValueThumbLayer.isHighlight || maxValueThumbLayer.isHighlight
    }

    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
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
            if index > rangeValues.indexOf(maxV)! {
                minValue = maxV
            } else {
                minValue = rangeValues[index]
            }
        } else if maxValue != -1 && maxValueThumbLayer.isHighlight {
            if index < rangeValues.indexOf(minValue)! {
                maxValue = minValue
            } else {
                maxValue = rangeValues[index]
            }
        }
        updateLayerFrames()
        
        delegate?.rangeSliderValueChanged(self, minValue: minValue, maxValue: maxValue)
        
        return true
    }
    
    public func minRange() -> Int {
        return rangeValues[0]
    }
    
    public func maxRange() -> Int {
        return rangeValues[rangeValues.count - 1]
    }
    
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        minValueThumbLayer.isHighlight = false
        maxValueThumbLayer.isHighlight = false
    }

    @nonobjc
    public func setRangeValues(rangeValues: [Int]) {
        self.rangeValues = rangeValues
        setMinAndMaxValue(rangeValues[0], maxValue: rangeValues[rangeValues.count - 1])
    }

    public func setMinAndMaxValue(minValue: Int, maxValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        
        if maxValue == -1 {
            maxValueThumbLayer.hidden = true
            maxValueDisplayLayer.hidden = true
        }
        
        updateLayerFrames()
    }

    func setupLayers() {
        layer.backgroundColor = UIColor.clearColor().CGColor

        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)

        minValueThumbLayer.rangeSlider = self
        minValueThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(minValueThumbLayer)

        minValueDisplayLayer.rangeSlider = self
        minValueDisplayLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(minValueDisplayLayer)

        maxValueThumbLayer.rangeSlider = self
        maxValueThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(maxValueThumbLayer)

        maxValueDisplayLayer.rangeSlider = self
        maxValueDisplayLayer.contentsScale = UIScreen.mainScreen().scale
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

        minValueDisplayLayer.frame = CGRect(x: minValuePosition,
                                            y: displayLayerOffsetY,
                                            width: thumbSize,
                                            height: displayTextFontSize)

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
                                              width: thumbSize * 2.0,
                                              height: thumbSize)
            maxValueThumbLayer.setNeedsDisplay()

            maxValueDisplayLayer.frame = CGRect(x: maxValuePosition,
                                                y: displayLayerOffsetY,
                                                width: thumbSize * 2.0,
                                                height: displayTextFontSize)

            if let maxValueDisplayText = delegate?.rangeSliderMaxValueDisplayText(self, maxValue: maxValue) {
                maxValueDisplayLayer.string = maxValueDisplayText
            } else {
                maxValueDisplayLayer.string = "\(maxValue)"
            }

            maxValueDisplayLayer.setNeedsDisplay()
        }
        
        CATransaction.commit()
    }

    func position(value: Int) -> CGFloat {
        let index = rangeValues.indexOf(value)!
        let count = rangeValues.count
        if index == 0 {
            return thumbRadius
        } else if index == count - 1 {
            return bounds.width - thumbRadius
        }

        return (bounds.width - thumbSize) * CGFloat(index) / CGFloat(count) + thumbRadius
    }
}
