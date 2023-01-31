import ballerina/http;
import ballerina/uuid;

float accountBalance = 0;
int transactionIndex = 0;

type Transactions record {|
    readonly int indexNo;
    float amount;
    string sourceOfPayment;
    string currency;
    string timeofTransaction;
|};

table<Transactions> key(indexNo) allTransactions = table [
    ];

type Accounts record {|
    readonly string userId;
    string accountName;
    string accountNumber;
    float balance;
|};


table<Accounts> key(userId) allAccounts = table [
    ];


# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function post create\-account(@http:Payload json accountDetails) returns json|error {
        // Send a response back to the caller.
        string userId = check accountDetails.userId;
        string accountName = check accountDetails.accountName;
        string accountNumber = check uuid:createType5AsString(
                                uuid:NAME_SPACE_DNS, "ballerina.io");
        json createdAccountDetails = {"UserId": userId, "Account Name": accountName, "Account Number": accountNumber};
        allAccounts.add({userId: userId, accountName:accountName, accountNumber:accountNumber, balance: accountBalance});
        return createdAccountDetails;
    }

    resource function post payments(@http:Payload json paymentDetails) returns json|error {
        // Send a response back to the caller.
        string typeofTransaction = check paymentDetails.typeofTransaction;
        float amount = check paymentDetails.amount;
        string sourceOfPayment = check paymentDetails.bankAccount;
        string currency = check paymentDetails.currency;
        string timeOfTransaction = check paymentDetails.timeOfTransaction;
        if (typeofTransaction == "RECEIVE")
        {
            accountBalance += amount;
        }
        else {
            accountBalance -= amount;
        }
        transactionIndex += 1;
        allTransactions.add({indexNo: transactionIndex, amount: amount, sourceOfPayment: sourceOfPayment, currency: currency, timeofTransaction: timeOfTransaction}); //update the transaction History table
        json transactionSummary = {"IndexNo": transactionIndex, "Amount": amount, sourceOfPayment: sourceOfPayment, currency: currency, timeofTransaction: timeOfTransaction};
        return transactionSummary;
    }

    resource function get transactions() returns json[] {
        // Send a response back to the caller.
        json[] transactionsHistory = <json[]>allTransactions.toJson();
        return transactionsHistory;

    }

    resource function get registered\-funding\-banks() returns json|error {
        // Send a response back to the caller.
        json listOfBanks = {"ListofBanks": ["ABC", "Bank GSA", "ERGO Bank", "MIS Bank", "LP Bank", "Co Bank"]};
        return listOfBanks;
    }

    resource function get accounts() returns json[]|error {
        // Send a response back to the caller.
        json[] listOfAccounts = <json[]>allAccounts.toJson();
        return listOfAccounts;
    }
}

