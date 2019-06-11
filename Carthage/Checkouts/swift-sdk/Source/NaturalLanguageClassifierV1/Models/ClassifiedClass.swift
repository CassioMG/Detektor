/**
 * Copyright IBM Corporation 2019
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

/**
 Class and confidence.
 */
public struct ClassifiedClass: Codable, Equatable {

    /**
     A decimal percentage that represents the confidence that Watson has in this class. Higher values represent higher
     confidences.
     */
    public var confidence: Double?

    /**
     Class label.
     */
    public var className: String?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case confidence = "confidence"
        case className = "class_name"
    }

}
