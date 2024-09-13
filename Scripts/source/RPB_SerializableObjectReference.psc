scriptname RPB_SerializableObjectReference extends ObjectReference
{
    @property string ID
    @property bool Active
}

import RPB_Utility

; ==========================================================
;                Serializable ObjectReference
; ==========================================================

bool __initialized
bool _active
bool property Active
    bool function get() ; public
        if (!__initialized)
            _active = self.ActiveByDefault()
            __initialized = true
        endif
        return _active
    endFunction

    function set(bool value) ; protected
        if (!__initialized)
            return
        endif

        _active = value
    endFunction
endProperty

string property ID
    string function get()
        return self.GetSerializableID()
    endFunction
endProperty

bool function ActiveByDefault() ; virtual
    return true
endFunction


string function Rules(string rule)
    if (rule == "Required Properties")
        
    endif
endFunction

function Delete()
    ; Release serializable object, in case it was retained in memory
    JValue.release(self.GetSerializableRootObject())
    _active = false

    self.DeleteAllLocalProperties()
    self.OnReferenceDeleted()
endFunction

string function GetSerializableID() ; abstract
    return self.TryGetString("ID")
endFunction

;/
    returns (any& <JContainer>): Retrieves the serializable root object that represents this ObjectReference.
/;
int function GetSerializableRootObject() ; abstract
    DebugWarn("["+ self +"] SerializableObjectReference::GetSerializableRootObject", "Root data object has not been implemented!")
endFunction

bool function HasProperty(string asPropertyName, bool abCheckEmpty = false)
    return RPB_Data.HasProperty(__internalSerializedRootObject(), asPropertyName, abCheckEmpty = abCheckEmpty)
endFunction

; ==========================================================
;                          Getters
; ==========================================================

