import Foundation
public struct UserDefaultsWrapper {
    public static var `default` = UserDefaultsWrapper()
    @UserDefault("serviceType", defaultValue: Constants.defaultServiceType)
    public var serviceType: String
}
