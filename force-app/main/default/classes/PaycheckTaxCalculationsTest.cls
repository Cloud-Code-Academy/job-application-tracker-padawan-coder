/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    Test Class for the PaycheckTaxCalculations Class
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */


 // while writing test I noticed that calculating a year was not well defined, the below numbers will be meaningful for the year 2025 only!! nee
 @IsTest
private class PaycheckTaxCalculationsTest {
    @IsTest
    static void shouldCalculatePaycheckEstimatesForPositiveSalary (){
        Decimal yearlySalary = 100000;

        Test.startTest();
        PaycheckTaxCalculations.PaycheckResult result = PaycheckTaxCalculations.calculatePaycheckEstimate(yearlySalary);
        Test.stopTest();

        System.assertEquals(13449.00, result.federalIncomeTaxYearly, 'Federal income tax should be calculated from the 2025 single filer tax brackets');
        
        System.assertEquals(6200.00, result.socialSecurityTaxYearly, 'Social Security tax should be 6.2% of salary.');

        System.assertEquals(1450.00, result.medicareWithholdingYearly, 'Medicare withholding should be 1.45% of salary.');

        System.assertEquals(78901.00, result.takeHomePayYearly, 'Take-home yearly should equal salary minus federal tax, Social Security, and Medicare.');

        System.assertEquals(6575.08, result.takeHomePayMonthly, 'Take-home monthly should equal yearly take-home divided by 12.');

    }

    @IsTest
    static void shouldReturnZeroForNullSalary(){

        Test.startTest();
        PaycheckTaxCalculations.PaycheckResult result = PaycheckTaxCalculations.calculatePaycheckEstimate(null);
        Test.stopTest();

        System.assertEquals(0, result.federalIncomeTaxYearly);
        System.assertEquals(0, result.socialSecurityTaxYearly);
        System.assertEquals(0, result.medicareWithholdingYearly);
        System.assertEquals(0, result.takeHomePayYearly);
        System.assertEquals(0, result.takeHomePayMonthly);

    }


    @IsTest
    static void shouldReturnZeroForZeroSalary(){

        Test.startTest();
        PaycheckTaxCalculations.PaycheckResult result = PaycheckTaxCalculations.calculatePaycheckEstimate(0);
        Test.stopTest();

        System.assertEquals(0, result.federalIncomeTaxYearly);
        System.assertEquals(0, result.socialSecurityTaxYearly);
        System.assertEquals(0, result.medicareWithholdingYearly);
        System.assertEquals(0, result.takeHomePayYearly);
        System.assertEquals(0, result.takeHomePayMonthly);

    }

    @IsTest
    static void shouldReturnZeroFederalTaxforLowSalary(){

        Decimal yearlySalary = 10000;

        Test.startTest();
        PaycheckTaxCalculations.PaycheckResult result = PaycheckTaxCalculations.calculatePaycheckEstimate(yearlySalary);
        Test.stopTest();

        System.assertEquals(0, result.federalIncomeTaxYearly);
        System.assertEquals(620.00, result.socialSecurityTaxYearly);
        System.assertEquals(145.00, result.medicareWithholdingYearly);
        System.assertEquals(9235.00, result.takeHomePayYearly);

    }
}