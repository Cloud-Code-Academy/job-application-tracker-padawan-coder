/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Event Trigger
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
trigger EventTrigger on Event (before insert, before update) {

    new EventTriggerHandler().run();

}