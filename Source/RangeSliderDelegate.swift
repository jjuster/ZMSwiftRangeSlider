import UIKit

public protocol RangeSliderDelegate {

    func rangeSliderValueChanged(sender: RangeSlider, minValue: Int, maxValue: Int)

    func rangeSliderMinValueDisplayText(sender: RangeSlider, minValue: Int) -> String?

    func rangeSliderMaxValueDisplayText(sender: RangeSlider, maxValue: Int) -> String?
}
