//
//  ShoppingListFeatureUITests.swift
//  ShoppingListFeatureUITests
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import XCTest

final class ShoppingListFeatureUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAddNewItem() throws {
        // Given: App is launched with empty list
        XCTAssertTrue(app.navigationBars["Shopping List"].exists)
        
        // When: Tap add button
        app.buttons["plus"].tap()
        
        // Then: Add item sheet should appear
        XCTAssertTrue(app.navigationBars["Add Item"].exists)
        
        // When: Fill in item details
        let nameTextField = app.textFields["Item name"]
        nameTextField.tap()
        nameTextField.typeText("Milk")
        
        let quantityStepper = app.steppers["Quantity: 1"]
        quantityStepper.buttons["Increment"].tap() // Set to 2
        
        let noteTextField = app.textFields["Note (optional)"]
        noteTextField.tap()
        noteTextField.typeText("Organic whole milk")
        
        // When: Tap Add button
        app.buttons["Add"].tap()
        
        // Then: Sheet should dismiss and item should appear in list
        XCTAssertFalse(app.navigationBars["Add Item"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Qty: 2"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Organic whole milk"].waitForExistence(timeout: 2))
    }
    
    func testToggleBoughtStatus() throws {
        // Given: Add an item first
        app.buttons["plus"].tap()
        
        let nameTextField = app.textFields["Item name"]
        nameTextField.tap()
        nameTextField.typeText("Bread")
        
        app.buttons["Add"].tap()
        
        // Wait for item to be added
        XCTAssertTrue(app.staticTexts["Bread"].waitForExistence(timeout: 2))
        
        // When: Tap the circle button to mark as bought
        let circleButton = app.buttons["circle"]
        circleButton.tap()
        
        // Then: Item should be marked as bought (checkmark should appear)
        XCTAssertTrue(app.buttons["checkmark.circle.fill"].waitForExistence(timeout: 2))
        
        // When: Tap again to mark as not bought
        app.buttons["checkmark.circle.fill"].tap()
        
        // Then: Should be back to circle
        XCTAssertTrue(app.buttons["circle"].waitForExistence(timeout: 2))
    }
    
    func testSearchFunctionality() throws {
        // Given: Add multiple items
        app.buttons["plus"].tap()
        
        let nameTextField = app.textFields["Item name"]
        nameTextField.tap()
        nameTextField.typeText("Milk")
        app.buttons["Add"].tap()
        
        // Wait for first item to be added
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 2))
        
        app.buttons["plus"].tap()
        nameTextField.tap()
        nameTextField.typeText("Bread")
        app.buttons["Add"].tap()
        
        // Wait for second item to be added
        XCTAssertTrue(app.staticTexts["Bread"].waitForExistence(timeout: 2))
        
        // When: Search for "Milk"
        let searchField = app.textFields["Search items..."]
        searchField.tap()
        searchField.typeText("Milk")
        
        // Then: Only Milk should be visible
        XCTAssertTrue(app.staticTexts["Milk"].exists)
        XCTAssertFalse(app.staticTexts["Bread"].exists)
        
        // When: Clear search
        searchField.tap()
        searchField.buttons["Clear text"].tap()
        
        // Then: Both items should be visible again
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Bread"].waitForExistence(timeout: 2))
    }
    
    func testFilterBoughtItems() throws {
        // Given: Add an item and mark it as bought
        app.buttons["plus"].tap()
        
        let nameTextField = app.textFields["Item name"]
        nameTextField.tap()
        nameTextField.typeText("Milk")
        app.buttons["Add"].tap()
        
        // Wait for item to be added
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 2))
        
        // Mark as bought
        app.buttons["circle"].tap()
        XCTAssertTrue(app.buttons["checkmark.circle.fill"].waitForExistence(timeout: 2))
        
        // When: Toggle "Show Bought" off
        let showBoughtToggle = app.switches["Show Bought"]
        showBoughtToggle.tap()
        
        // Then: Item should be hidden
        XCTAssertFalse(app.staticTexts["Milk"].exists)
        
        // When: Toggle "Show Bought" on
        showBoughtToggle.tap()
        
        // Then: Item should be visible again
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 2))
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let stringValue = self.value as? String else {
            self.typeText(text)
            return
        }
        
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
} 