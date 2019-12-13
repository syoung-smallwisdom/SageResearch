//
//  RSDImageData+Platform.swift
//  ResearchPlatformContext
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension RSDSize {
    
    /// The CGSize represented by this size.
    public var cgSize: CGSize {
        return CGSize(width: self.width, height: self.height)
    }
}

extension RSDImageData {
    
    /// Fetch the image.
    ///
    /// - parameters:
    ///     - size:        The size of the image to return.
    ///     - callback:    The callback with the image, run on the main thread.
    public func fetchImage(for size: CGSize, callback: @escaping ((String?, RSDImage?) -> Void)) {
        if let image = self as? RSDImage {
            DispatchQueue.main.async {
                callback(self.imageIdentifier, image)
            }
        }
        else if self.imageIdentifier.starts(with: "http"),
            let url = URL(string: self.imageIdentifier) {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            let task = URLSession.shared.dataTask(with: request) {(data, _, _) in
                    let image: RSDImage? = (data != nil) ? RSDImage(data: data!) : nil
                    DispatchQueue.main.async {
                        callback(self.imageIdentifier, image)
                    }
            }
            task.resume()
        }
        else if let resourceInfo = self as? RSDResourceDataInfo {
            let image = RSDDesignSystem.shared.imageRules.assetImage(named: resourceInfo.resourceName, using: resourceInfo)
            DispatchQueue.main.async {
                callback(self.imageIdentifier, image)
            }
        }
        else {
            DispatchQueue.main.async {
                callback(self.imageIdentifier, nil)
            }
        }
    }
}

extension RSDResourceImageData {
    
    /// Get the embedded image for this resource info.
    ///
    /// - parameters:
    ///     - designSystem: The design system to use to fetch images.
    ///     - traitCollection: The trait collection for the presenting view.
    /// - returns: Image if found.
    public func embeddedImage(using designSystem: RSDDesignSystem? = nil,
                              compatibleWith traitCollection: UITraitCollection? = nil) -> RSDImage? {
        let designSystem = designSystem ?? RSDDesignSystem.shared
        return designSystem.imageRules.assetImage(named: self.resourceName,
                                                  using: self,
                                                  compatibleWith: traitCollection)
    }
}
