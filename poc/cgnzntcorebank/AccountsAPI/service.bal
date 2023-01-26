import ballerina/http;
import ballerina/uuid;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource to return generate an accountNumber and return
    # + return - account Number
    resource function get create\-account() returns string|error {
        // Send a response back to the caller.
        string uuid5String = check uuid:createType5AsString(
                                    uuid:NAME_SPACE_DNS, "ballerina.io");
        return uuid5String;
    }
}
