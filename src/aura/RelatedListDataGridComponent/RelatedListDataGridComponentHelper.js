({
    applyShadowEffect : function(component, event) {
        //Apply the shadow effect on the grid
        var gridContainer = component.find("gridContainer");
        $A.util.toggleClass(gridContainer, "shadow-effect");
    },
    toogleEditButton : function(component, event){
        //Show/hide the edit button
        var editButton = component.find("editButton");
        $A.util.toggleClass(editButton, "hidden");
    },   
    toogleGridActions : function(component, event){
        //Show/hide the action bar on the bottom
        var gridActions = component.find("gridActions");
        $A.util.toggleClass(gridActions, "hidden");
    },
    refreshUIElements : function(component, event){
        //Apply the shadow on the grid
        this.applyShadowEffect(component, event);
        
        //Toogle the edit button
        this.toogleEditButton(component, event);
        
        //Toogle the grid actions
        this.toogleGridActions(component, event);
        
        //Toogle the total row
        this.toogleTotal(component, event);
    },
    loadItems : function(component){
        //Load items from Salesforce
        var dataAction = component.get("c.getReleatedListItems");
        dataAction.setParams({
            "objectId": component.get("v.recordId"),
            "relatedlistName": component.get("v.relatedListName")
        });	
        
        dataAction.setCallback(this, function(res) {             
            var aggregate_map = { 
                sum : function(a, b){return a + b;},
                max : function(a, b){return Math.max(a,b);},
                min : function(a, b){return Math.min(a,b);}
            };
            
            var columns = component.get("v.columns");
        	var aggregations = Array(columns.length).fill("");     	
        
            if (res.getState() === "SUCCESS") {                 
                var items = res.getReturnValue();                
				var json_filter = component.get("v.filter");                
                
                //Apply Filters
                if (json_filter != null){
                    var obj_filter = JSON.parse(json_filter); 
                    var fn_filter = function(elt){
						for (var field in obj_filter) {
                            if (obj_filter.hasOwnProperty(field)) {
                                if(obj_filter[field] != elt[field]){
                                    return false;
                                }
                            }
                        }                       
                        
                        return true;
                    }
                    
                    items = items.filter(fn_filter);
                    
                }
                               
                //Apply Aggregate
                var json_aggregate = component.get("v.aggregate");                
                
                if (json_aggregate != null){    		
                    var obj_aggregate = JSON.parse(json_aggregate); 
                    columns.forEach(function(column, index){
                        if(obj_aggregate.hasOwnProperty(column.name)){
                            var key_aggregate = obj_aggregate[column.name];
                            var fn_aggregate = aggregate_map[key_aggregate];
                            var values = items.map(function(elt){return elt[column.name]});
                            
                            aggregations[index] = values.reduce(fn_aggregate).toString();
                        }    
                    });
                }
                
                aggregations[0] = "Total";
                
                //Update the UI
                component.set("v.items", items);                 
                component.set("v.aggregations", aggregations);                
            }
            else if (res.getState() === "ERROR") {
                $A.log("Errors", res.getError());
            }
        });   
        
        $A.enqueueAction(dataAction);    
    },
    refreshItems : function(component, items, displayMode){
        //Set the display mode
        component.set("v.displayMode", displayMode); 
        
        //Refresh the items        
        component.set("v.items", JSON.parse(JSON.stringify(items)));                
    },
    getCellComponents : function(component){
        var cellComponents = [];
        component.find("row").forEach(function(row){
            row.get("v.body").forEach(function(cell){
                cellComponents.push(cell);
            })
        });
        
        return cellComponents;
    },
    checkItems : function(component){
        var cellComponents = this.getCellComponents(component);        
        for(var c=0; c < cellComponents.length; c++){
            var cellCmp = cellComponents[c];
            if (cellCmp.get("v.hasErrors")){
                return false;
            }
        }                
        
        return true;
    },
    updateItems : function(component){        
        var items = component.get("v.items");
        var cellComponents = this.getCellComponents(component);
        
        //Update the items from cells
        cellComponents.forEach(function(cellCmp){
            var column = cellCmp.get("v.column");
            var item = items[cellCmp.get("v.itemRank")];
            
            item[column.name] = cellCmp.get("v.value");  
            
            if(column.type=='Reference'){
                item[column.name + '__Name'] = cellCmp.get("v.refLabel");
            }
        });
        
        return items;
    },
    saveItems : function(component, items, saveCallback){
        //Save items on Salesforce
        var saveItemsAction = component.get("c.saveRelatedListItems");
        
        saveItemsAction.setParams({
            "jsonData": JSON.stringify(component.get("v.items"))
        });	
        
        saveItemsAction.setCallback(this, function(res) { 
            if(res.getState()=="SUCCESS"){
                var dataAction = component.get("c.getReleatedListItems");
                dataAction.setParams({
                    "objectId": component.get("v.recordId"),
                    "relatedlistName": component.get("v.relatedListName")
                });	
                
                dataAction.setCallback(this, function(res) {                        
                    saveCallback(res.getState(), res.getError(), res.getReturnValue());                  
                });   
                
                $A.enqueueAction(dataAction);     
            }
            else{
                saveCallback(res.getState(), res.getError(), items);                  
            }             
        });   
        
        $A.enqueueAction(saveItemsAction);
    },
    toogleTotal : function(component, event){
        //Show/hide the total row on the bottom
        var totalComponent = component.find("total");
        $A.util.toggleClass(totalComponent, "hidden");
    }
})