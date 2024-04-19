public class jamTestAct extends jam.Action {
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