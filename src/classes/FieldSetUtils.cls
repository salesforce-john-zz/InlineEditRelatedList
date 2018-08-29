public class FieldSetUtils {
   private static IFieldSet mockFieldSet;
            
    /** 
    * Return a IFieldSet based on the given object name & fieldSet name
    **/
    public static IFieldSet getFieldSet(String objectName, String fielSetName)
    {
        if(Test.isRunningTest() && mockFieldSet!=null){
            return mockFieldSet;
        }
        else{
            SObjectType objectType =  Schema.getGlobalDescribe().get(objectName);    
            Schema.DescribeSobjectResult objectDescribe = objectType.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();                         
            Schema.FieldSet fieldSet = fieldSetMap.get(fielSetName);
            
            if(fieldSet != null){
                return new RtFieldSetImp(fieldSet);
            }
            
            return null;
        }                
    }
    
    /**
    * Provides a mock response to the 'construct' method during a test context
    **/
    @TestVisible
    private static void setMock(List<SObjectField> mockFields, String fieldSetName, String fieldSetLabel)
    {
        mockFieldSet = new TstFieldSetImp(mockFields, fieldSetName, fieldSetLabel);
    }       
    
    /** 
    * Interface to handle FieldSet
    **/
    public interface IFieldSet
    {
        String getName();
        String getLabel();
        
        List<IFieldSetMember> getFields();        
    }
    
    /** 
    * Interface to handle FieldSetMember
    **/
    public interface IFieldSetMember
    {
        String getFieldPath();        
    }
    
    public class RtFieldSetImp implements IFieldSet
    {        
		private Schema.FieldSet mFieldSet; 
        private List<IFieldSetMember> fields = new List<IFieldSetMember>();
        
        RtFieldSetImp(Schema.FieldSet fieldSet){
            this.mFieldSet = fieldSet;
            
            for(Schema.FieldSetMember member : fieldSet.getFields()){
                fields.add(new RtFieldSetMemberImp(member));
            }
        }
        
        public String getName(){
            return mFieldSet.getName();
        }
        
        public String getLabel(){
            return mFieldSet.getLabel();
        }
        
        public List<IFieldSetMember> getFields(){
            return fields;
        }
    }
    
    public class TstFieldSetImp implements IFieldSet
    {		
        private String mFieldSetName;
        private String mFieldSetLabel;        
        private List<IFieldSetMember> fields = new List<IFieldSetMember>();
        
        TstFieldSetImp(List<SObjectField> mockFields, String fieldSetName, String fieldSetLabel){
            this.mFieldSetName = fieldSetName;
            this.mFieldSetLabel = fieldSetLabel;
            
            for(SObjectField field : mockFields){
                fields.add(new TstFieldSetMemberImpl(field));
            }            
        }
        
        public String getName(){
            return mFieldSetName;
        }
        
        public String getLabel(){
            return mFieldSetLabel;
        }  
        
        public List<IFieldSetMember> getFields(){
            return fields;
        }
    }
    
    public class RtFieldSetMemberImp implements IFieldSetMember
    {
        private Schema.FieldSetMember mField; 
        
        RtFieldSetMemberImp(Schema.FieldSetMember field){
            this.mField = field;    
        }
                
        public String getFieldPath(){
            return mField.getFieldPath();
        }
    }
    
    public class TstFieldSetMemberImpl implements IFieldSetMember
    {
        private Schema.DescribeFieldResult mField; 
        
        TstFieldSetMemberImpl(Schema.SObjectField field){
            this.mField = field.getDescribe();    
        }
                
        public String getFieldPath(){
            return mField.getName();
        }            
    } 
}