/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ListDeleteBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Set<Id> mcListIds;
    global String nextJob;
    global Boolean runNextJobInChain;
    global ListDeleteBatch(Set<Id> mcListIds) {

    }
    global ListDeleteBatch(Set<Id> mcListIds, Boolean runNextJobInChain) {

    }
    global ListDeleteBatch(Set<Id> mcListIds, Boolean runNextJobInChain, String nextJob) {

    }
    global void execute(Database.BatchableContext context, List<SObject> records) {

    }
    global void finish(Database.BatchableContext context) {

    }
    global Database.QueryLocator start(Database.BatchableContext context) {
        return null;
    }
}
