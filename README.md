# LedgerName
Have a trigger on Ledger Entry that will populate a field on the LE called 'EF GL Code' with data from opportunity, allocation or payment dependind on the type of LE

Trigger works as expected, but  having trouble getting the test class to work.

Issues running into

-Payment autocreation occurs, but allocation autocreation does not occur

-Have inserted npsp__Allocation_Settings__c with the apropriate settings to enable allocation creation, but I assume I am missing some sort of addiitonal setting?

-Allocation autocreation doesn't necessarily need to work, as I can insert my own allocations, but when I do this, the Ledger Creation does not work still.

-The code I received to call the ledger creation works when I run a seealldata test, but I cannot get it to run in a standard test

-I assume I need to set Accounting Subledger settings to enable the creation of ledger entries, but in doing that I also need to have allocation creation working correctly I think?
