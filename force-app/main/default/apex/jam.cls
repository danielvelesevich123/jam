global inherited sharing class jam implements Callable  {

    global Object call(String action, Map<String, Object> dtoMap) {
        jam.objects.throwIfBlank(action, 'Action is required');
        return jam.objects.getAction(action).run(dtoMap).getMap();
    }

    @AuraEnabled
    global static String runAction(String action, String requestJSON) {
        try {
            return jam.run(action, requestJSON).getJSON();
        } catch (Exception ex) {
            return new jam.Response(ex).getJSON();
        }
    }

    @RemoteAction
    global static String runAction(String requestJSON) {
        try {
            Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);

            if (request.containsKey('action') && request.containsKey('dto')) {
                return runAction((String) request.get('action'), JSON.serialize(request.get('dto')));
            }

            return new jam.Response('Invalid request attributes.').getJSON();
        } catch (Exception ex) {
            return new jam.Response(ex).getJSON();
        }
    }

    public static jam.Response run(String action, String requestJSON) {
        Savepoint savepoint;

        try {
            jam.Action actionVar = jam.objects.getAction(action);
            jam.DTO requestVar = actionVar.initRequest(requestJSON);

            Boolean doesPerformCallout = actionVar instanceof Database.AllowsCallouts;

            if (doesPerformCallout != true) {
                savepoint = Database.setSavepoint();
            }

            return new jam.Response(actionVar.run(requestVar));
        } catch (Exception ex) {
            if (savepoint != null) {
                Database.rollback(savepoint);
            }
            throw ex;
        }
    }

    public abstract class Action {
        protected DTO request;
        protected jam.Response response = new jam.Response(new Map<String, Object>());

        public virtual jam.Response run(Map<String, Object> requestMap) {
            return this.run(this.initRequest(requestMap));
        }

        public virtual jam.Response run(String requestJSON) {
            return this.run(this.initRequest(requestJSON));
        }

        public virtual jam.Response run(DTO request) {
            this.request = request;
//            this.initSelectOptions();
            this.run();
            return this.response;
        }

        public abstract void run();

        public virtual DTO initRequest(String requestJSON) {
            return this.initRequest((Map<String, Object>) JSON.deserializeUntyped(requestJSON));
        }

        public virtual DTO initRequest(Map<String, Object> requestMap) {
            return new DTO(requestMap);
        }

        //GETTER ALIASES
        public Object get(String path) {
            return this.request == null ? null : this.request.get(path);
        }

        public String getString(String path) {
            return this.request == null ? null : this.request.getString(path);
        }

        public String getRequiredString(String path) {
            return this.request == null ? null : this.request.getRequiredString(path);
        }

        public String getRequiredString(String path, String errorMessage) {
            return this.request == null ? null : this.request.getRequiredString(path, errorMessage);
        }

        public Integer getInteger(String path) {
            return this.request == null ? null : this.request.getInteger(path);
        }

        public Long getLong(String path) {
            return this.request == null ? null : this.request.getLong(path);
        }

        public Decimal getDecimal(String path) {
            return this.request == null ? null : this.request.getDecimal(path);
        }

        public Boolean getBoolean(String path) {
            return this.request == null ? false : this.request.getBoolean(path);
        }

        public Date getDate(String path) {
            return this.request == null ? null : this.request.getDate(path);
        }

        public Time getTime(String path) {
            return this.request == null ? null : this.request.getTime(path);
        }

        public Datetime getDatetime(String path) {
            return this.request == null ? null : this.request.getDatetime(path);
        }

        public SObject getSObject(String path, SObjectType sObjectTypeVar) {
            return this.request == null ? null : this.request.getSObject(path, sObjectTypeVar);
        }

        public jam.Action getSObject(String path, SObject sObj) {
            if (this.request != null) {
                this.request.getSObject(path, sObj);
            }

            return this;
        }

        public jam.Action getSObject(String path, SObject sObj, Boolean skipValidation) {
            if (this.request != null) {
                this.request.getSObject(path, sObj, skipValidation);
            }

            return this;
        }

        public List<Object> getObjects(String path) {
            return this.request == null ? null : this.request.getObjects(path);
        }

        public List<String> getStrings(String path) {
            return this.request == null ? null : this.request.getStrings(path);
        }

        public List<Map<String, Object>> getMaps(String path) {
            return this.request == null ? null : this.request.getMaps(path);
        }

        public List<DTO> getDTOs(String path) {
            return this.request == null ? null : this.request.getDTOs(path);
        }

        public List<SObject> getSObjects(String path, SObjectType sObjectTypeVar) {
            return this.request == null ? null : this.request.getSObjects(path, sObjectTypeVar);
        }

        public List<SObject> getSObjects(String path, SObjectType sObjectTypeVar, Boolean skipValidation) {
            return this.request == null ? null : this.request.getSObjects(path, sObjectTypeVar, skipValidation);
        }


        //SETTER ALIASES
        public jam.Action put(String path, Object value) {
            this.response.put(path, value);
            return this;
        }

        public jam.Action put(String path, Object value, Boolean mapSobjects) {
            this.response.put(path, value, mapSobjects);
            return this;
        }

        public jam.Action put(String path, Object value, Integer recordsLimit) {
            this.response.put(path, value, recordsLimit);
            return this;
        }

        public jam.Action put(String path, Object value, Boolean mapSobjects, Integer recordsLimit) {
            this.response.put(path, value, mapSobjects, recordsLimit);
            return this;
        }

        public jam.Action put(Map<String, Object> mapVar) {
            this.response.put(mapVar);
            return this;
        }

        public jam.Action put(Map<String, Object> mapVar, Boolean mapSobjects) {
            this.response.put(mapVar, mapSobjects);
            return this;
        }

        public jam.Action put(Map<String, Object> mapVar, Integer recordsLimit) {
            this.response.put(mapVar, recordsLimit);
            return this;
        }

        public jam.Action put(Map<String, Object> mapVar, Boolean mapSobjects, Integer recordsLimit) {
            this.response.put(mapVar, mapSobjects, recordsLimit);
            return this;
        }
    }

    global virtual class DTO {
        public Map<String, Object> dto = new Map<String, Object>();
        public Boolean isVisualforce = false;
        public Boolean isAllFields = false;
        public Object defaultFieldValue = '';

        //CONSTRUCTORS
        global DTO() {
        }

        global DTO(String requestJSON) {
            this.dto = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);
        }

        global DTO(Map<String, Object> requestMap) {
            this.dto = requestMap == null ? this.dto : requestMap;
        }

        global DTO(String path, String arrayJSON) {
            Object arrayObject = JSON.deserializeUntyped(arrayJSON);
            jam.objects.setMapValue(this.dto, path, arrayObject);
        }

        global DTO setIsVisualforce(Boolean value) {
            this.isVisualforce = value == true;
            return this;
        }

        global DTO setIsAllFields(Boolean value) {
            this.isAllFields = value == true;
            return this;
        }

        global DTO setDefaultFieldValue(Object value) {
            this.defaultFieldValue = value;
            return this;
        }

        //GETTERS
        global Object get(String path) {
            return jam.objects.getMapValue(this.dto, path);
        }

        global String getString(String path) {
            Object val = jam.objects.getMapValue(this.dto, path);
            return val == null ? null : String.valueOf(val);
        }

        global String getRequiredString(String path) {
            return this.getRequiredString(path, 'The following parameter is missing in the dto: ' + path);
        }

        global String getRequiredString(String path, String errorMessage) {
            String val = this.getString(path);
            jam.objects.throwIfBlank(val, errorMessage);
            return val;
        }

        global Integer getInteger(String path) {
            Object val = jam.objects.getMapValue(this.dto, path);
            return val == null ? null : Integer.valueOf(val);
        }

        global Long getLong(String path) {
            Object val = jam.objects.getMapValue(this.dto, path);
            return val == null ? null : (val instanceof String ? Long.valueOf((String) val) : (Long) val);
        }

        global Decimal getDecimal(String path) {
            return jam.objects.parseDecimal(jam.objects.getMapValue(this.dto, path));
        }

        global Boolean getBoolean(String path) {
            Object val = jam.objects.getMapValue(this.dto, path);
            if (val == null) {
                return false;
            }
            if (val instanceof Boolean) {
                return (Boolean) val;
            }
            return Boolean.valueOf(val);
        }

        global Date getDate(String path) {
            String dateStr = this.getString(path);
            return String.isBlank(dateStr) ? null : Date.valueOf(dateStr);
        }

        global Time getTime(String path) {
            String timeStr = this.getString(path);
            if (String.isBlank(timeStr)) {
                return null;
            }
            return jam.dates.timeStringToTime(timeStr);
        }

        global Datetime getDatetime(String path) {
            String datetimeStr = this.getString(path);
            return datetimeStr == null ? null : jam.dates.datetimeStringToDatetime(datetimeStr);
        }

        global SObject getSObject(String path, SObjectType sObjectTypeVar) {
            SObject sObj = sObjectTypeVar.newSObject();
            getSObject(path, sObj, false);
            return sObj;
        }

        global DTO getSObject(String path, SObject sObj) {
            return getSObject(path, sObj, false);
        }

        global DTO getSObject(String path, SObject sObj, Boolean skipValidation) {
            if (path == null || sObj == null) {
                return null;
            }

            Object value;
            if (String.isNotBlank(path)) {
                value = jam.objects.getMapValue(this.dto, path);
            } else {
                value = this.dto;
            }

            if (value != null) {
                Map<String, Object> dataMap = (Map<String, Object>) value;
                jam.sObjects.mapToSObject(sObj, dataMap, skipValidation, this.isVisualforce);
            }

            return this;
        }

        global List<Object> getObjects(String path) {
            return (List<Object>) jam.objects.getMapValue(this.dto, path);
        }

        global List<String> getStrings(String path) {
            List<String> strings = new List<String>();

            List<Object> objects = (List<Object>) jam.objects.getMapValue(this.dto, path);

            if (objects == null) {
                return null;
            }

            for (Object obj : objects) {
                strings.add(obj == null ? null : obj.toString());
            }

            return strings;
        }

        global List<Map<String, Object>> getMaps(String path) {
            List<Map<String, Object>> returnList = new List<Map<String, Object>>();

            List<Object> objects = getObjects(path);
            if (objects == null) {
                return null;
            }

            for (Object obj : objects) {
                returnList.add((Map<String, Object>) obj);
            }

            return returnList;
        }

        global List<DTO> getDTOs(String path) {
            List<Map<String, Object>> maps = getMaps(path);

            if (maps == null) {
                return new List<DTO>();
            }

            List<DTO> returnList = new List<DTO>();

            for (Map<String, Object> mapVar : maps) {
                returnList.add(new DTO(mapVar));
            }

            return returnList;
        }

        global List<SObject> getSObjects(String path, SObjectType sObjectTypeVar) {
            return getSObjects(path, sObjectTypeVar, false);
        }

        global List<SObject> getSObjects(String path, SObjectType sObjectTypeVar, Boolean skipValidation) {

            List<Object> values = (List<Object>) jam.objects.getMapValue(this.dto, path);

            if (values == null) {
                return null;
            }

            List<SObject> sObjects = new List<SObject>();

            for (Object value : values) {
                SObject sObj = sObjectTypeVar.newSObject();
                Map<String, Object> dataMap = (Map<String, Object>) value;
                sObjects.add(jam.sObjects.mapToSObject(sObj, dataMap, skipValidation, this.isVisualforce));
            }

            return sObjects;
        }

        //SETTERS
        global DTO put(Map<String, Object> mapVar) {
            return this.put(mapVar, true);
        }

        global DTO put(Map<String, Object> mapVar, Integer recordsLimit) {
            return this.put(mapVar, true, recordsLimit);
        }

        global DTO put(Map<String, Object> mapVar, Boolean mapSObjects) {
            return this.put(mapVar, mapSObjects, null);
        }

        public DTO put(Map<String, Object> mapVar, Boolean mapSObjects, Integer recordsLimit) {
            for (String path : mapVar.keySet()) {
                this.put(path, mapVar.get(path), mapSObjects, recordsLimit);
            }
            return this;
        }

        global DTO put(String path, Object value) {
            return this.put(path, value, true);
        }

        global DTO put(String path, Object value, Integer recordsLimit) {
            return this.put(path, value, true, recordsLimit);
        }

        global DTO put(String path, Object value, Boolean mapSObjects) {
            return this.put(path, value, mapSObjects, null);
        }

        global DTO put(String path, Object value, Boolean mapSObjects, Integer recordsLimit) {
            if (value != null) {
                if (value instanceof List<Object>) {
                    List<Object> resultValueArray = (List<Object>) (value instanceof List<SObject> && mapSObjects ? jam.sObjects.sObjectsToMaps((List<SObject>) value, this.defaultFieldValue, this.isAllFields, this.isVisualforce) : value);
                    value = resultValueArray;

                    if (recordsLimit != null) {
                        Boolean hasMore = resultValueArray.size() > recordsLimit;
                        while (resultValueArray.size() > recordsLimit) {
                            resultValueArray.remove(resultValueArray.size() - 1);
                        }

                        String hasMorePath = path + '.hasMore';
                        String limitPath = path + '.limit';
                        String countPath = path + '.count';

                        this.put(hasMorePath, hasMore);
                        this.put(limitPath, recordsLimit);
                        this.put(countPath, resultValueArray.size());

                        path += '.records';
                    }
                } else if (value instanceof SObject && mapSObjects) {
                    value = jam.sObjects.sObjectToMap((SObject) value, this.defaultFieldValue, this.isAllFields, this.isVisualforce);
                }
            }

            jam.objects.setMapValue(this.dto, path, value);
            return this;
        }
    }

    public inherited sharing virtual class Response extends jam.DTO {

        public Boolean isValid = true;
        public jam.ErrorDetails error;
        public List<jam.ErrorDetails> errors = new List<jam.ErrorDetails>();

        public Response(Map<String, Object> requestMap) {
            super(requestMap);
        }

        public Response(jam.DTO requestDTO) {
            super(requestDTO.dto);
        }

        public Response(Exception ex) {
            this.isValid = (ex == null);

            if (ex != null) {
                this.error = new jam.ExceptionDetails(ex);
                this.errors.add(this.error);
            }
        }

        public Response(List<String> messages) {
            this(String.join(messages, ', '));

            this.errors = new List<jam.ErrorDetails>();
            for (String message : messages) {
                this.errors.add(new jam.ErrorDetails(message));
            }
        }

        public Response(String message) {
            this.setError(message);
        }

        public void setError(String message) {
            this.isValid = (String.isBlank(message));

            if (String.isNotBlank(message)) {
                this.error = new jam.ErrorDetails(message);
                this.errors.add(this.error);
            }
        }

        public String getJSON() {
            return JSON.serialize(this.getMap());
        }

        public Map<String, Object> getMap() {
            return new Map<String, Object>{
                    'dto' => this.dto,
                    'isValid' => this.isValid,
                    'error' => this.error,
                    'errors' => this.errors
            };
        }
    }

    //STRUCTURES
    public inherited sharing virtual class SelectOption {

        public Object value;
        public String label;

        public SelectOption() {
        }

        public SelectOption(Object value, String label) {
            this.value = value;
            this.label = label;
        }

        public SelectOption(String value) {
            this(value, value);
        }
    }

    public inherited sharing virtual class ErrorDetails {
        public String message { get; set; }

        public ErrorDetails(String message) {
            this.message = message;
        }
    }

    public inherited sharing class ExceptionDetails extends ErrorDetails {
        public Integer lineNumber { get; set; }
        public String stackTraceString { get; set; }
        public String typeName { get; set; }

        public ExceptionDetails(Exception ex) {
            super(ex.getMessage());
            this.lineNumber = ex.getLineNumber();
            this.stackTraceString = ex.getStackTraceString();
            this.typeName = ex.getTypeName();
        }
    }

    public abstract class Expression {
        public String source;
        public List<String> params = new List<String>();

        public Expression(String source) {
            this.source = source;
            this.parseSource();
        }

        protected abstract void parseSource();
        protected abstract String getValue(DTO dtoVar);

        public virtual String apply(DTO dtoVar, String targetStr) {
            String expressionStrToReplace = ('{!' + this.source + '}');
            String escapedExpressionStrToReplace = expressionStrToReplace.replaceAll('\\p{Punct}', '\\\\$0');
            return targetStr.replaceAll(escapedExpressionStrToReplace, this.getValue(dtoVar));
        }
    }

    public virtual class MergeFieldExpression extends Expression {
        public MergeFieldExpression(String source) {
            super(source);
        }

        protected override void parseSource() {
            this.params.add(this.source);
        }

        protected override String getValue(jam.DTO dtoVar) {
            String path = this.params.get(0);
            String value = jam.objects.defaultIfNull(dtoVar.getString(path), '');
            return value;
        }
    }

    private class TPicklistEntry {
        public String label { get; set; }
        public String value { get; set; }
        public String validFor { get; set; }
        public TPicklistEntry() {

        }
    }

    //UTILS
    public inherited sharing class PicklistExtensions {
        public Set<String> getPicklistAsSetStrings(Schema.SObjectField sObjectField) {
            return getPicklistAsSetStrings(sObjectField, null);
        }

        public Set<String> getPicklistAsSetStrings(Schema.SObjectField sObjectField, Set<String> excludingValues) {
            Set<String> picklistValues;

            if (sObjectField.getDescribe().getType() == Schema.DisplayType.MULTIPICKLIST || sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST) {
                picklistValues = new Set<String>();
                List<Schema.PicklistEntry> pickListEntries = sObjectField.getDescribe().getPicklistValues();

                for (Schema.PicklistEntry pickListEntryVar : pickListEntries) {
                    if (excludingValues == null || !excludingValues.contains(pickListEntryVar.getValue())) {
                        picklistValues.add(pickListEntryVar.getValue());
                    }
                }
            }

            return picklistValues;
        }

        public List<jam.SelectOption> getPicklistValuesAsSelectOptions(Schema.SObjectField sObjectField) {
            return getPicklistValuesAsSelectOptions(sObjectField, null);
        }

        public List<jam.SelectOption> getPicklistValuesAsSelectOptions(Schema.SObjectField sObjectField, Set<String> excuding) {
            List<jam.SelectOption> selectOptions = new List<jam.SelectOption>();
            List<Schema.PicklistEntry> pickListEntries = sObjectField.getDescribe().getPicklistValues();

            for (Schema.PicklistEntry pickListEntry : pickListEntries) {
                if (excuding == null || !excuding.contains(pickListEntry.getValue())) {
                    selectOptions.add(new jam.SelectOption(pickListEntry.getValue(), pickListEntry.getLabel()));
                }
            }
            return selectOptions;
        }

        public Map<String, List<jam.SelectOption>> getPicklistOptionsMap(Set<SObjectField> fields) {

            Map<String, List<jam.SelectOption>> result = new Map<String, List<jam.SelectOption>>();

            for (SObjectField field : fields) {
                String key = this.getFieldKey(field);
                result.put(key, this.getPicklistValuesAsSelectOptions(field));
            }

            return result;
        }

        public Map<String, Map<String, List<jam.SelectOption>>> getDependentPicklistOptionsMap(Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType) {

            Map<String, Map<String, List<jam.SelectOption>>> result = new Map<String, Map<String, List<jam.SelectOption>>>();

            for (SObjectType sObjectType : dependentFieldsBySObjectType.keySet()) {
                Map<SObjectField, SObjectField> dependentFields = dependentFieldsBySObjectType.get(sObjectType);
                if (dependentFields != null) {
                    for (SObjectField dependentField : dependentFields.keySet()) {
                        SObjectField controllingField = dependentFields.get(dependentField);

                        String key = this.getFieldKey(dependentField);
                        result.put(key, this.getDependentOptions(sObjectType, controllingField, dependentField));
                    }
                }
            }

            return result;
        }

        private String getFieldKey(SObjectField field) {
            return sObjects.fieldToProperty(field) + 'Options';
        }

        public Map<String, List<jam.SelectOption>> getDependentOptions(Schema.SObjectType pType, Schema.SObjectField controllingField, Schema.SObjectField dependentField) {
            Map<String, List<jam.SelectOption>> mapResults = new Map<String, List<jam.SelectOption>>();

            final String pControllingFieldName = controllingField.getDescribe().getName();
            final String pDependentFieldName = dependentField.getDescribe().getName();

            //verify/get object schema
            if (pType == null) return mapResults;
            Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

            //verify field names
            if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;

            //get the control & dependent values
            List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
            List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

            //clear heap
            objFieldMap = null;

            //initialize results mapping
            for (Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++) {
                mapResults.put(ctrl_ple[pControllingIndex].getValue(), new List<jam.SelectOption>());
            }
            //cater for null and empty
            mapResults.put('', new List<jam.SelectOption>());
            mapResults.put(null, new List<jam.SelectOption>());


            //serialize dep entries
            List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();

            objDS_Entries = (List<TPicklistEntry>) JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);

            List<Integer> validIndexes;
            for (TPicklistEntry objDepPLE : objDS_Entries) {

                validIndexes = cnvBits(objDepPLE.validFor);

                for (Integer validIndex : validIndexes) {
                    mapResults.get(ctrl_ple[validIndex - 1].getValue()).add(new jam.SelectOption(objDepPLE.value, objDepPLE.label));
                }
            }

            //clear heap
            objDS_Entries = null;

            mapResults.remove(null);
            mapResults.remove('');

            return mapResults;
        }

        public void convertFlowPicklistFieldValues(SObject recordVar) {
            Set<SObjectField> picklistFields = jam.sObjects.getFieldsByTypes(recordVar.getSObjectType(), new Set<DisplayType>{
                    DisplayType.PICKLIST
            });
            Map<String, Object> populatedFieldsMap = recordVar.getPopulatedFieldsAsMap();
            for (SObjectField fieldVar : picklistFields) {
                if (!populatedFieldsMap.containsKey('' + fieldVar)) {
                    continue;
                }
                try {
                    Object val = recordVar.get(fieldVar);
                    if (val == null) {
                        continue;
                    }
                    String strVal = '' + val;
                    recordVar.put(fieldVar, strVal);
                } catch (Exception e) {
                }
            }
        }
    }

    public inherited sharing class DateExtensions {

        public Datetime parseDatetimeAnyFormat(String datetimeStr, String format) {
            return this.parseDatetimeAnyFormat(datetimeStr, format, false);
        }

        public Datetime parseDatetimeAnyFormat(String datetimeStr, String format, Boolean isGMT) {
            if (String.isBlank(datetimeStr)) {
                return null;
            }

            Datetime datetimeVar = null;

            try {

                String formatDelimiters = format.replaceAll('DD|dd|d|MM|M|YYYY|yyyy|YY|yy|mm|m|HH|hh|H|h|SS|ss|S|s|A|a', '##');

                Set<String> delimitersSet = new Set<String>(formatDelimiters.split('##'));
                delimitersSet.remove(null);
                delimitersSet.remove('');
                delimitersSet.add(' ');
                List<String> delimiters = new List<String>(delimitersSet);

                String formatPartsStr = format.replaceAll('[[' + String.join(delimiters, ']]|[[') + ']]', '~');

                List<String> formatParts = formatPartsStr.split('~');

                String datetimePartsStr = datetimeStr.replaceAll('[[' + String.join(delimiters, ']]|[[') + ']]', '~');

                List<String> datetimeParts = datetimePartsStr.split('~');

                Datetime now = Datetime.now();
                Integer year = now.year();
                Integer month = now.month();
                Integer day = now.day();
                Integer hour = now.hour();
                Integer minute = now.minute();
                Integer second = now.second();
                String a;

                for (Integer i = 0; i < formatParts.size(); i++) {
                    String formatPart = formatParts[i];
                    String value = datetimeParts[i];

                    if ('yyyy'.equalsIgnoreCase(formatPart)) {
                        year = Integer.valueOf(value);
                    }
                    if ('yy'.equalsIgnoreCase(formatPart)) {
                        year = Integer.valueOf(value) + 2000;
                    }
                    if ('MM'.equals(formatPart) || 'M'.equals(formatPart)) {
                        month = Integer.valueOf(value);
                    }
                    if ('dd'.equalsIgnoreCase(formatPart) || 'd'.equalsIgnoreCase(formatPart)) {
                        day = Integer.valueOf(value);
                    }
                    if ('hh'.equalsIgnoreCase(formatPart) || 'h'.equalsIgnoreCase(formatPart)) {
                        hour = Integer.valueOf(value);
                    }
                    if ('mm'.equals(formatPart) || 'm'.equals(formatPart)) {
                        minute = Integer.valueOf(value);
                    }
                    if ('ss'.equalsIgnoreCase(formatPart) || 's'.equalsIgnoreCase(formatPart)) {
                        second = Integer.valueOf(value);
                    }
                    if ('a'.equalsIgnoreCase(formatPart)) {
                        a = value;
                    }
                }

                if ('AM'.equalsIgnoreCase(a)) {
                    if (hour == 12) {
                        hour = 0;
                    }
                } else if ('PM'.equalsIgnoreCase(a)) {
                    if (hour != 12) {
                        hour = hour + 12;
                    }
                }

                datetimeVar = Datetime.newInstance(year, month, day, hour, minute, second);

                if (isGMT) {
                    datetimeVar = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
                } else {
                    datetimeVar = Datetime.newInstance(year, month, day, hour, minute, second);
                }

            } catch (Exception ex) {
                ex.setMessage('Invalid date: ' + datetimeStr + ': ' + ex.getMessage());
                throw ex;
            }

            return datetimeVar;
        }

        public Datetime parseDatetimeAusFormat(String datetimeStr) {
            return this.parseDatetimeAnyFormat(datetimeStr, 'dd/MM/yyyy hh:mm a');
        }

        public Date parseDateAnyFormat(String dateStr, String format) {
            return datetimeToDate(this.parseDatetimeAnyFormat(dateStr, format));
        }

        public Date parseDateAusFormat(String dateStr) {
            return this.parseDateAnyFormat(dateStr, 'dd/MM/yyyy');
        }

        public Date datetimeToDate(Datetime datetimeVar) {
            return datetimeVar != null ? datetimeVar.date() : null;
        }

        public Datetime dateToDateTime(Date d) {
            return Datetime.newInstance(d.year(), d.month(), d.day(), 0, 0, 0);
        }

        public Integer totalWorkingDays(Date startDate, Date endDate) {

            Datetime sdate = dateToDateTime(startDate);
            Datetime edate = dateToDateTime(endDate);

            Integer i = 0;

            while (sdate <= edate) {
                if (isWorkingDay(sdate) == true) {
                    i = i + 1;
                }
                sdate = sdate.addDays(1);
            }

            return i;

        }

        public Boolean isWorkingDay(Date d) {
            Datetime dt = dateToDateTime(d);
            return isWorkingDay(dt);
        }

        public Boolean isWorkingDay(Datetime dt) {
            return (dt.format('E') != 'Sat' && dt.format('E') != 'Sun');
        }

        public Time timeStringToTime(String t) {
            String[] arr = t.split(':');
            return Time.newInstance(
                    Integer.valueOf(arr[0]),
                    Integer.valueOf(arr[1]),
                    0,
                    0
            );
        }

        public Time timeStringAMPMToTime(String t) {

            if (String.isBlank(t)) {
                throw new jam.MissingDataException('Time Argument is null');
            }

            List<String> timeParts = t.split(' ');
            List<String> hoursMinutes = timeParts.get(0).split(':');

            String amPMStr = timeParts.get(1);
            String hoursStr = hoursMinutes.get(0);
            String minutesStr = hoursMinutes.get(1);

            Integer hours = Integer.valueOf(hoursStr);
            Integer minutes = Integer.valueOf(minutesStr);

            if ('AM'.equals(amPMStr)) {
                if (hours == 12) {
                    hours = 0;
                }
            } else if ('PM'.equals(amPMStr)) {
                if (hours != 12) {
                    hours = hours + 12;
                }
            }

            return Time.newInstance(
                    hours,
                    minutes,
                    0,
                    0
            );
        }

        public Datetime datetimeStringToDatetime(String dt) {
            if (String.isBlank(dt)) {
                throw new jam.MissingDataException('Datetime string argument is null');
            }

            return (Datetime) JSON.deserialize(dt, Datetime.class);
        }


        public Datetime getStartOfDay(Datetime dateTimeVar) {
            return Datetime.newInstance(dateTimeVar.year(), dateTimeVar.month(), dateTimeVar.day(), 0, 0, 0);
        }

        public Datetime getEndOfDay(Datetime dateTimeVar) {
            return Datetime.newInstance(dateTimeVar.year(), dateTimeVar.month(), dateTimeVar.day(), 23, 59, 9);
        }

        public Datetime getStartDateOfWeek(Datetime dateTimeVar) {
            Integer dayOfWeek = Integer.valueOf(dateTimeVar.format('u'));
            Datetime startDateOfWeek = dateTimeVar.addDays(-1 * (dayOfWeek - 1));
            return getStartOfDay(startDateOfWeek);
        }

        public Date getStartDateOfWeek(Date dateVar) {
            return getStartDateOfWeek(dateToDateTime(dateVar)).date();
        }

        public Datetime getEndDateOfWeek(Datetime dateTimeVar) {
            return getEndOfDay(getStartDateOfWeek(dateTimeVar).addDays(6));
        }

        public Date getEndDateOfWeek(Date dateVar) {
            return getEndDateOfWeek(dateToDateTime(dateVar)).date();
        }

        public Boolean isDateInCurrentWeekOrInFuture(Date dateVar) {
            return dateVar >= getStartDateOfWeek(Date.today());
        }

        public Date getLastDayInMonth(Date dateVar) {
            return dateVar.addMonths(1).toStartOfMonth().addDays(-1);
        }

        public Date getLastWorkingDay(Date dateVar) {
            while (!isWorkingDay(dateVar)) {
                dateVar = dateVar.addDays(-1);
            }
            return dateVar;
        }

        public Date getLastDayInFortnight(Date dateVar, Date startDate) {
            if (dateVar < startDate) {
                throw new jam.ProcessException('getLastDayInFortnight error: Date should be greater than Period Start Date');
            }

            Date startOfThePeriod = getStartDateOfWeek(startDate);
            Date endOfThePeriod = startOfThePeriod.addDays(13);

            while (dateVar > endOfThePeriod) {
                endOfThePeriod = endOfThePeriod.addDays(14);
            }

            return endOfThePeriod;
        }

        public Date getFirstDayInFortnight(Date dateVar, Date startDate) {
            Date endOfThePeriod = getLastDayInFortnight(dateVar, startDate);
            return endOfThePeriod.addDays(-13);
        }

        public Date detectDateInRange(Date firstDate, Date secondDate, Date thirdDate) {

            Date dateVar = secondDate > firstDate ? secondDate : firstDate;
            dateVar = thirdDate < firstDate ? thirdDate : firstDate;

            return dateVar;
        }

        public Boolean dateInRange(Date dateVar, Date startOfRange, Date endOfRange, Boolean allowCrossing) {
            return allowCrossing == true ? (dateVar >= startOfRange && dateVar <= endOfRange) : (dateVar > startOfRange && dateVar < endOfRange);
        }

        public Boolean crossingDateRanges(Datetime date1start, Datetime date1end, Datetime date2start, Datetime date2end) {
            return !(date1end <= date2start || date1start >= date2end);
        }

        public Integer age(Date birthDate, Date onDate) {
            Date birthDateOnDate = Date.newInstance(
                    onDate.year(),
                    birthDate.month(),
                    birthDate.day()
            );
            Integer age = onDate.year() - birthDate.year();
            return Math.max(birthDateOnDate > onDate ? age - 1 : age, 0);
        }

        public Integer age(Date birthDate) {
            return age(birthDate, Date.today());
        }

        public Date max(List<Date> dates) {
            Date maxDate;
            for (Date dateVar : dates) {
                if (maxDate == null || dateVar > maxDate) {
                    maxDate = dateVar;
                }
            }
            return maxDate;
        }

        public Date max(Date date1, Date date2) {
            return max(new List<Date>{
                    date1,
                    date2
            });
        }

        public Date min(List<Date> dates) {
            Date minDate;
            for (Date dateVar : dates) {
                if (minDate == null || dateVar < minDate) {
                    minDate = dateVar;
                }
            }
            return minDate;
        }

        public Date min(Date date1, Date date2) {
            return min(new List<Date>{
                    date1,
                    date2
            });
        }
    }

    public inherited sharing class StringExtensions {

        public String emptyStringIfNull(String str) {
            return String.isBlank(str) ? '' : str;
        }

        public String newGuid() {
            return EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        }

        public String newUuid() {
            return UUID.randomUUID().toString();
        }

        public String joinNonBlank(List<String> parts, String separator) {
            List<String> notBlankParts = new List<String>();

            for (String part : parts) {
                if (String.isNotBlank(part)) {
                    notBlankParts.add(part);
                }
            }

            return String.join(notBlankParts, separator);
        }

    }

    public inherited sharing class UserExtensions {
        public Boolean hasPermSetAssigned(String userId, String permSetName) {
            List<String> permSetChunks = permSetName.split('\\.');
            String namespace = permSetChunks.size() > 1 ? permSetChunks[0] : null;
            String name = permSetChunks.size() > 1 ? permSetChunks[1] : permSetChunks[0];

            return [
                    SELECT COUNT()
                    FROM PermissionSetAssignment
                    WHERE AssigneeId = :userId
                    AND PermissionSet.Name = :name
                    AND PermissionSet.NamespacePrefix = :namespace
                    WITH USER_MODE
            ] > 0;
        }

        public Boolean hasPermSetAssigned(String permSetName) {
            return hasPermSetAssigned(UserInfo.getUserId(), permSetName);
        }

        public void assertPermSet(String permSetName, String errorMessage) {
            if (!hasPermSetAssigned(permSetName)) {
                throw new jam.ProcessException(errorMessage);
            }
        }
    }

    public inherited sharing class SObjectExtensions {

        public void assertReadable(List<SObject> records) {
            assertAccessType(records, AccessType.READABLE);
        }

        public void assertReadable(SObject record) {
            assertReadable(new List<SObject>{
                    record
            });
        }

        public void assertAccessType(List<SObject> records, AccessType accessType) {
            if (records.isEmpty()) {
                return;
            }
            SObjectType sObjTypeVar = records.get(0).getSObjectType();
            try {
                SObjectAccessDecision decision = Security.stripInaccessible(
                        accessType,
                        records
                );
                records = decision.getRecords();
            } catch (System.NoAccessException ex) {
                throw new jam.ProcessException('No ' + accessType + ' Access to entity of type: ' + sObjTypeVar);
            }
        }

        public Set<Id> getIdFieldValues(List<SObject> records, Schema.SObjectField field) {
            return getIdFieldValues(records, '' + field);
        }

        public Set<Id> getIdFieldValues(List<SObject> records, String fieldName) {

            Set<Id> values = new Set<Id>();

            for (SObject rec : records) {
                Id value = (Id) rec.get(fieldName);
                if (value != null) {
                    values.add(value);
                }
            }

            return values;

        }

        public Set<String> getStringFieldValues(List<SObject> records, Schema.SObjectField field) {
            return getStringFieldValues(records, '' + field);
        }

        public Set<String> getStringFieldValues(List<SObject> records, String fieldName) {

            Set<String> values = new Set<String>();

            for (SObject rec : records) {
                String value = rec.get(fieldName) == null ? null : String.valueOf(rec.get(fieldName));
                if (value != null) {
                    values.add(value);
                }
            }

            return values;

        }

        public Map<String, SObject> getSObjectsByAnyFieldMap(List<SObject> sObjects, Schema.SObjectField sObjectField) {
            return getSObjectsByAnyFieldMap(sObjects, '' + sObjectField);
        }

        public Map<String, SObject> getSObjectsByAnyFieldMap(List<SObject> sObjects, String sObjectField) {
            Map<String, SObject> resultMap = new Map<String, SObject>();
            for (SObject record : sObjects) {
                String value = (String) record.get(sObjectField);
                if (value != null) {
                    resultMap.put(value, record);
                }
            }
            return resultMap;
        }

        public Map<String, List<SObject>> getSObjectsListByAnyFieldMap(List<SObject> sObjects, Schema.SObjectField sObjectField) {
            return getSObjectsListByAnyFieldMap(sObjects, '' + sObjectField);
        }

        public Map<String, List<SObject>> getSObjectsListByAnyFieldMap(List<SObject> sObjects, String sObjectField) {
            Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
            for (SObject record : sObjects) {
                String value = (String) record.get(sObjectField);
                if (value != null) {
                    if (resultMap.containsKey(value)) {
                        resultMap.get(value).add(record);
                    } else {
                        resultMap.put(value, new List<SObject>{
                                record
                        });
                    }
                }
            }
            return resultMap;
        }

        public String fieldToProperty(SObjectField field) {
            return fieldNameToProperty(field.getDescribe().getName());
        }

        public String fieldNameToProperty(String fieldName) {
            if (String.isBlank(fieldName)) return '';

            List<String> parts = new List<String>();

            fieldName = fieldName.replace('__c', '');
            fieldName = fieldName.replace('__s', '');

            String namespace = '';
            if (fieldName.contains('__')) {
                namespace = fieldName.substringBefore('__').toLowerCase();
                fieldName = fieldName.substringAfter('__');
            }

            for (String part : fieldName.split('_')) {
                parts.add(part.substring(0, 1).toUpperCase() + part.substring(1));
            }

            String property = namespace + String.join(parts, '');
            property = property.isAllUpperCase() ? property : property.substring(0, 1).toLowerCase() + property.substring(1);

            return property;
        }

        public RecordTypeInfo recordTypeByAPIName(SObjectType sObjectTypeVar, String apiName) {
            return sObjectTypeVar.getDescribe().getRecordTypeInfosByDeveloperName().get(apiName);
        }

        public Id recordTypeIdByAPIName(SObjectType sObjectTypeVar, String apiName) {
            RecordTypeInfo recType = this.recordTypeByAPIName(sObjectTypeVar, apiName);
            if (recType == null) {
                throw new jam.MissingDataException('No Record Type for: ' + sObjectTypeVar + ' with API Name: ' + apiName);
            }
            return recType.getRecordTypeId();
        }

        public jam.SelectOption toSelectOption(SObject sObj, String valueFieldName, String labelFieldName) {
            return new jam.SelectOption(
                    (String) sObj.get(valueFieldName),
                    (String) sObj.get(labelFieldName)
            );
        }

        public jam.SelectOption toSelectOption(SObject sObj, String labelFieldName) {
            return new jam.SelectOption(
                    (String) sObj.get('Id'),
                    (String) sObj.get(labelFieldName)
            );
        }

        public jam.SelectOption toSelectOption(SObject sObj) {
            return new jam.SelectOption(
                    (String) sObj.get('Id'),
                    (String) sObj.get('Name')
            );
        }

        public List<jam.SelectOption> toSelectOptions(List<SObject> sObjects, String valueFieldName, String labelFieldName) {
            List<jam.SelectOption> options = new List<jam.SelectOption>();

            for (SObject sObj : sObjects) {
                options.add(toSelectOption(sObj, valueFieldName, labelFieldName));
            }

            return options;
        }

        public List<jam.SelectOption> toSelectOptions(List<System.SelectOption> selectOptions) {
            List<jam.SelectOption> options = new List<jam.SelectOption>();
            for (System.SelectOption option : selectOptions) {
                options.add(new jam.SelectOption(option.getValue().replaceAll(' ', '_'), option.getLabel()));
            }
            return options;
        }

        public List<jam.SelectOption> toSelectOptions(List<SObject> sObjects, String labelFieldName) {
            return toSelectOptions(sObjects, 'Id', labelFieldName);
        }

        public List<jam.SelectOption> toSelectOptions(List<SObject> sObjects) {
            return toSelectOptions(sObjects, 'Id', 'Name');
        }

        public void swap(SObject record, SObjectField field1, SObjectField field2) {
            Object valueOfField1 = record.get(field1);
            record.put(field1, record.get(field2));
            record.put(field2, valueOfField1);
        }

        public SObjectType stringToSObjectType(String sObjectTypeStr) {
            jam.objects.throwIfBlank(sObjectTypeStr, 'No SObjectType');

            SObjectType sObjectTypeVar = Schema.getGlobalDescribe().get(sObjectTypeStr.toLowerCase());
            jam.objects.throwIfNull(sObjectTypeVar, 'No SObjectType with API Name: ' + sObjectTypeStr);

            return sObjectTypeVar;
        }

        public Set<SObjectField> getFieldsByTypes(SObjectType sObjType, Set<DisplayType> types) {
            Set<SObjectField> fields = new Set<SObjectField>();
            for (SObjectField field : sObjType.getDescribe().fields.getMap().values()) {
                if (types.contains(field.getDescribe().type)) {
                    fields.add(field);
                }
            }
            return fields;
        }

        public Boolean isSomeFieldChanged(SObject record, SObject existingRecord, List<String> fields) {
            if (fields == null) {
                throw new jam.MissingDataException('fields argument is missing');
            }

            if (existingRecord == null) {
                throw new jam.MissingDataException('record argument is missing');
            }

            if (record == null) {
                throw new jam.MissingDataException('existingRecord argument is missing');
            }

            for (String field : fields) {
                Object newFieldValue = record.get(field);
                Object oldFieldValue = existingRecord.get(field);

                if (newFieldValue != oldFieldValue) {
                    return true;
                }
            }

            return false;
        }

        public Boolean isSomeFieldChanged(SObject record, SObject existingRecord, List<SObjectField> fields) {
            if (fields == null) {
                throw new jam.MissingDataException('fields argument is missing');
            }

            if (existingRecord == null) {
                throw new jam.MissingDataException('record argument is missing');
            }

            if (record == null) {
                throw new jam.MissingDataException('existingRecord argument is missing');
            }

            List<String> fieldsStrings = new List<String>();
            for (SObjectField field : fields) {
                fieldsStrings.add(field.getDescribe().getName());
            }
            return isSomeFieldChanged(record, existingRecord, fieldsStrings);
        }

        public Object getValueByPath(SObject recordVar, String path) {
            path = path.toLowerCase();
            List<String> pathItems = path.split('\\.');

            SObject targetSobjectVar = recordVar;
            while (pathItems.size() > 1 && targetSobjectVar != null) {
                String pathItem = pathItems.remove(0);
                targetSobjectVar = targetSobjectVar.getSObject(pathItem);
            }

            return targetSobjectVar == null ? null : targetSobjectVar.get(pathItems.get(0));
        }

        public void restoreNotBlankValues(List<SObject> records, Set<SObjectField> fields) {
//            if(records != null && records.isEmpty() == false && fields != null && fields.isEmpty() == false){
//                SObjectType sObjectTypeVar = records.get(0).getSObjectType();
//                fflib_QueryFactory queryFactory = new fflib_QueryFactory(sObjectTypeVar);
//                queryFactory.selectField('Id');
//                queryFactory.selectFields(fields);
//                queryFactory.setCondition('Id IN :records');
//                List<SObject> sourceRecords = Database.query(queryFactory.toSOQL());
//                Map<Id, SObject> sourceRecordsMap = new Map<Id, SObject>(sourceRecords);
//                for (SObject recordVar : records) {
//                    SObject sourceRecordVar = sourceRecordsMap.get(recordVar.Id);
//                    for (SObjectField preserveField : fields) {
//                        Object sourceValue = sourceRecordVar.get(preserveField);
//                        if(sourceValue != null){
//                            recordVar.put(preserveField, sourceValue);
//                        }
//                    }
//                }
//            }
        }

        public Boolean deduplicate(SObject recordVar) {
            return deduplicate(recordVar, null);
        }

        public Boolean deduplicate(SObject recordVar, Set<SObjectField> preserveFields) {
            return deduplicate(recordVar, preserveFields, null);
        }

        public Boolean deduplicate(SObject recordVar, Set<SObjectField> preserveFields, String duplicateRuleName) {
            if (recordVar == null || recordVar.Id != null) {
                return false;
            }

            try {
                Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(new List<SObject>{
                        recordVar
                });
                for (Datacloud.FindDuplicatesResult dupeResult : results) {
                    for (Datacloud.DuplicateResult dupeRes : dupeResult.getDuplicateResults()) {
                        if (String.isNotBlank(duplicateRuleName) && !duplicateRuleName.equals(dupeRes.getDuplicateRule())) {
                            continue;
                        }

                        for (Datacloud.MatchResult matchRes : dupeRes.getMatchResults()) {
                            for (Datacloud.MatchRecord matchRec : matchRes.getMatchRecords()) {
                                recordVar.Id = (String) matchRec.getRecord().get('id');
                                jam.sObjects.restoreNotBlankValues(new List<SObject>{
                                        recordVar
                                }, preserveFields);
                                return true;
                            }
                        }
                    }
                }
            } catch (System.HandledException ex) { //No active duplicate rules are defined for the object type.
//                System.debug(ex.getMessage());
            } catch (Exception ex) {
//                System.debug(ex.getMessage()); // Other issue.
            }
            return false;
        }

        public Map<String, Object> getSObjectDescribe(List<SObjectType> sObjectTypes) {
            DTO dto = new DTO();

            for (SObjectType sObjType : sObjectTypes) {
                DescribeSObjectResult sObjDescribe = sObjType.getDescribe();
                String sObjName = sObjDescribe.getName();

                dto.put(sObjName + '.name', sObjDescribe.getName())
                        .put(sObjName + '.localName', sObjDescribe.getLocalName())
                        .put(sObjName + '.label', sObjDescribe.getLabel())
                        .put(sObjName + '.pluralLabel', sObjDescribe.getLabelPlural())
                        .put(sObjName + '.keyPrefix', sObjDescribe.getKeyPrefix());

                for (SObjectField field : sObjDescribe.fields.getMap().values()) {
                    DescribeFieldResult fieldDescribe = field.getDescribe();
                    String fieldName = fieldDescribe.getName();

                    dto.put(sObjName + '.' + fieldName + '.name', fieldDescribe.getName())
                            .put(sObjName + '.' + fieldName + '.localName', fieldDescribe.getLocalName())
                            .put(sObjName + '.' + fieldName + '.label', fieldDescribe.getLabel())
                            .put(sObjName + '.' + fieldName + '.helpText', fieldDescribe.getInlineHelpText())
                            .put(sObjName + '.' + fieldName + '.defaultValue', fieldDescribe.getDefaultValue())
                            .put(sObjName + '.' + fieldName + '.type', fieldDescribe.getType())
                            .put(sObjName + '.' + fieldName + '.type', fieldDescribe.getType());
                }
            }

            return dto.dto;
        }

        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects) {
            return sObjectsToMaps(sObjects, '');
        }

        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects, Object defaultFieldValue) {
            return sObjectsToMaps(sObjects, defaultFieldValue, false);
        }

        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects, Object defaultFieldValue, Boolean isAllFields) {
            return sObjectsToMaps(sObjects, defaultFieldValue, isAllFields, false);
        }

        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects, Object defaultFieldValue, Boolean isAllFields, Boolean isVisualforce) {
            List<Map<String, Object>> sObjMaps = new List<Map<String, Object>>();

            for (SObject sObj : sObjects) {
                sObjMaps.add(this.sObjectToMap(sObj, defaultFieldValue, isAllFields, isVisualforce));
            }

            return sObjMaps;
        }

        public Map<String, Object> sObjectToMap(SObject sObj) {
            return sObjectToMap(sObj, '');
        }

        public Map<String, Object> sObjectToMap(SObject sObj, Object defaultFieldValue) {
            return sObjectToMap(sObj, defaultFieldValue, false);
        }

        public Map<String, Object> sObjectToMap(SObject sObj, Object defaultFieldValue, Boolean isAllFields) {
            return sObjectToMap(sObj, defaultFieldValue, isAllFields, false);
        }

        public Map<String, Object> sObjectToMap(SObject sObj, Object defaultFieldValue, Boolean isAllFields, Boolean isVisualforce) {
            Map<String, Object> sObjMap = new Map<String, Object>();

            Map<String, Object> populatedFieldsMap = sObj.getPopulatedFieldsAsMap();
            Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();

            for (String fieldName : populatedFieldsMap.keySet()) {
                Object fieldValue = populatedFieldsMap.get(fieldName);
                SObjectField fieldVar = fieldsMap.get(fieldName);

                if (fieldValue instanceof List<SObject>) {
                    // Skip related Lists
                    continue;
                }

                if (fieldValue instanceof SObject) {
                    sObjMap.put(fieldName, this.sObjectToMap((SObject) fieldValue, defaultFieldValue, isAllFields, isVisualforce));
                    continue;
                }

                if (isVisualforce == true && fieldValue != null && fieldVar != null) {
                    if (fieldVar.getDescribe().type == DisplayType.DATE) {
                        sObjMap.put(fieldName, jam.dates.dateToDateTime(((Date) fieldValue)).format('dd/MM/yyyy'));
                        continue;
                    }

                    if (fieldVar.getDescribe().type == DisplayType.DATETIME) {
                        sObjMap.put(fieldName, ((Datetime) fieldValue).format());
                        continue;
                    }

                    if (fieldVar.getDescribe().type == DisplayType.TIME) {
                        sObjMap.put(fieldName, Datetime.newInstance(Date.today(), (Time) fieldValue).format('hh:mm a'));
                        continue;
                    }
                }

                sObjMap.put(fieldName, fieldValue == null ? defaultFieldValue : fieldValue);
            }

            if (isAllFields == true) {
                for (SObjectField field : fieldsMap.values()) {
                    String fieldName = field.getDescribe().getName();
                    if (!populatedFieldsMap.containsKey(fieldName)) {
                        sObjMap.put(fieldName, defaultFieldValue);
                    }
                }
            }

            return sObjMap;
        }

        public SObject mapToSObject(SObject sObj, Map<String, Object> sObjMap, Boolean skipValidation, Boolean isVisualforce) {
            Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();
            for (String property : sObjMap.keySet()) {

                SObjectField field = fieldsMap.get(property.toLowerCase());

                if (field != null) {
                    try {
                        Object fieldValue = sObjMap.get(property);
                        if (fieldValue instanceof Long && (fieldValue instanceof Integer) == false) {
                            sObj.put(property, (Long) fieldValue);
                            continue;
                        }

                        if (fieldValue instanceof String && String.isNotBlank((String) fieldValue)) {
                            String fieldValueStr = (String) fieldValue;

                            DisplayType fieldDisplayType = field.getDescribe().type;

                            if (fieldDisplayType == DisplayType.DATE) {
                                fieldValue = isVisualforce == true ? jam.dates.parseDateAusFormat(fieldValueStr) : Date.valueOf(fieldValueStr);
                            } else if (fieldDisplayType == DisplayType.DATETIME) {
                                if (isVisualforce == true) {
                                    fieldValue = jam.dates.parseDatetimeAusFormat(fieldValueStr);
                                } else {
                                    if (!fieldValueStr.startsWith('"')) {
                                        fieldValueStr = '"' + fieldValueStr;
                                    }
                                    if (!fieldValueStr.endsWith('"')) {
                                        fieldValueStr = fieldValueStr + '"';
                                    }
                                    fieldValue = jam.dates.datetimeStringToDatetime(fieldValueStr);
                                }
                            } else if (fieldDisplayType == DisplayType.TIME) {
                                if (isVisualforce == true) {
                                    Datetime dt = jam.dates.parseDatetimeAnyFormat(fieldValueStr, 'hh:mm a');
                                    fieldValue = dt == null ? fieldValue : dt.time();
                                } else {
                                    fieldValue = fieldValueStr.toUpperCase().contains('AM') || fieldValueStr.toUpperCase().contains('PM') ?
                                            jam.dates.timeStringAMPMToTime(fieldValueStr.toUpperCase()) :
                                            jam.dates.timeStringToTime(fieldValueStr);
                                }
                            } else if (DisplayType.DOUBLE == fieldDisplayType || DisplayType.CURRENCY == fieldDisplayType) {
                                fieldValue = Decimal.valueOf(fieldValueStr);
                            } else if (DisplayType.INTEGER == fieldDisplayType) {
                                fieldValue = Integer.valueOf(fieldValueStr);
                            } else if (DisplayType.BASE64 == fieldDisplayType) {
                                fieldValue = EncodingUtil.base64Decode(fieldValueStr);
                            } else if (DisplayType.BOOLEAN == fieldDisplayType) {
                                fieldValue = Boolean.valueOf(fieldValue);
                            }
                        }

                        sObj.put(property, fieldValue);
                        continue;
                    } catch (SObjectException ex) {
                    } catch (Exception ex) {
                        throw ex;
                    }
                }

                if (property.endsWithIgnoreCase('__c') && skipValidation != true) {
                    throw new jam.MissingDataException(String.format(
                            'No Field with name {0} on {1}',
                            new List<String>{
                                    property,
                                    '' + sObj
                            }
                    ));
                }
            }

            return sObj;
        }
    }

    public inherited sharing class URLExtensions {

        public String generateReportURL(String reportAPIName, List<String> paramValues) {
            return generateReportURL(reportAPIName, paramValues, true, null);
        }

        public String generateReportURL(String reportAPIName, List<String> paramValues, Boolean isSecurityEnforced, String namespacePrefix) {

            String reportQuery = 'SELECT Id, Name\n' +
                    'FROM Report\n' +
                    'WHERE DeveloperName = :reportAPIName AND NamespacePrefix = :namespacePrefix' +
                    (isSecurityEnforced == true ? ' WITH USER_MODE' : '');

            Report reportId = (Report) jam.arrays.firstOrNull(
                    Database.query(reportQuery)
            );

            List<String> reportParams = new List<String>();
            if (paramValues != null) {
                for (Integer i = 0; i < paramValues.size(); i++) {
                    reportParams.add(String.format('fv{0}={1}', new List<String>{
                            '' + (i + 1),
                            EncodingUtil.urlEncode(paramValues[i], 'UTF-8')
                    }));
                }
            }

            String reportURL = String.format('/lightning/r/Report/{0}/view?queryScope=userFolders{1}', new List<String>{
                    Test.isRunningTest() ? 'test' : reportId?.Id,
                    reportParams.isEmpty() ? '' : '&' + String.join(reportParams, '&')
            });

            return reportURL;
        }

        public PageReference listView(Schema.SObjectType destinationSObject) {
            Schema.DescribeSObjectResult destination = destinationSObject.getDescribe();
            PageReference pageRef = new PageReference('/' + destination.getKeyPrefix());
            pageRef.setRedirect(true);
            return pageRef;
        }
    }


    public static Organization currentOrg {
        get {
            if (currentOrg == null) {
                currentOrg = (Organization) jam.arrays.firstOrException([
                        SELECT IsSandbox, TrialExpirationDate
                        FROM Organization
                        WHERE Id = :UserInfo.getOrganizationId()
                ], ' No Organisation');
            }
            return currentOrg;
        }
        private set;
    }

    public static Boolean isSandbox {
        get {
            return currentOrg.IsSandbox && currentOrg.TrialExpirationDate == null;
        }
        private set;
    }

    public static Boolean isScratch {
        get {
            return currentOrg.IsSandbox && currentOrg.TrialExpirationDate != null;
        }
        private set;
    }

    public static Boolean isTrialOrg {
        get {
            return !currentOrg.IsSandbox && currentOrg.TrialExpirationDate != null;
        }
        private set;
    }

    public static List<Holiday> holidays {
        get {
            if (holidays == null) {
                holidays = [
                        SELECT StartTimeInMinutes, EndTimeInMinutes, Name, ActivityDate, Description, IsAllDay, IsRecurrence
                        FROM Holiday
                ];
            }
            return holidays;
        }
        private set;
    }

    public inherited sharing class EncodingExtensions {

        public String mapToFormUrlEncoded(Map<String, String> dataMap) {
            List<String> keyValuePairsEncoded = new List<String>();
            for (String key : dataMap.keySet()) {
                keyValuePairsEncoded.add(String.format('{0}={1}', new List<String>{
                        System.EncodingUtil.urlEncode(key, 'UTF-8'),
                        System.EncodingUtil.urlEncode(jam.strings.emptyStringIfNull(dataMap.get(key)), 'UTF-8')
                }));
            }

            return String.join(keyValuePairsEncoded, '&');
        }

        public String getEncryptedValue(String value, String blobEncodedString) {
            Blob cryptoKey = EncodingUtil.base64Decode(blobEncodedString);

            Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(value));

            String encryptedValue = EncodingUtil.base64Encode(encryptedToken);

            return encryptedValue;
        }

        public String getDecryptedValue(String encryptedValue, String blobEncodedString) {
            Blob cryptoKey = EncodingUtil.base64Decode(blobEncodedString);

            Blob encryptedToken = EncodingUtil.base64Decode(encryptedValue);

            Blob decryptedToken = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedToken);

            return decryptedToken.toString();
        }

    }

    public inherited sharing class ArrayExtensions {
        public Object firstOrDefault(List<Object> records, Object defaultVar) {
            return records.isEmpty() ? defaultVar : records[0];
        }

        public Object firstOrNull(List<Object> records) {
            return firstOrDefault(records, null);
        }

        public Object firstOrException(List<Object> records) {
            return firstOrException(records, 'The list is empty');
        }

        public Object firstOrException(List<Object> records, String message) {
            return firstOrException(records, message, null);
        }

        public Object firstOrException(List<Object> records, String message, Type exceptionType) {
            if (records == null || records.isEmpty()) {
                Exception ex;
                if (exceptionType != null) {
                    ex = (Exception) exceptionType.newInstance();
                    ex.setMessage(message);
                } else {
                    ex = new jam.MissingDataException(message);
                }
                throw ex;
            }
            return records.get(0);
        }

        public void addToSetIfNotBlank(Set<String> dataSet, String value) {
            if (String.isNotBlank(value)) {
                dataSet.add(value);
            }
        }

        public void addToListOrCreateNew(Map<String, List<Object>> dataMap, Type listType, String key, Object obj, Integer index) {
            if (dataMap == null) {
                dataMap = new Map<String, List<Object>>();
            }
            if (!dataMap.containsKey(key) || dataMap.get(key) == null) {
                List<Object> newList = (List<Object>) listType.newInstance();
                dataMap.put(key, newList);
            }
            if (index != null && dataMap.get(key).size() > index) {
                dataMap.get(key).add(index, obj);
            } else {
                dataMap.get(key).add(obj);
            }
        }

        public void addToListOrCreateNew(Map<String, List<Object>> dataMap, Type listType, String key, Object obj) {
            this.addToListOrCreateNew(dataMap, listType, key, obj, null);
        }

        //Example: jam.arrays.split(new List<Integer>{1, 2, 3, 4, 5, 6, 7, 8, 9 ,10}, 2, List<Integer>.class)
        public List<List<Object>> split(List<Object> arr, Integer chunkSize, Type chunkListType) {

            jam.objects.throwIfNull(chunkSize, 'chunkSize is null');

            List<List<Object>> result = new List<List<Object>>();

            List<Object> chunk;
            Integer chunkCounter = 0;
            for (Object item : arr) {
                if (chunkCounter == 0) {
                    chunk = (List<Object>) chunkListType.newInstance();
                    result.add(chunk);
                }
                chunk.add(item);
                chunkCounter++;
                if (chunkCounter == chunkSize) {
                    chunkCounter = 0;
                }
            }

            return result;
        }
    }

    public inherited sharing class TemplateExtensions {

        public String compose(String template, Map<String, Object> dtoMap) {
            return this.compose(template, new DTO(dtoMap));
        }

        public String compose(String template, DTO dto) {

            String reExp = '(?s)(\\{!.+?\\})';

            Pattern patternVar = Pattern.compile(reExp);
            Matcher matcherVar = patternVar.matcher(template);

            Set<String> placeholders = new Set<String>();

            while (matcherVar.find()) {
                for (Integer i = 1; i <= matcherVar.groupCount(); i++) {
                    String placeholder = matcherVar.group(i);
                    placeholders.add(placeholder);
                }
            }

            String result = template;

            for (String placeholder : placeholders) {

                jam.Expression expressionVar = getExpression(placeholder);

                try {
                    result = expressionVar.apply(dto, result);
                } catch (Exception ex) {
                    throw new jam.ProcessException('Unable to apply merge field: ' + placeholder);
                }
            }

            return result;
        }

        public jam.Expression getExpression(String placeholder) {
            jam.Expression expressionVar;

            if (String.isBlank(placeholder)) {
                return expressionVar;
            }

            // Remove the brackets  {! }
            String expressionStr = placeholder.substring(2, placeholder.length() - 1);
            expressionVar = new jam.MergeFieldExpression(expressionStr);

            return expressionVar;
        }

    }

    public inherited sharing class ObjectExtensions {
        public jam.Action getAction(String actionName) {
            return getAction(actionName, 'No Action with Name: ' + actionName);
        }

        public jam.Action getAction(String actionName, String errorMessage) {
            String namespace;
            String className = actionName;

            List<String> actionParts = actionName.split('\\.');

            if (actionParts.size() == 2) {
                namespace = actionParts[0];
                className = actionParts[1];
            }

            Type actionType = Type.forName(namespace, className);
            if (actionType == null) {
                throw new jam.ProcessException(errorMessage);
            }

            jam.Action actionVar = (jam.Action) actionType.newInstance();

            if (actionVar == null) {
                throw new jam.ProcessException('Unable to create Action instance of type name: ' + actionName);
            }

            return actionVar;
        }

        public void throwIfNull(Object obj, Exception ex) {
            if (obj == null) {
                throw ex;
            }
        }

        public void throwIfNull(Object obj, String message) {
            if (obj == null) {
                throw new jam.MissingDataException(message);
            }
        }

        public Boolean isBlankValue(Object obj) {
            return obj == null || (obj instanceof String && String.isBlank((String) obj));
        }

        public void throwIfBlank(Object obj, String message) {
            if (this.isBlankValue(obj)) {
                throw new jam.MissingDataException(message);
            }
        }

        public Decimal parseDecimal(Object val) {
            if (val == null) {
                return null;
            } else if (val instanceof Decimal) {
                return (Decimal) val;
            } else if (val instanceof String && String.isNotBlank((String) val)) {
                return Decimal.valueOf((String) val);
            } else if (val instanceof Integer) {
                return Decimal.valueOf((Integer) val);
            } else if (val instanceof Long) {
                return Decimal.valueOf((Long) val);
            } else if (val instanceof Double) {
                return Decimal.valueOf((Double) val);
            }
            throw new jam.ProcessException('Unable to parse Decimal from: ' + val);
        }

        public Decimal defaultIfNull(Decimal val, Decimal defaultVal) {
            return val == null ? defaultVal : val;
        }

        public Integer defaultIfNull(Integer val, Integer defaultVal) {
            return val == null ? defaultVal : val;
        }

        public String defaultIfNull(String val, String defaultVal) {
            return val == null ? defaultVal : val;
        }

        public Object getMapValue(Map<String, Object> dataMap, String path) {
            return this.getMapValue(dataMap, path.split('\\.'));
        }

        public Object getMapValue(Map<String, Object> dataMap, List<String> path) {

            List<String> currentKeys = path;
            Map<String, Object> tempMap = dataMap;
            List<Object> tempArr = null;

            while (!currentKeys.isEmpty()) {

                if (tempMap == null && tempArr == null) {
                    return null;
                }

                String key = currentKeys.remove(0);
                Pattern arrayNotation = Pattern.compile('\\[(\\d+)]');
                Matcher arrayMatcher = arrayNotation.matcher(key);
                Boolean isArrayKey = arrayMatcher.matches();
                Integer index = isArrayKey ? Integer.valueOf(arrayMatcher.group(1)) : null;

                if (isArrayKey && (tempArr == null || index == null || tempArr.size() <= index)) {
                    return null;
                }

                Object val = isArrayKey ? tempArr.get(index) : tempMap.get(key);

                Boolean isLastKey = currentKeys.isEmpty();

                if (isLastKey == true) {
                    return val;
                } else {
                    if (val instanceof List<Object>) {
                        tempArr = (List<Object>) val;
                    } else {
                        Object t = isArrayKey ?
                                tempArr.get(index) :
                                tempMap.get(key);

                        if (t instanceof Map<String, Object>) {
                            tempMap = (Map<String, Object>) t;
                            tempArr = null;
                        } else {
                            return null;
                        }
                    }
                }

            }
            return null;
        }

        public void setMapValue(Map<String, Object> dataMap, String path, Object value) {
            this.setMapValue(dataMap, path.split('\\.'), value);
        }

        public void setMapValue(Map<String, Object> dataMap, List<String> path, Object value) {
            List<String> currentKeys = path;
            Map<String, Object> tempMap = dataMap;

            while (!currentKeys.isEmpty()) {

                if (tempMap == null) {
                    return;
                }

                String key = currentKeys.remove(0);

                Boolean isLastKey = currentKeys.isEmpty();

                if (isLastKey == true) {
                    tempMap.put(key, value);
                } else {
                    if (!tempMap.containsKey(key)) {
                        tempMap.put(key, new Map<String, Object>());
                    }
                    tempMap = (Map<String, Object>) tempMap.get(key);
                }

            }

        }

        public void removeMapValue(Map<String, Object> dataMap, String path) {
            this.removeMapValue(dataMap, path == null ? null : path.split('\\.'));
        }
        public void removeMapValue(Map<String, Object> dataMap, List<String> path) {

            List<String> currentKeys = path == null ? new List<String>{
                    null
            } : path;
            Map<String, Object> tempMap = dataMap;
            List<Object> tempArr = null;

            while (!currentKeys.isEmpty()) {

                if (tempMap == null && tempArr == null) {
                    return;
                }

                String key = currentKeys.remove(0);

                Pattern arrayNotation = Pattern.compile('\\[(\\d+)]');
                Matcher arrayMatcher = key == null ? null : arrayNotation.matcher(key);
                Boolean isArrayKey = arrayMatcher == null ? false : arrayMatcher.matches();
                Integer index = isArrayKey ? Integer.valueOf(arrayMatcher.group(1)) : null;

                if (isArrayKey && (tempArr == null || index == null || tempArr.size() <= index)) {
                    return;
                }

                Object val = isArrayKey ? tempArr.get(index) : tempMap.get(key);

                Boolean isLastKey = currentKeys.isEmpty();

                if (isLastKey == true) {
                    if (isArrayKey) {
                        tempArr.remove(index);
                    } else {
                        tempMap.remove(key);
                    }
                    return;
                } else {
                    if (val instanceof List<Object>) {
                        tempArr = (List<Object>) val;
                    } else {
                        tempMap = isArrayKey ?
                                (Map<String, Object>) tempArr.get(index) :
                                (Map<String, Object>) tempMap.get(key);
                        tempArr = null;
                    }
                }

            }
        }

        public Boolean mapContains(Map<String, Object> dataMap, String path) {
            return getMapValue(dataMap, path) != null;
        }
    }

    // Converts a base64 string into a list of integers representing the encoded bytes
    public static List<Integer> B64ToBytes(String sIn) {
        Map<Integer, Integer> base64 = new Map<Integer, Integer>{
                65 => 0, 66 => 1, 67 => 2, 68 => 3, 69 => 4, 70 => 5, 71 => 6, 72 => 7, 73 => 8, 74 => 9, 75 => 10, 76 => 11, 77 => 12, 78 => 13, 79 => 14, 80 => 15, 81 => 16, 82 => 17, 83 => 18, 84 => 19, 85 => 20, 86 => 21, 87 => 22, 88 => 23, 89 => 24, 90 => 25
                , 97 => 26, 98 => 27, 99 => 28, 100 => 29, 101 => 30, 102 => 31, 103 => 32, 104 => 33, 105 => 34, 106 => 35, 107 => 36, 108 => 37, 109 => 38, 110 => 39, 111 => 40, 112 => 41, 113 => 42, 114 => 43, 115 => 44, 116 => 45, 117 => 46, 118 => 47, 119 => 48, 120 => 49, 121 => 50, 122 => 51
                , 48 => 52, 49 => 53, 50 => 54, 51 => 55, 52 => 56, 53 => 57, 54 => 58, 55 => 59, 56 => 60, 57 => 61, 43 => 62, 47 => 63
        };

        List<Integer> lstOut = new List<Integer>();
        if (sIn == null || sIn == '') return lstOut;

        sIn += '='.repeat(4 - Math.mod(sIn.length(), 4));

        for (Integer idx = 0; idx < sIn.length(); idx += 4) {
            if (base64.get(sIn.charAt(idx + 1)) != null) lstOut.add((base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx + 1)) >>> 4));
            if (base64.get(sIn.charAt(idx + 2)) != null) lstOut.add(((base64.get(sIn.charAt(idx + 1)) & 15) << 4) | (base64.get(sIn.charAt(idx + 2)) >>> 2));
            if (base64.get(sIn.charAt(idx + 3)) != null) lstOut.add(((base64.get(sIn.charAt(idx + 2)) & 3) << 6) | base64.get(sIn.charAt(idx + 3)));
        }

        return lstOut;
    }

    // Converts a base64 string into a list of integers indicating at which position the bits are on
    public static List<Integer> cnvBits(String b64Str) {
        List<Integer> lstOut = new List<Integer>();
        if (b64Str == null || b64Str == '') return lstOut;

        List<Integer> lstBytes = B64ToBytes(b64Str);

        Integer i, b, v;
        for (i = 0; i < lstBytes.size(); i++) {
            v = lstBytes[i];
            for (b = 1; b <= 8; b++) {
                if ((v & 128) == 128) lstOut.add((i * 8) + b);
                v <<= 1;
            }
        }

        return lstOut;
    }

    public inherited sharing class MissingDataException extends Exception {
    }
    public inherited sharing class ValidationException extends Exception {
    }
    public inherited sharing class ProcessException extends Exception {
    }

    //UTILS ALIASES
    public static PicklistExtensions picklists {
        get {
            if (picklists == null) {
                picklists = new PicklistExtensions();
            }
            return picklists;
        }
        private set;
    }

    public static DateExtensions dates {
        get {
            if (dates == null) {
                dates = new DateExtensions();
            }
            return dates;
        }
        private set;
    }

    public static StringExtensions strings {
        get {
            if (strings == null) {
                strings = new StringExtensions();
            }
            return strings;
        }
        private set;
    }

    public static UserExtensions users {
        get {
            if (users == null) {
                users = new UserExtensions();
            }
            return users;
        }
        private set;
    }

    public static SObjectExtensions sObjects {
        get {
            if (sObjects == null) {
                sObjects = new SObjectExtensions();
            }
            return sObjects;
        }
        private set;
    }

    public static URLExtensions URLs {
        get {
            if (URLs == null) {
                URLs = new URLExtensions();
            }
            return URLs;
        }
        private set;
    }

    public static EncodingExtensions encodings {
        get {
            if (encodings == null) {
                encodings = new EncodingExtensions();
            }
            return encodings;
        }
        private set;
    }

    public static ArrayExtensions arrays {
        get {
            if (arrays == null) {
                arrays = new ArrayExtensions();
            }
            return arrays;
        }
        private set;
    }

    public static ObjectExtensions objects {
        get {
            if (objects == null) {
                objects = new ObjectExtensions();
            }
            return objects;
        }
        private set;
    }

    public static TemplateExtensions templates {
        get {
            if (templates == null) {
                templates = new TemplateExtensions();
            }
            return templates;
        }
        private set;
    }
}