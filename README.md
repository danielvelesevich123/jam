
## Utils
```apex
jam.objects.throwIfBlank(stringVar, 'stringVar is blank'); // allows keeping the liner code for code test coverage

jam.arrays.firstOrException([SELECT Id FROM Contact WHERE Email = 'test@test.com']); // return first element of list

Contact contactVar = new Contact(LastName = 'Doe', Email = 'doe@gmail.com');
jam.sObjects.deduplicate(contactVar); // tries to find the record based on Duplicate/Matching rules and populates the Id
jam.sObjects.upsertAsUser(contactVar); // upserts the record enforcing the CRUD/FLS

jam.utils.sObjects.getIdFieldValues(contacts, Contact.AccountId); // return set of Account Ids
```

## DTO
```apex
String jsonStr = '{"contact": {"Name": "John Doe", "Email": "test@test.com"}, "invoices": [{"Name": "Invoice 1", Start_Date__c": "2020-01-01"}, {"Name": "Invoice 2", Start_Date__c": "2021-01-01"}], "status": "Active"}';
jam.DTO dtoVar = new jam.DTO(jsonStr);
String status = dtoVar.getRequiredString('status');

Contact contactVar = dtoVar.getSObject('contact', Contact.SObjectType);
List<Invoice__c> invoices = dtoVar.getSObjects('invoices', Invoice__c.SObjectType);

jam.sObjects.deduplicate(contactVar);
jam.sObjects.upsertAsUser(contactVar);

for(Invoice__c invoice : invoices) {
    invoice.Contact__c = contactVar.Id;
}
jam.sObjects.upsertAsUser(invoices);
```

## Query Factory
```apex
Contact contactVar = jam.queryFactory(Contact.SobjectType)
    .selectFields(new Set<String>{'Id', 'Name', 'Email'})
    .setCondition('Name = :name', new Map<String, Object>{'name' => 'John Doe'}) 
    .setConditions(new List<String>{'Name = :name', 'Email != null'}, new Map<String, Object>{'name' => 'John Doe'})
    .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
    .queryFirstOrException('Unable to find Contact');
```

## Unit of Work
```apex
new jam.UnitOfWork(
    new List<SObjectType>{
        Contact.SObjectType,
        Invoice__c.SObjectType,
        Invoice_Line_Item__c.SObjectType
    })
    .registerUpsert(contactVar)
    .registerUpsert(invoiceVar)
    .registerNew(invoiceLiveVar1, Invoice_Line_Item__c.Invoice__c, invoice)
    .registerNew(invoiceLiveVar2, Invoice_Line_Item__c.Invoice__c, invoice)
    .commitWork();
```

## Sample Action
```apex
public with sharing class SampleAct extends jam.Action {
    public override void run() {
        //get any value from request
        String recordId = (String) this.get('value');

        //get string from request
        String anyString = this.getString('string');

        //get required string from request
        String anyRequiredString = this.getRequiredString('requiredString');
        //get required string from request with error message
        String anyRequiredStringWithMessage = this.getRequiredString('requiredStringWithMessage', 'required string is missing');

        //get integer from request
        Integer anyInteger = this.getInteger('integer');

        //get integer from request
        Decimal anyDecimal = this.getDecimal('decimal');

        //get integer from request
        Long anyLong = this.getLong('long');

        //get integer from request
        Boolean anyBoolean = this.getBoolean('boolean');

        //get integer from request
        Date anyDate = this.getDate('date');

        //get integer from request
        Time anyTime = this.getTime('time');

        //get datetime from request
        Datetime datetimeVar = this.getDatetime('datetime');

        //get strings from request
        List<String> strings = this.getStrings('strings');

        //get objects from request
        List<Object> objects = this.getObjects('objects');

        //get maps from request
        List<Map<String,Object>> maps = this.getMaps('maps');

        //get DTOs from request
        List<jam.DTO> DTOs = this.getDTOs('DTOs');

        //get SObjects from request
        List<SObject> sObjects = this.getSObjects('contacts', Contact.SObjectType);

        //initialize SObject from request
        Contact contactVar = (Contact) this.getSObject('contact', Contact.SObjectType);

        //initialize SObject records one by one from request
        Account accVar = new Account();
        Opportunity oppVar = new Opportunity();

        this.getSObject('account', accVar)
            .getSObject('opportunity', oppVar);

        contactVar.Email = 'test@test.com';

        Contact contactVar2 = (Contact) jam.arrays.firstOrException([SELECT Id, FirstName, LastName, Email FROM Contact LIMIT1]);
        List<Contact> contacts = new List<Contact>{contactVar, contactVar2};

        this
                .put('object', 2)
                .put('SObject', new Contact(LastName = '1'))
                .put('SObjectNotMappable', new Contact(LastName = '1'), false)
                .put('listObjects', new List<String>{
                        '123', '234'
                })
                .put('listObjectsWithLimit', new List<String>{
                        '123', '234'
                }, 1)
                .put('listSObjects', new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                })
                .put('listSObjectsNotMappable', new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                }, false)
                .put('listSObjectsWithLimit', new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                }, 1)
                .put('listSObjectsWithLimitNotMappable', new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                }, false, 1);

        this.put(new Map<String, Object>{
                'object' => 2,
                'listObjects' => new List<String>{
                        '123', '234'
                },
                'listSObjects' => new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                }
        });

        this.put(new Map<String, Object>{
                'object' => 2,
                'listObjectsWithLimit' => new List<String>{
                        '123', '234'
                },
                'listSObjectsWithLimit' => new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                }
        }, 1);

        this.put(new Map<String, Object>{
                'object' => 2,
                'listObjects' => new List<String>{
                        '123', '234'
                },
                'listSObjectsNotMappable' => new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                }
        }, false);

        this.put(new Map<String, Object>{
                'object' => 2,
                'listObjectsWithLimit' => new List<String>{
                        '123', '234'
                },
                'listSObjectsWithLimitNotMappable' => new List<Contact>{
                        new Contact(LastName = '1'), new Contact(LastName = '2')
                }
        }, false, 1);
    }
}
```