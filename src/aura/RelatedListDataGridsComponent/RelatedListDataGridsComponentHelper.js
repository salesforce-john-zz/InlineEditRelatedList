({
    loadRelatedLists : function(component, event) {
        //Get the Session ID first        
        var sessionIdAction = component.get("c.getSessionId");  
        
        sessionIdAction.setCallback(this, function(res) {            
            if (res.getState() === "SUCCESS" && res.getReturnValue()) {   
                component.set("v.sessionId", res.getReturnValue());
                
                //Get the related list for the given object        
                var metadataAction = component.get("c.getReleatedListsMetadata");
                
                metadataAction.setParams({
                    "objectId": component.get("v.recordId"),
                    "sessionId":component.get("v.sessionId")
                });
                
                metadataAction.setCallback(this, function(res) {			
                    if (res.getState() === "SUCCESS") { 
                        component.set("v.relatedLists", res.getReturnValue());
                    } 
                    else if (res.getState() === "ERROR") {
                        $A.log("Errors", res.getError());
                    }           
                });  
                
                $A.enqueueAction(metadataAction);  
            }
            else if (res.getState() === "ERROR") {
                $A.log("Errors", res.getError());
            }           
        });  
        
        $A.enqueueAction(sessionIdAction); 
    }
})