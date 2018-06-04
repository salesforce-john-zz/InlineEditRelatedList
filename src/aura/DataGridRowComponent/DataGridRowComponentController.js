({
    doInit : function(component, event, helper) {
        var item = component.get("v.item");        
        var itemRank = component.get("v.itemRank");
        
        var columns = component.get("v.columns");
        var displayMode = component.get("v.displayMode");
        
        function getCellComponent(column, index){            
            var columnType = column.type;                    
            if(displayMode == 'read' && 
               column.name.toLowerCase() == 'name'){
                return "c:DataGridItemLinkCellComponent";
            }
            else{
                switch(columnType) {
                    case 'Boolean':
                        return "c:DataGridBooleanCellComponent";
                    case 'String':
                        return "c:DataGridStringCellComponent";                    
                    case 'TextArea':
                        return "c:DataGridTextAreaCellComponent";
                    case 'Phone':
                        return "c:DataGridPhoneCellComponent";
                    case 'Email':
                        return "c:DataGridEmailCellComponent";
                    case 'Url':
                        return "c:DataGridUrlCellComponent";
                    case 'Currency':
                        return "c:DataGridCurrencyCellComponent";
                    case 'Double':
                        return "c:DataGridDoubleCellComponent";
                    case 'Integer':
                        return "c:DataGridIntegerCellComponent";
                    case 'Percent':
                        return "c:DataGridPercentCellComponent";
                    case 'Date':
                        return "c:DataGridDateCellComponent";
                    case 'Datetime':
                        return "c:DataGridDatetimeCellComponent";
                    case 'PickList':
                        return "c:DataGridPickListCellComponent";
                    case 'Reference':
                        return "c:DataGridReferenceCellComponent";
                    case 'ItemLink':
                        return "c:DataGridItemLinkCellComponent";
                    case 'Formula':
                        return "c:DataGridFormulaCellComponent";
                    default:
                        return "c:DataGridFormulaCellComponent";
                }  
            }
        }
        
        var cellComponents = columns.map(function(column, index){
            return [getCellComponent(column, index),{                
                "aura:id" : "cellWrapper",
                "item" : item,
                "itemRank" : itemRank,                
                "displayMode" : displayMode,                
                "columnRank" : index,
                "column" : column				
            }];    
        });        
        
        $A.createComponents(
            cellComponents, 
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    components.forEach(function(subCmp){
                        body.push(subCmp);
                    });
                    component.set("v.body", body);
                }                
                else {
                    if(status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }                    
                }
            }
        );                            
    },    
    handleMenuSelect: function(component, event, helper) {
        var selectedValue = event.getParam("value");        
        if(selectedValue === "delete"){
            var deleteEvt = component.getEvent("onDelete");                
            deleteEvt.setParams({
                item: component.get('v.item')
            });
            
            deleteEvt.fire();          
        }
        if(selectedValue === "edit"){            
            var updateEvt = component.getEvent("onEdit");                
            updateEvt.setParams({
                item: component.get('v.item')
            });
            
            updateEvt.fire();
        }            
    }                      
})