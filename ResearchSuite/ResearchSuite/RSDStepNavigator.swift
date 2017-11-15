//
//  RSDStepNavigator.swift
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

/// `RSDStepNavigator` is the model object used by the `RSDTaskController` to determine the order of
/// presentation of the steps in a task.
///
/// - seealso: `RSDTask`, `RSDTaskController`, and `RSDConditionalStepNavigator`
public protocol RSDStepNavigator {
    
    /// Returns the step associated with a given identifier.
    /// - parameter identifier:  The identifier for the step.
    /// - returns: The step with this identifier or nil if not found.
    func step(with identifier: String) -> RSDStep?
    
    /// Should the task exit early from the entire task?
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should exit.
    func shouldExit(after step: RSDStep?, with result: RSDTaskResult) -> Bool
    
    /// Is there a step after the current step with the given result.
    ///
    /// - note: the result may not include a result for the current step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should show a next button.
    func hasStep(after step: RSDStep?, with result: RSDTaskResult) -> Bool
    
    /// Is there a step before the current step with the given result.
    ///
    /// - note: the result may not include a result for the current step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should show a back button.
    func hasStep(before step: RSDStep, with result: RSDTaskResult) -> Bool
    
    /// Return the step to go to after completing the given step.
    ///
    /// - parameters:
    ///     - step:    The previous step or nil if this is the first step.
    ///     - result:  The current result set for this task.
    /// - returns: The next step to display or nil if this is the end of the task.
    func step(after step: RSDStep?, with result: inout RSDTaskResult) -> RSDStep?
    
    /// Return the step to go to before the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: The previous step or nil if the task does not support backward navigation.
    func step(before step: RSDStep, with result: inout RSDTaskResult) -> RSDStep?
    
    /// Return the progress through the task for a given step with the current result.
    ///
    /// - parameters:
    ///     - step:         The current step.
    ///     - result:       The current result set for this task.
    /// - returns:
    ///     - current:      The current progress. This indicates progress within the task.
    ///     - total:        The total number of steps.
    ///     - isEstimated:  Whether or not the progress is an estimate (if the task has variable navigation)
    func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: Int, total: Int, isEstimated: Bool)?
}
