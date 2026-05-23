/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Test Class  for EventTriggerHandler
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */

 @IsTest
public with sharing class EventTriggerHandlerTest {
    
    @IsTest
    static void shouldAllowWeekdayEvents () {
        Event weekDayEvent = TestFactory.createEvent ('Weekday Interview', DateTime.newInstance(2026,5,26,10,0,0));

        Test.startTest();
        insert weekDayEvent;
        Test.stopTest();

        System.assertNotEquals(null, weekDayEvent.Id, 'Weekday Event should be inserted successfully.');

    }


    @IsTest
    static void shouldBlockWeekendEvents () {
        Event weekendEvent = TestFactory.createEvent ('Weekend Interview', DateTime.newInstance(2026,5,23,10,0,0));

        Test.startTest();
        
        try{
            insert weekendEvent;
            System.assert(false, 'Weekend Event should not be inserted');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Interview meetings cannot be scheduled on the weekend'), 'Expected Error Message');
        }
        
        Test.stopTest();

    }



    @IsTest
    static void shouldBlockEventWithSameStartDateTime () {
        DateTime sharedStartDateTime = DateTime.newInstance(2026, 5, 18, 10, 0, 0);

        Event firstEvent = TestFactory.createEvent ('First Interview', sharedStartDateTime);
        insert firstEvent;

        Event secondEvent = TestFactory.createEvent('Second Interview',sharedStartDateTime);


        Test.startTest();
        
        try{
            insert secondEvent;
            System.assert(false, 'Event should not be inserted with the same StartDateTime.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Another meeting with the same start time has been scheduled.'), 'Expected validation Error for Double Booking');
        }
        
        Test.stopTest();

    }

    
}