//  HubApiExplorer
//  Created by erwin on 12/10/19 using Swift 5.0.
//  Copyright © 2019 erwin. All rights reserved.

import Foundation

struct Verification: Codable {
	let verified: Bool
	let reason: String
	let signature: String?
	let payload: String?

	var verificationReason: Reason {
		return Reason(rawValue: reason) ?? .unsigned // TODO: verify this is a reasonable default
	}

	enum Reason: String {
		case expired_key
		case not_signing_key
		case gpgverify_error
		case gpgverify_unavailable
		case unsigned
		case unknown_signature_type
		case no_user
		case unverified_email
		case bad_email
		case unknown_key
		case malformed_signature
		case invalid
		case valid
	}
}
