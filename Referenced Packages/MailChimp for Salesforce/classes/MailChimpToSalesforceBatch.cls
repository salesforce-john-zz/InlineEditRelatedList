/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MailChimpToSalesforceBatch implements Database.AllowsCallouts, Database.Batchable<Integer>, Database.Stateful {
    global MC4SF.ListIterator mcListIterator;
    global Datetime startTime;
    global String status;
    global MailChimpToSalesforceBatch() {

    }
    global MailChimpToSalesforceBatch(MC4SF.ListIterator mcListIterator) {

    }
    global MailChimpToSalesforceBatch(Id mcListId) {

    }
    global MailChimpToSalesforceBatch(String status) {

    }
    global MailChimpToSalesforceBatch(MC4SF.ListIterator mcListIterator, String status) {

    }
    global MailChimpToSalesforceBatch(Id mcListId, String status) {

    }
    global void execute(Database.BatchableContext context, List<Integer> pages) {

    }
    global void finish(Database.BatchableContext context) {

    }
    global System.Iterable start(Database.BatchableContext context) {
        return null;
    }
global class PageIterable implements System.Iterable<Integer>, System.Iterator<Integer> {
    global Boolean hasNext() {
        return null;
    }
    global System.Iterator iterator() {
        return null;
    }
    global Integer next() {
        return null;
    }
}
}
