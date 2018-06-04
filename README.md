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

Display all the related lists. The list of related list is extracted from the object layout.
![alt text](https://cloud.githubusercontent.com/assets/7535971/20064242/4b87cb60-a50a-11e6-9f93-425d2ab6e065.PNG "Related Lists in read mode")

Then we switch to the edition mode:
![alt text](https://cloud.githubusercontent.com/assets/7535971/20064243/4b8a0ce0-a50a-11e6-8adb-a7f21a5e819e.PNG "Related Lists in write mode")

### RelatedListDataGridComponent

Display a specific related list based on the label. Using the label is more user friendly. 
The related list label can set from the app lightning builder.

Both components are availables in the lightning app builder. So just drag&drop and enjoy.
![alt text](https://cloud.githubusercontent.com/assets/7535971/20064241/4b8711d4-a50a-11e6-93a2-adbd40a93979.PNG "App Builder")

## Apex Testing

The package contains Unit Tests for Apex classes and Static Resources for Rest MockUp.

In this tutorial, I will show you how to use RelatedListEditor components from deployment to testing.

## Get Started

### Configuration
* Create subdomain on your salesforce instance. See [My Domain Setup](https://help.salesforce.com/articleView?id=domain_name_overview.htm&language=en_US&type=0) for more details.

* Add your salesforce instance as "Remote Site". See [Remote Site Setup](https://help.salesforce.com/articleView?id=configuring_remoteproxy.htm&type=0&language=en_US&release=206.8) for more details.
Here is my entry for this tutorial:
![](https://cloud.githubusercontent.com/assets/7535971/22865451/3d4ae65c-f165-11e6-9686-b6ac20d43511.png)
 
### App Builder
At this step, you will be able to see 2 new custom lightning components in the "lightning app builder". 

![Lightning App Builder](https://cloud.githubusercontent.com/assets/7535971/22865386/59da45da-f163-11e6-94fc-9d2f68875dca.png)

Now, You can change the account lightning page to use the brand new grid component.

All you have to do is to remove the 'Out Of The Box' components above and drag and drop the new component 'RelatedListDataGridsComponent'. 

![](https://cloud.githubusercontent.com/assets/7535971/22865469/b195282e-f165-11e6-9703-a42d3bd5fef9.png)

You can also change the page layout to display only the account contact list. We can see that the page is refreshed right away reflecting exactly what is defined at page layout.

![](https://cloud.githubusercontent.com/assets/7535971/22865535/79978a60-f166-11e6-9ce2-92470d7e645e.png)

Note that:
* RelatedListDataGridsComponent is used to display all the related list defined in page layout
* RelatedListDataGridComponent (without s) is to display a specific related list and you have specify the related list 'label' not the name.

### Testing
If you we zoom on a specific account, you can check that the contact list is well displayed in the grid and you can edit and save your changes from this page.  

![](https://cloud.githubusercontent.com/assets/7535971/22865560/f6e39892-f166-11e6-8b34-5beac7e4bdea.png)

![](https://cloud.githubusercontent.com/assets/7535971/22865582/a13617ca-f167-11e6-9919-926ee8c8f4d6.png)


