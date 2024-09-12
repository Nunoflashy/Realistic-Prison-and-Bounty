scriptname RPB_StorageVars hidden

import RPB_Utility

string function GetRootPath() global
    return ".rpb_root.storage"
endFunction

int function GetObjectHandle(string asCategory = "null") global 
    if (asCategory != "null" && asCategory != "")
        return JDB.solveObj(GetRootPath() + "." + asCategory)
    endif

    return JDB.solveObj(GetRootPath())
endFunction

int function GetObjectHandleOnForm(Form akForm, string asCategory = "null") global
    if (asCategory != "null" && asCategory != "")
        return JDB.solveObj(GetRootPath() + "." + akForm.GetFormID() + "." + asCategory)
    endif

    return JDB.solveObj(GetRootPath() + "." + akForm.GetFormID())
endFunction

int function GetObjectHandleOnKey(string asKey, string asCategory = "null") global
    if (asCategory != "null" && asCategory != "")
        return JDB.solveObj(GetRootPath() + "." + asKey + "." + asCategory)
    endif

    return JDB.solveObj(GetRootPath() + "." + asKey)
endFunction

; ==========================================================
;                        Normal Vars
; ==========================================================

string function GetVarPath(string asKey, string asCategory = "null") global
    string path = none
    
    if (asCategory != "null" && asCategory != "")
        path = GetRootPath() + "." + asCategory + "." + asKey
    else
        path = GetRootPath() + "." + asKey
    endif

    return path
endFunction

string function GetCategoryPath(string asCategory) global
    return GetRootPath() + "." + asCategory
endFunction

;                          Getters

bool function GetBool(string asKey, string asCategory = "null", bool abDefault = false) global
    string path = GetVarPath(asKey, asCategory)
    return JDB.solveInt(path, abDefault as int) as bool
endFunction

