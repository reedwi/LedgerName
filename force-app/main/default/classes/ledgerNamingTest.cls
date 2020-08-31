@isTest
public with sharing class ledgerNamingTest {
    @isTest
    public  static void ledgerNamingTest() {
        //create and insert a GAU that will be used as Default GAU for default allocations
        npsp__General_Accounting_Unit__c defaultGau = new npsp__General_Accounting_Unit__c(Name='20020-EFA0000000000', GAU_Upload_Name__c='20020-EFA0000000000', Type__c='Revenue', npsp__Active__c=true);
        insert defaultGau;

        //create and insert allocation settings that should allow auto allocation to be enabled
        npsp__Allocations_Settings__c sett = new npsp__Allocations_Settings__c(
            npsp__Default_Allocations_Enabled__c = true,
            npsp__Default__c = defaultGau.Id,
            npsp__Excluded_Opp_RecTypes__c = null,
            npsp__Excluded_Opp_Types__c = null,
            npsp__Payment_Allocations_Enabled__c = true,
            npsp__Rollup_N_Day_Value__c = 365,
            npsp__Use_Fiscal_Year_for_Rollups__c = true
        );
        insert sett;


        //create and insert account
        List<Account> aList = new List<Account>{
            new Account (Name = 'Test Account')
        };
        insert aList;

        //create and insert accounting chapters
        List<Chapter__c> chapList = new List<Chapter__c>{
            new Chapter__c(
                Name = 'WDC',
                Active__c = TRUE,
                Chapter_Code__c = 'WDC'
            ),
            new Chapter__c(
                Name = 'WV1',
                Active__c = TRUE,
                Chapter_Code__c = 'WV1'
            )
        };
        insert chapList;

        //create and insert accounting departments
        List<Accounting_Department__c> deptList = new List<Accounting_Department__c>{
            new Accounting_Department__c(
                Name = '943 - Individual Giving',
                Active__c = TRUE,
                Department_Code__c = '943'
            ),
            new Accounting_Department__c(
                Name = '620 - Programs',
                Active__c = TRUE,
                Department_Code__c = '620'
            )
        };
        insert deptList;

        //create and insert accounting projects
        List<Accounting_Project__c> projList = new List<Accounting_Project__c>{
            new Accounting_Project__c(
                Name = '084 - TSU',
                Active__c = TRUE,
                Project_Code__c = '084'
            ),
            new Accounting_Project__c(
                Name = '004 - Skill Building',
                Active__c = TRUE,
                Project_Code__c = '004'
            )
        };
        insert projList;

        //create and insert GAUs
        List<npsp__General_Accounting_Unit__c> gauList = new List<npsp__General_Accounting_Unit__c>{
            new npsp__General_Accounting_Unit__c(
                Name = '10410-EFA0000000000',
                npsp__Active__c = TRUE,
                Account_Number__c = '10410',
                Type__c = 'Cash',
                GAU_Upload_Name__c = '10410-EFA0000000000'
            ),
            new npsp__General_Accounting_Unit__c(
                Name = '40130 - Online giving',
                npsp__Active__c = TRUE,
                Account_Number__c = '40130',
                Type__c = 'Revenue',
                GAU_Upload_Name__c = '40130 - Online giving'
            )
        };

        insert gauList;

        //create and insert opportunities
        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test Donation 1',
                RecordTypeId = '0126g0000019Jw5AAE',
                CloseDate = System.today(),
                AccountId = aList[0].id,
                StageName = 'Pledged',
                Amount = 1000,
                Chapter__c = chapList[0].id,
                Department__c = deptList[0].id,
                Project__c = projList[0].id,
                Default_Debit_Account__c = gauList[0].id            
            ),

            new Opportunity(
                Name = 'Test Donation 2',
                RecordTypeId = '0126g0000019Jw5AAE',
                CloseDate = System.today(),
                AccountId = aList[0].id,
                StageName = 'Posted',
                Amount = 2000,
                Chapter__c = chapList[1].id,
                Department__c = deptList[1].id,
                Project__c = projList[1].id,
                Default_Debit_Account__c = gauList[0].id           
            )
        };

        insert oppList;

        //Sleep for 3 seconds
        Long startingTime3 = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds3 = 3000; // three-second delay
        while (System.now().getTime() - startingTime3 < delayInMilliseconds3)  {
            // Do nothing until desired delay has passed
        }

        //begin test
        test.startTest();

        //call subledger to run and create ledger entries
        Callable subledgerAPI = (Callable) Type.forName('abacus', 'LEDG_CallableAPI').newInstance();
        Map<String, Object> subledgerAPIParams = new Map<String, Object>();
        Boolean result = (Boolean) subledgerAPI.call('ledg.dispatchaccountingjob', subledgerAPIParams);

        test.stopTest();

        //lists to check to see if records were created and inserted
        List<Opportunity> oppIds = [SELECT id, Department__c FROM Opportunity];
        List<abacus__Ledger_Entry__c> ledgList = [SELECT abacus__Opportunity__c, id FROM abacus__Ledger_Entry__c];
        List<npsp__Allocation__c> alloListIds = [SELECT npsp__Opportunity__c FROM npsp__Allocation__c];
        List<Accounting_Project__c> projs = [SELECT Name FROM Accounting_Project__c];
        List<Accounting_Department__c> depts = [SELECT Name FROM Accounting_Department__c];    
        List<Chapter__c> chaps = [SELECT Name FROM Chapter__c];
        List<npe01__OppPayment__c> payListIds = [SELECT npe01__Opportunity__c, Chapter__c, Department__c, Debit_Account__c  FROM npe01__OppPayment__c];
        List<npsp__Allocations_Settings__c> pass = [SELECT npsp__Default_Allocations_Enabled__c, npsp__Default__c, npsp__Payment_Allocations_Enabled__c, npsp__Rollup_N_Day_Value__c, npsp__Excluded_Opp_RecTypes__c, npsp__Excluded_Opp_Types__c, npsp__Use_Fiscal_Year_for_Rollups__c FROM npsp__Allocations_Settings__c];

        system.debug(pass);
        system.debug(alloListIds); //empty
        system.debug(projs);
        system.debug(depts);
        system.debug(chaps);
        system.debug(ledgList); //empty
        system.debug(oppIds);
        system.debug(payListIds);

        //Queries for the debit and credit allocation pledges
        abacus__Ledger_Entry__c newledgdebit = [SELECT abacus__GL_Code__c, EF_GL_Code__c, abacus__Type__c, abacus__Debit_Credit__c, abacus__Opportunity__c FROM abacus__Ledger_Entry__c WHERE abacus__Opportunity__c IN :oppList AND (abacus__Type__c =: 'Allocation' AND abacus__Debit_Credit__c =: 'Debit') LIMIT 1];
        abacus__Ledger_Entry__c newledgcredit = [SELECT abacus__GL_Code__c, EF_GL_Code__c, abacus__General_Accounting_Unit__c, abacus__Opportunity__c FROM abacus__Ledger_Entry__c WHERE abacus__Opportunity__c IN :oppList AND (abacus__Type__c =: 'Allocation' AND abacus__Debit_Credit__c =: 'Credit') LIMIT 1];
        npsp__Allocation__c newallocation = [SELECT GAU_Account_Structure__c, npsp__Opportunity__c, npsp__General_Accounting_Unit__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c  =: oppList[0].id LIMIT 1];

        //Queries for debit and credit direct payment
        abacus__Ledger_Entry__c paymentledgdebit = [SELECT abacus__Opportunity__c, EF_GL_Code__c, Payment_Debit_Account_GL__c,  Payment_Debit_Account_GL__r.Name  FROM abacus__Ledger_Entry__c WHERE abacus__Opportunity__c IN :oppList AND (abacus__Fulfills_A_Pledge__c =: FALSE AND abacus__Type__c =: 'Payment' AND abacus__Debit_Credit__c =: 'Debit') LIMIT 1];
        abacus__Ledger_Entry__c paymentledgcredit = [SELECT abacus__Opportunity__c, EF_GL_Code__c, Payment_Debit_Account_GL__c,  Payment_Debit_Account_GL__r.Name  FROM abacus__Ledger_Entry__c WHERE abacus__Opportunity__c IN :oppList AND (abacus__Fulfills_A_Pledge__c =: FALSE AND abacus__Type__c =: 'Payment' AND abacus__Debit_Credit__c =: 'Debit') LIMIT 1];
        npsp__Allocation__c paymentallo = [SELECT Name, GAU_Account_Structure__c, npsp__Payment__c, npsp__General_Accounting_Unit__c, npsp__Payment__r.npe01__Opportunity__c FROM npsp__Allocation__c WHERE npsp__Payment__r.npe01__Opportunity__c IN :oppList AND npsp__Payment__c != NULL LIMIT 1];

        //Assertions for pledges
        System.assertEquals(newledgdebit.EF_GL_Code__c, newledgdebit.abacus__GL_Code__c);
        System.assertEquals(newledgcredit.EF_GL_Code__c, newallocation.GAU_Account_Structure__c);

        //Assertions for payments
        System.assertEquals(paymentledgdebit.EF_GL_Code__c, paymentledgdebit.Payment_Debit_Account_GL__r.Name);
        System.assertEquals(paymentledgcredit.EF_GL_Code__c, paymentallo.GAU_Account_Structure__c);
    } 
}

