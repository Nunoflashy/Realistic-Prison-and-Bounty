scriptname RPB_Data hidden
{
    Script responsible of handling anything related to the data required for static configuration of the Mod.
}

import RPB_Utility

; ==========================================================
;                           MCM
; ==========================================================

string function MCM_GetRootPropertyOfTypeString(string asMcmObjectName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&

    string rootProperty = JMap.getStr(mcmObject, asProperty)
    return rootProperty
endFunction

string[] function MCM_GetRootPropertyOfTypeStringArray(string asMcmObjectName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&

    int rootProperty = JMap.getObj(mcmObject, asProperty)
    return JArray.asStringArray(rootProperty)
endFunction

int function MCM_GetOptionObject() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, "Config") ; JMap&

    int obj = JMap.getObj(mcmObject, "Options")
    return obj
endFunction

int function MCM_GetDefaultsObject() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, "Config") ; JMap&

    int defaultsObj = JMap.getObj(mcmObject, "Defaults")
    return defaultsObj
endFunction

int function MCM_GetMaximumsObject() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, "Config") ; JMap&

    int obj = JMap.getObj(mcmObject, "Maximums")
    return obj
endFunction

string[] function MCM_GetChildPropertyOfTypeStringArray(string asMcmObjectName, string asChildName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&
    int childObject = JMap.getObj(mcmObject, asChildName) ; JMap&

    int childProperty = JMap.getObj(childObject, asProperty)
    return JArray.asStringArray(childProperty)
endFunction

int function MCM_GetRootPropertyOfTypeObject(string asMcmObjectName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&

    int rootProperty = JMap.getObj(mcmObject, asProperty)
    return rootProperty
endFunction

string function MCM_GetPrisonTemplate() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int statsObj    = JMap.getObj(mcmConfig, "Stats") ; JMap&
    int prisonObj   = JMap.getObj(statsObj, "Prison")

    string prisonTemplate = JMap.getStr(prisonObj, "Template")

    return prisonTemplate
endFunction

string function MCM_GetArrestTemplate() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int statsObj    = JMap.getObj(mcmConfig, "Stats") ; JMap&
    int arrestObj   = JMap.getObj(statsObj, "Arrest")

    string template = JMap.getStr(arrestObj, "Template")

    return template
endFunction



; ==========================================================
;                        Serialization
; ==========================================================

string function GetModDataDirectory() global
    return "Data/RPB_Data/"
endFunction

string function GetDataFile() global
    return "data.json"
endFunction

;/
    Retrieves the root of a hold from the data file specified through @asHold.
    Alternatively, if no hold is specified, the root item of the data file is returned,
    containing every hold.

    string?  @asHold: The hold to retrieve.

    returns (JMap&): A reference to the root object containing all of the Holds, or the specified Hold if specified.
/;
int function GetRootObject(string asHold = "/") global
    int configFile
    bool rootIsLoaded = JDB.hasPath(".rpb_root.data")

    if (rootIsLoaded)
        configFile = JDB.solveObj(".rpb_root.data")
    else
        configFile = Unserialize()
    endif
    
    if (asHold == "/")
        return configFile ; Return the root item of the config file, no hold specified
    endif

    int holdRootItem = JMap.getObj(configFile, asHold)

    return holdRootItem
endFunction

;/
    Sets @apRootContainer to be the root container of the data.
/;
bool function SetRootContainer(int apRootContainer) global
    JDB.setObj("rpb_root.data", apRootContainer)
endFunction

;/
    Binds the container @apContainerToBind to the key @asKey to be the root of this path.
/;
bool function BindContainerToKey(string asKey, int apContainerToBind) global
    JDB.setObj(asKey, apContainerToBind)
endFunction

;/
    Writes the container @apContainer to the main data file.
/;
function Serialize(int apContainer) global
    JValue.writeToFile(apContainer, GetModDataDirectory() + GetDataFile())
endFunction

;/
    Reads all the data from the main data file into the returned object.

    returns (JMap&): A reference to the root object.
/;
int function Unserialize() global
    int unserializedData = JValue.readFromFile(GetModDataDirectory() + GetDataFile())
    SetRootContainer(unserializedData)

    return unserializedData
endFunction

;/
    Refreshes the root item currently stored in .rpb_root with the new content
    from the data file.
/;
int function RefreshRootObject() global
    return Unserialize()
endFunction

; Same as Unserialize()
int function LoadData() global
    return Unserialize()
endFunction

;/
    Saves the root object into the main data file.
/;
function SaveRoot() global
    int rootItem = GetRootObject()
    Serialize(rootItem)
endFunction

; ==========================================================
;                         Data Getters
; ==========================================================

;/
    Retrieves the object at @akExplodedPath[@aiIterations] after traversing the path if it exists.
    By default, it retrieves the second to last element in the path, which is the parent object.

    any& <JContainer>   @apRootObject: The reference to the root object.
    string[]            @akExplodedPath: The path to the object, imploded as an array.
    int?                @aiIterations: How many iterations of the path to traverse. (default n-1)

    returns (any& <JContainer>): The reference to the object that is at the path.
/;
int function TraversePathToFinalObject(int apRootObject, string[] akExplodedPath, int aiIterations = 0) global
    int propertyObject = apRootObject

    if (akExplodedPath.Length == 1)
        return propertyObject
    endif

    int iterations = aiIterations

    if (aiIterations == 0)
         ; second to last element, because the last is not an object, and if it is, we do not want it
        iterations = akExplodedPath.Length - 1
    elseif (iterations > akExplodedPath.Length)
        DebugError("Data::TraversePathToFinalObject", "Number of iterations fall outside of the bounds of the array!")
        return -1
    endif

    int i = 0
    while (i < iterations)
        ; DebugWithArgs("Data::TraversePathToFinalObject", "akExplodedPath: " + akExplodedPath, \
        ;     "\n\t akExplodedPath[i]: "  + akExplodedPath[i] + \
        ;     "\n\t isMap: "              + JValue.isMap(propertyObject) + \
        ;     "\n\t isFormMap: "          + JValue.isFormMap(propertyObject) + \
        ;     "\n\t isIntMap: "           + JValue.isIntegerMap(propertyObject) + \
        ;     "\n\t isArray: "            + JValue.isArray(propertyObject) \
        ; )

        if (JValue.isMap(propertyObject))
            propertyObject = JMap.getObj(propertyObject, akExplodedPath[i])
            ; DebugWithArgs("Data::TraversePathToFinalObject", "akExplodedPath: " + akExplodedPath, "Processing a Map...")

            ; int arrayStartBracket   = StringUtil.Find(akExplodedPath[i+1], "[")
            ; int arrayEndBracket     = StringUtil.Find(akExplodedPath[i+1], "]", arrayStartBracket)
            ; if (arrayStartBracket != -1)
            ;     string arrayIndex          = StringUtil.Substring(akExplodedPath[i+1], arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1)
            ;     ; propertyObject = JMap.getObj(propertyObject, akExplodedPath[i])
            ;     string arrayName = StringUtil.Substring(akExplodedPath[i], 0, arrayStartBracket)

            ;     ; DebugWithArgs("Data::TraversePathToFinalObject", "akExplodedPath: " + akExplodedPath, \
            ;     ;     "\n\t akExplodedPath[i]: " + akExplodedPath[i] + \
            ;     ;     "\n\t arrayStartBracket: " + arrayStartBracket + \
            ;     ;     "\n\t arrayEndBracket: "   + arrayEndBracket + \
            ;     ;     "\n\t arrayIndex: "        + arrayIndex + \
            ;     ;     "\n\t arrayName: "         + arrayName \
            ;     ; )
            ; endif
            
        elseif (JValue.isFormMap(propertyObject))
            Form theForm = GetFormFromString(akExplodedPath[i])

            if (theForm == none)
                DebugError("Data::TraversePathToFinalObject", "Could not process the Form at ["+ i +"] in the path! (Got: " + akExplodedPath[i] + ")")
                Error("Could not process the Form at ["+ i +"] in the path! (Got: " + akExplodedPath[i] + ")")
            endif
            propertyObject = JFormMap.getObj(propertyObject, theForm)
            ; DebugWithArgs("Data::TraversePathToFinalObject", "akExplodedPath: " + akExplodedPath, "Processing a Form Map... Form: " + theForm + ", akExplodedPath[i]: " + akExplodedPath[i])

        elseif (JValue.isArray(propertyObject))
            int index = akExplodedPath[i] as int
            propertyObject = JArray.getObj(propertyObject, index)
            DebugWithArgs("Data::TraversePathToFinalObject", "akExplodedPath: " + akExplodedPath, "Processing an Array... akExplodedPath[i]: " + akExplodedPath[i])
        else
            ; int arrayStartBracket   = StringUtil.Find(akExplodedPath[i], "[")
            ; int arrayEndBracket     = StringUtil.Find(akExplodedPath[i], "]", arrayStartBracket)
            ; string arrayIndex          = StringUtil.Substring(akExplodedPath[i], arrayStartBracket, arrayEndBracket - arrayStartBracket)
            ; ; propertyObject = JMap.getObj(propertyObject, akExplodedPath[i])
            ; string arrayName = StringUtil.Substring(akExplodedPath[i], 0, arrayStartBracket)

            ; DebugWithArgs("Data::TraversePathToFinalObject", "akExplodedPath: " + akExplodedPath, \
            ;     "\n\t akExplodedPath[i]: " + akExplodedPath[i] + \
            ;     "\n\t arrayStartBracket: " + arrayStartBracket + \
            ;     "\n\t arrayEndBracket: "   + arrayEndBracket + \
            ;     "\n\t arrayIndex: "        + arrayIndex + \
            ;     "\n\t arrayName: "         + arrayName \
            ; )

            

            ; DebugError("Data::TraversePathToFinalObject", "Invalid object type at ["+ i +"]: "+ akExplodedPath[i] +", cannot proceed!")
            ; Error("Invalid object type at ["+ i +"]: "+ akExplodedPath[i] +", cannot proceed!")
        endif
        i += 1
    endWhile

    return propertyObject
endFunction

int function GetObjectFromContainer(int apRootObject, string asElementKey, int apDefaultObjectOnFail = -1) global
    int TYPE_OBJECT = 5
    int returnedObject

    if (JValue.isMap(apRootObject)) ; Element is Map
        if (JMap.valueType(apRootObject, asElementKey) != TYPE_OBJECT)
            return apDefaultObjectOnFail
        endif

        returnedObject = JMap.getObj(apRootObject, asElementKey)

    elseif (JValue.isFormMap(apRootObject)) ; Element is FormMap
        Form keyElement = GetFormFromString(asElementKey)
        if (JFormMap.valueType(apRootObject, keyElement) != TYPE_OBJECT)
            return apDefaultObjectOnFail
        endif

        returnedObject = JFormMap.getObj(apRootObject, keyElement)

    elseif (JValue.isIntegerMap(apRootObject)) ; Element is IntMap (NOT TESTED)
        int keyElement = asElementKey as int

        if (JIntMap.valueType(apRootObject, keyElement) != TYPE_OBJECT)
            return apDefaultObjectOnFail
        endif

        returnedObject = JIntMap.getObj(apRootObject, keyElement)

    elseif (JValue.isArray(apRootObject)) ; Element is Array (NOT TESTED)
        int arrayIndex = asElementKey as int

        if (JArray.valueType(apRootObject, arrayIndex) != TYPE_OBJECT)
            return apDefaultObjectOnFail
        endif

        returnedObject = JArray.getObj(apRootObject, arrayIndex)
    endif

    return returnedObject
endFunction

;/
    Retrieves the jail object of a hold from the data file obtained from the hold's root object.

    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (JMap&): The reference to the jail object of this Hold.
/;
int function Hold_GetJailObject(int apHoldRootObject) global
    return JMap.getObj(apHoldRootObject, "Jail") ; JMap&
endFunction

;/
    Retrieves whether a property exists given by the path starting at the root.

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (bool): true if the property exists, false otherwise.
/;
bool function HasProperty(int apRootObject, string asPropertyPath, string asPathDelimiter = "//", bool abCheckEmpty = false) global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    string elementPath      = "." + pathKey
    bool isObject           = JValue.solvedValueType(parentObject, elementPath) == 5

    if (isObject)
        int obj = JValue.solveObj(parentObject, elementPath)
        if (abCheckEmpty && JValue.empty(obj))
            return false
        endif
    endif

    return JValue.hasPath(parentObject, elementPath)
endFunction

;/
    Retrieves a property of type bool.

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    bool?               @abDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (bool): A property of type bool.
/;
bool function GetPropertyOfTypeBool(int apRootObject, string asPropertyPath, bool abDefaultInvalidValue = false, bool abCheckExists = true, string asPathDelimiter = "//") global
    return GetPropertyOfTypeInteger(apRootObject, asPropertyPath, abDefaultInvalidValue as int, abCheckExists, asPathDelimiter) as bool
endFunction

;/
    Retrieves a property of type int.

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    int?                @aiDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (int): A property of type int.
/;
int function GetPropertyOfTypeInteger(int apRootObject, string asPropertyPath, int aiDefaultInvalidValue = -1, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_INTEGER        = 2

    if (JValue.isMap(parentObject))
        if (JMap.valueType(parentObject, pathKey) != TYPE_INTEGER)
            return aiDefaultInvalidValue
        endif

        if (abCheckExists && !JMap.hasKey(parentObject, pathKey))
            return aiDefaultInvalidValue
        endif

        return JMap.getInt(parentObject, pathKey)

    elseif (JValue.isArray(parentObject))
        int arrayStartBracket   = StringUtil.Find(pathKey, "[")
        int arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        int arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        if (JArray.valueType(parentObject, arrayIndex) != TYPE_INTEGER)
            return aiDefaultInvalidValue
        endif

        return JArray.getInt(parentObject, arrayIndex)
    endif
endFunction

;/
    Retrieves a property of type float.

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    float?              @afDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (float): A property of type float.
/;
float function GetPropertyOfTypeFloat(int apRootObject, string asPropertyPath, float afDefaultInvalidValue = -1.0, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_FLOAT          = 3

    if (JValue.isMap(parentObject))
        if (JMap.valueType(parentObject, pathKey) != TYPE_FLOAT)
            return afDefaultInvalidValue
        endif

        if (abCheckExists && !JMap.hasKey(parentObject, pathKey))
            return afDefaultInvalidValue
        endif

        return JMap.getFlt(parentObject, pathKey)

    elseif (JValue.isArray(parentObject))
        int arrayStartBracket   = StringUtil.Find(pathKey, "[")
        int arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        int arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        if (JArray.valueType(parentObject, arrayIndex) != TYPE_FLOAT)
            return afDefaultInvalidValue
        endif

        return JArray.getFlt(parentObject, arrayIndex)
    endif
endFunction

;/
    Retrieves a property of type string.

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    string?             @asDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (string): A property of type string.
/;
string function GetPropertyOfTypeString(int apRootObject, string asPropertyPath, string asDefaultInvalidValue = "", bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_STRING         = 6

    ; Debug("Data::GetPropertyOfTypeString", "asPropertyPath: " + asPropertyPath)
    ; DebugWithArgs("Data::GetPropertyOfTypeString", asPropertyPath, \
    ;     "\n\t pathKey: "            + pathKey + \
    ;     "\n\t isMap: "              + JValue.isMap(parentObject) + \
    ;     "\n\t isFormMap: "          + JValue.isFormMap(parentObject) + \
    ;     "\n\t isIntMap: "           + JValue.isIntegerMap(parentObject) + \
    ;     "\n\t isArray: "            + JValue.isArray(parentObject) \
    ; )

    if (JValue.isMap(parentObject))
        if (JMap.valueType(parentObject, pathKey) != TYPE_STRING)
            return asDefaultInvalidValue
        endif

        return JMap.getStr(parentObject, pathKey)

    elseif (JValue.isArray(parentObject))
        int arrayStartBracket   = StringUtil.Find(pathKey, "[")
        int arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        int arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        if (JArray.valueType(parentObject, arrayIndex) != TYPE_STRING)
            return asDefaultInvalidValue
        endif

        return JArray.getStr(parentObject, arrayIndex)
    endif
endFunction

;/
    Retrieves a property of type Form.

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    Form?               @akDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (Form): A property of type Form.
/;
Form function GetPropertyOfTypeForm(int apRootObject, string asPropertyPath, Form akDefaultInvalidValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_FORM           = 4

    if (JValue.isMap(parentObject))
        if (JMap.valueType(parentObject, pathKey) != TYPE_FORM)
            return akDefaultInvalidValue
        endif

        if (abCheckExists && !JMap.hasKey(parentObject, pathKey))
            return akDefaultInvalidValue
        endif

        return JMap.getForm(parentObject, pathKey)

    elseif (JValue.isArray(parentObject))
        int arrayStartBracket   = StringUtil.Find(pathKey, "[")
        int arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        int arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        if (JArray.valueType(parentObject, arrayIndex) != TYPE_FORM)
            return akDefaultInvalidValue
        endif

        return JArray.getForm(parentObject, arrayIndex)
    endif
endFunction

;/
    Retrieves a property of type int[].

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    int[]?              @akDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (int[]): A property of type int[].
/;
int[] function GetPropertyOfTypeIntegerArray(int apRootObject, string asPropertyPath, int[] akDefaultInvalidValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_OBJECT         = 5

    int returnedObject

    if (JValue.isMap(parentObject))
        if (JMap.valueType(parentObject, pathKey) != TYPE_OBJECT)
            return akDefaultInvalidValue
        endif

        returnedObject = JMap.getObj(parentObject, pathKey)

    elseif (JValue.isArray(parentObject))
        int arrayStartBracket   = StringUtil.Find(pathKey, "[")
        int arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        int arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        if (JArray.valueType(parentObject, arrayIndex) != TYPE_OBJECT)
            return akDefaultInvalidValue
        endif

        returnedObject = JArray.getObj(parentObject, arrayIndex)
    endif

    if (abCheckExists && JValue.empty(returnedObject))
        return akDefaultInvalidValue
    endif

    int[] arr = JArray.asIntArray(returnedObject)

    if (!arr)
        return akDefaultInvalidValue
    endif

    return arr
endFunction

;/
    Retrieves a property of type float[].

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    float[]?            @akDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (float[]): A property of type float[].
/;
float[] function GetPropertyOfTypeFloatArray(int apRootObject, string asPropertyPath, float[] akDefaultInvalidValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_OBJECT         = 5

    int returnedObject

    if (JValue.isMap(parentObject))
        if (JMap.valueType(parentObject, pathKey) != TYPE_OBJECT)
            return akDefaultInvalidValue
        endif

        returnedObject = JMap.getObj(parentObject, pathKey)

    elseif (JValue.isArray(parentObject))
        int arrayStartBracket   = StringUtil.Find(pathKey, "[")
        int arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        int arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        if (JArray.valueType(parentObject, arrayIndex) != TYPE_OBJECT)
            return akDefaultInvalidValue
        endif

        returnedObject = JArray.getObj(parentObject, arrayIndex)
    endif

    if (abCheckExists && JValue.empty(returnedObject))
        return akDefaultInvalidValue
    endif

    float[] arr = JArray.asFloatArray(returnedObject)

    if (!arr)
        return akDefaultInvalidValue
    endif

    return arr
endFunction

;/
    Retrieves a property of type string[].

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    string[]?           @akDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (string[]): A property of type string[].
/;
string[] function GetPropertyOfTypeStringArray(int apRootObject, string asPropertyPath, string[] akDefaultInvalidValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_OBJECT         = 5

    ; DebugWithArgs("Data::GetPropertyOfTypeStringArray", asPropertyPath, \
    ;     "\n\t pathKey: "            + pathKey + \
    ;     "\n\t isMap: "              + JValue.isMap(parentObject) + \
    ;     "\n\t isFormMap: "          + JValue.isFormMap(parentObject) + \
    ;     "\n\t isIntMap: "           + JValue.isIntegerMap(parentObject) + \
    ;     "\n\t isArray: "            + JValue.isArray(parentObject) \
    ; )

    int returnedObject

    if (JValue.isMap(parentObject))
        if (JMap.valueType(parentObject, pathKey) != TYPE_OBJECT)
            return akDefaultInvalidValue
        endif

        returnedObject = JMap.getObj(parentObject, pathKey)

    elseif (JValue.isArray(parentObject))
        int arrayStartBracket   = StringUtil.Find(pathKey, "[")
        int arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        int arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        ; ; Check for multi-dimensional array
        ; if (arrayIndex)
        ;     int nestedArray = JArray.getObj(parentObject, arrayIndex)

        ;     if (JValue.isArray(nestedArray) && pathKey != "["+ arrayIndex +"]")
        ;         arrayStartBracket   = StringUtil.Find(pathKey, "[", arrayEndBracket)
        ;         arrayEndBracket     = StringUtil.Find(pathKey, "]", arrayStartBracket)
        ;         arrayIndex          = StringUtil.Substring(pathKey, arrayStartBracket + 1, (arrayEndBracket - arrayStartBracket) - 1) as int

        ;         parentObject = nestedArray

        ;         DebugWithArgs("Data::GetPropertyOfTypeStringArray", asPropertyPath, \
        ;             "\n\t nestedArray: "            + GetContainerList(nestedArray) + \
        ;             "\n\t arrayIndex: "              + arrayIndex + \
        ;             "\n\t arrayStartBracket: "          + arrayStartBracket + \
        ;             "\n\t arrayEndBracket: "           + arrayEndBracket \
        ;         )
        ;     endif
        ; endif

        if (JArray.valueType(parentObject, arrayIndex) != TYPE_OBJECT)
            return akDefaultInvalidValue
        endif

        returnedObject = JArray.getObj(parentObject, arrayIndex)
    endif

    ; Element is a Map, get the Keys as array
    if (JValue.isMap(returnedObject))
        returnedObject = JMap.allKeys(returnedObject)
    endif

    if (abCheckExists && JValue.empty(returnedObject))
        return akDefaultInvalidValue
    endif

    string[] arr = JArray.asStringArray(returnedObject)

    if (!arr)
        return akDefaultInvalidValue
    endif

    return arr
endFunction

;/
    Retrieves a property of type Form[].

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    Form[]?             @akDefaultInvalidValue: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (Form[]): A property of type Form[].
/;
Form[] function GetPropertyOfTypeFormArray(int apRootObject, string asPropertyPath, Form[] akDefaultInvalidValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_OBJECT         = 5

    ; string args = "apRootObject: " + apRootObject + ", asPropertyPath: " + asPropertyPath
    ; DebugWithArgs("Data::GetPropertyOfTypeFormArray", args, "\n\tsubCategories: " + subCategories + "\n\tpathKey: " + pathKey + "\n\tfinalObject: " + GetContainerList(parentObject))

    if (JValue.empty(parentObject))
        return akDefaultInvalidValue
    endif
    ; Debug("Data::GetPropertyOfTypeFormArray", "asPropertyPath: " + asPropertyPath)

    int returnedObject

    if (JValue.isMap(parentObject))
        returnedObject = JMap.getObj(parentObject, pathKey)
        ; Debug("Data::GetPropertyOfTypeFormArray", "This is a Map, pathKey: " + pathKey)

    ; elseif (JValue.isFormMap(parentObject))
    ;     returnedObject = JMap.getObj(parentObject, pathKey)
    ;     Debug("Data::GetPropertyOfTypeFormArray", "This is a Form Map, pathKey: " + pathKey)
    
    endif

    if (JValue.isFormMap(returnedObject))
        returnedObject = JFormMap.allKeys(returnedObject)
    endif

    ; Debug("Data::GetPropertyOfTypeFormArray", "Final Object: " + GetContainerList(parentObject))
    ; Debug("Data::GetPropertyOfTypeFormArray", "Object Returned: " + GetContainerList(returnedObject))

    ; if (JMap.valueType(parentObject, pathKey) != TYPE_OBJECT)
    ;     return akDefaultInvalidValue
    ; endif

    ; int returnedObject
    ; if (JValue.isMap(parentObject))
    ;     returnedObject = JMap.getObj(parentObject, pathKey)
    ;     Debug("Data::GetPropertyOfTypeFormArray", "This is a Map")
    ; elseif (JValue.isFormMap(parentObject))
    ;     ; returnedObject = JFormMap.getObj(parentObject, pathKey)
    ;     Debug("Data::GetPropertyOfTypeFormArray", "This is a Form Map")
    ; endif
    ; Debug("Data::GetPropertyOfTypeFormArray", "Object Returned: " + GetContainerList(returnedObject))

    if (abCheckExists && JValue.empty(returnedObject))
        return akDefaultInvalidValue
    endif

    Form[] arr = JArray.asFormArray(returnedObject)

    if (!arr)
        return akDefaultInvalidValue
    endif

    return arr
endFunction

;/
    Retrieves a property of type any& <JContainer>

    any& <JContainer>   @apRootObject: The reference to the root object.
    string              @asPropertyPath: The name or the path to the property.
    any& <JContainer>?  @apDefaultObject: The value to return if the retrieval fails.
    bool?               @abCheckExists: Whether to check if this property exists.
    string?             @asPathDelimiter: The delimiter when building the path to traverse.

    returns (any& <JContainer>): A property of type object.
/;
int function GetPropertyOfTypeObject(int apRootObject, string asPropertyPath, int apDefaultObject = -1, bool abCheckExists = true, string asPathDelimiter = "//") global
    string[] subCategories  = StringUtil.Split(asPropertyPath, asPathDelimiter)
    int parentObject        = TraversePathToFinalObject(apRootObject, subCategories)
    string pathKey          = subCategories[subCategories.Length - 1]
    int TYPE_OBJECT         = 5

    ; DebugWithArgs("Data::GetPropertyOfTypeObject", asPropertyPath, \
    ;     "\n\t pathKey: "            + pathKey + \
    ;     "\n\t subCategories: "      + subCategories + \
    ;     "\n\t isMap: "              + JValue.isMap(parentObject) + \
    ;     "\n\t isFormMap: "          + JValue.isFormMap(parentObject) + \
    ;     "\n\t isIntMap: "           + JValue.isIntegerMap(parentObject) + \
    ;     "\n\t isArray: "            + JValue.isArray(parentObject) \
    ; )

    int returnedObject = GetObjectFromContainer(parentObject, pathKey)

    if (abCheckExists && JValue.empty(returnedObject))
        return apDefaultObject
    endif

    ; if (JValue.isMap(parentObject)) ; Element is Map
    ;     if (JMap.valueType(parentObject, pathKey) != TYPE_OBJECT)
    ;         return apDefaultObject
    ;     endif

    ;     returnedObject = JMap.getObj(parentObject, pathKey)

    ; elseif (JValue.isFormMap(parentObject)) ; Element is FormMap
    ;     Form keyElement = GetFormFromString(pathKey)
    ;     if (JFormMap.valueType(parentObject, keyElement) != TYPE_OBJECT)
    ;         return apDefaultObject
    ;     endif

    ;     returnedObject = JFormMap.getObj(parentObject, keyElement)

    ; elseif (JValue.isIntegerMap(parentObject)) ; Element is IntMap (NOT TESTED)
    ;     int keyElement = pathKey as int

    ;     if (JIntMap.valueType(parentObject, keyElement) != TYPE_OBJECT)
    ;         return apDefaultObject
    ;     endif

    ;     returnedObject = JIntMap.getObj(parentObject, keyElement)

    ; elseif (JValue.isArray(parentObject)) ; Element is Array (NOT TESTED)
    ;     int arrayIndex = pathKey as int

    ;     if (JArray.valueType(parentObject, arrayIndex) != TYPE_OBJECT)
    ;         return apDefaultObject
    ;     endif

    ;     returnedObject = JArray.getObj(parentObject, arrayIndex)
    ; endif

    return returnedObject
endFunction

; TODO: Implement
bool function FindPropertyOfTypeBool(int apRootObject, string asPropertyPath, string apFindConditions = "[]", bool abDefaultValue = false, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

int function FindPropertyOfTypeInteger(int apRootObject, string asPropertyPath, string apFindConditions = "[]", int aiDefaultValue = -1, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

float function FindPropertyOfTypeFloat(int apRootObject, string asPropertyPath, string apFindConditions = "[]", float afDefaultValue = -1.0, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

string function FindPropertyOfTypeString(int apRootObject, string asPropertyPath, string apFindConditions = "[]", string asDefaultValue = "", bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

Form function FindPropertyOfTypeForm(int apRootObject, string asPropertyPath, string apFindConditions = "[]", Form akDefaultValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

int[] function FindPropertyOfTypeIntegerArray(int apRootObject, string asPropertyPath, string apFindConditions = "[]", int[] akDefaultValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

float[] function FindPropertyOfTypeFloatArray(int apRootObject, string asPropertyPath, string apFindConditions = "[]", float[] akDefaultValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

string[] function FindPropertyOfTypeStringArray(int apRootObject, string asPropertyPath, string apFindConditions = "[]", string[] akDefaultValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

Form[] function FindPropertyOfTypeFormArray(int apRootObject, string asPropertyPath, string apFindConditions = "[]", Form[] akDefaultValue = none, bool abCheckExists = true, string asPathDelimiter = "//") global
endFunction

;/
    Retrieves the locations of a specific hold through its root object

    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (Form[]): The locations of this Hold.
/;
Form[] function Hold_GetLocations(int apHoldRootObject) global
    int array_locations = JMap.getObj(apHoldRootObject, "Locations") ; JArray&
    return JArray.asFormArray(array_locations)
endFunction

;/
    Retrieves the hold's crime faction through its root object

    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (Faction): This Hold's Crime Faction.
/;
Faction function Hold_GetCrimeFaction(int apHoldRootObject) global
    Form factionForm = JMap.getForm(apHoldRootObject, "Crime Faction")
    return factionForm as Faction
endFunction

;/
    Retrieves the city from the hold's root object.
    
    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (string): The city of this Hold.
/;
string function Hold_GetCity(int apHoldRootObject) global
    string city = JMap.getStr(apHoldRootObject, "City")
    return city
endFunction

;/
    Retrieves the jail cells object of a Jail from the data file obtained from the jail's object.

    JMap& @apHoldJailObject: The reference to the jail object of this hold.

    returns (JFormMap&): The reference to the jail cells object of this Jail.
/;
int function Jail_GetCellsObject(int apHoldJailObject) global
    int formMap_jailCells = JMap.getObj(apHoldJailObject, "Cells") ; JFormMap&
    return formMap_jailCells
endFunction

;/
    Retrieves a jail cell by its ID from a Prison.

    JMap&   @apHoldJailObject: The reference to the prison object.
    string  @asCellID: The ID of the jail cell.

    returns (RPB_JailCell): An RPB_JailCell instance that has this ID.
/;
RPB_JailCell function Jail_GetJailCellByID(int apHoldJailObject, string asCellID) global
    int prisonCellsObj  = JMap.getObj(apHoldJailObject, "Cells") ; JFormMap&
    int cellsObjects    = JFormMap.allValues(prisonCellsObj) ; JArray<JMap>
    int numberOfCells   = JValue.count(prisonCellsObj)

    int i = 0
    while (i < numberOfCells)
        int cellObj     = JArray.getObj(cellsObjects, i) ; JMap&
        string cellId   = JMap.getStr(cellObj, "ID")

        if (cellId == asCellID)
            Form cellForm = JFormMap.getNthKey(prisonCellsObj, i)
            return cellForm as RPB_JailCell
        endif
        i += 1
    endWhile

    return none
endFunction


;/
    Retrieves the parent Forms of the jail cells. 
    Each element is able to be cast to a RPB_JailCell.

    JFormMap&   @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    bool        @abOnlyActiveCells: Whether to retrieve only Cells marked as active.

    returns (Form[]): All the jail cell parents.
/;
Form[] function JailCell_GetParents(int apPrisonCellsObject, bool abOnlyActiveCells = true) global
    int array_cellsKeys = JFormMap.allKeys(apPrisonCellsObject) ; JArray& (RPB_JailCell[])

    if (abOnlyActiveCells)
        int array_allCellObjects    = JFormMap.allValues(apPrisonCellsObject) ; JArray& (JMap[])
        int activeCells             = JArray.object()
    
        int i = 0
        while (i < JValue.count(array_allCellObjects))
            int currentJailCellObj = JArray.getObj(array_allCellObjects, i) ; JMap&
            bool isActiveCell      = JMap.getInt(currentJailCellObj, "Active") as bool
    
            if (isActiveCell)
                Form currentJailCellForm = JArray.getForm(array_cellsKeys, i)
                JArray.addForm(activeCells, currentJailCellForm)
            endif
            i += 1
        endWhile
    
        if (JValue.count(activeCells) <= 0)
            return none
        endif
    
        Form[] asFormArray  = JArray.asFormArray(activeCells)
        return asFormArray
    endif

    return JArray.asFormArray(array_cellsKeys)
endFunction

;/
    Checks if a given jail cell has an option, determined by @asOptionCategory, optionally checking if the contents are empty or not.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell to check the existence of options.
    string          @asOption: The name of the option to check.
    string?         @asOptionCategory: The category of options to check.
    bool?           @abCheckEmptyContent: Whether to check for the options' empty content.

    returns (bool): Whether the jail cell has options of the specified type.
/;
bool function JailCell_HasOption(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null", bool abCheckEmptyContent = false) global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_finalOptionObject   = map_options ; Default to main Options category

    if (asOptionCategory != "null")
        bool optionCategoryExists = JMap.hasKey(map_options, asOptionCategory)
        if (!optionCategoryExists)
            Error("Option category " + asOptionCategory + " does not exist for jail cell " + akJailCell + "!")
            DebugError("Data::HasJailCellOption", "Option category " + asOptionCategory + " does not exist for jail cell " + akJailCell + "!")
            return false
        endif

        ; We got a sub option object (such as Scan), change the final object to retrieve the option from
        map_finalOptionObject = JMap.getObj(map_options, asOptionCategory)

        if (abCheckEmptyContent)
            int subObjectsCategoryContainer = JMap.getObj(map_finalOptionObject, asOptionCategory)
            bool isEmpty = JValue.empty(subObjectsCategoryContainer)
    
            return map_finalOptionObject && !isEmpty
        endif
    endif

    ; Debug(none, "Data::HasJailCellOption", akJailCell + " Meets Criteria: " + (map_options && JMap.hasKey(map_finalOptionObject, asOption)) + " - map_options: " + map_options + ", JMap.hasKey(map_finalOptionObject, asOption):" + JMap.hasKey(map_finalOptionObject, asOption) + ", map_finalOptionObject: " + GetContainerList(map_finalOptionObject))

    return map_options && JMap.hasKey(map_finalOptionObject, asOption)
endFunction

;/
    Checks if a given jail cell has any type of object, determined by @asObjectCategory, optionally checking if the contents are empty or not.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell to check the existence of objects.
    string          @asObjectCategory: The type of objects to check.
    bool?           @abCheckEmptyContent: Whether to check for the objects' empty content.

    returns (bool): Whether the jail cell has objects of the specified type.
/;
bool function JailCell_HasObjects(int apPrisonCellsObject, RPB_JailCell akJailCell, string asObjectCategory, bool abCheckEmptyContent = false) global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_objects             = JMap.getObj(map_cellDataContent, "Objects")           ; JMap& - The Objects for this cell

    bool hasSubObjectsCategory  = JMap.hasKey(map_objects, asObjectCategory)

    if (abCheckEmptyContent)
        int subObjectsCategoryContainer = JMap.getObj(map_objects, asObjectCategory) ; JArray&
        bool isEmpty = JValue.empty(subObjectsCategoryContainer)

        ; Debug(none, "Data::JailCell_HasObjects", "Objects("+ subObjectsCategoryContainer +"): " + GetContainerList(subObjectsCategoryContainer))
        ; Debug(none, "Data::JailCell_HasObjects", "Empty:" + isEmpty + ", Returns: " + (map_objects && !isEmpty))

        return map_objects && !isEmpty
    endif

    return map_objects && hasSubObjectsCategory 
endFunction


; ==========================================================
;                         Data Setters
; ==========================================================

; bool function RemoveJailGuard(int apHoldJailObject, Form akGuard) global
;     int guardsArray = JMap.getObj(apHoldJailObject, "Guards") ; JArray&
;     bool hasElement = JArray.findForm(guardsArray, akGuard) != -1

;     if (!hasElement)
;         ; No element found, don't remove anything
;         return false
;     endif

;     JArray.eraseForm(guardsArray, akGuard)

;     return true
; endFunction

; bool function AddJailGuard(int apHoldJailObject, Form akGuard) global
;     int guardsArray = JMap.getObj(apHoldJailObject, "Guards") ; JArray&
;     bool hasElement = JArray.findForm(guardsArray, akGuard) != -1

;     if (hasElement)
;         ; Guard already exists, don't add anything
;         return false
;     endif

;     JArray.addForm(guardsArray, akGuard)

;     return true
; endFunction

; bool function ReplaceJailGuard(int apHoldJailObject, Form akOldGuard, Form akNewGuard) global
;     if (RemoveJailGuard(apHoldJailObject, akOldGuard))
;         return AddJailGuard(apHoldJailObject, akNewGuard)
;     endif

;     return false
; endFunction

; bool function AddHoldLocation(Form akLocation, int apHoldRootObject) global
;     int locationsArray = JMap.getObj(apHoldRootObject, "Locations")
;     JArray.addForm(locationsArray, akLocation)

;     return JArray.findForm(locationsArray, akLocation)
; endFunction

; bool function AddJailCellMarker(Form akMarker, int apHoldJailObject, string asInteriorOrExterior, bool abSaveData = true) global
;     if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
;         return none
;     endif

;     int cellsMap    = JMap.getObj(apHoldJailObject, "Cells") ; Map with both Exterior and Interior markers
;     int cellTypeMap = JMap.getObj(cellsMap, asInteriorOrExterior) ; The map holding all of the jail cell arrays, key is the parent FormID and the value is an array containing all of the markers belonging to said parent

;     akMarker = Game.GetForm(0x3C9FE) ; temporary, to test

;     int markerId        = akMarker.GetFormID() ; The jail cell identifier
;     int markersArray    = JMap.getObj(cellTypeMap, markerId) ; The array holding all of the jail cells belonging to parent (format is CellID: []) where [] = markersArray

;     ; Create array if it doesn't exist yet
;     if (!markersArray)
;         markersArray = JArray.object()
;     endif

;     bool itemExists = JArray.findForm(markersArray, akMarker) != -1

;     if (!itemExists)
;         ; Add the actual form to the array that contains all forms belonging to this parent
;         JArray.addForm(markersArray, akMarker)
;     endif

;     JMap.setObj(cellTypeMap, markerId, markersArray) ; Add the marker to the jail cell's marker array

;     string debugInfo = GetContainerList(cellsMap)
;     Debug(none, "Config::AddJailCellMarker", debugInfo)

;     ; self.AddJailCellToParent(markersArray, Game.GetForm(0x14))
;     int parentArray = RawObject_GetJailCellParent(apHoldJailObject, akMarker as RPB_JailCell) ; To be tested after the refactor to JFormMap
;     AddJailCellToParent(parentArray, Game.GetForm(0x14))

;     if (abSaveData)
;         RPB_Data.SaveRoot()
;     endif

;     return JArray.findForm(markersArray, akMarker) != -1
; endFunction

; bool function AddJailCellToParent(int apJailCellParentItem, Form akJailCellMarker) global ; Might not be working after the refactor
;     ; apJailCellParentItem = The identifier of the jail cell, for example, for Interior markers: Haafingar.Interior.0x3880 (Array)

;     bool itemExists = JArray.findForm(apJailCellParentItem, akJailCellMarker) != -1

;     if (!itemExists && JValue.isArray(apJailCellParentItem))
;         JArray.addForm(apJailCellParentItem, akJailCellMarker)
;     endif
; endFunction

; bool function AddJailPrisonerContainer(Form akPrisonerContainer, int apHoldJailObject)
;     int prisonerContainersArray = JMap.getObj(apHoldJailObject, "Prisoner Containers")
;     JArray.addForm(prisonerContainersArray, akPrisonerContainer)

;     return JArray.findForm(prisonerContainersArray, akPrisonerContainer)
; endFunction

; bool function Hold_SetCity(int apHoldRootObject, string asCity)
;     JMap.setStr(apHoldRootObject, "City", asCity)
; endFunction

; bool function Hold_SetCrimeFaction(int apHoldRootObject, Faction akCrimeFaction)
;     JMap.setForm(apHoldRootObject, "Crime Faction", akCrimeFaction)
; endFunction


; ==========================================================
;                           private
; ==========================================================

;   JArray& (RPB_JailCell[]) @apCellKeysArray: The array containing every parent jail cell key 
Form[] function private_JailCell_GetActiveParents(int apPrisonCellsObject, int apCellKeysArray) global
    int array_allCellObjects = JFormMap.allValues(apPrisonCellsObject) ; JArray& (JMap[])

    int activeCells = JArray.object()
    ; Debug(none, "Data::JailCell_GetActiveParents","Values: " + GetContainerList(array_allCellObjects))

    int i = 0
    while (i < JValue.count(array_allCellObjects))
        int currentJailCellObj = JArray.getObj(array_allCellObjects, i) ; JMap&
        bool isActiveCell      = JMap.getInt(currentJailCellObj, "Active") as bool

        if (isActiveCell)
            Form currentJailCellForm = JArray.getForm(apCellKeysArray, i)
            JArray.addForm(activeCells, currentJailCellForm)
        endif
        i += 1
    endWhile

    if (JValue.count(activeCells) <= 0)
        return none
    endif

    Form[] asFormArray  = JArray.asFormArray(activeCells)
    return asFormArray
endFunction


; ==========================================================
;                           Unused
; ==========================================================

;/
    Retrieves the Hold's jail parent markers for the cells, whether Interior or Exterior depending on the param through the jail item.

    int     @apHoldJailObject: The reference to the jail item of the Hold.
    string  @asInteriorOrExterior: Whether to retrieve Interior or Exterior markers.
/;
Form[] function GetJailCellParentMarkers(int apHoldJailObject, string asInteriorOrExterior = "Interior") global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    int cellsMap    = JMap.getObj(apHoldJailObject, "Cells")
    int cellArrays  = JMap.getObj(cellsMap, asInteriorOrExterior) ; Since asInteriorOrExterior will now either be Interior or Exterior

    ; int testFormMap = JFormMap.object()
    ; int testArray = JArray.object()
    ; int testArray2 = JArray.object()
    ; int secondArray = JArray.object()
    ; int interiorMap = JMap.object()

    ; JArray.addForm(testArray, Game.GetFormEx(0x36897))
    ; JArray.addForm(testArray, GetFormFromMod(0x3879))

    ; JArray.addForm(testArray2, GetFormFromMod(0x3879))
    ; JArray.addForm(testArray2, GetFormFromMod(0x3880))

    ; JFormMap.setObj(testFormMap, Game.GetFormEx(0x36897), testArray)
    ; JFormMap.setObj(testFormMap, GetFormFromMod(0x3879), testArray2)

    ; JMap.setObj(interiorMap, "Interior", testFormMap)

    ; JValue.writeToFile(interiorMap, "Data/RPB_Data/test_structure2.json")

    ; Debug(none, "Config::GetJailCellParentMarkers", "Test Form Map: " + GetContainerList(testFormMap))

    ; SaveRoot()

    ; int parentCells = JArray.object()

    ; Debug(none, "Config::GetJailCellParentMarkers", "Cell Arrays: " + GetContainerList(cellArrays))

    ; int i = 0
    ; while (i < JValue.count(cellArrays))
    ;     string cellArrayMapKey  = JMap.getNthKey(cellArrays, i)
    ;     int currentCellArray    = JMap.getObj(cellArrays, cellArrayMapKey) ; Array
    ;     Form parentCell         = JArray.getForm(currentCellArray, 0) ; Always get the 1st element, we only want the parents of each one
    ;     bool isCellValid        = (parentCell as RPB_JailCell) != none ; parent must have RPB_JailCell script attached

    ;     if (isCellValid)
    ;         JArray.addForm(parentCells, parentCell)
    ;     endif
        
    ;     i += 1
    ; endWhile


    ; int i = 0
    ; while (i < JValue.count(cellArrays))
    ;     Form parentCell  = JFormMap.getNthKey(cellArrays, i)
    ;     bool isCellValid = (parentCell as RPB_JailCell) != none ; parent must have RPB_JailCell script attached

    ;     if (isCellValid)
    ;         JArray.addForm(parentCells, parentCell)
    ;     endif
        
    ;     i += 1
    ; endWhile

    Form[] parentCells = JFormMap.allKeysPArray(cellArrays)

    ; Debug(none, "Config::GetJailCellParentMarkers", "Parent Cells: " + parentCells)

    return parentCells
endFunction

;/
    Retrieves the Hold's jail child markers for the cells, whether Interior or Exterior depending on the param through the jail item.

    int     @apHoldJailObject: The reference to the jail item of the Hold.
    string  @asInteriorOrExterior: Whether to retrieve Interior or Exterior markers.
/;
Form[] function GetJailCellChildMarkers(int apHoldJailObject, Form akParentForm, string asInteriorOrExterior = "Interior") global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    int cellsMap = JMap.getObj(apHoldJailObject, "Cells")
    int cellArrays  = JMap.getObj(cellsMap, asInteriorOrExterior)
    int selectedCellArray = JFormMap.getObj(cellArrays, akParentForm)

    int children = selectedCellArray

    ; Debug(none, "Config::GetJailCellChildMarkers", akParentForm + "'s " + asInteriorOrExterior +" Children: " + GetContainerList(children))

    Form[] childrenAsForms = JArray.asFormArray(children)

    return childrenAsForms


    ; ; Debug(none, "Config::GetJailCellChildMarkers", "cellArrays " + GetContainerList(cellArrays))
    ; Debug(none, "Config::GetJailCellChildMarkers", "selectedCellArray " + GetContainerList(selectedCellArray))

    ; int childCells = JArray.object()

    ; int i = 0 
    ; while (i < JValue.count(selectedCellArray))
    ;     Form currentChildCell = JArray.getForm(selectedCellArray, i)

    ;     if ((currentChildCell.GetFormID() != aiParentFormID) && (currentChildCell != none))
    ;         JArray.addForm(childCells, currentChildCell)
    ;     endif

    ;     ; if (currentChildCell != none)
    ;     ;     JArray.addForm(childCells, currentChildCell)
    ;     ; endif

    ;     i += 1
    ; endWhile

    ; Debug(none, "Config::GetJailCellChildMarkers", "Cell Arrays: " + GetContainerList(childCells))

    ; return JArray.asFormArray(childCells)
endFunction

; bool function AddJailCellMarker(Form akMarker, int apHoldJailObject, string asInteriorOrExterior)
;     if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
;         return none
;     endif

;     int rootItem = self.GetRootItem()

;     string hold = JMap.getNthKey(apHoldJailObject, 0)

;     int cellsMap    = JMap.getObj(apHoldJailObject, "Cells")
;     int cellTypeMap = JMap.getObj(cellsMap, asInteriorOrExterior)

;     akMarker = Game.GetForm(0x3C9FE)

;     int markerId        = akMarker.GetFormID() ; The jail cell identifier
;     int markersArray    = JMap.getObj(cellTypeMap, markerId) ; The map holding all of the jail cells (format is CellID: []) since arrays are stored here for each key

;     int newMarkersArray = JArray.object()
;     JArray.addForm(newMarkersArray, akMarker)

;     JArray.addForm(cellTypeMap, akMarker)
;     JMap.setObj(cellTypeMap, markerId, newMarkersArray) ; Add the marker to the jail cell's marker array

;     string debugInfo = GetContainerList(cellsMap)
;     Debug(none, "Config::AddJailCellMarker", debugInfo)
;     Debug(none, "Config::AddJailCellMarker", "Hold: " + hold)

;     JDB.solveObjSetter(".rpb_root.Haafingar.Jail.Cells.Interior", cellTypeMap)

;     self.Serialize(rjson")

;     ; return true
;     return JArray.findForm(markersArray, akMarker) != -1
; endFunction

function testSerializeAll() global
    ; miscVars.SetForm("Jail::Release::Teleport[Haafingar]", Game.GetFormEx(0x3EF19))
    ; miscVars.AddFormToArray("Locations[Eastmarch]", Game.GetForm(0x00018A57))
    ; miscVars.AddFormToArray("Locations[Eastmarch]", Game.GetForm(0x0001676A))

    ; int cellsMapFile = RPB_Data.Unserialize("RPB_Cells.json")
    int cellsMapFile = RPB_Data.Unserialize()
    int eastmarchArray = JMap.getObj(cellsMapFile, "Eastmarch") ; JArray (Form[])

    int locationsMap = JMap.object()
    int locationsArray = JArray.object()

    int crimeFactionMap = JMap.object()

    int jailMap = JMap.object()
    int jailArray = JArray.object()

    int cellsMap = JMap.object()
    int cellsArray = JArray.object()

    int releaseMarkersMap = JMap.object()
    int releaseMarkersArray = JArray.object()

    int prisonerContainerMap = JMap.object()
    int prisonerContainerArray = JArray.object()

    ; Jail
    cellsArray = JValue.deepCopy(eastmarchArray)
    JMap.setObj(cellsMap, "Cells", cellsArray)

    JArray.addForm(releaseMarkersArray, Game.GetFormEx(0x3EF19))
    JMap.setObj(releaseMarkersMap, "Release", releaseMarkersArray)

    JArray.addForm(prisonerContainerArray, Game.GetFormEx(0x3EF19))
    JMap.setObj(prisonerContainerMap, "PrisonerContainers", prisonerContainerArray)

    JArray.addObj(jailArray, cellsMap)
    JArray.addObj(jailArray, releaseMarkersMap)
    JArray.addObj(jailArray, prisonerContainerMap)
    ; End Jail

    JArray.addForm(locationsArray, Game.GetForm(0x00018A57))
    JArray.addForm(locationsArray, Game.GetForm(0x0001676A))

    JMap.setObj(locationsMap, "Locations", locationsArray)
    JMap.setForm(crimeFactionMap, "CrimeFaction", Game.GetForm(0x000267E3))


    JMap.setObj(jailMap, "Jail", jailArray)
    
    JArray.addObj(eastmarchArray, locationsMap)
    JArray.addObj(eastmarchArray, crimeFactionMap)
    JArray.addObj(eastmarchArray, jailMap)
    ; int cityMap = JMap.object()
    ; JMap.setStr(cityMap, "City", "Windhelm")
    ; JArray.addObj(eastmarchArray, cityMap)
    ; RPB_Data.Serialize"RPB_Data.json")
    RPB_Data.Serialize(cellsMapFile)
endFunction

Form[] function GetJailMarkers(string asHold) global
    ; Later the arrays must be dynamic and create one for each hold that exists (easy)
    ; int whiterunCells   = JArray.object()
    ; int windhelmCells   = JArray.object()
    ; int falkreathCells  = JArray.object()
    ; int solitudeCells   = JArray.object()
    ; int morthalCells    = JArray.object()
    ; int riftenCells     = JArray.object()
    ; int dawnstarCells   = JArray.object()

    ; int cellsMap        = JMap.object()

    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3885)) ; Jail Cell 01
    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3886)) ; Jail Cell 02
    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3887)) ; Jail Cell 03
    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3888)) ; Jail Cell 04 (Alik'r Cell)

    ; ; missing Winterhold markers

    ; JArray.addForm(windhelmCells, Game.GetForm(0x58CF8)) ; Jail Cell 01
    ; JArray.addForm(windhelmCells, GetFormFromMod(0x388A)) ; Jail Cell 02
    ; JArray.addForm(windhelmCells, GetFormFromMod(0x388B)) ; Jail Cell 03
    ; JArray.addForm(windhelmCells, GetFormFromMod(0x388C)) ; Jail Cell 04

    ; JArray.addForm(falkreathCells, Game.GetForm(0x3EF07)) ; Jail Cell 01

    ; JArray.addForm(solitudeCells, Game.GetForm(0x36897)) ; Jail Cell 01 (Original)
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3880)) ; Jail Cell 02
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3879)) ; Jail Cell 03
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3881)) ; Jail Cell 04
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3882)) ; Jail Cell 05
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3883)) ; Jail Cell 06
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3884)) ; Jail Cell 07 (Bjartur Cell)

    ; JArray.addForm(morthalCells, Game.GetForm(0x3EF08)) ; Jail Cell 01

    ; ; missing The Reach markers (Markarth)

    ; JArray.addForm(riftenCells, Game.GetForm(0x6128D)) ; Jail Cell 01 (Original)
    ; JArray.addForm(riftenCells, GetFormFromMod(0x388D)) ; Jail Cell 02 (Threki the Innocent)
    ; JArray.addForm(riftenCells, GetFormFromMod(0x388E)) ; Jail Cell 03
    ; JArray.addForm(riftenCells, GetFormFromMod(0x388F)) ; Jail Cell 04 (Sibbi's Cell [RESERVED])
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3890)) ; Jail Cell 05
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3893)) ; Jail Cell 06
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3894)) ; Jail Cell 07
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3895)) ; Jail Cell 08

    ; JArray.addForm(dawnstarCells, GetFormFromMod(0x3896)) ; Jail Cell 01

    ; JMap.setObj(cellsMap, "Whiterun", whiterunCells)
    ; JMap.setObj(cellsMap, "Eastmarch", windhelmCells)
    ; JMap.setObj(cellsMap, "Falkreath", falkreathCells)
    ; JMap.setObj(cellsMap, "Haafingar", solitudeCells)
    ; JMap.setObj(cellsMap, "Hjaalmarch", morthalCells)
    ; JMap.setObj(cellsMap, "The Rift", riftenCells)
    ; JMap.setObj(cellsMap, "The Pale", dawnstarCells)

    ; int cellsMapFile = JValue.readFromFile("testcell.json")
    ; int cellsMapFile = RPB_Data.Unserialize("RPB_Cells.json")
    int cellsMapFile = RPB_Data.Unserialize()

    int holdArray = JMap.getObj(cellsMapFile, asHold)
    ; int holdArray = JMap.getObj(cellsMap, asHold)

    
    ; JValue.writeToFile(cellsMapFile, self.ModDataDirectory + "RPB_Cells.json")
    ; RPB_Data.Serialize"RPB_Cells.json")
    RPB_Data.Serialize(cellsMapFile)

    testSerializeAll()

    return JArray.asFormArray(holdArray)

endFunction