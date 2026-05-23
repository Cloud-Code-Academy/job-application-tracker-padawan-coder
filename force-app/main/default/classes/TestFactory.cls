/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Creating test records for test classes
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */

 @IsTest
public without sharing class TestFactory {



    public static Job_Application__c createJobApplication(String statusValue) {

        return new Job_Application__c (
            Name = 'Test Application',
            Status__c = statusValue
        );
    }


    public static Account createAccount(){

        return new Account (
            Name='Test Account'
        );
    }

    public static Contact createContact(Id accountId){

       return new Contact (
        LastName = 'Recuiter',
        AccountId= accountId
       ) ;
    }

    public static Job_Application_Contact__c createJobAppRelatedContact (Id appId, Id contactId ){

        return new Job_Application_Contact__c (
            Job_Application__c= appId,
            contact__c=contactId

        );
    }

    public static Event createEvent  (String subject, DateTime startDateTime){

        return new Event (
            Subject= subject,
            startDateTime = startDateTime,
            EndDatetime = startDateTime.addHours(1)
        );
    }


}
