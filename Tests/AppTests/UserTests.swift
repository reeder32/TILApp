//
//  UserTests.swift
//  App
//
//  Created by Nick Reeder on 1/4/19.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {

    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!


    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }

    override func tearDown() {
        conn.close()
    }

    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: usersName,
                        username: usersUsername,
                        password: "password")

        let receivedUser = try app.getResponse(to: usersURI, method: .POST, headers: ["Content-Type": "application/json"], data: user, decodeTo: User.Public.self, loggedInRequest: true)

        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)

        let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self)

        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, receivedUser.id)
    }

    func testUsersCanBeRetrievedFromAPI() throws {


        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        _ = try User.create(on: conn)

        let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self)

        XCTAssertEqual(users.count, 3)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, user.id)
    }

    func testGettingASingleUserFromTheAPI() throws {
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        let retrievedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.Public.self)


        XCTAssertEqual(retrievedUser.name, usersName)
        XCTAssertEqual(retrievedUser.username, usersUsername)
        XCTAssertEqual(retrievedUser.id, user.id)

    }

    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: conn)

        let acronymShort = "OMG"
        let acronymLong = "Oh My God"

        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: conn)

        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: conn)

        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)

        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronym1.short)
        XCTAssertEqual(acronyms[0].long, acronym1.long)
    }

    static let allTests = [
    ("testUsersCanBeRetrievedFromAPI",
     testUsersCanBeRetrievedFromAPI),
    ("testUserCanBeSavedWithAPI",
    testUserCanBeSavedWithAPI),
    ("testGettingASingleUserFromTheAPI",
    testGettingASingleUserFromTheAPI),
    ("testGettingAUsersAcronymsFromTheAPI",
    testGettingAUsersAcronymsFromTheAPI)]
}
