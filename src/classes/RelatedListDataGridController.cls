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
    
    private static List<SObjectField> mockFieldSetMemberList;
    
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
            Map<String, DescribeFieldResult> percentFields = new Map<String,DescribeFieldResult>();    
            
            for(Schema.SObjectField sfield : objectDescResult.fields.getMap().Values()){ 
                DescribeFieldResult fieldDescResult = sfield.getDescribe();                
                if(fieldDescResult.getType()==Schema.DisplayType.REFERENCE){                        
                    lookupFields.put(fieldDescResult.getName(), fieldDescResult);
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
	
    /**
    * Check if the object is safe to use
    * */
	private static boolean isSafeObject(String objName){
	    Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    SObjectType myObj = schemaMap.get(objName);
	    
	    return (myObj != null && myObj.getDescribe().isAccessible()); 
	}
	
    /**
    * Check if the field is safe to use
    * */
	private static boolean isSafeField(String fieldName, String objName){
	    	Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    	SObjectType myObj = schemaMap.get(objName);
	    	
	        SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);
	        return (myField != null && myField.getDescribe().isAccessible());	    
	}	
    
    /**
    * Delete a related record
    * */
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
        
        List<String> queryFields = new List<String>();
        
        DescribeSObjectResult objectDescResult = objectId.getSobjectType().getDescribe();        
        Map<String, DescribeFieldResult> lookupFields = new Map<String,DescribeFieldResult>();            
        
        for(Schema.SObjectField sfield : objectDescResult.fields.getMap().Values()){ 
            DescribeFieldResult fieldDescResult = sfield.getDescribe(); 
            
            if(fieldDescResult.isAccessible()){
                queryFields.add(fieldDescResult.getName());                 
                if(fieldDescResult.getType()==Schema.DisplayType.REFERENCE){                        
                    lookupFields.put(fieldDescResult.getName(), fieldDescResult);
                }  
            }
        }
        
        String query = 'Select ' + String.join(queryFields, ', ') +
            ' From ' + String.valueOf(objectId.getSobjectType()) + 
        	' Where Id=\'' + objectId + '\'';
        
        System.debug(query);
        SObject item = Database.query(query); 
        
        if(item != null){            
            Map<String, Object> mItem = (Map<String, Object>)
                JSON.deserializeUntyped(JSON.serialize(item));
            
            
            //Set the lookup labels based on the field type
            for(String fieldKey : lookupFields.keySet()){
                Set<Id> lookupIds = new Set<Id>();
                
                //Build the list of IDs            
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
            
            return mItem; 
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
                Schema.DescribeFieldResult sfield = relatedDescribe.fields.getMap().get(field).getDescribe();   
                if(isSafeField(sfield.getName(), objectName)){
                    if(defaultValues.containsKey(field)){  
                        String defaultValue = (String)defaultValues.get(field);
                        
                        if(sfield.getType() == Schema.DisplayType.DATE){
                            String dateStr = defaultValue + ' 00:00:00';
                            relatedObject.put(field, Date.valueOf(dateStr));                                                
                        }                    
                        else if(sfield.getType() == Schema.DisplayType.DATETIME){
                            String datetimeStr = defaultValue.replace('T', ' ').replace('000Z', '');
                            relatedObject.put(field, Datetime.valueOf(datetimeStr));                                            
                        }
                        else if(sfield.getType() == Schema.DisplayType.REFERENCE &&
                                defaultValue.toUpperCase().startsWith('SELECT')){
                            System.debug('Set default value for ' + sfield.getName() + ' from ' + defaultValue);                                                                                    
                            List<SObject> results = Database.query(defaultValue);
                            if(results != null && results.size() > 0){
                                relatedObject.put(field, results[0].Id);
                            }                        
                        }     
                        else{
                            relatedObject.put(field, defaultValues.get(field));                    
                        }
                    }                    
                }
            }                
            
            insert relatedObject;            
            return relatedObject.Id;
        }
        
        return null;
    } 
    
    /**
    * Return the fieldSet based on the object name and the fieldSet name
    * */
    private static FieldSetUtils.IFieldSet getFieldSet(String objectName, 
                                                       String fielSetName)
    {
        if(isSafeObject(objectName)) { 
            return FieldSetUtils.getFieldSet(objectName, 
                                             fielSetName);
        }

		return null;        
    }        
    
    /**
    * Return the metadata of the fieldSet
    * */
    @AuraEnabled
    public static Object getFieldSetMetadata(String objectName, 
                                             String fielSetName)
    {
        Map<String, Object> mRelatedListMetadata = null;        
        FieldSetUtils.IFieldSet fieldSet = getFieldSet(objectName, fielSetName);
        
        if(fieldSet != null){
            mRelatedListMetadata = new Map<String, Object>();                
            //Set the name 
            mRelatedListMetadata.put('name', fieldSet.getName());                
            //Set the label
            mRelatedListMetadata.put('label', fieldSet.getLabel());                
            //Set the object name 
            mRelatedListMetadata.put('sobject', objectName);                
            
            //Set the columns 
            Map<String, Object> mColumns = new Map<String, Object>();
            mRelatedListMetadata.put('columns', getFieldSetColumns(objectName, fieldSet));  
        }       
        
        return mRelatedListMetadata;
    }  
    
    /**
    * Clean the fieldSet metadata
	* -If the field is AutoNumber or Calculated set the type to Formula. Otherwise set the type from the map
	* -If the column is not an inner field set the type to Reference
	* -If the field is not accessible remove the field from columns list  
	* */
    private static List<Object> getFieldSetColumns(String objectName, 
                                                   FieldSetUtils.IFieldSet fieldSet)
    {       
        List<Object> columnList = new List<Object>();
        List<FieldSetUtils.IFieldSetMember> fieldMemberList = fieldSet.getFields();  
        
        SObjectType relatedObjectType =  Schema.getGlobalDescribe().get(objectName);    
        Schema.DescribeSObjectResult objectDesc = relatedObjectType.getDescribe();        
        
        for(FieldSetUtils.IFieldSetMember fieldMember : fieldMemberList){ 
            String fieldName = fieldMember.getFieldPath();
            
            Schema.SObjectField sfield = objectDesc.fields.getMap().get(fieldName);            
            if(sfield != null){
                DescribeFieldResult fieldDescResult = sfield.getDescribe(); 
                
                if(fieldDescResult.isAccessible()){                    
                    Map<String, Object> mColumn = new Map<String, Object>();
                    
                    mColumn.put('name', fieldName);
                    mColumn.put('label', fieldDescResult.getLabel());
                    
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
                    
                    //Set type refObject for Lookup fields
                    if(mColumn.get('type') == 'Reference'){
                        mColumn.put('refObjName', String.ValueOf(fieldDescResult.getReferenceTo()[0]));                           
                    }  
                    
                    columnList.add(mColumn);
                }                           
            }
        }
        
        return columnList;
    }
    
    /**
    * Return the the fieldSet items
    * */
    @AuraEnabled
    public static Object[] getFieldSetItems(String objectName, 
                                            String fieldSetName,
                                            String filterBy,
                                            String sortBy,
                                            String orderBy)
    {            
        FieldSetUtils.IFieldSet fieldSet = getFieldSet(objectName, fieldSetName);
        
        if(fieldSet != null) {
            SObjectType relatedObjectType =  Schema.getGlobalDescribe().get(objectName);    
            Schema.DescribeSobjectResult relatedDescribe = relatedObjectType.getDescribe();
            
            String query = 'Select ';
            
            for(FieldSetUtils.IFieldSetMember fieldMember : fieldSet.getFields()) {
                String fieldName = fieldMember.getFieldPath();                                                            
                Schema.SObjectField sfield = relatedDescribe.fields.getMap().get(fieldName);
                
                if(sfield != null){
                    DescribeFieldResult fieldDescResult = sfield.getDescribe();                             
                    if(fieldDescResult.isAccessible()){
                        if(fieldDescResult.getType() == Schema.DisplayType.REFERENCE){
                            query += fieldName + ', ' + getLookupNamePath(fieldName) + ', '; 
                        }
                        else {
                            query += fieldName + ', '; 
                        }
                    }
                }                    
            }
            
            query += 'Id From ' + objectName;
            
            //Apply filter
            if(filterBy != null){
                Map<String, Object> filterMap = 
                    (Map<String, Object>)JSON.deserializeUntyped(filterBy);
                
                List<String> filterList = new List<String>();
                for(String field : filterMap.keySet()){
                    filterList.add(field + '=\'' +  filterMap.get(field) + '\'');
                }
                
                if(filterList.size()>0){
                    query += ' Where ' + String.join(filterList , ' And ');                    
                }
            }
            
            //Apply sort
            if(String.isNotBlank(sortBy)){
                query +=  ' Order By ' + sortBy; 
                //Apply order
                if(orderBy != null){
                    query +=  ' ' + orderBy; 
                }
            }              
            
            System.debug(query);
            
            return Database.query(query);                
        }
        
        return null;
    }     
    
    /**
    * Return the lookup field name	  
	* */
    static String getLookupNamePath(String fieldName)
    {
        return fieldName.endsWith('__c') ?
            fieldName.replace('__c', '__r.Name')  :
        fieldName.substring(0,fieldName.length()-2) + '.Name';
    }         
}