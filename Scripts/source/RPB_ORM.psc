scriptname RPB_ORM hidden

import RPB_Utility

; ==========================================================
;                           Query
; ==========================================================

string function QueryString(int apRootObject, string asSelect = "*", string apFindConditions = "[]", string asDefaultValue = "", bool abCheckExists = true, string asPathDelimiter = "//") global

endFunction

Form[] function QueryFormArray(int apRootObject, string asSelect = "*", string apFindConditions = "[]", Form[] akDefaultValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
    int parentObject = apRootObject

    if (JValue.empty(parentObject))
        return akDefaultValue
    endif
    
    string query = NormalizeJSON(apFindConditions)
    int formsInContainer
    int returnedFormArray = JArray.object()

    string[] selectedAttributes
    if (asSelect != "*")
        selectedAttributes = StringUtil.Split(asSelect, ",")
    endif

    bool isSelectQuery = asSelect != "*" && selectedAttributes.Length > 0

    if (JValue.isMap(parentObject))
        ; Process all Form values inside the map
        formsInContainer = JMap.allValues(parentObject)

    elseif (JValue.isIntegerMap(parentObject))
        formsInContainer = JIntMap.allValues(parentObject)

    elseif (JValue.isFormMap(parentObject))
        formsInContainer = JFormMap.allKeys(parentObject)

    elseif (JValue.isArray(parentObject))
        formsInContainer = parentObject ; To be revised
    endif

    int formsLength = JValue.count(formsInContainer)

    if (JValue.isFormMap(parentObject))
        int i = 0
        while (i < formsLength)
            Form childKey       = JFormMap.getNthKey(parentObject, i)
            int childObject     = JFormMap.getObj(parentObject, childKey)
            bool conditionsMet  = CheckFindConditions(childObject, query)
            if (conditionsMet)
                if (isSelectQuery)
                    int selectedObject  = __performSelect(childObject, selectedAttributes)
                    ; int mergedArray     = __mergeArray(selectedObject)
                    int selectedObjectValues = JMap.allValues(selectedObject) ; Array
                    int currentSelectObject = 0
                    while (currentSelectObject < JValue.count(selectedObjectValues))
                        int currentObject = JArray.getObj(selectedObjectValues, currentSelectObject)
                        JArray.addFromArray(returnedFormArray, currentObject)
                        currentSelectObject += 1
                    endWhile
                    ; Debug("Data::QueryFormArray", "selectedObjectValues: " + GetContainerList(selectedObjectValues))
                    ; JArray.addObj(returnedFormArray, selectedObjectValues)
                    ; JArray.addFromArray(returnedFormArray, selectedObjectValues)
                else
                    JArray.addForm(returnedFormArray, childKey)
                endif
            endif
            i += 1
        endWhile
    endif
    ; Debug("Data::QueryFormArray", "returnedFormArray: " + GetContainerList(returnedFormArray))

    ; return none
    return JArray.asFormArray(returnedFormArray)
endFunction

; ==========================================================
;                       
; ==========================================================

int function __mergeArray(int apObject) global
    int arr = JArray.object()
    int selectedObjectValues = JMap.allValues(apObject) ; Array

    int i = 0
    while (i < selectedObjectValues)
        int currentObject = JArray.getObj(selectedObjectValues, i)
        JArray.addFromArray(arr, currentObject)
        i += 1
    endWhile

    return arr
endFunction

;/
    Performs the SELECT part of the Query on @apChildObject.

    returns (JMap<any & <JContainer> >): An object containing the selected attributes.
/;
int function __performSelect(int apChildObject, string[] akSelectedAttributes) global
    ; int selectedFields = JArray.object()
    int selectedFields = JMap.object()
    int j = 0
    while (j < akSelectedAttributes.Length)
        int selectedObject = JMap.getObj(apChildObject, akSelectedAttributes[j])
        if (selectedObject)
            ; JArray.addFromArray(selectedFields, selectedObject)
            JMap.setObj(selectedFields, akSelectedAttributes[j], selectedObject)
        endif
        j += 1
    endWhile

    return selectedFields
endFunction

; ==========================================================
;                       Compare Values
; ==========================================================

bool function CompareIntValues(int apObject, int conditionValue, string conditionKey, int actualValueType) global
    int TYPE_INT    = 2
    int TYPE_FLOAT  = 3
    int TYPE_STRING = 6
    int TYPE_FORM   = 5

    if (actualValueType == TYPE_INT)
        int actualValue = JMap.getInt(apObject, conditionKey)
        return actualValue == conditionValue

    elseif (actualValueType == TYPE_FLOAT)
        float actualValue = JMap.getFlt(apObject, conditionKey)
        return actualValue == conditionValue

    elseif (actualValueType == TYPE_STRING)
        string actualValue = JMap.getStr(apObject, conditionKey)
        return actualValue == conditionValue as string
    endif

    return false
endFunction

bool function CompareFloatValues(int apObject, float conditionValue, string conditionKey, int actualValueType) global
    int TYPE_INT    = 2
    int TYPE_FLOAT  = 3
    int TYPE_STRING = 6

    if (actualValueType == TYPE_INT)
        int actualValue = JMap.getInt(apObject, conditionKey)
        return actualValue == conditionValue

    elseif (actualValueType == TYPE_FLOAT)
        float actualValue = JMap.getFlt(apObject, conditionKey)
        return actualValue == conditionValue

    elseif (actualValueType == TYPE_STRING)
        string actualValue = JMap.getStr(apObject, conditionKey)
        return actualValue == conditionValue as string
    endif

    return false
endFunction

bool function CompareStringValues(int apObject, string conditionValue, string conditionKey, int actualValueType) global
    int TYPE_INT    = 2
    int TYPE_FLOAT  = 3
    int TYPE_STRING = 6

    if (actualValueType == TYPE_INT)
        int actualValue = JMap.getInt(apObject, conditionKey)
        return actualValue as string == conditionValue

    elseif (actualValueType == TYPE_FLOAT)
        float actualValue = JMap.getFlt(apObject, conditionKey)
        return actualValue as string == conditionValue

    elseif (actualValueType == TYPE_STRING)
        string actualValue = JMap.getStr(apObject, conditionKey)
        return actualValue as string == conditionValue
    endif

    return false
endFunction

bool function CompareOnValueType(int apObject, int apConditionObject, string asConditionKey) global
    int TYPE_INT    = 2
    int TYPE_FLOAT  = 3
    int TYPE_STRING = 6

    int actualValueType     = JMap.valueType(apObject, asConditionKey)
    int conditionValueType  = JMap.valueType(apConditionObject, asConditionKey)

    if (conditionValueType == TYPE_INT)
        int conditionValue = JMap.getInt(apConditionObject, asConditionKey)
        ; LogComparison(conditionValueType, asConditionKey, conditionValue, apObject)
        return CompareIntValues(apObject, conditionValue, asConditionKey, actualValueType)

    elseif (conditionValueType == TYPE_FLOAT)
        float conditionValue = JMap.getFlt(apConditionObject, asConditionKey)
        ; LogComparison(conditionValueType, asConditionKey, conditionValue, apObject)
        return CompareFloatValues(apObject, conditionValue, asConditionKey, actualValueType)

    elseif (conditionValueType == TYPE_STRING)
        string conditionValue = JMap.getStr(apConditionObject, asConditionKey)
        ; LogComparison(conditionValueType, asConditionKey, conditionValue, apObject)
        return CompareStringValues(apObject, conditionValue, asConditionKey, actualValueType)

    else
        ; Debug("Data::CheckFindConditions", "Unsupported value type for key: " + asConditionKey)
        return false
    endif
endFunction

; ==========================================================
;                       Find Conditions
; ==========================================================

bool function Integer_CheckFindConditions(int apObject, int apConditionObject, string asConditionKey, int conditionValue) global
    int actualValueType     = JValue.solvedValueType(apObject, "." + asConditionKey)
    int actualValue         = 0
    bool conditionMet       = false

    if (actualValueType == 2) ; int
        actualValue = JMap.getInt(apObject, asConditionKey)

        Debug("Data::Integer_CheckFindConditions", "Condition (int) vs. Actual (int): ConditionValue: " + conditionValue + ", ActualValueStr: " + actualValue)

        ; Compare the string condition with the stringified integer value
        if (conditionValue == actualValue)
            conditionMet = true
        endif

    elseif (actualValueType == 6) ; string
        actualValue = JMap.getStr(apObject, asConditionKey) as int
        Debug("Data::Integer_CheckFindConditions", "Condition (int) vs. Actual (string): ConditionValue: " + conditionValue + ", ActualValueStr: " + actualValue)

        if (conditionValue == actualValue)
            conditionMet = true
        endif
    endif

    if (!conditionMet)
        Debug("Data::Integer_CheckFindConditions", "Condition failed for key: " + asConditionKey)
        return false
    endif

    Debug("Data::Integer_CheckFindConditions", "All conditions passed, returned true")
    return true
endFunction

bool function Float_CheckFindConditions(int apObject, int apConditionObject, string asConditionKey, float conditionValue) global
    int actualValueType     = JValue.solvedValueType(apObject, "." + asConditionKey)
    float actualValue         = 0
    bool conditionMet       = false

    if (actualValueType == 2) ; int
        float floatValue = JMap.getFlt(apObject, asConditionKey)
        float decimalValue = floatValue - math.floor(floatValue)

        actualValue = JMap.getInt(apObject, asConditionKey)

        Debug("Data::Float_CheckFindConditions", "Condition (float) vs. Actual (int): ConditionValue: " + conditionValue + ", ActualValueStr: " + actualValue)

        ; Compare the string condition with the stringified integer value
        if (conditionValue == actualValue)
            conditionMet = true
        endif
    
    elseif (actualValueType == 3) ; float
        actualValue = JMap.getFlt(apObject, asConditionKey)

        Debug("Data::Float_CheckFindConditions", "Condition (float) vs. Actual (float): ConditionValue: " + conditionValue + ", ActualValueStr: " + actualValue)

        ; Compare the string condition with the stringified integer value
        if (conditionValue == actualValue)
            conditionMet = true
        endif

    elseif (actualValueType == 6) ; string
        actualValue = JMap.getStr(apObject, asConditionKey) as float
        Debug("Data::Float_CheckFindConditions", "Condition (float) vs. Actual (string): ConditionValue: " + conditionValue + ", ActualValueStr: " + actualValue)

        if (conditionValue == actualValue)
            conditionMet = true
        endif
    endif

    if (!conditionMet)
        Debug("Data::Float_CheckFindConditions", "Condition failed for key: " + asConditionKey)
        return false
    endif

    Debug("Data::Float_CheckFindConditions", "All conditions passed, returned true")
    return true
endFunction

bool function String_CheckFindConditions(int apObject, int apConditionObject, string asConditionKey, string asConditionValue, int aiOverrideValueType = 0) global
    int actualValueType     = int_if (aiOverrideValueType != 0, aiOverrideValueType, JValue.solvedValueType(apObject, "." + asConditionKey))
    string actualValue      = ""
    bool conditionMet       = false

    if (actualValueType == 2) ; int
        actualValue = JMap.getInt(apObject, asConditionKey) as string ; Convert the integer to a string for comparison

        Debug("Data::String_CheckFindConditions", "Condition (string) vs. Actual (int): ConditionValue: " + asConditionValue + ", ActualValueStr: " + actualValue)

        ; Compare the string condition with the stringified integer value
        if (asConditionValue == actualValue)
            conditionMet = true
        endif

    elseif (actualValueType == 3) ; float
        actualValue = JMap.getFlt(apObject, asConditionKey) as string ; Convert the integer to a string for comparison
        Debug("Data::String_CheckFindConditions", "Condition (string) vs. Actual (int): ConditionValue: " + asConditionValue + ", ActualValueStr: " + actualValue)

        ; Compare the string condition with the stringified integer value
        if (asConditionValue == actualValue)
            conditionMet = true
        endif

    elseif (actualValueType == 6) ; string
        ; JSON parser doesn't support float, parse it here and override value type
        ; if ()

        actualValue = JMap.getStr(apObject, asConditionKey)
        Debug("Data::String_CheckFindConditions", "Condition (string) vs. Actual (string): ConditionValue: " + asConditionValue + ", ActualValueStr: " + actualValue)

        if (asConditionValue == actualValue)
            conditionMet = true
        endif
    endif

    if (!conditionMet)
        Debug("Data::String_CheckFindConditions", "Condition failed for key: " + asConditionKey)
        return false
    endif

    Debug("Data::String_CheckFindConditions", "All conditions passed, returned true")
    return true
endFunction

bool function CheckFindConditions(int apObject, string apFindConditions, bool abCheckMissingKeys = true) global
    string jsonConditions = NormalizeJSON(apFindConditions)
    int conditionObj      = JValue.objectFromPrototype(jsonConditions)

    if (!conditionObj)
        return false
    endif

    int conditionObjLength  = JValue.count(conditionObj)
    ; Debug("Data::CheckFindConditions", "conditionObjLength: " + conditionObjLength + ", conditionObj: " + GetContainerList(conditionObj) + ", jsonConditions: " + jsonConditions)

    return CheckConditionsRecursively(apObject, conditionObj, abCheckMissingKeys)
endFunction

bool function CheckConditionsRecursively(int apObject, int apConditionObject, bool abCheckMissingKeys = true) global
    int conditionsLength = JValue.count(apConditionObject)

    int TYPE_INT    = 2
    int TYPE_FLOAT  = 3
    int TYPE_STRING = 6
    int TYPE_OBJECT = 5

    int i = 0
    while (i < conditionsLength)
        string conditionKey     = JMap.getNthKey(apConditionObject, i)
        int conditionValueType  = JValue.solvedValueType(apConditionObject, "." + conditionKey)
        bool keyExists          = JValue.hasPath(apObject, "." + conditionKey)

        bool continue = false

        if (!keyExists)
            ; Key is missing, treat it as false
            if (!abCheckMissingKeys && conditionValueType == TYPE_INT)
                int conditionValue = JMap.getInt(apConditionObject, conditionKey)
                if (conditionValue == 0)
                    Debug("Data::CheckConditionsRecursively", "Key Missing: " + conditionKey + ", assuming false, condition satisfied.")
                    continue = true

                else
                    Debug("Data::CheckConditionsRecursively", "Condition failed for Key: " + conditionKey + ", expected true but key is missing, condition not satisfied.")
                    return false
                endif
            endif
        elseif (!JValue.hasPath(apObject, "." + conditionKey) && !continue)
            Debug("Data::CheckConditionsRecursively", "Condition failed for key: " + conditionKey)
            return false
        endif

        if (!continue)
            if (conditionValueType == TYPE_OBJECT)
                int nestedConditionObject   = JMap.getObj(apConditionObject, conditionKey)
                int nestedActualObject      = JMap.getObj(apObject, conditionKey)

                if (!CheckConditionsRecursively(nestedActualObject, nestedConditionObject, abCheckMissingKeys))
                    return false
                endif
            else
                if (!CompareOnValueType(apObject, apConditionObject, conditionKey))
                    return false
                endif
            endif
        endif

        i += 1
    endWhile

    return true
endFunction





;/
    This function is here due to the way syntax highlighting works when using escape sequences.

    Converts single quotes in a JSON string to valid double quotes, making it easier to pass as param
    without using escape sequences.
/;
string function NormalizeJSON(string asJSON) global
    return ReplaceString(asJSON, "'", "\"")
endFunction
