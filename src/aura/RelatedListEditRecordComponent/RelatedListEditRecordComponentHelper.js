({	
    fireCloseEvent : function(component, confirmResult, inputResult, context) {
        var evt = component.getEvent("onClose");
        
        evt.setParams({
            dialogType: component.get('v.type'),
            confirmResult: confirmResult || false,
            context: component.get('v.context') || {},
        });
        
        evt.fire();
    },
    fireSaveEvent : function(component, confirmResult, inputResult, context) {
        var evt = component.getEvent("onSave");
        
        evt.setParams({
            dialogType: component.get('v.type'),
            confirmResult: confirmResult || false,
            context: component.get('v.context') || {},
        });
        
        evt.fire();
    }
})