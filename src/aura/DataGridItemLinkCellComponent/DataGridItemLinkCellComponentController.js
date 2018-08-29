({
    doInit : function(component, event, helper) {              
        helper.doInit(component, event); 
        helper.doCustomInit(component, event); 
    },
    navigateToObject : function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.item").Id,
            "slideDevName": "detail"
        });
        
        navEvt.fire();
    }
})