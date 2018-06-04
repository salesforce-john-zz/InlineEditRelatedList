public with sharing class RelatedListDataGridController {      
    public static Map<Schema.DisplayType, String> typesMap = new Map<Schema.DisplayType, String>();
    
    static {
        typesMap.put(Schema.DisplayType.TextArea, 'TextArea');
        typesMap.put(Schema.DisplayType.STRING, 'String');
        typesMap.put(Schema.DisplayType.BOOLEAN, 'Boolean');
        typesMap.put(Schema.DisplayType.COMBOBOX, 'Combobox');
        typesMap.put(Schema.DisplayType.CURRENCY, 'Currency');
        typesMap.put(Schema.DisplayType.DATE, 'Date');
        typesMap.put(Schema.DisplayType.DATETIME, 'Datetime');
        typesMap.put(Schema.DisplayType.DOUBLE, 'Double');
        typesMap.put(Schema.DisplayType.ADDRESS, 'Adress');
        typesMap.put(Schema.DisplayType.EMAIL, 'Email');
        typesMap.put(Schema.DisplayType.INTEGER, 'Integer');
        typesMap.put(Schema.DisplayType.PERCENT, 'Percent');
        typesMap.put(Schema.DisplayType.MULTIPICKLIST, 'Multi PickList');
        typesMap.put(Schema.DisplayType.PICKLIST, 'PickList');
        typesMap.put(Schema.DisplayType.PHONE, 'Phone');
        typesMap.put(Schema.DisplayType.REFERENCE, 'Reference');
        typesMap.put(Schema.DisplayType.URL, 'Url');       
    }
    
    /**
    * Clean the related list metadata
	* -If the field is AutoNumber or Calculated set the type to Formula. Otherwise set the type from the map
	* -If the column is not an inner field set the type to Reference
	* -If the field is not accessible remove the field from columns list  
	* */
    private static void cleanRelatedListMetadata(Map<String, Object> mRelatedListMetadata)
    {
        Object[] columns = (Object[] )mRelatedListMetadata.get('columns');                
        String relatedObjectName = (String)mRelatedListMetadata.get('sobject');
        
        Schema.SObjectType relatedObjType = Schema.getGlobalDescribe().get(relatedObjectName);
        Schema.DescribeSObjectResult relatedObjDesc = relatedObjType.getDescribe();        
        
        for(Integer i=0; i<columns.size(); i++){
            Map<String, Object> mColumn = (Map<String, Object>) columns.get(i);
            String columnKey = (String)mColumn.get('name');
            
            //If it's a Picklist field
            if(columnKey.startsWith('toLabel(')){
                columnKey = columnKey.substringBetween('toLabel(', ')');
                mColumn.put('name', columnKey);
            }
            //If it's a Reference field
            if(columnKey.endsWith('.Name')){                
                mColumn.put('refObjName', ((String)mColumn.get('field')).replace('.Name', ''));
                if(mColumn.get('lookupId')!=null){
                    columnKey = ((String)mColumn.get('lookupId')).replace('.', '');
                    mColumn.put('name', columnKey);   
                }
            }
            
            Schema.SObjectField sfield = relatedObjDesc.fields.getMap().get(columnKey);           
            if(sfield != null){
                DescribeFieldResult fieldDescResult = sfield.getDescribe(); 
                
                if(fieldDescResult.isAccessible()){
                    //Set requied flag
                    mColumn.put('required', JSON.serialize(!fieldDescResult.isNillable()));
                    
                    //Set precision
                    mColumn.put('precision', JSON.serialize(fieldDescResult.getPrecision()));
                    
                    //Set picklistValues
                    mColumn.put('options', JSON.serialize(fieldDescResult.getPicklistValues()));
                    
                    //Set digits
                    mColumn.put('digits', JSON.serialize(fieldDescResult.getDigits()));
                    
                    //Set length
                    mColumn.put('length', JSON.serialize(fieldDescResult.getLength()));
                    
                    //Set type
                    mColumn.put('type', typesMap.get(fieldDescResult.getType()));        
                    
                    //Set type for Formula Fields
                    if(fieldDescResult.isCalculated()){
                        mColumn.put('calculatedType', mColumn.get('type')); 
                        mColumn.put('type', 'Formula');                           
                    }   
                    
 					//Set type for AutoNumber Fields
                    if(fieldDescResult.isAutoNumber()){
                        mColumn.put('calculatedType', mColumn.get('type')); 
                        mColumn.put('type', 'ItemLink');                           
                    }                       
                }else{
                    columns.remove(i);
                }                            
            }else{
                mColumn.put('type', 'Reference');                    
            }
        }
    }
    
    /**
    * Return the list of related metadata information
    * */
    @AuraEnabled
    public static Object[] getReleatedListsMetadata(Id objectId)
    {
        String recordTypeName = RestAPIUtils.getObjectRecordTypeName(objectId);
        if(recordTypeName=='Master' || recordTypeName=='Principal'){
            recordTypeName = null;
        }
        Object[] relatedListsMetatdata = RestAPIUtils.getRelatedListsMetadata(objectId, 
                                                                              recordTypeName);
        
        for(Object relatedListMetadata : relatedListsMetatdata){
            cleanRelatedListMetadata((Map<String, Object>)relatedListMetadata); 
        }
        
        return relatedListsMetatdata;
    }
    
    /**
    * Return the metadata of the related list
    * */
    @AuraEnabled
    public static Object getReleatedListMetadata(Id objectId, 
                                                 String relatedListLabel)
    {
        String recordTypeName = RestAPIUtils.getObjectRecordTypeName(objectId);
        if(recordTypeName=='Master' || recordTypeName=='Principal'){
            recordTypeName = null;
        }
        Object[] relatedListsMetatdata = RestAPIUtils.getRelatedListsMetadata(objectId, 
                                                                              recordTypeName);
        
        for(Object relatedListMetadata : relatedListsMetatdata){
            Map<String, Object> mRelatedListMetadata = (Map<String, Object>)relatedListMetadata;
            if(mRelatedListMetadata.get('label') == relatedListLabel){
                cleanRelatedListMetadata(mRelatedListMetadata); 
                return mRelatedListMetadata;
            }
        }           
        
        return null;
    }        
    
    /**
    * Return the the related list items
    * */
    @AuraEnabled
    public static Object[] getReleatedListItems(Id objectId, 
                                                String relatedlistName)
    {            
        Object[] items = RestAPIUtils.getRelatedListItems(objectId, 
                                                          relatedlistName);
        if(items.size()>0){        
            Id firstChildId = (Id)((Map<String, Object>) items.get(0)).get('Id');            
        	DescribeSObjectResult objectDescResult = firstChildId.getSobjectType().getDescribe();
            
        	Map<String, DescribeFieldResult> lookupFields = new Map<String,DescribeFieldResult>();  
            Map<String, DescribeFieldResult> pickListFields = new Map<String,DescribeFieldResult>();    
            Map<String, DescribeFieldResult> percentFields = new Map<String,DescribeFieldResult>();    
            
            for(Schema.SObjectField sfield : objectDescResult.fields.getMap().Values()){ 
                DescribeFieldResult fieldDescResult = sfield.getDescribe();                
                if(fieldDescResult.getType()==Schema.DisplayType.REFERENCE){                        
                    lookupFields.put(fieldDescResult.getName(), fieldDescResult);
                } 
                
                if(fieldDescResult.getType()==Schema.DisplayType.PICKLIST){                        
                    pickListFields.put(fieldDescResult.getName(), fieldDescResult);
                } 
                
                if(fieldDescResult.getType()==Schema.DisplayType.PERCENT){                        
                    percentFields.put(fieldDescResult.getName(), fieldDescResult);
                } 
            }   
			
            //Set the lookup labels based on the field type
            for(String fieldKey : lookupFields.keySet()){
                Set<Id> lookupIds = new Set<Id>();
                Map<Id, List<Object>> lookupMap = new Map<Id, List<Object>>();                
                
                //Build the list of IDs
                for(Object item : items){
                    Map<String, Object> mItem = (Map<String, Object>) item;
                    if(mItem.containsKey(fieldKey)){
                        Id lookupId = (Id)mItem.get(fieldKey);
                        if(lookupId != null){
                            lookupIds.add(lookupId); 
                            if(!lookupMap.containsKey(lookupId)){
                                lookupMap.put(lookupId, new List<Object>());
                            }
                            lookupMap.get(lookupId).add(mItem);
                        }                        
                    }
                }
                               
                //Do SOQL query based on the ID list
                if(!lookupIds.isEmpty()){
                    SObject[] lookupObjs = getLookupObjects(lookupIds);                 
                    for(SObject lookupObj : lookupObjs){
                        for(Object item : lookupMap.get(lookupObj.Id)){
                            Map<String, Object> mItem = (Map<String, Object>) item;
                            try{                            	
                                mItem.put(fieldKey + '__Name', lookupObj.get('Name'));                                                                                        
                            }
                            catch(Exception e){
                                System.debug(e.getMessage());
                                mItem.put(fieldKey + '__Name', 'Undefined'); 
                            }
                        }
                    }
                }
            }
            
            //Update the pickList field 
            for(String fieldKey : pickListFields.keySet()){                
                DescribeFieldResult fieldDescResult =  pickListFields.get(fieldKey);                        
                List<PicklistEntry> valuesList = fieldDescResult.getPicklistValues();                    
                Map<String, String> valuesMap = new Map<String, String>();
                for(PicklistEntry entry : valuesList){
                    valuesMap.put(entry.getValue(), entry.getLabel());
                }
                
                for(Object item : items){                    
                    Map<String, Object> mItem = (Map<String, Object>) item;
                    mItem.put(fieldKey, (String)valuesMap.get((String)mItem.get(fieldKey)));
                }
            }             
             
            
            //Update the percent field 
            for(String fieldKey : percentFields.keySet()){                
                for(Object item : items){                    
                    Map<String, Object> mItem = (Map<String, Object>) item;
                    if(mItem.get(fieldKey) != null){
	                    mItem.put(fieldKey, (decimal)mItem.get(fieldKey)/100);
                    }
                }
            }    
            
            return items;                    
        }
                
        return null;
    } 
    
    /**
     * Return the list of objects based on the lookup ids
     * */
    private static SObject[] getLookupObjects(Set<Id> lookupIds)
    {
        Schema.SObjectType sobjectType = (new list<Id>(lookupIds))[0].getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        if(isSafeObject(sobjectName) && isSafeField('Name', sobjectName)){
        	return Database.query('Select Id, Name From ' + 
	                              sobjectName + 
	                              ' Where Id in :lookupIds');
        }
        
        return null;                   
    }
    
    /**
    * Save the related list items
    * */
    @AuraEnabled
    public static Boolean saveRelatedListItems(String jsonData)
    {
        List<SObject> sObjectsItems = new List<SObject>();
        
        Object[] items = (Object[])JSON.deserializeUntyped(jsonData);
        
        for(Object obj : items) {
            Map<String, Object> mObj = (Map<String, Object>)obj;
            
            //Init the SObject instance
            Id objId = (Id)mObj.get('Id');
            Schema.SObjectType objType = objId.getSobjectType();
            SObject sObj = objType.newSObject(objId);
            
            //Update the fields
            for(String field : mObj.keySet()){
                Schema.SObjectField sfield = objType.getDescribe().fields.getMap().get(field);
                if(sfield != null && sfield.getDescribe().isUpdateable()){
                    if(sfield.getDescribe().getType() == Schema.DisplayType.DATE){
                        if(mObj.get(field) != null){
                            String dateStr = ((String)mObj.get(field)) + ' 00:00:00';
                            sObj.put(field, Date.valueOf(dateStr));                                                
                        }
                    }
                    else if(sfield.getDescribe().getType() == Schema.DisplayType.DATETIME){
                        if(mObj.get(field) != null){
                            String datetimeStr = ((String)mObj.get(field)).replace('T', ' ').replace('000Z', '');
                            sObj.put(field, Datetime.valueOf(datetimeStr));                    
                        }
                    }
                    else if(sfield.getDescribe().getType() == Schema.DisplayType.PERCENT){
                        if(mObj.get(field) != null){                            
                            sObj.put(field, (decimal)mObj.get(field)*100);                    
                        }
                    }
                    else if(sfield.getDescribe().getType() == Schema.DisplayType.PICKLIST){
                        Schema.DescribeFieldResult fieldDescribe = sfield.getDescribe();
                        List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
                        for(Schema.PicklistEntry entry : entries){
                            if(entry.getValue()==mObj.get(field)){
                                sObj.put(field, mObj.get(field)); 
                                break;
                            }
                        }
                    }
                    else{                        
                        sObj.put(field, mObj.get(field));                    
                    }                    
                }                    
            }
            
            sObjectsItems.add(sObj);
        }
        
        update sObjectsItems;
        return true;
    } 
    
    /**
     * Search Candiate for Lookup Field
     * */
    @AuraEnabled
	public static Object[] getLookupCandidates(String refObjName, String searchTerm) {
		String qname = '%' + searchTerm + '%';
		
		if(isSafeObject(refObjName) && isSafeField('Name', refObjName)){
	        return Database.query('Select Id,Name From ' + 
	        					  refObjName + 
	            				  ' Where Name Like :qname Limit 5');
		}
		
		return null;
	}
	
	private static boolean isSafeObject(String objName){
	    Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    SObjectType myObj = schemaMap.get(objName);
	    
	    return (myObj != null && myObj.getDescribe().isAccessible()); 
	}
	
	private static boolean isSafeField(String fieldName, String objName){
	    	Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    	SObjectType myObj = schemaMap.get(objName);
	    	
	        SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);
	        return (myField != null && myField.getDescribe().isAccessible());	    
	}	
    
    
    @AuraEnabled
    public static Boolean deleteRelatedRecord(Id objectId){
        Schema.SObjectType sobjectType = objectId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        
        if(isSafeObject(sobjectName)) {
            Database.DeleteResult result = Database.delete(objectId);            
            return result.isSuccess();
        }
        return False;
    }
    
    /**
    * Return the object details
    * */
    @AuraEnabled
    public static Object getObject(Id objectId)
    {            
        Object item = RestAPIUtils.getObject(objectId);
        if(item != null){        
            DescribeSObjectResult objectDescResult = objectId.getSobjectType().getDescribe();
            
        	Map<String, DescribeFieldResult> lookupFields = new Map<String,DescribeFieldResult>();            
            for(Schema.SObjectField sfield : objectDescResult.fields.getMap().Values()){ 
                DescribeFieldResult fieldDescResult = sfield.getDescribe();                
                if(fieldDescResult.getType()==Schema.DisplayType.REFERENCE){                        
                    lookupFields.put(fieldDescResult.getName(), fieldDescResult);
                }                                
            }   
			
            //Set the lookup labels based on the field type
            for(String fieldKey : lookupFields.keySet()){
                Set<Id> lookupIds = new Set<Id>();
                
                //Build the list of IDs
                Map<String, Object> mItem = (Map<String, Object>) item;
                if(mItem.containsKey(fieldKey)){
                    Id lookupId = (Id)mItem.get(fieldKey);
                    if(lookupId != null){
                        lookupIds.add(lookupId); 
                    }                        
                }
                
                               
                //Do SOQL query based on the ID list
                if(!lookupIds.isEmpty()){
                    SObject[] lookupObjs = getLookupObjects(lookupIds);                 
                    for(SObject lookupObj : lookupObjs){
                        try{                            	
                            mItem.put(fieldKey + '__Name', lookupObj.get('Name'));                                                                                        
                        }
                        catch(Exception e){
                            System.debug(e.getMessage());
                            mItem.put(fieldKey + '__Name', 'Undefined'); 
                        }                        
                    }
                }                                    
            }
            
            return item;                    
        }
                
        return null;
    } 
    
    /**
    * Create the object based on a json
    * */
    @AuraEnabled
    public static Id createRelatedObject(Id objectId,
                                         String objectName,
                                         String jsonData)
    {
        if(isSafeObject(objectName)){
            Map<String, Object> defaultValues = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        	SObjectType relatedObjectType =  Schema.getGlobalDescribe().get(objectName);    
            Schema.DescribeSobjectResult relatedDescribe = relatedObjectType.getDescribe();
            
        	SObject relatedObject = relatedObjectType.newSObject();
            
            //Update the fields from default values
            for(String field : relatedDescribe.fields.getMap().keySet()){                 
                if(defaultValues.containsKey(field)){    
                    Schema.SObjectField sfield = relatedDescribe.fields.getMap().get(field);
                    if(sfield.getDescribe().getType() == Schema.DisplayType.DATE){
                        String dateStr = ((String)defaultValues.get(field)) + ' 00:00:00';
                        relatedObject.put(field, Date.valueOf(dateStr));                                                
                    }                    
                    else if(sfield.getDescribe().getType() == Schema.DisplayType.DATETIME){
                        String datetimeStr = ((String)defaultValues.get(field)).replace('T', ' ').replace('000Z', '');
                        relatedObject.put(field, Datetime.valueOf(datetimeStr));                                            
                    }                                                            
                    else{
                        relatedObject.put(field, defaultValues.get(field));                    
                    }
                }                    
            }           
            
            insert relatedObject;            
            return relatedObject.Id;
        }
        
        return null;
    } 
}