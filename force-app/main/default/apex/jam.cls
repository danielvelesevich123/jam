global inherited sharing class jam implements Callable {
    \n' +
        '\n' +
        '    public interface AllowsCallable {}\n' +
        '\n' +
        '    /*\n' +
        '    *   Callable Interface implementation allows for the execution of the Action from another package.\n' +
        '    *   The calling Action MUST implement the jam.AllowsCallable interface.\n' +
        '    *\n' +
        '    *   jam.objects.runPackageAction(\'namespace2\', \'SampleAct\', new Map<String, Object>{\n' +
        '    *       \'someValue\' => \'test\'\n' +
        '    *   });\n' +
        '    */\n' +
        '    global Object call(String action, Map<String, Object> dtoMap) {\n' +
        '        jam.objects.throwIfBlank(action, \'Action is required\');\n' +
        '        jam.objects.throwIfBlank(dtoMap, \'DTO Map is required\');\n' +
        '        jam.Action actionInstance = jam.objects.getAction(action);\n' +
        '        if ((actionInstance instanceof jam.AllowsCallable) != true) { // Make sure the action implements the jam.AllowsCallable interface\n' +
        '            throw new jam.ProcessException(String.format(\'Action {0} does not implement the AllowsCallable interface\', new List<String>{action}));\n' +
        '        }\n' +
        '        return actionInstance.run(dtoMap).getMap();\n' +
        '    }\n' +
        '\n' +
        '    @AuraEnabled\n' +
        '    public static String runAction(String action, String requestJSON) {\n' +
        '        try {\n' +
        '            return jam.run(action, requestJSON).getJSON();\n' +
        '        } catch (Exception ex) {\n' +
        '            return new jam.Response(ex).getJSON();\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    @RemoteAction\n' +
        '    public static String runAction(String requestJSON) {\n' +
        '        try {\n' +
        '            Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);\n' +
        '\n' +
        '            if (request.containsKey(\'action\') && request.containsKey(\'dto\')) {\n' +
        '                return runAction((String) request.get(\'action\'), JSON.serialize(request.get(\'dto\')));\n' +
        '            }\n' +
        '\n' +
        '            return new jam.Response(\'Invalid request attributes.\').getJSON();\n' +
        '        } catch (Exception ex) {\n' +
        '            return new jam.Response(ex).getJSON();\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    /**\n' +
        '     * Executes the specified action with the provided request JSON.\n' +
        '     *\n' +
        '     * @param action The name of the action to be executed. This should correspond to an existing action in the system.\n' +
        '     * @param requestJSON The JSON string representing the request data for the action. The structure of this JSON should match the expected input for the action.\n' +
        '     *\n' +
        '     * @return A jam.Response object representing the result of the action execution. This includes any data returned by the action and information about the execution status.\n' +
        '     *\n' +
        '     * @throws Exception If there is an error during the execution of the action, an exception is thrown. This could be due to issues with the action itself or problems with the input data.\n' +
        '     */\n' +
        '    public static jam.Response run(String action, String requestJSON) {\n' +
        '        Savepoint savepoint;\n' +
        '\n' +
        '        try {\n' +
        '            jam.Action actionVar = jam.objects.getAction(action);\n' +
        '            jam.DTO requestVar = actionVar.initRequest(requestJSON);\n' +
        '\n' +
        '            Boolean doesPerformCallout = actionVar instanceof Database.AllowsCallouts;\n' +
        '\n' +
        '            if (doesPerformCallout != true) {\n' +
        '                savepoint = Database.setSavepoint();\n' +
        '            }\n' +
        '\n' +
        '            return new jam.Response(actionVar.run(requestVar));\n' +
        '        } catch (Exception ex) {\n' +
        '            if (savepoint != null) {\n' +
        '                Database.rollback(savepoint);\n' +
        '            }\n' +
        '            throw ex;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing abstract class Action implements Queueable {\n' +
        '        protected DTO request;\n' +
        '        protected jam.Response response = new jam.Response();\n' +
        '\n' +
        '        public Action() {\n' +
        '        }\n' +
        '\n' +
        '        public Action(Map<String, Object> requestMap) {\n' +
        '            this.request = this.initRequest(requestMap);\n' +
        '        }\n' +
        '\n' +
        '        public virtual jam.Response run(Map<String, Object> requestMap) {\n' +
        '            return this.run(this.initRequest(requestMap));\n' +
        '        }\n' +
        '\n' +
        '        public virtual jam.Response run(String requestJSON) {\n' +
        '            return this.run(this.initRequest(requestJSON));\n' +
        '        }\n' +
        '\n' +
        '        public virtual jam.Response run(DTO request) {\n' +
        '            this.request = request;\n' +
        '//            this.initSelectOptions();\n' +
        '            this.run();\n' +
        '            return this.response;\n' +
        '        }\n' +
        '\n' +
        '        public abstract void run();\n' +
        '\n' +
        '\n' +
        '        /*\n' +
        '        *   Queueable Interface implementation\n' +
        '        *   Allows for the execution of the Action in a Queueable context\n' +
        '        *   System.enqueueJob(new SampleAct(new Map<String, Object>{\'key\' => \'value\'}))\n' +
        '         */\n' +
        '        public void execute(QueueableContext context) {\n' +
        '            this.run();\n' +
        '        }\n' +
        '\n' +
        '        public virtual DTO initRequest(String requestJSON) {\n' +
        '            return this.initRequest((Map<String, Object>) JSON.deserializeUntyped(requestJSON));\n' +
        '        }\n' +
        '\n' +
        '        public virtual DTO initRequest(Map<String, Object> requestMap) {\n' +
        '            return new DTO(requestMap);\n' +
        '        }\n' +
        '\n' +
        '        //GETTER ALIASES\n' +
        '        public Object get(String path) {\n' +
        '            return this.request == null ? null : this.request.get(path);\n' +
        '        }\n' +
        '\n' +
        '        public String getString(String path) {\n' +
        '            return this.request == null ? null : this.request.getString(path);\n' +
        '        }\n' +
        '\n' +
        '        public String getRequiredString(String path) {\n' +
        '            return this.request == null ? null : this.request.getRequiredString(path);\n' +
        '        }\n' +
        '\n' +
        '        public String getRequiredString(String path, String errorMessage) {\n' +
        '            return this.request == null ? null : this.request.getRequiredString(path, errorMessage);\n' +
        '        }\n' +
        '\n' +
        '        public Integer getInteger(String path) {\n' +
        '            return this.request == null ? null : this.request.getInteger(path);\n' +
        '        }\n' +
        '\n' +
        '        public Long getLong(String path) {\n' +
        '            return this.request == null ? null : this.request.getLong(path);\n' +
        '        }\n' +
        '\n' +
        '        public Decimal getDecimal(String path) {\n' +
        '            return this.request == null ? null : this.request.getDecimal(path);\n' +
        '        }\n' +
        '\n' +
        '        public Boolean getBoolean(String path) {\n' +
        '            return this.request == null ? false : this.request.getBoolean(path);\n' +
        '        }\n' +
        '\n' +
        '        public Date getDate(String path) {\n' +
        '            return this.request == null ? null : this.request.getDate(path);\n' +
        '        }\n' +
        '\n' +
        '        public Time getTime(String path) {\n' +
        '            return this.request == null ? null : this.request.getTime(path);\n' +
        '        }\n' +
        '\n' +
        '        public Datetime getDatetime(String path) {\n' +
        '            return this.request == null ? null : this.request.getDatetime(path);\n' +
        '        }\n' +
        '\n' +
        '        public SObject getSObject(String path, SObjectType sObjectTypeVar) {\n' +
        '            return this.request == null ? null : this.request.getSObject(path, sObjectTypeVar);\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action getSObject(String path, SObject sObj) {\n' +
        '            if (this.request != null) {\n' +
        '                this.request.getSObject(path, sObj);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action getSObject(String path, SObject sObj, Boolean skipValidation) {\n' +
        '            if (this.request != null) {\n' +
        '                this.request.getSObject(path, sObj, skipValidation);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public List<Object> getObjects(String path) {\n' +
        '            return this.request == null ? null : this.request.getObjects(path);\n' +
        '        }\n' +
        '\n' +
        '        public List<String> getStrings(String path) {\n' +
        '            return this.request == null ? null : this.request.getStrings(path);\n' +
        '        }\n' +
        '\n' +
        '        public List<Map<String, Object>> getMaps(String path) {\n' +
        '            return this.request == null ? null : this.request.getMaps(path);\n' +
        '        }\n' +
        '\n' +
        '        public List<DTO> getDTOs(String path) {\n' +
        '            return this.request == null ? null : this.request.getDTOs(path);\n' +
        '        }\n' +
        '\n' +
        '        public List<SObject> getSObjects(String path, SObjectType sObjectTypeVar) {\n' +
        '            return this.request == null ? null : this.request.getSObjects(path, sObjectTypeVar);\n' +
        '        }\n' +
        '\n' +
        '        public List<SObject> getSObjects(String path, SObjectType sObjectTypeVar, Boolean skipValidation) {\n' +
        '            return this.request == null ? null : this.request.getSObjects(path, sObjectTypeVar, skipValidation);\n' +
        '        }\n' +
        '\n' +
        '\n' +
        '        //SETTER ALIASES\n' +
        '        public jam.Action put(String path, Object value) {\n' +
        '            this.response.put(path, value);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action put(String path, Object value, Boolean mapSobjects) {\n' +
        '            this.response.put(path, value, mapSobjects);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action put(String path, Object value, Integer recordsLimit) {\n' +
        '            this.response.put(path, value, recordsLimit);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action put(String path, Object value, Boolean mapSobjects, Integer recordsLimit) {\n' +
        '            this.response.put(path, value, mapSobjects, recordsLimit);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action put(Map<String, Object> mapVar) {\n' +
        '            this.response.put(mapVar);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action put(Map<String, Object> mapVar, Boolean mapSobjects) {\n' +
        '            this.response.put(mapVar, mapSobjects);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action put(Map<String, Object> mapVar, Integer recordsLimit) {\n' +
        '            this.response.put(mapVar, recordsLimit);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action put(Map<String, Object> mapVar, Boolean mapSobjects, Integer recordsLimit) {\n' +
        '            this.response.put(mapVar, mapSobjects, recordsLimit);\n' +
        '            return this;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing virtual class DTO {\n' +
        '        public Map<String, Object> dto = new Map<String, Object>();\n' +
        '        public Boolean isVisualforce = false;\n' +
        '        public Boolean isAllFields = false;\n' +
        '        public Object defaultFieldValue = \'\';\n' +
        '\n' +
        '        //CONSTRUCTORS\n' +
        '        public DTO() {\n' +
        '        }\n' +
        '\n' +
        '        public DTO(String requestJSON) {\n' +
        '            this.dto = (Map<String, Object>) JSON.deserializeUntyped(requestJSON);\n' +
        '        }\n' +
        '\n' +
        '        public DTO(Map<String, Object> requestMap) {\n' +
        '            this.dto = requestMap == null ? this.dto : requestMap;\n' +
        '        }\n' +
        '\n' +
        '        public DTO(String path, String arrayJSON) {\n' +
        '            Object arrayObject = JSON.deserializeUntyped(arrayJSON);\n' +
        '            jam.objects.setMapValue(this.dto, path, arrayObject);\n' +
        '        }\n' +
        '\n' +
        '        public DTO setIsVisualforce(Boolean value) {\n' +
        '            this.isVisualforce = value == true;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public DTO setIsAllFields(Boolean value) {\n' +
        '            this.isAllFields = value == true;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public DTO setDefaultFieldValue(Object value) {\n' +
        '            this.defaultFieldValue = value;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        //GETTERS\n' +
        '        public Object get(String path) {\n' +
        '            return jam.objects.getMapValue(this.dto, path);\n' +
        '        }\n' +
        '\n' +
        '        public String getString(String path) {\n' +
        '            Object val = jam.objects.getMapValue(this.dto, path);\n' +
        '            return val == null ? null : String.valueOf(val);\n' +
        '        }\n' +
        '\n' +
        '        public String getRequiredString(String path) {\n' +
        '            return this.getRequiredString(path, \'The following parameter is missing in the dto: \' + path);\n' +
        '        }\n' +
        '\n' +
        '        public String getRequiredString(String path, String errorMessage) {\n' +
        '            String val = this.getString(path);\n' +
        '            jam.objects.throwIfBlank(val, errorMessage);\n' +
        '            return val;\n' +
        '        }\n' +
        '\n' +
        '        public Integer getInteger(String path) {\n' +
        '            Object val = jam.objects.getMapValue(this.dto, path);\n' +
        '            return val == null ? null : Integer.valueOf(val);\n' +
        '        }\n' +
        '\n' +
        '        public Long getLong(String path) {\n' +
        '            Object val = jam.objects.getMapValue(this.dto, path);\n' +
        '            return val == null ? null : (val instanceof String ? Long.valueOf((String) val) : (Long) val);\n' +
        '        }\n' +
        '\n' +
        '        public Decimal getDecimal(String path) {\n' +
        '            return jam.objects.parseDecimal(jam.objects.getMapValue(this.dto, path));\n' +
        '        }\n' +
        '\n' +
        '        public Boolean getBoolean(String path) {\n' +
        '            Object val = jam.objects.getMapValue(this.dto, path);\n' +
        '            if (val == null) {\n' +
        '                return false;\n' +
        '            }\n' +
        '            if (val instanceof Boolean) {\n' +
        '                return (Boolean) val;\n' +
        '            }\n' +
        '            return Boolean.valueOf(val);\n' +
        '        }\n' +
        '\n' +
        '        public Date getDate(String path) {\n' +
        '            String dateStr = this.getString(path);\n' +
        '            return String.isBlank(dateStr) ? null : Date.valueOf(dateStr);\n' +
        '        }\n' +
        '\n' +
        '        public Time getTime(String path) {\n' +
        '            String timeStr = this.getString(path);\n' +
        '            if (String.isBlank(timeStr)) {\n' +
        '                return null;\n' +
        '            }\n' +
        '            return jam.dates.timeStringToTime(timeStr);\n' +
        '        }\n' +
        '\n' +
        '        public Datetime getDatetime(String path) {\n' +
        '            String datetimeStr = this.getString(path);\n' +
        '            return datetimeStr == null ? null : jam.dates.datetimeStringToDatetime(datetimeStr);\n' +
        '        }\n' +
        '\n' +
        '        public SObject getSObject(String path, SObjectType sObjectTypeVar) {\n' +
        '            SObject sObj = sObjectTypeVar.newSObject();\n' +
        '            getSObject(path, sObj, false);\n' +
        '            return sObj;\n' +
        '        }\n' +
        '\n' +
        '        public DTO getSObject(String path, SObject sObj) {\n' +
        '            return getSObject(path, sObj, false);\n' +
        '        }\n' +
        '\n' +
        '        public DTO getSObject(String path, SObject sObj, Boolean skipValidation) {\n' +
        '            if (path == null || sObj == null) {\n' +
        '                return null;\n' +
        '            }\n' +
        '\n' +
        '            Object value;\n' +
        '            if (String.isNotBlank(path)) {\n' +
        '                value = jam.objects.getMapValue(this.dto, path);\n' +
        '            } else {\n' +
        '                value = this.dto;\n' +
        '            }\n' +
        '\n' +
        '            if (value != null) {\n' +
        '                Map<String, Object> dataMap = (Map<String, Object>) value;\n' +
        '                jam.sObjects.mapToSObject(sObj, dataMap, skipValidation, this.isVisualforce);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public List<Object> getObjects(String path) {\n' +
        '            return (List<Object>) jam.objects.getMapValue(this.dto, path);\n' +
        '        }\n' +
        '\n' +
        '        public List<String> getStrings(String path) {\n' +
        '            List<String> strings = new List<String>();\n' +
        '\n' +
        '            List<Object> objects = (List<Object>) jam.objects.getMapValue(this.dto, path);\n' +
        '\n' +
        '            if (objects == null) {\n' +
        '                return null;\n' +
        '            }\n' +
        '\n' +
        '            for (Object obj : objects) {\n' +
        '                strings.add(obj == null ? null : obj.toString());\n' +
        '            }\n' +
        '\n' +
        '            return strings;\n' +
        '        }\n' +
        '\n' +
        '        public List<Map<String, Object>> getMaps(String path) {\n' +
        '            List<Map<String, Object>> returnList = new List<Map<String, Object>>();\n' +
        '\n' +
        '            List<Object> objects = getObjects(path);\n' +
        '            if (objects == null) {\n' +
        '                return null;\n' +
        '            }\n' +
        '\n' +
        '            for (Object obj : objects) {\n' +
        '                returnList.add((Map<String, Object>) obj);\n' +
        '            }\n' +
        '\n' +
        '            return returnList;\n' +
        '        }\n' +
        '\n' +
        '        public List<DTO> getDTOs(String path) {\n' +
        '            List<Map<String, Object>> maps = getMaps(path);\n' +
        '\n' +
        '            if (maps == null) {\n' +
        '                return new List<DTO>();\n' +
        '            }\n' +
        '\n' +
        '            List<DTO> returnList = new List<DTO>();\n' +
        '\n' +
        '            for (Map<String, Object> mapVar : maps) {\n' +
        '                returnList.add(new DTO(mapVar));\n' +
        '            }\n' +
        '\n' +
        '            return returnList;\n' +
        '        }\n' +
        '\n' +
        '        public List<SObject> getSObjects(String path, SObjectType sObjectTypeVar) {\n' +
        '            return getSObjects(path, sObjectTypeVar, false);\n' +
        '        }\n' +
        '\n' +
        '        public List<SObject> getSObjects(String path, SObjectType sObjectTypeVar, Boolean skipValidation) {\n' +
        '\n' +
        '            List<Object> values = (List<Object>) jam.objects.getMapValue(this.dto, path);\n' +
        '\n' +
        '            if (values == null) {\n' +
        '                return null;\n' +
        '            }\n' +
        '\n' +
        '            List<SObject> sObjects = new List<SObject>();\n' +
        '\n' +
        '            for (Object value : values) {\n' +
        '                SObject sObj = sObjectTypeVar.newSObject();\n' +
        '                Map<String, Object> dataMap = (Map<String, Object>) value;\n' +
        '                sObjects.add(jam.sObjects.mapToSObject(sObj, dataMap, skipValidation, this.isVisualforce));\n' +
        '            }\n' +
        '\n' +
        '            return sObjects;\n' +
        '        }\n' +
        '\n' +
        '        //SETTERS\n' +
        '        public DTO put(Map<String, Object> mapVar) {\n' +
        '            return this.put(mapVar, true);\n' +
        '        }\n' +
        '\n' +
        '        public DTO put(Map<String, Object> mapVar, Integer recordsLimit) {\n' +
        '            return this.put(mapVar, true, recordsLimit);\n' +
        '        }\n' +
        '\n' +
        '        public DTO put(Map<String, Object> mapVar, Boolean mapSObjects) {\n' +
        '            return this.put(mapVar, mapSObjects, null);\n' +
        '        }\n' +
        '\n' +
        '        public DTO put(Map<String, Object> mapVar, Boolean mapSObjects, Integer recordsLimit) {\n' +
        '            for (String path : mapVar.keySet()) {\n' +
        '                this.put(path, mapVar.get(path), mapSObjects, recordsLimit);\n' +
        '            }\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public DTO put(String path, Object value) {\n' +
        '            return this.put(path, value, true);\n' +
        '        }\n' +
        '\n' +
        '        public DTO put(String path, Object value, Integer recordsLimit) {\n' +
        '            return this.put(path, value, true, recordsLimit);\n' +
        '        }\n' +
        '\n' +
        '        public DTO put(String path, Object value, Boolean mapSObjects) {\n' +
        '            return this.put(path, value, mapSObjects, null);\n' +
        '        }\n' +
        '\n' +
        '        public DTO put(String path, Object value, Boolean mapSObjects, Integer recordsLimit) {\n' +
        '            if (value != null) {\n' +
        '                if (value instanceof List<Object>) {\n' +
        '                    List<Object> resultValueArray = (List<Object>) (value instanceof List<SObject> && mapSObjects ? jam.sObjects.sObjectsToMaps((List<SObject>) value, this.defaultFieldValue, this.isAllFields, this.isVisualforce) : value);\n' +
        '                    value = resultValueArray;\n' +
        '\n' +
        '                    if (recordsLimit != null) {\n' +
        '                        Boolean hasMore = resultValueArray.size() > recordsLimit;\n' +
        '                        while (resultValueArray.size() > recordsLimit) {\n' +
        '                            resultValueArray.remove(resultValueArray.size() - 1);\n' +
        '                        }\n' +
        '\n' +
        '                        String hasMorePath = path + \'.hasMore\';\n' +
        '                        String limitPath = path + \'.limit\';\n' +
        '                        String countPath = path + \'.count\';\n' +
        '\n' +
        '                        this.put(hasMorePath, hasMore);\n' +
        '                        this.put(limitPath, recordsLimit);\n' +
        '                        this.put(countPath, resultValueArray.size());\n' +
        '\n' +
        '                        path += \'.records\';\n' +
        '                    }\n' +
        '                } else if (value instanceof SObject && mapSObjects) {\n' +
        '                    value = jam.sObjects.sObjectToMap((SObject) value, this.defaultFieldValue, this.isAllFields, this.isVisualforce);\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            jam.objects.setMapValue(this.dto, path, value);\n' +
        '            return this;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing virtual class Response extends jam.DTO {\n' +
        '\n' +
        '        public Boolean isValid = true;\n' +
        '        public jam.ErrorDetails error;\n' +
        '        public List<jam.ErrorDetails> errors = new List<jam.ErrorDetails>();\n' +
        '\n' +
        '        public Response() {\n' +
        '            super((Map<String, Object>) null);\n' +
        '        }\n' +
        '\n' +
        '\n' +
        '        public Response(Map<String, Object> responseMap) {\n' +
        '            this.isValid = (Boolean) responseMap.get(\'isValid\');\n' +
        '            this.dto = (Map<String, Object>) responseMap.get(\'dto\');\n' +
        '            this.error = (ErrorDetails) responseMap.get(\'error\');\n' +
        '            this.errors = (List<ErrorDetails>) responseMap.get(\'errors\');\n' +
        '        }\n' +
        '\n' +
        '        public Response(Boolean isValid, Map<String, Object> dto, ErrorDetails error, List<ErrorDetails> errors) {\n' +
        '            this.isValid = isValid;\n' +
        '            this.dto = dto;\n' +
        '            this.error = error;\n' +
        '            this.errors = errors;\n' +
        '        }\n' +
        '\n' +
        '        public Response(jam.DTO responseDTO) {\n' +
        '            super(responseDTO.dto);\n' +
        '        }\n' +
        '\n' +
        '        public Response(Exception ex) {\n' +
        '            this.isValid = (ex == null);\n' +
        '\n' +
        '            if (ex != null) {\n' +
        '                this.error = new jam.ExceptionDetails(ex);\n' +
        '                this.errors.add(this.error);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public Response(List<String> messages) {\n' +
        '            this(String.join(messages, \', \'));\n' +
        '\n' +
        '            this.errors = new List<jam.ErrorDetails>();\n' +
        '            for (String message : messages) {\n' +
        '                this.errors.add(new jam.ErrorDetails(message));\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public Response(String message) {\n' +
        '            this.setError(message);\n' +
        '        }\n' +
        '\n' +
        '        public void setError(String message) {\n' +
        '            this.isValid = (String.isBlank(message));\n' +
        '\n' +
        '            if (String.isNotBlank(message)) {\n' +
        '                this.error = new jam.ErrorDetails(message);\n' +
        '                this.errors.add(this.error);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public String getJSON() {\n' +
        '            return JSON.serialize(this.getMap());\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, Object> getMap() {\n' +
        '            return new Map<String, Object>{\n' +
        '                    \'dto\' => this.dto,\n' +
        '                    \'isValid\' => this.isValid,\n' +
        '                    \'error\' => this.error,\n' +
        '                    \'errors\' => this.errors\n' +
        '            };\n' +
        '        }\n' +
        '\n' +
        '        public void throwIfInvalid() {\n' +
        '            if (!this.isValid) {\n' +
        '                throw new jam.ProcessException(this.errors.size() == 0 ? \'Unknown error\' : this.errors[0].message);\n' +
        '            }\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    //STRUCTURES\n' +
        '    public inherited sharing virtual class SelectOption {\n' +
        '\n' +
        '        public Object value;\n' +
        '        public String label;\n' +
        '\n' +
        '        public SelectOption() {\n' +
        '        }\n' +
        '\n' +
        '        public SelectOption(Object value, String label) {\n' +
        '            this.value = value;\n' +
        '            this.label = label;\n' +
        '        }\n' +
        '\n' +
        '        public SelectOption(String value) {\n' +
        '            this(value, value);\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    @JsonAccess(Serializable=\'always\' Deserializable=\'always\')\n' +
        '    public inherited sharing virtual class ErrorDetails {\n' +
        '        public String message { get; set; }\n' +
        '\n' +
        '        public ErrorDetails(String message) {\n' +
        '            this.message = message;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    @JsonAccess(Serializable=\'always\' Deserializable=\'always\')\n' +
        '    public inherited sharing class ExceptionDetails extends ErrorDetails {\n' +
        '        public Integer lineNumber { get; set; }\n' +
        '        public String stackTraceString { get; set; }\n' +
        '        public String typeName { get; set; }\n' +
        '\n' +
        '        public ExceptionDetails(Exception ex) {\n' +
        '            super(ex.getMessage());\n' +
        '            this.lineNumber = ex.getLineNumber();\n' +
        '            this.stackTraceString = ex.getStackTraceString();\n' +
        '            this.typeName = ex.getTypeName();\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    private inherited sharing class TPicklistEntry {\n' +
        '        public String label { get; set; }\n' +
        '        public String value { get; set; }\n' +
        '        public String validFor { get; set; }\n' +
        '        public TPicklistEntry() {\n' +
        '\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    //UTILS\n' +
        '    public inherited sharing class PicklistExtensions {\n' +
        '        public Set<String> getPicklistAsSetStrings(Schema.SObjectField sObjectField) {\n' +
        '            return getPicklistAsSetStrings(sObjectField, null);\n' +
        '        }\n' +
        '\n' +
        '        public Set<String> getPicklistAsSetStrings(Schema.SObjectField sObjectField, Set<String> excludingValues) {\n' +
        '            Set<String> picklistValues;\n' +
        '\n' +
        '            if (sObjectField.getDescribe().getType() == Schema.DisplayType.MULTIPICKLIST || sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST) {\n' +
        '                picklistValues = new Set<String>();\n' +
        '                List<Schema.PicklistEntry> pickListEntries = sObjectField.getDescribe().getPicklistValues();\n' +
        '\n' +
        '                for (Schema.PicklistEntry pickListEntryVar : pickListEntries) {\n' +
        '                    if (excludingValues == null || !excludingValues.contains(pickListEntryVar.getValue())) {\n' +
        '                        picklistValues.add(pickListEntryVar.getValue());\n' +
        '                    }\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return picklistValues;\n' +
        '        }\n' +
        '\n' +
        '        public List<jam.SelectOption> getPicklistValuesAsSelectOptions(Schema.SObjectField sObjectField) {\n' +
        '            return getPicklistValuesAsSelectOptions(sObjectField, null);\n' +
        '        }\n' +
        '\n' +
        '        public List<jam.SelectOption> getPicklistValuesAsSelectOptions(Schema.SObjectField sObjectField, Set<String> excuding) {\n' +
        '            List<jam.SelectOption> selectOptions = new List<jam.SelectOption>();\n' +
        '            List<Schema.PicklistEntry> pickListEntries = sObjectField.getDescribe().getPicklistValues();\n' +
        '\n' +
        '            for (Schema.PicklistEntry pickListEntry : pickListEntries) {\n' +
        '                if (excuding == null || !excuding.contains(pickListEntry.getValue())) {\n' +
        '                    selectOptions.add(new jam.SelectOption(pickListEntry.getValue(), pickListEntry.getLabel()));\n' +
        '                }\n' +
        '            }\n' +
        '            return selectOptions;\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, List<jam.SelectOption>> getPicklistOptionsMap(Set<SObjectField> fields) {\n' +
        '\n' +
        '            Map<String, List<jam.SelectOption>> result = new Map<String, List<jam.SelectOption>>();\n' +
        '\n' +
        '            for (SObjectField field : fields) {\n' +
        '                String key = this.getFieldKey(field);\n' +
        '                result.put(key, this.getPicklistValuesAsSelectOptions(field));\n' +
        '            }\n' +
        '\n' +
        '            return result;\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, Map<String, List<jam.SelectOption>>> getDependentPicklistOptionsMap(Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType) {\n' +
        '\n' +
        '            Map<String, Map<String, List<jam.SelectOption>>> result = new Map<String, Map<String, List<jam.SelectOption>>>();\n' +
        '\n' +
        '            for (SObjectType sObjectType : dependentFieldsBySObjectType.keySet()) {\n' +
        '                Map<SObjectField, SObjectField> dependentFields = dependentFieldsBySObjectType.get(sObjectType);\n' +
        '                if (dependentFields != null) {\n' +
        '                    for (SObjectField dependentField : dependentFields.keySet()) {\n' +
        '                        SObjectField controllingField = dependentFields.get(dependentField);\n' +
        '\n' +
        '                        String key = this.getFieldKey(dependentField);\n' +
        '                        result.put(key, this.getDependentOptions(sObjectType, controllingField, dependentField));\n' +
        '                    }\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return result;\n' +
        '        }\n' +
        '\n' +
        '        private String getFieldKey(SObjectField field) {\n' +
        '            return sObjects.fieldToProperty(field) + \'Options\';\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, List<jam.SelectOption>> getDependentOptions(Schema.SObjectType pType, Schema.SObjectField controllingField, Schema.SObjectField dependentField) {\n' +
        '            Map<String, List<jam.SelectOption>> mapResults = new Map<String, List<jam.SelectOption>>();\n' +
        '\n' +
        '            final String pControllingFieldName = controllingField.getDescribe().getName();\n' +
        '            final String pDependentFieldName = dependentField.getDescribe().getName();\n' +
        '\n' +
        '            //verify/get object schema\n' +
        '            if (pType == null) return mapResults;\n' +
        '            Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();\n' +
        '\n' +
        '            //verify field names\n' +
        '            if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;\n' +
        '\n' +
        '            //get the control & dependent values\n' +
        '            List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();\n' +
        '            List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();\n' +
        '\n' +
        '            //clear heap\n' +
        '            objFieldMap = null;\n' +
        '\n' +
        '            //initialize results mapping\n' +
        '            for (Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++) {\n' +
        '                mapResults.put(ctrl_ple[pControllingIndex].getValue(), new List<jam.SelectOption>());\n' +
        '            }\n' +
        '            //cater for null and empty\n' +
        '            mapResults.put(\'\', new List<jam.SelectOption>());\n' +
        '            mapResults.put(null, new List<jam.SelectOption>());\n' +
        '\n' +
        '\n' +
        '            //serialize dep entries\n' +
        '            List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();\n' +
        '\n' +
        '            objDS_Entries = (List<TPicklistEntry>) JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);\n' +
        '\n' +
        '            List<Integer> validIndexes;\n' +
        '            for (TPicklistEntry objDepPLE : objDS_Entries) {\n' +
        '\n' +
        '                validIndexes = cnvBits(objDepPLE.validFor);\n' +
        '\n' +
        '                for (Integer validIndex : validIndexes) {\n' +
        '                    mapResults.get(ctrl_ple[validIndex - 1].getValue()).add(new jam.SelectOption(objDepPLE.value, objDepPLE.label));\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            //clear heap\n' +
        '            objDS_Entries = null;\n' +
        '\n' +
        '            mapResults.remove(null);\n' +
        '            mapResults.remove(\'\');\n' +
        '\n' +
        '            return mapResults;\n' +
        '        }\n' +
        '\n' +
        '        public void convertFlowPicklistFieldValues(SObject recordVar) {\n' +
        '            Set<SObjectField> picklistFields = jam.sObjects.getFieldsByTypes(recordVar.getSObjectType(), new Set<DisplayType>{\n' +
        '                    DisplayType.PICKLIST\n' +
        '            });\n' +
        '            Map<String, Object> populatedFieldsMap = recordVar.getPopulatedFieldsAsMap();\n' +
        '            for (SObjectField fieldVar : picklistFields) {\n' +
        '                if (!populatedFieldsMap.containsKey(\'\' + fieldVar)) {\n' +
        '                    continue;\n' +
        '                }\n' +
        '                try {\n' +
        '                    Object val = recordVar.get(fieldVar);\n' +
        '                    if (val == null) {\n' +
        '                        continue;\n' +
        '                    }\n' +
        '                    String strVal = \'\' + val;\n' +
        '                    recordVar.put(fieldVar, strVal);\n' +
        '                } catch (Exception e) {\n' +
        '                }\n' +
        '            }\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class DateExtensions {\n' +
        '\n' +
        '        public Datetime parseDatetimeAnyFormat(String datetimeStr, String format) {\n' +
        '            return this.parseDatetimeAnyFormat(datetimeStr, format, false);\n' +
        '        }\n' +
        '\n' +
        '        public Datetime parseDatetimeAnyFormat(String datetimeStr, String format, Boolean isGMT) {\n' +
        '            if (String.isBlank(datetimeStr)) {\n' +
        '                return null;\n' +
        '            }\n' +
        '\n' +
        '            Datetime datetimeVar = null;\n' +
        '\n' +
        '            try {\n' +
        '\n' +
        '                String formatDelimiters = format.replaceAll(\'DD|dd|d|MM|M|YYYY|yyyy|YY|yy|mm|m|HH|hh|H|h|SS|ss|S|s|A|a\', \'##\');\n' +
        '\n' +
        '                Set<String> delimitersSet = new Set<String>(formatDelimiters.split(\'##\'));\n' +
        '                delimitersSet.remove(null);\n' +
        '                delimitersSet.remove(\'\');\n' +
        '                delimitersSet.add(\' \');\n' +
        '                List<String> delimiters = new List<String>(delimitersSet);\n' +
        '\n' +
        '                String formatPartsStr = format.replaceAll(\'[[\' + String.join(delimiters, \']]|[[\') + \']]\', \'~\');\n' +
        '\n' +
        '                List<String> formatParts = formatPartsStr.split(\'~\');\n' +
        '\n' +
        '                String datetimePartsStr = datetimeStr.replaceAll(\'[[\' + String.join(delimiters, \']]|[[\') + \']]\', \'~\');\n' +
        '\n' +
        '                List<String> datetimeParts = datetimePartsStr.split(\'~\');\n' +
        '\n' +
        '                Datetime now = Datetime.now();\n' +
        '                Integer year = now.year();\n' +
        '                Integer month = now.month();\n' +
        '                Integer day = now.day();\n' +
        '                Integer hour = now.hour();\n' +
        '                Integer minute = now.minute();\n' +
        '                Integer second = now.second();\n' +
        '                String a;\n' +
        '\n' +
        '                for (Integer i = 0; i < formatParts.size(); i++) {\n' +
        '                    String formatPart = formatParts[i];\n' +
        '                    String value = datetimeParts[i];\n' +
        '\n' +
        '                    if (\'yyyy\'.equalsIgnoreCase(formatPart)) {\n' +
        '                        year = Integer.valueOf(value);\n' +
        '                    }\n' +
        '                    if (\'yy\'.equalsIgnoreCase(formatPart)) {\n' +
        '                        year = Integer.valueOf(value) + 2000;\n' +
        '                    }\n' +
        '                    if (\'MM\'.equals(formatPart) || \'M\'.equals(formatPart)) {\n' +
        '                        month = Integer.valueOf(value);\n' +
        '                    }\n' +
        '                    if (\'dd\'.equalsIgnoreCase(formatPart) || \'d\'.equalsIgnoreCase(formatPart)) {\n' +
        '                        day = Integer.valueOf(value);\n' +
        '                    }\n' +
        '                    if (\'hh\'.equalsIgnoreCase(formatPart) || \'h\'.equalsIgnoreCase(formatPart)) {\n' +
        '                        hour = Integer.valueOf(value);\n' +
        '                    }\n' +
        '                    if (\'mm\'.equals(formatPart) || \'m\'.equals(formatPart)) {\n' +
        '                        minute = Integer.valueOf(value);\n' +
        '                    }\n' +
        '                    if (\'ss\'.equalsIgnoreCase(formatPart) || \'s\'.equalsIgnoreCase(formatPart)) {\n' +
        '                        second = Integer.valueOf(value);\n' +
        '                    }\n' +
        '                    if (\'a\'.equalsIgnoreCase(formatPart)) {\n' +
        '                        a = value;\n' +
        '                    }\n' +
        '                }\n' +
        '\n' +
        '                if (\'AM\'.equalsIgnoreCase(a)) {\n' +
        '                    if (hour == 12) {\n' +
        '                        hour = 0;\n' +
        '                    }\n' +
        '                } else if (\'PM\'.equalsIgnoreCase(a)) {\n' +
        '                    if (hour != 12) {\n' +
        '                        hour = hour + 12;\n' +
        '                    }\n' +
        '                }\n' +
        '\n' +
        '                datetimeVar = Datetime.newInstance(year, month, day, hour, minute, second);\n' +
        '\n' +
        '                if (isGMT) {\n' +
        '                    datetimeVar = Datetime.newInstanceGmt(year, month, day, hour, minute, second);\n' +
        '                } else {\n' +
        '                    datetimeVar = Datetime.newInstance(year, month, day, hour, minute, second);\n' +
        '                }\n' +
        '\n' +
        '            } catch (Exception ex) {\n' +
        '                ex.setMessage(\'Invalid date: \' + datetimeStr + \': \' + ex.getMessage());\n' +
        '                throw ex;\n' +
        '            }\n' +
        '\n' +
        '            return datetimeVar;\n' +
        '        }\n' +
        '\n' +
        '        public Datetime parseDatetimeAusFormat(String datetimeStr) {\n' +
        '            return this.parseDatetimeAnyFormat(datetimeStr, \'dd/MM/yyyy hh:mm a\');\n' +
        '        }\n' +
        '\n' +
        '        public Date parseDateAnyFormat(String dateStr, String format) {\n' +
        '            return datetimeToDate(this.parseDatetimeAnyFormat(dateStr, format));\n' +
        '        }\n' +
        '\n' +
        '        public Date parseDateAusFormat(String dateStr) {\n' +
        '            return this.parseDateAnyFormat(dateStr, \'dd/MM/yyyy\');\n' +
        '        }\n' +
        '\n' +
        '        public Date datetimeToDate(Datetime datetimeVar) {\n' +
        '            return datetimeVar != null ? datetimeVar.date() : null;\n' +
        '        }\n' +
        '\n' +
        '        public Datetime dateToDateTime(Date d) {\n' +
        '            return Datetime.newInstance(d.year(), d.month(), d.day(), 0, 0, 0);\n' +
        '        }\n' +
        '\n' +
        '        public Integer totalWorkingDays(Date startDate, Date endDate) {\n' +
        '\n' +
        '            Datetime sdate = dateToDateTime(startDate);\n' +
        '            Datetime edate = dateToDateTime(endDate);\n' +
        '\n' +
        '            Integer i = 0;\n' +
        '\n' +
        '            while (sdate <= edate) {\n' +
        '                if (isWorkingDay(sdate) == true) {\n' +
        '                    i = i + 1;\n' +
        '                }\n' +
        '                sdate = sdate.addDays(1);\n' +
        '            }\n' +
        '\n' +
        '            return i;\n' +
        '\n' +
        '        }\n' +
        '\n' +
        '        public Boolean isWorkingDay(Date d) {\n' +
        '            Datetime dt = dateToDateTime(d);\n' +
        '            return isWorkingDay(dt);\n' +
        '        }\n' +
        '\n' +
        '        public Boolean isWorkingDay(Datetime dt) {\n' +
        '            return (dt.format(\'E\') != \'Sat\' && dt.format(\'E\') != \'Sun\');\n' +
        '        }\n' +
        '\n' +
        '        public Time timeStringToTime(String t) {\n' +
        '            String[] arr = t.split(\':\');\n' +
        '            return Time.newInstance(\n' +
        '                    Integer.valueOf(arr[0]),\n' +
        '                    Integer.valueOf(arr[1]),\n' +
        '                    0,\n' +
        '                    0\n' +
        '            );\n' +
        '        }\n' +
        '\n' +
        '        public Time timeStringAMPMToTime(String t) {\n' +
        '\n' +
        '            if (String.isBlank(t)) {\n' +
        '                throw new jam.MissingDataException(\'Time Argument is null\');\n' +
        '            }\n' +
        '\n' +
        '            List<String> timeParts = t.split(\' \');\n' +
        '            List<String> hoursMinutes = timeParts.get(0).split(\':\');\n' +
        '\n' +
        '            String amPMStr = timeParts.get(1);\n' +
        '            String hoursStr = hoursMinutes.get(0);\n' +
        '            String minutesStr = hoursMinutes.get(1);\n' +
        '\n' +
        '            Integer hours = Integer.valueOf(hoursStr);\n' +
        '            Integer minutes = Integer.valueOf(minutesStr);\n' +
        '\n' +
        '            if (\'AM\'.equals(amPMStr)) {\n' +
        '                if (hours == 12) {\n' +
        '                    hours = 0;\n' +
        '                }\n' +
        '            } else if (\'PM\'.equals(amPMStr)) {\n' +
        '                if (hours != 12) {\n' +
        '                    hours = hours + 12;\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return Time.newInstance(\n' +
        '                    hours,\n' +
        '                    minutes,\n' +
        '                    0,\n' +
        '                    0\n' +
        '            );\n' +
        '        }\n' +
        '\n' +
        '        public Datetime datetimeStringToDatetime(String dt) {\n' +
        '            if (String.isBlank(dt)) {\n' +
        '                throw new jam.MissingDataException(\'Datetime string argument is null\');\n' +
        '            }\n' +
        '\n' +
        '            return (Datetime) JSON.deserialize(dt, Datetime.class);\n' +
        '        }\n' +
        '\n' +
        '\n' +
        '        public Datetime getStartOfDay(Datetime dateTimeVar) {\n' +
        '            return Datetime.newInstance(dateTimeVar.year(), dateTimeVar.month(), dateTimeVar.day(), 0, 0, 0);\n' +
        '        }\n' +
        '\n' +
        '        public Datetime getEndOfDay(Datetime dateTimeVar) {\n' +
        '            return Datetime.newInstance(dateTimeVar.year(), dateTimeVar.month(), dateTimeVar.day(), 23, 59, 9);\n' +
        '        }\n' +
        '\n' +
        '        public Datetime getStartDateOfWeek(Datetime dateTimeVar) {\n' +
        '            Integer dayOfWeek = Integer.valueOf(dateTimeVar.format(\'u\'));\n' +
        '            Datetime startDateOfWeek = dateTimeVar.addDays(-1 * (dayOfWeek - 1));\n' +
        '            return getStartOfDay(startDateOfWeek);\n' +
        '        }\n' +
        '\n' +
        '        public Date getStartDateOfWeek(Date dateVar) {\n' +
        '            return getStartDateOfWeek(dateToDateTime(dateVar)).date();\n' +
        '        }\n' +
        '\n' +
        '        public Datetime getEndDateOfWeek(Datetime dateTimeVar) {\n' +
        '            return getEndOfDay(getStartDateOfWeek(dateTimeVar).addDays(6));\n' +
        '        }\n' +
        '\n' +
        '        public Date getEndDateOfWeek(Date dateVar) {\n' +
        '            return getEndDateOfWeek(dateToDateTime(dateVar)).date();\n' +
        '        }\n' +
        '\n' +
        '        public Boolean isDateInCurrentWeekOrInFuture(Date dateVar) {\n' +
        '            return dateVar >= getStartDateOfWeek(Date.today());\n' +
        '        }\n' +
        '\n' +
        '        public Date getLastDayInMonth(Date dateVar) {\n' +
        '            return dateVar.addMonths(1).toStartOfMonth().addDays(-1);\n' +
        '        }\n' +
        '\n' +
        '        public Date getLastWorkingDay(Date dateVar) {\n' +
        '            while (!isWorkingDay(dateVar)) {\n' +
        '                dateVar = dateVar.addDays(-1);\n' +
        '            }\n' +
        '            return dateVar;\n' +
        '        }\n' +
        '\n' +
        '        public Date getLastDayInFortnight(Date dateVar, Date startDate) {\n' +
        '            if (dateVar < startDate) {\n' +
        '                throw new jam.ProcessException(\'getLastDayInFortnight error: Date should be greater than Period Start Date\');\n' +
        '            }\n' +
        '\n' +
        '            Date startOfThePeriod = getStartDateOfWeek(startDate);\n' +
        '            Date endOfThePeriod = startOfThePeriod.addDays(13);\n' +
        '\n' +
        '            while (dateVar > endOfThePeriod) {\n' +
        '                endOfThePeriod = endOfThePeriod.addDays(14);\n' +
        '            }\n' +
        '\n' +
        '            return endOfThePeriod;\n' +
        '        }\n' +
        '\n' +
        '        public Date getFirstDayInFortnight(Date dateVar, Date startDate) {\n' +
        '            Date endOfThePeriod = getLastDayInFortnight(dateVar, startDate);\n' +
        '            return endOfThePeriod.addDays(-13);\n' +
        '        }\n' +
        '\n' +
        '        public Date detectDateInRange(Date firstDate, Date secondDate, Date thirdDate) {\n' +
        '\n' +
        '            Date dateVar = secondDate > firstDate ? secondDate : firstDate;\n' +
        '            dateVar = thirdDate < firstDate ? thirdDate : firstDate;\n' +
        '\n' +
        '            return dateVar;\n' +
        '        }\n' +
        '\n' +
        '        public Boolean dateInRange(Date dateVar, Date startOfRange, Date endOfRange, Boolean allowCrossing) {\n' +
        '            return allowCrossing == true ? (dateVar >= startOfRange && dateVar <= endOfRange) : (dateVar > startOfRange && dateVar < endOfRange);\n' +
        '        }\n' +
        '\n' +
        '        public Boolean crossingDateRanges(Datetime date1start, Datetime date1end, Datetime date2start, Datetime date2end) {\n' +
        '            return !(date1end <= date2start || date1start >= date2end);\n' +
        '        }\n' +
        '\n' +
        '        public Integer age(Date birthDate, Date onDate) {\n' +
        '            Date birthDateOnDate = Date.newInstance(\n' +
        '                    onDate.year(),\n' +
        '                    birthDate.month(),\n' +
        '                    birthDate.day()\n' +
        '            );\n' +
        '            Integer age = onDate.year() - birthDate.year();\n' +
        '            return Math.max(birthDateOnDate > onDate ? age - 1 : age, 0);\n' +
        '        }\n' +
        '\n' +
        '        public Integer age(Date birthDate) {\n' +
        '            return age(birthDate, Date.today());\n' +
        '        }\n' +
        '\n' +
        '        public Date max(List<Date> dates) {\n' +
        '            Date maxDate;\n' +
        '            for (Date dateVar : dates) {\n' +
        '                if (maxDate == null || dateVar > maxDate) {\n' +
        '                    maxDate = dateVar;\n' +
        '                }\n' +
        '            }\n' +
        '            return maxDate;\n' +
        '        }\n' +
        '\n' +
        '        public Date max(Date date1, Date date2) {\n' +
        '            return max(new List<Date>{\n' +
        '                    date1,\n' +
        '                    date2\n' +
        '            });\n' +
        '        }\n' +
        '\n' +
        '        public Date min(List<Date> dates) {\n' +
        '            Date minDate;\n' +
        '            for (Date dateVar : dates) {\n' +
        '                if (minDate == null || dateVar < minDate) {\n' +
        '                    minDate = dateVar;\n' +
        '                }\n' +
        '            }\n' +
        '            return minDate;\n' +
        '        }\n' +
        '\n' +
        '        public Date min(Date date1, Date date2) {\n' +
        '            return min(new List<Date>{\n' +
        '                    date1,\n' +
        '                    date2\n' +
        '            });\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class StringExtensions {\n' +
        '        public String defaultIfBlank(String str, String defaultValue) {\n' +
        '            return String.isBlank(str) ? defaultValue : str;\n' +
        '        }\n' +
        '\n' +
        '        public String emptyStringIfNull(String str) {\n' +
        '            return String.isBlank(str) ? \'\' : str;\n' +
        '        }\n' +
        '\n' +
        '        public String newGuid() {\n' +
        '            return EncodingUtil.convertToHex(Crypto.generateAesKey(128));\n' +
        '        }\n' +
        '\n' +
        '        public String newUuid() {\n' +
        '            return UUID.randomUUID().toString();\n' +
        '        }\n' +
        '\n' +
        '        public String joinNonBlank(List<String> parts, String separator) {\n' +
        '            List<String> notBlankParts = new List<String>();\n' +
        '\n' +
        '            for (String part : parts) {\n' +
        '                if (String.isNotBlank(part)) {\n' +
        '                    notBlankParts.add(part);\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return String.join(notBlankParts, separator);\n' +
        '        }\n' +
        '\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class UserExtensions {\n' +
        '        public Boolean hasPermSetAssigned(String userId, String permSetName) {\n' +
        '            List<String> permSetChunks = permSetName.split(\'\\\\.\');\n' +
        '            String namespace = permSetChunks.size() > 1 ? permSetChunks[0] : null;\n' +
        '            String name = permSetChunks.size() > 1 ? permSetChunks[1] : permSetChunks[0];\n' +
        '\n' +
        '            return [\n' +
        '                    SELECT COUNT()\n' +
        '                    FROM PermissionSetAssignment\n' +
        '                    WHERE AssigneeId = :userId\n' +
        '                    AND PermissionSet.Name = :name\n' +
        '                    AND PermissionSet.NamespacePrefix = :namespace\n' +
        '                    WITH USER_MODE\n' +
        '            ] > 0;\n' +
        '        }\n' +
        '\n' +
        '        public Boolean hasPermSetAssigned(String permSetName) {\n' +
        '            return hasPermSetAssigned(UserInfo.getUserId(), permSetName);\n' +
        '        }\n' +
        '\n' +
        '        public void assertPermSet(String permSetName, String errorMessage) {\n' +
        '            if (!hasPermSetAssigned(permSetName)) {\n' +
        '                throw new jam.ProcessException(errorMessage);\n' +
        '            }\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public enum Operation {\n' +
        '        OP_INSERT, OP_UPDATE, OP_DELETE, OP_UPSERT\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class SObjectExtensions {\n' +
        '\n' +
        '        public void assertReadable(List<SObject> records) {\n' +
        '            assertAccessType(records, AccessType.READABLE);\n' +
        '        }\n' +
        '\n' +
        '        public void assertReadable(SObject record) {\n' +
        '            assertReadable(new List<SObject>{\n' +
        '                    record\n' +
        '            });\n' +
        '        }\n' +
        '\n' +
        '        public void assertAccessType(List<SObject> records, AccessType accessType) {\n' +
        '            if (records.isEmpty()) {\n' +
        '                return;\n' +
        '            }\n' +
        '            SObjectType sObjTypeVar = records.get(0).getSObjectType();\n' +
        '            try {\n' +
        '                SObjectAccessDecision decision = Security.stripInaccessible(\n' +
        '                        accessType,\n' +
        '                        records\n' +
        '                );\n' +
        '                records = decision.getRecords();\n' +
        '            } catch (System.NoAccessException ex) {\n' +
        '                throw new jam.ProcessException(\'No \' + accessType + \' Access to entity of type: \' + sObjTypeVar);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public Set<Id> getIdFieldValues(List<SObject> records, Schema.SObjectField field) {\n' +
        '            return getIdFieldValues(records, \'\' + field);\n' +
        '        }\n' +
        '\n' +
        '        public Set<Id> getIdFieldValues(List<SObject> records, String fieldName) {\n' +
        '\n' +
        '            Set<Id> values = new Set<Id>();\n' +
        '\n' +
        '            for (SObject rec : records) {\n' +
        '                Id value = (Id) rec.get(fieldName);\n' +
        '                if (value != null) {\n' +
        '                    values.add(value);\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return values;\n' +
        '\n' +
        '        }\n' +
        '\n' +
        '        public Set<String> getStringFieldValues(List<SObject> records, Schema.SObjectField field) {\n' +
        '            return getStringFieldValues(records, \'\' + field);\n' +
        '        }\n' +
        '\n' +
        '        public List<SObject> setFieldValue(List<SObject> records, Schema.SObjectField field, Object value) {\n' +
        '            for (SObject record : records) {\n' +
        '                record.put(field, value);\n' +
        '            }\n' +
        '            return records;\n' +
        '        }\n' +
        '\n' +
        '        public List<SObject> setFieldsValues(List<SObject> records, Map<SObjectField, Object> fieldsValues) {\n' +
        '            for (SObject record : records) {\n' +
        '                for (SObjectField field : fieldsValues.keySet()) {\n' +
        '                    record.put(field, fieldsValues.get(field));\n' +
        '                }\n' +
        '            }\n' +
        '            return records;\n' +
        '        }\n' +
        '\n' +
        '        public Set<String> getStringFieldValues(List<SObject> records, String fieldName) {\n' +
        '\n' +
        '            Set<String> values = new Set<String>();\n' +
        '\n' +
        '            for (SObject rec : records) {\n' +
        '                String value = rec.get(fieldName) == null ? null : String.valueOf(rec.get(fieldName));\n' +
        '                if (value != null) {\n' +
        '                    values.add(value);\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return values;\n' +
        '\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, SObject> getSObjectsByAnyFieldMap(List<SObject> sObjects, Schema.SObjectField sObjectField) {\n' +
        '            return getSObjectsByAnyFieldMap(sObjects, \'\' + sObjectField);\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, SObject> getSObjectsByAnyFieldMap(List<SObject> sObjects, String sObjectField) {\n' +
        '            Map<String, SObject> resultMap = new Map<String, SObject>();\n' +
        '            for (SObject record : sObjects) {\n' +
        '                String value = (String) record.get(sObjectField);\n' +
        '                if (value != null) {\n' +
        '                    resultMap.put(value, record);\n' +
        '                }\n' +
        '            }\n' +
        '            return resultMap;\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, List<SObject>> getSObjectsListByAnyFieldMap(List<SObject> sObjects, Schema.SObjectField sObjectField) {\n' +
        '            return getSObjectsListByAnyFieldMap(sObjects, \'\' + sObjectField);\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, List<SObject>> getSObjectsListByAnyFieldMap(List<SObject> sObjects, String sObjectField) {\n' +
        '            Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();\n' +
        '            for (SObject record : sObjects) {\n' +
        '                String value = (String) record.get(sObjectField);\n' +
        '                if (value != null) {\n' +
        '                    if (resultMap.containsKey(value)) {\n' +
        '                        resultMap.get(value).add(record);\n' +
        '                    } else {\n' +
        '                        resultMap.put(value, new List<SObject>{\n' +
        '                                record\n' +
        '                        });\n' +
        '                    }\n' +
        '                }\n' +
        '            }\n' +
        '            return resultMap;\n' +
        '        }\n' +
        '\n' +
        '        public String fieldToProperty(SObjectField field) {\n' +
        '            return fieldNameToProperty(field.getDescribe().getName());\n' +
        '        }\n' +
        '\n' +
        '        public String fieldNameToProperty(String fieldName) {\n' +
        '            if (String.isBlank(fieldName)) return \'\';\n' +
        '\n' +
        '            List<String> parts = new List<String>();\n' +
        '\n' +
        '            fieldName = fieldName.replace(\'__c\', \'\');\n' +
        '            fieldName = fieldName.replace(\'__s\', \'\');\n' +
        '\n' +
        '            String namespace = \'\';\n' +
        '            if (fieldName.contains(\'__\')) {\n' +
        '                namespace = fieldName.substringBefore(\'__\').toLowerCase();\n' +
        '                fieldName = fieldName.substringAfter(\'__\');\n' +
        '            }\n' +
        '\n' +
        '            for (String part : fieldName.split(\'_\')) {\n' +
        '                parts.add(part.substring(0, 1).toUpperCase() + part.substring(1));\n' +
        '            }\n' +
        '\n' +
        '            String property = namespace + String.join(parts, \'\');\n' +
        '            property = property.isAllUpperCase() ? property : property.substring(0, 1).toLowerCase() + property.substring(1);\n' +
        '\n' +
        '            return property;\n' +
        '        }\n' +
        '\n' +
        '        public RecordTypeInfo recordTypeByAPIName(SObjectType sObjectTypeVar, String apiName) {\n' +
        '            return sObjectTypeVar.getDescribe().getRecordTypeInfosByDeveloperName().get(apiName);\n' +
        '        }\n' +
        '\n' +
        '        public Id recordTypeIdByAPIName(SObjectType sObjectTypeVar, String apiName) {\n' +
        '            RecordTypeInfo recType = this.recordTypeByAPIName(sObjectTypeVar, apiName);\n' +
        '            if (recType == null) {\n' +
        '                throw new jam.MissingDataException(\'No Record Type for: \' + sObjectTypeVar + \' with API Name: \' + apiName);\n' +
        '            }\n' +
        '            return recType.getRecordTypeId();\n' +
        '        }\n' +
        '\n' +
        '        public jam.SelectOption toSelectOption(SObject sObj, String valueFieldName, String labelFieldName) {\n' +
        '            return new jam.SelectOption(\n' +
        '                    (String) sObj.get(valueFieldName),\n' +
        '                    (String) sObj.get(labelFieldName)\n' +
        '            );\n' +
        '        }\n' +
        '\n' +
        '        public jam.SelectOption toSelectOption(SObject sObj, String labelFieldName) {\n' +
        '            return new jam.SelectOption(\n' +
        '                    (String) sObj.get(\'Id\'),\n' +
        '                    (String) sObj.get(labelFieldName)\n' +
        '            );\n' +
        '        }\n' +
        '\n' +
        '        public jam.SelectOption toSelectOption(SObject sObj) {\n' +
        '            return new jam.SelectOption(\n' +
        '                    (String) sObj.get(\'Id\'),\n' +
        '                    (String) sObj.get(\'Name\')\n' +
        '            );\n' +
        '        }\n' +
        '\n' +
        '        public List<jam.SelectOption> toSelectOptions(List<SObject> sObjects, String valueFieldName, String labelFieldName) {\n' +
        '            List<jam.SelectOption> options = new List<jam.SelectOption>();\n' +
        '\n' +
        '            for (SObject sObj : sObjects) {\n' +
        '                options.add(toSelectOption(sObj, valueFieldName, labelFieldName));\n' +
        '            }\n' +
        '\n' +
        '            return options;\n' +
        '        }\n' +
        '\n' +
        '        public List<jam.SelectOption> toSelectOptions(List<System.SelectOption> selectOptions) {\n' +
        '            List<jam.SelectOption> options = new List<jam.SelectOption>();\n' +
        '            for (System.SelectOption option : selectOptions) {\n' +
        '                options.add(new jam.SelectOption(option.getValue().replaceAll(\' \', \'_\'), option.getLabel()));\n' +
        '            }\n' +
        '            return options;\n' +
        '        }\n' +
        '\n' +
        '        public List<jam.SelectOption> toSelectOptions(List<SObject> sObjects, String labelFieldName) {\n' +
        '            return toSelectOptions(sObjects, \'Id\', labelFieldName);\n' +
        '        }\n' +
        '\n' +
        '        public List<jam.SelectOption> toSelectOptions(List<SObject> sObjects) {\n' +
        '            return toSelectOptions(sObjects, \'Id\', \'Name\');\n' +
        '        }\n' +
        '\n' +
        '        public void swap(SObject record, SObjectField field1, SObjectField field2) {\n' +
        '            Object valueOfField1 = record.get(field1);\n' +
        '            record.put(field1, record.get(field2));\n' +
        '            record.put(field2, valueOfField1);\n' +
        '        }\n' +
        '\n' +
        '        public SObjectType stringToSObjectType(String sObjectTypeStr) {\n' +
        '            jam.objects.throwIfBlank(sObjectTypeStr, \'No SObjectType\');\n' +
        '\n' +
        '            SObjectType sObjectTypeVar = Schema.getGlobalDescribe().get(sObjectTypeStr.toLowerCase());\n' +
        '            jam.objects.throwIfNull(sObjectTypeVar, \'No SObjectType with API Name: \' + sObjectTypeStr);\n' +
        '\n' +
        '            return sObjectTypeVar;\n' +
        '        }\n' +
        '\n' +
        '        public Set<SObjectField> getFieldsByTypes(SObjectType sObjType, Set<DisplayType> types) {\n' +
        '            Set<SObjectField> fields = new Set<SObjectField>();\n' +
        '            for (SObjectField field : sObjType.getDescribe().fields.getMap().values()) {\n' +
        '                if (types.contains(field.getDescribe().type)) {\n' +
        '                    fields.add(field);\n' +
        '                }\n' +
        '            }\n' +
        '            return fields;\n' +
        '        }\n' +
        '\n' +
        '        public Boolean isSomeFieldChanged(SObject record, SObject existingRecord, List<String> fields) {\n' +
        '            if (fields == null) {\n' +
        '                throw new jam.MissingDataException(\'fields argument is missing\');\n' +
        '            }\n' +
        '\n' +
        '            if (existingRecord == null) {\n' +
        '                throw new jam.MissingDataException(\'record argument is missing\');\n' +
        '            }\n' +
        '\n' +
        '            if (record == null) {\n' +
        '                throw new jam.MissingDataException(\'existingRecord argument is missing\');\n' +
        '            }\n' +
        '\n' +
        '            for (String field : fields) {\n' +
        '                Object newFieldValue = record.get(field);\n' +
        '                Object oldFieldValue = existingRecord.get(field);\n' +
        '\n' +
        '                if (newFieldValue != oldFieldValue) {\n' +
        '                    return true;\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return false;\n' +
        '        }\n' +
        '\n' +
        '        public Boolean isSomeFieldChanged(SObject record, SObject existingRecord, List<SObjectField> fields) {\n' +
        '            if (fields == null) {\n' +
        '                throw new jam.MissingDataException(\'fields argument is missing\');\n' +
        '            }\n' +
        '\n' +
        '            if (existingRecord == null) {\n' +
        '                throw new jam.MissingDataException(\'record argument is missing\');\n' +
        '            }\n' +
        '\n' +
        '            if (record == null) {\n' +
        '                throw new jam.MissingDataException(\'existingRecord argument is missing\');\n' +
        '            }\n' +
        '\n' +
        '            List<String> fieldsStrings = new List<String>();\n' +
        '            for (SObjectField field : fields) {\n' +
        '                fieldsStrings.add(field.getDescribe().getName());\n' +
        '            }\n' +
        '            return isSomeFieldChanged(record, existingRecord, fieldsStrings);\n' +
        '        }\n' +
        '\n' +
        '        public Object getValueByPath(SObject recordVar, String path) {\n' +
        '            path = path.toLowerCase();\n' +
        '            List<String> pathItems = path.split(\'\\\\.\');\n' +
        '\n' +
        '            SObject targetSobjectVar = recordVar;\n' +
        '            while (pathItems.size() > 1 && targetSobjectVar != null) {\n' +
        '                String pathItem = pathItems.remove(0);\n' +
        '                targetSobjectVar = targetSobjectVar.getSObject(pathItem);\n' +
        '            }\n' +
        '\n' +
        '            return targetSobjectVar == null ? null : targetSobjectVar.get(pathItems.get(0));\n' +
        '        }\n' +
        '\n' +
        '        public void restoreNotBlankValues(List<SObject> records, Set<SObjectField> fields) {\n' +
        '            if (records != null && records.isEmpty() == false && fields != null && fields.isEmpty() == false) {\n' +
        '                SObjectType sObjectTypeVar = records.get(0).getSObjectType();\n' +
        '                jam.QueryFactory queryFactory = new jam.QueryFactory(sObjectTypeVar);\n' +
        '                queryFactory.selectField(\'Id\');\n' +
        '                queryFactory.selectFields(fields);\n' +
        '                queryFactory.setCondition(\'Id IN :records\');\n' +
        '                List<SObject> sourceRecords = Database.query(queryFactory.toSOQL());\n' +
        '                Map<Id, SObject> sourceRecordsMap = new Map<Id, SObject>(sourceRecords);\n' +
        '                for (SObject recordVar : records) {\n' +
        '                    SObject sourceRecordVar = sourceRecordsMap.get(recordVar.Id);\n' +
        '                    for (SObjectField preserveField : fields) {\n' +
        '                        Object sourceValue = sourceRecordVar.get(preserveField);\n' +
        '                        if (sourceValue != null) {\n' +
        '                            recordVar.put(preserveField, sourceValue);\n' +
        '                        }\n' +
        '                    }\n' +
        '                }\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public Boolean deduplicate(SObject recordVar) {\n' +
        '            return deduplicate(recordVar, null);\n' +
        '        }\n' +
        '\n' +
        '        public Boolean deduplicate(SObject recordVar, Set<SObjectField> preserveFields) {\n' +
        '            return deduplicate(recordVar, preserveFields, null);\n' +
        '        }\n' +
        '\n' +
        '        public Boolean deduplicate(SObject recordVar, Set<SObjectField> preserveFields, String duplicateRuleName) {\n' +
        '            if (recordVar == null || recordVar.Id != null) {\n' +
        '                return false;\n' +
        '            }\n' +
        '\n' +
        '            try {\n' +
        '                Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(new List<SObject>{\n' +
        '                        recordVar\n' +
        '                });\n' +
        '                for (Datacloud.FindDuplicatesResult dupeResult : results) {\n' +
        '                    for (Datacloud.DuplicateResult dupeRes : dupeResult.getDuplicateResults()) {\n' +
        '                        if (String.isNotBlank(duplicateRuleName) && !duplicateRuleName.equals(dupeRes.getDuplicateRule())) {\n' +
        '                            continue;\n' +
        '                        }\n' +
        '\n' +
        '                        for (Datacloud.MatchResult matchRes : dupeRes.getMatchResults()) {\n' +
        '                            for (Datacloud.MatchRecord matchRec : matchRes.getMatchRecords()) {\n' +
        '                                recordVar.Id = (String) matchRec.getRecord().get(\'id\');\n' +
        '                                jam.sObjects.restoreNotBlankValues(new List<SObject>{\n' +
        '                                        recordVar\n' +
        '                                }, preserveFields);\n' +
        '                                return true;\n' +
        '                            }\n' +
        '                        }\n' +
        '                    }\n' +
        '                }\n' +
        '            } catch (System.HandledException ex) { //No active duplicate rules are defined for the object type.\n' +
        '//                System.debug(ex.getMessage());\n' +
        '            } catch (Exception ex) {\n' +
        '//                System.debug(ex.getMessage()); // Other issue.\n' +
        '            }\n' +
        '            return false;\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, Object> getSObjectDescribe(List<SObjectType> sObjectTypes) {\n' +
        '            DTO dto = new DTO();\n' +
        '\n' +
        '            for (SObjectType sObjType : sObjectTypes) {\n' +
        '                DescribeSObjectResult sObjDescribe = sObjType.getDescribe();\n' +
        '                String sObjName = sObjDescribe.getName();\n' +
        '\n' +
        '                dto.put(sObjName + \'.name\', sObjDescribe.getName())\n' +
        '                        .put(sObjName + \'.localName\', sObjDescribe.getLocalName())\n' +
        '                        .put(sObjName + \'.label\', sObjDescribe.getLabel())\n' +
        '                        .put(sObjName + \'.pluralLabel\', sObjDescribe.getLabelPlural())\n' +
        '                        .put(sObjName + \'.keyPrefix\', sObjDescribe.getKeyPrefix());\n' +
        '\n' +
        '                for (SObjectField field : sObjDescribe.fields.getMap().values()) {\n' +
        '                    DescribeFieldResult fieldDescribe = field.getDescribe();\n' +
        '                    String fieldName = fieldDescribe.getName();\n' +
        '\n' +
        '                    dto.put(sObjName + \'.\' + fieldName + \'.name\', fieldDescribe.getName())\n' +
        '                            .put(sObjName + \'.\' + fieldName + \'.localName\', fieldDescribe.getLocalName())\n' +
        '                            .put(sObjName + \'.\' + fieldName + \'.label\', fieldDescribe.getLabel())\n' +
        '                            .put(sObjName + \'.\' + fieldName + \'.helpText\', fieldDescribe.getInlineHelpText())\n' +
        '                            .put(sObjName + \'.\' + fieldName + \'.defaultValue\', fieldDescribe.getDefaultValue())\n' +
        '                            .put(sObjName + \'.\' + fieldName + \'.type\', fieldDescribe.getType());\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return dto.dto;\n' +
        '        }\n' +
        '\n' +
        '        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects) {\n' +
        '            return sObjectsToMaps(sObjects, \'\');\n' +
        '        }\n' +
        '\n' +
        '        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects, Object defaultFieldValue) {\n' +
        '            return sObjectsToMaps(sObjects, defaultFieldValue, false);\n' +
        '        }\n' +
        '\n' +
        '        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects, Object defaultFieldValue, Boolean isAllFields) {\n' +
        '            return sObjectsToMaps(sObjects, defaultFieldValue, isAllFields, false);\n' +
        '        }\n' +
        '\n' +
        '        public List<Map<String, Object>> sObjectsToMaps(List<SObject> sObjects, Object defaultFieldValue, Boolean isAllFields, Boolean isVisualforce) {\n' +
        '            List<Map<String, Object>> sObjMaps = new List<Map<String, Object>>();\n' +
        '\n' +
        '            for (SObject sObj : sObjects) {\n' +
        '                sObjMaps.add(this.sObjectToMap(sObj, defaultFieldValue, isAllFields, isVisualforce));\n' +
        '            }\n' +
        '\n' +
        '            return sObjMaps;\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, Object> sObjectToMap(SObject sObj) {\n' +
        '            return sObjectToMap(sObj, \'\');\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, Object> sObjectToMap(SObject sObj, Object defaultFieldValue) {\n' +
        '            return sObjectToMap(sObj, defaultFieldValue, false);\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, Object> sObjectToMap(SObject sObj, Object defaultFieldValue, Boolean isAllFields) {\n' +
        '            return sObjectToMap(sObj, defaultFieldValue, isAllFields, false);\n' +
        '        }\n' +
        '\n' +
        '        public Map<String, Object> sObjectToMap(SObject sObj, Object defaultFieldValue, Boolean isAllFields, Boolean isVisualforce) {\n' +
        '            Map<String, Object> sObjMap = new Map<String, Object>();\n' +
        '\n' +
        '            Map<String, Object> populatedFieldsMap = sObj.getPopulatedFieldsAsMap();\n' +
        '            Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();\n' +
        '\n' +
        '            for (String fieldName : populatedFieldsMap.keySet()) {\n' +
        '                Object fieldValue = populatedFieldsMap.get(fieldName);\n' +
        '                SObjectField fieldVar = fieldsMap.get(fieldName);\n' +
        '\n' +
        '                if (fieldValue instanceof List<SObject>) {\n' +
        '                    // Skip related Lists\n' +
        '                    continue;\n' +
        '                }\n' +
        '\n' +
        '                if (fieldValue instanceof SObject) {\n' +
        '                    sObjMap.put(fieldName, this.sObjectToMap((SObject) fieldValue, defaultFieldValue, isAllFields, isVisualforce));\n' +
        '                    continue;\n' +
        '                }\n' +
        '\n' +
        '                if (isVisualforce == true && fieldValue != null && fieldVar != null) {\n' +
        '                    if (fieldVar.getDescribe().type == DisplayType.DATE) {\n' +
        '                        sObjMap.put(fieldName, jam.dates.dateToDateTime(((Date) fieldValue)).format(\'dd/MM/yyyy\'));\n' +
        '                        continue;\n' +
        '                    }\n' +
        '\n' +
        '                    if (fieldVar.getDescribe().type == DisplayType.DATETIME) {\n' +
        '                        sObjMap.put(fieldName, ((Datetime) fieldValue).format());\n' +
        '                        continue;\n' +
        '                    }\n' +
        '\n' +
        '                    if (fieldVar.getDescribe().type == DisplayType.TIME) {\n' +
        '                        sObjMap.put(fieldName, Datetime.newInstance(Date.today(), (Time) fieldValue).format(\'hh:mm a\'));\n' +
        '                        continue;\n' +
        '                    }\n' +
        '                }\n' +
        '\n' +
        '                sObjMap.put(fieldName, fieldValue == null ? defaultFieldValue : fieldValue);\n' +
        '            }\n' +
        '\n' +
        '            if (isAllFields == true) {\n' +
        '                for (SObjectField field : fieldsMap.values()) {\n' +
        '                    String fieldName = field.getDescribe().getName();\n' +
        '                    if (!populatedFieldsMap.containsKey(fieldName)) {\n' +
        '                        sObjMap.put(fieldName, defaultFieldValue);\n' +
        '                    }\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return sObjMap;\n' +
        '        }\n' +
        '\n' +
        '        public SObject mapToSObject(SObject sObj, Map<String, Object> sObjMap, Boolean skipValidation, Boolean isVisualforce) {\n' +
        '            Map<String, SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();\n' +
        '            for (String property : sObjMap.keySet()) {\n' +
        '\n' +
        '                SObjectField field = fieldsMap.get(property.toLowerCase());\n' +
        '\n' +
        '                if (field != null) {\n' +
        '                    try {\n' +
        '                        Object fieldValue = sObjMap.get(property);\n' +
        '                        if (fieldValue instanceof Long && (fieldValue instanceof Integer) == false) {\n' +
        '                            sObj.put(property, (Long) fieldValue);\n' +
        '                            continue;\n' +
        '                        }\n' +
        '\n' +
        '                        if (fieldValue instanceof String && String.isNotBlank((String) fieldValue)) {\n' +
        '                            String fieldValueStr = (String) fieldValue;\n' +
        '\n' +
        '                            DisplayType fieldDisplayType = field.getDescribe().type;\n' +
        '\n' +
        '                            if (fieldDisplayType == DisplayType.DATE) {\n' +
        '                                fieldValue = isVisualforce == true ? jam.dates.parseDateAusFormat(fieldValueStr) : Date.valueOf(fieldValueStr);\n' +
        '                            } else if (fieldDisplayType == DisplayType.DATETIME) {\n' +
        '                                if (isVisualforce == true) {\n' +
        '                                    fieldValue = jam.dates.parseDatetimeAusFormat(fieldValueStr);\n' +
        '                                } else {\n' +
        '                                    if (!fieldValueStr.startsWith(\'"\')) {\n' +
        '                                        fieldValueStr = \'"\' + fieldValueStr;\n' +
        '                                    }\n' +
        '                                    if (!fieldValueStr.endsWith(\'"\')) {\n' +
        '                                        fieldValueStr = fieldValueStr + \'"\';\n' +
        '                                    }\n' +
        '                                    fieldValue = jam.dates.datetimeStringToDatetime(fieldValueStr);\n' +
        '                                }\n' +
        '                            } else if (fieldDisplayType == DisplayType.TIME) {\n' +
        '                                if (isVisualforce == true) {\n' +
        '                                    Datetime dt = jam.dates.parseDatetimeAnyFormat(fieldValueStr, \'hh:mm a\');\n' +
        '                                    fieldValue = dt == null ? fieldValue : dt.time();\n' +
        '                                } else {\n' +
        '                                    fieldValue = fieldValueStr.toUpperCase().contains(\'AM\') || fieldValueStr.toUpperCase().contains(\'PM\') ?\n' +
        '                                            jam.dates.timeStringAMPMToTime(fieldValueStr.toUpperCase()) :\n' +
        '                                            jam.dates.timeStringToTime(fieldValueStr);\n' +
        '                                }\n' +
        '                            } else if (DisplayType.DOUBLE == fieldDisplayType || DisplayType.CURRENCY == fieldDisplayType) {\n' +
        '                                fieldValue = Decimal.valueOf(fieldValueStr);\n' +
        '                            } else if (DisplayType.INTEGER == fieldDisplayType) {\n' +
        '                                fieldValue = Integer.valueOf(fieldValueStr);\n' +
        '                            } else if (DisplayType.BASE64 == fieldDisplayType) {\n' +
        '                                fieldValue = EncodingUtil.base64Decode(fieldValueStr);\n' +
        '                            } else if (DisplayType.BOOLEAN == fieldDisplayType) {\n' +
        '                                fieldValue = Boolean.valueOf(fieldValue);\n' +
        '                            }\n' +
        '                        }\n' +
        '\n' +
        '                        sObj.put(property, fieldValue);\n' +
        '                        continue;\n' +
        '                    } catch (SObjectException ex) {\n' +
        '                    } catch (Exception ex) {\n' +
        '                        throw ex;\n' +
        '                    }\n' +
        '                }\n' +
        '\n' +
        '                if (property.endsWithIgnoreCase(\'__c\') && skipValidation != true) {\n' +
        '                    throw new jam.MissingDataException(String.format(\n' +
        '                            \'No Field with name {0} on {1}\',\n' +
        '                            new List<String>{\n' +
        '                                    property,\n' +
        '                                    \'\' + sObj\n' +
        '                            }\n' +
        '                    ));\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return sObj;\n' +
        '        }\n' +
        '\n' +
        '        // CRUD/FLS-safe DML operations. These honor the CRUD and FLS permissions of the running user\n' +
        '        public void insertAsUser(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            performDMLOperation(new List<SObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.\n' +
        '                    obj\n' +
        '            }, Operation.OP_INSERT);\n' +
        '        }\n' +
        '        public void updateAsUser(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            performDMLOperation(new List<SObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.\n' +
        '                    obj\n' +
        '            }, Operation.OP_UPDATE);\n' +
        '        }\n' +
        '        public void upsertAsUser(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            performDMLOperation(new List<SObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.\n' +
        '                    obj\n' +
        '            }, Operation.OP_UPSERT);\n' +
        '        }\n' +
        '        public void deleteAsUser(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            performDMLOperation(new List<SObject>{ // Bulkify Apex False Positive: there is an overridden Bulk method below used by this method.\n' +
        '                    obj\n' +
        '            }, Operation.OP_DELETE);\n' +
        '        }\n' +
        '\n' +
        '        public void insertAsUser(List<SObject> objList) {\n' +
        '            performDMLOperation(objList, Operation.OP_INSERT);\n' +
        '        }\n' +
        '        public void updateAsUser(List<SObject> objList) {\n' +
        '            performDMLOperation(objList, Operation.OP_UPDATE);\n' +
        '        }\n' +
        '        public void upsertAsUser(List<SObject> objList) {\n' +
        '            performDMLOperation(objList, Operation.OP_UPSERT);\n' +
        '        }\n' +
        '        public void deleteAsUser(List<SObject> objList) {\n' +
        '            performDMLOperation(objList, Operation.OP_DELETE);\n' +
        '        }\n' +
        '\n' +
        '        // Pass-thru methods to raw DML operations.\n' +
        '        // Use these sparingly, and only with good reason, since the DML operations are not CRUD/FLS safe\n' +
        '        public void insertAsSystem(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            insert obj; // CRUD/FLS False Positive: system method should insert with no CRUD check as a system user.\n' +
        '        }\n' +
        '        public void updateAsSystem(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            update obj; // CRUD/FLS False Positive: system method should update with no CRUD check as a system user.\n' +
        '        }\n' +
        '        public void upsertAsSystem(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            upsert obj; // CRUD/FLS False Positive: system method should upsert with no CRUD check as a system user.\n' +
        '        }\n' +
        '        public void deleteAsSystem(SObject obj) { // Bulkify Apex False Positive: no need to bulkify. There is separate method below.\n' +
        '            delete obj; // CRUD/FLS False Positive: system method should delete with no CRUD check as a system user.\n' +
        '        }\n' +
        '        public void insertAsSystem(List<SObject> objList) {\n' +
        '            insert objList; // CRUD/FLS False Positive: system method should insert with no CRUD check as a system user.\n' +
        '        }\n' +
        '        public void updateAsSystem(List<SObject> objList) {\n' +
        '            update objList; // CRUD/FLS False Positive: system method should update with no CRUD check as a system user.\n' +
        '        }\n' +
        '        public void upsertAsSystem(List<SObject> objList) {\n' +
        '            upsert objList; // CRUD/FLS False Positive: system method should upsert with no CRUD check as a system user.\n' +
        '        }\n' +
        '        public void deleteAsSystem(List<SObject> objList) {\n' +
        '            delete objList; // CRUD/FLS False Positive: system method should delete with no CRUD check as a system user.\n' +
        '        }\n' +
        '\n' +
        '        // Items in the following set must be entered in lower case\n' +
        '        private Set<String> exceptionValues = new Set<String>{\n' +
        '                \'id\', \'isdeleted\', \'createddate\', \'systemmodstamp\', \'lastmodifiedbyid\', \'createdbyid\', \'lastmodifieddate\'\n' +
        '        };\n' +
        '\n' +
        '        private Map<Operation, Map<SObjectType, List<String>>> cachedRestrictedFields = new Map<Operation, Map<SObjectType, List<String>>>();\n' +
        '\n' +
        '        private void performDMLOperation(List<SObject> objList, Operation dmlOperation) {\n' +
        '            Map<SObjectType, List<Id>> objTypeMap = analyzeDMLCollection(objList, dmlOperation);\n' +
        '\n' +
        '            checkCRUDPermission(objTypeMap.keySet(), dmlOperation);\n' +
        '\n' +
        '            if (dmlOperation == Operation.OP_INSERT) {\n' +
        '                for (SObject obj : objList) {\n' +
        '                    checkCreateAction(obj);\n' +
        '                }\n' +
        '            } else if (dmlOperation == Operation.OP_UPDATE || dmlOperation == Operation.OP_UPSERT) {\n' +
        '\n' +
        '                Map<Id, SObject> existingRecords = getExistingRecords(objTypeMap);\n' +
        '\n' +
        '                for (SObject obj : objList) {\n' +
        '                    SObject existingRecord = existingRecords.get(obj.Id);\n' +
        '                    if (obj.Id != null) {\n' +
        '                        checkUpdateAction(obj, existingRecord);\n' +
        '                    } else {\n' +
        '                        checkCreateAction(obj);\n' +
        '                    }\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            // If no errors have been thrown to this point, execute the dml operation.\n' +
        '            if (dmlOperation == Operation.OP_INSERT) {\n' +
        '                insert objList;\n' +
        '            } else if (dmlOperation == Operation.OP_UPDATE) {\n' +
        '                update objList;\n' +
        '            } else if (dmlOperation == Operation.OP_UPSERT) {\n' +
        '                upsertCollection(objList);\n' +
        '            } else if (dmlOperation == Operation.OP_DELETE) {\n' +
        '                delete objList;\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        private void upsertCollection(List<SObject> objList) {\n' +
        '            // This is to deal with a call to upsertAsUser with a singular object.\n' +
        '            // Since we wrap that into a List<SObject> (which can\'t be passed into an upsert)\n' +
        '            // we unpack it and upsert the object individually.\n' +
        '            if (objList.size() == 1) {\n' +
        '                upsert objList.get(0);\n' +
        '            } else {\n' +
        '                upsert objList;\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        private Map<String, Object> getFieldMapFromExistingSObject(SObject obj) {\n' +
        '            // Get actual fields present in object.  The getPopulatedFieldsAsMap method removes implicit nulls.\n' +
        '            return obj.getPopulatedFieldsAsMap();\n' +
        '        }\n' +
        '\n' +
        '        private void checkCreateAction(SObject obj) {\n' +
        '            List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_INSERT).get(obj.getSObjectType());\n' +
        '            //Save ourselves a trip through the loop below if there are no restricted fields\n' +
        '            if (restrictedFields == null || restrictedFields.isEmpty()) {\n' +
        '                return;\n' +
        '            }\n' +
        '\n' +
        '            Map<String, Object> fieldsMap = getFieldMapFromExistingSObject(obj);\n' +
        '\n' +
        '            // If any restricted fields are present, throw an exception\n' +
        '            for (String fieldName : restrictedFields) {\n' +
        '                if (fieldsMap.get(fieldName) != null) {\n' +
        '                    throw new jam.ProcessException(\n' +
        '                            \'Access Denied: \' + Operation.OP_INSERT + \' on \' + obj.getSObjectType() + \'.\' + obj.getSObjectType().getDescribe().fields.getMap().get(fieldName)\n' +
        '                    );// if any of the restricted fields are present in the candidate, throw an exception\n' +
        '                }\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        private void checkUpdateAction(SObject obj, SObject existingRecord) {\n' +
        '            List<String> restrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE).get(obj.getSObjectType());\n' +
        '            //Save ourselves a trip through the loop below if there are no restricted fields\n' +
        '            if (restrictedFields == null || restrictedFields.isEmpty()) {\n' +
        '                return;\n' +
        '            }\n' +
        '\n' +
        '            if (existingRecord == null) {\n' +
        '                throw new jam.ProcessException(\'DML ERROR:  An existing record could not be found for object with Id = \' + obj.Id);\n' +
        '            }\n' +
        '\n' +
        '            Map<String, Object> fieldsMap = getFieldMapFromExistingSObject(obj);\n' +
        '\n' +
        '            // If any of the restricted values are present and have changed in the dml candidate object, throw an exception\n' +
        '            for (String fieldName : restrictedFields) {\n' +
        '                if (fieldsMap.get(fieldName) != null && fieldsMap.get(fieldName) != existingRecord.get(fieldName)) {\n' +
        '                    throw new jam.ProcessException(\n' +
        '                            \'Access Denied: \' + Operation.OP_INSERT + \' on \' + obj.getSObjectType() + \'.\' + obj.getSObjectType().getDescribe().fields.getMap().get(fieldName)\n' +
        '                    );// if any of the restricted fields are present in the candidate, throw an exception\n' +
        '                }\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '\n' +
        '        // For update and upsert operations, retrieve a Map of all existing records, for each object that has an ID.\n' +
        '        // objects without an Id are skipped, because there is no existing record in the database.\n' +
        '        private Map<Id, SObject> getExistingRecords(Map<SObjectType, List<Id>> objTypeMap) {\n' +
        '            Map<Id, SObject> result = new Map<Id, SObject>();\n' +
        '\n' +
        '            Map<SObjectType, List<String>> operationRestrictedFields = cachedRestrictedFields.get(Operation.OP_UPDATE);\n' +
        '\n' +
        '            for (SObjectType objType : objTypeMap.keySet()) {\n' +
        '                List<String> restrictedFields = operationRestrictedFields.get(objType);\n' +
        '\n' +
        '                if (restrictedFields == null || restrictedFields.isEmpty()) {\n' +
        '                    continue;\n' +
        '                }\n' +
        '\n' +
        '                List<Id> seenIds = objTypeMap.get(objType);\n' +
        '                if (seenIds.isEmpty()) {\n' +
        '                    continue;\n' +
        '                }\n' +
        '\n' +
        '                String fieldList = String.join(restrictedFields, \',\');\n' +
        '                //?\n' +
        '                result.putAll((Database.query(\'SELECT \' + fieldList + \' FROM \' + objType.getDescribe().getName() + \' WHERE Id IN :seenIds\')));\n' +
        '            }\n' +
        '\n' +
        '            return result;\n' +
        '        }\n' +
        '\n' +
        '        // Check CRUD permissions for the current user on the object\n' +
        '        private void checkCRUDPermission(Set<SObjectType> objTypeList, Operation dmlOperation) {\n' +
        '            for (SObjectType objType : objTypeList) {\n' +
        '                DescribeSObjectResult describeObject = objType.getDescribe();\n' +
        '                if ((dmlOperation == Operation.OP_INSERT && !describeObject.isCreateable()) ||\n' +
        '                        (dmlOperation == Operation.OP_UPDATE && !describeObject.isUpdateable()) ||\n' +
        '                        (dmlOperation == Operation.OP_DELETE && !describeObject.isDeletable()) ||\n' +
        '                        (dmlOperation == Operation.OP_UPSERT && !(describeObject.isCreateable() && describeObject.isUpdateable()))) {\n' +
        '                    throw new jam.ProcessException(\'Access Denied: \' + dmlOperation + \' on \' + objType);\n' +
        '                }\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        // Get a Map of all the object types in the dml request and the list of fields for each\n' +
        '        // that the current user cannot update, based on FLS security settings\n' +
        '        private Map<SObjectType, List<Id>> analyzeDMLCollection(List<SObject> objList, Operation dmlOperation) {\n' +
        '            Map<SObjectType, List<Id>> result = new Map<SObjectType, List<Id>>();\n' +
        '\n' +
        '            for (SObject obj : objList) {\n' +
        '                ensureRestrictedFieldsEntry(obj, dmlOperation);\n' +
        '\n' +
        '                List<Id> seenIds = result.get(obj.getSObjectType());\n' +
        '                if (seenIds == null) {\n' +
        '                    seenIds = new List<Id>();\n' +
        '                    result.put(obj.getSObjectType(), seenIds);\n' +
        '                }\n' +
        '\n' +
        '                if (obj.Id == null) {\n' +
        '                    continue;\n' +
        '                }\n' +
        '\n' +
        '                seenIds.add(obj.Id);\n' +
        '\n' +
        '            }\n' +
        '            return result;\n' +
        '        }\n' +
        '\n' +
        '        private void ensureRestrictedFieldsEntry(SObject obj, Operation dmlOperation) {\n' +
        '            if (dmlOperation == Operation.OP_UPSERT) {\n' +
        '                ensureRestrictedFields(obj, Operation.OP_INSERT);\n' +
        '                ensureRestrictedFields(obj, Operation.OP_UPDATE);\n' +
        '            } else {\n' +
        '                ensureRestrictedFields(obj, dmlOperation);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        private void ensureRestrictedFields(SObject obj, Operation dmlOperation) {\n' +
        '            Map<SObjectType, List<String>> operationRestrictedFields = cachedRestrictedFields.get(dmlOperation);\n' +
        '            if (operationRestrictedFields == null) {\n' +
        '                operationRestrictedFields = new Map<SObjectType, List<String>>();\n' +
        '                cachedRestrictedFields.put(dmlOperation, operationRestrictedFields);\n' +
        '            }\n' +
        '\n' +
        '            if (!operationRestrictedFields.containsKey(obj.getSObjectType())) {\n' +
        '\n' +
        '                DescribeSObjectResult describeObject = obj.getSObjectType().getDescribe();\n' +
        '\n' +
        '                Map<String, Schema.SObjectField> objectFields = describeObject.fields.getMap();\n' +
        '\n' +
        '                List<String> restrictedFields = new List<String>();\n' +
        '\n' +
        '                for (String nm : objectFields.keySet()) {\n' +
        '                    if (!exceptionValues.contains(nm.toLowerCase())) {\n' +
        '                        DescribeFieldResult fr = objectFields.get(nm).getDescribe();\n' +
        '                        if ((!fr.isCalculated()) && ((dmlOperation == Operation.OP_INSERT && !fr.isCreateable()) ||\n' +
        '                                (dmlOperation == Operation.OP_UPDATE && !fr.isUpdateable()))\n' +
        '                        ) {\n' +
        '                            restrictedFields.add(fr.getName());\n' +
        '                        }  // there is not an isDeletable method at the field level\n' +
        '                    }\n' +
        '                }\n' +
        '                operationRestrictedFields.put(obj.getSObjectType(), restrictedFields);\n' +
        '            }\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class URLExtensions {\n' +
        '\n' +
        '        public String generateReportURL(String reportAPIName, List<String> paramValues) {\n' +
        '            return generateReportURL(reportAPIName, paramValues, true, null);\n' +
        '        }\n' +
        '\n' +
        '        public String generateReportURL(String reportAPIName, List<String> paramValues, Boolean isSecurityEnforced, String namespacePrefix) {\n' +
        '\n' +
        '            String reportQuery = \'SELECT Id, Name\\n\' +\n' +
        '                    \'FROM Report\\n\' +\n' +
        '                    \'WHERE DeveloperName = :reportAPIName AND NamespacePrefix = :namespacePrefix\' +\n' +
        '                    (isSecurityEnforced == true ? \' WITH USER_MODE\' : \'\');\n' +
        '\n' +
        '            Report reportId = (Report) jam.arrays.firstOrNull(\n' +
        '                    Database.query(reportQuery)\n' +
        '            );\n' +
        '\n' +
        '            List<String> reportParams = new List<String>();\n' +
        '            if (paramValues != null) {\n' +
        '                for (Integer i = 0; i < paramValues.size(); i++) {\n' +
        '                    reportParams.add(String.format(\'fv{0}={1}\', new List<String>{\n' +
        '                            \'\' + (i + 1),\n' +
        '                            EncodingUtil.urlEncode(paramValues[i], \'UTF-8\')\n' +
        '                    }));\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            String reportURL = String.format(\'/lightning/r/Report/{0}/view?queryScope=userFolders{1}\', new List<String>{\n' +
        '                    Test.isRunningTest() ? \'test\' : reportId?.Id,\n' +
        '                    reportParams.isEmpty() ? \'\' : \'&\' + String.join(reportParams, \'&\')\n' +
        '            });\n' +
        '\n' +
        '            return reportURL;\n' +
        '        }\n' +
        '\n' +
        '        public PageReference listView(Schema.SObjectType destinationSObject) {\n' +
        '            Schema.DescribeSObjectResult destination = destinationSObject.getDescribe();\n' +
        '            PageReference pageRef = new PageReference(\'/\' + destination.getKeyPrefix());\n' +
        '            pageRef.setRedirect(true);\n' +
        '            return pageRef;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class EncodingExtensions {\n' +
        '\n' +
        '        public String mapToFormUrlEncoded(Map<String, String> dataMap) {\n' +
        '            List<String> keyValuePairsEncoded = new List<String>();\n' +
        '            for (String key : dataMap.keySet()) {\n' +
        '                keyValuePairsEncoded.add(String.format(\'{0}={1}\', new List<String>{\n' +
        '                        System.EncodingUtil.urlEncode(key, \'UTF-8\'),\n' +
        '                        System.EncodingUtil.urlEncode(jam.strings.emptyStringIfNull(dataMap.get(key)), \'UTF-8\')\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            return String.join(keyValuePairsEncoded, \'&\');\n' +
        '        }\n' +
        '\n' +
        '        public String getEncryptedValue(String value, String blobEncodedString) {\n' +
        '            Blob cryptoKey = EncodingUtil.base64Decode(blobEncodedString);\n' +
        '\n' +
        '            Blob encryptedToken = Crypto.encryptWithManagedIV(\'AES256\', cryptoKey, Blob.valueOf(value));\n' +
        '\n' +
        '            String encryptedValue = EncodingUtil.base64Encode(encryptedToken);\n' +
        '\n' +
        '            return encryptedValue;\n' +
        '        }\n' +
        '\n' +
        '        public String getDecryptedValue(String encryptedValue, String blobEncodedString) {\n' +
        '            Blob cryptoKey = EncodingUtil.base64Decode(blobEncodedString);\n' +
        '\n' +
        '            Blob encryptedToken = EncodingUtil.base64Decode(encryptedValue);\n' +
        '\n' +
        '            Blob decryptedToken = Crypto.decryptWithManagedIV(\'AES256\', cryptoKey, encryptedToken);\n' +
        '\n' +
        '            return decryptedToken.toString();\n' +
        '        }\n' +
        '\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class ArrayExtensions {\n' +
        '        public Object firstOrDefault(List<Object> records, Object defaultVar) {\n' +
        '            return records.isEmpty() ? defaultVar : records[0];\n' +
        '        }\n' +
        '\n' +
        '        public Object firstOrNull(List<Object> records) {\n' +
        '            return firstOrDefault(records, null);\n' +
        '        }\n' +
        '\n' +
        '        public Object firstOrException(List<Object> records) {\n' +
        '            return firstOrException(records, \'The list is empty\');\n' +
        '        }\n' +
        '\n' +
        '        public Object firstOrException(List<Object> records, String message) {\n' +
        '            return firstOrException(records, message, null);\n' +
        '        }\n' +
        '\n' +
        '        public Object firstOrException(List<Object> records, String message, Type exceptionType) {\n' +
        '            if (records == null || records.isEmpty()) {\n' +
        '                Exception ex;\n' +
        '                if (exceptionType != null) {\n' +
        '                    ex = (Exception) exceptionType.newInstance();\n' +
        '                    ex.setMessage(message);\n' +
        '                } else {\n' +
        '                    ex = new jam.MissingDataException(message);\n' +
        '                }\n' +
        '                throw ex;\n' +
        '            }\n' +
        '            return records.get(0);\n' +
        '        }\n' +
        '\n' +
        '        public void addToSetIfNotBlank(Set<String> dataSet, String value) {\n' +
        '            if (String.isNotBlank(value)) {\n' +
        '                dataSet.add(value);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public void addToListOrCreateNew(Map<String, List<Object>> dataMap, Type listType, String key, Object obj, Integer index) {\n' +
        '            if (dataMap == null) {\n' +
        '                dataMap = new Map<String, List<Object>>();\n' +
        '            }\n' +
        '            if (!dataMap.containsKey(key) || dataMap.get(key) == null) {\n' +
        '                List<Object> newList = (List<Object>) listType.newInstance();\n' +
        '                dataMap.put(key, newList);\n' +
        '            }\n' +
        '            if (index != null && dataMap.get(key).size() > index) {\n' +
        '                dataMap.get(key).add(index, obj);\n' +
        '            } else {\n' +
        '                dataMap.get(key).add(obj);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public void addToListOrCreateNew(Map<String, List<Object>> dataMap, Type listType, String key, Object obj) {\n' +
        '            this.addToListOrCreateNew(dataMap, listType, key, obj, null);\n' +
        '        }\n' +
        '\n' +
        '        //Example: jam.arrays.split(new List<Integer>{1, 2, 3, 4, 5, 6, 7, 8, 9 ,10}, 2, List<Integer>.class)\n' +
        '        public List<List<Object>> split(List<Object> arr, Integer chunkSize, Type chunkListType) {\n' +
        '\n' +
        '            jam.objects.throwIfNull(chunkSize, \'chunkSize is null\');\n' +
        '\n' +
        '            List<List<Object>> result = new List<List<Object>>();\n' +
        '\n' +
        '            List<Object> chunk;\n' +
        '            Integer chunkCounter = 0;\n' +
        '            for (Object item : arr) {\n' +
        '                if (chunkCounter == 0) {\n' +
        '                    chunk = (List<Object>) chunkListType.newInstance();\n' +
        '                    result.add(chunk);\n' +
        '                }\n' +
        '                chunk.add(item);\n' +
        '                chunkCounter++;\n' +
        '                if (chunkCounter == chunkSize) {\n' +
        '                    chunkCounter = 0;\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return result;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class TemplateExtensions {\n' +
        '\n' +
        '        public String compose(String template, Map<String, Object> dtoMap) {\n' +
        '            return this.compose(template, new DTO(dtoMap));\n' +
        '        }\n' +
        '\n' +
        '        public String compose(String template, DTO dto) {\n' +
        '            String result = template;\n' +
        '            List<jam.Expression> expressions = this.getExpressions(template);\n' +
        '\n' +
        '            for (jam.Expression expressionVar : expressions) {\n' +
        '                try {\n' +
        '                    result = expressionVar.apply(dto, result);\n' +
        '                } catch (Exception ex) {\n' +
        '                    throw new jam.ProcessException(\'Unable to apply merge field: \' + expressionVar.source);\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return result;\n' +
        '        }\n' +
        '\n' +
        '        public List<jam.Expression> getExpressions(String template) {\n' +
        '            String reExp = \'(?s)(\\\\{!.+?\\\\})\';\n' +
        '\n' +
        '            Pattern patternVar = Pattern.compile(reExp);\n' +
        '            Matcher matcherVar = patternVar.matcher(template);\n' +
        '\n' +
        '            Set<String> placeholders = new Set<String>();\n' +
        '\n' +
        '            while (matcherVar.find()) {\n' +
        '                for (Integer i = 1; i <= matcherVar.groupCount(); i++) {\n' +
        '                    String placeholder = matcherVar.group(i);\n' +
        '                    placeholders.add(placeholder);\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            List<jam.Expression> expressions = new List<jam.Expression>();\n' +
        '\n' +
        '            for (String placeholder : placeholders) {\n' +
        '                jam.Expression expressionVar;\n' +
        '                if (String.isBlank(placeholder)) {\n' +
        '                    expressions.add(expressionVar);\n' +
        '                }\n' +
        '\n' +
        '                String expressionStr = placeholder.substring(2, placeholder.length() - 1);\n' +
        '                expressionVar = new jam.MergeFieldExpression(expressionStr);\n' +
        '                expressions.add(expressionVar);\n' +
        '            }\n' +
        '\n' +
        '            return expressions;\n' +
        '        }\n' +
        '\n' +
        '        public Set<String> getSources(String template) {\n' +
        '            Set<String> sources = new Set<String>();\n' +
        '            List<jam.Expression> expressions = this.getExpressions(template);\n' +
        '\n' +
        '            for (jam.Expression expressionVar : expressions) {\n' +
        '                sources.add(expressionVar.source);\n' +
        '            }\n' +
        '\n' +
        '            return sources;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing abstract class Expression {\n' +
        '        public String source;\n' +
        '        public List<String> params = new List<String>();\n' +
        '\n' +
        '        public Expression(String source) {\n' +
        '            this.source = source;\n' +
        '            this.parseSource();\n' +
        '        }\n' +
        '\n' +
        '        protected abstract void parseSource();\n' +
        '        protected abstract String getValue(DTO dtoVar);\n' +
        '\n' +
        '        public virtual String apply(DTO dtoVar, String targetStr) {\n' +
        '            String expressionStrToReplace = (\'{!\' + this.source + \'}\');\n' +
        '            String escapedExpressionStrToReplace = expressionStrToReplace.replaceAll(\'\\\\p{Punct}\', \'\\\\\\\\$0\');\n' +
        '            return targetStr.replaceAll(escapedExpressionStrToReplace, this.getValue(dtoVar));\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing virtual class MergeFieldExpression extends Expression {\n' +
        '        public MergeFieldExpression(String source) {\n' +
        '            super(source);\n' +
        '        }\n' +
        '\n' +
        '        protected override void parseSource() {\n' +
        '            this.params.add(this.source);\n' +
        '        }\n' +
        '\n' +
        '        protected override String getValue(jam.DTO dtoVar) {\n' +
        '            String path = this.params.get(0);\n' +
        '            String value = \'\';\n' +
        '\n' +
        '            //OR implementation\n' +
        '            if (path.contains(\'|\')) {\n' +
        '                for (String pathVar : path.split(\'\\\\|\')) {\n' +
        '                    value = jam.objects.defaultIfNull(dtoVar.getString(pathVar), \'\');\n' +
        '\n' +
        '                    if (String.isNotBlank(value)) {\n' +
        '                        return value;\n' +
        '                    }\n' +
        '                }\n' +
        '\n' +
        '                return value;\n' +
        '            }\n' +
        '\n' +
        '            value = jam.objects.defaultIfNull(dtoVar.getString(path), \'\');\n' +
        '            return value;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    private static Map<String, jam.Response> PACKAGE_ACTION_MOCK;\n' +
        '\n' +
        '    public static void setPackageActionMock(String namespace, String action, Map<String, Object> responseMap) {\n' +
        '        setPackageActionMock(namespace, action, new jam.Response(new jam.DTO(responseMap)));\n' +
        '    }\n' +
        '\n' +
        '    public static void setPackageActionMock(String namespace, String action, jam.Response response) {\n' +
        '        if (PACKAGE_ACTION_MOCK == null) {\n' +
        '            PACKAGE_ACTION_MOCK = new Map<String, jam.Response>();\n' +
        '        }\n' +
        '        PACKAGE_ACTION_MOCK.put(namespace + \'.\' + action, response);\n' +
        '    }\n' +
        '\n' +
        '\n' +
        '    public inherited sharing class ObjectExtensions {\n' +
        '        public jam.Response runPackageAction(String namespace, String action, Map<String, Object> dto) {\n' +
        '            jam.objects.throwIfBlank(namespace, \'Namespace is required for cross-package calling\');\n' +
        '\n' +
        '            if (Test.isRunningTest()) {\n' +
        '                jam.Response mockResponse = PACKAGE_ACTION_MOCK?.get(namespace + \'.\' + action);\n' +
        '                jam.objects.throwIfNull(mockResponse, \'No mock response for namespace: \' + namespace + \'. Please set Mock.\');\n' +
        '                return mockResponse;\n' +
        '            }\n' +
        '\n' +
        '            Type jamCallableType = Type.forName(namespace, \'jam\');\n' +
        '\n' +
        '            if (jamCallableType == null) {\n' +
        '                throw new jam.ProcessException(\'No jam type for namespace: \' + namespace);\n' +
        '            }\n' +
        '\n' +
        '            Callable callableInstance = (Callable) jamCallableType.newInstance();\n' +
        '\n' +
        '            if (callableInstance == null) {\n' +
        '                throw new jam.ProcessException(\'No jam callable instance for namespace: \' + namespace);\n' +
        '            }\n' +
        '\n' +
        '            Map<String, Object> callResponseVar = (Map<String, Object>) callableInstance.call(action, dto);\n' +
        '\n' +
        '            return new jam.Response(\n' +
        '                    (Boolean) callResponseVar.get(\'isValid\'),\n' +
        '                    (Map<String, Object>) callResponseVar.get(\'dto\'),\n' +
        '                    callResponseVar.get(\'error\') == null ? null : (jam.ErrorDetails) JSON.deserialize(JSON.serialize(callResponseVar.get(\'error\')), jam.ErrorDetails.class),\n' +
        '                    (List<jam.ErrorDetails>) JSON.deserialize(JSON.serialize(callResponseVar.get(\'errors\')), List<jam.ErrorDetails>.class)\n' +
        '            );\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action getAction(String actionName) {\n' +
        '            return getAction(actionName, \'No Action with Name: \' + actionName);\n' +
        '        }\n' +
        '\n' +
        '        public jam.Action getAction(String actionName, String errorMessage) {\n' +
        '            String namespace;\n' +
        '            String className = actionName;\n' +
        '\n' +
        '            List<String> actionParts = actionName.split(\'\\\\.\');\n' +
        '\n' +
        '            if (actionParts.size() == 2) {\n' +
        '                namespace = actionParts[0];\n' +
        '                className = actionParts[1];\n' +
        '            }\n' +
        '\n' +
        '            Type actionType = Test.isRunningTest() ? Type.forName(actionName) : Type.forName(namespace, className);\n' +
        '            if (actionType == null) {\n' +
        '                throw new jam.ProcessException(errorMessage);\n' +
        '            }\n' +
        '\n' +
        '            jam.Action actionVar = (jam.Action) actionType.newInstance();\n' +
        '\n' +
        '            if (actionVar == null) {\n' +
        '                throw new jam.ProcessException(\'Unable to create Action instance of type name: \' + actionName);\n' +
        '            }\n' +
        '\n' +
        '            return actionVar;\n' +
        '        }\n' +
        '\n' +
        '        public void throwIfNull(Object obj, Exception ex) {\n' +
        '            if (obj == null) {\n' +
        '                throw ex;\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public void throwIfNull(Object obj, String message) {\n' +
        '            if (obj == null) {\n' +
        '                throw new jam.MissingDataException(message);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public Boolean isBlankValue(Object obj) {\n' +
        '            return obj == null || (obj instanceof String && String.isBlank((String) obj));\n' +
        '        }\n' +
        '\n' +
        '        public void throwIfBlank(Object obj, String message) {\n' +
        '            if (this.isBlankValue(obj)) {\n' +
        '                throw new jam.MissingDataException(message);\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public Decimal parseDecimal(Object val) {\n' +
        '            if (val == null) {\n' +
        '                return null;\n' +
        '            } else if (val instanceof Decimal) {\n' +
        '                return (Decimal) val;\n' +
        '            } else if (val instanceof String && String.isNotBlank((String) val)) {\n' +
        '                return Decimal.valueOf((String) val);\n' +
        '            } else if (val instanceof Integer) {\n' +
        '                return Decimal.valueOf((Integer) val);\n' +
        '            } else if (val instanceof Long) {\n' +
        '                return Decimal.valueOf((Long) val);\n' +
        '            } else if (val instanceof Double) {\n' +
        '                return Decimal.valueOf((Double) val);\n' +
        '            }\n' +
        '            throw new jam.ProcessException(\'Unable to parse Decimal from: \' + val);\n' +
        '        }\n' +
        '\n' +
        '        public Decimal defaultIfNull(Decimal val, Decimal defaultVal) {\n' +
        '            return val == null ? defaultVal : val;\n' +
        '        }\n' +
        '\n' +
        '        public Integer defaultIfNull(Integer val, Integer defaultVal) {\n' +
        '            return val == null ? defaultVal : val;\n' +
        '        }\n' +
        '\n' +
        '        public String defaultIfNull(String val, String defaultVal) {\n' +
        '            return val == null ? defaultVal : val;\n' +
        '        }\n' +
        '\n' +
        '        public Object getMapValue(Map<String, Object> dataMap, String path) {\n' +
        '            return this.getMapValue(dataMap, path.split(\'\\\\.\'));\n' +
        '        }\n' +
        '\n' +
        '        public Object getMapValue(Map<String, Object> dataMap, List<String> path) {\n' +
        '            List<String> currentKeys = path;\n' +
        '            Map<String, Object> tempMap = dataMap;\n' +
        '            List<Object> tempArr = null;\n' +
        '\n' +
        '            while (!currentKeys.isEmpty()) {\n' +
        '\n' +
        '                if (tempMap == null && tempArr == null) {\n' +
        '                    return null;\n' +
        '                }\n' +
        '\n' +
        '                String key = currentKeys.remove(0);\n' +
        '                Pattern arrayNotation = Pattern.compile(\'\\\\[(\\\\d+)]\');\n' +
        '                Matcher arrayMatcher = arrayNotation.matcher(key);\n' +
        '                Boolean isArrayKey = arrayMatcher.matches();\n' +
        '                Integer index = isArrayKey ? Integer.valueOf(arrayMatcher.group(1)) : null;\n' +
        '\n' +
        '                if (isArrayKey && (tempArr == null || index == null || tempArr.size() <= index)) {\n' +
        '                    return null;\n' +
        '                }\n' +
        '\n' +
        '                Object val = isArrayKey ? tempArr.get(index) : tempMap.get(key);\n' +
        '\n' +
        '                Boolean isLastKey = currentKeys.isEmpty();\n' +
        '\n' +
        '                if (isLastKey == true) {\n' +
        '                    return val;\n' +
        '                } else {\n' +
        '                    if (val instanceof List<Object>) {\n' +
        '                        tempArr = (List<Object>) val;\n' +
        '                    } else {\n' +
        '                        Object t = isArrayKey ?\n' +
        '                                tempArr.get(index) :\n' +
        '                                tempMap.get(key);\n' +
        '\n' +
        '                        if (t instanceof Map<String, Object>) {\n' +
        '                            tempMap = (Map<String, Object>) t;\n' +
        '                            tempArr = null;\n' +
        '                        } else {\n' +
        '                            return null;\n' +
        '                        }\n' +
        '                    }\n' +
        '                }\n' +
        '\n' +
        '            }\n' +
        '            return null;\n' +
        '        }\n' +
        '\n' +
        '        public void setMapValue(Map<String, Object> dataMap, String path, Object value) {\n' +
        '            this.setMapValue(dataMap, path.split(\'\\\\.\'), value);\n' +
        '        }\n' +
        '\n' +
        '        public void setMapValue(Map<String, Object> dataMap, List<String> path, Object value) {\n' +
        '            List<String> currentKeys = path;\n' +
        '            Map<String, Object> tempMap = dataMap;\n' +
        '\n' +
        '            while (!currentKeys.isEmpty()) {\n' +
        '\n' +
        '                if (tempMap == null) {\n' +
        '                    return;\n' +
        '                }\n' +
        '\n' +
        '                String key = currentKeys.remove(0);\n' +
        '\n' +
        '                Boolean isLastKey = currentKeys.isEmpty();\n' +
        '\n' +
        '                if (isLastKey == true) {\n' +
        '                    tempMap.put(key, value);\n' +
        '                } else {\n' +
        '                    if (!tempMap.containsKey(key)) {\n' +
        '                        tempMap.put(key, new Map<String, Object>());\n' +
        '                    }\n' +
        '                    tempMap = (Map<String, Object>) tempMap.get(key);\n' +
        '                }\n' +
        '\n' +
        '            }\n' +
        '\n' +
        '        }\n' +
        '\n' +
        '        public void removeMapValue(Map<String, Object> dataMap, String path) {\n' +
        '            this.removeMapValue(dataMap, path == null ? null : path.split(\'\\\\.\'));\n' +
        '        }\n' +
        '        public void removeMapValue(Map<String, Object> dataMap, List<String> path) {\n' +
        '\n' +
        '            List<String> currentKeys = path == null ? new List<String>{\n' +
        '                    null\n' +
        '            } : path;\n' +
        '            Map<String, Object> tempMap = dataMap;\n' +
        '            List<Object> tempArr = null;\n' +
        '\n' +
        '            while (!currentKeys.isEmpty()) {\n' +
        '\n' +
        '                if (tempMap == null && tempArr == null) {\n' +
        '                    return;\n' +
        '                }\n' +
        '\n' +
        '                String key = currentKeys.remove(0);\n' +
        '\n' +
        '                Pattern arrayNotation = Pattern.compile(\'\\\\[(\\\\d+)]\');\n' +
        '                Matcher arrayMatcher = key == null ? null : arrayNotation.matcher(key);\n' +
        '                Boolean isArrayKey = arrayMatcher == null ? false : arrayMatcher.matches();\n' +
        '                Integer index = isArrayKey ? Integer.valueOf(arrayMatcher.group(1)) : null;\n' +
        '\n' +
        '                if (isArrayKey && (tempArr == null || index == null || tempArr.size() <= index)) {\n' +
        '                    return;\n' +
        '                }\n' +
        '\n' +
        '                Object val = isArrayKey ? tempArr.get(index) : tempMap.get(key);\n' +
        '\n' +
        '                Boolean isLastKey = currentKeys.isEmpty();\n' +
        '\n' +
        '                if (isLastKey == true) {\n' +
        '                    if (isArrayKey) {\n' +
        '                        tempArr.remove(index);\n' +
        '                    } else {\n' +
        '                        tempMap.remove(key);\n' +
        '                    }\n' +
        '                    return;\n' +
        '                } else {\n' +
        '                    if (val instanceof List<Object>) {\n' +
        '                        tempArr = (List<Object>) val;\n' +
        '                    } else {\n' +
        '                        tempMap = isArrayKey ?\n' +
        '                                (Map<String, Object>) tempArr.get(index) :\n' +
        '                                (Map<String, Object>) tempMap.get(key);\n' +
        '                        tempArr = null;\n' +
        '                    }\n' +
        '                }\n' +
        '\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        public Boolean mapContains(Map<String, Object> dataMap, String path) {\n' +
        '            return getMapValue(dataMap, path) != null;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    // Converts a base64 string into a list of integers representing the encoded bytes\n' +
        '    public static List<Integer> B64ToBytes(String sIn) {\n' +
        '        Map<Integer, Integer> base64 = new Map<Integer, Integer>{\n' +
        '                65 => 0, 66 => 1, 67 => 2, 68 => 3, 69 => 4, 70 => 5, 71 => 6, 72 => 7, 73 => 8, 74 => 9, 75 => 10, 76 => 11, 77 => 12, 78 => 13, 79 => 14, 80 => 15, 81 => 16, 82 => 17, 83 => 18, 84 => 19, 85 => 20, 86 => 21, 87 => 22, 88 => 23, 89 => 24, 90 => 25\n' +
        '                , 97 => 26, 98 => 27, 99 => 28, 100 => 29, 101 => 30, 102 => 31, 103 => 32, 104 => 33, 105 => 34, 106 => 35, 107 => 36, 108 => 37, 109 => 38, 110 => 39, 111 => 40, 112 => 41, 113 => 42, 114 => 43, 115 => 44, 116 => 45, 117 => 46, 118 => 47, 119 => 48, 120 => 49, 121 => 50, 122 => 51\n' +
        '                , 48 => 52, 49 => 53, 50 => 54, 51 => 55, 52 => 56, 53 => 57, 54 => 58, 55 => 59, 56 => 60, 57 => 61, 43 => 62, 47 => 63\n' +
        '        };\n' +
        '\n' +
        '        List<Integer> lstOut = new List<Integer>();\n' +
        '        if (sIn == null || sIn == \'\') return lstOut;\n' +
        '\n' +
        '        sIn += \'=\'.repeat(4 - Math.mod(sIn.length(), 4));\n' +
        '\n' +
        '        for (Integer idx = 0; idx < sIn.length(); idx += 4) {\n' +
        '            if (base64.get(sIn.charAt(idx + 1)) != null) lstOut.add((base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx + 1)) >>> 4));\n' +
        '            if (base64.get(sIn.charAt(idx + 2)) != null) lstOut.add(((base64.get(sIn.charAt(idx + 1)) & 15) << 4) | (base64.get(sIn.charAt(idx + 2)) >>> 2));\n' +
        '            if (base64.get(sIn.charAt(idx + 3)) != null) lstOut.add(((base64.get(sIn.charAt(idx + 2)) & 3) << 6) | base64.get(sIn.charAt(idx + 3)));\n' +
        '        }\n' +
        '\n' +
        '        return lstOut;\n' +
        '    }\n' +
        '\n' +
        '    // Converts a base64 string into a list of integers indicating at which position the bits are on\n' +
        '    public static List<Integer> cnvBits(String b64Str) {\n' +
        '        List<Integer> lstOut = new List<Integer>();\n' +
        '        if (b64Str == null || b64Str == \'\') return lstOut;\n' +
        '\n' +
        '        List<Integer> lstBytes = B64ToBytes(b64Str);\n' +
        '\n' +
        '        Integer i, b, v;\n' +
        '        for (i = 0; i < lstBytes.size(); i++) {\n' +
        '            v = lstBytes[i];\n' +
        '            for (b = 1; b <= 8; b++) {\n' +
        '                if ((v & 128) == 128) lstOut.add((i * 8) + b);\n' +
        '                v <<= 1;\n' +
        '            }\n' +
        '        }\n' +
        '\n' +
        '        return lstOut;\n' +
        '    }\n' +
        '\n' +
        '    //EXCEPTIONS\n' +
        '    public inherited sharing class MissingDataException extends Exception {\n' +
        '    }\n' +
        '    public inherited sharing class ValidationException extends Exception {\n' +
        '    }\n' +
        '    public inherited sharing class ProcessException extends Exception {\n' +
        '    }\n' +
        '\n' +
        '    //QUERY FACTORY\n' +
        '    public static QueryFactory queryFactory(SObjectType sObjectType) {\n' +
        '        return new QueryFactory(sObjectType);\n' +
        '    }\n' +
        '\n' +
        '    @TestVisible\n' +
        '    private static String getFieldTokenPath(Schema.SObjectField field) {\n' +
        '        if (field == null) {\n' +
        '            throw new jam.ProcessException(\'Invalid field: null\');\n' +
        '        }\n' +
        '        return field.getDescribe().getName();\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class QueryFactory {\n' +
        '\n' +
        '        public Schema.SObjectType table { get; private set; }\n' +
        '        @TestVisible\n' +
        '        private Set<String> fields;\n' +
        '        private String conditionExpression;\n' +
        '        private Map<String, Object> bindVariablesMap;\n' +
        '        private Integer limitCount;\n' +
        '        private Integer offsetCount;\n' +
        '        private List<Ordering> order;\n' +
        '        private Boolean isSecurityEnforced = true;\n' +
        '        private Boolean sortSelectFields = true;\n' +
        '        private Schema.ChildRelationship relationship;\n' +
        '        private Map<Schema.ChildRelationship, QueryFactory> subSelectQueryMap;\n' +
        '        private Boolean isSubSelectFactory = false;\n' +
        '\n' +
        '        private String getFieldPath(String fieldName) {\n' +
        '            if (!fieldName.contains(\'.\')) {\n' +
        '                Schema.SObjectField token = table.getDescribe().fields.getMap().get(fieldName.toLowerCase());\n' +
        '                if (token == null) throw new jam.ProcessException(\'Invalid field \\\'\' + fieldName + \'\\\' for object \\\'\' + table + \'\\\'\');\n' +
        '                return token.getDescribe().getName();\n' +
        '            }\n' +
        '\n' +
        '            List<String> fieldPath = new List<String>();\n' +
        '            Schema.SObjectType lastSObjectType = table;\n' +
        '            Iterator<String> i = fieldName.split(\'\\\\.\').iterator();\n' +
        '            while (i.hasNext()) {\n' +
        '                String field = i.next();\n' +
        '\n' +
        '                Schema.SObjectField token = lastSObjectType.getDescribe().fields.getMap().get(field.endsWithIgnoreCase(\'__r\') ?\n' +
        '                        (field.removeEndIgnoreCase(\'__r\') + \'__c\') :\n' +
        '                        field);\n' +
        '\n' +
        '                if (token == null) {\n' +
        '                    token = lastSObjectType.getDescribe().fields.getMap().get(field + \'id\');\n' +
        '                }\n' +
        '\n' +
        '                DescribeFieldResult tokenDescribe = token != null ? token.getDescribe() : null;\n' +
        '\n' +
        '                if (token != null && i.hasNext() && tokenDescribe.getSoapType() == Schema.SoapType.ID) {\n' +
        '                    lastSObjectType = tokenDescribe.getReferenceTo()[0];\n' +
        '                    fieldPath.add(tokenDescribe.getRelationshipName());\n' +
        '                } else if (token != null && !i.hasNext()) {\n' +
        '                    fieldPath.add(tokenDescribe.getName());\n' +
        '                } else {\n' +
        '                    if (token == null) {\n' +
        '                        throw new jam.ProcessException(\'Invalid field \\\'\' + field + \'\\\' for object \\\'\' + lastSObjectType + \'\\\'\');\n' +
        '                    } else {\n' +
        '                        throw new jam.ProcessException(lastSObjectType + \'.\' + field + \' is not a lookup or master-detail field but is used in a cross-object query field.\');\n' +
        '                    }\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            return String.join(fieldPath, \'.\');\n' +
        '        }\n' +
        '\n' +
        '        public Boolean equals(Object obj) {\n' +
        '            if (!(obj instanceof QueryFactory) || ((QueryFactory) obj).table != this.table || ((QueryFactory) obj).fields.size() != this.fields.size()) return false;\n' +
        '            return ((QueryFactory) obj).toSOQL() == this.toSOQL();\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory(Schema.SObjectType table) {\n' +
        '            this.table = table;\n' +
        '            fields = new Set<String>();\n' +
        '            order = new List<Ordering>();\n' +
        '        }\n' +
        '\n' +
        '        private QueryFactory(Schema.ChildRelationship relationship) {\n' +
        '            this(relationship.getChildSObject());\n' +
        '            this.relationship = relationship;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setSecurityEnforced(Boolean isSecurityEnforced) {\n' +
        '            this.isSecurityEnforced = isSecurityEnforced;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setSortSelectFields(Boolean doSort) {\n' +
        '            this.sortSelectFields = doSort;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectField(String fieldName) {\n' +
        '            fields.add(getFieldPath(fieldName));\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectField(Schema.SObjectField field) {\n' +
        '            if (field == null) throw new jam.ProcessException(\'Invalid field \\\'\' + null + \'\\\' for object \\\'\' + table + \'\\\'\');\n' +
        '            fields.add(getFieldTokenPath(field));\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectFields(Set<String> fieldNames) {\n' +
        '            for (String fieldName : fieldNames) {\n' +
        '                fields.add(getFieldPath(fieldName));\n' +
        '            }\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectFields(List<String> fieldNames) {\n' +
        '            for (String fieldName : fieldNames) fields.add(getFieldPath(fieldName));\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectFields(Set<Schema.SObjectField> fields) {\n' +
        '            for (Schema.SObjectField token : fields) {\n' +
        '                if (token == null) throw new jam.ProcessException();\n' +
        '                this.fields.add(getFieldTokenPath(token));\n' +
        '            }\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectFields(List<Schema.SObjectField> fields) {\n' +
        '            for (Schema.SObjectField token : fields) {\n' +
        '                if (token == null) throw new jam.ProcessException();\n' +
        '                this.fields.add(getFieldTokenPath(token));\n' +
        '            }\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectFieldSet(Schema.FieldSet fieldSet) {\n' +
        '            return selectFieldSet(fieldSet, true);\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory selectFieldSet(Schema.FieldSet fieldSet, Boolean allowCrossObject) {\n' +
        '            if (fieldSet.getSObjectType() != table) throw new jam.ProcessException(\'Field set "\' + fieldSet.getName() + \'" is not for SObject type "\' + table + \'"\');\n' +
        '            for (Schema.FieldSetMember field : fieldSet.getFields()) {\n' +
        '                if (!allowCrossObject && field.getFieldPath().contains(\'.\')) throw new jam.ProcessException(\'Cross-object fields not allowed and field "\' + field.getFieldPath() + \'"" is a cross-object field.\');\n' +
        '                fields.add(getFieldPath(field.getFieldPath()));\n' +
        '            }\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setCondition(String conditionExpression) {\n' +
        '            this.conditionExpression = conditionExpression;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setCondition(String conditionExpression, Map<String, Object> bindVariablesMap) {\n' +
        '            this.setCondition(conditionExpression);\n' +
        '            this.bindVariablesMap = bindVariablesMap;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setBindVariables(Map<String, Object> bindVariablesMap) {\n' +
        '            this.bindVariablesMap = bindVariablesMap;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setConditionsAND(List<String> conditionExpressions) {\n' +
        '            this.conditionExpression = String.join(conditionExpressions, \' AND \');\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setConditionsOR(List<String> conditionExpressions) {\n' +
        '            this.conditionExpression = String.join(conditionExpressions, \' OR \');\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setConditionsAND(List<String> conditionExpressions, Map<String, Object> bindVariablesMap) {\n' +
        '            this.setConditionsAND(conditionExpressions);\n' +
        '            this.bindVariablesMap = bindVariablesMap;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setConditionsOR(List<String> conditionExpressions, Map<String, Object> bindVariablesMap) {\n' +
        '            this.setConditionsOR(conditionExpressions);\n' +
        '            this.bindVariablesMap = bindVariablesMap;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public String getCondition() {\n' +
        '            return this.conditionExpression;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setLimit(Integer limitCount) {\n' +
        '            this.limitCount = limitCount;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public Integer getLimit() {\n' +
        '            return this.limitCount;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setOffset(Integer offsetCount) {\n' +
        '            this.offsetCount = offsetCount;\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public Integer getOffset() {\n' +
        '            return this.offsetCount;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory addOrdering(Ordering o) {\n' +
        '            this.order.add(o);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setOrdering(Ordering o) {\n' +
        '            this.order = new List<Ordering>{\n' +
        '                    o\n' +
        '            };\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public List<Ordering> getOrderings() {\n' +
        '            return this.order;\n' +
        '        }\n' +
        '\n' +
        '        public Set<String> getSelectedFields() {\n' +
        '            return this.fields;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory subSelectQuery(SObjectType related) {\n' +
        '            return setSubSelectQuery(getChildRelationship(related));\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory subSelectQuery(String relationshipName) {\n' +
        '            ChildRelationship relationship = getChildRelationship(relationshipName);\n' +
        '            if (relationship != null) {\n' +
        '                return setSubSelectQuery(relationship);\n' +
        '            }\n' +
        '            throw new jam.ProcessException(\'Invalid call to subselectQuery with relationshipName = \' + relationshipName + \'.  Relationship does not exist for \' + table.getDescribe().getName());\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory subSelectQuery(ChildRelationship relationship) {\n' +
        '            return setSubSelectQuery(relationship);\n' +
        '        }\n' +
        '\n' +
        '        private QueryFactory setSubSelectQuery(ChildRelationship relationship) {\n' +
        '            if (this.relationship != null) {\n' +
        '                throw new jam.ProcessException(\'Invalid call to subselectQuery.  You may not add a subselect query to a subselect query.\');\n' +
        '            }\n' +
        '            if (this.subSelectQueryMap == null) {\n' +
        '                this.subSelectQueryMap = new Map<ChildRelationship, QueryFactory>();\n' +
        '            }\n' +
        '            if (this.subSelectQueryMap.containsKey(relationship)) {\n' +
        '                return subSelectQueryMap.get(relationship);\n' +
        '            }\n' +
        '\n' +
        '            QueryFactory subSelectQuery = new QueryFactory(relationship);\n' +
        '            subSelectQuery.isSubSelectFactory = true;\n' +
        '\n' +
        '            subSelectQuery.setSortSelectFields(sortSelectFields);\n' +
        '            subSelectQueryMap.put(relationship, subSelectQuery);\n' +
        '            return subSelectQuery;\n' +
        '        }\n' +
        '\n' +
        '        public List<QueryFactory> getSubSelectQueries() {\n' +
        '            if (subSelectQueryMap != null) {\n' +
        '                return subSelectQueryMap.values();\n' +
        '            }\n' +
        '            return null;\n' +
        '        }\n' +
        '\n' +
        '        private Schema.ChildRelationship getChildRelationship(SObjectType objType) {\n' +
        '            for (Schema.ChildRelationship childRow : table.getDescribe().getChildRelationships()) {\n' +
        '                if (childRow.getChildSObject() == objType && childRow.getRelationshipName() != null) {\n' +
        '                    return childRow;\n' +
        '                }\n' +
        '            }\n' +
        '            throw new jam.ProcessException(\'Invalid call to subselectQuery.  Invalid relationship for table \' + table + \' and objtype=\' + objType);\n' +
        '        }\n' +
        '\n' +
        '        private Schema.ChildRelationship getChildRelationship(String relationshipName) {\n' +
        '            for (Schema.ChildRelationship childRow : table.getDescribe().getChildRelationships()) {\n' +
        '                if (childRow.getRelationshipName() == relationshipName) {\n' +
        '                    return childRow;\n' +
        '                }\n' +
        '            }\n' +
        '            return null;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory addOrdering(String fieldName, SortOrder direction, Boolean nullsLast) {\n' +
        '            order.add(\n' +
        '                    new Ordering(getFieldPath(fieldName), direction, nullsLast)\n' +
        '            );\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory addOrdering(SObjectField field, SortOrder direction, Boolean nullsLast) {\n' +
        '            order.add(\n' +
        '                    new Ordering(getFieldTokenPath(field), direction, nullsLast)\n' +
        '            );\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory addOrdering(String fieldName, SortOrder direction) {\n' +
        '            order.add(\n' +
        '                    new Ordering(getFieldPath(fieldName), direction)\n' +
        '            );\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory addOrdering(SObjectField field, SortOrder direction) {\n' +
        '            order.add(\n' +
        '                    new Ordering(getFieldTokenPath(field), direction)\n' +
        '            );\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setOrdering(String fieldName, SortOrder direction, Boolean nullsLast) {\n' +
        '            Ordering ordr = new Ordering(getFieldPath(fieldName), direction, nullsLast);\n' +
        '            return setOrdering(ordr);\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setOrdering(SObjectField field, SortOrder direction, Boolean nullsLast) {\n' +
        '            Ordering ordr = new Ordering(getFieldTokenPath(field), direction, nullsLast);\n' +
        '            return setOrdering(ordr);\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setOrdering(String fieldName, SortOrder direction) {\n' +
        '            Ordering ordr = new Ordering(getFieldPath(fieldName), direction);\n' +
        '            return setOrdering(ordr);\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory setOrdering(SObjectField field, SortOrder direction) {\n' +
        '            Ordering ordr = new Ordering(getFieldTokenPath(field), direction);\n' +
        '            return setOrdering(ordr);\n' +
        '        }\n' +
        '\n' +
        '        public String toSOQL() {\n' +
        '            String result = \'SELECT \';\n' +
        '\n' +
        '            if (fields.size() == 0) {\n' +
        '                result += \'Id\';\n' +
        '            } else {\n' +
        '                List<String> fieldsToQuery = new List<String>(fields);\n' +
        '\n' +
        '                if (sortSelectFields) {\n' +
        '                    fieldsToQuery.sort();\n' +
        '                }\n' +
        '\n' +
        '                result += String.join(fieldsToQuery, \', \');\n' +
        '            }\n' +
        '\n' +
        '            if (subSelectQueryMap != null && !subSelectQueryMap.isEmpty()) {\n' +
        '                for (QueryFactory childRow : subSelectQueryMap.values()) {\n' +
        '                    result += \', (\' + childRow.toSOQL() + \') \';\n' +
        '                }\n' +
        '            }\n' +
        '\n' +
        '            result += \' FROM \' + (relationship != null ? relationship.getRelationshipName() : table.getDescribe().getName());\n' +
        '            if (String.isNotBlank(conditionExpression)) result += \' WHERE \' + conditionExpression;\n' +
        '\n' +
        '            if (this.isSecurityEnforced && !this.isSubSelectFactory) {\n' +
        '                result += \' WITH USER_MODE\';\n' +
        '            }\n' +
        '\n' +
        '            if (order.size() > 0) {\n' +
        '                result += \' ORDER BY \';\n' +
        '                for (Ordering o : order) result += o.toSOQL() + \', \';\n' +
        '                result = result.substring(0, result.length() - 2);\n' +
        '            }\n' +
        '\n' +
        '            if (limitCount != null) result += \' LIMIT \' + limitCount;\n' +
        '\n' +
        '            if (offsetCount != null) result += \' OFFSET \' + offsetCount;\n' +
        '\n' +
        '            return result;\n' +
        '        }\n' +
        '\n' +
        '        public List<SObject> query() {\n' +
        '            return (this.bindVariablesMap == null) ?\n' +
        '                    Database.query(this.toSOQL()) :\n' +
        '                    Database.queryWithBinds(\n' +
        '                            this.toSOQL().remove(\'WITH USER_MODE\'),\n' +
        '                            this.bindVariablesMap,\n' +
        '                            this.isSecurityEnforced ? AccessLevel.USER_MODE : AccessLevel.SYSTEM_MODE\n' +
        '                    );\n' +
        '        }\n' +
        '\n' +
        '        public SObject queryFirstOrException() {\n' +
        '            return this.queryFirstOrException(\'No records found for query: \' + this.toSOQL());\n' +
        '        }\n' +
        '\n' +
        '        public SObject queryFirstOrException(String errorMessage) {\n' +
        '            this.setLimit(1);\n' +
        '            return (SObject) jam.arrays.firstOrException(this.query(), errorMessage);\n' +
        '        }\n' +
        '\n' +
        '        public SObject queryFirstOrNull() {\n' +
        '            this.setLimit(1);\n' +
        '            return (SObject) jam.arrays.firstOrNull(this.query());\n' +
        '        }\n' +
        '\n' +
        '        public QueryFactory deepClone() {\n' +
        '\n' +
        '            QueryFactory clone = new QueryFactory(this.table)\n' +
        '                    .setLimit(this.limitCount)\n' +
        '                    .setOffset(this.offsetCount)\n' +
        '                    .setCondition(this.conditionExpression)\n' +
        '                    .setBindVariables(this.bindVariablesMap);\n' +
        '\n' +
        '            Map<Schema.ChildRelationship, QueryFactory> subqueries = this.subSelectQueryMap;\n' +
        '            if (subqueries != null) {\n' +
        '                Map<Schema.ChildRelationship, QueryFactory> clonedSubqueries = new Map<Schema.ChildRelationship, QueryFactory>();\n' +
        '                for (Schema.ChildRelationship key : subqueries.keySet()) {\n' +
        '                    clonedSubqueries.put(key, subqueries.get(key).deepClone());\n' +
        '                }\n' +
        '                clone.subSelectQueryMap = clonedSubqueries;\n' +
        '            }\n' +
        '\n' +
        '            clone.relationship = this.relationship;\n' +
        '            clone.order = this.order.clone();\n' +
        '            clone.fields = this.fields.clone();\n' +
        '\n' +
        '            return clone;\n' +
        '        }\n' +
        '\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class Ordering {\n' +
        '        private SortOrder direction;\n' +
        '        private Boolean nullsLast;\n' +
        '        private String field;\n' +
        '\n' +
        '        public Ordering(String sObjectTypeStr, String fieldName, SortOrder direction) {\n' +
        '\n' +
        '            this(\n' +
        '                    Schema.getGlobalDescribe().get(sObjectTypeStr.toLowerCase()).getDescribe().fields.getMap().get(fieldName),\n' +
        '                    direction\n' +
        '            );\n' +
        '        }\n' +
        '\n' +
        '        public Ordering(Schema.SObjectField field, SortOrder direction) {\n' +
        '            this(field.getDescribe().getName(), direction, false);\n' +
        '        }\n' +
        '        public Ordering(Schema.SObjectField field, SortOrder direction, Boolean nullsLast) {\n' +
        '            this(field.getDescribe().getName(), direction, nullsLast);\n' +
        '        }\n' +
        '        @TestVisible\n' +
        '        private Ordering(String field, SortOrder direction) {\n' +
        '            this(field, direction, false);\n' +
        '        }\n' +
        '        @TestVisible\n' +
        '        private Ordering(String field, SortOrder direction, Boolean nullsLast) {\n' +
        '            this.direction = direction;\n' +
        '            this.field = field;\n' +
        '            this.nullsLast = nullsLast;\n' +
        '        }\n' +
        '        public String getField() {\n' +
        '            return this.field;\n' +
        '        }\n' +
        '        public SortOrder getDirection() {\n' +
        '            return direction;\n' +
        '        }\n' +
        '        public String toSOQL() {\n' +
        '            return field + \' \' + (direction == SortOrder.ASCENDING ? \'ASC\' : \'DESC\') + (nullsLast ? \' NULLS LAST \' : \' NULLS FIRST \');\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public enum SortOrder {\n' +
        '        ASCENDING, DESCENDING\n' +
        '    }\n' +
        '\n' +
        '    public static UnitOfWork uow(List<SObjectType> sObjectTypes) {\n' +
        '        return new UnitOfWork(sObjectTypes);\n' +
        '    }\n' +
        '\n' +
        '    //UNIT OF WORK\n' +
        '    public interface IDoWork {\n' +
        '        void doWork();\n' +
        '    }\n' +
        '\n' +
        '    public interface IDML {\n' +
        '        void dmlInsert(List<SObject> objList);\n' +
        '        void dmlUpdate(List<SObject> objList);\n' +
        '        void dmlDelete(List<SObject> objList);\n' +
        '        void eventPublish(List<SObject> objList);\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class DMLAsUserImpl implements IDML {\n' +
        '        public void dmlInsert(List<SObject> objList) {\n' +
        '            jam.sObjects.insertAsUser(objList);\n' +
        '        }\n' +
        '        public void dmlUpdate(List<SObject> objList) {\n' +
        '            jam.sObjects.updateAsUser(objList);\n' +
        '        }\n' +
        '        public void dmlDelete(List<SObject> objList) {\n' +
        '            jam.sObjects.deleteAsUser(objList);\n' +
        '        }\n' +
        '        public void eventPublish(List<SObject> objList) {\n' +
        '            EventBus.publish(objList);\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing class DMLAsSystemImpl implements IDML {\n' +
        '        public void dmlInsert(List<SObject> objList) {\n' +
        '            insert objList;\n' +
        '        }\n' +
        '        public void dmlUpdate(List<SObject> objList) {\n' +
        '            update objList;\n' +
        '        }\n' +
        '        public void dmlDelete(List<SObject> objList) {\n' +
        '            delete objList;\n' +
        '        }\n' +
        '        public void eventPublish(List<SObject> objList) {\n' +
        '            EventBus.publish(objList);\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    private inherited sharing class DoHierarchyWork implements jam.IDoWork {\n' +
        '        IDML dmlImpl;\n' +
        '\n' +
        '        public DoHierarchyWork(UnitOfWork uow) {\n' +
        '            this.dmlImpl = uow.getDmlImpl();\n' +
        '            uow.registerWork(this);\n' +
        '        }\n' +
        '\n' +
        '        private List<HierarchyReference> references = new List<HierarchyReference>();\n' +
        '\n' +
        '        public void registerRelationship(SObject child, SObjectField field, SObject parent) {\n' +
        '            this.registerRelationship(new HierarchyReference(child, field, parent));\n' +
        '        }\n' +
        '\n' +
        '        public void registerRelationship(HierarchyReference parentChildReference) {\n' +
        '            this.references.add(parentChildReference);\n' +
        '        }\n' +
        '\n' +
        '        public void doWork() {\n' +
        '            Map<SObjectType, List<SObject>> recordsToUpdateMap = new Map<SObjectType, List<SObject>>();\n' +
        '\n' +
        '            for (HierarchyReference referenceVar : references) {\n' +
        '\n' +
        '                referenceVar.child.put(referenceVar.field, referenceVar.parent.Id);\n' +
        '\n' +
        '                List<SObject> records = recordsToUpdateMap.get(referenceVar.child.getSObjectType());\n' +
        '                if (records == null) {\n' +
        '                    records = new List<SObject>();\n' +
        '                    recordsToUpdateMap.put(referenceVar.child.getSObjectType(), records);\n' +
        '                }\n' +
        '\n' +
        '                if (new Map<Id, SObject>(records).containsKey(referenceVar.child.Id) == false) {\n' +
        '                    records.add(referenceVar.child);\n' +
        '                }\n' +
        '\n' +
        '            }\n' +
        '\n' +
        '            for (SObjectType sObjectTypeVar : recordsToUpdateMap.keySet()) {\n' +
        '                dmlImpl.dmlUpdate(recordsToUpdateMap.get(sObjectTypeVar));\n' +
        '            }\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    private inherited sharing class HierarchyReference {\n' +
        '        public SObject child;\n' +
        '        public SObjectField field;\n' +
        '        public SObject parent;\n' +
        '\n' +
        '        public HierarchyReference(SObject child, SObjectField field, SObject parent) {\n' +
        '            this.child = child;\n' +
        '            this.field = field;\n' +
        '            this.parent = parent;\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    private inherited sharing class Relationships {\n' +
        '        private List<IRelationship> m_relationships = new List<IRelationship>();\n' +
        '\n' +
        '        public void resolve() {\n' +
        '            for (IRelationship relationship : m_relationships) {\n' +
        '                relationship.resolve();\n' +
        '            }\n' +
        '\n' +
        '        }\n' +
        '\n' +
        '        public void add(SObject record, Schema.SObjectField relatedToField, SObject relatedTo) {\n' +
        '            Relationship relationship = new Relationship();\n' +
        '            relationship.Record = record;\n' +
        '            relationship.RelatedToField = relatedToField;\n' +
        '            relationship.RelatedTo = relatedTo;\n' +
        '            m_relationships.add(relationship);\n' +
        '        }\n' +
        '\n' +
        '        public void add(Messaging.SingleEmailMessage email, SObject relatedTo) {\n' +
        '            EmailRelationship emailRelationship = new EmailRelationship();\n' +
        '            emailRelationship.email = email;\n' +
        '            emailRelationship.relatedTo = relatedTo;\n' +
        '            m_relationships.add(emailRelationship);\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    private interface IRelationship {\n' +
        '        void resolve();\n' +
        '    }\n' +
        '\n' +
        '    private inherited sharing class Relationship implements IRelationship {\n' +
        '        public SObject Record;\n' +
        '        public Schema.SObjectField RelatedToField;\n' +
        '        public SObject RelatedTo;\n' +
        '\n' +
        '        public void resolve() {\n' +
        '            this.Record.put(this.RelatedToField, this.RelatedTo.Id);\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    private inherited sharing class EmailRelationship implements IRelationship {\n' +
        '        public Messaging.SingleEmailMessage email;\n' +
        '        public SObject relatedTo;\n' +
        '\n' +
        '        public void resolve() {\n' +
        '            this.email.setWhatId(this.relatedTo.Id);\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public interface IEmailWork extends IDoWork {\n' +
        '        void registerEmail(Messaging.Email email);\n' +
        '    }\n' +
        '\n' +
        '    private inherited sharing class SendEmailWork implements IEmailWork {\n' +
        '        private List<Messaging.Email> emails;\n' +
        '\n' +
        '        public SendEmailWork() {\n' +
        '            this.emails = new List<Messaging.Email>();\n' +
        '        }\n' +
        '\n' +
        '        public void registerEmail(Messaging.Email email) {\n' +
        '            this.emails.add(email);\n' +
        '        }\n' +
        '\n' +
        '        public void doWork() {\n' +
        '            if (emails.size() > 0) Messaging.sendEmail(emails);\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '    public inherited sharing virtual class UnitOfWork {\n' +
        '        protected List<Schema.SObjectType> m_sObjectTypes = new List<Schema.SObjectType>();\n' +
        '\n' +
        '        protected Map<String, List<SObject>> m_newListByType = new Map<String, List<SObject>>();\n' +
        '\n' +
        '        protected Map<String, Map<Id, SObject>> m_dirtyMapByType = new Map<String, Map<Id, SObject>>();\n' +
        '\n' +
        '        protected Map<String, Map<Id, SObject>> m_deletedMapByType = new Map<String, Map<Id, SObject>>();\n' +
        '\n' +
        '        protected Map<String, Relationships> m_relationships = new Map<String, Relationships>();\n' +
        '\n' +
        '        protected Map<String, List<SObject>> m_publishBeforeListByType = new Map<String, List<SObject>>();\n' +
        '        protected Map<String, List<SObject>> m_publishAfterSuccessListByType = new Map<String, List<SObject>>();\n' +
        '        protected Map<String, List<SObject>> m_publishAfterFailureListByType = new Map<String, List<SObject>>();\n' +
        '\n' +
        '        protected List<IDoWork> m_workList = new List<IDoWork>();\n' +
        '\n' +
        '        @TestVisible\n' +
        '        protected IEmailWork m_emailWork = new SendEmailWork();\n' +
        '\n' +
        '        protected IDML m_dml;\n' +
        '\n' +
        '        private DoHierarchyWork doHierarchyWork;\n' +
        '\n' +
        '        public UnitOfWork(List<Schema.SObjectType> sObjectTypes) {\n' +
        '            this(sObjectTypes, new DMLAsUserImpl());\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml) {\n' +
        '            this.m_sObjectTypes = sObjectTypes.clone();\n' +
        '\n' +
        '            for (Schema.SObjectType sObjectType : this.m_sObjectTypes) {\n' +
        '                handleRegisterType(sObjectType);\n' +
        '            }\n' +
        '\n' +
        '            this.m_relationships.put(Messaging.SingleEmailMessage.class.getName(), new Relationships());\n' +
        '            this.m_dml = dml;\n' +
        '            this.doHierarchyWork = new DoHierarchyWork(this);\n' +
        '        }\n' +
        '\n' +
        '        public IDML getDmlImpl() {\n' +
        '            return this.m_dml;\n' +
        '        }\n' +
        '\n' +
        '        public virtual void onRegisterType(Schema.SObjectType sObjectType) {\n' +
        '        }\n' +
        '        public virtual void onCommitWorkStarting() {\n' +
        '        }\n' +
        '\n' +
        '        public virtual void onPublishBeforeEventsStarting() {\n' +
        '        }\n' +
        '        public virtual void onPublishBeforeEventsFinished() {\n' +
        '        }\n' +
        '\n' +
        '        public virtual void onDMLStarting() {\n' +
        '        }\n' +
        '        public virtual void onDMLFinished() {\n' +
        '        }\n' +
        '\n' +
        '        public virtual void onDoWorkStarting() {\n' +
        '        }\n' +
        '        public virtual void onDoWorkFinished() {\n' +
        '        }\n' +
        '\n' +
        '        public virtual void onPublishAfterSuccessEventsStarting() {\n' +
        '        }\n' +
        '        public virtual void onPublishAfterSuccessEventsFinished() {\n' +
        '        }\n' +
        '\n' +
        '        public virtual void onPublishAfterFailureEventsStarting() {\n' +
        '        }\n' +
        '        public virtual void onPublishAfterFailureEventsFinished() {\n' +
        '        }\n' +
        '\n' +
        '        public virtual void onCommitWorkFinishing() {\n' +
        '        }\n' +
        '        public virtual void onCommitWorkFinished(Boolean wasSuccessful) {\n' +
        '        }\n' +
        '\n' +
        '        private void handleRegisterType(Schema.SObjectType sObjectType) {\n' +
        '            String sObjectName = sObjectType.getDescribe().getName();\n' +
        '\n' +
        '            m_newListByType.put(sObjectName, new List<SObject>());\n' +
        '            m_dirtyMapByType.put(sObjectName, new Map<Id, SObject>());\n' +
        '            m_deletedMapByType.put(sObjectName, new Map<Id, SObject>());\n' +
        '            m_relationships.put(sObjectName, new Relationships());\n' +
        '\n' +
        '            m_publishBeforeListByType.put(sObjectName, new List<SObject>());\n' +
        '            m_publishAfterSuccessListByType.put(sObjectName, new List<SObject>());\n' +
        '            m_publishAfterFailureListByType.put(sObjectName, new List<SObject>());\n' +
        '\n' +
        '            onRegisterType(sObjectType);\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerWork(IDoWork work) {\n' +
        '            m_workList.add(work);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerEmail(Messaging.Email email) {\n' +
        '            m_emailWork.registerEmail(email);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerNew(SObject record) {\n' +
        '            registerNew(record, null, null);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerNew(List<SObject> records) {\n' +
        '            for (SObject record : records) {\n' +
        '                registerNew(record, null, null);\n' +
        '            }\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerNew(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord) {\n' +
        '            if (record.Id != null) {\n' +
        '                throw new jam.ProcessException(\'Only new records can be registered as new\');\n' +
        '            }\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) == \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} must use registerPublishBeforeTransaction or \' +\n' +
        '                        \'registerPublishAfterTransaction methods to be used within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_newListByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '            m_newListByType.get(sObjectType).add(record);\n' +
        '            if (relatedToParentRecord != null && relatedToParentField != null) {\n' +
        '                registerRelationship(record, relatedToParentField, relatedToParentRecord);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerUpsert(SObject record) {\n' +
        '            if (record.Id == null) {\n' +
        '                this.registerNew(record);\n' +
        '            } else {\n' +
        '                this.registerDirty(record);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerUpsert(List<SObject> records) {\n' +
        '            for (SObject record : records) {\n' +
        '                this.registerUpsert(record);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerRelationship(List<SObject> records, Schema.SObjectField relatedToField, SObject relatedTo) {\n' +
        '            for (SObject record : records) {\n' +
        '                this.registerRelationship(record, relatedToField, relatedTo);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo) {\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) == \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} must use registerPublishBeforeTransaction or \' +\n' +
        '                        \'registerPublishAfterTransaction methods to be used within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_newListByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '            m_relationships.get(sObjectType).add(record, relatedToField, relatedTo);\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerRelationship(Messaging.SingleEmailMessage email, SObject relatedTo) {\n' +
        '            m_relationships.get(Messaging.SingleEmailMessage.class.getName()).add(email, relatedTo);\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerDirty(SObject record) {\n' +
        '            registerDirty(record, new List<SObjectField>());\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerDirty(SObject record, List<SObjectField> dirtyFields) {\n' +
        '            if (record.Id == null) {\n' +
        '                throw new jam.ProcessException(\'New records cannot be registered as dirty\');\n' +
        '            }\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) == \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} must use registerPublishBeforeTransaction or \' +\n' +
        '                        \'registerPublishAfterTransaction methods to be used within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_dirtyMapByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_dirtyMapByType.get(sObjectType).containsKey(record.Id) || dirtyFields.isEmpty()) {\n' +
        '                m_dirtyMapByType.get(sObjectType).put(record.Id, record);\n' +
        '            } else {\n' +
        '                SObject registeredRecord = m_dirtyMapByType.get(sObjectType).get(record.Id);\n' +
        '\n' +
        '                for (SObjectField dirtyField : dirtyFields) {\n' +
        '                    registeredRecord.put(dirtyField, record.get(dirtyField));\n' +
        '                }\n' +
        '\n' +
        '                m_dirtyMapByType.get(sObjectType).put(record.Id, registeredRecord);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerDirty(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord) {\n' +
        '            if (record.Id == null) {\n' +
        '                throw new jam.ProcessException(\'New records cannot be registered as dirty\');\n' +
        '            }\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) == \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} must use registerPublishBeforeTransaction or \' +\n' +
        '                        \'registerPublishAfterTransaction methods to be used within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_dirtyMapByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '            m_dirtyMapByType.get(sObjectType).put(record.Id, record);\n' +
        '            if (relatedToParentRecord != null && relatedToParentField != null) {\n' +
        '                registerRelationship(record, relatedToParentField, relatedToParentRecord);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerDirty(List<SObject> records) {\n' +
        '            for (SObject record : records) {\n' +
        '                this.registerDirty(record);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerDeleted(SObject record) {\n' +
        '            if (record.Id == null) {\n' +
        '                throw new jam.ProcessException(\'New records cannot be registered for deletion\');\n' +
        '            }\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) == \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} must use registerPublishBeforeTransaction or \' +\n' +
        '                        \'registerPublishAfterTransaction methods to be used within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_deletedMapByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '            m_deletedMapByType.get(sObjectType).put(record.Id, record);\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerDeleted(List<SObject> records) {\n' +
        '            for (SObject record : records) {\n' +
        '                this.registerDeleted(record);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerHierarchy(SObject child, SObjectField field, SObject parent) {\n' +
        '            if (child.getSObjectType() == parent.getSObjectType()) {\n' +
        '                doHierarchyWork.registerRelationship(child, field, parent);\n' +
        '            } else {\n' +
        '                throw new jam.ProcessException(\'Couldn\\\'t create hierarchy relationship for different SObject Types.\');\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerPublishBeforeTransaction(SObject record) {\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) != \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is invalid for publishing within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_publishBeforeListByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            m_publishBeforeListByType.get(sObjectType).add(record);\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerPublishBeforeTransaction(List<SObject> records) {\n' +
        '            for (SObject record : records) {\n' +
        '                this.registerPublishBeforeTransaction(record);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerPublishAfterSuccessTransaction(SObject record) {\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) != \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is invalid for publishing within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_publishAfterSuccessListByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            m_publishAfterSuccessListByType.get(sObjectType).add(record);\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerPublishAfterSuccessTransaction(List<SObject> records) {\n' +
        '            for (SObject record : records) {\n' +
        '                this.registerPublishAfterSuccessTransaction(record);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerPublishAfterFailureTransaction(SObject record) {\n' +
        '            String sObjectType = record.getSObjectType().getDescribe().getName();\n' +
        '\n' +
        '            if (sObjectType.length() > 3 && sObjectType.right(3) != \'__e\') {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is invalid for publishing within this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            if (!m_publishAfterFailureListByType.containsKey(sObjectType)) {\n' +
        '                throw new jam.ProcessException(String.format(\'SObject type {0} is not supported by this unit of work\', new String[]{\n' +
        '                        sObjectType\n' +
        '                }));\n' +
        '            }\n' +
        '\n' +
        '            m_publishAfterFailureListByType.get(sObjectType).add(record);\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public UnitOfWork registerPublishAfterFailureTransaction(List<SObject> records) {\n' +
        '            for (SObject record : records) {\n' +
        '                this.registerPublishAfterFailureTransaction(record);\n' +
        '            }\n' +
        '\n' +
        '            return this;\n' +
        '        }\n' +
        '\n' +
        '        public void commitWork() {\n' +
        '            onCommitWorkStarting();\n' +
        '\n' +
        '            Savepoint sp = Database.setSavepoint();\n' +
        '            Boolean wasSuccessful = false;\n' +
        '            try {\n' +
        '                onPublishBeforeEventsStarting();\n' +
        '\n' +
        '                for (Schema.SObjectType sObjectType : m_sObjectTypes) {\n' +
        '                    m_dml.eventPublish(m_publishBeforeListByType.get(sObjectType.getDescribe().getName()));\n' +
        '                }\n' +
        '\n' +
        '                onPublishBeforeEventsFinished();\n' +
        '\n' +
        '                onDMLStarting();\n' +
        '                for (Schema.SObjectType sObjectType : m_sObjectTypes) {\n' +
        '                    m_relationships.get(sObjectType.getDescribe().getName()).resolve();\n' +
        '                    m_dml.dmlInsert(m_newListByType.get(sObjectType.getDescribe().getName()));\n' +
        '                }\n' +
        '                for (Schema.SObjectType sObjectType : m_sObjectTypes) {\n' +
        '                    m_dml.dmlUpdate(m_dirtyMapByType.get(sObjectType.getDescribe().getName()).values());\n' +
        '                }\n' +
        '                Integer objectIdx = m_sObjectTypes.size() - 1;\n' +
        '                while (objectIdx >= 0) {\n' +
        '                    m_dml.dmlDelete(m_deletedMapByType.get(m_sObjectTypes[objectIdx--].getDescribe().getName()).values());\n' +
        '                }\n' +
        '\n' +
        '                m_relationships.get(Messaging.SingleEmailMessage.class.getName()).resolve();\n' +
        '\n' +
        '                onDMLFinished();\n' +
        '\n' +
        '                onDoWorkStarting();\n' +
        '                m_workList.add(m_emailWork);\n' +
        '                for (IDoWork work : m_workList) {\n' +
        '                    work.doWork();\n' +
        '                }\n' +
        '                onDoWorkFinished();\n' +
        '\n' +
        '                onCommitWorkFinishing();\n' +
        '\n' +
        '                wasSuccessful = true;\n' +
        '            } catch (Exception e) {\n' +
        '                Database.rollback(sp);\n' +
        '\n' +
        '                throw e;\n' +
        '            } finally {\n' +
        '\n' +
        '                if (wasSuccessful) {\n' +
        '                    onPublishAfterSuccessEventsStarting();\n' +
        '\n' +
        '                    for (Schema.SObjectType sObjectType : m_sObjectTypes) {\n' +
        '                        m_dml.eventPublish(m_publishAfterSuccessListByType.get(sObjectType.getDescribe().getName()));\n' +
        '                    }\n' +
        '\n' +
        '                    onPublishAfterSuccessEventsFinished();\n' +
        '                } else {\n' +
        '                    onPublishAfterFailureEventsStarting();\n' +
        '\n' +
        '                    for (Schema.SObjectType sObjectType : m_sObjectTypes) {\n' +
        '                        m_dml.eventPublish(m_publishAfterFailureListByType.get(sObjectType.getDescribe().getName()));\n' +
        '                    }\n' +
        '\n' +
        '                    onPublishAfterFailureEventsFinished();\n' +
        '                }\n' +
        '\n' +
        '                onCommitWorkFinished(wasSuccessful);\n' +
        '            }\n' +
        '        }\n' +
        '    }\n' +
        '\n' +
        '\n' +
        '    //UTILS LAZY PROPERTIES\n' +
        '    public static PicklistExtensions picklists {\n' +
        '        get {\n' +
        '            if (picklists == null) {\n' +
        '                picklists = new PicklistExtensions();\n' +
        '            }\n' +
        '            return picklists;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static DateExtensions dates {\n' +
        '        get {\n' +
        '            if (dates == null) {\n' +
        '                dates = new DateExtensions();\n' +
        '            }\n' +
        '            return dates;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static StringExtensions strings {\n' +
        '        get {\n' +
        '            if (strings == null) {\n' +
        '                strings = new StringExtensions();\n' +
        '            }\n' +
        '            return strings;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static UserExtensions users {\n' +
        '        get {\n' +
        '            if (users == null) {\n' +
        '                users = new UserExtensions();\n' +
        '            }\n' +
        '            return users;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static SObjectExtensions sObjects {\n' +
        '        get {\n' +
        '            if (sObjects == null) {\n' +
        '                sObjects = new SObjectExtensions();\n' +
        '            }\n' +
        '            return sObjects;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static URLExtensions URLs {\n' +
        '        get {\n' +
        '            if (URLs == null) {\n' +
        '                URLs = new URLExtensions();\n' +
        '            }\n' +
        '            return URLs;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static EncodingExtensions encodings {\n' +
        '        get {\n' +
        '            if (encodings == null) {\n' +
        '                encodings = new EncodingExtensions();\n' +
        '            }\n' +
        '            return encodings;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static ArrayExtensions arrays {\n' +
        '        get {\n' +
        '            if (arrays == null) {\n' +
        '                arrays = new ArrayExtensions();\n' +
        '            }\n' +
        '            return arrays;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static ObjectExtensions objects {\n' +
        '        get {\n' +
        '            if (objects == null) {\n' +
        '                objects = new ObjectExtensions();\n' +
        '            }\n' +
        '            return objects;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static TemplateExtensions templates {\n' +
        '        get {\n' +
        '            if (templates == null) {\n' +
        '                templates = new TemplateExtensions();\n' +
        '            }\n' +
        '            return templates;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static Organization currentOrg {\n' +
        '        get {\n' +
        '            if (currentOrg == null) {\n' +
        '                currentOrg = (Organization) jam.arrays.firstOrException([\n' +
        '                        SELECT IsSandbox, TrialExpirationDate\n' +
        '                        FROM Organization\n' +
        '                        WHERE Id = :UserInfo.getOrganizationId()\n' +
        '                ], \' No Organisation\');\n' +
        '            }\n' +
        '            return currentOrg;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static Boolean isSandbox {\n' +
        '        get {\n' +
        '            return currentOrg.IsSandbox && currentOrg.TrialExpirationDate == null;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static Boolean isScratch {\n' +
        '        get {\n' +
        '            return currentOrg.IsSandbox && currentOrg.TrialExpirationDate != null;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static Boolean isTrialOrg {\n' +
        '        get {\n' +
        '            return !currentOrg.IsSandbox && currentOrg.TrialExpirationDate != null;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '\n' +
        '    public static List<Holiday> holidays {\n' +
        '        get {\n' +
        '            if (holidays == null) {\n' +
        '                holidays = [\n' +
        '                        SELECT StartTimeInMinutes, EndTimeInMinutes, Name, ActivityDate, Description, IsAllDay, IsRecurrence\n' +
        '                        FROM Holiday\n' +
        '                ];\n' +
        '            }\n' +
        '            return holidays;\n' +
        '        }\n' +
        '        private set;\n' +
        '    }\n' +
        '}