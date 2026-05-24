/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    sends an email reminder the day before an interview is scheduled.
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
public with sharing class InterviewReminderScheduler implements Schedulable {

    public void execute (SchedulableContext context) {
        sendInterviewReminders();
    }

    public static void sendInterviewReminders(){

        Date tomorrow = Date.today().addDays(1);

        Datetime startOfTomorrow = Datetime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
        Datetime endOfTomorrow = Datetime.newInstance(tomorrow.addDays(1), Time.newInstance(0, 0, 0, 0));


        List<Event> tomorrowEvents = [SELECT Id, Subject, startDateTime,EndDateTime, Description, OwnerId, Owner.Email, Owner.Name
        FROM Event WHERE StartDateTime >= :startOfTomorrow AND startDateTime < :endOfTomorrow 
        AND (Subject LIKE '%Call%' OR Subject LIKE '%Meeting%' OR Subject LIKE '%Interview%')];

        if (tomorrowEvents.isEmpty()){
            return;
        }

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage> ();

        for (Event interviewEvent : tomorrowEvents) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            if (interviewEvent.Owner == null || String.isBlank(interviewEvent.Owner.Email)) {
                continue;            
            }

            email.setToAddresses(new List<String> {interviewEvent.Owner.Email});

            email.setSubject('Interview reminder:' + interviewEvent.Subject);

            email.setPlainTextBody(buildEmailBody(interviewEvent));

            emailsToSend.add(email);
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }

    }

    private static String buildEmailBody(Event interviewEvent){

        String body ='';

        body += 'Hi' + interviewEvent.Owner.Name + ',\n\n';
        body += 'This is a reminder that you have an interview scheduled tomorrow.\n\n';
        body += 'Interview details:\n';
        body += 'Subject: ' + interviewEvent.Subject + '\n';
        body += 'Start: ' + String.valueOf(interviewEvent.StartDateTime) + '\n';
        body += 'End: ' + String.valueOf(interviewEvent.EndDateTime) + '\n\n';
        body += 'Good Luck!';

        return body;
    }



}