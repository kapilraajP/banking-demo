import ballerina/http;

type Accounts record {
    readonly string name;
    int accountNumber;
    float amount;
};

// Creates a `table` with Account details 
// An account is uniquely identified using their `name` field.
table<Accounts> key(name) t = table [
        {name: "My Savings Account", accountNumber: 10001234, amount: 24000.00},
        {name: "College Fund Account", accountNumber: 10005678, amount: 8572.00},
        {name: "Vacation Account", accountNumber: 10002222, amount: 7234.00}
    ];

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for fund accounts details
    # + return - details of accounts
    resource function get accounts() returns json[]|error {
        // Send a response back to the caller.
        json[] accountDetails = <json[]>t.toJson();
        return accountDetails;
    }
}
