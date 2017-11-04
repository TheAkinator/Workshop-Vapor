//
//  UserController.swift
//  hello-persistance
//
//  Created by Raul Marques de Oliveira on 20/08/17.
//
//

import Foundation
import Vapor
import HTTP


class UserController: ResourceRepresentable {

    let droplet: Droplet
//    let token: RouteBuilder

    init(droplet: Droplet) {
        self.droplet = droplet
//        self.token = token
        self.droplet.get("users", "startswith", String.parameter, handler: usersStartsWith(request:))
 
    }
    
    func usersStartsWith(request: Request) throws -> ResponseRepresentable {
        let string = try request.parameters.next(String.self)
        
        return try User.makeQuery().filter("name", .hasPrefix, string).all().makeJSON()
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let user =  try request.user()
        
        // ensure no user with this email already exists
        guard try User.makeQuery().filter("email", user.email).first() == nil else {
            throw Abort(.badRequest, reason: "A user with that email already exists.")
        }
        
        
        // require a plaintext password is supplied
        guard let password = request.json?["password"]?.string else {
            throw Abort(.badRequest, reason: "Password doesn't provided")
        }
        
        // hash the password and set it on the user
        user.password = try droplet.hash.make(password.makeBytes()).makeString()
        
        // save and return the new user
        try user.save()
        return user
    }
    
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    func update(request: Request, user: User) throws -> ResponseRepresentable {
        let new = try request.user()
        
        // require a plaintext password is supplied
        guard let password = request.json?["password"]?.string else {
            throw Abort(.badRequest, reason: "Password doesn't provided")
        }
        
        // hash the password and set it on the user
        new.password = try droplet.hash.make(password.makeBytes()).makeString()
        
        let user = user
        user.name = new.name
        user.email = new.email
        user.password = new.password
        try user.save()
        return user
    }
    
    func delete(request: Request, user: User) throws -> ResponseRepresentable {

        try user.delete()
        return JSON([:])
    }
    
    func makeResource() -> Resource<User> {
        
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            destroy: delete
        )
    }
}

extension Request {
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

