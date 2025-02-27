// AtomNetworking
//
// Copyright (c) 2025 Alaska Airlines
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// MARK: - Public APIs

extension Atom {
    /// Notification name posted when an attempt to refresh the access token fails.
    ///
    /// This notification is posted when there's an error during the process of refreshing the access token, allowing
    /// other parts of the application to respond to this event, such as updating UI to reflect login status or
    /// prompting the user to re-authenticate.
    public static let didFailToRefreshAccessToken = Notification.Name(rawValue: "com.alaskaair.atom.didFailToRefreshAccessToken")

    /// Notification name posted when an attempt to authorize the request fails.
    ///
    /// This notification is posted when there's an error during the process of authorizing the request, allowing
    /// other parts of the application to respond to this event, such as updating UI to reflect login status or
    /// prompting the user to re-authenticate.
    public static let didFailToAuthorizeRequest = Notification.Name(rawValue: "com.alaskaair.atom.didFailToAuthorizeRequest")
}
