//
//  HKQuantitySample+Codable.swift
//  ResearchSuite
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
import HealthKit

extension HKQuantityTypeIdentifier : Codable {
}

extension HKQuantitySample {
}

extension HKQuantityType {
    
    /// Returns the base unit for this quantity type.
    public func baseUnit() -> HKUnit {
        return HKUnit.defaultUnit(for: self)
    }
}

extension HKUnit {
    
    /// beats / min
    public static func bpm() -> HKUnit {
        return HKUnit.count().unitDivided(by: HKUnit.minute())
    }
    
    /// ml/(kg*min)
    public static func vo2Max() -> HKUnit {
        return HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.minute().unitMultiplied(by: HKUnit.gramUnit(with: .kilo)))
    }

    static let encodingUnits : [HKUnit] = [
        .gram(),
        .meter(),
        .liter(),
        .pascal(),
        .second(),
        .joule(),
        .kelvin(),
        .siemen(),
        .count(),
        .percent(),
        .bpm(),
    ]
    
    static func defaultUnit(for quantityType: HKQuantityType) -> HKUnit {
        let typeIdentifier = HKQuantityTypeIdentifier(rawValue: quantityType.identifier)
        
        // Check types that are only available for iOS 11 first and exit early if found.
        if #available(iOS 11.0, *) {
            switch typeIdentifier {
            case .vo2Max:
                return .vo2Max()
            case .waistCircumference:
                return .meterUnit(with: .centi)
            case .restingHeartRate,
                 .walkingHeartRateAverage:
                return .bpm()
            default:
                break
            }
        }
                
        // Check for remaining cast types.
        switch typeIdentifier {
        case .height:
            return .meterUnit(with: .centi)
        case .bodyMass:
            return .gramUnit(with: .kilo)
        case .heartRate:
            return .bpm()
        case .distanceWalkingRunning,
             .distanceCycling,
             .distanceWheelchair:
            return .meterUnit(with: .kilo)
        case .bloodPressureSystolic,
             .bloodPressureDiastolic:
            return HKUnit.millimeterOfMercury()
            
        default:
        // If none of the types are available then look for a match.
        for unit in encodingUnits {
            if quantityType.is(compatibleWith: unit) {
                return unit
            }
        }
        
        assertionFailure("Failed to find appropriate unit for \(quantityType)")
        return HKUnit(from: "")
        }
    }
}

struct RSDHealthKitDevice : Codable {
    public let name: String?
    public let manufacturer: String?
    public let model: String?
    public let hardwareVersion: String?
    public let firmwareVersion: String?
    public let softwareVersion: String?
    
    public init?(_ device: HKDevice?) {
        guard let device = device else { return nil }
        self.name = device.name
        self.manufacturer = device.manufacturer
        self.model = device.model
        self.hardwareVersion = device.hardwareVersion
        self.firmwareVersion = device.firmwareVersion
        self.softwareVersion = device.softwareVersion
    }
    
    public func device() -> HKDevice {
        return HKDevice(name: name, manufacturer: manufacturer, model: model, hardwareVersion: hardwareVersion, firmwareVersion: firmwareVersion, softwareVersion: softwareVersion, localIdentifier: nil, udiDeviceIdentifier: nil)
    }
}

struct RSDQuantitySample : Codable {
    public let uuid: UUID
    public let startDate: Date
    public let endDate: Date
    public let typeIdentifier: String
    public let quantity: Double
    public let unit: String
    public let metadata: RSDMetadata?
    public let device: RSDHealthKitDevice?
    
    public init(_ sample: HKQuantitySample) {
        self.uuid = sample.uuid
        self.startDate = sample.startDate
        self.endDate = sample.endDate
        self.typeIdentifier = sample.quantityType.identifier
        let unit = sample.quantityType.baseUnit()
        self.unit = unit.unitString
        self.quantity = sample.quantity.doubleValue(for: unit)
        self.metadata = RSDMetadata(sample.metadata)
        self.device = RSDHealthKitDevice(sample.device)
    }
    
    public func quantitySample() -> HKQuantitySample? {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: self.typeIdentifier)
        let unit = HKUnit(from: self.unit)
        guard let quantityType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            return nil
        }
        let quantity = HKQuantity(unit: unit, doubleValue: self.quantity)
        let device = self.device?.device()
        return HKQuantitySample(type: quantityType, quantity: quantity, start: startDate, end: endDate, device: device, metadata: metadata?.metadata)
    }
}
