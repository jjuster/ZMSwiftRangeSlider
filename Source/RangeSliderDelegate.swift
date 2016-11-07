import UIKit

public protocol RangeSliderDelegate {

    func rangeSliderValueChanged(_ sender: RangeSlider, minValue: Int, maxValue: Int)

    func rangeSliderMinValueDisplayText(_ sender: RangeSlider, minValue: Int) -> String?

    func rangeSliderMaxValueDisplayText(_ sender: RangeSlider, maxValue: Int) -> String?
}
