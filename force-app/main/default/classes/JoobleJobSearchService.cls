/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Jooble Job Service Integration
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 */

public with sharing class JoobleJobSearchService {

    private static final String API_KEY='9923fad8-ba4e-434d-8955-2c558800e352';

    public class JoobleRequest {
        public String keywords;
        public String location;
        public Integer page;
        public Integer resultOnPage;
        public Boolean companySearch;
    }

    public class JoobleResponse {
        public Integer totalCount;
        public List<JoobleJob> jobs;
    }

    public class JoobleJob {
        public String title;
        public String location;
        public String snippet;
        public String salary;
        public String source;
        public String type;
        public String link;
        public String company;
        public String updated;
    }

    public static void importSalesforceJobs(){
        JoobleRequest requestBody = new JoobleRequest();
        requestBody.keywords = 'Salesforce Developer';
        requestBody.location = 'Florida';
        requestBody.page = 1;
        requestBody.resultOnPage = 10;
        requestBody.companySearch = false;

        JoobleResponse joobleResponse = searchJobs(requestBody);

        if (joobleResponse == null || joobleResponse.jobs == null || joobleResponse.jobs.isEmpty()) {
            return;
        }

        List<Job_Application__c> applicationsToInsert = new List<Job_Application__c>();

        for (JoobleJob job : joobleResponse.jobs){
            Job_Application__c app = new Job_Application__c();

            app.Status__c ='Saved';
            app.Position__c =job.title;
            app.Name =job.title +' at '+ job.company;

            if (app.Name.length() > 80){
                app.Name= app.Name.substring (0,80);
            }
            
            app.Office_Location__c = job.location;
            app.Description__c =cleanJobDescription(job.snippet);
            app.URL__c = job.link;
            app.CompanyName__c =job.company;

            applicationsToInsert.add(app);
        }

        if (!applicationsToInsert.isEmpty()) {
            insert applicationsToInsert;
        }
    }


    private static JoobleResponse searchJobs (JoobleRequest requestBody){

        HttpRequest request = new HttpRequest();

        request.setEndpoint('https://jooble.org/api/'+ API_KEY);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(requestBody));
        request.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode()<200 || response.getStatusCode() >= 300) {
            throw new JoobleApiException ('Jooble API call failed. Status:' + response.getStatusCode() + '. Body:' + response.getBody());

        }

        return (JoobleResponse) JSON.deserialize(response.getBody(), JoobleResponse.class);
    
    }


    private static String cleanJobDescription (String rawDescription){
        if (String.isEmpty(rawDescription)){
            return null;
        }

        String cleanDescription = rawDescription;

        cleanDescription = cleanDescription.replace('&nbsp;', ' ');
        cleanDescription = cleanDescription.replace('&amp;', '&');
        cleanDescription = cleanDescription.replace('&lt;', '<');
        cleanDescription = cleanDescription.replace('&gt;', '>');
        cleanDescription = cleanDescription.replace('&quot;', '"');
        cleanDescription = cleanDescription.replace('&#39;', '\'');
        cleanDescription = cleanDescription.replaceAll('<[^>]*>', '');

        return cleanDescription;

    }


    public class JoobleApiException extends Exception {}




}
