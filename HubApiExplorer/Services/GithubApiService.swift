//  HubApiExplorer
//  Created by erwin on 12/11/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation


struct GithubApiService: ApiServiceProtocol {

	let apiUrlString = "https://api.github.com"

	func fetchLatestCommitsFromRepo(_ repo: Repo, completion: @escaping ([Commit], Error?) -> Void) {
		LogFunc()

		let commitsEndpoint = "/repos/\(repo.ownerName)/\(repo.repoName)/git/commits"

		guard let url = URL(string: apiUrlString + commitsEndpoint) else {
			fatalError("Could not construct URL for repo '\(repo)'")
		}

		LogFunc(url.absoluteString)

		URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in

			// ignore error for now

			guard let data = data else {
				let apiError = APIError.response(message: response.debugDescription)
				completion([], apiError)
				return
			}

			do {
				let commitNodes = try JSONDecoder().decode([CommitNode].self, from: data)
				completion(commitNodes.map({ $0.commit }), nil)
			} catch {
				LogError(GenericLoggableError(error.localizedDescription))
				let apiError = APIError.json(message: error.localizedDescription)
				completion([], apiError)
			}
		}).resume()
	}


}
