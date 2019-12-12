//  HubApiExplorer
//  Created by erwin on 12/11/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import UIKit

class CommitsTableController: UITableViewController {

	// TODO: in a production app, colors are centralized in a "Design Constants" struct
	let alternateRowColor = UIColor.blue.withAlphaComponent(0.15)

	var commitNodes = [CommitNode]() {
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
		LogFunc()
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return commitNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

		let node = commitNodes[indexPath.row]
		cell.textLabel?.text = "\(node.commit.author.name):\n\n\(node.commit.message)"
		cell.detailTextLabel?.text = node.sha
		cell.contentView.backgroundColor = indexPath.row % 2 == 1 ? .white : alternateRowColor
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		LogFunc()

		tableView.deselectRow(at: indexPath, animated: true)

		let node = commitNodes[indexPath.row]

		UIPasteboard.general.string = node.sha

		let alert = UIAlertController(title: "Copied!", message: "\nCommit sha \n\n\(node.sha)\n\nhas been copied to your clipboard", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cool", style: .default, handler: { alertAction in
			alert.dismiss(animated: true, completion: nil)
		}))
		present(alert, animated: true, completion: nil)

	}
}
