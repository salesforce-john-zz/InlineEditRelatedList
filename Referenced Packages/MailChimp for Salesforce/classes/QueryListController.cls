/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class QueryListController {
    @RemoteAction
    global static MC4SF.QueryListController.ListData loadList(String listId) {
        return null;
    }
    @RemoteAction
    global static Id saveStaticSegment(String listId, String name) {
        return null;
    }
global class InterestGroup {
    global Id id;
    global String name;
    global Boolean subscribe;
    global InterestGroup() {

    }
}
global class InterestGrouping {
    global String formField;
    global Id id;
    global List<MC4SF.QueryListController.InterestGroup> interestGroups;
    global String name;
    global InterestGrouping() {

    }
}
global class ListData {
    global List<MC4SF.QueryListController.InterestGrouping> interestGroupings;
    global List<MC4SF.QueryListController.StaticSegment> staticSegments;
    global ListData() {

    }
}
global class StaticSegment {
    global Id id;
    global String name;
    global Boolean subscribe;
    global StaticSegment() {

    }
}
}
