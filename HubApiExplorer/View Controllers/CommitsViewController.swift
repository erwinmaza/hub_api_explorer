//  HubApiExplorer
//  Created by erwin on 12/10/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import UIKit

class CommitsViewController: UIViewController {

	var listTableController: CommitsTableController?

	var commits = [Commit]()

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		LogFunc()

		if let commitsTable = segue.destination as? CommitsTableController {
			listTableController = commitsTable
		}
	}

	override func viewDidLoad() {
		LogFunc()
		super.viewDidLoad()
	}


}