int function GetInt(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    Debug("StorageVars::GetInt", "path: " + path + ", value: " + JDB.solveInt(path))
    return JDB.solveInt(path)
endFunction

float function GetFloat(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    return JDB.solveFlt(path)
endFunction

string function GetString(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    return JDB.solveStr(path)
endFunction

Form function GetForm(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    return JDB.solveForm(path)
endFunction

int[] function GetInts(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    return JArray.asIntArray(JDB.solveObj(path))
endFunction

float[] function GetFloats(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    return JArray.asFloatArray(JDB.solveObj(path))
endFunction

string[] function GetStrings(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    return JArray.asStringArray(JDB.solveObj(path))
endFunction

Form[] function GetForms(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    return JArray.asFormArray(JDB.solveObj(path))
endFunction

;                          Setters

function SetBool(string asKey, bool abValue, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    JDB.solveIntSetter(path, abValue as int, true)
endFunction

function SetInt(string asKey, int aiValue, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    JDB.solveIntSetter(path, aiValue, true)
endFunction

function SetFloat(string asKey, float afValue, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    JDB.solveFltSetter(path, afValue, true)
endFunction

function SetString(string asKey, string asValue, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    JDB.solveStrSetter(path, asValue, true)
endFunction

function SetForm(string asKey, Form akValue, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    JDB.solveFormSetter(path, akValue, true)
endFunction

function SetInts(string asKey, int[] aiValues, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    int formToObject = JArray.objectWithInts(aiValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetFloats(string asKey, float[] afValues, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    int formToObject = JArray.objectWithFloats(afValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetStrings(string asKey, string[] asValues, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    int formToObject = JArray.objectWithStrings(asValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetForms(string asKey, Form[] akValues, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    int formToObject = JArray.objectWithForms(akValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetObject(string asKey, int akObject, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    JDB.solveObjSetter(path, akObject, true)
endFunction

function CreateObject(string asKey, string asCategory = "null") global
    string path = GetVarPath(asKey, asCategory)
    JDB.solveObjSetter(path, JMap.object(), true)
endFunction

;                          Modifiers
function ModInt(string asKey, int aiValue, string asCategory = "null")
    int currentValue = GetInt(asKey, asCategory)
    SetInt(asKey, currentValue + aiValue, asCategory)
endFunction

function ModFloat(string asKey, float afValue, string asCategory = "null")
    float currentValue = GetFloat(asKey, asCategory)
    SetFloat(asKey, currentValue + afValue, asCategory)
endFunction

;                     Delete Functions

function DeleteVariable(string asKey, string asCategory = "null") global
    int obj = GetObjectHandle(asCategory)
    JMap.removeKey(obj, asKey)
endFunction

function DeleteCategory(string asCategory) global
    int obj = GetObjectHandle()
    JMap.removeKey(obj, asCategory)
endFunction

function DeleteAll() global
    int deletedObj = GetObjectHandle()
    JMap.clear(deletedObj)
    JMap.removeKey(JDB.root(), GetRootPath())
endFunction

; ==========================================================
;                       Form Specific
; ==========================================================

string function GetVarPathOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = none
    
    if (asCategory != "null" && asCategory != "")
        path = GetRootPath() + "." + akForm.GetFormID() + "." + asCategory + "." + asKey
    else
        path = GetRootPath() + "." + akForm.GetFormID() + "." + asKey
    endif

    return path
endFunction

string function GetCategoryPathOnForm(Form akForm, string asCategory) global
    return GetRootPath() + "." + akForm.GetFormID() + "." + asCategory
endFunction

string function GetFormPath(Form akForm) global
    return GetRootPath() + "." + akForm.GetFormID()
endFunction

;                          Getters

bool function GetBoolOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)

    ; Debug(none, "StorageVars::GetBoolOnForm", "path: " + path + ", value: " + JDB.solveInt(path))

    return JDB.solveInt(path) as bool
endFunction

int function GetIntOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JDB.solveInt(path)
endFunction

float function GetFloatOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JDB.solveFlt(path)
endFunction

string function GetStringOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JDB.solveStr(path)
endFunction

Form function GetFormOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    ; Debug(none, "StorageVars::GetFormOnForm", "path: " + path + ", value: " + JDB.solveForm(path))

    return JDB.solveForm(path)
endFunction

int[] function GetIntsOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asIntArray(JDB.solveObj(path))
endFunction

float[] function GetFloatsOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asFloatArray(JDB.solveObj(path))
endFunction

string[] function GetStringsOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asStringArray(JDB.solveObj(path))
endFunction

Form[] function GetFormsOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asFormArray(JDB.solveObj(path))
endFunction

;                          Setters

function SetBoolOnForm(string asKey, Form akForm, bool abValue, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    JDB.solveIntSetter(path, abValue as int, true)
endFunction

function SetIntOnForm(string asKey, Form akForm, int aiValue, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    JDB.solveIntSetter(path, aiValue, true)
endFunction

function SetFloatOnForm(string asKey, Form akForm, float afValue, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    JDB.solveFltSetter(path, afValue, true)
endFunction

function SetStringOnForm(string asKey, Form akForm, string asValue, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    JDB.solveStrSetter(path, asValue, true)
endFunction

function SetFormOnForm(string asKey, Form akForm, Form akValue, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    
    JDB.solveFormSetter(path, akValue, true)
    ; Debug(none, "StorageVars::SetFormOnForm", "path: " + path + ", value: " + JDB.solveForm(path))
endFunction

function SetIntsOnForm(string asKey, Form akForm, int[] aiValues, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithInts(aiValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetFloatsOnForm(string asKey, Form akForm, float[] afValues, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithFloats(afValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetStringsOnForm(string asKey, Form akForm, string[] asValues, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithStrings(asValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetFormsOnForm(string asKey, Form akForm, Form[] akValues, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithForms(akValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

;                          Modifiers
function ModIntOnForm(string asKey, Form akForm, int aiValue, string asCategory = "null") global
    int currentValue = GetIntOnForm(asKey, akForm, asCategory)
    SetIntOnForm(asKey, akForm, currentValue + aiValue, asCategory)
endFunction

function ModFloatOnForm(string asKey, Form akForm, float afValue, string asCategory = "null") global
    float currentValue = GetFloatOnForm(asKey, akForm, asCategory)
    SetFloatOnForm(asKey, akForm, currentValue + afValue, asCategory)
endFunction

;                     Delete Functions

function DeleteVariableOnForm(string asKey, Form akForm, string asCategory = "null") global
    ; string path = GetVarPathOnForm(asKey, akForm, asCategory)
    ; JDB.solveObjSetter(path, 0)
    int obj = GetObjectHandleOnForm(akForm, asCategory)
    JMap.removeKey(obj, asKey)
endFunction

function DeleteCategoryOnForm(Form akForm, string asCategory) global
    ; string path = GetCategoryPathOnForm(akForm, asCategory)
    ; JDB.solveObjSetter(path, 0)
    int deletedObj = GetObjectHandleOnForm(akForm)
    JMap.removeKey(deletedObj, asCategory)
endFunction

function DeleteAllOnForm(Form akForm) global
    ; string path = GetFormPath(akForm)
    ; JDB.solveObjSetter(path, 0, true)
    int deletedObj = GetObjectHandleOnForm(akForm)
    JMap.clear(deletedObj)
    JMap.removeKey(GetObjectHandle(), akForm.GetFormID())
endFunction

bool function HasVarOnForm(string asKey, Form akForm, string asCategory = "null") global
    string path = GetVarPathOnForm(asKey, akForm, asCategory)
    return JDB.hasPath(path)
endFunction

bool function HasVarsOnForm(Form akForm, string asCategory = "null") global
    int formId  = akForm.GetFormID()
    string path = GetRootPath() + "."+ formId

    return JDB.hasPath(path)
endFunction

; ==========================================================
;                      ActiveMagicEffect
; ==========================================================

string function GetVarPathOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = none
    
    if (asCategory != "null" && asCategory != "")
        path = GetRootPath() + "." + apEffect + "." + asCategory + "." + asKey
    else
        path = GetRootPath() + "." + apEffect + "." + asKey
    endif

    return path
endFunction

string function GetCategoryPathOnActiveMagicEffect(ActiveMagicEffect apEffect, string asCategory) global
    return GetRootPath() + "." + apEffect as string + "." + asCategory
endFunction

string function GetActiveMagicEffectPath(ActiveMagicEffect apEffect) global
    return GetRootPath() + "." + apEffect as string
endFunction

;                          Getters

bool function GetBoolOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JDB.solveInt(path) as bool
endFunction

int function GetIntOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JDB.solveInt(path)
endFunction

float function GetFloatOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JDB.solveFlt(path)
endFunction

string function GetStringOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JDB.solveStr(path)
endFunction

Form function GetFormOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JDB.solveForm(path)
endFunction

int[] function GetIntsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JArray.asIntArray(JDB.solveObj(path))
endFunction

float[] function GetFloatsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JArray.asFloatArray(JDB.solveObj(path))
endFunction

string[] function GetStringsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JArray.asStringArray(JDB.solveObj(path))
endFunction

Form[] function GetFormsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JArray.asFormArray(JDB.solveObj(path))
endFunction

;                          Setters

function SetBoolOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, bool abValue, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    JDB.solveIntSetter(path, abValue as int, true)
endFunction

function SetIntOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, int aiValue, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    JDB.solveIntSetter(path, aiValue, true)
endFunction

function SetFloatOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, float afValue, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    JDB.solveFltSetter(path, afValue, true)
endFunction

function SetStringOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asValue, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    JDB.solveStrSetter(path, asValue, true)
endFunction

function SetFormOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, Form akValue, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    JDB.solveFormSetter(path, akValue, true)
endFunction

function SetIntsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, int[] aiValues, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    int formToObject = JArray.objectWithInts(aiValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetFloatsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, float[] afValues, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    int formToObject = JArray.objectWithFloats(afValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetStringsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string[] asValues, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    int formToObject = JArray.objectWithStrings(asValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetFormsOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, Form[] akValues, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    int formToObject = JArray.objectWithForms(akValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

;                          Modifiers
function ModIntOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, int aiValue, string asCategory = "null") global
    int currentValue = GetIntOnActiveMagicEffect(asKey, apEffect, asCategory)
    SetIntOnActiveMagicEffect(asKey, apEffect, currentValue + aiValue, asCategory)
endFunction

function ModFloatOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, float afValue, string asCategory = "null") global
    float currentValue = GetFloatOnActiveMagicEffect(asKey, apEffect, asCategory)
    SetFloatOnActiveMagicEffect(asKey, apEffect, currentValue + afValue, asCategory)
endFunction

;                     Delete Functions

function DeleteVariableOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    int obj = GetObjectHandleOnKey(apEffect, asCategory)
    JMap.removeKey(obj, asKey)
endFunction

function DeleteCategoryOnActiveMagicEffect(ActiveMagicEffect apEffect, string asCategory) global
    int deletedObj = GetObjectHandleOnKey(apEffect)
    JMap.removeKey(deletedObj, asCategory)
endFunction

function DeleteAllOnActiveMagicEffect(ActiveMagicEffect apEffect) global
    int deletedObj = GetObjectHandleOnKey(apEffect)
    JMap.clear(deletedObj)
    JMap.removeKey(GetObjectHandle(), apEffect as string)
endFunction

bool function HasVarOnActiveMagicEffect(string asKey, ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetVarPathOnActiveMagicEffect(asKey, apEffect, asCategory)
    return JDB.hasPath(path)
endFunction

bool function HasVarsOnActiveMagicEffect(ActiveMagicEffect apEffect, string asCategory = "null") global
    string path = GetRootPath() + "." + apEffect as string
    return JDB.hasPath(path)
endFunction

; ==========================================================
;                  Any Reference as Source
; ==========================================================

;/
    Getters:
        Returns a value <T> from the given reference, optionally from a specific category.
        The reference is taken as a string since all objects can be implicitly cast as one.

        Function Signature: <T> function GetTypeOnReference(string Key, string Reference, string? Category)
            string  @Key: The key to access the value.
            string  @Reference: The reference on which this value should be set (References can be anything implicitly castable to a string: Form, ReferenceAlias, ActiveMagicEffect, etc...).
            string  @Category: The category on which this value will be stored (sub-category of Reference).

            returns (<T>): The value from the given key on the reference.

    Setters:
        Sets a value <T> on a given reference, optionally setting it on a specific category of that reference.
        The reference is taken as a string since all objects can be implicitly cast as one.

        Function Signature: <T> function SetTypeOnReference(string Key, string Reference, T Value, string? Category)
            string  @Key: The key to access the value.
            string  @Reference: The reference on which this value should be set (References can be anything implicitly castable to a string: Form, ReferenceAlias, ActiveMagicEffect, etc...).
            T       @Value: The value to set for this key on this reference.
            string  @Category: The category on which this value will be stored (sub-category of Reference).
/;

string function GetVarPathOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = ""
    
    if (asCategory != "null" && asCategory != "")
        path = GetRootPath() + "." + apReference + "." + asCategory + "." + asKey
    else
        path = GetRootPath() + "." + apReference + "." + asKey
    endif
    ; DebugWithArgs("StorageVars::GetVarPathOnReference", "Key: " + asKey + ", Reference: " + apReference + ", Category: " + asCategory, path)

    return path
endFunction

;                          Getters

bool function GetBoolOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JDB.solveInt(path) as bool
endFunction

int function GetIntOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JDB.solveInt(path)
endFunction

float function GetFloatOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JDB.solveFlt(path)
endFunction

string function GetStringOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JDB.solveStr(path)
endFunction

Form function GetFormOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JDB.solveForm(path)
endFunction

int[] function GetIntsOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JArray.asIntArray(JDB.solveObj(path))
endFunction

float[] function GetFloatsOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JArray.asFloatArray(JDB.solveObj(path))
endFunction

string[] function GetStringsOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JArray.asStringArray(JDB.solveObj(path))
endFunction

Form[] function GetFormsOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JArray.asFormArray(JDB.solveObj(path))
endFunction

;                          Setters

function SetBoolOnReference(string asKey, string apReference, bool abValue, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    JDB.solveIntSetter(path, abValue as int, true)
endFunction

function SetIntOnReference(string asKey, string apReference, int aiValue, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    JDB.solveIntSetter(path, aiValue, true)
endFunction

function SetFloatOnReference(string asKey, string apReference, float afValue, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    JDB.solveFltSetter(path, afValue, true)
endFunction

function SetStringOnReference(string asKey, string apReference, string asValue, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    JDB.solveStrSetter(path, asValue, true)
endFunction

function SetFormOnReference(string asKey, string apReference, Form akValue, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    JDB.solveFormSetter(path, akValue, true)
endFunction

function SetIntsOnReference(string asKey, string apReference, int[] aiValues, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    int formToObject = JArray.objectWithInts(aiValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetFloatsOnReference(string asKey, string apReference, float[] afValues, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    int formToObject = JArray.objectWithFloats(afValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetStringsOnReference(string asKey, string apReference, string[] asValues, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    int formToObject = JArray.objectWithStrings(asValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

function SetFormsOnReference(string asKey, string apReference, Form[] akValues, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    int formToObject = JArray.objectWithForms(akValues)
    JDB.solveObjSetter(path, formToObject, true)
endFunction

;                          Modifiers
function ModIntOnReference(string asKey, string apReference, int aiValue, string asCategory = "null") global
    int currentValue = GetIntOnReference(asKey, apReference, asCategory)
    SetIntOnReference(asKey, apReference, currentValue + aiValue, asCategory)
endFunction

function ModFloatOnReference(string asKey, string apReference, float afValue, string asCategory = "null") global
    float currentValue = GetFloatOnReference(asKey, apReference, asCategory)
    SetFloatOnReference(asKey, apReference, currentValue + afValue, asCategory)
endFunction

;                     Delete Functions

function DeleteVariableOnReference(string asKey, string apReference, string asCategory = "null") global
    int obj = GetObjectHandleOnKey(apReference, asCategory)
    JMap.removeKey(obj, asKey)
endFunction

function DeleteCategoryOnReference(string apReference, string asCategory) global
    int deletedObj = GetObjectHandleOnKey(apReference)
    JMap.removeKey(deletedObj, asCategory)
endFunction

function DeleteAllOnReference(string apReference) global
    int deletedObj = GetObjectHandleOnKey(apReference)
    JMap.clear(deletedObj)
    JMap.removeKey(GetObjectHandle(), apReference as string)
endFunction

bool function HasVarOnReference(string asKey, string apReference, string asCategory = "null") global
    string path = GetVarPathOnReference(asKey, apReference, asCategory)
    return JDB.hasPath(path)
endFunction

bool function HasVarsOnReference(string apReference, string asCategory = "null") global
    string path = GetRootPath() + "." + apReference as string
    return JDB.hasPath(path)
endFunction

; ==========================================================
;                         Listing
; ==========================================================

string function GetList(string asCategory = "null") global
    return GetContainerList(GetObjectHandle(asCategory))
endFunction

string function GetListOnForm(Form akForm, string asCategory = "null") global
    return GetContainerList(GetObjectHandleOnForm(akForm, asCategory))
endFunction

; ==========================================================
;                        Serialization
; ==========================================================

function Serialize(string asFilePath, string asCategory = "null") global
    int obj = GetObjectHandle(asCategory)
    JValue.writeToFile(obj, asFilePath)
endFunction

function SerializeForm(string asFilePath, Form akForm, string asCategory = "null") global
    int obj = GetObjectHandleOnForm(akForm, asCategory)
    JValue.writeToFile(obj, asFilePath)
endFunction

int function Unserialize(string asFilePath, string asCategory = "null") global
    int rootObj = JValue.readFromFile(asFilePath)

    if (JValue.empty(rootObj))
        return 0
    endif

    if (asCategory == "null" || asCategory == "")
        return rootObj
    endif

    int objWithCategory = JMap.getObj(rootObj, asCategory)

    return objWithCategory
endFunction

int function UnserializeForm(string asFilePath, Form akForm, string asCategory = "null") global
    int rootObj = JValue.readFromFile(asFilePath)
    rootObj     = JMap.getObj(rootObj, akForm.GetFormID())

    if (JValue.empty(rootObj))
        return 0
    endif

    if (asCategory == "null" || asCategory == "")
        return rootObj
    endif

    ; rootObj is now the Form specific container, get the category inside that
    int objWithCategory = JMap.getObj(rootObj, asCategory)

    return objWithCategory
endFunction


bool function HasOverride(string asParamKey) global

endFunction

string function GetKeyInUse(string asParamKey, bool abAllowOverriding) global

endFunction