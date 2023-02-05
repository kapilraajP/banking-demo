import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
# + name - Name of Bank Account
# + balance - Current balance of the accoaunt
# + accountNum - Account Number

type BankAccount record {
    readonly string name;
    float balance;
    int accountNum;
};

table<BankAccount> key(name) t = table [
    { name: "My Savings Account", balance: 24000.0, accountNum: 10001234 },
    { name: "College Fund Account", balance: 8572.0, accountNum: 10005678},
    { name: "Vacation Account", balance: 7234.0, accountNum: 10002222}
];


service / on new http:Listener(9090) {

    # A resource for retuning the list of accounts in the funding bank

    # + return - list of banks
    resource function get accounts() returns json[]{
        // Send a response back to the caller.
        json[] listOfAccounts = <json[]>t.toJson();
        return listOfAccounts;
    }
     resource function get transactions() returns json{
        // Send a response back to the caller.
        return {};
    }

     resource function post payments(@http:Payload json paymentDetails) returns json{
        // Send a response back to the caller.
        return {};
    }
}