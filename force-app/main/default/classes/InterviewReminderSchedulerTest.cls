/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Test Class  for InterviewReminderScheduler
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */

 @IsTest
public with sharing class InterviewReminderSchedulerTest {
    
    @IsTest
    static void shouldSendReminderEmailForTomorrowEvent(){

        Date tomorrow =Date.today().addDays(1);
        User reminderUser = createReminderUser();

        if (isWeekend (tomorrow)){
            System.assert(true, 'Skipping positive testing Reminder as tomorrow is weekend and event validations blocks the weekend events. ');
            return;
        }

        Event tomorrowEvent =TestFactory.createEvent('Salesforce Developer Interview', Datetime.newInstance (tomorrow,Time.newInstance(10,0,0,0)));
        tomorrowEvent.OwnerId= reminderUser.Id;

        insert tomorrowEvent;

        Test.startTest();

        Integer emailInvocationsBefore = Limits.getEmailInvocations();
        InterviewReminderScheduler.sendInterviewReminders();
        Integer emailInvocationsAfter = Limits.getEmailInvocations();

        Test.stopTest();

        System.assertEquals(emailInvocationsBefore + 1, emailInvocationsAfter, 'The scheduler should send one email invocation for tomorrow events');

    }


    @IsTest
    static void shouldNotSendReminderEmailForNotTomorrowEvent(){
        Event notTomorrowEvent =TestFactory.createEvent('Salesforce Developer Interview Not Tomorrow', DateTime.newInstance(2026,5,1,10,0,0));

        insert notTomorrowEvent;

        Test.startTest();

        InterviewReminderScheduler.sendInterviewReminders();
        Integer emailInvocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.assertEquals(0, emailInvocations, 'The scheduler should not send email reminders for events scheduled today');

    }


    private static Boolean isWeekend (Date dateToCheck){

        String dayOfWeek = Datetime.newInstance(dateToCheck,Time.newInstance(0, 0, 0, 0)).format ('E');

        return dayOfWeek == 'Sat'  || dayOfWeek == 'Sun';
    }


    private static User createReminderUser() {

        String uniqueValue = String.valueOf(Datetime.now().getTime());

        Profile testProfile= [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        User testUser = new User (
            FirstName='Interview', LastName='Reminder', Alias='irem', 
            Email= 'interview.reminder' + uniqueValue + '@example.com',
            Username='interview.reminder' + uniqueValue + '@example.com',
            TimeZoneSidKey = 'Europe/Berlin', LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',ProfileId = testProfile.Id

        );

        insert testUser;
        return testUser;
    }


}