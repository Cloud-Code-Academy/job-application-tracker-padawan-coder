import { LightningElement } from 'lwc';
import calculateEstimate from '@salesforce/apex/TakeHomePayCalculatorController.calculateEstimate';

export default class TakeHomePayCalculator extends LightningElement {
    salary=0;
    paycheckResult;
    errorMessage;

    handleSalaryChange (event) {
        this.salary = Number ( event.target.value);

        if (!this.salary || this.salary <=0) {
            this.paycheckResult= null;
            this.errorMessage= null;
            return;
        }

        this.calculatePaycheck();
    }

    
    calculatePaycheck (){

        calculateEstimate({salary: this.salary}) 
            .then((result) => {
            this.paycheckResult= result;
            });
    }



    get hasResult(){
        return this.paycheckResult  !== undefined && this.paycheckResult !== null;
    }

    get formattedsalary (){
        return this.formatCurrency(this.salary);
    }

    get formattedFederalTax(){
        return this.formatCurrency(this.paycheckResult.federalIncomeTaxYearly);
    }

    get formattedSocialSecurityTax(){
        return this.formatCurrency(this.paycheckResult.socialSecurityTaxYearly);
    }

    get formattedMedicareWithholding(){
        return this.formatCurrency(this.paycheckResult.medicareWithholdingYearly);
    }

    get formattedTakeHomeYearly(){
        return this.formatCurrency(this.paycheckResult.takeHomePayYearly);
    }

    get formattedTakeHomeSixMonths(){
        return this.formatCurrency(this.paycheckResult.takeHomePayYearly / 2);
    }

    get formattedTakeHomeMonthly(){
        return this.formatCurrency(this.paycheckResult.takeHomePayMonthly);
    }

    get formattedTakeHomeBiWeekly(){
        return this.formatCurrency(this.paycheckResult.takeHomePayYearly / 26);
    }

    formatCurrency(value) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2 ,
            maximumFractionDigits: 2
        }).format (value || 0);
    }

}