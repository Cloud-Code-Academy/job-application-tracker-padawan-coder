/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    asynchronous process that checks if a job application is stale and moves the 
 *                              record status to closed. Update the notes field that the 
 *                              job application was closed by an automated process.
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
public with sharing class StaleJobApplicationCleanerScheduler implements Schedulable {
    public void execute (SchedulableContext context){
        closeStaleJobApplications ();
    }

    public static void closeStaleJobApplications (){
        Date staleFollowUpDate = Date.today().addDays(-30);

        List<Job_Application__c> staleApplications = 
        [SELECT Id, Status__c, Follow_up_Date__c, Notes__c FROM Job_Application__c 
        WHERE status__c NOT IN ('Closed', 'Accepted') AND Follow_up_Date__c <= :staleFollowUpDate ];

        if (staleApplications.isEmpty()){
            return;
        }

        for (Job_Application__c app : staleApplications){
            app.Status__c = 'Closed';

            String automatedNote ='Closed by automated process on' + String.valueOf(Date.today()) + '.';

            if (String.isBlank(app.Notes__c)){
                app.Notes__c = automatedNote;
            }else {
                app.Notes__c = app.Notes__c + '\n' + automatedNote;
            }
        }

        update staleApplications;

    }

}