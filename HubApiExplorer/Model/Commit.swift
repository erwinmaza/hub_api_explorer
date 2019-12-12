//  HubApiExplorer
//  Created by erwin on 12/10/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation

struct Commit: Codable {
	let url: String
	let author: Person
	let committer: Person
	let message: String
	let tree: Resource
	let comment_count: Int
	let verification: Verification
	let parents: [Resource]?
}

