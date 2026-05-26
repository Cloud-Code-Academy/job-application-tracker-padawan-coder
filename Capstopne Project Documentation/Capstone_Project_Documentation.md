Job Application Tracker - Capstone Project 

1. Overview:

The Job Application Tracker is  designed to manage the full job application lifecycle in one place. The system stores job opportunities, tracks application status, creates follow-up tasks, manages interview events, calculates estimated take-home pay, sends reminders, closes stale applications, and imports Salesforce-related jobs from the Jooble API.


2. Main Requirements, Implemented solution, and Data Model:

-###  Job Application Object:
Custom Job_Application__c objet stores each job opportunity or application. It is the central object of the project with the key fields:

Status__c	Picklist
Company_Name__c	Account lookup
CompanyName__c	text
Position__c	Text
Application_Date__c	Date
Salary__c	Currency
URL__c	URL
Office_Location__c	Text
Location__c	"Picklist 
(Remote
On-siite
Hybrid)"
Follow_up_Date__c	Date
Rating__c"	Picklist (1 to 5)
Notes__c	Text
Primary_Contact__c	Lookup field to contact
Estimated_Federal_Taxes_Yearly__c	currency 
Estimated_Social_Security_Tax_Yearly__c	currency 
Estimated_Medicare_Withholding_Yearly__c	currency 
Estimated_Take_Home_Pay_Yearly__c	currency 
Estimated_Take_Home_Pay_Monthly__c	currency 

Job_Application_Record_Page1	flexipage

New App Job Application was created for users that are working with the Job Applications and all the permissions that are needed can be granted to the users by the permission set: Job_Application_Management_Access


-###  Activities: Standard Salesforce Tasks, Events and Emails were enabled for Job Application Records. 

-###  Multiple Contacts on Job Application Records:

A junction object: Job_Application_Contact__c (Master-Detail(Job Application)). This object associate many Contacts with one Job Application with the fields:
Contact__c	Lookup(Contact)
Role__c	"Picklist (Recruiter, Hiring Manager, Employee , Referral)
Notes__c	Long Text Area(32768)


-###  Application Status Automation:
Apex trigger creates task records when the application status is inserted or changed.

TriggerHandler	Apex Class
JobApplicationTriggerHandler	Apex Class
JobApplicationTrigger	Apex Trigger
JobApplicationTriggerHandlerTest	Apex Class

What happens and when:

Insert: create tasks if Status is populated.
Update: create tasks only when Status changes.
Blank Status: do not create tasks.

| Status      | Task Count | Priority | Due Date Logic |
|-------------|------------|----------|----------------|
| Saved       |     3      | Normal   | Today + 2 days |
| Applying    |     5      | High     | Today + 2 days |
| Applied     |     4      | High     | Today + 7 days |
| Interviewing|     5      | High     | Today + 1 day  |
| Negotiating |     3      | High     | Today + 2 days |
| Accepted    |     3      | Normal   | Today + 3 days |
| Closed      |     2      | Normal   | Today + 2 days |


**Assumption1: the Priority and Due date were not clarified in the requirements. 
**Assumption2 and potential point of improvement: if the user switch between the status, each time new tasks will be created and there will be duplications.

-###  Primary Contact Automation: 
Apex automation populates Primary Contact when blank using the first related contact or first company/account contact

TriggerHandler	Apex Class
JobApplicationTriggerHandler	Apex Class
JobApplicationTrigger	Apex Trigger
JobApplicationTriggerHandlerTest	Apex Class

If Primary_Contact__c is already populated:
    Do nothing.

If Primary_Contact__c is blank:
    First check contacts related through Job_Application_Contact__c.
    If none exists, check the first Contact related to the Company/Account.
    If no Contact exists, leave Primary Contact blank.

**Assumption and point of improvement: This automation runs on Job Application before insert/update. For records where a junction contact is added after the Job Application is created, the Job Application must be updated for this handler to run. A future enhancement could add a trigger on the junction object.


-###  Take-home Pay Estimation: 
Apex calculates estimated federal tax, Social Security, Medicare, yearly take-home pay, and monthly take-home pay.

TriggerHandler	Apex Class
JobApplicationTriggerHandler	Apex Class
JobApplicationTrigger	Apex Trigger
JobApplicationTriggerHandlerTest	Apex Class
PaycheckTaxCalculations 	Apex Class
PaycheckTaxCalculationsTest	Apex Class

and Custom Metadata Types to avoid hardcoding the values in Apex code and make the codes escalable. 

Tax_Rate_Setting__mdt with the fields:

Tax_Rate_Setting__mdt	Year__c	Number
Tax_Rate_Setting__mdt	Rate_Type__c	Picklist: (Social Security, Medicare Withholding)
Tax_Rate_Setting__mdt	Rate__c	Number
Tax_Rate_Setting__mdt	Amount__c	Number

Federal_Tax_Bracket__mdt with the fields:

Tax_Year__c 	Number
Filing_Status__c	"PickList: (Single; Married, filing jointly; Married, filing seperately; Head of the Household)
Lower_Limit__c	Number
Upper_Limit__c	Number
Tax_Rate__c	Number

