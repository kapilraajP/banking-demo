import ballerina/http;
import ballerina/uuid;
import ballerina/time;

float accountBalance = 0;
int transactionIndex = 0;

type Transactions record {|

    string accountId;
    readonly int transactionId;
    string transactionReference;
    float amount;
    string creditDebitIndicator;
    string bookingDateTime;
    string valueDateTime;
    string issuer;
    float balance;
    string currency;
|};

table<Transactions> key(transactionId) allTransactions = table [
    ];

type Accounts record {|
    readonly string accountId;
    string accountName;
    string status;
    string statusUpdateDateTime;
    string currency;
    string nickName;
    string openingDate;
    string maturityDate;
    string accountType;
    string accountSubType;
    float balance;

|};

table<Accounts> key(accountId) allAccounts = table [
    ];

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function post create\-account(@http:Payload json accountDetails) returns json|error {
        // Send a response back to the caller.
        string userId = check accountDetails.Data.Account.UserId;
        string accountName = check accountDetails.Data.Account.DisplayName;
        string currency = check accountDetails.Data.Account.Currency;
        string nickName = check accountDetails.Data.Account.Nickname;
        string openingDate = check accountDetails.Data.Account.OpeningDate;
        string maturityDate = check accountDetails.Data.Account.MaturityDate;
        string accountType = check accountDetails.Data.Account.AccountType;
        string accountSubType = check accountDetails.Data.Account.AccountSubType;
        string accountNumber = check uuid:createType5AsString(
                                uuid:NAME_SPACE_DNS, "ballerina.io");
        json createdAccountDetails = {"AccountID": accountNumber, "Account Name": accountName, "Status": "Enabled", "StatusUpdateDateTime": time:utcToString(time:utcNow()), "Currency": currency, "AccountType": accountType, "AccountSubType": accountSubType, "Nickname": nickName, "OpeningDate": openingDate, "MaturityDate": maturityDate, "Balance": accountBalance};
        allAccounts.add({accountId: accountNumber, accountName: accountName, status: "Enabled", statusUpdateDateTime: time:utcToString(time:utcNow()), currency: currency, nickName: nickName, openingDate: openingDate, maturityDate: maturityDate, accountType: accountType, accountSubType: accountSubType, balance: accountBalance});
        json returnvalue = {
            "Data": {
                "Account": [createdAccountDetails],
                "Meta": {
                },
                "Risk": {
                },
                "Links": {
                    "Self": ""
                }
            }
        };
        return returnvalue;
    }

    resource function post payments(@http:Payload json paymentDetails) returns json|error {
        // Send a response back to the caller.
        string reference = check paymentDetails.Data.Initiation.Reference;
        string creditDebitIndicator = check paymentDetails.Data.Initiation.CreditDebitIndicator;
        string amountTemp = check paymentDetails.Data.Initiation.InstructedAmount.Amount;
        string currency = check paymentDetails.Data.Initiation.CurrencyOfTransfer;
        string issuer = "";
        string accountId = "";
        string bookingDateTime = time:utcToString(time:utcNow());
        string valueDateTime = time:utcToString(time:utcNow());
        float amount = check float:fromString(amountTemp);

        issuer = check paymentDetails.Data.Initiation.CreditorAccount.SchemeName;
        accountBalance += amount;
        accountId = check paymentDetails.Data.Initiation.DebtorAccount.Identification;

        transactionIndex += 1;

        return self.setCredit(accountId, transactionIndex, reference, amount, creditDebitIndicator, bookingDateTime, valueDateTime, issuer, accountBalance, currency);
    }

    resource function get transactions() returns json {
        // Send a response back to the caller.
        json[] transactionsHistory = <json[]>allTransactions.toJson();

        return {
            "Data": {
                "Transaction": [transactionsHistory]

            }
        };
    }
    resource function get registered\-funding\-banks() returns json|error {
        // Send a response back to the caller.
        json listOfBanks = {"ListofBanks": ["ABC", "Bank GSA", "ERGO Bank", "MIS Bank", "LP Bank", "Co Bank"]};
        return listOfBanks;
    }

    resource function get accounts() returns json|error {
        // Send a response back to the caller.
        json[] listOfAccounts = <json[]>allAccounts.toJson();
        json returnData = {"Data": {"Account": listOfAccounts}};
        return returnData;
    }

    private function setCredit(string accountId, int transactionId, string transactionReference,
            float amount,
            string creditDebitIndicator,
            string bookingDateTime,
            string valueDateTime,
            string issuer,
            float balance,
            string currency) returns json {

        allTransactions.add({accountId: accountId, transactionId: transactionIndex, transactionReference: transactionReference, amount: amount, creditDebitIndicator: creditDebitIndicator, bookingDateTime: bookingDateTime, valueDateTime: valueDateTime, issuer: issuer, balance: accountBalance, currency: currency});
        json transactionSummary = {
            "Data": {
                "Status": "InitiationCompleted",
                "StatusUpdateDateTime": bookingDateTime,
                "CreationDateTime": valueDateTime,
                "Initiation": {

                },
                "Reference": transactionReference,
                "CurrencyOfTransfer": currency

            },
            "Meta": {

            },
            "Links": {
                "Self": ""
            }
        };
        return transactionSummary;

    }
}

