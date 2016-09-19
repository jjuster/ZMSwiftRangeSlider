import UIKit

class TrackLayer: CALayer {

    weak var rangeSlider: RangeSlider?

    override func drawInContext(ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }

        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height * 0.5)
        CGContextAddPath(ctx, path.CGPath)

        CGContextSetFillColorWithColor(ctx, slider.trackTintColor.CGColor)
        CGContextAddPath(ctx, path.CGPath)
        CGContextFillPath(ctx)

        let color = slider.maxValue == -1 ? slider.trackTintColor : slider.trackHighlightTintColor
        
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        let minValueOffsetX = slider.position(slider.minValue)
        
        let maxValue = slider.maxValue == -1 ? slider.maxRange() : slider.maxValue
        
        let maxValueOffsetX = slider.position(maxValue)
        let rect = CGRect(x: minValueOffsetX, y: 0.0, width: maxValueOffsetX - minValueOffsetX, height: bounds.height)
        CGContextFillRect(ctx, rect)
    }
}
