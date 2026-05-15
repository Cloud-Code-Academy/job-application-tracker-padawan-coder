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

        Return new Job_Application__c (
            Name = 'Test Application',
            Status__c = statusValue
        );
}


}
