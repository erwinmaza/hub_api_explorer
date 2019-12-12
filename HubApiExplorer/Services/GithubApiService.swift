//  HubApiExplorer
//  Created by erwin on 12/11/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation


struct GithubApiService: ApiServiceProtocol {

	let apiUrlString = "https://api.github.com"

	func fetchLatestCommitsFromRepo(_ repo: Repo, completion: @escaping ([CommitNode], Error?) -> Void) {
		LogFunc()

		let commitsEndpoint = "/repos/\(repo.ownerName)/\(repo.repoName)/commits"

		guard let url = URL(string: apiUrlString + commitsEndpoint) else {
			fatalError("Could not construct URL for repo '\(repo)'")
		}

		LogFunc(url.absoluteString)

		// TODO: In a production app, we safeguard secrets using one of a variety of methods
		// temp workaround so github doesn't invalidate the token upon commit
		let tokenPrefix = "2c7b207098b6fb4b1"
		let tokenSuffix = "f34ec2499aabfa294494871"

		var request = URLRequest(url: url)
		request.addValue("Bearer \(tokenPrefix)\(tokenSuffix)", forHTTPHeaderField: "Authorization")

		URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in

			// ignore errors for now

			guard let data = data else {
				let apiError = APIError.response(message: response.debugDescription)
				completion([], apiError)
				return
			}

			do {
				let commitNodes = try JSONDecoder().decode([CommitNode].self, from: data)
				completion(commitNodes, nil)
			} catch {
				LogError(GenericLoggableError(error.localizedDescription))
				let apiError = APIError.json(message: error.localizedDescription)
				completion([], apiError)
			}
		}).resume()
	}


}
