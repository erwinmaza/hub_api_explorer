//  HubApiExplorer
//  Created by erwin on 12/11/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation

struct CommitNode: Codable {
	let url: String
	let sha: String

	// in a production app, we'd use convert[To/From]SnakeCase in our JSONEncoder/JSONDecoder
	let node_id: String
	let html_url: String
	let comments_url: String

	let commit: Commit
	let author: PersonProfile?
	let committer: PersonProfile
}

