/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Test Class  for JobApplicationTriggerHandler
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */

@IsTest
public with sharing class JobApplicationTriggerHandlerTest {

    /** 

        *below tests are related to the automated Task Creation on Job Application Status Change 

    */

    @IsTest
    static void shouldCreateSavedTasksAfterInsert() {

        Job_Application__c app = TestFactory.createJobApplication('Saved');

        Test.startTest();

        insert app;

        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, WhatId, OwnerId, Status, Priority, ActivityDate FROM Task WHERE WhatId = :app.Id];

        System.assertEquals(3,tasks.size(),'Inserting a Job Application with Status Saved should create 3 tasks.');

        Set<String> actualSubjects = new Set<String>();

        for (Task taskRecord : tasks) {

            actualSubjects.add(taskRecord.Subject);

            System.assertEquals('Normal',taskRecord.Priority,'Saved tasks should have Normal priority.');

            System.assertEquals(Date.today().addDays(2),taskRecord.ActivityDate,'Saved tasks should be due 2 days from today.');

        }

        System.assert(actualSubjects.contains('Check if the job description aligns with your interests and values'),

            'Missing expected Saved task subject.');

        System.assert(actualSubjects.contains('Review the highlighted skills to see if the role is a good fit'),

            'Missing expected Saved task subject.');

        System.assert(actualSubjects.contains('Research the company or role and mark your excitement level'),

            'Missing expected Saved task subject.');

    }



    @IsTest

    static void shouldNotCreateTasksWhenStatusIsBlank() {

        Job_Application__c app = TestFactory.createJobApplication(null);

        Test.startTest();

        insert app;

        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :app.Id];

        System.assertEquals(0,tasks.size(),'No tasks should be created when Status is blank.');

    }

   

    @IsTest

    static void shouldCreateApplyingTasksWhenStatusChanges() {

        Job_Application__c app = TestFactory.createJobApplication('Saved');

        insert app;

        app.Status__c = 'Applying';

        Test.startTest();

        update app;

        Test.stopTest();

        List<Task> applyingTasks = [SELECT Id, Subject, WhatId, Status, Priority, ActivityDate FROM Task WHERE WhatId = :app.Id AND Priority = 'High'];

        System.assertEquals(5,applyingTasks.size(),'Changing Status to Applying should create 5 High priority tasks.');

        Set<String> actualSubjects = new Set<String>();

        for (Task taskRecord : applyingTasks) {

            actualSubjects.add(taskRecord.Subject);

        }

        // since I checked the number of newly created tasks, I did not check all the added topics

        System.assert(actualSubjects.contains('Find and research someone who works at the company and add them as a contact'),

            'Missing expected Applying task subject.');

        System.assert(actualSubjects.contains('Submit your application on the company website if possible'),

            'Missing expected Applying task subject.');

    }


    @IsTest

    static void shouldNotCreateTasksWhenStatusDoesNotChange() {

        Job_Application__c app = TestFactory.createJobApplication('Saved');

        insert app;

        Integer taskCountBeforeUpdate = [SELECT COUNT() FROM Task WHERE WhatId = :app.Id];

        app.Name = 'Updated Test Job Application';

        Test.startTest();

        update app;

        Test.stopTest();

        Integer taskCountAfterUpdate = [SELECT COUNT() FROM Task WHERE WhatId = :app.Id];

        System.assertEquals(3,taskCountAfterUpdate,'No additional tasks should be created when Status does not change.');

    }

    /** 

        *below tests are related to linking Primary Contact to Job Application automatically 

    */

    @IsTest
    private static void shouldSetPrimaryContactFromAccountOnInsert(){
        
        Account testAccount = TestFactory.createAccount();

        Contact testContact = TestFactory.createContact(testAccount.Id);

        Job_Application__c app = TestFactory.createJobApplication(null);

        app.Company_Name__c=testAccount.Id;

        Test.startTest();

        insert app;

        Test.stopTest();

        Job_Application__c insertedApp = [SELECT Id, Primary_Contact__c, Company_Name__c FROM Job_Application__c WHERE Id = : app.Id];

        System.assertEquals(testContact.Id, insertedApp.Primary_Contact__c, 'Primary Contact should be set from the first Contact related to the Company Account.');


    }


    @IsTest
    private static void shouldSetPrimaryContactFromJobAppRelatedContactOnUpdate(){

        Account testAccount = TestFactory.createAccount();

        Contact testContact = TestFactory.createContact(testAccount.Id);

        Job_Application__c app = TestFactory.createJobApplication(null);

        insert testAccount;
        insert testContact;
        insert app;

        Job_Application_Contact__c jobAppRelatedContact = TestFactory.createJobAppRelatedContact (app.Id, testContact.Id);

        insert jobAppRelatedContact;

        app.Name = 'Updated Job App';

        Test.startTest();
        update app;
        Test.stopTest();

        Job_Application__c updatedapp =[SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id=: app.Id];

        System.assertEquals(testContact.Id, updatedapp.Primary_Contact__c,'Primary Contact should be set from the first Contact related through Job Application Contact.' );

    }


    //negative Testing:

    @IsTest 
    private static void shouldNotOverwriteExistingPrimaryContact(){

        Account testAccount = TestFactory.createAccount();
        insert testAccount;

        Contact testContact = TestFactory.createContact(testAccount.Id);
        insert testContact;

        Job_Application__c app = TestFactory.createJobApplication(null);
        app.Primary_Contact__c= testContact.Id;

        Test.startTest();

        insert app;

        Test.stopTest();


        Job_Application__c insertedApp = [SELECT Id, Primary_Contact__c, Company_Name__c FROM Job_Application__c WHERE Id = : app.Id];

        System.assertEquals(testContact.Id, insertedApp.Primary_Contact__c, 'Existing Primary Contact should not be overwritten.');


    }

    //negative Testing:

    @IsTest
    private static void shouldLeavePrimarycontactEmptyNoContact(){

        Account testAccount = TestFactory.createAccount();

        Job_Application__c app = TestFactory.createJobApplication(null);

        insert testAccount;

        Test.startTest();

        insert app;

        Test.stopTest();


        Job_Application__c insertedApp = [SELECT Id, Primary_Contact__c, Company_Name__c FROM Job_Application__c WHERE Id = : app.Id];

        System.assertEquals(null, insertedApp.Primary_Contact__c, 'Primary Contact should stay blank when no related Contact exists.');


    }


     /** 

        *below tests are related to automatic calculation of Estiomated fields on Job Application Records

    */


    @IsTest
    private static void shouldPopulatePaycheckFieldsOnInsert(){
        Job_Application__c app = TestFactory.createJobApplication(null);
        app.Salary__c=100000;

        Test.startTest();
        insert app;
        Test.stopTest();

        Job_Application__c insertedApp = [SELECT Id, Salary__c, Estimated_Federal_Taxes_Yearly__c,
        Estimated_Social_Security_Tax_Yearly__c,
        Estimated_Medicare_Withholding_Yearly__c,
        Estimated_Take_Home_Pay_Yearly__c,
        Estimated_Take_Home_Pay_Monthly__c 
        FROM Job_Application__c WHERE Id =: app.Id];

        System.assertEquals(13449.00, insertedApp.Estimated_Federal_Taxes_Yearly__c, 'Federal income tax should be calculated from the 2025 single filer tax brackets');
        
        System.assertEquals(6200.00, insertedApp.Estimated_Social_Security_Tax_Yearly__c, 'Social Security tax should be 6.2% of salary.');

        System.assertEquals(1450.00, insertedApp.Estimated_Medicare_Withholding_Yearly__c, 'Medicare withholding should be 1.45% of salary.');

        System.assertEquals(78901.00, insertedApp.Estimated_Take_Home_Pay_Yearly__c, 'Take-home yearly should equal salary minus federal tax, Social Security, and Medicare.');

        System.assertEquals(6575.08, insertedApp.Estimated_Take_Home_Pay_Monthly__c, 'Take-home monthly should equal yearly take-home divided by 12.');

    }



    @IsTest
    private static void shouldRecalculatePaycheckFieldsOnSalaryUpdate(){
        Job_Application__c app = TestFactory.createJobApplication(null);
        app.Salary__c=100000;
        insert app;

        app.Salary__c = 80000;

        Test.startTest();
        update app;
        Test.stopTest();

        Job_Application__c updatedApp = [SELECT Id, Salary__c, Estimated_Federal_Taxes_Yearly__c,
        Estimated_Social_Security_Tax_Yearly__c,
        Estimated_Medicare_Withholding_Yearly__c,
        Estimated_Take_Home_Pay_Yearly__c,
        Estimated_Take_Home_Pay_Monthly__c 
        FROM Job_Application__c WHERE Id =: app.Id];

        System.assertEquals(9049.00, updatedApp.Estimated_Federal_Taxes_Yearly__c, 'should have been recalculated.');
        
        System.assertEquals(4960.00, updatedApp.Estimated_Social_Security_Tax_Yearly__c, 'should have been recalculated.');

        System.assertEquals(1160.00, updatedApp.Estimated_Medicare_Withholding_Yearly__c, 'should have been recalculated.');

        System.assertEquals(64831.00, updatedApp.Estimated_Take_Home_Pay_Yearly__c, 'should have been recalculated.');

        System.assertEquals(5402.58, updatedApp.Estimated_Take_Home_Pay_Monthly__c, 'should have been recalculated.');

    }



    @IsTest
    private static void shouldPopulateZeroPaycheckValuesOnNullSalary(){
        Job_Application__c app = TestFactory.createJobApplication(null);
        app.Salary__c=null;

        Test.startTest();
        insert app;
        Test.stopTest();

        Job_Application__c insertedApp = [SELECT Id, Salary__c, Estimated_Federal_Taxes_Yearly__c,
        Estimated_Social_Security_Tax_Yearly__c,
        Estimated_Medicare_Withholding_Yearly__c,
        Estimated_Take_Home_Pay_Yearly__c,
        Estimated_Take_Home_Pay_Monthly__c 
        FROM Job_Application__c WHERE Id =: app.Id];

        System.assertEquals(0, insertedApp.Estimated_Federal_Taxes_Yearly__c);
        System.assertEquals(0, insertedApp.Estimated_Social_Security_Tax_Yearly__c);
        System.assertEquals(0, insertedApp.Estimated_Medicare_Withholding_Yearly__c);
        System.assertEquals(0, insertedApp.Estimated_Take_Home_Pay_Yearly__c);
        System.assertEquals(0, insertedApp.Estimated_Take_Home_Pay_Monthly__c);

    }


}