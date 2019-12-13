//
//  RSDResourceTransformer.swift
//  Research
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/// `RSDDecodableBundleInfo` is a convenience protocol for getting a bundle from a bundle identifier.
public protocol RSDDecodableBundleInfo : Decodable, RSDResourceInfo {
    
    /// The bundle identifier. Decodable identifier that can be used to get the bundle.
    var bundleIdentifier : String? { get }
    
    /// A pointer to the bundle set by the factory (if applicable).
    var factoryBundle: RSDResourceBundle? { get set }
    
    /// The package name (if applicable)
    var packageName: String? { get set }
}

extension Bundle : RSDResourceBundle {
}

extension RSDResourceInfo {
    
    /// The bundle returned for the given `bundleIdentifier` or `factoryBundle` if `nil`.
    public var bundle: Bundle? {
        guard let identifier = bundleIdentifier
            else {
                return self.factoryBundle as? Bundle
        }
        return Bundle(identifier: identifier)
    }
}


/// `RSDResourceTransformer` is a protocol for getting either embedded resources or online resources.
///
/// - seealso: `RSDStepResourceTransformer` and `RSDTaskResourceTransformer`
///
public protocol RSDResourceTransformer: RSDDecodableBundleInfo {
    
    /// Either a fully qualified URL string or else a relative reference to either an embedded resource or
    /// a relative URL defined globally by overriding the `RSDResourceConfig` class methods.
    var resourceName: String { get }
    
    /// The classType for converting the resource to an object.
    var classType: String? { get }
}

extension RSDResourceTransformer {
    
    /// The estimated time required to fetch the resource.
    public var estimatedFetchTime: TimeInterval {
        return isOnlineResourceURL() ? 60 : 0
    }
    
    /// Whether or not the resource is an online URL or from an embedded resource bundle.
    /// - returns: `true` if the resource is an online URL or `false` if it is an embedded resource.
    public func isOnlineResourceURL() -> Bool {
        return resourceName.hasPrefix("http")
    }
    
    /// Get the full URL for a given resource no matter if it is a local or online resource.
    ///
    /// - returns: The URL for this resource.
    /// - throws: `RSDResourceTransformerError` if the file cannot be found, or
    ///           `RSDValidationError` if the online resource is not valid.
    public func fullURL() throws -> URL {
        if self.isOnlineResourceURL() {
            guard let url = URL(string: resourceName) else {
                throw RSDValidationError.unexpectedNullObject("Failed to convert \(resourceName) to a URL.")
            }
            return url
        }
        else {
            return try resourceURL().url
        }
    }
    
    /// Get the URL for a given resource. This can return either a URL to an online resource or a URL
    /// for an embedded resource.
    ///
    /// - parameters:
    ///     - defaultExtension: The default extension for the URL. If `nil` then the `resourceName` will be inspected
    ///                         for a file extension. If that is `nil` then "json" will be assumed.
    ///     - bundle: The bundle to use for fetching the resource. If `nil` then the `RSDResourceConfig` will be used.
    /// - returns:
    ///     - url: The returned URL for this resource.
    ///     - resourceType: The resource type.
    /// - throws: `RSDResourceTransformerError` if the file cannot be found.
    public func resourceURL(ofType defaultExtension: String? = nil, bundle: RSDResourceBundle? = nil) throws -> (url: URL, resourceType: RSDResourceType) {
        
        // get the resource name and extension
        let splitValue = resourceName.splitFilename(defaultExtension: defaultExtension)
        let resource = splitValue.resourceName
        let ext = splitValue.fileExtension ?? RSDResourceType.json.rawValue
        let resourceType = RSDResourceType(rawValue: ext)
        
        // get the bundle
        let rBundle: Bundle
        if let inBundle = bundle as? Bundle {
            rBundle = inBundle
        }
        else if let factoryBundle = self.bundle {
            rBundle = factoryBundle
        }
        else if let bundleIdentifier = self.bundleIdentifier {
            let bundleIds = Bundle.allBundles.compactMap { $0.bundleIdentifier }
            throw RSDResourceTransformerError.bundleNotFound("\(bundleIdentifier) Not Found. Available identifiers: \(bundleIds.joined(separator: ","))")
        }
        else {
            rBundle = Bundle.main
        }

        // get the url
        guard let url = rBundle.url(forResource: resource, withExtension: ext) else {
            throw RSDResourceTransformerError.fileNotFound("\(resource) not found in \(String(describing: rBundle.bundleIdentifier))")
        }
        
        return (url, resourceType)
    }
    
    
    /// Get the `Data` for a given resource. This is used to get data from an embedded resource.
    ///
    /// - returns:
    ///     - data: The returned Data for this resource.
    ///     - resourceType: The resource type.
    /// - throws: `RSDResourceTransformerError` if the file cannot be found.
    public func resourceData() throws -> (data: Data, resourceType: RSDResourceType) {
        return try _resourceData(ofType: nil, bundle: nil)
    }
    
