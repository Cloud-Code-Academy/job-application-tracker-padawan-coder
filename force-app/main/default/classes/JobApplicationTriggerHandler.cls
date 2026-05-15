 /**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Automated Task Creation for each Status update on Job Application Object
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
public with sharing class JobApplicationTriggerHandler extends TriggerHandler  {

    public override void afterInsert() {
        List<Job_Application__c> newApplications = (List<Job_Application__c>) Trigger.new;
        createStatusTasks(newApplications, null);

    }

    public override void afterUpdate() {

        List<Job_Application__c> updatedApplications = (List<Job_Application__c>) Trigger.new;

        Map<Id, Job_Application__c> oldApplicationMap = (Map<Id, Job_Application__c>) Trigger.oldMap;

        createStatusTasks(updatedApplications, oldApplicationMap);

    }


    // creating tasks for status change:

    private static void createStatusTasks(List<Job_Application__c> applications, Map<Id, Job_Application__c> oldApplicationMap) {


        List<Task> tasksToInsert = new List<Task>();

        for (Job_Application__c app : applications) {
            if (String.isBlank(app.Status__c)){
                continue;
            }

            Boolean shouldCreateTask= false;

            if (oldApplicationMap == null) {
            //after insert
            shouldCreateTask =true;

            } else {
                // after update
                Job_Application__c oldApp=oldApplicationMap.get(app.Id);
                if (app.Status__c != oldApp.Status__c) {
                    shouldCreateTask = true;
                }
            }

            if (shouldCreateTask) {
                List<String> taskSubjects = getTaskSubjectsForStatus(app.Status__c);
                for (String subj : taskSubjects) {

                    Task newTask = new Task();
    
                    newTask.Subject = subj;
    
                    newTask.WhatId = app.Id;
    
                    newTask.OwnerId = app.OwnerId;
    
                    newTask.Status = 'Not Started';
    
                    newTask.Priority = getPriorityForStatus(app.Status__c);
    
                    newTask.ActivityDate = getDueDateForStatus(app.Status__c);
    
                    tasksToInsert.add(newTask);
    
                }

            }
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }   

    }
    



    private static List<String> getTaskSubjectsForStatus (String applicationStatus) {

        List<String> taskSubjects =new List<String>();

        if (applicationStatus == 'Saved') {

            taskSubjects.add('Check if the job description aligns with your interests and values');

            taskSubjects.add('Review the highlighted skills to see if the role is a good fit');

            taskSubjects.add('Research the company or role and mark your excitement level');

        } else if (applicationStatus == 'Applying') {

            taskSubjects.add('Find and research someone who works at the company and add them as a contact');

            taskSubjects.add('Set up an informational interview to learn more about the role/company');

            taskSubjects.add('Identify potential referrals to help get your application on the top of the pile');

            taskSubjects.add('Customize your work achievements using the job description keywords');

            taskSubjects.add('Submit your application on the company website if possible');

        } else if (applicationStatus == 'Applied') {

            taskSubjects.add('Reach out to the hiring manager or recruiter');

            taskSubjects.add('Follow up on your application via email weekly');

            taskSubjects.add('Continue identifying and saving similar job opportunities');

            taskSubjects.add('Set up weekly networking calls to explore similar companies/roles');

        } else if (applicationStatus == 'Interviewing') {

            taskSubjects.add('Prepare your blurb or “tell me about yourself” response');

            taskSubjects.add('Practice answering behavioral interview questions');

            taskSubjects.add('Research the company and your interviewers');

            taskSubjects.add('Set up your virtual interview space and test your tech');

            taskSubjects.add('Send thank you emails within 24 hours');

        } else if (applicationStatus == 'Negotiating') {

            taskSubjects.add('Research your market value and know your numbers');

            taskSubjects.add('Prepare your negotiation scripts');

            taskSubjects.add('Evaluate your offer and decline or accept');

        } else if (applicationStatus == 'Accepted') {

            taskSubjects.add('Plan your resignation if applicable');

            taskSubjects.add('Take some time to relax and recharge');

            taskSubjects.add('Prepare for your first day of onboarding');

        } else if (applicationStatus == 'Closed') {

            taskSubjects.add('Send a follow-up email thanking the interviewer and asking for feedback');

            taskSubjects.add('Review your notes and reflect on areas of improvement');

        }

        return taskSubjects;
    }



    private static String getPriorityForStatus(String applicationStatus){
        if (

            applicationStatus == 'Applying' ||

            applicationStatus == 'Applied' ||

            applicationStatus == 'Interviewing' ||

            applicationStatus == 'Negotiating'

        ) {

            return 'High';

        }

        return 'Normal';
    }

    
    private static Date getDueDateForStatus (String applicationStatus){
       
        if (applicationStatus == 'Interviewing') {

            return Date.today().addDays(1);

        }

        if (applicationStatus == 'Applied') {

            return Date.today().addDays(7);

        }

        if (applicationStatus == 'Accepted') {

            return Date.today().addDays(3);

        }

        return Date.today().addDays(2);

    }
}  
