//  HubApiExplorer
//  Created by erwin on 12/10/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation

struct Commit: Codable {
	let sha: String
	let url: String
	let author: Person
	let committer: Person
	let message: String
	let tree: Resource
	let parents: [Person]
	let verification: Verification
}
