scriptname RPB_SerializableReferenceAlias extends ReferenceAlias

import RPB_Utility

; ==========================================================
;                Serializable ReferenceAlias
; ==========================================================

string __fallbackId
string __id
string property ID
    string function get()
        return self.GetSerializableID()
    endFunction
endProperty

string __fallbackName
string __name
string property Name
    string function get()
        return self.GetSerializableName()
    endFunction
endProperty

int __rootObject

bool property IsDataHotLoadable auto

function SetFallbackID(string asFallbackID)
    __fallbackId = asFallbackID
endFunction

function SetFallbackName(string asFallbackName)
    __fallbackName = asFallbackName
endFunction

string function Rules(string rule)
    if (rule == "Required Properties")
        
    endif
endFunction

bool function __verifyDataIntegrity()
    ; Check the data file for this object for errors
    return true
endFunction

int function __updateRootObject()
    if (!__rootObject)
        __rootObject = JValue.deepCopy(self.GetSerializableRootObject())
        JValue.retain(__rootObject)
    endif

    __rootObject = JValue.deepCopy(self.GetSerializableRootObject())
    return __rootObject
endFunction 

; Add verification of data integrity
int function __getCachedSerializedRootObject()
    return self.GetSerializableRootObject()

    if (self.IsDataHotLoadable)
        return __updateRootObject()
    endif

    if (!__rootObject)
        __updateRootObject()
    endif

    return __rootObject
endFunction

bool function ReloadData()
    bool isValidData = __verifyDataIntegrity()

    if (isValidData)
        __rootObject = self.GetSerializableRootObject()

        Debug("["+ self +"] SerializableReferenceAlias::ReloadData", "Data has been reloaded.", !self.IsDataHotLoadable)
        DebugWarn("["+ self +"] SerializableReferenceAlias::ReloadData", "Data has been reloaded, but the reference is already hot loadable!", self.IsDataHotLoadable)
    else
        DebugError("["+ self +"] SerializableReferenceAlias::ReloadData", "There are errors in the data object, cannot reload data!", !isValidData)
        Error("There are errors in the data object, cannot reload data!", !isValidData)
    endif

    return isValidData
endFunction


string function GetSerializableName() ; virtual
    if (self.IsDataHotLoadable)
        string value = self.GetPropertyOfTypeString("Name")
        if (value)
            return value
        else
            return __fallbackName
        endif
    endif

    if (!__name)
        __name = self.GetPropertyOfTypeString("Name")
    endif
    
    if (!__name)
        return __fallbackName
    endif

    return __name
endFunction

string function GetSerializableID() ; virtual
    if (self.IsDataHotLoadable)
        string value = self.GetPropertyOfTypeString("ID")
        if (value)
            return value
        else
            return __fallbackId
        endif
    endif

    if (!__id)
        __id = self.GetPropertyOfTypeString("ID")
    endif
    
    if (!__id)
        return __fallbackId
    endif

    return __id
endFunction

;/
    returns (any& <JContainer>): Retrieves the serializable root object that represents this ObjectReference.
/;
int function GetSerializableRootObject() ; abstract
    DebugWarn("["+ self +"] SerializableReferenceAlias::GetSerializableRootObject", "Root data object has not been implemented!")
endFunction

bool function HasProperty(string asPropertyName, bool abCheckEmpty = false)
    return RPB_Data.HasProperty(__getCachedSerializedRootObject(), asPropertyName, abCheckEmpty = abCheckEmpty)
endFunction

; ==========================================================
;                          Getters
; ==========================================================

bool function GetPropertyOfTypeBool(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeBool(__getCachedSerializedRootObject(), asPropertyName)
endFunction

int function GetPropertyOfTypeInt(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeInteger(__getCachedSerializedRootObject(), asPropertyName)
endFunction

float function GetPropertyOfTypeFloat(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFloat(__getCachedSerializedRootObject(), asPropertyName)
endFunction

string function GetPropertyOfTypeString(string asPropertyName)
    float s = StartBenchmark()
    string prop = RPB_Data.GetPropertyOfTypeString(__getCachedSerializedRootObject(), asPropertyName)
    EndBenchmark(s, "["+ self +"] SerializableReferenceAlias::GetPropertyOfTypeString ("+ asPropertyName +")")
    return prop
endFunction

Form function GetPropertyOfTypeForm(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeForm(__getCachedSerializedRootObject(), asPropertyName)
endFunction

int[] function GetPropertyOfTypeIntegerArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeIntegerArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

float[] function GetPropertyOfTypeFloatArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFloatArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

string[] function GetPropertyOfTypeStringArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeStringArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

Form[] function GetPropertyOfTypeFormArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFormArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction


; ==========================================================
;                          Setters
; ==========================================================

function SetPropertyOfTypeBool(string asPropertyName, bool abValue)
    ; return RPB_Data.SetPropertyOfTypeBool(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeInt(string asPropertyName, int aiValue)
    ; return RPB_Data.SetPropertyOfTypeInteger(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeFloat(string asPropertyName, float afValue)
    ; return RPB_Data.SetPropertyOfTypeFloat(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeString(string asPropertyName, string asValue)
    ; return RPB_Data.SetPropertyOfTypeString(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeForm(string asPropertyName, Form akValue)
    ; return RPB_Data.SetPropertyOfTypeForm(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeIntegerArray(string asPropertyName, int[] akValue)
    ; return RPB_Data.SetPropertyOfTypeIntegerArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeFloatArray(string asPropertyName, float[] akValue)
    ; return RPB_Data.SetPropertyOfTypeFloatArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeStringArray(string asPropertyName, string[] akValue)
    ; return RPB_Data.SetPropertyOfTypeStringArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeFormArray(string asPropertyName, Form[] akValue)
    ; return RPB_Data.SetPropertyOfTypeFormArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction


; ==========================================================
;                   Find Property in Path
; ==========================================================

bool function FindPropertyOfTypeBool(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeBool(__getCachedSerializedRootObject(), asPropertyName)
endFunction

int function FindPropertyOfTypeInt(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeInteger(__getCachedSerializedRootObject(), asPropertyName)
endFunction

float function FindPropertyOfTypeFloat(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeFloat(__getCachedSerializedRootObject(), asPropertyName)
endFunction

string function FindPropertyOfTypeString(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeString(__getCachedSerializedRootObject(), asPropertyName)
endFunction

Form function FindPropertyOfTypeForm(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeForm(__getCachedSerializedRootObject(), asPropertyName)
endFunction

int[] function FindPropertyOfTypeIntegerArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeIntegerArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

float[] function FindPropertyOfTypeFloatArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeFloatArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

string[] function FindPropertyOfTypeStringArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeStringArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction

Form[] function FindPropertyOfTypeFormArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeFormArray(__getCachedSerializedRootObject(), asPropertyName)
endFunction
