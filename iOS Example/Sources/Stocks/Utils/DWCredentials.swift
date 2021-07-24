internal struct DWCredentials {
    
    public var appTypeID: Int
    public var username: String
    public var password: String
    public var appKey: String
    public var session: DWSession?
}


internal struct DWSession {
    
    public var userID: String
    public var authToken: String
}
