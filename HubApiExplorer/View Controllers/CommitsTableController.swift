//  HubApiExplorer
//  Created by erwin on 12/11/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import UIKit

class CommitsTableController: UITableViewController {

	var commits = [Commit]() {
		didSet {
			tableView.reloadData()
		}
	}

    override func viewDidLoad() {
		LogFunc()
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return commits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        return cell
    }
}
