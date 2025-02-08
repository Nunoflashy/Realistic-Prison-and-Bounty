scriptname RPB_SerializableReferenceAlias extends ReferenceAlias
{
    @property int ID
    @property string UUID
    @property bool Active
}

import RPB_Utility

; ==========================================================
;                Serializable ReferenceAlias
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

int property ID
    int function get()
        return self.GetID()
    endFunction
endProperty

string __oldUuid
string __uuid
string property UUID
    string function get()
        if (!__uuid)
            __requestUUID()
        endif

        __checkAndTriggerIdentityChange()
        return __uuid
    endFunction
endProperty

string function Rules(string rule)
    if (rule == "Required Properties")
        
    endif
endFunction

function Delete()
    ; Release serializable object, in case it was retained in memory
    JValue.release(self.GetSerializableRootObject())

    ; Release the object that is bound to this ReferenceAlias
    UnbindAlias(self)

    _active = false

    self.DeleteAllLocalProperties()

    ; Assign new UUID to differentiate this Ref from the new one
    __assignNewIdentity()

    self.OnReferenceDeleted()
endFunction

bool function ActiveByDefault() ; virtual
    return true
endFunction

;/
    returns (any& <JContainer>): Retrieves the serializable root object that represents this ReferenceAlias.
/;
int function GetSerializableRootObject() ; abstract
    DebugWarn("["+ self +"] SerializableReferenceAlias::GetSerializableRootObject", "Root data object has not been implemented!")
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
    return RPB_Data.GetPropertyOfTypeString(__internalSerializedRootObject(), asPropertyName)
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

