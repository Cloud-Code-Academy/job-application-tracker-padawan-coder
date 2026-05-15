/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Job Application Trigger
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */

trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    new JobApplicationTriggerHandler().run();

}