({
    doCustomInit : function(component, event){
        var item = component.get("v.item");
        
        component.set("v.refValue", this.sobjectViewUrl(item.Id));
        component.set("v.refLabel", component.getReference("v.value"));      
    }
})