    /// Get the `Data` for a given resource. This is used to get data from an embedded resource.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to get bundle or package information about a resource.
    /// - returns:
    ///     - data: The returned Data for this resource.
    ///     - resourceType: The resource type.
    /// - throws: `RSDResourceTransformerError` if the file cannot be found.
    public func resourceData(using decoder: Decoder) throws -> (data: Data, resourceType: RSDResourceType) {
        return try _resourceData(ofType: .json, bundle: decoder.bundle)
    }
    
    /// Get the `Data` for a given resource. This is used to get data from an embedded resource.
    ///
    /// - parameters:
    ///     - defaultExtension: The default extension for the URL. If `nil` then the `resourceName` will be inspected
    ///                         for a file extension. If that is `nil` then "json" will be assumed.
    /// - returns:
    ///     - data: The returned Data for this resource.
    ///     - resourceType: The resource type.
    /// - throws: `RSDResourceTransformerError` if the file cannot be found.
    public func resourceData(ofType defaultExtension: RSDResourceType) throws -> (data: Data, resourceType: RSDResourceType) {
        return try _resourceData(ofType: defaultExtension, bundle: nil)
    }
    
    /// Get the `Data` for a given resource. This is used to get data from an embedded resource.
    ///
    /// - parameters:
    ///     - defaultExtension: The default extension for the URL. If `nil` then the `resourceName` will be inspected
    ///                         for a file extension. If that is `nil` then "json" will be assumed.
    ///     - bundle: The bundle to use for fetching the resource. If `nil` then the `RSDResourceConfig` will be used.
    /// - returns:
    ///     - data: The returned Data for this resource.
    ///     - resourceType: The resource type.
    /// - throws: `RSDResourceTransformerError` if the file cannot be found.
    private func _resourceData(ofType defaultExtension: RSDResourceType?, bundle: RSDResourceBundle?) throws -> (data: Data, resourceType: RSDResourceType) {
        
        // get the url
        let (url, resourceType) = try resourceURL(ofType: defaultExtension?.rawValue, bundle: bundle)
        
        // get the data
        let data = try Data(contentsOf: url)
        return (data, resourceType)
    }
}

/// `RSDResourceType` is an extendable struct for describing the type of a resource.
/// By default, these values will map to the file extension.
public struct RSDResourceType : RawRepresentable, Equatable, Hashable, Codable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// JSON file.
    public static let json = RSDResourceType(rawValue: "json")
    
    /// PList file.
    public static let plist = RSDResourceType(rawValue: "plist")
    
    /// HTML file.
    public static let html = RSDResourceType(rawValue: "html")
    
    /// PDF file.
    public static let pdf = RSDResourceType(rawValue: "pdf")
    
    /// PNG image file.
    public static let png = RSDResourceType(rawValue: "png")
    
    /// JPEG image file.
    public static let jpeg = RSDResourceType(rawValue: "jpeg")
}

/// `RSDResourceTransformerError` is used to support throwing errors when attempting to transform a resource.
public enum RSDResourceTransformerError : Error, CustomNSError {
    
    /// The bundle could not be found.
    case bundleNotFound(String)
    
    /// File not found in the expected bundle.
    case fileNotFound(String)
    
    /// The resource type is not supported.
    case invalidResourceType(String)
    
    /// The platform context has not been set.
    case platformContextNotSet
    
    /// The domain of the error.
    public static var errorDomain: String {
        return "RSDResourceTransformerErrorDomain"
    }
    
    /// The error code within the given domain.
    public var errorCode: Int {
        switch(self) {
        case .bundleNotFound(_):
            return -2
        case .fileNotFound(_):
            return -3
        case .invalidResourceType(_):
            return -4
        case .platformContextNotSet:
            return -5
        }
    }
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        let description: String
        switch(self) {
        case .bundleNotFound(let str):
            description = str
        case .fileNotFound(let str):
            description = str
        case .invalidResourceType(let str):
            description = str
        case .platformContextNotSet:
            description = "Platform context was not set before attempting to load a resource."
        }
        return ["NSDebugDescription": description]
    }
}
