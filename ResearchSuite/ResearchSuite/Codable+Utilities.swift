//
//  Codable+Utilities.swift
//  ResearchSuite
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

/// Internally defined method for converting a decoding container to a dictionary
/// where any key in the dictionary is accessible.
struct AnyCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

struct AnyCodableArray : Codable {
    let array : [Any]
    
    public init(array : [Any]) {
        self.array = array
    }
    
    public init(from decoder: Decoder) throws {
        var genericContainer = try decoder.unkeyedContainer()
        self.array = try genericContainer.decode(Array<Any>.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for obj in array {
            if let encodable = obj as? Encodable {
                let nestedEncoder = container.superEncoder()
                try encodable.encode(to: nestedEncoder)
            } else if let arr = obj as? [Any] {
                let encodable = AnyCodableArray(array: arr)
                let nestedEncoder = container.superEncoder()
                try encodable.encode(to: nestedEncoder)
            } else if let dictionary = obj as? [String : Any] {
                let encodable = RSDMetadata(dictionary)
                let nestedEncoder = container.superEncoder()
                try encodable.encode(to: nestedEncoder)
            }
        }
    }
}

/// Wrapper for generic metadata.
public struct RSDMetadata : Codable {
    public let metadata : [String : Any]
    
    public init?(_ metadata : [String : Any]?) {
        guard let metadata = metadata else { return nil }
        self.metadata = metadata
    }
    
    public init(from decoder: Decoder) throws {
        let genericContainer = try decoder.container(keyedBy: AnyCodingKey.self)
        self.metadata = try genericContainer.decode(Dictionary<String, Any>.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        for obj in metadata {
            let key = AnyCodingKey(stringValue: obj.key)!
            if let encodable = obj.value as? Encodable {
                let nestedEncoder = container.superEncoder(forKey: key)
                try encodable.encode(to: nestedEncoder)
            } else if let array = obj.value as? [Any] {
                let encodable = AnyCodableArray(array: array)
                let nestedEncoder = container.superEncoder(forKey: key)
                try encodable.encode(to: nestedEncoder)
            } else if let dictionary = obj.value as? [String : Any] {
                let encodable = RSDMetadata(dictionary)
                let nestedEncoder = container.superEncoder(forKey: key)
                try encodable.encode(to: nestedEncoder)
            }
        }
    }
}

/// Extension of the keyed decoding container for decoding to any dictionary. These methods are defined internally
/// to avoid possible namespace clashes.
extension KeyedDecodingContainer {
    
    /// Decode `Dictionary<String, Any>` for the given key.
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        return try container.decode(type)
    }
    
    /// Decode `Dictionary<String, Any>` for the given key if the dictionary is present for that key.
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    /// Decode `Array<Any>` for the given key.
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    /// Decode `Array<Any>` for the given key if the array is present for that key.
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    /// Decode this container as a `Dictionary<String, Any>`.
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            }
            else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            }
            else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            }
            else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            }
            else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            }
            else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

/// Extension of the unkeyed decoding container for decoding to any array. These methods are defined internally
/// to avoid possible namespace clashes.
extension UnkeyedDecodingContainer {
    
    /// For the elements in the unkeyed contain, decode all the elements.
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }
}
