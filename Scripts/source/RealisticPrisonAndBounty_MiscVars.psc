scriptname RealisticPrisonAndBounty_MiscVars extends Quest

import Math
import RealisticPrisonAndBounty_Util

; ====================================================================
; Functions & Events
; ====================================================================

; ====================================================================
; String Map Functions
; ====================================================================

; ========= Setters =========

function SetBool(string paramKey, bool value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setInt(_container, paramKey, value as int)
endFunction

function SetInt(string paramKey, int value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setInt(_container, paramKey, value)
endFunction

function SetFloat(string paramKey, float value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setFlt(_container, paramKey, value)
endFunction

function SetString(string paramKey, string value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setStr(_container, paramKey, value)
endFunction

function SetForm(string paramKey, Form value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setForm(_container, paramKey, value)
endFunction

function SetReference(string paramKey, ObjectReference value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setForm(_container, paramKey, value)
endFunction

function SetActor(string paramKey, Actor value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setForm(_container, paramKey, value)
endFunction

function SetObject(string paramKey, int value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.setObj(_container, paramKey, value)
endFunction

function ModInt(string paramKey, int value, string parentContainer = "root")
    int currentValue = self.GetInt(paramKey, parentContainer)
    self.SetInt(paramKey, currentValue + value)
endFunction

function ModFloat(string paramKey, float value, string parentContainer = "root")
    float currentValue = self.GetFloat(paramKey, parentContainer)
    self.SetFloat(paramKey, currentValue + value)
endFunction

; ========= Getters =========

bool function GetBool(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JMap.getInt(_container, __getUsedKey(paramKey, allowOverrides)) as bool
endFunction

int function GetInt(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    int thisValue = JMap.getInt(_container, __getUsedKey(paramKey, allowOverrides))

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)
    
    if (hasMin || hasMax)
        int minValue = self.GetIntMin(paramKey)
        int maxValue = self.GetIntMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

int function GetIntIntegerMap(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    int thisValue = JIntMap.getInt(_container, paramKey)

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)
    
    if (hasMin || hasMax)
        int minValue = self.GetIntMin(paramKey)
        int maxValue = self.GetIntMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

float function GetFloat(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    float thisValue = JMap.getFlt(_container, __getUsedKey(paramKey, allowOverrides))

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)

    if (hasMin || hasMax)
        float minValue = self.GetFloatMin(paramKey)
        float maxValue = self.GetFloatMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

string function GetString(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JMap.getStr(_container, __getUsedKey(paramKey, allowOverrides))
endFunction

Form function GetForm(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JMap.getForm(_container, __getUsedKey(paramKey, allowOverrides))
endFunction

ObjectReference function GetReference(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    return GetForm(paramKey, parentContainer, allowOverrides) as ObjectReference
endFunction

Actor function GetActor(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    return GetForm(paramKey, parentContainer, allowOverrides) as Actor
endFunction

int function GetObject(string paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JMap.getObj(_container, __getUsedKey(paramKey, allowOverrides))
endFunction

; function SetIntInContainer(string paramKey, int value)
;     Debug.StartStackProfiling()
;     int indexOfDelimiter = StringUtil.Find(paramKey, "/")
;     string containerKey = StringUtil.Substring(paramKey, 0, indexOfDelimiter)
;     string optionKey = StringUtil.Substring(paramKey, indexOfDelimiter + 1)
;     int parentContainer = JMap.getObj(_miscVarsContainer, containerKey)
;     JMap.setInt(parentContainer, optionKey, value)
;     ; Debug(self, "MiscVars::SetIntInContainer", "containerKey: " + containerKey + ", optionKey: " + optionKey)
;     Debug.StopStackProfiling()
; endFunction

; function SetIntInContainer(string parentContainerKey, string paramKey, int value)
;     Debug.StartStackProfiling()
;     int parentContainer = JMap.getObj(_miscVarsContainer, parentContainerKey)
;     JMap.setInt(parentContainer, paramKey, value)
;     Debug.StopStackProfiling()
; endFunction

; function SetStringInContainer(string paramKey, string value, string containerKey)
;     string parentContainerKey = StringUtil.Substring(containerKey, 0, StringUtil.Find(containerKey, "::"))
;     int _container = JMap.getObj(_miscVarsContainer, parentContainerKey)
    
;     int childContainerKeyIndex = StringUtil.Find(containerKey, "::")
;     if (childContainerKeyIndex != -1)
;         string childContainerKey = StringUtil.Substring(containerKey, childContainerKeyIndex + 2)
        
;         Info(self, "", "["+ ModName() +"] containerKey: " + containerKey)
;         Info(self, "", "["+ ModName() +"] parentContainerKey: " + parentContainerKey)
;         Info(self, "", "["+ ModName() +"] childContainerKey: " + childContainerKey)

;         ; Get the child container from the parent container
;         int childContainer = JMap.getObj(_container, childContainerKey)
;         Info(self, "", "["+ ModName() +"] childContainer: " + childContainer)
;         Info(self, "", "["+ ModName() +"] parentContainer: " + _container)

;         JMap.setStr(childContainer, paramKey, value)
;         return
;     endif
    
;     JMap.setStr(_container, paramKey, value)
; endFunction



; ====================================================================
; Integer Map Functions
; ====================================================================

; ========= Setters =========

function IntMap_SetBool(int paramKey, bool value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setInt(_container, paramKey, value as int)
endFunction

function IntMap_SetFloat(int paramKey, float value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setFlt(_container, paramKey, value)
endFunction

function IntMap_SetInt(int paramKey, int value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setInt(_container, paramKey, value)
endFunction

function IntMap_SetString(int paramKey, string value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setStr(_container, paramKey, value)
endFunction

function IntMap_SetForm(int paramKey, Form value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setForm(_container, paramKey, value)
endFunction

function IntMap_SetReference(int paramKey, ObjectReference value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setForm(_container, paramKey, value)
endFunction

function IntMap_SetActor(int paramKey, Actor value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setForm(_container, paramKey, value)
endFunction

function IntMap_SetObject(int paramKey, int value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JIntMap.setObj(_container, paramKey, value)
endFunction

function IntMap_ModInt(int paramKey, int value, string parentContainer = "root")
    int currentValue = self.IntMap_GetInt(paramKey, parentContainer)
    self.IntMap_SetInt(paramKey, currentValue + value)
endFunction

function IntMap_ModFloat(int paramKey, float value, string parentContainer = "root")
    float currentValue = self.IntMap_GetFloat(paramKey, parentContainer)
    self.IntMap_SetFloat(paramKey, currentValue + value)
endFunction

; ========= Getters =========

bool function IntMap_GetBool(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JIntMap.getInt(_container, paramKey) as bool
endFunction

int function IntMap_GetInt(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    int thisValue = JIntMap.getInt(_container, paramKey)

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)
    
    if (hasMin || hasMax)
        int minValue = self.GetIntMin(paramKey)
        int maxValue = self.GetIntMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

float function IntMap_GetFloat(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    float thisValue = JIntMap.getFlt(_container, paramKey)

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)

    if (hasMin || hasMax)
        float minValue = self.GetFloatMin(paramKey)
        float maxValue = self.GetFloatMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

string function IntMap_GetString(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JIntMap.getStr(_container, paramKey)
endFunction

Form function IntMap_GetForm(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JIntMap.getForm(_container, paramKey)
endFunction

ObjectReference function IntMap_GetReference(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    return GetForm(paramKey, parentContainer, allowOverrides) as ObjectReference
endFunction

Actor function IntMap_GetActor(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    return GetForm(paramKey, parentContainer, allowOverrides) as Actor
endFunction

int function IntMap_GetObject(int paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JIntMap.getObj(_container, paramKey)
endFunction

function IntMap_Remove(int paramKey, bool removeOverrides = true)

endFunction

; ====================================================================
; Form Map Functions
; ====================================================================

; ========= Setters =========

function FormMap_SetBool(Form paramKey, bool value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setInt(_container, paramKey, value as int)
endFunction

function FormMap_SetFloat(Form paramKey, float value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setFlt(_container, paramKey, value)
endFunction

function FormMap_SetInt(Form paramKey, int value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setInt(_container, paramKey, value)
endFunction

function FormMap_SetString(Form paramKey, string value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setStr(_container, paramKey, value)
endFunction

function FormMap_SetForm(Form paramKey, Form value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setForm(_container, paramKey, value)
endFunction

function FormMap_SetReference(Form paramKey, ObjectReference value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setForm(_container, paramKey, value)
endFunction

function FormMap_SetActor(Form paramKey, Actor value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setForm(_container, paramKey, value)
endFunction

function FormMap_SetObject(Form paramKey, int value, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JFormMap.setObj(_container, paramKey, value)
endFunction

function FormMap_ModInt(Form paramKey, int value, string parentContainer = "root")
    int currentValue = self.FormMap_GetInt(paramKey, parentContainer)
    self.FormMap_SetInt(paramKey, currentValue + value)
endFunction

function FormMap_ModFloat(Form paramKey, float value, string parentContainer = "root")
    float currentValue = self.FormMap_GetFloat(paramKey, parentContainer)
    self.FormMap_SetFloat(paramKey, currentValue + value)
endFunction

; ========= Getters =========

bool function FormMap_GetBool(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JFormMap.getInt(_container, paramKey) as bool
endFunction

int function FormMap_GetInt(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    int thisValue = JFormMap.getInt(_container, paramKey)

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)
    
    if (hasMin || hasMax)
        int minValue = self.GetIntMin(paramKey)
        int maxValue = self.GetIntMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

float function FormMap_GetFloat(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    float thisValue = JFormMap.getFlt(_container, paramKey)

    bool hasMin = self.HasMinimumValue(paramKey)
    bool hasMax = self.HasMaximumValue(paramKey)

    if (hasMin || hasMax)
        float minValue = self.GetFloatMin(paramKey)
        float maxValue = self.GetFloatMax(paramKey)

        if (hasMax && thisValue > maxValue)
            return maxValue

        elseif (hasMin && thisValue < minValue)
            return minValue
        endif
    endif

    return thisValue
endFunction

string function FormMap_GetString(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JFormMap.getStr(_container, paramKey)
endFunction

Form function FormMap_GetForm(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JFormMap.getForm(_container, paramKey)
endFunction

ObjectReference function FormMap_GetReference(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    return GetForm(paramKey, parentContainer, allowOverrides) as ObjectReference
endFunction

Actor function FormMap_GetActor(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    return GetForm(paramKey, parentContainer, allowOverrides) as Actor
endFunction

int function FormMap_GetObject(Form paramKey, string parentContainer = "root", bool allowOverrides = true)
    int _container = self.GetHandle(parentContainer)
    return JFormMap.getObj(_container, paramKey)
endFunction

function FormMap_Remove(Form paramKey, bool removeOverrides = true)

endFunction



function Remove(string paramKey, bool removeOverrides = true)
    JMap.removeKey(_miscVarsContainer, paramKey)
    JValue.release(JMap.getObj(_miscVarsContainer, paramKey))
    
    if (self.HasOverride(paramKey) && removeOverrides)
        JMap.removeKey(_miscVarsContainer, GetOverrideKey(paramKey))
    endif
endFunction

function Clear(string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JMap.clear(_container)
endFunction

function Retain(string containerName, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    JValue.retain(JMap.getObj(_container, containerName), "RPB_MiscVarsContainer")
endFunction

bool function Exists(string paramKey, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    return JMap.hasKey(_container, paramKey)
endFunction

; To be tested
bool function ExistsContainer(string containerKey, string parentContainer = "root")
    int _container = self.GetHandle(parentContainer)
    return JMap.hasKey(_container, containerKey)
endFunction

bool function HasOverride(string paramKey)
    return JMap.hasKey(_miscVarsContainer, GetOverrideKey(paramKey))
endFunction

string function GetOverrideKey(string paramKey)
    return "Override::" + paramKey
endFunction

bool function HasMinimumValue(string paramKey)
    return JMap.hasKey(_miscVarsContainer, "Min::" + paramKey)
endFunction

bool function HasMaximumValue(string paramKey)
    return JMap.hasKey(_miscVarsContainer, "Max::" + paramKey)
endFunction

function SetIntMin(string paramKey, int minValue, bool allowNewRecords = false)
    if (!self.HasMinimumValue(paramKey) || allowNewRecords)
        JMap.setInt(_miscVarsContainer, "Min::" + paramKey, minValue)
    endif
endFunction

function SetIntMax(string paramKey, int minValue, bool allowNewRecords = false)
    if (!self.HasMaximumValue(paramKey) || allowNewRecords)
        JMap.setInt(_miscVarsContainer, "Max::" + paramKey, minValue)
    endif
endFunction

function SetFloatMin(string paramKey, float minValue, bool allowNewRecords = false)
    if (!self.HasMinimumValue(paramKey) || allowNewRecords)
        JMap.setFlt(_miscVarsContainer, "Min::" + paramKey, minValue)
    endif
endFunction

function SetFloatMax(string paramKey, float minValue, bool allowNewRecords = false)
    if (!self.HasMaximumValue(paramKey) || allowNewRecords)
        JMap.setFlt(_miscVarsContainer, "Max::" + paramKey, minValue)
    endif
endFunction

int function GetIntMin(string paramKey)
    return JMap.getInt(_miscVarsContainer, "Min::" + paramKey)
endFunction

int function GetIntMax(string paramKey)
    return JMap.getInt(_miscVarsContainer, "Max::" + paramKey)
endFunction

float function GetFloatMin(string paramKey)
    return JMap.getFlt(_miscVarsContainer, "Min::" + paramKey)
endFunction

float function GetFloatMax(string paramKey)
    return JMap.getFlt(_miscVarsContainer, "Max::" + paramKey)
endFunction

string function GetList(string category = "")
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "", category + "::")
    return GetContainerList(_miscVarsContainer, includeStringFilter = categoryKey)
endFunction

function List(string category = "")
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "", category + "::")
    Debug(self, string_if (!hasCategory, "MiscVars::List", "MiscVars::List("+ category +")"), GetContainerList(_miscVarsContainer, includeStringFilter = categoryKey))
endFunction

function ListOverrides(string category = "")
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "Override::", "Override::" + category + "::")
    Debug(self, string_if (!hasCategory, "MiscVars::ListOverrides", "MiscVars::ListOverrides("+ category +")"), GetContainerList(_miscVarsContainer, includeStringFilter = categoryKey))
endFunction

; Returns the made overriden key for this param if the var has an override and overriding is enabled,
; otherwise, returns the normal var key
string function __getUsedKey(string paramKey, bool allowOverrides)
    if (allowOverrides && self.HasOverride(paramKey))
        return GetOverrideKey(paramKey)
    endif
    
    return paramKey
endFunction

; ==========================================================
; Individual Container Functions
; ==========================================================

;/
    Base method for the creation of containers.
    Creates a container with the specified key, optionally inside another parent container.

    string  @containerKey: The key of the container to create
    string  @containerType: The type of the container (Array, Map, IntMap, FormMap...)
    string? @parentContainerKey: The key of the parent container to put this container into
    bool?   @retainInSave: Whether to retain this container in the save file

    returns: The key of the created container
/;
string function CreateContainer(string containerKey, string containerType, string parentContainerKey = "", bool retainInSave = true)
    int _container
    if (containerType == "Array")
        _container = JArray.object()
 
    elseif (containerType == "StringMap" || containerType == "Map")
        _container = JMap.object()

    elseif (containerType == "IntegerMap" || containerType == "IntMap")
        _container = JIntMap.object()

    elseif (containerType == "FormMap")
        _container = JFormMap.object()

    else
        Error(self, "MiscVars::CreateContainer", "The container type specified is invalid!")
        return ""
    endif

    if (retainInSave)
        JValue.retain(_container)
    endif

    int parentContainer = _miscVarsContainer
    if (parentContainerKey)
        parentContainer = JMap.getObj(_miscVarsContainer, parentContainerKey)
    endif

    if (!createdContainersIds)
        createdContainersIds = JMap.object()
        JValue.retain(createdContainersIds)
    endif

    ; Store the container's id
    JMap.setObj(createdContainersIds, containerKey, _container)
    JMap.setObj(_miscVarsContainer, "id", createdContainersIds)

    JMap.setObj(parentContainer, containerKey, _container)
    return containerKey
endFunction


;/
    Creates a string map with the specified key

    string  @containerKey: The key of the container to create
    bool?   @retainInSave: Whether to retain this container in the save file

    returns: The key of the container
/;
string function CreateStringMap(string containerKey, bool retainInSave = true)
    return self.CreateContainer(containerKey, "StringMap", "", retainInSave)
endFunction

;/
    Creates an array with the specified key

    string  @containerKey: The key of the container to create
    bool?   @retainInSave: Whether to retain this container in the save file

    returns: The key of the container
/;
string function CreateArray(string containerKey, bool retainInSave = true)
    return self.CreateContainer(containerKey, "Array", "", retainInSave)
endFunction

;/
    Creates an integer map with the specified key

    string  @containerKey: The key of the container to create
    bool?   @retainInSave: Whether to retain this container in the save file

    returns: The key of the container
/;
string function CreateIntegerMap(string containerKey, bool retainInSave = true)
    return self.CreateContainer(containerKey, "IntegerMap", "", retainInSave)
endFunction

;/
    Creates a form map with the specified key

    string  @containerKey: The key of the container to create
    bool?   @retainInSave: Whether to retain this container in the save file

    returns: The key of the container
/;
string function CreateFormMap(string containerKey, bool retainInSave = true)
    return self.CreateContainer(containerKey, "FormMap", "", retainInSave)
endFunction

;/
    Adds a child container to a base parent container through their keys to the internal container for this script.
    e.g: baseContainerKey: Locations, childContainerKey: Locations[Whiterun] will add
    Locations[Whiterun] to Locations

    string  @baseContainerKey: The parent container's key
    string  @childContainerKey: The child container's key, or the element that will be added to the parent
/;
function AddToContainer(string baseContainerKey, string childContainerKey)
    int _baseContainer  = JMap.getObj(_miscVarsContainer, baseContainerKey)
    int _childContainer = JMap.getObj(_miscVarsContainer, childContainerKey)
    
    JMap.setObj(_baseContainer, childContainerKey, _childContainer)
endFunction

function AddContainerToArray(string baseContainerKey, string childContainerKey)
    int _baseContainer  = JMap.getObj(_miscVarsContainer, baseContainerKey)
    int _childContainer = JMap.getObj(_miscVarsContainer, childContainerKey)
    
    JArray.addObj(_baseContainer, _childContainer)
endFunction

function AddArrayToContainer(string arrayKey, string parentContainerKey)
    int _array = JMap.getObj(_miscVarsContainer, arrayKey)
    int _parentContainer = JMap.getObj(_miscVarsContainer, parentContainerKey)
    JMap.setObj(_parentContainer, arrayKey, JValue.deepCopy(_array))
endFunction

function AddFormToArray(string arrayKey, Form akForm)
    if (!self.Exists(arrayKey))
        int _container = JArray.object()
        JValue.retain(_container)
        JArray.addForm(_container, akForm)
        JMap.setObj(_miscVarsContainer, arrayKey, _container)
        ; Debug(self, "MiscVars::AddFormToArray", "Added " + akForm + " to container. (id: "+ _container +")")
    
    else
        int _container = JMap.getObj(_miscVarsContainer, arrayKey)
        JArray.addForm(_container, akForm)
        ; Debug(self, "MiscVars::AddFormToArray", "Added " + akForm + " to container. (id: "+ _container +")")
    endif
endFunction

function AddStringToArray(string arrayKey, string asString)
    if (!self.Exists(arrayKey))
        int _container = JArray.object()
        JValue.retain(_container)
        JArray.addStr(_container, asString)
        JMap.setObj(_miscVarsContainer, arrayKey, _container)
        ; Debug(self, "MiscVars::AddStringToArray", "Added " + asString + " to container. (id: "+ _container +")")
    
    else
        int _container = JMap.getObj(_miscVarsContainer, arrayKey)
        JArray.addStr(_container, asString)
        ; Debug(self, "MiscVars::AddStringToArray", "Added " + asString + " to container. (id: "+ _container +")")
    endif
endFunction

; function AddString(string containerKey, string asString, bool createContainerIfNotExists = false, string parentContainerKey = "")
;     ; Determine if it's an array, int map, map, form map, etc...
;     if (createContainerIfNotExists && !self.Exists(containerKey))
;         self.CreateArray(containerKey)
;     endif

;     int _container = JMap.getObj(_miscVarsContainer, containerKey)

;     if (parentContainerKey)
;         int parentContainer = JMap.getObj(_miscVarsContainer, parentContainerKey)
;         _container = JMap.getObj(parentContainer, containerKey)
;     endif

;     if (JValue.isArray(_container))
;         JArray.addStr(_container, asString)

;     else
;         Error(self, "", "Container is not an array!")
;     endif

; endFunction

;/
    Retrieves a float from the array at index n

    string  @paramKey: The key of the array
    int     @index: The index to get the string from
/;
float function GetFloatFromArray(string arrayKey, int index)
    return JArray.getFlt(JMap.getObj(_miscVarsContainer, arrayKey), index)
endFunction

;/
    Retrieves an integer from the array at index n

    string  @arrayKey: The key of the array
    int     @index: The index to get the string from
/;
int function GetIntegerFromArray(string arrayKey, int index)
    return JArray.getInt(JMap.getObj(_miscVarsContainer, arrayKey), index)
endFunction

;/
    Retrieves a form from the array at index n

    string  @arrayKey: The key of the array
    int     @index: The index to get the string from
/;
Form function GetFormFromArray(string arrayKey, int index)
    return JArray.getForm(JMap.getObj(_miscVarsContainer, arrayKey), index)
endFunction

;/
    Retrieves a string from the array at index n

    string  @arrayKey: The key of the array
    int     @index: The index to get the string from
/;
string function GetStringFromArray(string arrayKey, int index)
    return JArray.getStr(JMap.getObj(_miscVarsContainer, arrayKey), index)
endFunction

string function Array_GetStringAt(string arrayKey, int index)
    return JArray.getStr(JMap.getObj(_miscVarsContainer, arrayKey), index)
endFunction

;/
    Converts an integer array into a papyrus integer array

    string  @arrayKey: The key of the array.

    returns: The papyrus equivalent of this array.
/;
int[] function GetPapyrusIntegerArray(string arrayKey)
    return JArray.asIntArray(JMap.getObj(_miscVarsContainer, arrayKey))
endFunction

;/
    Converts a float array into a papyrus float array

    string  @arrayKey: The key of the array.

    returns: The papyrus equivalent of this array.
/;
float[] function GetPapyrusFloatArray(string arrayKey)
    return JArray.asFloatArray(JMap.getObj(_miscVarsContainer, arrayKey))
endFunction

;/
    Converts a form array into a papyrus form array

    string  @arrayKey: The key of the array.

    returns: The papyrus equivalent of this array.
/;
Form[] function GetPapyrusFormArray(string arrayKey)
    return JArray.asFormArray(JMap.getObj(_miscVarsContainer, arrayKey))
endFunction

;/
    Converts a string array into a papyrus string array

    string  @arrayKey: The key of the array.

    returns: The papyrus equivalent of this array.
/;
string[] function GetPapyrusStringArray(string arrayKey)
    return JArray.asStringArray(JMap.getObj(_miscVarsContainer, arrayKey))
endFunction

;/
    Gets the length of a specified container.

    string  @containerKey: The container's key to check the length of.

    returns: The length of the container, 0 if empty.
/;
int function GetLengthOf(string containerKey)
    return JValue.count(JMap.getObj(_miscVarsContainer, containerKey))
endFunction

;/
    Checks to see if a given element exists in this container.

    string  @containerKey: The container to check the element in.
    string  @elementKey: The name of the element to check for its existence in the container.

    returns: true if the element is found in the container, false otherwise.
/;
bool function ExistsInContainer(string containerKey, string elementKey)
    return JMap.hasKey(JMap.getObj(_miscVarsContainer, containerKey), elementKey)
endFunction

;/
    Stores the contents of a container in a file.

    string  @containerKey: The key of the container as stored in the root container. If it's the root container then specify 'root'.
    string  @filePath: The file to write the container's data to.
/;
function Serialize(string containerKey, string filePath)
    Debug.StartStackProfiling()
    int _container = int_if (containerKey == "root", _miscVarsContainer, JMap.getObj(_miscVarsContainer, containerKey))
    JValue.writeToFile(_container, filePath)

    JValue.writeToFile(createdContainersIds, "containerIds.txt")

    Debug.StopStackProfiling()
endFunction

;/
    Extracts the contents from a file into a newly created container specified by @containerKey.

    string  @containerKey: The key of the container to be stored.
    string  @filePath: The file to read the container's data from.

    returns [string]: The key of the container as passed in through @containerKey.
/;
string function Unserialize(string containerKey, string filePath, bool retainInSave = true)
    int _container = JValue.readFromFile(filePath)
    string containerType = self.GetContainerType(_container)

    if (retainInSave)
        JValue.retain(_container)
    endif

    int parentContainer = _miscVarsContainer

    JMap.setObj(parentContainer, containerKey, _container)
    return containerKey
endFunction

string function GetContainerType(int _container)
    if (JValue.isArray(_container))
        return "Array"
    
    elseif (JValue.isMap(_container))
        return "StringMap"

    elseif (JValue.isIntegerMap(_container))
        return "IntMap"

    elseif (JValue.isFormMap(_container))
        return "FormMap"
    endif
    
endFunction

;/
    Idea is to get the last container of the path, example:
    Jail::Cells/Jail::Cells[Whiterun] should return the container Jail::Cells[Whiterun].
    This function must be recursive because it's unknown how deep the containers will go in terms of parent to child relationship 
/;
string function GetNthContainer(string containerKey)
    string internalKey
    
    int delimIndex = StringUtil.Find(containerKey, "/")

    
endFunction

function ListContainer(string containerKey, string category = "")
    int _container = JMap.getObj(_miscVarsContainer, containerKey)
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "", category + "::")
    Info(self, string_if (!hasCategory, "MiscVars::ListContainer["+ containerKey +"]", "MiscVars::ListContainer["+ containerKey +"]("+ category +")"), GetContainerList(_container, includeStringFilter = categoryKey))
endFunction

;/
    Writes the container to a file, optionally getting the container from
    another parent container.

    Idea for recursive call to get containers from the parent container:
    self.WriteToFile("Jail::Cells[Whiterun]", "jailCellsWhiterun.txt", "Jail/Jail::Cells/")
    
    This would get the container "Jail::Cells[Whiterun]" stored into the container Jail::Cells which itself is inside the Jail container.
    For each '/', do a recursive call and get the next container.
/;
function WriteToFile(string containerKey, string filePath, string fromParentContainer = "")
    int _container = JMap.getObj(_miscVarsContainer, containerKey)

    if (fromParentContainer)
        int parentContainer = JMap.getObj(_miscVarsContainer, fromParentContainer)
        _container = JMap.getObj(parentContainer, containerKey)
    endif

    JValue.writeToFile(_container, filePath)
endFunction

event OnInit()
    _miscVarsContainer = JMap.object()
    JValue.retain(_miscVarsContainer)

    createdContainersIds = JMap.object()
    JValue.retain(createdContainersIds)
    Debug(self, "__init", "Initialized Misc Vars Container")
endEvent

;/
    Returns the internal handle of the container (the id)
    if no key is specified, the handle of the root container will be returned,
        otherwise, the handle of the container created by @containerKey will be returned instead.

    string  @containerKey: The key of the container as specified on its creation

    returns: The handle of the container specified
/;
int function GetHandle(string containerKey = "root")
    if (containerKey == "root")
        return _miscVarsContainer ; Get the handle of the root container

    else
        if (!JMap.hasKey(createdContainersIds, containerKey))
            Error(self, "", "The handle specified is invalid! (Got: "+ containerKey +")")
            return -1
        endif

        return JMap.getObj(createdContainersIds, containerKey) ; Get the handle of the child container stored in createdContainersIds
    endif
endFunction

int property Size
    int function get()
        return JValue.count(_miscVarsContainer)
    endFunction
endProperty

int _miscVarsContainer
int createdContainersIds