int function GetPropertyOfTypeObject(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeObject(__internalSerializedRootObject(), asPropertyName)
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

Form[] function QueryFormArray(string asPropertyName, string apFindConditions)
    return RPB_Data.QueryFormArray(__internalSerializedRootObject(), asPropertyName, apFindConditions)
endFunction

; ==========================================================
;             Local Properties bound to Reference
; ==========================================================

;                          Getters
; ==========================================================

bool function GetLocalPropertyOfTypeBool(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetBoolOnReference(asPropertyName, UUID, asCategory)
endFunction

int function GetLocalPropertyOfTypeInt(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetIntOnReference(asPropertyName, UUID, asCategory)
endFunction

float function GetLocalPropertyOfTypeFloat(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFloatOnReference(asPropertyName, UUID, asCategory)
endFunction

string function GetLocalPropertyOfTypeString(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetStringOnReference(asPropertyName, UUID, asCategory)
endFunction

Form function GetLocalPropertyOfTypeForm(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFormOnReference(asPropertyName, UUID, asCategory)
endFunction

int[] function GetLocalPropertyOfTypeIntegerArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetIntsOnReference(asPropertyName, UUID, asCategory)
endFunction

float[] function GetLocalPropertyOfTypeFloatArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFloatsOnReference(asPropertyName, UUID, asCategory)
endFunction

string[] function GetLocalPropertyOfTypeStringArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetStringsOnReference(asPropertyName, UUID, asCategory)
endFunction

Form[] function GetLocalPropertyOfTypeFormArray(string asPropertyName, string asCategory = "null")
    return RPB_StorageVars.GetFormsOnReference(asPropertyName, UUID, asCategory)
endFunction

;                          Setters
; ==========================================================

function SetLocalPropertyOfTypeBool(string asPropertyName, bool abValue, string asCategory = "null")
    RPB_StorageVars.SetBoolOnReference(asPropertyName, UUID, abValue, asCategory)
endFunction

function SetLocalPropertyOfTypeInt(string asPropertyName, int aiValue, string asCategory = "null")
    RPB_StorageVars.SetIntOnReference(asPropertyName, UUID, aiValue, asCategory)
endFunction

function SetLocalPropertyOfTypeFloat(string asPropertyName, float afValue, string asCategory = "null")
    RPB_StorageVars.SetFloatOnReference(asPropertyName, UUID, afValue, asCategory)
endFunction

function SetLocalPropertyOfTypeString(string asPropertyName, string asValue, string asCategory = "null")
    RPB_StorageVars.SetStringOnReference(asPropertyName, UUID, asValue, asCategory)
endFunction

function SetLocalPropertyOfTypeForm(string asPropertyName, Form akValue, string asCategory = "null")
    RPB_StorageVars.SetFormOnReference(asPropertyName, UUID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeIntegerArray(string asPropertyName, int[] akValue, string asCategory = "null")
    RPB_StorageVars.SetIntsOnReference(asPropertyName, UUID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeFloatArray(string asPropertyName, float[] akValue, string asCategory = "null")
    RPB_StorageVars.SetFloatsOnReference(asPropertyName, UUID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeStringArray(string asPropertyName, string[] akValue, string asCategory = "null")
    RPB_StorageVars.SetStringsOnReference(asPropertyName, UUID, akValue, asCategory)
endFunction

function SetLocalPropertyOfTypeFormArray(string asPropertyName, Form[] akValue, string asCategory = "null")
    RPB_StorageVars.SetFormsOnReference(asPropertyName, UUID, akValue, asCategory)
endFunction

;                           Misc.
; ==========================================================

function DeleteLocalProperty(string asKey, string asCategory = "null")
    RPB_StorageVars.DeleteVariableOnReference(asKey, UUID, asCategory)
endFunction

function DeleteLocalCategory(string asCategory)
    RPB_StorageVars.DeleteCategoryOnReference(UUID, asCategory)
endFunction

function DeleteAllLocalProperties()
    RPB_StorageVars.DeleteAllOnReference(UUID)
endFunction

bool function HasLocalProperty(string asKey, string asCategory = "null")
    return RPB_StorageVars.HasVarOnReference(asKey, UUID, asCategory)
endFunction

bool function HasLocalProperties()
    return RPB_StorageVars.HasVarsOnReference(UUID)
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

; =========================================================
;                       State Registry                      
; =========================================================

function SetReferenceStateInt(string asReference, string asStateProperty, int aiValue)
    RPB_StorageVars.SetIntOnReference(asStateProperty, asReference, aiValue, UUID + "::State")
endFunction

function SetReferenceStateFloat(string asReference, string asStateProperty, float afValue)
    RPB_StorageVars.SetFloatOnReference(asStateProperty, asReference, afValue, UUID + "::State")
endFunction

function SetReferenceStateString(string asReference, string asStateProperty, string asValue)
    RPB_StorageVars.SetStringOnReference(asStateProperty, asReference, asValue, UUID + "::State")
endFunction

int function GetReferenceStateInt(string asReference, string asStateProperty)
    return RPB_StorageVars.GetIntOnReference(asStateProperty, asReference, UUID + "::State")
endFunction

float function GetReferenceStateFloat(string asReference, string asStateProperty)
    return RPB_StorageVars.GetFloatOnReference(asStateProperty, asReference, UUID + "::State")
endFunction

string function GetReferenceStateString(string asReference, string asStateProperty)
    return RPB_StorageVars.GetStringOnReference(asStateProperty, asReference, UUID + "::State")
endFunction

function RemoveReferenceState(string asReference, string asStateProperty)
    RPB_StorageVars.DeleteVariableOnReference(asStateProperty, asReference, UUID + "::State")

    bool hasStates = RPB_StorageVars.HasVarsOnReference(asReference, UUID + "::State")

    if (!hasStates)
        RPB_StorageVars.DeleteCategoryOnReference(asReference, UUID + "::State")
    endif
endFunction

; ==========================================================

function EnsureFunctionalState()
    ; UUID changed, this is a new RefAlias
    __checkAndTriggerIdentityChange()

    if (!__uuid)
        __requestUUID()
    endif
endFunction

; Triggers when the UUID for this RefAlias is changed
event OnIdentityChanged(string asOldUUID, string asNewUUID)
    Debug("["+ self +"] SerializableReferenceAlias::OnIdentityChanged", "Identity has changed! (Old UUID: "+ asOldUUID +", Current UUID: "+ asNewUUID +")")
endEvent

event OnReferenceDeleted() ; abstract
endEvent

; ==========================================================
;                           private
; ==========================================================

function __requestUUID()
    __assignNewIdentity()
    Debug("["+ self +"] (private) SerializableReferenceAlias::RequestUUID", "Requested UUID: " + UUID)
endFunction

;Generates and assigns a new UUID to this instance.
function __assignNewIdentity()
    __oldUuid = __uuid
    __uuid = RPB_Utility.GenerateUUID()
endFunction

; Checks whether the UUID has changed and triggers the event if it has.
function __checkAndTriggerIdentityChange()
    if (__uuid != __oldUuid && __oldUuid != "")
        self.OnIdentityChanged(__oldUuid, __uuid)
        __oldUuid = ""
    endif
endFunction

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