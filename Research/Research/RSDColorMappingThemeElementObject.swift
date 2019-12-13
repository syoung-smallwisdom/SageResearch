//
//  RSDColorMappingThemeElementObject.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// A color data object is a light-weight codable implementation for storing custom color data.
public struct RSDColorDataObject : Codable, RSDColorData {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case colorIdentifier = "color", usesLightStyle
    }
    
    /// The color identifier. Typically, the name in an asset catalog or a hexcode.
    public let colorIdentifier: String
    
    /// Whether or not text and images displayed on top of this color should use light style.
    public let usesLightStyle : Bool
    
    public init(colorIdentifier: String, usesLightStyle : Bool) {
        self.colorIdentifier = colorIdentifier
        self.usesLightStyle = usesLightStyle
    }
}

/// `RSDColorPlacementThemeElementObject` tells the UI what the background color and foreground color are for
/// a given view as well as whether or not the foreground elements should use "light style".
///
/// The mapping is handled using a dictionary of color placements to the color style for that placement.
public struct RSDColorPlacementThemeElementObject : RSDColorMappingThemeElement, RSDDecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case type, bundleIdentifier, packageName, placement, customColor
    }

    /// The type for the class
    public let type: RSDColorMappingThemeElementType

    /// The color placement mapping.
    let placement: [String : RSDColorStyle]
    
    /// The custom color tile to use for a color placement.
    let customColor: RSDColorDataObject?
    
    /// The bundle identifier.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: RSDResourceBundle? = nil
    
    /// The Android package name.
    public var packageName: String?

    /// Default initializer.
    ///
    /// - parameters:
    ///     - placement: The placement mapping for the sections of the view.
    ///     - customColorName: The name of the custom color.
    ///     - usesLightStyle: If using a custom color, the light style for the custom color.
    ///     - bundleIdentifier: The bundle identifier if using a color asset file.
    public init(placement: [String : RSDColorStyle],
                customColorName: String? = nil,
                usesLightStyle: Bool = false,
                bundleIdentifier: String? = nil,
                packageName: String? = nil) {
        self.type = .placementMapping
        self.placement = placement
        if let name = customColorName {
            self.customColor = RSDColorDataObject(colorIdentifier: name, usesLightStyle: usesLightStyle)
        }
        else {
            self.customColor = nil
        }
        self.bundleIdentifier = bundleIdentifier
        self.packageName = packageName
    }
    
    /// The custom color used by this theme element.
    public var customColorData: RSDColorData? {
        return self.customColor
    }
    
    /// The background color style for a given placement.
    public func backgroundColorStyle(for placement: RSDColorPlacement) -> RSDColorStyle {
        if let style = self.placement[placement.stringValue] {
            return style
        }
        else {
            return ((self.customColor != nil) ? .custom : .background)
        }
    }
}

extension RSDColorPlacementThemeElementObject : RSDDocumentableDecodableObject {

    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    static func colorThemeExamples() -> [[String : RSDJSONValue]] {
        let exA: [String : RSDJSONValue] = [
            "type" : "placementMapping",
            "bundleIdentifier" : "FooModule",
            "packageName" : "org.sagebase.foo",
            "customColor" : [ "color" : "sky", "usesLightStyle" : false],
            "placement" : [
                "header" : "primary",
                "body" : "white",
                "footer" : "white"
            ]
        ]
        return [exA]
    }

    static func examples() -> [[String : RSDJSONValue]] {
        return colorThemeExamples()
    }
}

/// `RSDSingleColorThemeElementObject` tells the UI what the background color and foreground color are for
/// a given view as well as whether or not the foreground elements should use "light style".
///
/// The mapping is handled using a single style for the entire view.
public struct RSDSingleColorThemeElementObject : RSDColorMappingThemeElement, RSDDecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case type, bundleIdentifier, packageName, colorStyle, customColor
    }
    
    /// The type for the class
    public let type: RSDColorMappingThemeElementType
    
    /// The bundle identifier.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: RSDResourceBundle? = nil
    
    /// The Android package name.
    public var packageName: String?
    
    /// The color placement mapping.
    let colorStyle: RSDColorStyle?
    
    /// The custom color tile to use for a color placement.
    let customColor: RSDColorDataObject?
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - colorStyle: The color style for this mapping.
    ///     - customColorName: The name of the custom color.
    ///     - usesLightStyle: If using a custom color, the light style for the custom color.
    ///     - bundleIdentifier: The bundle identifier if using a color asset file.
    public init(colorStyle: RSDColorStyle?,
                customColorName: String? = nil,
                usesLightStyle: Bool = false,
                bundleIdentifier: String? = nil,
                packageName: String? = nil) {
        self.type = .singleColor
        self.colorStyle = colorStyle
        if let name = customColorName {
            self.customColor = RSDColorDataObject(colorIdentifier: name, usesLightStyle: usesLightStyle)
        }
        else {
            self.customColor = nil
        }
        self.bundleIdentifier = bundleIdentifier
        self.packageName = packageName
    }
    
    /// The custom color used by this theme element.
    public var customColorData: RSDColorData? {
        return self.customColor
    }
    
    /// The background color style for a given placement.
    public func backgroundColorStyle(for placement: RSDColorPlacement) -> RSDColorStyle {
        return colorStyle ?? ((self.customColor != nil) ? .custom : .white)
    }
}

extension RSDSingleColorThemeElementObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    static func colorThemeExamples() -> [[String : RSDJSONValue]] {
        let exA: [String : RSDJSONValue] = [
            "type" : "singleColor",
            "bundleIdentifier" : "FooModule",
            "packageName" : "org.sagebase.foo",
            "customColor" : [ "color" : "sky", "usesLightStyle" : false]
        ]
        let exB: [String : RSDJSONValue] = [
            "type" : "singleColor",
            "colorStyle" : "successGreen"
        ]
        return [exA, exB]
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        return colorThemeExamples()
    }
}
