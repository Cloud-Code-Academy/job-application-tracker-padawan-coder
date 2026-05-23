public with sharing class TakeHomePayCalculatorController {

    @AuraEnabled
    public static PaycheckTaxCalculations.PaycheckResult calculateEstimate (Decimal salary) {

        return PaycheckTaxCalculations.calculatePaycheckEstimate(salary);

    }
}