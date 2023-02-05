import ballerina/http;
import ballerina/time;
import ballerina/log;

# A service representing a network-accessible API
# bound to port `9090`.
# + name - Name of Bank Account
# + balance - Current balance of the accoaunt
# + accountNum - Account Number

type BankAccount record {
    readonly string name;
    float balance;
    string accountId;
};

table<BankAccount> key(name) allAccounts = table [
    { name: "My Savings Account", balance: 24000.0, accountId: "10001234" },
    { name: "College Fund Account", balance: 8572.0, accountId: "10005678"},
    { name: "Vacation Account", balance: 7234.0, accountId: "10002222"}
];

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

service / on new http:Listener(9090) {

    # A resource for retuning the list of accounts in the funding bank

    # + return - list of banks
    resource function get accounts() returns json[]{
        // Send a response back to the caller.
        json[] listOfAccounts = <json[]>allAccounts.toJson();
        return listOfAccounts;
    }
     resource function get transactions() returns json{
        // Send a response back to the caller.
        return {};
    }

     resource function post payments(@http:Payload json paymentDetails) returns json|http:BadRequest{
        // Send a response back to the caller.
         do {
            // Send a response back to the caller.
            string reference = check paymentDetails.Data.Initiation.Reference;
            string creditDebitIndicator = check paymentDetails.Data.Initiation.CreditDebitIndicator;
            string amountTemp = check paymentDetails.Data.Initiation.Amount.Amount;
            string currency = check paymentDetails.Data.Initiation.Amount.Currency;
            string bookingDateTime = time:utcToString(time:utcNow());
            string valueDateTime = time:utcToString(time:utcNow());
            float amount = check float:fromString(amountTemp);
            string[] accountId_issuer = check self.setAccount(paymentDetails, amount);
            string issuer = accountId_issuer[0];
            string accountId = accountId_issuer[1];
            transactionIndex += 1;
            float accountBalance = check self.getAccountBal(accountId);
            return self.setCredit(accountId, transactionIndex, reference, amount, creditDebitIndicator, bookingDateTime, valueDateTime, issuer, accountBalance, currency);
        } on fail var e {
            string message = e.message();
            log:printError(message);
            return http:BAD_REQUEST;
    }
     }

    private function setAccount(json details, float amount) returns string[]|error
    {
        string creditDebitIndicator = check details.Data.Initiation.CreditDebitIndicator;
        string issuer = "";
        string accountId = "";
        if (creditDebitIndicator == "Credit")
        {
            issuer = check details.Data.Initiation.DebtorAccount.SchemeName;
            accountId = check details.Data.Initiation.CreditorAccount.Identification;
            self.changeAccountBalance(amount, accountId, "Credit");

        }
        else {
            issuer = check details.Data.Initiation.CreditorAccount.SchemeName;
            accountId = check details.Data.Initiation.DebtorAccount.Identification;
            self.changeAccountBalance(amount, accountId, "Debit");

        }
        return [issuer, accountId];

    }

    private function changeAccountBalance(float amount, string accountId, string typeofTrans)
    {
        foreach BankAccount ac in allAccounts {
            if (ac.accountId == accountId && typeofTrans == "Credit")
            {
                ac.balance += amount;
            }
            if (ac.accountId == accountId && typeofTrans == "Debit")
            {
                ac.balance -= amount;
            }

        }
    }

    private function getAccountBal(string accountId) returns float|error
    {
        foreach BankAccount ac in allAccounts {
            if (ac.accountId == accountId)
            {
                return ac.balance;
            }

        }

        return 0;
    }

    private function setCredit(string accountId, int transactionId, string transactionReference,
            float amount,
            string creditDebitIndicator,
            string bookingDateTime,
            string valueDateTime,
            string issuer,
            float balance,
            string currency) returns json {

        allTransactions.add({accountId: accountId, transactionId: transactionIndex, transactionReference: transactionReference, amount: amount, creditDebitIndicator: creditDebitIndicator, bookingDateTime: bookingDateTime, valueDateTime: valueDateTime, issuer: issuer, balance: balance, currency: currency});
        json transactionSummary = {
            "Data": {
                "Status": "InitiationCompleted",
                "StatusUpdateDateTime": bookingDateTime,
                "CreationDateTime": valueDateTime,
                "Initiation": {
                    "Issuer": issuer
                },
                "Reference": transactionReference,
                "Amount": {
                    "Amount": amount,
                    "Currency": currency
                }
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