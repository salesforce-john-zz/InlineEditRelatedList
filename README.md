<a href="https://githubsfdeploy.herokuapp.com?owner=hicham-elmansouri/&repo=SFRelatedListEditor">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## Overview

This app provides all the necessary lightning components to enable inline editing for related list.

## What is in the box

The app provides lightning components for the client side and a controller to handle metatdata and data manipulation in the backend.
The controller can handle any type of object (standard and custom as well). To achieve this, I massivelly used the Salesfroce Rest API mainly "sobject" API(s). 

## Lightning Components

### RelatedListDataGridsComponent

Display all the related lists. The list of related list is extracted from the object layout (See below: View mode and edition mode).
![alt text](https://user-images.githubusercontent.com/7535971/40939794-0dab7d40-6846-11e8-9ec8-1589bcba46d3.png "Related Lists")


### RelatedListDataGridComponent

Display a specific related list based on the label. Using the label is more user friendly. 
The related list label can set from the app lightning builder.

Both components are availables in the lightning app builder. So just drag&drop and enjoy.
![Lightning App Builder](https://cloud.githubusercontent.com/assets/7535971/22865386/59da45da-f163-11e6-94fc-9d2f68875dca.png)


## Apex Testing

The package contains Unit Tests for Apex classes and Static Resources for Rest MockUp.

In this tutorial, I will show you how to use RelatedListEditor components from deployment to testing.

## Get Started

### Configuration
* Each user using any page with RelatedListGrid should have a profil with API enabled.

* Create subdomain on your salesforce instance. See [My Domain Setup](https://help.salesforce.com/articleView?id=domain_name_overview.htm&language=en_US&type=0) for more details.

* Add your salesforce instance as "Remote Site". See [Remote Site Setup](https://help.salesforce.com/articleView?id=configuring_remoteproxy.htm&type=0&language=en_US&release=206.8) for more details.
Here is my entry for this tutorial:
![](https://cloud.githubusercontent.com/assets/7535971/22865451/3d4ae65c-f165-11e6-9686-b6ac20d43511.png)

 
### App Builder
At this step, you will be able to see 2 new custom lightning components in the "lightning app builder". 

To change the account lightning page and use RelatedListGrid components, remove the 'Out Of The Box' components above and drag and drop the new component 'RelatedListDataGridsComponent'.

![](https://user-images.githubusercontent.com/7535971/40939796-0e0b5f6c-6846-11e8-842a-094f85c6602d.png)

Note that:
* RelatedListDataGridsComponent is used to display all the related list defined in page layout
* RelatedListDataGridComponent (without s) is to display a specific related list and you have specify the related list 'label' not the name.

When you display only one related list, you have different options to play with like filtering, sorting (see screenshot below):

![](https://user-images.githubusercontent.com/7535971/40939795-0ddb9b24-6846-11e8-98fe-2a391308a813.png)

* Filter example : If we want to filter only Closed Won Opportunities : {"StageName":"Closed Won"}

* Aggregate example :  If we want to display the total row at the end representing the sum of opportunities amount : {"Amount":"sum"}

* Default Values example : If we check 'Can Create Object', the component use default values property to initialize the new object when you hit (+) button. This is usefulf to set the non displayed fields. The parent id for exemple. {"accountid":"$recordId", "name":"Opp 1", "closedate" : "2018-07-07","stagename":"Needs Analysis"}

Note that: Use $recordId to reference the current record Id and dot not forget to user low case for field name. 

* Sort example : If you want to sort the grid, set the field name : Amount  

* Order exemple : 'asc' or 'desc'


