//  HubApiExplorer
//  Created by erwin on 12/11/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation

protocol ApiServiceProtocol {

	func fetchLatestCommitsFromRepo(_ repo: Repo, completion: @escaping ([CommitNode], Error?) -> Void)

}

enum NetworkingError: Error {
	case config(message: String)
	case connectivity(message: String)
	case reachability(message: String)

	func description() -> String {
		switch self {
			case .config(let message): return message
			case .connectivity(let message): return message
			case .reachability(let message): return message
		}
	}
}

enum APIError: Error {
	case request(message: String)
	case response(message: String)
	case json(message: String)

	func description() -> String {
		switch self {
			case .request(let message): return message
			case .response(let message): return message
			case .json(let message): return message
		}
	}
}

struct ApiService {

	var current: ApiServiceProtocol {
		switch currentApi {
			case .github:
				return GithubApiService()
			case .test:
				return TestService()
		}
	}

	enum API {
		case github, test
	}

	init(_ api: API = .github) {
		currentApi = api
	}

	// MARK: - Private stuff
	private let currentApi: API

}
