//
//  iOS_App_PreBuilt_SetupUITestsLaunchTests.swift
//  iOS App PreBuilt SetupUITests
//
//  Created by 3EDGE TECH on 01/03/22.
//

import XCTest

class iOS_App_PreBuilt_SetupUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
