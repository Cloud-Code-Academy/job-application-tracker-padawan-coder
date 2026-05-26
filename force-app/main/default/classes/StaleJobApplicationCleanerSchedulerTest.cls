/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Test Class for StaleJobApplicationCleanerScheduler Apex class
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
@IsTest
private class StaleJobApplicationCleanerSchedulerTest {

    @IsTest
    static void shouldCloseStaleJobApplications(){
        Job_Application__c staleApp = TestFactory.createJobApplication ('Applied');
        staleApp.Follow_up_Date__c = Date.today().addDays(-30);
        staleApp.Notes__c= 'Original note';

        insert staleApp;

        Test.startTest();
        StaleJobApplicationCleanerScheduler.closeStaleJobApplications();
        Test.stopTest();

        Job_Application__c updatedApp = [SELECT Id, Status__c, Follow_up_Date__c, Notes__c
                FROM Job_Application__c WHERE Id= :staleApp.Id];

        System.assertEquals('Closed', updatedApp.Status__c, 'Stale Job Application should be moved to closed.');

        System.assert(updatedApp.Notes__c.contains('Original note'),'Existing notes should be preserved.');

        System.assert(updatedApp.Notes__c.contains('Closed by automated process on'),'Notes should include the automated closure message');


    }


    @IsTest
    static void shouldNotCloseAcceptedJobApplications (){
        Job_Application__c acceptedApp = TestFactory.createJobApplication ('Accepted');
        acceptedApp.Follow_up_Date__c = Date.today().addDays(-40);

        insert acceptedApp;

        Test.startTest();
        StaleJobApplicationCleanerScheduler.closeStaleJobApplications();
        Test.stopTest();

        Job_Application__c updatedApp = [SELECT Id, Status__c, Follow_up_Date__c, Notes__c
                FROM Job_Application__c WHERE Id= :acceptedApp.Id];

        System.assertEquals('Accepted', updatedApp.Status__c, 'Accepted Job Applications should not be closed.');

    }


    @IsTest
    static void shouldNotCloseRecentJobApplications (){
        Job_Application__c recentApp = TestFactory.createJobApplication ('Applied');
        recentApp.Follow_up_Date__c = Date.today().addDays(-10);

        insert recentApp;

        Test.startTest();
        StaleJobApplicationCleanerScheduler.closeStaleJobApplications();
        Test.stopTest();

        Job_Application__c updatedApp = [SELECT Id, Status__c, Follow_up_Date__c, Notes__c
                FROM Job_Application__c WHERE Id= :recentApp.Id];

        System.assertEquals('Applied', updatedApp.Status__c, 'Recent Job Applications should not be closed.');

    }


    
}