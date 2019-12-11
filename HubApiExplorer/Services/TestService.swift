//  HubApiExplorer
//  Created by erwin on 12/11/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation

struct TestService: ApiServiceProtocol {

	// TODO: create test server
	let apiUrlString = "probably something on AWS"

	func fetchLatestCommitsFromRepo(_ repo: Repo, completion: @escaping ([Commit], Error?) -> Void) {
		LogFunc()
		// TODO: this
	}

}
