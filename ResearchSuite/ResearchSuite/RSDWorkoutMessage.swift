//
//  RSDWorkoutMessage.swift
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
import WatchConnectivity
import HealthKit

/// Codable String enum for the watch's workout session state.
public enum RSDWorkoutState : String, Codable {
    
    /// The workout session has not been started and is waiting for the command to start.
    case notStarted
    
    /// The workout session is starting.
    case starting
    
    /// The workout session is running.
    case running
    
    /// The workout session is stopping.
    case stopping
    
    /// The workout session has ended.
    case ended
    
    /// The workout session is paused.
    case pause
}

/// Codable String enum for commands to change the watch's workout session state.
public enum RSDWorkoutCommand : String, Codable {
    
    /// Stop the workout.
    case stop
    
    /// Pause the workout.
    case pause
    
    /// Resume the workout.
    case resume
    
    /// Move to the given step.
    case moveToStep
    
    /// Start the task.
    case startTask
    
    /// Ping the watch to check for connectivity and keep the connection open.
    case ping
}

/// Codable String enum for the message type of the message data. This is used to
/// encode and decode the message data.
/// - seealso: `RSDWorkoutMessageProtocol`
public enum RSDWorkoutMessageType : String, Codable {
    case instruction, samples, event, error
}

/// The `RSDWorkoutMessageProtocol` is a protocol that can be used to describe messages
/// sent between the watch and phone.
public protocol RSDWorkoutMessageProtocol {
    
    /// An identifier for the message. By default, this value is set to a UUID.
    var identifier : String { get }
    
    /// The current step path.
    var currentStepPath : String { get }

    /// The type of the message.
    var messageType : RSDWorkoutMessageType { get }
    
    /// The timestamp for when the message was created.
    var timestamp : Date { get }
}

/// Extension of the `RSDWorkoutMessageProtocol` for messages sent from the phone.
public protocol RSDPhoneMesssageProtocol : RSDWorkoutMessageProtocol {
    
    /// Command sent from the phone to tell the watch to change state.
    var command : RSDWorkoutCommand { get }
}

/// Extension of the `RSDWorkoutMessageProtocol` for messages sent from the watch.
public protocol RSDWatchMesssageProtocol : RSDWorkoutMessageProtocol {
    
    /// The current state of the watch workout.
    var state : RSDWorkoutState { get }
}

/// `RSDInstructionWorkoutMessage` messages are sent from the phone to the watch.
public struct RSDInstructionWorkoutMessage : RSDPhoneMesssageProtocol, Codable {
    
    /// An identifier for the message. By default, this value is set to a UUID.
    public let identifier : String
    
    /// The current step path.
    public let currentStepPath: String
    
    /// The type of the message.
    public let messageType : RSDWorkoutMessageType
    
    /// The timestamp for when the message was created.
    public let timestamp : Date
    
    /// Command sent from the phone to tell the watch to change state.
    public let command : RSDWorkoutCommand
}

/// `RSDSamplesWorkoutMessage` messages are sent from the watch when a tracked HealthKit
/// value is updated.
public struct RSDSamplesWorkoutMessage : RSDWatchMesssageProtocol, Codable {
    
    /// An identifier for the message. By default, this value is set to a UUID.
    public let identifier : String
    
    /// The current step path.
    public let currentStepPath: String
    
    /// The type of the message.
    public let messageType : RSDWorkoutMessageType
    
    /// The timestamp for when the message was created.
    public let timestamp : Date
    
    /// The current state of the watch workout.
    public let state : RSDWorkoutState
    
    /// The quantity type identifier for this set of samples.
    public let quantityTypeIdentifier: HKQuantityTypeIdentifier
    
    /// The samples being sent.
    public var quantitySamples : [HKQuantitySample] {
        get {
            return samples.rsd_mapAndFilter { $0.quantitySample() }
        }
        set {
            samples = newValue.map { RSDQuantitySample($0) }
        }
    }
    var samples : [RSDQuantitySample]
}

/// `RSDEventWorkoutMessage` messages are sent from the watch when a workout session
/// event happens.
public struct RSDEventWorkoutMessage : RSDWatchMesssageProtocol, Codable {
    
    /// An identifier for the message. By default, this value is set to a UUID.
    public let identifier : String
    
    /// The current step path.
    public let currentStepPath: String
    
    /// The type of the message.
    public let messageType : RSDWorkoutMessageType
    
    /// The timestamp for when the message was created.
    public let timestamp : Date
    
    /// The current state of the watch workout.
    public let state : RSDWorkoutState
    
    /// The event that triggered the message send.
    // TODO: syoung 02/09/2018 Implement Codable
    // public let event : HKWorkoutEvent
}

/// `RSDErrorWorkoutMessage` messages are sent from the watch when a workout session
/// error happens.
public struct RSDErrorWorkoutMessage : RSDWatchMesssageProtocol, Codable {
    
    /// An identifier for the message. By default, this value is set to a UUID.
    public let identifier : String
    
    /// The current step path.
    public let currentStepPath: String
    
    /// The type of the message.
    public let messageType : RSDWorkoutMessageType
    
    /// The timestamp for when the message was created.
    public let timestamp : Date
    
    /// The current state of the watch workout.
    public let state : RSDWorkoutState
    
    /// The event that triggered the message send.
    // TODO: syoung 02/09/2018 Implement Codable
    // public let error : Error
}

