@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
        
        let users = UserController(droplet: self)
        self.resource("users", users)
    }
}
