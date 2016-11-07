import UIKit

class TrackLayer: CALayer {

    weak var rangeSlider: RangeSlider?

    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }

        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height * 0.5)
        ctx.addPath(path.cgPath)

        ctx.setFillColor(slider.trackTintColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()

        let color = slider.maxValue == -1 ? slider.trackTintColor : slider.trackHighlightTintColor
        
        ctx.setFillColor(color.cgColor)
        let minValueOffsetX = slider.position(slider.minValue)
        
        let maxValue = slider.maxValue == -1 ? slider.maxRange() : slider.maxValue
        
        let maxValueOffsetX = slider.position(maxValue)
        let rect = CGRect(x: minValueOffsetX, y: 0.0, width: maxValueOffsetX - minValueOffsetX, height: bounds.height)
        ctx.fill(rect)
    }
}
