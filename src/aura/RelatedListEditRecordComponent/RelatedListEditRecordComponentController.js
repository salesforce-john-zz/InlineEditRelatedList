({
    onShowDialogValueChange: function(component, event, helper){
        if(component.get('v.showDialog')) return;
        helper.fireCloseEvent(component, false, null);
    },
    
    cancelAction: function(component, event, helper){
        component.set('v.showDialog', false);
        helper.fireCloseEvent(component, false, null);        
        
        component.set('v.context', null); 
    },
    saveAction: function(component, event, helper){
        component.find('editComponent').get("e.recordSave").fire();        
        component.set('v.showDialog', false);                
        
        helper.fireCloseEvent(component, true, null);         
    },
    onSaveSuccess : function(component, event, helper) {
        helper.fireSaveEvent(component, true, null);  
        component.set('v.context', null); 
    }    
})