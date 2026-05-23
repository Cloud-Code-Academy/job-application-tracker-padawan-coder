/**
 * @author                 :    narjes.b@gmail.com
 * Description             :    This Controller makes the calculation in PaycheckTaxCalculations accessible to the takeHomePayCalculator (LWC)
 * Last modified by        :    narjes.b@gmail.com
 * last modified Date      :    May 2026
 * 
 */
public with sharing class TakeHomePayCalculatorController {

    @AuraEnabled
    public static PaycheckTaxCalculations.PaycheckResult calculateEstimate (Decimal salary) {

        return PaycheckTaxCalculations.calculatePaycheckEstimate(salary);

    }
}