//
//  RSDTextFieldOptions.swift
//  Research
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

/// `RSDTextFieldOptions` defines the options for a text field.
///
/// - seealso: `RSDInputField` and `RSDFormStepDataSource`
public protocol RSDTextFieldOptions {
    
    /// A custom text validator that can be used to validate a string.
    var textValidator: RSDTextValidator? { get }
    
    /// The localized text presented to the user when invalid input is received.
    var invalidMessage: String? { get }
    
    /// The maximum length of the text users can enter. When the value of this property is 0, there
    /// is no maximum.
    var maximumLength: Int { get }
    
    /// Is the text field for password entry?
    var isSecureTextEntry: Bool { get }
    
    /// Auto-capitalization type for the text field.
    var autocapitalizationType: RSDTextAutocapitalizationType { get }
    
    /// Auto-correction type for the text field.
    var autocorrectionType: RSDTextAutocorrectionType { get }
    
    /// Spell checking type for the text field.
    var spellCheckingType: RSDTextSpellCheckingType { get }
    
    /// Keyboard type for the text field.
    var keyboardType: RSDKeyboardType { get }
}

public protocol RSDTextValidator {

    /// Whether or not the text is considered valid.
    /// - returns: `true` if the string is valid. Otherwise, returns `false`.
    /// - throws: Error if the regular expression cannot be instantiated.
    func isValid(_ string: String) throws -> Bool
}

public protocol RSDRegExMatchValidator : RSDTextValidator {
    
    /// A localized custom regular expression that can be used to validate a string.
    /// - returns: The regular expression to use in validation.
    /// - throws: Error if the regular expression cannot be instantiated.
    func regularExpression() throws -> NSRegularExpression
}

public protocol RSDCodableRegExMatchValidator : RSDRegExMatchValidator {
    
    /// The regular expression pattern used to create the `NSRegularExpression` object.
    var regExPattern: String { get }
}

extension RSDCodableRegExMatchValidator {
    
    /// A localized custom regular expression that can be used to validate a string.
    public func regularExpression() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: regExPattern, options: [])
    }
}

extension RSDRegExMatchValidator {
    
    /// Method for evaluating a string against the `validationRegex` for a match.
    /// - paramater string: The string to evaluate.
    /// - returns: The number of matches found.
    /// - throws: If the regular expression cannot be created.
    public func regExMatches(_ string: String) throws -> Int {
        let expression = try regularExpression()
        return expression.numberOfMatches(in: string, options: [], range: NSRange(string.startIndex..., in: string))
    }
    
    /// Test the string against the validation regular expression and return `true` if there is one or more
    /// matches to the given string.
    /// - paramater string: The string to evaluate.
    /// - returns: Whether or not the string is valid.
    /// - throws: If the regular expression cannot be created.
    public func isValid(_ string: String) throws -> Bool {
        let count = try self.regExMatches(string)
        return count > 0
    }
}


/// `Codable` enum for the auto-capitalization type for an input text field.
/// - keywords: ["none", "words", "sentences", "allCharacters"]
public enum RSDTextAutocapitalizationType : String, Codable, RSDStringEnumSet {
    case none, words, sentences, allCharacters
    
    public static var all: Set<RSDTextAutocapitalizationType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextAutocapitalizationType] {
        return [.none, .words, .sentences, .allCharacters]
    }

    public func rawIntValue() -> Int? {
        return RSDTextAutocapitalizationType.orderedSet.firstIndex(of: self)
    }
}

extension RSDTextAutocapitalizationType : RSDDocumentableStringEnum {
}


/// `Codable` enum for the auto-capitalization type for an input text field.
/// - keywords: ["default", "no", yes"]
public enum RSDTextAutocorrectionType : String, Codable, RSDStringEnumSet {
    case `default`, no, yes
    
    public static var all: Set<RSDTextAutocorrectionType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextAutocorrectionType] {
        return [.default, .no, .yes]
    }
    
    public func rawIntValue() -> Int? {
        return RSDTextAutocorrectionType.orderedSet.firstIndex(of: self)
    }
}

extension RSDTextAutocorrectionType : RSDDocumentableStringEnum {
}


/// `Codable` enum for the spell checking type for an input text field.
/// - keywords: ["default", "no", yes"]
public enum RSDTextSpellCheckingType  : String, Codable, RSDStringEnumSet {
    case `default`, no, yes
    
    public static var all: Set<RSDTextSpellCheckingType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextSpellCheckingType] {
        return [.default, .no, .yes]
    }

    public func rawIntValue() -> Int? {
        return RSDTextSpellCheckingType.orderedSet.firstIndex(of: self)
    }
}

extension RSDTextSpellCheckingType : RSDDocumentableStringEnum {
}


/// `Codable` enum for the spell checking type for an input text field.
/// - keywords: [ "default", "asciiCapable", "numbersAndPunctuation", "URL",
///               "numberPad", "phonePad", "namePhonePad", "emailAddress",
///               "decimalPad", "twitter", "webSearch", "asciiCapableNumberPad"]
public enum RSDKeyboardType  : String, Codable, RSDStringEnumSet {
    case `default`, asciiCapable, numbersAndPunctuation, URL, numberPad, phonePad, namePhonePad, emailAddress, decimalPad, twitter, webSearch, asciiCapableNumberPad
    
    public static var all: Set<RSDKeyboardType> {
        return Set(orderedSet)
    }

    static var orderedSet: [RSDKeyboardType] {
        return [.default, .asciiCapable, .numbersAndPunctuation, .URL, .numberPad, .phonePad, .namePhonePad, .emailAddress, .decimalPad, .twitter, .webSearch, .asciiCapableNumberPad]
    }

    public func rawIntValue() -> Int? {
        return RSDKeyboardType.orderedSet.firstIndex(of: self)
    }
}

extension RSDKeyboardType : RSDDocumentableStringEnum {
}
