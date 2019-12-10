//  Created by Erwin on 5/9/19

import Foundation

/* Description:

This is a lightweight, flexible, individually configurable console logging system

Main benefits:
Performant
Each developer can set their desired console output
Console output setting can be changed while the app is paused in the debugger
Reduces to a no-op when not in a DEBUG build
Custom output format designed for readability & debugability:
Short time/date
Easy to spot emoji delimeters for Error and Info output
Not-main-thread annotations
Long-running process annotations (works best when used extensively throughout codebase)
User-inititated code flow annotations (user meaning person using the app in simulator or device)

*/


/* Usage:

Ensure DEBUG is set (Build Settings -> Other Swift Flags = -DDEBUG).
Although in recent iOS versions print() only outputs to debug consoles, logging is reduced to a no-op in release builds for performance reasons

If using outside this module, import AHPlatform

There are 4 base types of logs defined in the OptionSet LogOutputOptions: error, info, api, and function.
There are also 6 convenience optionsets defined, which combine the above 4 in different ways, including .none and .all optionsets.

The default (not customized) behavior is to use the 'default' convenience set, which includes the .info and .error base sets.

There are 5 ways to send output to the console. Each is listed here with the base LogOutputOptions option required for it to be output

Example Use                                     LogOutputOptions option
----------------------------------------------------------------------------------
1- LogFunc()                                       .function
2- LogFunc("any non empty message string")         .info
3- LogAPICall(apiCallInstance)                     .api
4- LogAPIResponse(apiResponseInstance)             .api
5- LogError(loggableErrorInstance)                 .error

So, by default, the following will print to the debug console:
LogError(loggableErrorInstance)                    // see bottom of this file for example usage of LoggableError
LogFunc("any non empty message string")

And these will not print:
LogFunc()
LogAPICall(apiCallInstance)                        // example: LogAPICall(APICall(urlString: path, body: strBody))
LogAPIResponse(apiResponseInstance)                // example: LogAPIResponse(APIResponse(urlResponse: response.response!, data: response.data))

To change the default setting:
1) Create new breakpoint inside the LogOutputOptions.setLogOptions property closure below
2) Set the breakpoint action to "Debugger Command" and enter "expr LogStatus.outputOptions = [desired optionset]" as the command
examples:   expr LogStatus.outputOptions = .all
expr LogStatus.outputOptions = [.error, .api]
3) Check "Automatically continue after evaluating actions"
4) Ensure breakpopint is in the User space, not Workspace or Project

Tips:
1) Set up multiple user breakpoints with different log options.
Then verbosity can be changed per debug session by enabling/disabling individual breakpoints before running the app

2) While paused in the debugger, type "e LogStatus.outputOptions = [desired optionset]" to change the output on the fly

3) Maximum benefits accrue when LogFunc() is used as liberally as reasonable throughout the entire code base.
If every function that is not expected to run in a tight loop has LogFunc() as the first line, then it becomes very easy to:
View code flow as the app runs. Extremely helpul for new devs on the project
Spot unintended multiple runs of the same function
Spot unexpected order of execution. Very handy for example when views `load` before other views `disappear` and other hard-to-debug timing issues
Spot when the user tapps on a button to initiate a code flow.
Spot when the system did not register an expected tap or gesture (if LogFunc() is the first line of the IBAction, and there's no output when a tap happens)

Spot or verify background thread execution

All the above happens automatically, all the time (in DEBUG), without spending time setting and deleting breakpoints or writing and deleting print statements.

*/


public typealias APICall = (urlString: String, body: String?)
public typealias APIResponse = (urlResponse: HTTPURLResponse, data: Data?)

public protocol LoggableError: Error {
	var description: String { get }
}

public struct GenericLoggableError: LoggableError {
	private let message: String
	public var description: String {
		return message
	}
	public init(_ errorMessage: String) {
		message = errorMessage
	}
}

public struct LogStatus {
	static var outputOptions = LogOutputOptions.default
	static var lastTimeStamp = timeval(tv_sec: 0, tv_usec: 0)
}

public struct LogOutputOptions: OptionSet {
	public let rawValue: Int