**Assumption and point of improvement: The implementation currently uses a configured tax year 2025 in Apex.The rate and tax brackets are coming from custom metadata and only the values for the year 2025 are in the system. the Apex code in the future could have a helper method to calculate the year that suits the application. 

the formula for the calculations:

Taxable Income = Salary - Standard Deduction
Federal Income Tax = progressive tax calculated from metadata brackets
Social Security Tax = Salary × Social Security Rate
Medicare Withholding = Salary × Medicare Rate
Take Home Pay Yearly = Salary - Federal Income Tax - Social Security Tax - Medicare Withholding
Take Home Pay Monthly = Take Home Pay Yearly / 12

Example using Salary = 100,000 and 2025 metadata:
Value	               Result
-------------------------------
Federal Income Tax	  13,449.00
Social Security	      6,200.00
Medicare	          1,450.00
Take-home Yearly	  78,901.00
Take-home Monthly	  6,575.08




-### Take-home pay calculator: 
Lightning Web Component calculates take-home pay without saving the record.

takeHomePayCalculator	LWC
takeHomePayCalculatorController	Apex Class

User types salary in LWC.
LWC calls TakeHomePayCalculatorController.calculateEstimate().
Controller calls PaycheckTaxCalculations.calculatePaycheckEstimate().
LWC displays Federal Tax, Social Security, Medicare, Yearly Take-home, Six-Month Take-home, Monthly Take-home, and Bi-weekly Take-home.
No record save is required.




-###  Calendar Validation:
Apex validation on standard Event prevents weekend events and exact same-start-time double booking.

EventTriggerHandler	Apex Class
EventTrigger	Trigger
EventTriggerHandlerTest	Apex Class

Implemented version: Easy version.
Prevent weekend Events.
Prevent Events with the exact same StartDateTime as an existing Event.

**Assumption and point of improvements: This version checks exact same start time only. It does not check overlapping ranges such as:
10:00–11:00
10:30–11:30
A future enhancement could implement the hard version using start/end time overlap logic.


-###  Email Reminders:
Scheduled Apex sends interview reminder emails the day before scheduled interview events.
InterviewReminderScheduler	Apex Class
InterviewReminderSchedulerTest	Apex Class

**Assumtion: the scheduled interviews were identified by checking the subject containing thw words "Call", "Interview" and "Meeting" and it was set to run everyday at 8:00 am. 


-###  Stale Job Application Clean-up:
Create an asynchronous process that checks if a job application is stale (Follow-up Date is 30 days old or more) and the status is neither Closed or nor Accepted, and moves the status to Closed. Also update Notes to indicate that the record was closed by automation.

StaleJobApplicationCleanerScheduler	Apex Class
StaleJobApplicationCleanerSchedulerTest	Apex Class

**Assumtion: The Scheduled Job was set to run everyday at 7:00 am. 

-###  Job Integration:
Apex callout imports Salesforce-related jobs from Jooble and creates them as Saved Job Applications.

JoobleJobSearchService	Apex class
JoobleJobSearchServiceTest	Apex class

what happens:
Create a Jooble request body.
Search for Salesforce Developer jobs.
Deserialize Jooble response.
Create Job_Application__c records.
Set Status__c = Saved.
Map job title, company, location, description, and URL.
Clean HTML tags/entities from job description

**point of improvement: Apex callout service is run manually using Anonymous Apex and the searching criteria are hard coded. Also, The current implementation uses an API key for Jooble. A production improvement would be to avoid committing the real API key to GitHub public Repo.


3- Apex Test Coverage:

Apex tests were run by using Salesforce CLI:

sf apex run test --test-level RunLocalTests --code-coverage --result-format human --wait 10

and the results are:





=== Apex Code Coverage by Class
CLASSES                              PERCENT  UNCOVERED LINES        
───────────────────────────────────  ───────  ───────────────────────
JobApplicationTrigger                100%                            
TriggerHandler                       35%      18,19,28,29,30,...     
JobApplicationTriggerHandler         91%      139,141,143,145,147,...
PaycheckTaxCalculations              100%                            
EventTriggerHandler                  74%      17,18,19,20,38,...     
EventTrigger                         100%                            
InterviewReminderScheduler           90%      10,11,36               
StaleJobApplicationCleanerScheduler  81%      11,12,32               
JoobleJobSearchService               92%      48,61,92,103           




=== Test Summary
NAME                 VALUE                                   
───────────────────  ────────────────────────────────────────
Outcome              Passed                                  
Tests Ran            24                                      
Pass Rate            100%                                    
Fail Rate            0%                                      
Skip Rate            0%                                      
Test Run Id          707d200000qNhJG                         
Test Setup Time      0 ms                                    
Test Execution Time  3808 ms                                 
Test Total Time      3808 ms                                 
Org Id               00Dd200000iWOlpEAG                      
Username             narjes.dehkordi@mindful-moose-3qegai.com
Org Wide Coverage    84%                                     



