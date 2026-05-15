/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Test Class  for JobApplicationTriggerHandler
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */

@IsTest
public with sharing class JobApplicationTriggerHandlerTest {

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

}