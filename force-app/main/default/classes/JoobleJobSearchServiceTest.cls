/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Test Class for JoobleJobSearchService
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */

 @IsTest
public with sharing class JoobleJobSearchServiceTest {

    public class JoobleSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();

            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');

            response.setBody('{"totalCount":1,"jobs":[' +
                        '{' + '"title":"Salesforce Developer TEST",' + '"location":"Florida",' +
                        '"snippet":"<b>Salesforce</b> Developer role &amp; admin tasks.",' +
                        '"salary":"100000",' +'"source":"Jooble",' +
                        '"type":"Full-time",' +
                        '"link":"https://example.com/job",' +
                        '"company":"Example Company",' +
                        '"updated":"2025-05-01T10:00:00"' +'}' + ']}');
            
            return response;
        }
    }


    @IsTest
    static void shouldCreateSavedJobApplicationFromJoobleResponse(){

        test.setMock(HttpCalloutMock.class, new JoobleSuccessMock());

        Test.startTest();
        JoobleJobSearchService.importSalesforceJobs();
        Test.stopTest();

        List<Job_Application__c> createdJobApplications = 
        [ SELECT Id, Name, Status__c, Position__c, Office_Location__c, Description__c, URL__c, CompanyName__c 
        FROM Job_Application__c WHERE Position__c ='Salesforce Developer TEST'];

        System.assertEquals(1, createdJobApplications.size(),'One Job Application should be created.');

        Job_Application__c app = createdJobApplications[0];

        System.assertEquals('Saved', app.Status__c);
        System.assertEquals('Salesforce Developer TEST', app.Position__c);
        System.assertEquals('Florida', app.Office_Location__c);
        System.assertEquals('Example Company', app.CompanyName__c);
        System.assertEquals('https://example.com/job', app.URL__c);


    }
    

}