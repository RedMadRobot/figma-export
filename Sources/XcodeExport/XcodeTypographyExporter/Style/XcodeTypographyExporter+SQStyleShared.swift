//
//  File.swift
//  
//
//  Created by Semen Kologrivov on 19.01.2022.
//

import Foundation

extension XcodeTypographyExporter {

    func alignments(forStyle style: String) -> String {
        """
        @objc lazy var centrerAlignment: \(style) = {
            self.textAlignment = .center
            return self
        }()

        @objc lazy var leftAlignment: \(style) = {
            self.textAlignment = .left
            return self
        }()

        @objc lazy var rightAlignment: \(style) = {
            self.textAlignment = .right
            return self
        }()
        """
    }

    func lineBreaks(forStyle style: String) -> String {
        """
        @objc lazy var lineBreakModeByWordWrapping: \(style) = {
            self.lineBreakMode = .byWordWrapping
            return self
        }()

        @objc lazy var lineBreakModeByCharWrapping: \(style) = {
            self.lineBreakMode = .byCharWrapping
            return self
        }()

        @objc lazy var lineBreakModeByClipping: \(style) = {
            self.lineBreakMode = .byClipping
            return self
        }()

        @objc lazy var lineBreakModeByTruncatingHead: \(style) = {
            self.lineBreakMode = .byTruncatingHead
            return self
        }()

        @objc lazy var lineBreakModeByTruncatingTail: \(style) = {
            self.lineBreakMode = .byTruncatingTail
            return self
        }()

        @objc lazy var lineBreakModeByTruncatingMiddle: \(style) = {
            self.lineBreakMode = .byTruncatingMiddle
            return self
        }()
        """
    }

    func strikethroughTypes(forStyle style: String) -> String {
        """
        @objc lazy var strikethroughStyleSingle: \(style) = {
            self.strikethroughStyle = .single
            return self
        }()

        @objc lazy var strikethroughStyleThick: \(style) = {
            self.strikethroughStyle = .thick
            return self
        }()

        @objc lazy var strikethroughStyleDouble: \(style) = {
            self.strikethroughStyle = .double
            return self
        }()

        @objc lazy var strikethroughStylePatternDot: \(style) = {
            self.strikethroughStyle = .patternDot
            return self
        }()

        @objc lazy var strikethroughStylePatternDash: \(style) = {
            self.strikethroughStyle = .patternDash
            return self
        }()

        @objc lazy var strikethroughStylePatternDashDot: \(style) = {
            self.strikethroughStyle = .patternDashDot
            return self
        }()

        @objc lazy var strikethroughStylePatternDashDotDot: \(style) = {
            self.strikethroughStyle = .patternDashDotDot
            return self
        }()

        @objc lazy var strikethroughStyleByWord: \(style) = {
            self.strikethroughStyle = .byWord
            return self
        }()
        """
    }

    func underlineTypes(forStyle style: String) -> String {
        """
        @objc lazy var underlineStyleSingle: \(style) = {
            self.underlineStyle = .single
            return self
        }()

        @objc lazy var underlineStyleThick: \(style) = {
            self.underlineStyle = .thick
            return self
        }()

        @objc lazy var underlineStyleDouble: \(style) = {
            self.underlineStyle = .double
            return self
        }()

        @objc lazy var underlineStylePatternDot: \(style) = {
            self.underlineStyle = .patternDot
            return self
        }()

        @objc lazy var underlineStylePatternDash: \(style) = {
            self.underlineStyle = .patternDash
            return self
        }()

        @objc lazy var underlineStylePatternDashDot: \(style) = {
            self.underlineStyle = .patternDashDot
            return self
        }()

        @objc lazy var underlineStylePatternDashDotDot: \(style) = {
            self.underlineStyle = .patternDashDotDot
            return self
        }()

        @objc lazy var underlineStyleByWord: \(style) = {
            self.underlineStyle = .byWord
            return self
        }()
        """
    }

}
