/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SubscriptionsController {
    global static void addInterestGroup(String listId, List<String> subscriberIds, Id id) {

    }
    @RemoteAction
    global static List<String> addList(String listId, List<String> subscriberIds) {
        return null;
    }
    @RemoteAction
    global static void addStaticSegment(String listId, List<String> subscriberIds, Id id) {

    }
    @RemoteAction
    global static void changeInterestGroup(String listId, List<String> subscriberIds, Id oldId, Id newId) {

    }
    @RemoteAction
    global static MC4SF.SubscriptionsController.ListData loadList(List<String> subscriberIds, String listId) {
        return null;
    }
    @RemoteAction
    global static void removeInterestGroup(String listId, List<String> subscriberIds, Id id) {

    }
    @RemoteAction
    global static void removeList(String listId, List<String> subscriberIds) {

    }
    @RemoteAction
    global static void removeStaticSegment(String listId, List<String> subscriberIds, Id id) {

    }
    @RemoteAction
    global static List<String> saveInterestGroup(String listId, List<String> subscriberIds, Id id) {
        return null;
    }
    @RemoteAction
    global static Id saveStaticSegment(String listId, List<String> subscriberIds, String name) {
        return null;
    }
global class InterestGroup {
    global Id id;
    global String name;
    global Boolean subscribe;
    global Boolean subscribed;
    global InterestGroup() {

    }
}
global class InterestGrouping {
    global String formField;
    global Id id;
    global List<MC4SF.SubscriptionsController.InterestGroup> interestGroups;
    global String name;
    global InterestGrouping() {

    }
}
global class ListData {
    global List<MC4SF.SubscriptionsController.InterestGrouping> interestGroupings;
    global List<MC4SF.SubscriptionsController.StaticSegment> staticSegments;
    global ListData() {

    }
}
global class StaticSegment {
    global Id id;
    global String name;
    global Boolean subscribe;
    global Boolean subscribed;
    global StaticSegment() {

    }
}
}
