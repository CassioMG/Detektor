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
 A list of PDF conversion settings.
 */
public struct PDFSettings: Codable, Equatable {

    public var heading: PDFHeadingDetection?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case heading = "heading"
    }

    /**
     Initialize a `PDFSettings` with member variables.

     - parameter heading:

     - returns: An initialized `PDFSettings`.
    */
    public init(
        heading: PDFHeadingDetection? = nil
    )
    {
        self.heading = heading
    }

}
