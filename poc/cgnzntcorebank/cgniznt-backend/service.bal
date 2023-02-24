import ballerina/http;




# A service representing a network-accessible API

# bound to port `9090`.

configurable float testValue = ?;




public type Amount record {

    # A code allocated to a currency by a Maintenance Agency under an international identification scheme, as described in the latest edition of the international standard ISO 4217 "Codes for the representation of currencies and funds".

    string Currency = "USD";

};




service / on new http:Listener(9090) {




    # A resource for generating greetings

    # + name - the input string name

    # + return - string name with hello message or error

    resource function get greeting(string name) returns Amount {

        // Send a response back to the caller.

        // if name is "" {

        //     return error("name should not be empty!" + testValue.toString());

        // }

        // return "Hello, " + name + testValue.toString();




        Amount val = {};

        return val;




    }

}
