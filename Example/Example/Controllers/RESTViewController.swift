// Atom
//
// Copyright (c) 2019 Alaska Airlines
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

import Atom
import UIKit

internal class RESTViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet internal weak var button: UIButton!
    @IBOutlet internal weak var label: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSubviews()
    }

    // MARK: Actions

    @IBAction internal func refreshTapped(_ sender: Any) {
        typealias Endpoint = Joke.Endpoint

        // Start a new request.
        atom.load(Endpoint.random).execute(expecting: Joke.self) { [weak self] result in
            switch result {
            case .failure(let error):
                debugPrint(error)
            case .success(let joke):
                self?.label.text = joke.joke
            }
        }
    }
}

// MARK: Animations

private extension RESTViewController {
    private func animateSubviews() {
        UIView.animate(withDuration: 0.8) {
            self.button.alpha = 1.0
            self.label.alpha = 1.0
        }
    }
}
