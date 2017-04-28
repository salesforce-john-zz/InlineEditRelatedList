({
    onShowDialogValueChange: function(component, event, helper){
        if(component.get('v.showDialog')) return;
        helper.fireCloseEvent(component, false, null);
    },
    
    closeModal: function(component, event, helper){
        component.set('v.showDialog', false);
        helper.fireCloseEvent(component, false, null);
        
    },   
    closeModalYes: function(component, event, helper){
        component.set('v.showDialog', false);
        helper.fireCloseEvent(component, true, null);  
    }
})