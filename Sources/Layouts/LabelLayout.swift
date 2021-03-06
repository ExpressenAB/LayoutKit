// Copyright 2016 LinkedIn Corp.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

/**
 Layout for a UILabel.
 */
open class LabelLayout<Label: UILabel>: BaseLayout<Label>, ConfigurableLayout {

    public let text: Text
    public let font: UIFont
    public let numberOfLines: Int
    public let lineHeight: CGFloat
    public let lineBreakMode: NSLineBreakMode

    public init(text: Text,
                font: UIFont = LabelLayoutDefaults.defaultFont,
                lineHeight: CGFloat? = nil,
                numberOfLines: Int = LabelLayoutDefaults.defaultNumberOfLines,
                lineBreakMode: NSLineBreakMode = LabelLayoutDefaults.defaultLineBreakMode,
                alignment: Alignment = LabelLayoutDefaults.defaultAlignment,
                flexibility: Flexibility = LabelLayoutDefaults.defaultFlexibility,
                viewReuseId: String? = nil,
                viewReuseGroup: String? = nil,
                config: ((Label) -> Void)? = nil) {
        
        self.text = text
        self.numberOfLines = numberOfLines
        self.font = font
        self.lineHeight = lineHeight ?? font.lineHeight
        self.lineBreakMode = lineBreakMode
        super.init(alignment: alignment, flexibility: flexibility, viewReuseId: viewReuseId, viewReuseGroup: viewReuseGroup, config: config)
    }

    init(attributedString: NSAttributedString,
         font: UIFont = LabelLayoutDefaults.defaultFont,
         lineHeight: CGFloat? = nil,
         numberOfLines: Int = LabelLayoutDefaults.defaultNumberOfLines,
         lineBreakMode: NSLineBreakMode = LabelLayoutDefaults.defaultLineBreakMode,
         alignment: Alignment = LabelLayoutDefaults.defaultAlignment,
         flexibility: Flexibility = LabelLayoutDefaults.defaultFlexibility,
         viewReuseId: String? = nil,
         viewReuseGroup: String? = nil,
         viewClass: Label.Type? = nil,
         config: ((Label) -> Void)? = nil) {

        self.text = .attributed(attributedString)
        self.numberOfLines = numberOfLines
        self.font = font
        self.lineHeight = lineHeight ?? font.lineHeight
        self.lineBreakMode = lineBreakMode
        super.init(alignment: alignment, flexibility: flexibility, viewReuseId: viewReuseId, viewReuseGroup: viewReuseGroup, viewClass: viewClass ?? Label.self, config: config) 
    }

    init(string: String,
         font: UIFont = LabelLayoutDefaults.defaultFont,
         lineHeight: CGFloat? = nil,
         numberOfLines: Int = LabelLayoutDefaults.defaultNumberOfLines,
         lineBreakMode: NSLineBreakMode = LabelLayoutDefaults.defaultLineBreakMode,
         alignment: Alignment = LabelLayoutDefaults.defaultAlignment,
         flexibility: Flexibility = LabelLayoutDefaults.defaultFlexibility,
         viewReuseId: String? = nil,
         viewClass: Label.Type? = nil,
         config: ((Label) -> Void)? = nil) {

        self.text = .unattributed(string)
        self.numberOfLines = numberOfLines
        self.font = font
        self.lineHeight = lineHeight ?? font.lineHeight
        self.lineBreakMode = lineBreakMode
        super.init(alignment: alignment, flexibility: flexibility, viewReuseId: viewReuseId, viewClass: viewClass ?? Label.self, config: config)
    }

    // MARK: - Convenience initializers

    public convenience init(text: String,
                            font: UIFont = LabelLayoutDefaults.defaultFont,
                            lineHeight: CGFloat? = nil,
                            numberOfLines: Int = LabelLayoutDefaults.defaultNumberOfLines,
                            lineBreakMode: NSLineBreakMode = LabelLayoutDefaults.defaultLineBreakMode,
                            alignment: Alignment = LabelLayoutDefaults.defaultAlignment,
                            flexibility: Flexibility = LabelLayoutDefaults.defaultFlexibility,
                            viewReuseId: String? = nil,
                            viewReuseGroup: String? = nil,
                            config: ((Label) -> Void)? = nil) {

        self.init(text: .unattributed(text),
                  font: font,
                  lineHeight: lineHeight,
                  numberOfLines: numberOfLines,
                  lineBreakMode: lineBreakMode,
                  alignment: alignment,
                  flexibility: flexibility,
                  viewReuseId: viewReuseId,
                  viewReuseGroup: viewReuseGroup,
                  config: config)
    }

    public convenience init(attributedText: NSAttributedString,
                            font: UIFont = LabelLayoutDefaults.defaultFont,
                            lineHeight: CGFloat? = nil,
                            numberOfLines: Int = LabelLayoutDefaults.defaultNumberOfLines,
                            lineBreakMode: NSLineBreakMode = LabelLayoutDefaults.defaultLineBreakMode,
                            alignment: Alignment = LabelLayoutDefaults.defaultAlignment,
                            flexibility: Flexibility = LabelLayoutDefaults.defaultFlexibility,
                            viewReuseId: String? = nil,
                            viewReuseGroup: String? = nil,
                            config: ((Label) -> Void)? = nil) {

        self.init(text: .attributed(attributedText),
                  font: font,
                  lineHeight: lineHeight,
                  numberOfLines: numberOfLines,
                  lineBreakMode: lineBreakMode,
                  alignment: alignment,
                  flexibility: flexibility,
                  viewReuseId: viewReuseId,
                  viewReuseGroup: viewReuseGroup,
                  config: config)
    }

    // MARK: - Layout protocol

    open func measurement(within maxSize: CGSize) -> LayoutMeasurement {
        let fittedSize = textSize(within: maxSize)
        return LayoutMeasurement(layout: self, size: fittedSize.decreasedToSize(maxSize), maxSize: maxSize, sublayouts: [])
    }

    private func textSize(within maxSize: CGSize) -> CGSize {
        var size = text.textSize(within: maxSize, font: font, lineBreakMode: lineBreakMode)
        if numberOfLines > 0 {
            let maxHeight = (CGFloat(numberOfLines) * lineHeight).roundedUpToFractionalPoint
            if size.height > maxHeight {
                size = CGSize(width: maxSize.width, height: maxHeight)
            }
        }
        return size
    }

    open func arrangement(within rect: CGRect, measurement: LayoutMeasurement) -> LayoutArrangement {
        let frame = alignment.position(size: measurement.size, in: rect)
        return LayoutArrangement(layout: self, frame: frame, sublayouts: [])
    }

    open override func configure(view label: Label) {
        config?(label)

        // Workaround for when re-using a UILabel with attributedText and
        // then using the text property for updating the text. This caused
        // text to be rendered in a defect way eg. truncating text even if
        // there are enough space for the whole text.
        label.text = nil

        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
        label.font = font
        switch text {
        case .unattributed(let text):
            label.text = text
        case .attributed(let attributedText):
            label.attributedText = attributedText
        }
    }

    open override var needsView: Bool {
        return true
    }
}

// MARK: - Things that belong in LabelLayout but aren't because LabelLayout is generic.
// "Static stored properties not yet supported in generic types"

public class LabelLayoutDefaults {
    public static let defaultNumberOfLines = 0
    public static let defaultFont = UIFont.systemFont(ofSize: 17)
    public static let defaultAlignment = Alignment.topLeading
    public static let defaultLineBreakMode = NSLineBreakMode.byTruncatingTail
    public static let defaultFlexibility = Flexibility.flexible
}

