//  HubApiExplorer
//  Created by erwin on 12/10/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import UIKit

class CommitsViewController: UIViewController {

	@IBOutlet var infoLabel: UILabel?
	@IBOutlet var loadingView: UIView?

	let repo = Repo(ownerName: "apple", repoName: "swift")

	var listTableController: CommitsTableController?

	var commitNodes = [CommitNode]() {
		didSet {
			listTableController?.commitNodes = commitNodes
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		LogFunc()

		if let commitsTable = segue.destination as? CommitsTableController {
			commitsTable.commitNodes = commitNodes
			listTableController = commitsTable
		}
	}

	override func viewDidLoad() {
		LogFunc()
		super.viewDidLoad()
		hideLoading()
	}

	override func viewWillAppear(_ animated: Bool) {
		LogFunc()
		super.viewWillAppear(animated)
		getCommits()
	}

	func getCommits() {
		LogFunc()

		showLoading()

		infoLabel?.text = "Fetching commits from: \(repo.ownerName) / \(repo.repoName)"

		ApiService().current.fetchLatestCommitsFromRepo(repo) { commitNodes, error in
			DispatchQueue.main.async {
				self.commitNodes = commitNodes
				self.hideLoading()
				self.infoLabel?.text = "\(commitNodes.count) commits from: \(self.repo.ownerName) / \(self.repo.repoName)"
			}
		}
	}

	func showLoading() {
		LogFunc()

		// TODO: in a production app, animation constants are centralized in a "Design Constants" struct
		UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.6) {
			self.loadingView?.transform = .identity
			self.loadingView?.alpha = 1
		}.startAnimation()
	}

	func hideLoading() {
		LogFunc()

		// TODO: in a production app, animation constants are centralized in a "Design Constants" struct
		UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.6) {
			self.loadingView?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
			self.loadingView?.alpha = 0
		}.startAnimation()
	}

}

