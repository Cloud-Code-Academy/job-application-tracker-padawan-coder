/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    This Class complete the calculatrions regarding the tax and other deductions from Salary.
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
public with sharing class PaycheckTaxCalculations {

    public static final Integer taxYearToUse = 2025;
    public class PaycheckResult {
        @AuraEnabled
        public Integer taxYearUsed;

        @AuraEnabled
        public Decimal federalIncomeTaxYearly;

        @AuraEnabled
        public Decimal socialSecurityTaxYearly;

        @AuraEnabled
        public Decimal medicareWithholdingYearly;

        @AuraEnabled
        public Decimal takeHomePayYearly;

        @AuraEnabled
        public Decimal takeHomePayMonthly;

    }

    public class TaxSettings {

        public Integer taxYear;
        public Decimal socialSecurityRate;
        public Decimal medicareRate;
        public Decimal standardDeductionSingle;

    }

    public static PaycheckResult calculatePaycheckEstimate (Decimal yearlySalary){

        PaycheckResult result = new PaycheckResult();
        result.taxYearUsed = taxYearToUse;

        if ( yearlySalary == null || yearlySalary <=0)  {

            result.federalIncomeTaxYearly=0;
            result.socialSecurityTaxYearly=0;
            result.medicareWithholdingYearly=0;
            result.takeHomePayYearly=0;
            result.takeHomePayMonthly=0;
            return result;

        }

        TaxSettings settings = getTaxSettingsForYear(taxYearToUse);

        Decimal taxableIncome = yearlySalary - settings.standardDeductionSingle;

        if (taxableIncome < 0) {
            taxableIncome = 0;
        }

        Decimal federalIncomeTax = calculateFederalIncomeTax (taxableIncome,taxYearToUse,'Single');
        
        result.taxYearUsed=taxYearToUse;
        result.federalIncomeTaxYearly=federalIncomeTax.setScale(2);
        result.socialSecurityTaxYearly= (yearlySalary * settings.socialSecurityRate).setScale(2);
        result.medicareWithholdingYearly=(yearlySalary * settings.medicareRate).setScale(2);
        result.takeHomePayYearly=(yearlySalary - result.federalIncomeTaxYearly - result.socialSecurityTaxYearly - result.medicareWithholdingYearly).setScale(2);
        result.takeHomePayMonthly=(result.takeHomePayYearly/12).setScale(2);

        return result;
    }

    private static TaxSettings getTaxSettingsForYear (Integer taxYear){

        TaxSettings settings = new TaxSettings();
        settings.taxYear=taxYear;

        for (Tax_Rate_Setting__mdt setting : [ SELECT Year__c, Rate_Type__c, Rate__c, Amount__c FROM Tax_Rate_Setting__mdt WHERE Year__c= : taxYear ]) {

            if (setting.Rate_Type__c == 'Social Security') {
                settings.socialSecurityRate = setting.Rate__c;

            } else if (setting.Rate_Type__c == 'Medicare Withholding') {
                settings.medicareRate = setting.Rate__c;

            } else if (setting.Rate_Type__c == 'Standard Deduction Single') {
                settings.standardDeductionSingle = setting.Amount__c;

            }

        }

        return settings;

    }


    private static Decimal calculateFederalIncomeTax (Decimal taxableIncome, Integer taxYear, String filingstatus){

        if (taxableIncome == null || taxableIncome <= 0) {
            return 0;
        }

        List<Federal_Tax_Bracket__mdt> brackets = [ SELECT Tax_Year__c, Filing_Status__c, Lower_Limit__c, Upper_Limit__c, Tax_Rate__c FROM Federal_Tax_Bracket__mdt WHERE Tax_Year__c = :taxYear AND Filing_Status__c=: filingstatus ORDER BY Lower_Limit__c ASC   ];

        Decimal totalTax=0;

        for (Federal_Tax_Bracket__mdt bracket : brackets) {

            Decimal lowerLimit = bracket.Lower_Limit__c;
            Decimal upperLimit = bracket.Upper_Limit__c;
            Decimal taxRate = bracket.Tax_Rate__c;

            if (taxableIncome <= lowerLimit) {
                continue;
            }
            
            Decimal taxableAmountinBracket;

            if (upperLimit == null || taxableIncome < upperLimit)  {
                taxableAmountinBracket = taxableIncome - lowerLimit;
            } else {
                taxableAmountinBracket=upperLimit-lowerLimit;
            }

            totalTax += taxableAmountinBracket * taxRate;
        }

        return totalTax.setScale(2);

    }



}