	static let error =		LogOutputOptions(rawValue: 1 << 0)
	static let info =		LogOutputOptions(rawValue: 1 << 1)
	static let api =		LogOutputOptions(rawValue: 1 << 2)
	static let function = 	LogOutputOptions(rawValue: 1 << 3)

	// convenience option sets
	static let none:		LogOutputOptions = []
	static let `default`:	LogOutputOptions = [.info, .error]
	static let apiOnly:		LogOutputOptions = [.api]
	static let test:		LogOutputOptions = [.info, .error, .api, .function]
	static let all:			LogOutputOptions = [.info, .error, .api, .function]
	static let allButApi:	LogOutputOptions = [.info, .error, .function]

	var isEnabled: Bool {
		return LogStatus.outputOptions.contains(self)
	}

	public init(rawValue value: Int) {
		rawValue = value
	}

	// going through a breakpoint is slow (even if auto-continue is on), so we only want to do this once per app launch
	// this static let will only get called once, thus the breakpoint set inside it will only be triggered once
	// the return type and value are arbritrary, this property will not actually get used
	static let setLogOptions: Bool = {
		// the only purpose of this property is to serve as a trigger for an optional, developer-set breakpoint to set desired console output
		// See "Usage" above
		// Extra lines so multiple breakpoints can be set
		// Extra lines so multiple breakpoints can be set
		return true
	}()
}

public func LogError(_ error: LoggableError, file: String = #file, function: String = #function, line: Int = #line) {
	LogFunc(error.description, file: file, function: function, line: line, outputOption: .error)
}

public func LogAPICall(_ call: APICall, file: String = #file, function: String = #function, line: Int = #line) {
	#if DEBUG

	let message: String

	if let json = call.body {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		message = "Called endpoint: \(call.urlString) with payload: \(json)"
	} else {
		message = "Called endpoint with URL: \(call.urlString)"
	}

	LogFunc(message, file: file, function: function, line: line, outputOption: .api)
	#endif
}

public func LogAPIResponse(_ apiResponse: APIResponse, file: String = #file, function: String = #function, line: Int = #line) {
	#if DEBUG
	guard let url = apiResponse.urlResponse.url else {
		LogError(GenericLoggableError("Weirdness!! Response has no URL"))
		return
	}
	guard apiResponse.urlResponse.statusCode >= 200, apiResponse.urlResponse.statusCode < 300 else {
		LogError(GenericLoggableError("Response Not OK: URL: \(url), HTTP Status Code: \(apiResponse.urlResponse.statusCode)"))
		return
	}

	let message: String

	if let data = apiResponse.data, let jsonString = String(data: data, encoding: .utf8) {
		message = "Response from endpoint: \(url.absoluteString) has payload: \(jsonString)"
	} else {
		message = "Response from endpoint: \(url.absoluteString) has empty payload"
	}

	LogFunc(message, file: file, function: function, line: line, outputOption: .api)
	#endif
}

