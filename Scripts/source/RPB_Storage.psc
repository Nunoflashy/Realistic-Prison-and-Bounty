scriptname RPB_Storage extends ObjectReference hidden

import RPB_Utility

; ==========================================================
;                        Normal Vars
; ==========================================================

;                          Getters
; ==========================================================

;                          Setters
; ==========================================================

;                         Modifiers
; ==========================================================

;                          Delete
; ==========================================================

;                         Existence
; ==========================================================



; ==========================================================
;                       Form Specific
; ==========================================================

;                          Getters
; ==========================================================

bool function GetBoolOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JValue.solveInt(__rootObject, path) as bool
endFunction

int function GetIntOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = self.__getVarPathOnForm(asKey, akForm, asCategory)
    return JValue.solveInt(__rootObject, path)
endFunction

float function GetFloatOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JValue.solveFlt(__rootObject, path)
endFunction

string function GetStringOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JValue.solveStr(__rootObject, path)
endFunction

Form function GetFormOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    ; Debug(none, "StorageVars::GetFormOnForm", "path: " + path + ", value: " + JValue.solveForm(__rootObject, path))

    return JValue.solveForm(__rootObject, path)
endFunction

int[] function GetIntsOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asIntArray(JValue.solveObj(__rootObject, path))
endFunction

float[] function GetFloatsOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asFloatArray(JValue.solveObj(__rootObject, path))
endFunction

string[] function GetStringsOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asStringArray(JValue.solveObj(__rootObject, path))
endFunction

Form[] function GetFormsOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JArray.asFormArray(JValue.solveObj(__rootObject, path))
endFunction

;                          Setters
; ==========================================================

function SetBoolOnForm(string asKey, Form akForm, bool abValue, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    JValue.solveIntSetter(__rootObject, path, abValue as int, true)
endFunction

function SetIntOnForm(string asKey, Form akForm, int aiValue, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    JValue.solveIntSetter(__rootObject, path, aiValue, true)
endFunction

function SetFloatOnForm(string asKey, Form akForm, float afValue, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    JValue.solveFltSetter(__rootObject, path, afValue, true)
endFunction

function SetStringOnForm(string asKey, Form akForm, string asValue, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    JValue.solveStrSetter(__rootObject, path, asValue, true)
endFunction

function SetFormOnForm(string asKey, Form akForm, Form akValue, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    
    JValue.solveFormSetter(__rootObject, path, akValue, true)
    ; Debug(none, "StorageVars::SetFormOnForm", "path: " + path + ", value: " + JValue.solveForm(__rootObject, path))
endFunction

function SetIntsOnForm(string asKey, Form akForm, int[] aiValues, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithInts(aiValues)
    JValue.solveObjSetter(__rootObject, path, formToObject, true)
endFunction

function SetFloatsOnForm(string asKey, Form akForm, float[] afValues, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithFloats(afValues)
    JValue.solveObjSetter(__rootObject, path, formToObject, true)
endFunction

function SetStringsOnForm(string asKey, Form akForm, string[] asValues, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithStrings(asValues)
    JValue.solveObjSetter(__rootObject, path, formToObject, true)
endFunction

function SetFormsOnForm(string asKey, Form akForm, Form[] akValues, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    int formToObject = JArray.objectWithForms(akValues)
    JValue.solveObjSetter(__rootObject, path, formToObject, true)
endFunction

;                         Modifiers
; ==========================================================

function ModIntOnForm(string asKey, Form akForm, int aiValue, string asCategory = "null")
    int currentValue = GetIntOnForm(asKey, akForm, asCategory)
    SetIntOnForm(asKey, akForm, currentValue + aiValue, asCategory)
endFunction

function ModFloatOnForm(string asKey, Form akForm, float afValue, string asCategory = "null")
    float currentValue = GetFloatOnForm(asKey, akForm, asCategory)
    SetFloatOnForm(asKey, akForm, currentValue + afValue, asCategory)
endFunction


;                          Delete
; ==========================================================

function DeleteVariableOnForm(string asKey, Form akForm, string asCategory = "null")
    ; string path = __getVarPathOnForm(asKey, akForm, asCategory)
    ; JValue.solveObjSetter(__rootObject, path, 0)
    int obj = __getObjectHandleOnForm(akForm, asCategory)
    JMap.removeKey(obj, asKey)
endFunction

function DeleteCategoryOnForm(Form akForm, string asCategory)
    ; string path = __getCategoryPathOnForm(akForm, asCategory)
    ; JValue.solveObjSetter(__rootObject, path, 0)
    int deletedObj = __getObjectHandleOnForm(akForm)
    JMap.removeKey(deletedObj, asCategory)
endFunction

function DeleteAllOnForm(Form akForm)
    ; string path = GetFormPath(akForm)
    ; JValue.solveObjSetter(__rootObject, path, 0, true)
    int deletedObj = __getObjectHandleOnForm(akForm)
    JMap.clear(deletedObj)
    JMap.removeKey(__getObjectHandle(), akForm.GetFormID())
endFunction

;                         Existence
; ==========================================================

bool function HasVarOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = __getVarPathOnForm(asKey, akForm, asCategory)
    return JValue.hasPath(__rootObject, path)
endFunction

bool function HasVarsOnForm(Form akForm, string asCategory = "null")
    int formId  = akForm.GetFormID()
    string path = __getRootPath() + "."+ formId

    return JValue.hasPath(__rootObject, path)
endFunction


; ==========================================================
;                          private
; ==========================================================

int __rootObject ; JMap&

string function __getRootPath()
    return ".rpb_root.storage"
endFunction

int function __getObjectHandle(string asCategory = "null") 
    if (asCategory != "null" && asCategory != "")
        return JValue.solveObj(__rootObject, __getRootPath() + "." + asCategory)
    endif

    return JValue.solveObj(__rootObject, __getRootPath())
endFunction

int function __getObjectHandleOnForm(Form akForm, string asCategory = "null")
    if (asCategory != "null" && asCategory != "")
        return JValue.solveObj(__rootObject, __getRootPath() + "." + akForm.GetFormID() + "." + asCategory)
    endif

    return JValue.solveObj(__rootObject, __getRootPath() + "." + akForm.GetFormID())
endFunction

int function __getObjectHandleOnKey(string asKey, string asCategory = "null")
    if (asCategory != "null" && asCategory != "")
        return JValue.solveObj(__rootObject, __getRootPath() + "." + asKey + "." + asCategory)
    endif

    return JValue.solveObj(__rootObject, __getRootPath() + "." + asKey)
endFunction

string function __getVarPath(string asKey, string asCategory = "null")
    string path = none
    
    if (asCategory != "null" && asCategory != "")
        path = __getRootPath() + "." + asCategory + "." + asKey
    else
        path = __getRootPath() + "." + asKey
    endif

    return path
endFunction

string function __getCategoryPath(string asCategory)
    return __getRootPath() + "." + asCategory
endFunction

string function __getVarPathOnForm(string asKey, Form akForm, string asCategory = "null")
    string path = none
    
    if (asCategory != "null" && asCategory != "")
        path = __getRootPath() + "." + akForm.GetFormID() + "." + asCategory + "." + asKey
    else
        path = __getRootPath() + "." + akForm.GetFormID() + "." + asKey
    endif

    return path
endFunction

event OnInit()
    if (!__rootObject)
        __rootObject = JMap.object()
        JValue.retain(__rootObject)
    endif

    Debug("Storage::OnInit", "Initialized root object: " + __rootObject)
endEvent