scriptname RealisticPrisonAndBounty_MiscVars extends Quest

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

; ==========================================================
; Functions & Events
; ==========================================================

int property Size
    int function get()
        return JValue.count(_miscVarsContainer)
    endFunction
endProperty

function SetBool(string paramKey, bool value)
    JMap.setInt(_miscVarsContainer, paramKey, value as int)
endFunction

function SetInt(string paramKey, int value)
    JMap.setInt(_miscVarsContainer, paramKey, value)
endFunction

function SetFloat(string paramKey, float value)
    JMap.setFlt(_miscVarsContainer, paramKey, value)
endFunction

function SetString(string paramKey, string value)
    JMap.setStr(_miscVarsContainer, paramKey, value)
endFunction

function SetForm(string paramKey, Form value)
    JMap.setForm(_miscVarsContainer, paramKey, value)
endFunction

function SetReference(string paramKey, ObjectReference value)
    JMap.setForm(_miscVarsContainer, paramKey, value)
endFunction

function SetActor(string paramKey, Actor value)
    JMap.setForm(_miscVarsContainer, paramKey, value)
endFunction

function SetObject(string paramKey, int value)
    JMap.setObj(_miscVarsContainer, paramKey, value)
endFunction

function ModInt(string paramKey, int value)
    int currentValue = self.GetInt(paramKey)
    self.SetInt(paramKey, currentValue + value)
endFunction

function ModFloat(string paramKey, float value)
    float currentValue = self.GetFloat(paramKey)
    self.SetFloat(paramKey, currentValue + value)
endFunction

bool function GetBool(string paramKey, bool allowOverrides = true)
    return JMap.getInt(_miscVarsContainer, __getUsedKey(paramKey, allowOverrides)) as bool
endFunction

int function GetInt(string paramKey, bool allowOverrides = true)
    int thisValue = JMap.getInt(_miscVarsContainer, __getUsedKey(paramKey, allowOverrides))

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

float function GetFloat(string paramKey, bool allowOverrides = true)
    float thisValue = JMap.getFlt(_miscVarsContainer, __getUsedKey(paramKey, allowOverrides))

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

string function GetString(string paramKey, bool allowOverrides = true)
    return JMap.getStr(_miscVarsContainer, __getUsedKey(paramKey, allowOverrides))
endFunction

Form function GetForm(string paramKey, bool allowOverrides = true)
    return JMap.getForm(_miscVarsContainer, __getUsedKey(paramKey, allowOverrides))
endFunction

ObjectReference function GetReference(string paramKey)
    return GetForm(paramKey) as ObjectReference
endFunction

Actor function GetActor(string paramKey)
    return GetForm(paramKey) as Actor
endFunction

int function GetObject(string paramKey, bool allowOverrides = true)
    return JMap.getObj(_miscVarsContainer, __getUsedKey(paramKey, allowOverrides))
endFunction

function Remove(string paramKey, bool removeOverrides = true)
    JMap.removeKey(_miscVarsContainer, paramKey)
    JValue.release(JMap.getObj(_miscVarsContainer, paramKey))
    
    if (self.HasOverride(paramKey) && removeOverrides)
        JMap.removeKey(_miscVarsContainer, GetOverrideKey(paramKey))
    endif
endFunction

function Clear()
    JMap.clear(_miscVarsContainer)
endFunction

bool function Exists(string paramKey)
    return JMap.hasKey(_miscVarsContainer, paramKey)
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

    elseif (containerType == "IntegerMap" || "IntMap")
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

function ListContainer(string containerKey, string category = "")
    int _container = JMap.getObj(_miscVarsContainer, containerKey)
    bool hasCategory = category != ""
    string categoryKey = string_if (!hasCategory, "", category + "::")
    Info(self, string_if (!hasCategory, "MiscVars::ListContainer["+ containerKey +"]", "MiscVars::ListContainer["+ containerKey +"]("+ category +")"), GetContainerList(_container, includeStringFilter = categoryKey))
endFunction

; string function GetHold(string city)
;     return self.GetString("Hold["+ city +"]")
; endFunction

; string function GetCity(string hold)
;     return self.GetString("City["+ hold +"]")
; endFunction

; Faction function GetCrimeFaction(string hold)
;     return self.GetForm("Faction::Crime["+ hold +"]") as Faction
; endFunction

; Faction function GetFaction(string hold)
;     return self.GetForm("Faction["+ hold +"]") as Faction
; endFunction

; Form[] function GetJailCells(string hold)
;     return containerManager.GetPapyrusFormArray("Jail::Cells["+ hold +"]")
; endFunction

; Form function GetJailCell(string hold, int index)
;     return self.GetJailCells(hold)[index]
; endFunction

event OnInit()
    _miscVarsContainer = JMap.object()
    JValue.retain(_miscVarsContainer)
    Debug(self, "__init", "Initialized Misc Vars Container")
endEvent


int function GetHandle()
    return _miscVarsContainer
endFunction

int _miscVarsContainer