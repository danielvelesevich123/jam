<a href="https://githubsfdeploy.herokuapp.com?owner=&repo=https://github.com/ReSourcePro/jam&ref=release-production default">
  <img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

<hr/>

# Salesforce Apex lightweight Framework


## Utils
```apex
jam.objects.throwIfBlank(stringVar, 'stringVar is blank'); // allows keeping the liner code for code test coverage

jam.arrays.firstOrException([SELECT Id FROM Contact WHERE Email = 'test@test.com']); // return first element of list

Contact contactVar = new Contact(LastName = 'Doe', Email = 'doe@gmail.com');
jam.sObjects.deduplicate(contactVar); // tries to find the record based on Duplicate/Matching rules and populates the Id
jam.sObjects.upsertAsUser(contactVar); // upserts the record enforcing the CRUD/FLS

jam.sObjects.getIdFieldValues(contacts, Contact.AccountId); // return set of Account Ids

jam.sObjects.setFieldsValues(invoices, new Map<SObjectField, Object>{
    Invoice__c.Status__c => 'Active',
    Invoice__c.Start_Date__c => Date.today()
}); // set fields values for list of sObjects
```

## DTO
#### DTO is a data transfer object that can be used to parse JSON or Map<String, Object> and get the values in a type-safe way. DTO is able to get/set the values of the nested objects and arrays.
```apex
String jsonStr = '{"contact": {"Name": "John Doe", "Email": "test@test.com"}, "invoices": [{"Name": "Invoice 1", Start_Date__c": "2020-01-01"}, {"Name": "Invoice 2", Start_Date__c": "2021-01-01"}], "status": "Active"}';
jam.DTO dtoVar = new jam.DTO(jsonStr);
String status = dtoVar.getRequiredString('status');

Contact contactVar = dtoVar.getSObject('contact', Contact.SObjectType);
List<Invoice__c> invoices = dtoVar.getSObjects('invoices', Invoice__c.SObjectType);

jam.sObjects.deduplicate(contactVar);
jam.sObjects.upsertAsUser(contactVar);

jam.sObjects.setFieldValue(invoices, Invoice.Contact__c, contactVar.Id);
jam.sObjects.upsertAsUser(invoices);
```

## Query Factory
```apex
Contact contactVar = jam.queryFactory(Contact.SobjectType)
    .selectFields(new Set<String>{'Id', 'Name', 'Email'})
    .setCondition('Name = :name', new Map<String, Object>{'name' => 'John Doe'}) 
    .setConditions(new List<String>{'Name = :name', 'Email != null'}, new Map<String, Object>{'name' => 'John Doe'})
    .addOrdering('Name', jam.SortOrder.ASCENDING)
    .queryFirstOrException('Unable to find Contact');
```

## Unit of Work
```apex
jam.uow(new List<SObjectType>{
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

## Actions
```apex
jam.Response responseVar = new SampleAction(new Map<String, Object>{
    'requiredString' => 'test'}
).run();

//OR JSON as an input

jam.Response responseVar = new SampleAction('{"requiredString":"test"}').run();

Contact contactVar = responseVar.getSObject('SObject', Contact.SObjectType);
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

## HTTP Mock
```apex
new jamTest.HttpMock()
    .add('PUT', 'https://test.com', 201, new Map<String, Object>{'test' => 'test'})
    .add('POST', 'https://test.com', 200, 'test response')
    .add('https://test.com', new Map<String, Object>{'test' => 'test'})
    .add('https://test.com', 'test response')
    .setMock();
```

## Cross-package Action execution and Mock for unit test
This allows to execute actions from one package to another package and mock the response for unit testing. Jam should be added in both packages. 
The calling Action MUST implement the jam.AllowsCallable interface.
```apex
// Assuming this code is in the namespace2
public with sharing class SampleAct extends jam.Action implements jam.AllowsCallable {
    public override void run() {
        String someValue = this.getRequiredString('someValue');
        this.put('returnedValue', 'Echo ' + someValue);
    }
}


// Assuming this code is called from namespace1 or unmanaged code
jam.Response response = jam.objects.runPackageAction('namespace2', 'SampleAct', new Map<String, Object>{
    'someValue' => 'test'
});
response.throwIfNotValid();

String str = response.getString('returnedValue'); // Echo test
```

Mock the response for unit test
```apex
jam.setPackageActionMock('namespace2', 'SampleAct', new Map<String, Object>{
    'id' => 'testId',
    'url' => 'testUrl'
});
```
