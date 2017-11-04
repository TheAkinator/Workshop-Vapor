//
//  User.swift
//  hello-persistance
//
//  Created by Raul Marques de Oliveira on 19/08/17.
//
//

import Foundation
import Vapor
import FluentProvider
import BCrypt


final class User: Model {
    
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    // Properties
    var name: String
    var email: String
    var password: String?
    
    // Properties keys
    static let idKey = "id"
    static let nameKey = "name"
    static let emailKey = "email"
    static let passwordKey = "password"

    
    init(name: String, email: String, password: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    init(row: Row) throws {
        name = try row.get(User.nameKey)
        email = try row.get(User.emailKey)
        password = try row.get(User.passwordKey)

    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        try row.set(User.emailKey, email)
        try row.set(User.passwordKey, password)

        return row
    }
    
    
}

// MARK: Fluent Preparation

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string(User.nameKey)
            users.string(User.emailKey)
            users.string(User.passwordKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(User.nameKey),
            email: json.get(User.emailKey)
        )
        id = try json.get(User.idKey)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.nameKey, name)
        try json.set(User.emailKey, email)
        try json.set(User.passwordKey, password)


        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension User: ResponseRepresentable { }