bool function GetPropertyOfTypeBool(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeBool(__internalSerializedRootObject(), asPropertyName)
endFunction

int function GetPropertyOfTypeInt(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeInteger(__internalSerializedRootObject(), asPropertyName)
endFunction

float function GetPropertyOfTypeFloat(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFloat(__internalSerializedRootObject(), asPropertyName)
endFunction

string function GetPropertyOfTypeString(string asPropertyName)
    float s = StartBenchmark()
    string prop = RPB_Data.GetPropertyOfTypeString(__internalSerializedRootObject(), asPropertyName)
    EndBenchmark(s, "["+ self +"] SerializableObjectReference::GetPropertyOfTypeString")
    return prop
endFunction

Form function GetPropertyOfTypeForm(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeForm(__internalSerializedRootObject(), asPropertyName)
endFunction

int[] function GetPropertyOfTypeIntegerArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeIntegerArray(__internalSerializedRootObject(), asPropertyName)
endFunction

float[] function GetPropertyOfTypeFloatArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFloatArray(__internalSerializedRootObject(), asPropertyName)
endFunction

string[] function GetPropertyOfTypeStringArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeStringArray(__internalSerializedRootObject(), asPropertyName)
endFunction

Form[] function GetPropertyOfTypeFormArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFormArray(__internalSerializedRootObject(), asPropertyName)
endFunction


; ==========================================================
;                          Setters
; ==========================================================

function SetPropertyOfTypeBool(string asPropertyName, bool abValue)
    ; return RPB_Data.SetPropertyOfTypeBool(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeInt(string asPropertyName, int aiValue)
    ; return RPB_Data.SetPropertyOfTypeInteger(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeFloat(string asPropertyName, float afValue)
    ; return RPB_Data.SetPropertyOfTypeFloat(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeString(string asPropertyName, string asValue)
    ; return RPB_Data.SetPropertyOfTypeString(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeForm(string asPropertyName, Form akValue)
    ; return RPB_Data.SetPropertyOfTypeForm(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeIntegerArray(string asPropertyName, int[] akValue)
    ; return RPB_Data.SetPropertyOfTypeIntegerArray(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeFloatArray(string asPropertyName, float[] akValue)
    ; return RPB_Data.SetPropertyOfTypeFloatArray(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeStringArray(string asPropertyName, string[] akValue)
    ; return RPB_Data.SetPropertyOfTypeStringArray(__internalSerializedRootObject(), asPropertyName)
endFunction

function SetPropertyOfTypeFormArray(string asPropertyName, Form[] akValue)
    ; return RPB_Data.SetPropertyOfTypeFormArray(__internalSerializedRootObject(), asPropertyName)
endFunction

; ==========================================================
;                   Find Property in Path
; ==========================================================

bool function FindPropertyOfTypeBool(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeBool(__internalSerializedRootObject(), asPropertyName)
endFunction

int function FindPropertyOfTypeInt(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeInteger(__internalSerializedRootObject(), asPropertyName)
endFunction

float function FindPropertyOfTypeFloat(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeFloat(__internalSerializedRootObject(), asPropertyName)
endFunction

string function FindPropertyOfTypeString(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeString(__internalSerializedRootObject(), asPropertyName)
endFunction

Form function FindPropertyOfTypeForm(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeForm(__internalSerializedRootObject(), asPropertyName)
endFunction

int[] function FindPropertyOfTypeIntegerArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeIntegerArray(__internalSerializedRootObject(), asPropertyName)
endFunction

float[] function FindPropertyOfTypeFloatArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeFloatArray(__internalSerializedRootObject(), asPropertyName)
endFunction

string[] function FindPropertyOfTypeStringArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeStringArray(__internalSerializedRootObject(), asPropertyName)
endFunction

Form[] function FindPropertyOfTypeFormArray(string asPropertyName, string apFindConditions)
    ; return RPB_Data.FindPropertyOfTypeFormArray(__internalSerializedRootObject(), asPropertyName)
endFunction

; ==========================================================
;             Local Properties bound to Reference
; ==========================================================

;                          Getters
; ==========================================================

bool function GetLocalPropertyOfTypeBool(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetBoolOnReference(asPropertyName, ID, asCategory)
endFunction

int function GetLocalPropertyOfTypeInt(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetIntOnReference(asPropertyName, ID, asCategory)
endFunction

float function GetLocalPropertyOfTypeFloat(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFloatOnReference(asPropertyName, ID, asCategory)
endFunction

string function GetLocalPropertyOfTypeString(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetStringOnReference(asPropertyName, ID, asCategory)
endFunction

Form function GetLocalPropertyOfTypeForm(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFormOnReference(asPropertyName, ID, asCategory)
endFunction

int[] function GetLocalPropertyOfTypeIntegerArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetIntsOnReference(asPropertyName, ID, asCategory)
endFunction

float[] function GetLocalPropertyOfTypeFloatArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFloatsOnReference(asPropertyName, ID, asCategory)
endFunction

string[] function GetLocalPropertyOfTypeStringArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetStringsOnReference(asPropertyName, ID, asCategory)
endFunction

Form[] function GetLocalPropertyOfTypeFormArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFormsOnReference(asPropertyName, ID, asCategory)
endFunction

;                          Setters
; ==========================================================

function SetLocalPropertyOfTypeBool(string asPropertyName, bool abValue, string asCategory = "null")
    RPB_StorageVars.SetBoolOnReference(asPropertyName, ID, abValue, asCategory)
endFunction

function SetLocalPropertyOfTypeInt(string asPropertyName, int aiValue, string asCategory = "null")
    RPB_StorageVars.SetIntOnReference(asPropertyName, ID, aiValue, asCategory)
endFunction

function SetLocalPropertyOfTypeFloat(string asPropertyName, float afValue, string asCategory = "null")
    RPB_StorageVars.SetFloatOnReference(asPropertyName, ID, afValue, asCategory)
endFunction

function SetLocalPropertyOfTypeString(string asPropertyName, string asValue, string asCategory = "null")
    RPB_StorageVars.SetStringOnReference(asPropertyName, ID, asValue, asCategory)
endFunction

function SetLocalPropertyOfTypeForm(string asPropertyName, Form akValue, string asCategory = "null")
    RPB_StorageVars.SetFormOnReference(asPropertyName, ID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeIntegerArray(string asPropertyName, int[] akValue, string asCategory = "null")
    RPB_StorageVars.SetIntsOnReference(asPropertyName, ID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeFloatArray(string asPropertyName, float[] akValue, string asCategory = "null")
    RPB_StorageVars.SetFloatsOnReference(asPropertyName, ID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeStringArray(string asPropertyName, string[] akValue, string asCategory = "null")
    RPB_StorageVars.SetStringsOnReference(asPropertyName, ID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeFormArray(string asPropertyName, Form[] akValue, string asCategory = "null")
    RPB_StorageVars.SetFormsOnReference(asPropertyName, ID, akValue, asCategory)
endFunction

;                           Misc.
; ==========================================================

function DeleteLocalProperty(string asKey, string asCategory = "null")
    RPB_StorageVars.DeleteVariableOnReference(asKey, ID, asCategory)
endFunction

function DeleteLocalCategory(string asCategory)
    RPB_StorageVars.DeleteCategoryOnReference(ID, asCategory)
endFunction

function DeleteAllLocalProperties()
    RPB_StorageVars.DeleteAllOnReference(ID)
endFunction

bool function HasLocalProperty(string asKey, string asCategory = "null")
    return RPB_StorageVars.HasVarOnReference(asKey, ID, asCategory)
endFunction

bool function HasLocalProperties()
    return RPB_StorageVars.HasVarsOnReference(ID)
endFunction

; ==========================================================
;                          Try Get
; ==========================================================
;/
    Attempts to get @asProperty from the Serializable Object and returns it,
    in case that fails, the fallback property is returned instead.
/;

function SetFallbackProperty(string asProperty, string asValue)
    self.SetLocalPropertyOfTypeString(asProperty, asValue, "Fallback")   
endFunction

bool function TryGetBool(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeBool(asProperty)
    endif

    return self.GetLocalPropertyOfTypeBool(asProperty, "Fallback")   
endFunction

int function TryGetInt(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeInt(asProperty)
    endif

    return self.GetLocalPropertyOfTypeInt(asProperty, "Fallback")   
endFunction

float function TryGetFloat(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeFloat(asProperty)
    endif

    return self.GetLocalPropertyOfTypeFloat(asProperty, "Fallback")   
endFunction

string function TryGetString(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeString(asProperty)
    endif

    return self.GetLocalPropertyOfTypeString(asProperty, "Fallback")   
endFunction

Form function TryGetForm(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeForm(asProperty)
    endif

    return self.GetLocalPropertyOfTypeForm(asProperty, "Fallback")   
endFunction

int[] function TryGetIntegerArray(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeIntegerArray(asProperty)
    endif

    return self.GetLocalPropertyOfTypeIntegerArray(asProperty, "Fallback")   
endFunction

float[] function TryGetFloatArray(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeFloatArray(asProperty)
    endif

    return self.GetLocalPropertyOfTypeFloatArray(asProperty, "Fallback")   
endFunction

string[] function TryGetStringArray(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeStringArray(asProperty)
    endif

    return self.GetLocalPropertyOfTypeStringArray(asProperty, "Fallback")   
endFunction

Form[] function TryGetFormArray(string asProperty)
    if (self.HasProperty(asProperty))
        return self.GetPropertyOfTypeFormArray(asProperty)
    endif

    return self.GetLocalPropertyOfTypeFormArray(asProperty, "Fallback")   
endFunction

; ==========================================================

event OnReferenceDeleted() ; abstract
endEvent

; ==========================================================
;                           private
; ==========================================================

bool function __verifyDataIntegrity()
    if (!Active)
        return false
    endif

    ; Check the data file for this object for errors
    return true
endFunction

; Add verification of data integrity
int function __internalSerializedRootObject()
    if (!Active)
        return 0
    endif

    return self.GetSerializableRootObject()
endFunction