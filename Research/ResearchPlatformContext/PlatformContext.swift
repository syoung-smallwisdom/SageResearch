//
//  PlatformContext.swift
//  ResearchPlatformContext (iOS)
//
//  Created by Shannon Young on 12/12/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import Foundation

class PlatformContext : RSDPlatformContextInfo {
    
    /// Information about the specific device.
    public let deviceInfo: String
    
    /// Specific model identifier of the device.
    /// - example: "Apple Watch Series 1"
    public let deviceTypeIdentifier: String
    
    /// The name of the application.
    public let appName: String
    
    /// The application version.
    public let appVersion: String
    
    /// Research framework version.
    public let rsdFrameworkVersion: String
    
    init() {
        
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        self.deviceInfo = "\(device.machineName); \(device.systemName)/\(device.systemVersion)"
        self.deviceTypeIdentifier = device.deviceTypeIdentifier
        #elseif os(macOS)
        self.deviceTypeIdentifier = "Mac"
        self.deviceInfo = "Mac \(ProcessInfo().operatingSystemVersionString)"
        #else
        let device = UIDevice.current
        self.deviceInfo = "\(device.machineName); \(device.systemName)/\(device.systemVersion)"
        self.deviceTypeIdentifier = device.deviceTypeIdentifier
        #endif
        
        self.appName = Bundle.main.executableName
        self.appVersion = Bundle.main.fullVersion
        self.rsdFrameworkVersion = Bundle(for: RSDTaskViewModel.self).fullVersion
    }
}

extension Bundle {
    
    /// The executable name is the bundle's non-localized name.
    fileprivate var executableName: String {
        if let bundleInfo = infoDictionary {
            if let name = bundleInfo["CFBundleExecutable"] as? String {
                return name
            }
            else if let name = bundleInfo["CFBundleName"] as? String {
                return name
            }
            else if let name = bundleInfo["CFBundleDisplayName"] as? String {
                return name
            }
        }
        return "???"
    }
    
    /// The full version is a non-localized string that uses both the "short version"
    /// string and the build number.
    fileprivate var fullVersion: String {
        guard let bundleInfo = infoDictionary,
            let version = bundleInfo["CFBundleShortVersionString"],
            let build = bundleInfo[(kCFBundleVersionKey as String)]
            else {
                return "???"
        }
        return "version \(version), build \(build)"
    }
}


#if os(watchOS)
import WatchKit
extension WKInterfaceDevice {
    
    /// An identifier for the device type pulled from the system info.
    fileprivate var deviceTypeIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// A human-readable mapped name for a given device type.
    fileprivate var machineName: String {
        let identifier = deviceTypeIdentifier
        switch identifier {
        case "Watch1":                                      return "Apple Watch Series 1"
        case "Watch2,6","Watch2,7","Watch2,3","Watch2,4":   return "Apple Watch Series 2"
        case "Watch3,1","Watch3,2","Watch3,3","Watch3,4":   return "Apple Watch Series 3"
        case "i386", "x86_64":                              return "Apple Watch Simulator"
            
        default:                                            return identifier
        }
    }
}

#elseif os(macOS)

import AppKit

#else
import UIKit
extension UIDevice {
    
    /// An identifier for the device type pulled from the system info.
    fileprivate var deviceTypeIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// A human-readable mapped name for a given device type.
    fileprivate var machineName: String {
        let identifier = deviceTypeIdentifier
        switch identifier {
        case "iPod5,1":                                     return "iPod Touch 5"
        case "iPod7,1":                                     return "iPod Touch 6"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":         return "iPhone 4"
        case "iPhone4,1":                                   return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                      return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                      return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                      return "iPhone 5s"
        case "iPhone7,2":                                   return "iPhone 6"
        case "iPhone7,1":                                   return "iPhone 6 Plus"
        case "iPhone8,1":                                   return "iPhone 6s"
        case "iPhone8,2":                                   return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                      return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                      return "iPhone 7 Plus"
        case "iPhone8,4":                                   return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                    return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                    return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                    return "iPhone X"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":    return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":               return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":               return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":               return "iPad Air"
        case "iPad5,3", "iPad5,4":                          return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                        return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":               return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":               return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":               return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                          return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                          return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                          return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                          return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                          return "iPad Pro 10.5 Inch"
            
        case "AppleTV5,3":                                  return "Apple TV"
        case "AppleTV6,2":                                  return "Apple TV 4K"
            
        case "AudioAccessory1,1":                           return "HomePod"
            
        case "i386", "x86_64":                              return "Simulator"
            
        default:                                            return identifier
        }
    }
}
#endif
