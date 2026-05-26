/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    stops double-booking (scheduling two meetings simultaneously) or scheduling meetings on the weekend.
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
public with sharing class EventTriggerHandler extends TriggerHandler  {


    public override void beforeInsert(){
        List<Event> newEvents= (List<Event>) Trigger.new;
        validateEvents(newEvents,null);

    }

    Public override void beforeUpdate(){
        List<Event> newEvents= (List<Event>) Trigger.new;
        Map<Id,Event>oldEventMap = (Map<Id, Event>) Trigger.oldMap;
        validateEvents(newEvents,oldEventMap);

    }


    // helper methods for validating the Events

    private static void validateEvents(List<Event> events, Map<Id,Event> oldEventMap){

        preventWeekendEvents (events);
        preventSameStartDateTimeDoubleBooking(events, oldEventMap);
    }


    private static void preventWeekendEvents (List<Event> events){

        for (Event eventRecord : events){
            if (eventRecord.StartDateTime ==null){
                continue;
            }

            Date eventDate = eventRecord.StartDateTime.date();

            String dayOfWeek =DateTime.newInstance(eventDate, Time.newInstance(0, 0, 0, 0)).format('E');

            if (dayOfWeek == 'Sat' || dayOfWeek == 'Sun'){
                eventRecord.addError ('Interview meetings cannot be scheduled on the weekend.');
            }


        }
    }

    private static void preventSameStartDateTimeDoubleBooking(List<Event> events, Map<Id, Event> oldEventMap){

        Set<Datetime> startDateTimesToCheck = new Set<Datetime>();
        
        //in case we are updating the events, the Ids are stored below so we do not compare them to themselves
        Set<Id> eventIdsToIgnore = new Set<Id>();

        for (Event eventRecord : events){
            if (eventRecord.StartDateTime == null){
                continue;
            }

            Boolean shouldCheck = false;
            if (oldEventMap == null){
                shouldCheck = true;
            } else { 
                
                Event oldEvent=oldEventMap.get(eventRecord.Id);
                if (eventRecord.StartDateTime != oldEvent.StartDateTime) {
                    shouldCheck=true;
                }
            }

            if (shouldCheck){
                startDateTimesToCheck.add(eventRecord.StartDateTime);
            }

            if (eventRecord.Id != null){
                eventIdsToIgnore.add(eventRecord.Id);
            }
        }

        if (startDateTimesToCheck.isEmpty()){
            return;
        }

        Map <DateTime, Event> startTimeToExistingEvent = new Map<Datetime, Event> ();

        for (Event existingevent : [SELECT Id,StartDateTime FROM Event WHERE StartDateTime IN: startDateTimesToCheck AND Id NOT IN :eventIdsToIgnore]) {
            startTimeToExistingEvent.put(existingevent.StartDateTime, existingevent);
        }

        for (Event eventRecord : events){
            if (eventRecord.StartDateTime != null && startTimeToExistingEvent.containsKey (eventRecord.StartDateTime)){
                eventRecord.addError ('Another meeting with the same start time has been scheduled.');
            }
        }
    }

}