public func LogFunc(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line, outputOption: LogOutputOptions? = nil) {
//	#if DEBUG
	let enabled: Bool
	let markerStart: String
	let markerEnd: String

	let _ = LogOutputOptions.setLogOptions    // only used to trigger a breakpoint, if any, inside the property calculation

	if let explicitOption = outputOption {
		enabled = explicitOption.isEnabled
		switch explicitOption {
		case .error:
			markerStart = "‼️ ‼️ "
			markerEnd = " ‼️ ‼️"
		default:
			markerStart = ""
			markerEnd = ""
		}
	} else {
		if message.isEmpty {
			enabled = LogOutputOptions.function.isEnabled
			markerStart = ""
			markerEnd = ""
		} else {
			enabled = LogOutputOptions.info.isEnabled
			markerStart = "👉 "
			markerEnd = " 👈"
		}
	}

	guard enabled else { return }

	let thread = (Thread.isMainThread) ? "" : " <#T##<Thread: \(threadNumberForThread(Thread.current))>##Any#>\t"

	var detail_time: timeval = timeval(tv_sec: 0, tv_usec: 0)
	gettimeofday(&detail_time, nil)

	let separator: String
	let lastTime = Int(LogStatus.lastTimeStamp.tv_sec * 1_000_000) + Int(LogStatus.lastTimeStamp.tv_usec)
	let thisTime = Int(detail_time.tv_sec * 1_000_000) + Int(detail_time.tv_usec)

	if lastTime == 0 {        // app startup
		separator = ""
	} else {
		switch thisTime - lastTime {
		case 0...10_000:
			separator = ""                                                                                  // under 0.01 sec
		case 10_000...500_000:
			separator = "------------------------------------------------------------------\n"
		default:
			separator = "\n⏰<#T##------------------------------------------------------------------##Any#>\n\n"        // over 0.5 sec
		}
	}

	LogStatus.lastTimeStamp = detail_time

	let miliseconds = String(format: ".%03d", detail_time.tv_usec / 1000)

	let time = NSDate().addingTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT(for: Date())))
	let fullString  = time.description
	let startIndex = fullString.index(fullString.startIndex, offsetBy: 11)
	let timeString = fullString[startIndex...]
	let endIndex = timeString.index(timeString.endIndex, offsetBy: -7)
	let timeMillisecondsString = "\(timeString[...endIndex])\(miliseconds)"

	let fileName = ((file as NSString).lastPathComponent as NSString).deletingPathExtension

	// attempt to align output for readability, by adding an "appropriate" number of tabs
	let fileNameThreshold: Double = 40
	let tabCount: Int = fileName.count > Int(fileNameThreshold) ? 1 : max(1, Int(pow((fileNameThreshold - Double(fileName.count)), 1.3) / 21))
	let tabPadding = String(repeating:"\t", count:tabCount)
	let linePadding = "\(line)".count < 3 ? " " : ""

	let messageString = message.isEmpty ?  "" : ":\t\(markerStart)\(message)\(markerEnd)"

	let message = "\(separator)\(timeMillisecondsString) \(fileName)\(tabPadding)\("[\(line)]")\(linePadding)\t\(thread)\(function)\(messageString)"
	print(message)

//	#endif
}

private func threadNumberForThread(_ thread: Thread) -> String {
	let array1 = thread.description.components(separatedBy: ">")
	if array1.count > 1 {
		let array2 = array1[1].trimmingCharacters(in: CharacterSet(charactersIn: "{}")).components(separatedBy: ",")
		for pair in array2 {
			let array3 = pair.components(separatedBy: "=")
			if array3.count > 1 {
				if array3[0].contains("number") {
					return array3[1].trimmingCharacters(in: CharacterSet.whitespaces)
				}
			}
		}
	}
	return "(unknown)"
}

private func testLogOptions() {
	LogFunc()

	LogError(GenericLoggableError("test error"))

	LogFunc("test message")

	let defaultSession = URLSession(configuration: .default)
	var dataTask: URLSessionDataTask?

	if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
		urlComponents.query = "media=music&entity=song&term=car"

		guard let url = urlComponents.url else {
			LogError(GenericLoggableError("Problem creatung test URL"))
			return
		}

		dataTask = defaultSession.dataTask(with: url) { data, response, error in
			defer { dataTask = nil }

			if let error = error {
				LogError(GenericLoggableError(error.localizedDescription))
			} else if let data = data, let response = response as? HTTPURLResponse {
				LogAPIResponse((urlResponse: response, data: data))
			}
		}

		LogAPICall((urlString: url.absoluteString, body: nil))
		dataTask?.resume()
	}
}

/*

Example LoggableError usage

enum JsonParsingError: LoggableError {
case dataParsing(message: String)
case noResults
case key(key: String, dictionary: Dictionary<String, Any>)
case valueExtraction(dictionary: Dictionary<String, Any>)
case urlParse(urlString: String)
case dateParse(dateString: String)

var description: String {
switch self {
case .dataParsing(let message):         return "Error parsing response data into JSON: \(message)"
case .noResults:                        return "No results returned"
case .key(let key, let dictionary):     return "Key \"\(key)\" not found in \(dictionary.debugDescription)"
case .valueExtraction(let dictionary):  return dictionary.debugDescription
case .urlParse(let urlString):          return "Error parsing \"\(urlString)\" as URL"
case .dateParse(let dateString):        return "Error parsing \"\(dateString)\" as a Date"
}
}
}


do {
if let jsonObj = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String, Any> {
// handle jsonObj
}
} catch {
LogError(JsonParsingError.dataParsing(message: error.localizedDescription))
}

*/


