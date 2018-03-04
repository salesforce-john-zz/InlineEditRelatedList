/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class QueryBatch implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful, System.Schedulable {
    global Map<String,MC4SF__MC_Query_Filter__c> codeBasedFilters;
    global MC4SF__MC_Query__c mcQuery;
    global MC4SF.ListIterator queryIterator;
    global Datetime startTime;
    global QueryBatch() {

    }
    global QueryBatch(MC4SF.ListIterator queryIterator, Datetime startTime) {

    }
    global void execute(System.SchedulableContext context) {

    }
    global void execute(Database.BatchableContext context, List<SObject> records) {

    }
    global void finish(Database.BatchableContext context) {

    }
    global Database.QueryLocator start(Database.BatchableContext context) {
        return null;
    }
global class Query {
    global Query(Id id, String objectName) {

    }
}
}
