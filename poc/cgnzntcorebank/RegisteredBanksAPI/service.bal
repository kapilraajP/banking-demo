import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource to Retrieve registered funding banks in Cognizant
    # + return - json type containing the list of banks
    resource function get registered\-funding\-banks() returns json|error {
        // Send a response back to the caller.
        json listOfBanks = {"ListofBanks": ["ABC", "Bank GSA", "ERGO Bank", "MIS Bank", "LP Bank", "Co Bank"]};
        return listOfBanks;
    }
}
