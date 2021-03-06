//
//  RSDCopyTask.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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


/// Protocol to describe a task that should be copied for each run of the task rather than simply passed.
/// This is used to allow an architecture where the task model uses a pointer to an in-memory object that is
/// used during navigation.
public protocol RSDCopyTask : RSDTask, RSDCopyWithIdentifier, RSDTaskTransformer {
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameters:
    ///     - identifier: The new identifier.
    ///     - schemaInfo: The schema info.
    func copy(with identifier: String, schemaInfo: RSDSchemaInfo?) -> Self
}

extension RSDCopyTask {
    
    /// Returns `0`.
    public var estimatedFetchTime: TimeInterval {
        return 0
    }
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - taskIdentifier: The task info for the task (if applicable).
    ///     - schemaInfo: The schema info for the task (if applicable).
    ///     - callback: The callback with the task or an error if the task failed, run on the main thread.
    public func fetchTask(with taskIdentifier: String, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler) {
        DispatchQueue.main.async {
            let copy = self.copy(with: taskIdentifier, schemaInfo: schemaInfo)
            callback(copy, nil)
        }
    }
}
