@isTest
public class RelatedListDataGridControllerTest {
    static private String getSessionId(){
    	return UserInfo.getSessionId();    
    }
    
 	static testMethod void testGetReleatedListsMetadata()
    {
		Test.startTest();                
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseGenerator());  
        Object[] relatedListsMatadata = RelatedListDataGridController.getReleatedListsMetadata('0010Y000003iFovQAE', getSessionId());
		System.assertEquals(true, relatedListsMatadata.size() > 0);                
        
        Test.stopTest();        
    }
    
    
    static testMethod void testGetReleatedListMetadata()
    {
        Test.startTest();       
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseGenerator());        		
             
        Object relatedListsMatadata = RelatedListDataGridController.getReleatedListMetadata('0010Y000003iFovQAE',
                                                                                            'Contacts',
                                                                                            getSessionId());
		System.assertEquals(true, relatedListsMatadata != null);        
        
        Test.stopTest();         
    }
    
    static testMethod void testGetReleatedListItems()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseGenerator());                              
        Object[] contacts = RelatedListDataGridController.getReleatedListItems('0010Y000003iFovQAE', 
                                                                               'Contacts',
                                                                               getSessionId());        
		System.assertEquals(true, contacts.size()>0);         
        
        Test.stopTest();
    } 
    
   
    static testMethod void testSaveRelatedListItems()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseGenerator());        
        
        Object[] contacts = RelatedListDataGridController.getReleatedListItems('0010Y000003iFovQAE', 
                                                                               'Contacts',
                                                                               getSessionId());                
		Account account = new Account();
        account.Name='Test Account' ;
        insert account;

        Contact contact = new Contact();
        contact.Accountid= account.id;
        contact.FirstName='Test';
        contact.LastName='Test';        
        insert contact;

        Map<String, Object> mContact = (Map<String, Object>)contacts.get(0);        
        mContact.put('AccountId', contact.AccountId);
        mContact.put('Id', contact.Id);        
        mContact.remove('OwnerId');
        
		Boolean result = RelatedListDataGridController.saveRelatedListItems(System.JSON.serialize(contacts), getSessionId());
        System.assertEquals(true, result);
        
        Object[] candidates = RelatedListDataGridController.getLookupCandidates('Account', 'Test', getSessionId());
        System.assertEquals(true, candidates.size() > 0);
        
        Test.stopTest();        
    }
    
    static Account createFakeAccount(){
        Account account = new Account();
        account.Name='Test Account' ;
        insert account;
        
        return account;
    }
    
    static testMethod void testGetObject()
    {
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseGenerator());                                
        Object jsonObj = RelatedListDataGridController.getObject('0019E000006nVr3QAE', getSessionId());        
        System.assertEquals(true, jsonObj != null);        
        
        Test.stopTest();            
    }
    
    static testMethod void testDelectObject()
    {
        Test.startTest();
        
        Contact ct = new Contact();
        ct.LastName = 'Hicham';
        ct.FirstName = 'El Mansouri';       
        insert ct;
        
        boolean result = RelatedListDataGridController.deleteRelatedRecord(ct.Id, getSessionId());
        System.assertEquals(true, result);
        
        Test.stopTest();
    }       
    
    static testMethod void testCreateRelatedObject()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestAPIMockHttpResponseGenerator()); 
        
        Account account = new Account();
        account.Name='Test Account' ;
        insert account;

        Map<String, String> data = new Map<String, String>();
        data.put('AccountId', account.id);
        data.put('lastname', 'Test');
        data.put('firstname', 'Test');        
                
        Id IdContact = RelatedListDataGridController.createRelatedObject(account.Id, 
                                                                         'Contact', 
                                                                         JSON.serialize(data),
                                                                         getSessionId());
        System.assertEquals(true, IdContact != null);
        
        Test.stopTest();
    }
}