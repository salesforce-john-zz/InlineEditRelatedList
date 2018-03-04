/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ListBatch implements Database.AllowsCallouts, Database.Batchable<MC4SF.API.MailChimpList>, Database.Stateful, System.Schedulable {
    global Set<Id> deletedMcListIds;
    global Boolean runNextJobInChain;
    global ListBatch() {

    }
    global ListBatch(Boolean runNextJobInChain) {

    }
    global void execute(System.SchedulableContext context) {

    }
    global void execute(Database.BatchableContext context, List<MC4SF.API.MailChimpList> mailChimpLists) {

    }
    global void finish(Database.BatchableContext context) {

    }
    global System.Iterable start(Database.BatchableContext context) {
        return null;
    }
global class MailChimpListIterable implements System.Iterable<MC4SF.API.MailChimpList>, System.Iterator<MC4SF.API.MailChimpList> {
    global Boolean hasNext() {
        return null;
    }
    global System.Iterator iterator() {
        return null;
    }
    global MC4SF.API.MailChimpList next() {
        return null;
    }
}
}
