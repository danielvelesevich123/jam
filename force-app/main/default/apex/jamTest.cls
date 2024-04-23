@IsTest
public class jamTest {
    private static List<Contact> createAndReturnContacts(Integer numContacts) {
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            Contact ct = new Contact(
                    FirstName = 'Contact' + i,
                    LastName = 'Contact' + i
            );
            contacts.add(ct);
        }

        insert contacts;
        return contacts;
    }

    private static List<String> createStringList(Integer numParts) {

        List<String> stringList = new List<String>();
        for (Integer i = 0; i < numParts; i++) {
            stringList.add('test' + i);
        }
        return stringList;

    }

    private static Contact createContact(String lastname, String mailingCountry) {

        Contact testContact = new Contact(
                LastName = lastname,
                MailingCountry = mailingCountry
        );
        return testContact;
    }

    /**
     * ==============================================================================================================
     *                                      PICKLIST EXTENSIONS
     * ==============================================================================================================
     */

    @IsTest
    static void testGetPicklistValuesAsSelectOptions() {
        System.assertNotEquals(null, jam.picklists.getPicklistValuesAsSelectOptions(Account.Industry));
    }

    @IsTest
    static void testGetPicklistAsSetStrings() {
        System.assertNotEquals(null, jam.picklists.getPicklistAsSetStrings(Account.Industry));
        System.assertNotEquals(null, jam.picklists.getPicklistAsSetStrings(Account.Industry, new Set<String>{
                'test'
        }));
    }

    @IsTest
    static void testGetPicklistOptionsMap() {
        Set<SObjectField> fields = new Set<SObjectField>{
                Account.Industry, Account.AccountSource
        };
        System.assertNotEquals(null, jam.picklists.getPicklistOptionsMap(fields));
    }

    @IsTest
    static void testGetDependentPicklistOptionsMap() {
        Map<SObjectField, SObjectField> fieldsMap = new Map<SObjectField, SObjectField>{
                Account.AccountSource.getDescribe().getSobjectField() => Account.Industry.getDescribe().getSobjectField()
        };
        Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType = new Map<SObjectType, Map<SObjectField, SObjectField>>{
                Account.getSObjectType() => fieldsMap
        };
        System.assertNotEquals(null, jam.picklists.getDependentPicklistOptionsMap(dependentFieldsBySObjectType));
    }

    @IsTest
    static void testGetDependentOptions() {
        System.assert(jam.picklists.getDependentOptions(null, Account.ShippingAddress.getDescribe().getSobjectField(),
                Account.BillingAddress.getDescribe().getSobjectField()).isEmpty());
        System.assert(jam.picklists.getDependentOptions(Contact.getSObjectType(), Account.ShippingAddress.getDescribe().getSobjectField(),
                Account.BillingAddress.getDescribe().getSobjectField()).isEmpty());
    }

    @IsTest
    static void testConvertFlowPicklistFieldValues() {
        String industry = 'Consulting';
        Account accountVar = new Account(Industry = industry);
        jam.picklists.convertFlowPicklistFieldValues(accountVar);
        System.assertEquals(industry, accountVar.Industry);
    }


    /**
     * ==============================================================================================================
     *                                      DATE AND DATETIME EXTENSIONS
     * ==============================================================================================================
     */

    @IsTest
    static void testParseDatetimeAnyFormat() {
        Datetime dtVar = jam.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00', 'DD/MM/YYYY hh:mm:ss');
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 11, 0, 0), dtVar);

        dtVar = jam.dates.parseDatetimeAnyFormat('', 'DD/MM/YYYY hh:mm:ss');
        System.assertEquals(null, dtVar);

        dtVar = jam.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00 AM', 'DD/MM/YYYY hh:mm:ss AM');
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 11, 0, 0), dtVar);

        dtVar = jam.dates.parseDatetimeAnyFormat('2018-12-01 00:00:00', 'yyyy-MM-dd');
        System.assertEquals(Date.newInstance(2018, 12, 1), dtVar.date());

        Boolean didThrowException = false;
        try {
            dtVar = jam.dates.parseDatetimeAnyFormat('19-09 11 00 00 PA', 'DD/MM/YYYY hh:mm:ss PM');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
    }

    @IsTest
    static void testParseDatetimeAusFormat() {
        String dtStr = '19/09/2018 10:30 AM';
        Datetime dtVar = jam.dates.parseDatetimeAusFormat(dtStr);
        System.assertEquals(dtStr, dtVar.format('dd/MM/yyyy hh:mm a'));
    }

    @IsTest
    static void testParseDateAusFormat() {
        Date dateVar = jam.dates.parseDateAusFormat('19/09/2018');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);
    }

    @IsTest
    static void testDatetimeToDate() {
        Datetime dtVar = Datetime.newInstance(2018, 9, 19, 10, 30, 0);
        Date dateVar = jam.dates.datetimeToDate(dtVar);
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);
    }

    @IsTest
    static void testParseDateAnyFormat() {

        Date dateVar = jam.dates.parseDateAnyFormat('19/09/2018', 'DD/MM/YYYY');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

        dateVar = jam.dates.parseDateAnyFormat('', 'DD/MM/YYYY');
        System.assertEquals(null, dateVar);

        dateVar = jam.dates.parseDateAnyFormat('19/09/18', 'DD/MM/YY');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

    }

    @IsTest
    static void testDateToDateTime() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Datetime dtVar = jam.dates.dateToDateTime(dateVar);
        System.assertEquals(Datetime.newInstance(2018, 9, 19), dtVar);

    }

    @IsTest
    static void testTotalWorkingDays() {

        Date startDate = Date.newInstance(2018, 9, 19);
        Date endDate = Date.newInstance(2018, 9, 24);
        Integer total = jam.dates.totalWorkingDays(startDate, endDate);
        System.assertEquals(4, total);
    }

    @IsTest
    static void testIsWorkingDay() {

// for date parameter
        Date dateVar = Date.newInstance(2018, 9, 19);
        Boolean isWorkingDay = jam.dates.isWorkingDay(dateVar);
        System.assertEquals(true, isWorkingDay);

// for datetime parameter
        Datetime dtVar = Datetime.newInstance(2018, 9, 19);
        isWorkingDay = jam.dates.isWorkingDay(dtVar);
        System.assertEquals(true, isWorkingDay);
    }

    @IsTest
    static void testTimeStringToTime() {

        Time timeVar = jam.dates.timeStringToTime('11:30:00');
        System.assertEquals(Time.newInstance(11, 30, 0, 0), timeVar);
    }

    @IsTest
    static void testTimeStringAMPMToTime() {

        Time timeVarAM1 = jam.dates.timeStringAMPMToTime('11:30:00 AM');
        System.assertEquals(Time.newInstance(11, 30, 0, 0), timeVarAM1);

        Time timeVarAM2 = jam.dates.timeStringAMPMToTime('12:30:00 AM');
        System.assertEquals(Time.newInstance(0, 30, 0, 0), timeVarAM2);

        Time timeVarPM1 = jam.dates.timeStringAMPMToTime('11:30:00 PM');
        System.assertEquals(Time.newInstance(23, 30, 0, 0), timeVarPM1);

        Time timeVarPM2 = jam.dates.timeStringAMPMToTime('12:30:00 PM');
        System.assertEquals(Time.newInstance(12, 30, 0, 0), timeVarPM2);

        Boolean didThrownException = false;
        try {
            jam.dates.timeStringAMPMToTime('');
        } catch (Exception ex) {
            didThrownException = true;
            System.assert(didThrownException);
        }

    }

    @IsTest
    static void testGetStartOfDay() {

        Datetime dtVar = jam.dates.getStartOfDay(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 0, 0, 0), dtVar);

    }

    @IsTest
    static void testGetEndOfDay() {

        Datetime dtVar = jam.dates.getEndOfDay(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 23, 59, 9), dtVar);

    }

    @IsTest
    static void testGetStartDateOfWeek() {

        Datetime dtVar = jam.dates.getStartDateOfWeek(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 17), dtVar);

        Date dateVar = jam.dates.getStartDateOfWeek(Date.newInstance(2018, 9, 22));
        System.assertEquals(Date.newInstance(2018, 9, 17), dateVar);
    }

    @IsTest
    static void testGetEndDateOfWeek() {

        Datetime dtVar = jam.dates.getEndDateOfWeek(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 23, 23, 59, 9), dtVar);

        Date dateVar = jam.dates.getEndDateOfWeek(Date.newInstance(2018, 9, 22));
        System.assertEquals(Date.newInstance(2018, 9, 23), dateVar);
    }

    @IsTest
    static void testIsDateInCurrentWeekOrInFuture() {

        Date dateVar = Date.today().addDays(10);
        Boolean currentOrFuture = jam.dates.isDateInCurrentWeekOrInFuture(dateVar);
        System.assertEquals(true, currentOrFuture);
    }

    @IsTest
    static void testGetLastDayInMonth() {

        Date dateVar = jam.dates.getLastDayInMonth(Date.newInstance(2018, 9, 19));
        System.assertEquals(Date.newInstance(2018, 9, 30), dateVar);
    }

    @IsTest
    static void testGetLastWorkingDay() {

        Date dateVar = jam.dates.getLastWorkingDay(Date.newInstance(2018, 9, 23));
        System.assertEquals(Date.newInstance(2018, 9, 21), dateVar);

    }

    @IsTest
    static void testGetLastDayInFortnight() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 18);
        Date endOfPeriod = jam.dates.getLastDayInFortnight(dateVar, startDate);
        System.assertEquals(Date.newInstance(2018, 9, 30), endOfPeriod);

        endOfPeriod = jam.dates.getLastDayInFortnight(Date.newInstance(2018, 10, 1), startDate);
        System.assertEquals(Date.newInstance(2018, 10, 14), endOfPeriod);
        Boolean didThrowException = false;
        try {
            jam.dates.getLastDayInFortnight(dateVar, Date.newInstance(2018, 9, 20));
        } catch (Exception ex) {
            didThrowException = true;
        }
        System.assert(didThrowException);
    }

    @IsTest
    static void testGetFirstDayInFortnight() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 18);
        Date startOfPeriod = jam.dates.getFirstDayInFortnight(dateVar, startDate);
        System.assertEquals(Date.newInstance(2018, 9, 17), startOfPeriod);
    }

    @IsTest
    static void testDateInRange() {
        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 17);
        Date endDate = Date.newInstance(2018, 9, 30);
        System.assert(jam.dates.dateInRange(dateVar, startDate, endDate, true));
    }

    @IsTest
    static void testDetectDateInRange() {
        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 17);
        Date endDate = Date.newInstance(2018, 9, 30);
        dateVar = jam.dates.detectDateInRange(dateVar, startDate, endDate);
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);
    }

    @IsTest
    static void testCrossingDateRanges() {
        Date date1start = Date.newInstance(2022, 7, 20);
        Date date1end = Date.newInstance(2022, 7, 30);
        Date date2start = Date.newInstance(2022, 7, 21);
        Date date2end = Date.newInstance(2022, 7, 22);
        System.assert(jam.dates.crossingDateRanges(date1start, date1end, date2start, date2end));
    }

    @IsTest
    static void testAge() {
        Date birthDate = Date.newInstance(2000, 9, 22);
        System.assert(jam.dates.age(birthDate) > 20);
    }

    @IsTest
    static void testMin() {
        Date date1 = Date.newInstance(2000, 9, 22);
        Date date2 = Date.newInstance(2000, 10, 22);
        System.assertEquals(date1, jam.dates.min(date1, date2));
    }

    @IsTest
    static void testMax() {
        Date date1 = Date.newInstance(2000, 9, 22);
        Date date2 = Date.newInstance(2000, 10, 22);
        System.assertEquals(date2, jam.dates.max(date1, date2));
    }

    @IsTest
    static void testDatetimeStringToDatetime() {
        System.assertNotEquals(null, jam.dates.datetimeStringToDatetime('2018-12-01 00:00:00'));
    }
    /**
          * ==============================================================================================================
          *                                         STRING EXTENSIONS
          * ==============================================================================================================
     */

    @IsTest
    static void testDefaultIfBlank() {
        String str = '';
        System.assertEquals('default', jam.strings.defaultIfBlank(str, 'default'));
    }

    @IsTest
    static void testEmptyStringIfNull() {
        String str;
        System.assertEquals('', jam.strings.emptyStringIfNull(str));
    }

    @IsTest
    static void testNewGuid() {
        System.assertNotEquals('string', jam.strings.newGuid());
    }

    @IsTest
    static void testNewUuid() {
        System.assertNotEquals('string', jam.strings.newUuid());
    }

    @IsTest
    static void testJoinNonBlank() {
        List<String> parts = new List<String>{
                'test1', '', 'test2', ''
        };
        System.assertEquals('test1;test2', jam.strings.joinNonBlank(parts, ';'));
    }

    /**f
     * ==============================================================================================================
     *                                           USER EXTENSIONS
     * ==============================================================================================================
     */

    @IsTest
    static void testAssertPermSet() {

        Boolean didThrowException = false;
        try {
            jam.users.assertPermSet('ActionAI Test Permission', 'Access Error');
        } catch (Exception ex) {
            didThrowException = true;
        }
        System.assert(didThrowException);
    }

    /**
     * ==============================================================================================================
     *                                         SOBJECT EXTENSIONS
     * ==============================================================================================================
     */

    @IsTest
    static void testGetIdFieldValues() {
        List<Contact> cts = createAndReturnContacts(3);
        Set<Id> setIds = new Set<Id>();
        for (Contact contact : cts) {
            setIds.add(contact.Id);
        }
        Set<Id> values = jam.sObjects.getIdFieldValues(cts, Contact.Id.getDescribe().getSobjectField());
        System.assert(setIds.equals(values));
    }

    @IsTest
    static void testGetStringFieldValues() {
        List<Contact> cts = createAndReturnContacts(3);
        Set<String> testSet = new Set<String>{
                'Contact0', 'Contact1', 'Contact2'
        };
        System.assertEquals(testSet, jam.sObjects.getStringFieldValues(cts, Contact.LastName.getDescribe().getSobjectField()));

    }

    @IsTest
    static void testGetSObjectsByAnyFieldMap() {

        List<Contact> cts = createAndReturnContacts(3);
        Map<String, SObject> mappedContacts = jam.sObjects.getSObjectsByAnyFieldMap(cts, Contact.Id.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());
    }

    @IsTest
    static void testGetSObjectsListByAnyFieldMap() {

        List<Contact> cts = createAndReturnContacts(3);
        Map<String, List<SObject>> mappedContacts = jam.sObjects.getSObjectsListByAnyFieldMap(cts, Contact.LastName.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());

        cts.add(new Contact(FirstName = 'Test', LastName = 'Contact0'));
        mappedContacts = jam.sObjects.getSObjectsListByAnyFieldMap(cts, Contact.LastName.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());
    }

    @IsTest
    static void testFieldToProperty() {

        String property = jam.sObjects.fieldToProperty(Contact.FirstName.getDescribe().getSobjectField());
        System.assertEquals('firstName', property);
    }

    @IsTest
    static void testFieldNameToProperty() {

        String property = jam.sObjects.fieldNameToProperty('');
        System.assertEquals('', property);

        property = jam.sObjects.fieldNameToProperty('rs__tests_field__c');
        System.assertEquals('rsTestsField', property);
    }

    @IsTest
    static void testToSelectOption() {

        List<Contact> cts = createAndReturnContacts(3);
        jam.SelectOption selectOption = jam.sObjects.toSelectOption(cts.get(0), 'FirstName', 'LastName');
        System.assertNotEquals(null, selectOption);

        selectOption = jam.sObjects.toSelectOption(cts.get(0), 'LastName');
        System.assertNotEquals(null, selectOption);

        selectOption = jam.sObjects.toSelectOption(cts.get(0));
        System.assertNotEquals(null, selectOption);

        List<System.SelectOption> options = new List<System.SelectOption>();
        for (Integer i = 0; i < 3; i++) {
            options.add(new System.SelectOption('Value' + i, 'Label' + i));
        }
        List<jam.SelectOption> selectOptions = jam.sObjects.toSelectOptions(options);
        System.assertNotEquals(null, selectOptions);


        selectOptions = jam.sObjects.toSelectOptions(cts);
        System.assertNotEquals(null, selectOptions);

        selectOptions = jam.sObjects.toSelectOptions(cts, 'FirstName');
        System.assertNotEquals(null, selectOptions);

        selectOptions = jam.sObjects.toSelectOptions(cts, 'FirstName', 'LastName');
        System.assertNotEquals(null, selectOptions);

    }

    @IsTest
    static void testSwap() {

        Contact ct = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert ct;

        Schema.SObjectField field1 = Contact.FirstName.getDescribe().getSobjectField();
        Schema.SObjectField field2 = Contact.LastName.getDescribe().getSobjectField();
        jam.sObjects.swap(ct, field1, field2);
        System.assertEquals('Contact', ct.get('FirstName'));
        System.assertEquals('Test', ct.get('LastName'));
    }

    @IsTest
    static void testStringToSObjectType() {

        SObjectType objectType = jam.sObjects.stringToSObjectType('Account');
        System.assertEquals(Account.getSObjectType(), objectType);
    }

    @IsTest
    static void testGetFieldsByTypes() {
        Set<DisplayType> displayTypes = new Set<DisplayType>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            displayTypes.add(fielddataType);
        }
        Set<SObjectField> fields = jam.sObjects.getFieldsByTypes(Account.getSObjectType(), displayTypes);
        System.assertNotEquals(null, fields);
    }

    @IsTest
    static void testAssertReadable() {
        Contact contactVar = new Contact(LastName = 'test');
        jam.sObjects.assertReadable(contactVar);
        System.assert(contactVar != null);
    }

    @IsTest
    static void testRecordTypeIdByAPIName() {
        try {
            jam.sObjects.recordTypeIdByAPIName(Account.SObjectType, 'Test');
        } catch (Exception ex) {
            System.assertEquals('No Record Type for: Account with API Name: Test', ex.getMessage());
        }
    }


    @IsTest
    static void testIsSomeFieldChanged() {
        Contact recordVar = new Contact(LastName = 'test1');
        Contact recordVar2 = new Contact(LastName = 'test2');

        System.assert(jam.sObjects.isSomeFieldChanged(recordVar, recordVar2, new List<SObjectField>{
                Contact.LastName
        }));
    }

    @IsTest
    static void testGetValueByPath() {
        Account accountVar = new Account(Name = 'testAcc');
        insert accountVar;
        Contact contactVar = new Contact(AccountId = accountVar.Id, LastName = 'testContact');
        insert contactVar;
        contactVar = [SELECT Id, Account.Name FROM Contact WHERE LastName = 'testContact'];
        System.assertEquals('testAcc', jam.sObjects.getValueByPath(contactVar, 'Account.Name'));
    }

    @IsTest
    static void testGetSObjectDescribe() {
        System.assertNotEquals(null, jam.sObjects.getSObjectDescribe(new List<SObjectType>{
                Account.SObjectType
        }));
    }

    @IsTest
    static void testSObjectsToMaps() {
        Account accountVar = new Account(Name = 'testAcc');
        insert accountVar;
        Contact contactVar = new Contact(AccountId = accountVar.Id, LastName = 'testContact', Birthdate = Date.newInstance(2000, 1, 1), FirstName = 'testFirstName');
        insert contactVar;

        contactVar = [SELECT Account.Name, LastName, FirstName, Birthdate FROM Contact WHERE LastName = 'testContact'];
        System.assertNotEquals(null, jam.sObjects.sObjectsToMaps(new List<Contact>{
                contactVar
        }));

        System.assertNotEquals(null, jam.sObjects.sObjectToMap(contactVar));
    }

    @IsTest
    static void testMapToSObject() {
        Contact testContact = createContact('test', 'Australia');
        Contact testContact2 = createContact('test2', 'Australia');

        List<Contact> testContacts = new List<Contact>{
                testContact, testContact2
        };

        jam.DTO dtoVar = new jam.DTO();


        dtoVar.put('contact', testContact)
                .put('contacts', testContacts);

        System.assert(dtoVar.dto.containsKey('contact'));
        System.assert(dtoVar.dto.containsKey('contacts'));

        Contact newContact = new Contact(
                Email = 'test@test.com', Birthdate = Date.newInstance(2018, 10, 10)
        );

        dtoVar.getSObject('contact', newContact);

        System.assertEquals('test@test.com', newContact.Email);
        System.assertEquals('Australia', newContact.MailingCountry);
        System.assertEquals('test', newContact.LastName);

        dtoVar.setIsVisualforce(true);
        dtoVar.setDefaultFieldValue(' ');
        dtoVar.put('newContact', newContact);
        dtoVar.getSObject('newContact', newContact);

        dtoVar.setIsVisualforce(false);
        dtoVar.put('newContact', newContact);
        dtoVar.getSObject('newContact', newContact);
    }

    @IsTest
    static void deduplicate() {
        Contact contact1 = new Contact(
                FirstName = '1',
                LastName = '1',
                Email = '1@test.com',
                Title = 'Developer'
        );

        insert contact1;

        Contact contact2 = contact1.clone(false);
        contact2.Title = 'Manager';

        Boolean isExistingRecordFound = jam.sObjects.deduplicate(contact2, new Set<SObjectField>{
                Contact.Title
        });

        upsert contact2;

        System.assertEquals(isExistingRecordFound ? 1 : 2, [SELECT COUNT() FROM Contact]);

        if (isExistingRecordFound) {
            System.assertEquals('Developer', contact2.Title); // Preserved Field.
        }


        // Just to increase the test coverage.
        jam.sObjects.deduplicate(contact2);
    }

    /**
     * ==============================================================================================================
     *                                            URL EXTENSIONS
     * ==============================================================================================================
     */


    @IsTest
    static void testURLExtensions() {
        PageReference pageRef = jam.URLs.listView(Account.getSObjectType());
        System.assertNotEquals(null, pageRef);
    }

    @IsTest
    static void testGenerateReportURL() {
        System.assertEquals('/lightning/r/Report/test/view?queryScope=userFolders&fv1=param1&fv2=param2', jam.URLs.generateReportURL('test', new List<String>{
                'param1', 'param2'
        }));
    }

    /**
     * ==============================================================================================================
     *                                          ENCODING EXTENSIONS
     * ==============================================================================================================
     */

    @IsTest
    static void testMapToFormUrlEncoded() {
        Map<String, String> dataMap = new Map<String, String>{
                'test1' => 'test1',
                'test2' => 'test2'
        };

        System.assertEquals('test1=test1&test2=test2', jam.encodings.mapToFormUrlEncoded(dataMap));
    }

    @IsTest
    static void testGetEncryptedValueAndGetDecryptedValue() {
        String key = 'D9N3GZGb1bGjIE1jOQs0gtIBgEV+IXhunJVbh5SKJ0M=';
        String testStr = 'test';
        String encryptedTestStr = jam.encodings.getEncryptedValue(testStr, key);
        System.assertNotEquals(testStr, encryptedTestStr);
        System.assertEquals(testStr, jam.encodings.getDecryptedValue(encryptedTestStr, key));
    }

    /**
    * ==============================================================================================================
    *                                             ARRAY EXTENSIONS
    * ==============================================================================================================
    */

    @IsTest
    static void testFirstOrDefault() {

        List<String> stringList = createStringList(0);
        String result = (String) jam.arrays.firstOrDefault(stringList, 'default');
        System.assertEquals('default', result);

        stringList = createStringList(3);
        result = (String) jam.arrays.firstOrDefault(stringList, 'default');
        System.assertEquals('test0', result);
    }

    @IsTest
    static void testFirstOrNull() {

        List<String> stringList = createStringList(0);
        String result = (String) jam.arrays.firstOrNull(stringList);
        System.assertEquals(null, result);

        stringList = createStringList(3);
        result = (String) jam.arrays.firstOrNull(stringList);
        System.assertEquals('test0', result);
    }

    @IsTest
    static void testFirstOrException() {

        List<String> stringList = createStringList(0);

        Boolean didThrowException = false;
        String result;
        try {
            result = (String) jam.arrays.firstOrException(stringList, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        System.assertEquals(null, result);

        stringList = createStringList(3);
        result = (String) jam.arrays.firstOrException(stringList);
        System.assertEquals('test0', result);
    }

    @IsTest
    static void testAddToSetIfNotBlank() {
        Set<String> dataSet = new Set<String>();

        jam.arrays.addToSetIfNotBlank(dataSet, '');
        jam.arrays.addToSetIfNotBlank(dataSet, 'test');
        System.assertEquals(1, dataSet.size());
    }

    @IsTest
    static void testSplit() {
        System.assertEquals(
                new List<List<Object>>{
                        new List<Object>{
                                1, 2
                        }
                        , new List<Object>{
                                3, 4
                        }, new List<Object>{
                                5, 6
                        }
                }, jam.arrays.split(new List<Integer>{
                        1, 2, 3, 4, 5, 6
                }, 2, List<Integer>. class));
    }

    @IsTest
    static void testAddToListOrCreateNew() {

        Map<String, List<String>> testMap = null;
        jam.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object', 2);
        if (testMap != null) {
            System.assertEquals('object', testMap.get('key0').get(0));
        }

        jam.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object', 0);
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        jam.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object');
        if (testMap != null) {
            System.assertEquals(3, testMap.get('key0').size());
        }

    }

    /**
    * ==============================================================================================================
    *                                             TEMPLATE EXTENSIONS
    * ==============================================================================================================
    */

    @IsTest
    static void testCompose() {
        String template = '{!firstParam} some text {!secondParam}';
        System.assertEquals('test1 some text test2', jam.templates.compose(template, new Map<String, Object>{
                'firstParam' => 'test1', 'secondParam' => 'test2'
        }));
    }

    @IsTest
    static void testGetExpressions() {
        String template = '{!firstParam} some text {!secondParam}';
        System.assertEquals(jam.templates.getExpressions(template).size(), 2);
    }

    @IsTest
    static void testGetSources() {
        String template = '{!firstParam} some text {!secondParam}';
        System.assertEquals(jam.templates.getSources(template).size(), 2);
    }

    /**
    * ==============================================================================================================
    *                                             OBJECT EXTENSIONS
    * ==============================================================================================================
    */

    @IsTest
    static void testRunPackageAction() {
        jam.setPackageActionMock('rs_stripy', 'StripeAct', new Map<String, Object>{
                'id' => 'testid',
                'url' => 'testUrl'
        });

        jam.Response response = jam.objects.runPackageAction('rs_stripy', 'StripeAct', null);
        System.assert(response.isValid);
    }

    @IsTest
    static void testGetMapValue() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        Object obj = jam.objects.getMapValue(testMap, 'key0.key1.key2');
        System.assertEquals(null, obj);

        obj = jam.objects.getMapValue(null, 'key0.key1.key2');
        System.assertEquals(null, obj);

    }

    @IsTest
    static void testSetMapValue() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        jam.objects.setMapValue(testMap, 'key0.key1.key2', new Map<String, Map<String, Object>>());
        System.assertNotEquals(null, testMap);

        jam.objects.setMapValue(null, 'key0.key1.key2', new Map<String, Map<String, Object>>());
        System.assertNotEquals(null, testMap);

    }

    @IsTest
    static void testRemoveMapValue() {
        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        jam.objects.setMapValue(testMap, 'key0.key1.key2', new Map<String, Map<String, Object>>());
        System.assertNotEquals(null, testMap);

        jam.objects.removeMapValue(testMap, 'key0.key1.key2');
        jam.objects.removeMapValue(testMap, 'key0.key1');
        System.assertNotEquals(null, testMap);
    }

    @IsTest
    static void testMapContains() {
        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        Boolean result = jam.objects.mapContains(testMap, 'key0.key1.key2');
        System.assertEquals(false, result);
    }

    @IsTest
    static void testThrowIfNull() {

        Boolean didThrowException = false;
        try {
            jam.objects.throwIfNull(null, new jam.MissingDataException());
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        try {
            jam.objects.throwIfNull(null, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
    }

    @IsTest
    static void testThrowIfBlank() {
        Boolean didThrowException = false;
        try {
            jam.objects.throwIfBlank(null, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        try {
            jam.objects.throwIfBlank('', 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

    @IsTest
    static void testParseDecimal() {
        Long myLong = 4271990;
        Integer myInt = 10;
        System.assertEquals(10.0, jam.objects.parseDecimal(myInt));
        System.assertEquals(4271990.0, jam.objects.parseDecimal(myLong));
        System.assertEquals(null, jam.objects.parseDecimal(null));
        System.assertEquals(12.0, jam.objects.parseDecimal(12.0));
        System.assertEquals(12.0, jam.objects.parseDecimal('12'));

        System.assertEquals(1809091.0, jam.objects.parseDecimal(Double.valueOf('1809091')));

        Boolean didThrowException = false;
        try {
            jam.objects.parseDecimal(didThrowException);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

    @IsTest
    static void testdDefaultIfNull() {
        System.assertEquals(12.0, jam.objects.defaultIfNull(null, 12.0));
        System.assertEquals(10.0, jam.objects.defaultIfNull(10.0, 12.0));
        System.assertEquals(10, jam.objects.defaultIfNull(null, 10));
        System.assertEquals(10, jam.objects.defaultIfNull(10, 12));
        System.assertEquals('12', jam.objects.defaultIfNull(null, '12'));
        System.assertEquals('10.0', jam.objects.defaultIfNull('10.0', '12.0'));
    }


    /**
     * ==============================================================================================================
     *                                          OTHER STATIC VARIABLES
     * ==============================================================================================================
     */

    @IsTest
    static void testJamStatic() {

        List<Organization> organizations = [
                SELECT IsSandbox, TrialExpirationDate
                FROM Organization
                WHERE Id = :UserInfo.getOrganizationId()
        ];
        Boolean didThrowException = false;
        Boolean isSandbox = false;
        Boolean isScratch = false;
        Boolean isTrialOrg = false;

        try {
            isSandbox = organizations.get(0).IsSandbox && organizations.get(0).TrialExpirationDate == null;
            isScratch = organizations.get(0).IsSandbox && organizations.get(0).TrialExpirationDate != null;
            isTrialOrg = !organizations.get(0).IsSandbox && organizations.get(0).TrialExpirationDate != null;
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

        System.assertEquals(isSandbox, jam.isSandbox);
        System.assertEquals(isScratch, jam.isScratch);
        System.assertEquals(isTrialOrg, jam.isTrialOrg);
        System.assertEquals(jam.holidays.size(), [SELECT Id FROM Holiday].size());
    }

    /**
     * ==============================================================================================================
     *                                          ACTION CLASS
     * ==============================================================================================================
     */

    @IsTest
    static void testRunAction() {
        Contact contactVar = new Contact(LastName = 'testContact');
        Account accountVar = new Account(Name = 'testAcc');
        Opportunity oppVar = new Opportunity(
                CloseDate = Date.today(),
                Amount = 100,
                StageName = 'Closed Won',
                Name = 'test opp'
        );

        insert contactVar;
        insert accountVar;
        insert oppVar;

        Map<String, Object> requestMap = new Map<String, Object>{
                'requiredString' => 'testRequiredString',
                'requiredStringWithMessage' => 'testRequiredStringWithMessage',
                'contact' => contactVar,
                'account' => accountVar,
                'opportunity' => oppVar
        };

        String requestJSON = JSON.serialize(requestMap);
        String response = jam.runAction('jamTest.jamTestAct', requestJSON);
        System.assertNotEquals(null, response);

        Boolean didThrowException = false;
        try {
            response = jam.runAction('NonexistentAct', requestJSON);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

        requestMap.put('string', 'test exception');
        requestJSON = JSON.serialize(requestMap);

        jam.Response invalidResponse = new jam.Response('Invalid request attributes.');
        System.assert(invalidResponse.isValid != true);
    }

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
            List<Map<String, Object>> maps = this.getMaps('maps');

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
            List<Contact> contacts = new List<Contact>{
                    contactVar, contactVar2
            };

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

    //QUERY FACTORY
    @IsTest
    static void fieldSelections() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('firstName');
        qf.selectField(Schema.Contact.SObjectType.fields.LastName);
        qf.selectFields(new Set<String>{
                'acCounTId', 'account.name'
        });
        qf.selectFields(new List<String>{
                'homePhonE', 'fAX'
        });
        qf.selectFields(new List<Schema.SObjectField>{
                Contact.Email, Contact.Title
        });
        System.assertEquals(new Set<String>{
                'FirstName',
                'LastName',
                'AccountId',
                'Account.Name',
                'HomePhone',
                'Fax',
                'Email',
                'Title'
        },
                qf.getSelectedFields());
    }

    @IsTest
    static void simpleFieldSelection() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('NAMe').selectFields(new Set<String>{
                'naMe', 'email'
        });
        String query = qf.toSOQL();
        System.assert(Pattern.matches('SELECT.*Name.*FROM.*', query), 'Expected Name field in query, got ' + query);
        System.assert(Pattern.matches('SELECT.*Email.*FROM.*', query), 'Expected Name field in query, got ' + query);
        qf.setLimit(100);
        System.assertEquals(100, qf.getLimit());
        System.assert(qf.toSOQL().endsWithIgnoreCase('LIMIT ' + qf.getLimit()), 'Failed to respect limit clause:' + qf.toSOQL());
    }

    @IsTest
    static void simpleFieldCondition() {
        String whereClause = 'name = \'test\'';
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition(whereClause);
        System.assertEquals(whereClause, qf.getCondition());
        String query = qf.toSOQL();
        System.assert(query.endsWith('WHERE name = \'test\' WITH USER_MODE'), 'Query should have ended with a filter on name, got: ' + query);
    }

    @IsTest
    static void duplicateFieldSelection() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('NAMe').selectFields(new Set<String>{
                'naMe', 'email'
        });
        String query = qf.toSOQL();
        System.assertEquals(1, query.countMatches('Name'), 'Expected one name field in query: ' + query);
    }

    @IsTest
    static void equalityCheck() {
        jam.QueryFactory qf1 = new jam.QueryFactory(Contact.SObjectType);
        jam.QueryFactory qf2 = new jam.QueryFactory(Contact.SObjectType);
        System.assertEquals(qf1, qf2);
        qf1.selectField('name');
        System.assertNotEquals(qf1, qf2);
        qf2.selectField('NAmE');
        System.assertEquals(qf1, qf2);
        qf1.selectField('name').selectFields(new Set<String>{
                'NAME', 'name'
        }).selectFields(new Set<Schema.SObjectField>{
                Contact.Name, Contact.Name
        });
        System.assertEquals(qf1, qf2);
    }

    @IsTest
    static void nonReferenceField() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        jam.ProcessException e;
        try {
            qf.selectField('name.title');
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(null, e, 'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
    }

    @IsTest
    static void invalidCrossObjectField() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        jam.ProcessException e;
        try {
            qf.selectField('account.NOT_A_REAL_FIELD');
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(null, e, 'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
    }

    @IsTest
    static void invalidFieldTests() {
        List<jam.ProcessException> exceptions = new List<jam.ProcessException>();
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        try {
            qf.selectField('Not_a_field');
        } catch (jam.ProcessException e) {
            exceptions.add(e);
        }
        try {
            qf.selectFields(new Set<String>{
                    'Not_a_field', 'alsoNotreal'
            });
        } catch (jam.ProcessException e) {
            exceptions.add(e);
        }
        try {
            qf.selectFields(new Set<Schema.SObjectField>{
                    null
            });
        } catch (jam.ProcessException e) {
            exceptions.add(e);
        }
        try {
            qf.selectFields(new List<Schema.SObjectField>{
                    null, Contact.Title
            });
        } catch (jam.ProcessException e) {
            exceptions.add(e);
        }
        System.assertEquals(4, exceptions.size());
    }

    @IsTest
    static void ordering() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition('name = \'test\'');
        qf.addOrdering(new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING)).addOrdering(new jam.Ordering('Contact', 'CreatedDATE', jam.SortOrder.DESCENDING));
        String query = qf.toSOQL();

        System.assertEquals(2, qf.getOrderings().size());
        System.assertEquals('Name', qf.getOrderings()[0].getField());
        System.assertEquals(jam.SortOrder.DESCENDING, qf.getOrderings()[1].getDirection());


        System.assert(Pattern.matches('SELECT.*Name.*FROM.*', query), 'Expected Name field in query, got ' + query);
        System.assert(Pattern.matches('SELECT.*Email.*FROM.*', query), 'Expected Name field in query, got ' + query);
    }

    @IsTest
    static void setOrdering_ReplacesPreviousOrderingsWithExpectedOrdering() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition('name = \'test\'');

        qf.setOrdering(new jam.Ordering('Contact', 'OwnerId', jam.SortOrder.DESCENDING));

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace default Orderings');
        System.assertEquals(Contact.OwnerId.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field OwnerId');
        System.assertEquals(jam.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        qf.setOrdering('LastModifiedDate', jam.SortOrder.ASCENDING, true);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(Contact.LastModifiedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field LastModifiedDate');
        System.assertEquals(jam.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        qf.setOrdering(Contact.CreatedDate, jam.SortOrder.DESCENDING, true);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(Contact.CreatedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field CreatedDate');
        System.assertEquals(jam.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        qf.setOrdering('CreatedBy.Name', jam.SortOrder.DESCENDING);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(jam.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        qf.setOrdering(Contact.Birthdate, jam.SortOrder.ASCENDING);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(Contact.Birthdate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field Birthdate');
        System.assertEquals(jam.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        String query = qf.toSOQL();
    }

    @IsTest
    static void invalidField_string() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        try {
            qf.selectField('not_a__field');
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(null, e);
    }

    @IsTest
    static void invalidFields_string() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        try {
            qf.selectFields(new List<String>{
                    'not_a__field'
            });
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(null, e);
    }

    @IsTest
    static void invalidField_nullToken() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        Schema.SObjectField token = null;
        try {
            qf.selectField(token);
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(null, e);
    }

    @IsTest
    static void invalidFields_nullToken() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        List<Schema.SObjectField> token = new List<Schema.SObjectField>{
                null
        };
        try {
            qf.selectFields(token);
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(null, e);
    }

    @IsTest
    static void invalidFields_noQueryField() {
        try {
            String path = jam.getFieldTokenPath(null);
            System.assert(false, 'Expected InvalidFieldException; none was thrown');
        } catch (jam.ProcessException ife) {
        } catch (Exception e) {
            System.assert(false, 'Expected InvalidFieldException; ' + e.getTypeName() + ' was thrown instead: ' + e);
        }
    }

    @IsTest
    static void queryFieldsNotEquals() {
        String qfld = jam.getFieldTokenPath(Contact.Name);
        String qfld2 = jam.getFieldTokenPath(Contact.LastName);
        System.assert(!qfld.equals(qfld2));
    }

    @IsTest
    static void addChildQueriesWithChildRelationship_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition('name like \'%test%\'').addOrdering('CreatedDate', jam.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        qf.subSelectQuery('Tasks').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<jam.QueryFactory> queries = qf.getSubSelectQueries();
        System.assert(queries != null);
        List<Contact> contacts = Database.query(qf.toSOQL());
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipNoAccessibleCheck_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition('name like \'%test%\'').addOrdering('CreatedDate', jam.SortOrder.DESCENDING, true);

        qf.subSelectQuery('Tasks').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<jam.QueryFactory> queries = qf.getSubSelectQueries();
        System.assert(queries != null);
        String soql = qf.toSOQL();
        List<Contact> contacts = Database.query(soql);
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipObjCheckIsAccessible_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition('name like \'%test%\'').addOrdering('CreatedDate', jam.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        Schema.ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        qf.subSelectQuery(relationship).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<jam.QueryFactory> queries = qf.getSubSelectQueries();
        System.assert(queries != null);
        List<Contact> contacts = Database.query(qf.toSOQL());
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipObj_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition('name like \'%test%\'').addOrdering('CreatedDate', jam.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        Schema.ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        qf.subSelectQuery(relationship).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<jam.QueryFactory> queries = qf.getSubSelectQueries();
        System.assert(queries != null);
        List<Contact> contacts = Database.query(qf.toSOQL());
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipNoAccessibleCheck_fail() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition('name like \'%test%\'').addOrdering('CreatedDate', jam.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();

        Exception e;
        try {
            qf.subSelectQuery('Tas').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(e, null);
    }

    @IsTest
    static void addChildQueries_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition('name like \'%test%\'').addOrdering('CreatedDate', jam.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        qf.subSelectQuery(Task.SObjectType).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<jam.QueryFactory> queries = qf.getSubSelectQueries();
        System.assert(queries != null);
        List<Contact> contacts = Database.query(qf.toSOQL());
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQuerySameRelationshipAgain_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('Id');
        qf.setCondition('name like \'%test%\'');
        qf.addOrdering(new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING)).addOrdering('CreatedBy.Name', jam.SortOrder.DESCENDING);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        System.assert(qf.getSubSelectQueries() == null);
        jam.QueryFactory childQf = qf.subSelectQuery(Task.SObjectType);
        childQf.selectField('Id');
        jam.QueryFactory childQf2 = qf.subSelectQuery(Task.SObjectType);
        List<jam.QueryFactory> queries = qf.getSubSelectQueries();
        System.assert(queries != null);
        System.assert(queries.size() == 1);
    }

    @IsTest
    static void addChildQueries_invalidChildRelationship() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition('name like \'%test%\'');
        qf.addOrdering(new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING)).addOrdering('CreatedDATE', jam.SortOrder.DESCENDING);
        Schema.DescribeSObjectResult descResult = Account.SObjectType.getDescribe();
        Exception e;
        try {
            SObjectType invalidType = null;
            jam.QueryFactory childQf = qf.subSelectQuery(invalidType);
            childQf.selectField('Id');
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(e, null);
    }

    @IsTest
    static void addChildQueries_invalidChildRelationshipTooDeep() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition('name like \'%test%\'');
        qf.addOrdering(new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING)).addOrdering('CreatedDATE', jam.SortOrder.DESCENDING);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();

        jam.QueryFactory childQf = qf.subSelectQuery(Task.SObjectType);
        childQf.selectField('Id');
        childQf.selectField('Subject');
        Exception e;
        try {
            jam.QueryFactory subChildQf = childQf.subSelectQuery(Task.SObjectType);
        } catch (jam.ProcessException ex) {
            e = ex;
        }
        System.assertNotEquals(e, null);
    }

    @IsTest
    static void checkFieldObjectReadSort_success() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType);
        qf.selectField('createdby.name')
                .selectField(Contact.LastModifiedById)
                .selectFields(new List<SObjectField>{
                        Contact.LastModifiedDate
                })
                .selectField(Contact.LastName)
                .selectFields(new List<SObjectField>{
                        Contact.Id
                })
                .setCondition('name like \'%test%\'')
                .selectFields(new Set<SObjectField>{
                        Contact.FirstName
                })
                .addOrdering(new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING))
                .addOrdering(Contact.LastModifiedDate, jam.SortOrder.DESCENDING)
                .addOrdering(Contact.CreatedDate, jam.SortOrder.DESCENDING, true);
        Set<String> fields = qf.getSelectedFields();
        jam.Ordering ordering = new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING);
        System.assertEquals('Name', ordering.getField());

        System.assertEquals(new Set<String>{
                'CreatedBy.Name',
                'LastModifiedById',
                'LastModifiedDate',
                'LastName',
                'Id',
                'FirstName'
        },
                fields);

        System.assert(qf.toSOQL().containsIgnoreCase('NULLS LAST'));
    }

    @IsTest
    static void deterministic_toSOQL() {
        jam.QueryFactory qf1 = new jam.QueryFactory(User.SObjectType);
        jam.QueryFactory qf2 = new jam.QueryFactory(User.SObjectType);
        for (jam.QueryFactory qf : new Set<jam.QueryFactory>{
                qf1, qf2
        }) {
            qf.selectFields(new List<String>{
                    'Id',
                    'FirstName',
                    'LastName',
                    'CreatedBy.Name',
                    'CreatedBy.Manager',
                    'LastModifiedBy.Email'
            });
        }
        String expectedQuery =
                'SELECT CreatedBy.ManagerId, CreatedBy.Name, '
                        + 'FirstName, Id, LastModifiedBy.Email, LastName '
                        + 'FROM User '
                        + 'WITH USER_MODE';
        System.assertEquals(qf1.toSOQL(), qf2.toSOQL());
        System.assertEquals(expectedQuery, qf1.toSOQL());
        System.assertEquals(expectedQuery, qf2.toSOQL());
    }

    @IsTest
    static void deepCloneBasicNoChanges() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType)
                .setLimit(10)
                .setCondition('id=12345')
                .selectField('Description')
                .addOrdering(new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING))
                .addOrdering(new jam.Ordering('Contact', 'CreatedDATE', jam.SortOrder.DESCENDING));

        jam.QueryFactory qf2 = qf.deepClone();

        System.assertEquals(qf2, qf);

        System.assertEquals(qf.getLimit(), qf2.getLimit());
        System.assertEquals(qf.getCondition(), qf2.getCondition());
        System.assertEquals(qf.toSOQL(), qf2.toSOQL());
        System.assertEquals(qf.getOrderings(), qf2.getOrderings());
    }

    @IsTest
    static void deepCloneBasic() {
        jam.QueryFactory qf = new jam.QueryFactory(Contact.SObjectType)
                .setLimit(10)
                .setCondition('id=12345')
                .selectField('Description')
                .addOrdering(new jam.Ordering('Contact', 'name', jam.SortOrder.ASCENDING))
                .addOrdering(new jam.Ordering('Contact', 'CreatedDATE', jam.SortOrder.DESCENDING));


        jam.QueryFactory qf2 = qf.deepClone()
                .setLimit(200)
                .setCondition('id=54321')
                .selectField('Fax')
                .addOrdering(new jam.Ordering('Contact', 'Fax', jam.SortOrder.ASCENDING));

        qf2.getOrderings().remove(0);

        System.assertEquals(10, qf.getLimit());
        System.assertEquals(200, qf2.getLimit());

        System.assertEquals('id=12345', qf.getCondition());
        System.assertEquals('id=54321', qf2.getCondition());

        String query = qf.toSOQL();
        String query2 = qf2.toSOQL();

        System.assert(query.containsIgnoreCase('Fax') == false);
        System.assert(query.containsIgnoreCase('Description'));
        System.assert(query2.containsIgnoreCase('Description'));
        System.assert(query2.containsIgnoreCase('Fax'));

        System.assertEquals(2, qf.getOrderings().size());
        System.assertEquals('Name', qf.getOrderings()[0].getField());
        System.assertEquals(jam.SortOrder.DESCENDING, qf.getOrderings()[1].getDirection());

        System.assertEquals(2, qf2.getOrderings().size());
        System.assertEquals('Fax', qf2.getOrderings()[1].getField());
        System.assertEquals(jam.SortOrder.ASCENDING, qf2.getOrderings()[1].getDirection());

    }

    @IsTest
    static void deepCloneSubquery() {
        jam.QueryFactory qf = new jam.QueryFactory(Account.SObjectType);
        qf.subSelectQuery('Contacts');

        jam.QueryFactory qf2 = qf.deepClone();
        qf2.subSelectQuery('Opportunities');

        List<jam.QueryFactory> subqueries = qf.getSubSelectQueries();
        List<jam.QueryFactory> subqueries2 = qf2.getSubSelectQueries();

        jam.QueryFactory subquery2_0 = subqueries2.get(0);

        subquery2_0.addOrdering(new jam.Ordering('Contact', 'Name', jam.SortOrder.ASCENDING));

        System.assert(subqueries.size() == 1);
        System.assert(subqueries2.size() == 2);

        System.assert(qf.getSubSelectQueries().get(0).getOrderings().size() == 0);
        System.assert(qf2.getSubSelectQueries().get(0).getOrderings().size() == 1);
    }

    @IsTest
    static void testSoql_unsortedSelectFields() {
        jam.QueryFactory qf = new jam.QueryFactory(User.SObjectType);
        qf.selectFields(new List<String>{
                'Id',
                'FirstName',
                'LastName',
                'CreatedBy.Name',
                'CreatedBy.Manager',
                'LastModifiedBy.Email'
        });

        qf.setSortSelectFields(false);

        String orderedQuery =
                'SELECT '
                        + 'FirstName, Id, LastName, '
                        + 'CreatedBy.ManagerId, CreatedBy.Name, LastModifiedBy.Email '
                        + 'FROM User';

        String actualSoql = qf.toSOQL();

        System.assertNotEquals(orderedQuery, actualSoql);
    }

    //UNIT OF WORK
    private static List<Schema.SObjectType> MY_SOBJECTS =
            new Schema.SObjectType[]{
                    Product2.SObjectType,
                    PricebookEntry.SObjectType,
                    Opportunity.SObjectType,
                    OpportunityLineItem.SObjectType
            };

    @IsTest
    private static void testUnitOfWorkEmail() {
        String testRecordName = 'UoW Test Name 1';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{
                'foobar@test.com'
        });
        email.setPlainTextBody('See Spot run.');

        jam.UnitOfWork uow = new jam.UnitOfWork(MY_SOBJECTS);

        uow.m_emailWork = new Mock_SendEmailWork();

        Opportunity opp = new Opportunity();
        opp.Name = testRecordName;
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        uow.registerNew(opp);

        uow.registerEmail(email);

        uow.registerRelationship(email, opp);

        uow.commitWork();

        List<Opportunity> opps = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Name = :testRecordName ORDER BY Name];

        System.assert(((Mock_SendEmailWork) uow.m_emailWork).doWorkWasCalled);
        System.assertEquals(1, opps.size());
    }

    @IsTest
    private static void testUnitOfWorkNewDirtyDelete() {
        {
            jam.UnitOfWork uow = new jam.UnitOfWork(MY_SOBJECTS);
            for (Integer o = 0; o < 10; o++) {
                Opportunity opp = new Opportunity();
                opp.Name = 'UoW Test Name ' + o;
                opp.StageName = 'Open';
                opp.CloseDate = System.today();
                uow.registerNew(new List<SObject>{
                        opp
                });
                for (Integer i = 0; i < o + 1; i++) {
                    Product2 product = new Product2();
                    product.Name = opp.Name + ' : Product : ' + i;
                    uow.registerNew(new List<SObject>{
                            product
                    });
                    PricebookEntry pbe = new PricebookEntry();
                    pbe.UnitPrice = 10;
                    pbe.IsActive = true;
                    pbe.UseStandardPrice = false;
                    pbe.Pricebook2Id = Test.getStandardPricebookId();
                    uow.registerNew(pbe, PricebookEntry.Product2Id, product);
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.Quantity = 1;
                    oppLineItem.TotalPrice = 10;
                    uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
                    uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
                }
            }

            uow.commitWork();
        }

        assertResults('UoW');
        List<Opportunity> opps = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Name LIKE 'UoW Test Name %' ORDER BY Name];

        {
            jam.UnitOfWork uow = new jam.UnitOfWork(MY_SOBJECTS);
            Opportunity opp = opps[0];
            opp.Name = opp.Name + ' Changed';
            uow.registerDirty(new List<SObject>{
                    opp
            });
            Product2 product = new Product2();
            product.Name = opp.Name + ' : New Product';
            uow.registerNew(new List<SObject>{
                    product
            });
            PricebookEntry pbe = new PricebookEntry();
            pbe.UnitPrice = 10;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            uow.registerNew(pbe, PricebookEntry.Product2Id, product);
            OpportunityLineItem newOppLineItem = new OpportunityLineItem();
            newOppLineItem.Quantity = 1;
            newOppLineItem.TotalPrice = 10;
            uow.registerRelationship(newOppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
            uow.registerNew(newOppLineItem, OpportunityLineItem.OpportunityId, opp);
            OpportunityLineItem existingOppLine = opp.OpportunityLineItems[0];
            existingOppLine.Quantity = 2;
            uow.registerDirty(new List<SObject>{
                    existingOppLine
            });
            existingOppLine.TotalPrice = 20;
            uow.registerDirty(new List<SObject>{
                    existingOppLine
            });
            uow.commitWork();
        }

        opps = [
                SELECT Id, Name, (SELECT Id, PricebookEntry.Product2.Name, Quantity, TotalPrice FROM OpportunityLineItems ORDER BY PricebookEntry.Product2.Name)
                FROM Opportunity
                WHERE Name LIKE
                        'UoW Test Name %'
                ORDER BY Name
        ];
        System.assertEquals(10, opps.size());
        System.assertEquals('UoW Test Name 0 Changed', opps[0].Name);
        System.assertEquals(2, opps[0].OpportunityLineItems.size());
        System.assertEquals(2, opps[0].OpportunityLineItems[0].Quantity);
        System.assertEquals(20, opps[0].OpportunityLineItems[0].TotalPrice);
        System.assertEquals('UoW Test Name 0 Changed : New Product', opps[0].OpportunityLineItems[1].PricebookEntry.Product2.Name);

        {
            jam.UnitOfWork uow = new jam.UnitOfWork(MY_SOBJECTS);
            uow.registerDeleted(new List<SObject>{
                    opps[0].OpportunityLineItems[1].PricebookEntry.Product2
            });
            uow.registerDeleted(new List<SObject>{
                    opps[0].OpportunityLineItems[1].PricebookEntry
            });
            uow.registerDeleted(new List<SObject>{
                    opps[0].OpportunityLineItems[1]
            });
            uow.registerDeleted(new List<SObject>{
                    opps[0].OpportunityLineItems[1].PricebookEntry.Product2
            });
            uow.registerDeleted(new List<SObject>{
                    opps[0].OpportunityLineItems[1].PricebookEntry
            });
            uow.registerDeleted(new List<SObject>{
                    opps[0].OpportunityLineItems[1]
            });
            uow.commitWork();
        }

        opps = [
                SELECT Id, Name, (SELECT Id, PricebookEntry.Product2.Name, Quantity FROM OpportunityLineItems ORDER BY PricebookEntry.Product2.Name)
                FROM Opportunity
                WHERE Name LIKE 'UoW Test Name %'
                ORDER BY Name
        ];
        List<Product2> prods = [SELECT Id FROM Product2 WHERE Name = 'UoW Test Name 0 Changed : New Product'];
        System.assertEquals(10, opps.size());
        System.assertEquals('UoW Test Name 0 Changed', opps[0].Name);
        System.assertEquals(1, opps[0].OpportunityLineItems.size()); // Should have deleted OpportunityLineItem added above
        System.assertEquals(0, prods.size()); // Should have deleted Product added above
    }

    private static void assertResults(String prefix) {
        String filter = prefix + ' Test Name %';
        List<Opportunity> opps = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Name LIKE :filter ORDER BY Name];
        System.assertEquals(10, opps.size());
        System.assertEquals(1, opps[0].OpportunityLineItems.size());
        System.assertEquals(2, opps[1].OpportunityLineItems.size());
        System.assertEquals(3, opps[2].OpportunityLineItems.size());
        System.assertEquals(4, opps[3].OpportunityLineItems.size());
        System.assertEquals(5, opps[4].OpportunityLineItems.size());
        System.assertEquals(6, opps[5].OpportunityLineItems.size());
        System.assertEquals(7, opps[6].OpportunityLineItems.size());
        System.assertEquals(8, opps[7].OpportunityLineItems.size());
        System.assertEquals(9, opps[8].OpportunityLineItems.size());
        System.assertEquals(10, opps[9].OpportunityLineItems.size());
    }

    @IsTest
    private static void testDerivedUnitOfWork_CommitSuccess() {
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS);
        for (Integer o = 0; o < 10; o++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'UoW Test Name ' + o;
            opp.StageName = 'Open';
            opp.CloseDate = System.today();
            uow.registerNew(new List<SObject>{
                    opp
            });
            for (Integer i = 0; i < o + 1; i++) {
                Product2 product = new Product2();
                product.Name = opp.Name + ' : Product : ' + i;
                uow.registerNew(new List<SObject>{
                        product
                });
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = 10;
                pbe.IsActive = true;
                pbe.UseStandardPrice = false;
                pbe.Pricebook2Id = Test.getStandardPricebookId();
                uow.registerNew(pbe, PricebookEntry.Product2Id, product);
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.Quantity = 1;
                oppLineItem.TotalPrice = 10;
                uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
                uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
            }
        }
        uow.commitWork();

        assertResults('UoW');

        assertEvents(new List<String>{
                'onCommitWorkStarting'
                , 'onPublishBeforeEventsStarting'
                , 'onPublishBeforeEventsFinished'
                , 'onDMLStarting'
                , 'onDMLFinished'
                , 'onDoWorkStarting'
                , 'onDoWorkFinished'
                , 'onCommitWorkFinishing'
                , 'onPublishAfterSuccessEventsStarting'
                , 'onPublishAfterSuccessEventsFinished'
                , 'onCommitWorkFinished - true'
        }
                , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    private static void testDerivedUnitOfWork_CommitDMLFail() {
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS);
        Opportunity opp = new Opportunity();
        uow.registerNew(new List<SObject>{
                opp
        });
        Boolean didFail = false;
        System.DmlException caughtEx = null;

        try {
            uow.commitWork();
        } catch (System.DmlException dmlex) {
            didFail = true;
            caughtEx = dmlex;
        }

        System.assertEquals(didFail, true, 'didFail');
        System.assert(caughtEx.getMessage().contains('REQUIRED_FIELD_MISSING'), String.format('Exception message was ', new List<String>{
                caughtEx.getMessage()
        }));

        assertEvents(new List<String>{
                'onCommitWorkStarting'
                , 'onPublishBeforeEventsStarting'
                , 'onPublishBeforeEventsFinished'
                , 'onDMLStarting'
                , 'onPublishAfterFailureEventsStarting'
                , 'onPublishAfterFailureEventsFinished'
                , 'onCommitWorkFinished - false'
        }
                , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    @IsTest
    private static void testDerivedUnitOfWork_CommitDoWorkFail() {
        DerivedUnitOfWork uow = new DerivedUnitOfWork(MY_SOBJECTS);
        Opportunity opp = new Opportunity();
        opp.Name = 'UoW Test Name 1';
        opp.StageName = 'Open';
        opp.CloseDate = System.today();
        uow.registerNew(new List<SObject>{
                opp
        });

        FailDoingWork fdw = new FailDoingWork();
        uow.registerWork(fdw);

        Boolean didFail = false;
        jam.ProcessException caughtEx = null;

        try {
            uow.commitWork();
        } catch (jam.ProcessException fdwe) {
            didFail = true;
            caughtEx = fdwe;
        }

        System.assertEquals(didFail, true, 'didFail');
        System.assert(caughtEx.getMessage().contains('Work failed.'), String.format('Exception message was ', new List<String>{
                caughtEx.getMessage()
        }));

        assertEvents(new List<String>{
                'onCommitWorkStarting'
                , 'onPublishBeforeEventsStarting'
                , 'onPublishBeforeEventsFinished'
                , 'onDMLStarting'
                , 'onDMLFinished'
                , 'onDoWorkStarting'
                , 'onPublishAfterFailureEventsStarting'
                , 'onPublishAfterFailureEventsFinished'
                , 'onCommitWorkFinished - false'
        }
                , uow.getCommitWorkEventsFired(), new Set<Schema.SObjectType>(MY_SOBJECTS), uow.getRegisteredTypes());
    }

    @IsTest
    private static void testRegisterDirty_ExpectReplacement() {
        final Opportunity insertedOpp = new Opportunity(Name = 'Original', StageName = 'Open', CloseDate = System.today());
        insert insertedOpp;

        Opportunity opp = new Opportunity(Id = insertedOpp.Id, Name = 'Never');
        Opportunity opp2 = new Opportunity(Id = insertedOpp.Id, Name = 'Expected');

        jam.UnitOfWork uow = new jam.UnitOfWork(MY_SOBJECTS);
        uow.registerDirty(opp);
        uow.registerDirty(opp2);
        uow.commitWork();

        Opportunity updated = [SELECT Id, Name FROM Opportunity WHERE Id = :insertedOpp.Id];
        System.assertEquals('Expected', updated.Name);
    }

    @IsTest
    private static void testRegisterDirty_field() {
        Opportunity opp = new Opportunity(Name = 'test name', StageName = 'Open', CloseDate = System.today());
        insert opp;

        Opportunity nameUpdate = new Opportunity(Id = opp.Id, Name = 'UpdateName');
        Opportunity amountUpdate = new Opportunity(Id = opp.Id, Amount = 250);
        jam.UnitOfWork uow = new jam.UnitOfWork(MY_SOBJECTS);
        uow.registerDirty(nameUpdate);
        uow.registerDirty(amountUpdate, new List<SObjectField>{
                Opportunity.Amount
        });
        uow.commitWork();

        opp = [SELECT Name, Amount FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(opp.Name, nameUpdate.Name);
        System.assertEquals(opp.Amount, amountUpdate.Amount);
    }

    private static void assertEvents(List<String> expectedEvents, List<String> actualEvents, Set<Schema.SObjectType> expectedTypes, Set<Schema.SObjectType> actualTypes) {
        System.assertEquals(expectedEvents.size(), actualEvents.size(), 'events size');
        for (Integer i = 0; i < expectedEvents.size(); i++) {
            System.assertEquals(expectedEvents[i], actualEvents[i], String.format('Event {0} was not fired in order expected.', new List<String>{
                    expectedEvents[i]
            }));
        }

        System.assertEquals(expectedTypes.size(), actualTypes.size(), 'types size');
        for (Schema.SObjectType sObjectType : expectedTypes) {
            System.assertEquals(true, actualTypes.contains(sObjectType), String.format('Type {0} was not registered.', new List<String>{
                    sObjectType.getDescribe().getName()
            }));
        }
    }

    private class FailDoingWork implements jam.IDoWork {
        public void doWork() {
            throw new jam.ProcessException('Work failed.');
        }
    }

    private class DerivedUnitOfWork extends jam.UnitOfWork {
        private List<String> m_commitWorkEventsFired = new List<String>();
        private Set<Schema.SObjectType> m_registeredTypes = new Set<Schema.SObjectType>();

        public List<String> getCommitWorkEventsFired() {
            return m_commitWorkEventsFired.clone();
        }

        public Set<Schema.SObjectType> getRegisteredTypes() {
            return m_registeredTypes.clone();
        }

        public DerivedUnitOfWork(List<Schema.SObjectType> sObjectTypes) {
            super(sObjectTypes);
        }

        public DerivedUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml) {
            super(sObjectTypes, dml);
        }

        private void addEvent(String event) {
            for (String eventName : m_commitWorkEventsFired) {
                if (event == eventName) {
                    throw new jam.ProcessException(String.format('Event {0} has already been fired.', new List<String>{
                            event
                    }));
                }
            }
            m_commitWorkEventsFired.add(event);
        }

        public override void onRegisterType(Schema.SObjectType sObjectType) {
            if (m_registeredTypes.contains(sObjectType)) {
                throw new jam.ProcessException(String.format('Type {0} has already been registered.', new List<String>{
                        sObjectType.getDescribe().getName()
                }));
            }
            m_registeredTypes.add(sObjectType);
        }

        public override void onCommitWorkStarting() {
            addEvent('onCommitWorkStarting');
        }

        public override void onPublishBeforeEventsStarting() {
            addEvent('onPublishBeforeEventsStarting');
        }

        public override void onPublishBeforeEventsFinished() {
            addEvent('onPublishBeforeEventsFinished');
        }

        public override void onDMLStarting() {
            addEvent('onDMLStarting');
        }

        public override void onDMLFinished() {
            addEvent('onDMLFinished');
        }

        public override void onDoWorkStarting() {
            addEvent('onDoWorkStarting');
        }

        public override void onDoWorkFinished() {
            addEvent('onDoWorkFinished');
        }

        public override void onCommitWorkFinishing() {
            addEvent('onCommitWorkFinishing');
        }

        public override void onPublishAfterSuccessEventsStarting() {
            addEvent('onPublishAfterSuccessEventsStarting');
        }

        public override void onPublishAfterSuccessEventsFinished() {
            addEvent('onPublishAfterSuccessEventsFinished');
        }

        public override void onPublishAfterFailureEventsStarting() {
            addEvent('onPublishAfterFailureEventsStarting');
        }

        public override void onPublishAfterFailureEventsFinished() {
            addEvent('onPublishAfterFailureEventsFinished');
        }

        public override void onCommitWorkFinished(Boolean wasSuccessful) {
            addEvent('onCommitWorkFinished - ' + wasSuccessful);
        }
    }

    private class Mock_SendEmailWork implements jam.IEmailWork {
        public Mock_SendEmailWork() {
        }

        public void registerEmail(Messaging.Email email) {
        }

        public void doWork() {
            doWorkWasCalled = true;
        }

        private Boolean doWorkWasCalled = false;
    }

    //DML
    private static User createRestrictedUser() {
        // PMGR-9655 - Starting with Spring '21, the "Read Only" profile may not exist. We should default to using the
        // new "Minimum Access - Salesforce" profile, falling back to "Read Only" otherwise.
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name IN ('Minimum Access - Salesforce', 'Read Only') ORDER BY Name];
        System.assert(
                profileList.size() >= 1,
                'Unable to create a "restricted" User for testing purposes because we are not able to find the required User Profiles.'
        );
        User restrictedUser = new User(
                Alias = 'standt',
                Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                // Use the first Profile in the list. Because we've ordered by name, this causes us to use
                // "Minimum Access - Salesforce" if it's present.
                ProfileId = profileList[0].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = '' + Datetime.now().getTime() + 'crudmanageruser1@testorg.com'
        );
        insert restrictedUser;

        // Create a Permission Set that grants "Read" access to Account, Contact and Opportunity
        PermissionSet ps = new PermissionSet(Label = 'Restricted User', Name = 'RestrictedUser');
        insert ps;

        List<ObjectPermissions> objectPerms = new List<ObjectPermissions>();
        objectPerms.add(createObjectPerms(ps.Id, 'Account', true, false, false, false));
        objectPerms.add(createObjectPerms(ps.Id, 'Contact', true, false, false, false));
        objectPerms.add(createObjectPerms(ps.Id, 'Opportunity', true, false, false, false));
        insert objectPerms;

        // Assign this perm set to our restricted user
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = restrictedUser.Id, PermissionSetId = ps.Id);
        insert psa;

        return restrictedUser;
    }

    private static ObjectPermissions createObjectPerms(
            Id parentId, String objectType, Boolean canRead, Boolean canCreate, Boolean canEdit, Boolean canDelete
    ) {
        return new ObjectPermissions(
                ParentId = parentId,
                SobjectType = objectType,
                PermissionsRead = canRead,
                PermissionsCreate = canCreate,
                PermissionsEdit = canEdit,
                PermissionsDelete = canDelete
        );
    }

    @IsTest
    private static void systemInsert() {
        Opportunity o1 = new Opportunity(Name = 'Original1 Opp', StageName = 'Won', CloseDate = Date.today());

        User restrictedUser = createRestrictedUser();

        Boolean isExceptionThrown = false;
        try {
            System.runAs(restrictedUser) {
                jam.sObjects.insertAsSystem(new Opportunity[]{
                        o1
                });
            }
        } catch (Exception e) {
            isExceptionThrown = true;
        } finally {
            System.assertEquals(false, isExceptionThrown, 'System mode should perform DML regardless of access');
        }
    }

    @IsTest
    private static void flsRestrictedInsert() {
        Campaign c1 = new Campaign(Name = 'Test1 Campaign');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new Campaign[]{
                    c1
            };
        }

        Opportunity o1 = new Opportunity(Name = 'Original1 Opp', CampaignId = c1.Id, StageName = 'Won', CloseDate = Date.today());

        User restrictedUser = createRestrictedUser();

        // Grant "Create" perm, in addition to "Read"
        assignObjectPermission(restrictedUser, 'Opportunity', true, false, false);

        System.runAs(restrictedUser) {
            try {
                jam.sObjects.insertAsUser(new Opportunity[]{
                        o1
                });
                System.assert(false, 'Expected a DML Error! Restricted User shouldn\'t be able to insert Opportunity.CampaignId');
            } catch (jam.ProcessException flse) {
                System.assert(String.isNotBlank(flse.getMessage()));
            }
        }

    }

    @IsTest
    private static void flsUnrestrictedUpsert() {
        Campaign c1 = new Campaign(Name = 'Test1 Campaign');
        Campaign c2 = new Campaign(Name = 'Test2 Campaign');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new Campaign[]{
                    c1, c2
            };
        }

        Opportunity o1 = new Opportunity(Name = 'Original1 Opp', CampaignId = c1.Id, StageName = 'Won', CloseDate = Date.today());
        jam.sObjects.upsertAsUser(new Opportunity[]{
                o1
        });
        System.assert(o1.Id != null);

        o1.Name = 'Updated1 Opp';
        o1.CampaignId = c2.Id;

        Opportunity o2 = new Opportunity(Name = 'Test2 Opp', CampaignId = c2.Id, StageName = 'Won', CloseDate = Date.today());

        jam.sObjects.upsertAsUser(new Opportunity[]{
                o1, o2
        });

        List<Opportunity> reload = [SELECT Id, Name, CampaignId FROM Opportunity ORDER BY Id];
        System.assertEquals(reload.size(), 2);
        System.assertEquals('Updated1 Opp', reload[0].Name);
        System.assertEquals(c2.Id, reload[0].CampaignId);
        System.assertEquals('Test2 Opp', reload[1].Name);
        System.assertEquals(c2.Id, reload[1].CampaignId);
        System.assert(reload[1].Id != null);
    }

    @IsTest
    private static void crudUnrestrictedInsertUpdateDelete() {
        Campaign c1 = new Campaign(Name = 'Test1 Campaign');
        jam.sObjects.insertAsUser(c1);

        //Would blow up if the Campaign wasn't inserted (List has no rows for assignment)
        Campaign c1Reload = [SELECT Id, Name, StartDate FROM Campaign WHERE Id = :c1.Id];
        System.assert(c1Reload.StartDate == null);

        c1Reload.StartDate = Date.today();

        jam.sObjects.updateAsUser(c1Reload);

        c1Reload = [SELECT Id, Name, StartDate FROM Campaign WHERE Id = :c1.Id];
        System.assertEquals(Date.today(), c1Reload.StartDate);

        jam.sObjects.deleteAsUser(c1Reload);

        List<Campaign> reloaded = [SELECT Id, Name FROM Campaign];
        System.assertEquals(0, reloaded.size());
    }

    @IsTest
    private static void crudRestrictedInsertUpdateDelete() {
        User restrictedUser = createRestrictedUser();

        Campaign c1 = new Campaign(Name = 'Test1 Campaign');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert c1;
        }

        System.runAs(restrictedUser) {
            // First try to insert a new object (including field two)
            try {
                Campaign c2 = new Campaign(Name = 'Test2  Campaign');
                jam.sObjects.insertAsUser(c2);
                System.assert(false, 'Expected a DML Error!, Restricted User shouldn\'t be able to insert a Campaign');
            } catch (jam.ProcessException crude) {
                System.assert(String.isNotBlank(crude.getMessage()));
            }

            // Second, try to update the already inserted (previously) object, including field two
            try {
                c1.Name = 'Updated1 Campaign';
                jam.sObjects.updateAsUser(c1);
                System.assert(false, 'Expected a DML Error!, Restricted User shouldn\'t be able to update a Campaign');
            } catch (jam.ProcessException crude) {
                System.assert(String.isNotBlank(crude.getMessage()));
            }

            try {
                jam.sObjects.deleteAsUser(c1);
                System.assert(false, 'Expected a DML Error!, Restricted User shouldn\'t be able to delete a Campaign');
            } catch (jam.ProcessException crude) {
                //expected
                System.assert(String.isNotBlank(crude.getMessage()));
            }
        }
    }

    @IsTest
    private static void testFailedUpdateWithErroneousId() {
        Campaign c1 = new Campaign(Name = 'Test1 Campaign');
        Id cId = null;

        insert new SObject[]{
                c1
        };
        cId = c1.Id;
        delete c1;

        try {
            Campaign c1Resurrected = new Campaign(Id = cId, Name = 'Resurrected Campaign');
            jam.sObjects.upsertAsUser(c1Resurrected);
            System.assert(false, 'Expected an ProcessException! Attempting to update a record with an erroneous Id should fail');
        } catch (jam.ProcessException dmle) {
            //expected
            System.assert(dmle.getMessage().contains('An existing record could not be found'));
        }
    }

    private static void assignObjectPermission(User u, String objectType, Boolean create, Boolean edit, Boolean remove) {
        PermissionSet ps = new PermissionSet(Name = 'Enable' + objectType, Label = 'Enable ' + objectType);
        insert ps;

        ObjectPermissions oPerm = new ObjectPermissions(ParentId = ps.Id,
                PermissionsRead = true,
                PermissionsCreate = create,
                PermissionsEdit = edit,
                PermissionsDelete = remove,
                SobjectType = objectType);

        insert oPerm;

        PermissionSetAssignment assign = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        insert assign;
    }

    /*
    * Mocks the HTTP callout
    * Usage example
    * new jamTest.HttpMock()
    * .add('GET', 'https://test.com', 200, new Map<String, Object>{'test': 'test'})
    * .add('GET', 'https://test.com', 200, 'test response')
    * .add('https://test.com', new Map<String, Object>{'test': 'test'})
    * .add('https://test.com', 'test response')
    * .setMock();
     */
    public class HttpMock implements HttpCalloutMock {

        private final Map<String, String> endpointResponseMap = new Map<String, String>();

        public HttpResponse respond(HttpRequest req) {
            String endpoint = req.getEndpoint();
            String method = req.getMethod();
            String mockData = endpointResponseMap.get(method + '|' + endpoint.substringBefore('?'));

            jam.objects.throwIfBlank(mockData, 'No Mock endpoint: ' + req.getEndpoint());
            List<String> mockParts = mockData.split('\\|');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(Integer.valueOf(mockParts[0]));
            res.setBody(mockParts[1]);
            return res;
        }

        public HttpMock add(String method, String endpoint, Integer code, String response) {
            endpointResponseMap.put(method + '|' + endpoint, code + '|' + response);
            return this;
        }

        public HttpMock add(String method, String endpoint, Integer code, Map<String, Object> responseMap) {
            return add(method, endpoint, code, JSON.serialize(responseMap));
        }

        public HttpMock add(String endpoint, Map<String, Object> responseMap) {
            return add('GET', endpoint, 200, responseMap);
        }

        public HttpMock add(String endpoint, String response) {
            return add('GET', endpoint, 200, response);
        }

        public HttpMock setMock() {
            Test.setMock(HttpCalloutMock.class, this);
            return this;
        }
    }
}