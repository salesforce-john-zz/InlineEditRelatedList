({
    doInit : function(component, event, helper) {  
        //If the component is initialized 
        //From the related lists component
        //We have just to load items
        if(component.get("v.relatedObjectName")!=""){
            helper.loadItems(component);                      
        }
        
        //Otherwise we have to load 
        //the metadata as well
        else{
            if(component.get("v.relatedListLabel")){
                var metadataAction = component.get("c.getReleatedListMetadata");
                
                metadataAction.setParams({
                    "objectId": component.get("v.recordId"),
                    "relatedListLabel": component.get("v.relatedListLabel")
                });
                
                metadataAction.setCallback(this, function(res) {            
                    if (res.getState() === "SUCCESS" && res.getReturnValue()) {        
                        component.set("v.relatedListName", res.getReturnValue().name);
                        component.set("v.relatedObjectName",  res.getReturnValue().sobject);
                        component.set("v.columns", res.getReturnValue().columns);                                               
                        
                        //Set the viewAll Link
                        var viewAllLink = helper.viewAllUrl(component.get("v.recordId"),
                                                            component.get("v.relatedListName"));                        
                        component.set("v.viewAllLink", viewAllLink);
                        
                        helper.loadItems(component);                      
                    } 
                    else if (res.getState() === "ERROR") {
                        $A.log("Errors", res.getError());
                    }           
                });  
                
                $A.enqueueAction(metadataAction);             
            }
        }
        
        //Toogle the total row
        helper.toogleTotal(component, event);
        
        //Update the default values for the current record
        var defaultValues = component.get("v.defaultValues");
        defaultValues = defaultValues.replace("$recordId", component.get("v.recordId"));
        component.set("v.defaultValues", defaultValues);
        
        //Set the display label        
        var displayLabel = component.get("v.customLabel") || component.get("v.relatedListLabel");                        
        component.set("v.displayLabel", displayLabel);                
    },    
    startEdit : function(component, event, helper) {
        //Save a copy of items
        component.set("v.oldItems", JSON.parse(JSON.stringify(component.get("v.items"))));
        
        //Refresh the items
        helper.refreshItems(component, component.get("v.items"), "write");               
        
        //Refresh the UI elements(Edit button and actions)
        helper.refreshUIElements(component, event);
    },
    cancelEdit : function(component, event, helper) {         
        helper.refreshItems(component, component.get("v.oldItems"), "read");                       
        helper.refreshUIElements(component, event);        
    },
    saveEdit : function(component, event, helper) {                       
        if(helper.checkItems(component)){
            //Update the items
            var items = helper.updateItems(component);
            
            //OnSave items callback
            function onSaveSuccess(res){
                //Set the display mode
                component.set("v.displayMode", "read"); 
                
                //Refresh the items
                helper.loadItems(component, function(newItems){                    
                    //Refresh the UI elements
                    helper.refreshUIElements(component, event);                    
                    
                    //Display a confirmation Taost
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": "The items list has been updated successfully"
                    });
                    toastEvent.fire(); 
                    
                    $A.get('e.force:refreshView').fire();
                });                                
            }
            
            function onSaveError(res){                      
                var errMsg = null;
                var errors = res.getError();
                
                if(errors[0] && errors[0].message){
                    errMsg = errors[0].message;
                } 
                if(errors[0] && errors[0].pageErrors) {
                    errMsg = errors[0].pageErrors[0].message;
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "mode" : "sticky",
                    "message": "Server Error:" + errMsg
                });
                toastEvent.fire();                    
            }        
            
            //Save items in the backend
            helper.saveItems(component, items, onSaveSuccess, onSaveError);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "mode" : "sticky",
                "message": "Save failed. Check your data and try again"
            });
            toastEvent.fire();
        }
    },
    createItem : function(component, event, helper){
        var createAction = component.get("c.createRelatedObject");
        
        createAction.setParams({          
            "objectId": component.get("v.recordId"),
            "objectName" : component.get("v.relatedObjectName"),                                       
            "jsonData": component.get("v.defaultValues")
        });
        
        createAction.setCallback(this, function(res) {            
            if (res.getState() === "SUCCESS" && res.getReturnValue()) {                        
                helper.notifyItemCreated(component, res.getReturnValue());                     
            } 
            else if (res.getState() === "ERROR") {
                $A.log("Errors", res.getError());
            }           
        });  
        
        $A.enqueueAction(createAction);         
    },
    reloadItems : function(component, event, helper){
        helper.loadItems(component); 
    },        
    deleteCallback: function(component, event, helper) {
        if (event.getParam('confirmResult')){
            var deleteDialog = component.find("deleteDialog");                
            var loaderDialog = component.find("loaderDialog");  
            
            var deleteAction = component.get("c.deleteRelatedRecord");
            var item = deleteDialog.get("v.context");
            
            deleteAction.setParams({
                "objectId": item.Id            
            });
            
            deleteAction.setCallback(this, function(res) { 
                loaderDialog.set('v.showDialog', false);                        
                
                if (res.getState() === "SUCCESS") {        
                    helper.notifyItemDeleted(component, item);
                } 
                
                else if (res.getState() === "ERROR") {
                    $A.log("Errors", res.getError());
                }                                   
            });   
            
            loaderDialog.set('v.title', 'Deleting ' + item.Name);
            loaderDialog.set("v.content", "Please wait while deleting the record");
            loaderDialog.set('v.showDialog', true);
            
            $A.enqueueAction(deleteAction);            
        }                
    },
    editCallback: function(component, event, helper) {
        if (event.getParam('confirmResult')){
            var loaderDialog = component.find("loaderDialog");
            loaderDialog.set('v.title', 'Saving ' + event.getParam('context').Name);
            loaderDialog.set("v.content", "Please wait while saving the record"); 
            loaderDialog.set('v.showDialog', true);           
        }
    },
    saveCallback: function(component, event, helper) {
        var loaderDialog = component.find("loaderDialog");         
        loaderDialog.set('v.showDialog', false); 
        
        helper.notifyItemUpdated(component, event.getParam('context'));                   
    },
    actionDelete : function(component, event, helper){       
        var deleteDialog = component.find("deleteDialog"); 
        var item = event.getParam('item');
        
        deleteDialog.set('v.title', 'Delete ' + item.Name);
        deleteDialog.set('v.content', 'Do you really want to delete this record?')                       
        deleteDialog.set('v.context', item);
        
        deleteDialog.set('v.showDialog', true);        
    },
    actionEdit : function(component, event, helper){                    
        var editDialog = component.find('editDialog');
        
        editDialog.set('v.context', event.getParam('item'));                       
        editDialog.set('v.showDialog', true);         
    }    
})