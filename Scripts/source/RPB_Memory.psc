scriptname RPB_Memory hidden

bool function __isTypeSafe(int object) global
    return JValue.isMap(object) && JMap.hasKey(object, "data")
endFunction

int function __retainObjectInMemory(int object, bool retain = true) global
    if (retain)
        JValue.retain(object, "RPB_MEMORY")
    endif

    return object
endFunction

function __releaseAll() global
    JValue.releaseObjectsWithTag("RPB_MEMORY")
endFunction

bool function Object_IsTypeSafe(int object) global
    return JValue.isMap(object) && JMap.hasKey(object, "data")
endFunction

bool function Object_IsArray(int object) global
    return (__isTypeSafe(object) && JValue.isArray(__getDataObject(object))) || (!__isTypeSafe(object) && JValue.isArray(object))
endFunction

bool function Object_IsMap(int object) global
    return (__isTypeSafe(object) && JValue.isMap(__getDataObject(object))) || (!__isTypeSafe(object) && JValue.isMap(object))
endFunction

bool function Object_IsFormMap(int object) global
    return (__isTypeSafe(object) && JValue.isFormMap(__getDataObject(object))) || (!__isTypeSafe(object) && JValue.isFormMap(object))
endFunction

bool function Object_IsIntMap(int object) global
    return (__isTypeSafe(object) && JValue.isIntegerMap(__getDataObject(object))) || (!__isTypeSafe(object) && JValue.isIntegerMap(object))
endFunction

int function Object_ReadData(string filepath) global
    return JValue.readFromFile(filepath)
endFunction

int function Object_Conditionally(int object, bool condition) global
    if (condition)
        return object
    endif

    return -1
endFunction

function Object_WriteData(int object, string filepath) global
    int data = object

    if (__isTypeSafe(object))
        data = __getDataObject(object)
        ; TODO: Iterate through possible child objects and strip them of their metadata and other objects excluding data
    endif

    JValue.writeToFile(data, filepath)
endFunction

int function Object_FromJSON(string json) global
    ; TODO: Check if JSON is valid, parse the JSON to determine the signature of the object and construct a Memory object from the value
    return JValue.objectFromPrototype(json)
endFunction

; ==========================================================
;                       Static Storage
; ==========================================================

int function StaticStorage() global
    string rootPath = ".rpb_root"
    return JDB.solveObj(rootPath)
endFunction

; ==========================================================
;                         Generic
; ==========================================================

int function Object_Size(int object) global
    int data = object

    if (__isTypeSafe(object))
        data = __getDataObject(object)
    endif

    return JValue.count(data)
endFunction

int function Size(int object) global
    return Object_Size(object)
endFunction

; Clears the object's data (does not clear metadata)
function Object_Clear(int object) global
    int data = object

    if (__isTypeSafe(object))
        data = __getDataObject(object)
    endif

    JValue.clear(data)
endFunction

bool function Object_Empty(int object) global
    ; Handle the various ways an object could be considered empty
    ; For now, return the simple isEmpty()

    int data = object

    if (__isTypeSafe(object))
        data = __getDataObject(object)
    endif

    return JValue.count(data) == 0
endFunction

; ==========================================================
;                    Fast Data Structures
; ==========================================================
;/
    Data structures that are not type safe, do not contain additional checks,
    do not throw exceptions and dont have any additional functionality.

    Essentially a wrapper for the JContainer classes, for now, to avoid tight coupling.

    - FastArray
    - FastMap
/;

int function FastArray(string elements = "", bool retain = false) global
    int obj = JArray.object()
    return __retainObjectInMemory(obj, retain)
endFunction

int function FastMap(string keyType = "<string>", bool retain = false) global
    int obj = -1

    if (keyType == "<string>")
        obj = JMap.object()

    elseif (keyType == "<int>")
        obj = JIntMap.object()

    elseif (keyType == "<Form>")
        obj = JFormMap.object()

    else
        return -1
    endif

    __retainObjectInMemory(obj, retain)
    return obj
endFunction


; ==========================================================
;                         Fast Array
; ==========================================================

int function FastArray_Size(int array) global
    return Object_Size(array)
endFunction

bool function FastArray_Empty(int array) global
    return FastArray_Size(array) <= 0
endFunction

function FastArray_Clear(int array) global
    Object_Clear(array)
endFunction

function FastArray_SetInt(int array, int index, int element) global
    JArray.setInt(array, index, element)
endFunction

function FastArray_SetFloat(int array, int index, float element) global
    JArray.setFlt(array, index, element)
endFunction

function FastArray_SetString(int array, int index, string element) global
    JArray.setStr(array, index, element)
endFunction

function FastArray_SetObject(int array, int index, int element) global
    JArray.setObj(array, index, element)
endFunction

function FastArray_SetForm(int array, int index, Form element) global
    JArray.setForm(array, index, element)
endFunction

function FastArray_AddInt(int array, int element) global
    JArray.addInt(array, element)
endFunction

function FastArray_AddFloat(int array, float element) global
    JArray.addFlt(array, element)
endFunction

function FastArray_AddString(int array, string element) global
    JArray.addStr(array, element)
endFunction

function FastArray_AddObject(int array, int element) global
    JArray.addObj(array, element)
endFunction

function FastArray_AddForm(int array, Form element) global
    JArray.addForm(array, element)
endFunction

function FastArray_AddFromArray(int array, int otherArray) global
    JArray.addFromArray(array, otherArray)
endFunction

int function FastArray_GetInt(int array, int index) global
    return JArray.getInt(array, index)
endFunction

float function FastArray_GetFloat(int array, int index) global
    return JArray.getFlt(array, index)
endFunction

string function FastArray_GetString(int array, int index) global
    return JArray.getStr(array, index)
endFunction

Form function FastArray_GetForm(int array, int index) global
    return JArray.getForm(array, index)
endFunction

int function FastArray_GetObject(int array, int index) global
    return JArray.getObj(array, index)
endFunction

int function FastArray_FindInt(int array, int elementToSearch) global
    return JArray.findInt(array, elementToSearch)
endFunction

int function FastArray_FindString(int array, string elementToSearch) global
    return JArray.findStr(array, elementToSearch)
endFunction

int function FastArray_FindForm(int array, Form elementToSearch) global
    return JArray.findForm(array, elementToSearch)
endFunction

int function FastArray_FindObject(int array, int elementToSearch) global
    return JArray.findObj(array, elementToSearch)
endFunction

function FastArray_Remove(int array, int index) global
    JArray.eraseIndex(array, index)
endFunction

int[] function FastArray_ToIntArray(int array) global
    return JArray.asIntArray(array)
endFunction

float[] function FastArray_ToFloatArray(int array) global
    return JArray.asFloatArray(array)
endFunction

string[] function FastArray_ToStringArray(int array) global
    return JArray.asStringArray(array)
endFunction

Form[] function FastArray_ToFormArray(int array) global
    return JArray.asFormArray(array)
endFunction

int function FastArray_FromBoolArray(bool[] array) global
    return JArray.objectWithBooleans(array)
endFunction

int function FastArray_FromIntArray(int[] array) global
    return JArray.objectWithInts(array)
endFunction

int function FastArray_FromFloatArray(float[] array) global
    return JArray.objectWithFloats(array)
endFunction

string function FastArray_FromStringArray(string[] array) global
    return JArray.objectWithStrings(array)
endFunction

int function FastArray_FromFormArray(Form[] array) global
    return JArray.objectWithForms(array)
endFunction

; ==========================================================
;                          Fast Map
; ==========================================================

int function FastMap_Size(int map) global
    return Object_Size(map)
endFunction

bool function FastMap_Empty(int map) global
    return FastMap_Size(map) <= 0
endFunction

function FastMap_Clear(int map) global
    JValue.clear(map)
endFunction

string function FastMap_GetNthKey(int map, int index) global
    return JMap.getNthKey(map, index)
endFunction

bool function FastMap_HasKey(int map, string _key) global
    return JMap.hasKey(map, _key)
endFunction

bool function FastMap_RemoveKey(int map, string _key) global
    return JMap.removeKey(map, _key)
endFunction

int function FastMap_Values(int map) global
    return JMap.allValues(map)
endFunction

int function FastMap_Keys(int map) global
    return JMap.allKeys(map)
endFunction

string[] function FastMap_KeysAsPapyrusArray(int map) global
    return JMap.allKeysPArray(map)
endFunction

string function FastMap_KeyFromValueString(int map, string value) global
    int _values = FastMap_Values(map)

    int i = 0
    while (i < FastArray_Size(_values))
        if (FastArray_GetString(_values, i) == value)
            return FastMap_GetNthKey(map, i)
        endif
        i += 1
    endWhile

    return ""
endFunction

string function FastMap_GetString(int map, string _key) global
    return JMap.getStr(map, _key)
endFunction

int function FastMap_GetInt(int map, string _key) global
    return JMap.getInt(map, _key)
endFunction

float function FastMap_GetFloat(int map, string _key) global
    return JMap.getFlt(map, _key)
endFunction

Form function FastMap_GetForm(int map, string _key) global
    return JMap.getForm(map, _key)
endFunction

int function FastMap_GetObject(int map, string _key) global
    return JMap.getObj(map, _key)
endFunction

int function FastMap_GetObjectOfType(int map, string objectType, string _key) global
    return JMap.getObj(map, _key)
endFunction

string function FastMap_SetString(int map, string _key, string value, bool condition = true) global
    if (condition)
        JMap.setStr(map, _key, value)
    endif
    
    return value
endFunction

int function FastMap_SetInt(int map, string _key, int value, bool condition = true) global
    if (condition)
        JMap.setInt(map, _key, value)
    endif
    
    return value
endFunction

float function FastMap_SetFloat(int map, string _key, float value, bool condition = true) global
    if (condition)
        JMap.setFlt(map, _key, value)
    endif
    
    return value
endFunction

Form function FastMap_SetForm(int map, string _key, Form value, bool condition = true) global
    if (condition)
        JMap.setForm(map, _key, value)
    endif
    
    return value
endFunction

int function FastMap_SetObject(int map, string _key, int value, bool condition = true) global
    if (condition)
        JMap.setObj(map, _key, value)
    endif
    
    return JMap.getObj(map, _key)
endFunction

; Integer Map (Temporary, maybe)
; ==========================================================

string function FastIntMap_GetNthKey(int map, int index) global
    return JIntMap.getNthKey(map, index)
endFunction

bool function FastIntMap_HasKey(int map, int _key) global
    return JIntMap.hasKey(map, _key)
endFunction

bool function FastIntMap_RemoveKey(int map, int _key) global
    return JIntMap.removeKey(map, _key)
endFunction

int function FastIntMap_Values(int map) global
    return JIntMap.allValues(map)
endFunction

int function FastIntMap_Keys(int map) global
    return JIntMap.allKeys(map)
endFunction

int[] function FastIntMap_KeysAsPapyrusArray(int map) global
    return JIntMap.allKeysPArray(map)
endFunction

string function FastIntMap_GetString(int map, int _key) global
    return JIntMap.getStr(map, _key)
endFunction

int function FastIntMap_GetInt(int map, int _key) global
    return JIntMap.getInt(map, _key)
endFunction

float function FastIntMap_GetFloat(int map, int _key) global
    return JIntMap.getFlt(map, _key)
endFunction

Form function FastIntMap_GetForm(int map, int _key) global
    return JIntMap.getForm(map, _key)
endFunction

int function FastIntMap_GetObject(int map, int _key) global
    return JIntMap.getObj(map, _key)
endFunction

function FastIntMap_SetString(int map, int _key, string value) global
    JIntMap.setStr(map, _key, value)
endFunction

function FastIntMap_SetInt(int map, int _key, int value) global
    JIntMap.setInt(map, _key, value)
endFunction

function FastIntMap_SetFloat(int map, int _key, float value) global
    JIntMap.setFlt(map, _key, value)
endFunction

function FastIntMap_SetForm(int map, int _key, Form value) global
    JIntMap.setForm(map, _key, value)
endFunction

function FastIntMap_SetObject(int map, int _key, int value) global
    JIntMap.setObj(map, _key, value)
endFunction

; ==========================================================
;                       Data Structures
; ==========================================================

;  CONSTRUCTORS
; ==========================================================

int function Array(string signature, string elements = "", bool retain = false) global
    int obj = __makeParent()

    int data        = __writeData(obj, JArray.object())
    ; int metadata    = __writeMetadata(obj, "array")

    if (retain)
        JValue.retain(obj, "memory")
    endif

    string[] splitValues        = StringUtil.Split(elements, ",")
    string[] splitKeys          = StringUtil.Split(elements, ", ")
    string[] splitKeyPrefixes   = StringUtil.Split(elements, ", ")
    string[] splitKeySuffixes   = StringUtil.Split(elements, ", ")
    string[] splitValuePrefixes = StringUtil.Split(elements, ", ")
    string[] splitValueSuffixes = StringUtil.Split(elements, ", ")

    if (elements)
        string[] splitElements = StringUtil.Split(elements, ", ")

        int elementIndex = 0
        while (elementIndex < splitElements.Length)
            JArray.addStr(data, splitElements[elementIndex])
        endWhile
    endif

    return obj
endFunction

int function Object(string signature, string params = "") global
endFunction

int function Map(string signature, bool retain = false) global
    int obj = __makeParent()

    int mapObj
    if (signature == "<string>")
        mapObj = JMap.object()

    elseif (signature == "<int>")
        mapObj = JIntMap.object()

    elseif (signature == "<Form>")
        mapObj = JFormMap.object()
    endif

    __writeData(obj, mapObj)
    __writeMetadata(obj, "map")

    if (retain)
        JValue.retain(obj, "memory")
    endif

    return obj
endFunction

int function Queue(string signature, bool retain = false) global
    int obj = __makeParent()
    __writeData(obj, JArray.object())
    __writeMetadata(obj, "queue")
    __retainObjectInMemory(obj, retain)
    return obj
endFunction

int function Deque(string signature, bool retain = false) global
    int obj = __makeParent()
    __writeData(obj, JArray.object())
    __writeMetadata(obj, "deque")
    __retainObjectInMemory(obj, retain)
    return obj
endFunction

int function Stack(string signature, bool retain = false) global
    if (!__parseSignature(signature, "stack"))
        return throwAndReturn(__invalidObject(), InvalidObjectException("Invalid signature for a stack data structure! (" + signature + ")"))
    endif

    int obj = JMap.object() ; parent object

    __writeData(obj, JArray.object())
    __writeMetadata(obj, "stack")

    __retainObjectInMemory(obj, retain)
    return obj
endFunction

int function Pair(string signature = "", bool retain = false) global
    if (!__parseSignature(signature, "pair"))
        return throwAndReturn(__invalidObject(), InvalidObjectException("Invalid signature for a pair data structure! (" + signature + ")"))
    endif

    int obj = __makeParent()
    __writeData(obj, FastArray())
    __writeMetadata(obj, "pair")
    __retainObjectInMemory(obj, retain)
    return obj
endFunction

int function Vector(string signature, bool retain = false) global
    if (!__parseSignature(signature, "vector"))
        return throwAndReturn(__invalidObject(), InvalidObjectException("Invalid signature for a vector data structure! (" + signature + ")"))
    endif

    int obj = __makeParent()
    __writeData(obj, FastArray())
    __writeMetadata(obj, "vector")
    __retainObjectInMemory(obj, retain)
    return obj
endFunction

int function Delete(int object) global
    return JValue.release(object)
endFunction


; ==========================================================
;                          Array
; ==========================================================

int function Array_Size(int array) global
    return Object_Size(array)
endFunction

bool function Array_Empty(int array) global
    return Array_Size(array) <= 0
endFunction

function Array_Clear(int array) global
    int data = __getDataObject(array)
    JValue.clear(data)
endFunction

int function Array_FromObject(int object) global
    int obj = __makeParent()
    JMap.setObj(obj, "data", object)

    return obj
endFunction

function Array_AddInt(int array, int element) global
    int data = __getDataObject(array)
    JArray.addInt(data, element)
endFunction

function Array_AddString(int array, string element) global
    int data = __getDataObject(array)
    JArray.addStr(data, element)
endFunction

function Array_AddObject(int array, int element) global
    int data = __getDataObject(array)
    JArray.addObj(data, element)
endFunction

function Array_AddForm(int array, Form element) global
    int data = __getDataObject(array)
    JArray.addForm(data, element)
endFunction

int function Array_GetInt(int array, int index) global
    int data = __getDataObject(array)

    ; if (index >= GetSize(data) || index < 0)
    ;     throw(array, IndexOutOfBoundsException("The index has gone out of the bounds of the array!"))
    ;     return -1
    ; endif
    
    return JArray.getInt(data, index)
endFunction

int function Array_FindInt(int array, int elementToSearch) global
    int data = __getDataObject(array)
    return JArray.findInt(data, elementToSearch)
endFunction

string function Array_GetString(int array, int index) global
    int data = __getDataObject(array)
    return JArray.getStr(data, index)
endFunction

Form function Array_GetForm(int array, int index) global
    int data = __getDataObject(array)
    return JArray.getForm(data, index)
endFunction


int function Array_GetObject(int array, int index) global
    int data = __getDataObject(array)
    
    int obj = __makeParent()
    JMap.setObj(obj, "data", data)
    return JMap.getObj(obj, index)
endFunction

function Array_Remove(int array, int index) global
    int data = __getDataObject(array)
    JArray.eraseIndex(data, index)
endFunction

Form[] function Array_ToPapyrusFormArray(int array) global
    int data = __getDataObject(array)
    return JArray.asFormArray(array)
endFunction

; ==========================================================
;                           Map
; ==========================================================

int function Map_Size(int map) global
    return Object_Size(map)
endFunction

bool function Map_Empty(int map) global
    return Map_Size(map) <= 0
endFunction

function Map_Clear(int map) global
    int data = __getDataObject(map)
    JValue.clear(data)
endFunction

string function Map_GetNthKey(int map, int index) global
    int data = __getDataObject(map)
    return JMap.getNthKey(data, index)
endFunction

bool function Map_HasKey(int map, string _key) global
    int data = __getDataObject(map)
    return JMap.hasKey(data, _key)
endFunction

bool function Map_RemoveKey(int map, string _key) global
    int data = __getDataObject(map)
    return JMap.removeKey(data, _key)
endFunction

int function Map_Values(int map) global
    int data = __getDataObject(map)
    return __toBaseObject(JMap.allValues(data))
endFunction

int function Map_Keys(int map) global
    int data = __getDataObject(map)
    return __toBaseObject(JMap.allKeys(data))
endFunction

string[] function Map_KeysAsPapyrusArray(int map) global
    int data = __getDataObject(map)
    return JMap.allKeysPArray(data)
endFunction

string function Map_GetString(int map, string _key) global
    int data = __getDataObject(map)
    return JMap.getStr(data, _key)
endFunction

int function Map_GetInt(int map, string _key) global
    int data = __getDataObject(map)
    return JMap.getInt(data, _key)
endFunction

float function Map_GetFloat(int map, string _key) global
    int data = __getDataObject(map)
    return JMap.getFlt(data, _key)
endFunction

Form function Map_GetForm(int map, string _key) global
    int data = __getDataObject(map)
    return JMap.getForm(data, _key)
endFunction

int function Map_GetObject(int map, string _key) global
    int data = __getDataObject(map)
    return __toBaseObject(JMap.getObj(data, _key))
endFunction

int function Map_GetObjectOfType(int map, string objectType, string _key) global
    int data = __getDataObject(map)
    return JMap.getObj(data, _key)
endFunction

function Map_SetString(int map, string _key, string value) global
    int data = __getDataObject(map)
    JMap.setStr(data, _key, value)
endFunction

function Map_SetInt(int map, string _key, int value) global
    int data = __getDataObject(map)
    JMap.setInt(data, _key, value)
endFunction

function Map_SetFloat(int map, string _key, float value) global
    int data = __getDataObject(map)
    JMap.setFlt(data, _key, value)
endFunction

function Map_SetForm(int map, string _key, Form value) global
    int data = __getDataObject(map)
    JMap.setForm(data, _key, value)
endFunction

function Map_SetObject(int map, string _key, int value) global
    int data = __getDataObject(map)
    JMap.setObj(data, _key, value)
    ; RPB_Utility.DebugWithArgs("Memory::Map_SetObject", "map: " + map + ", key: " + _key + ", value: " + value, RPB_Utility.GetContainerList(map))
endFunction

; Integer Map (Temporary, maybe)
; ==========================================================

string function IntMap_GetNthKey(int map, int index) global
    int data = __getDataObject(map)
    return JIntMap.getNthKey(data, index)
endFunction

bool function IntMap_HasKey(int map, int _key) global
    int data = __getDataObject(map)
    return JIntMap.hasKey(data, _key)
endFunction

bool function IntMap_RemoveKey(int map, int _key) global
    int data = __getDataObject(map)
    return JIntMap.removeKey(data, _key)
endFunction

int function IntMap_Values(int map) global
    int data = __getDataObject(map)
    return __toBaseObject(JIntMap.allValues(data))
endFunction

int function IntMap_Keys(int map) global
    int data = __getDataObject(map)
    return __toBaseObject(JIntMap.allKeys(data))
endFunction

int[] function IntMap_KeysAsPapyrusArray(int map) global
    int data = __getDataObject(map)
    return JIntMap.allKeysPArray(data)
endFunction

string function IntMap_GetString(int map, int _key) global
    int data = __getDataObject(map)
    return JIntMap.getStr(data, _key)
endFunction

int function IntMap_GetInt(int map, int _key) global
    int data = __getDataObject(map)
    return JIntMap.getInt(data, _key)
endFunction

float function IntMap_GetFloat(int map, int _key) global
    int data = __getDataObject(map)
    return JIntMap.getFlt(data, _key)
endFunction

Form function IntMap_GetForm(int map, int _key) global
    int data = __getDataObject(map)
    return JIntMap.getForm(data, _key)
endFunction

int function IntMap_GetObject(int map, int _key) global
    int data = __getDataObject(map)
    return __toBaseObject(JIntMap.getObj(data, _key))
endFunction

int function IntMap_GetObjectOfType(int map, string objectType, int _key) global
    int data = __getDataObject(map)
    return JIntMap.getObj(data, _key)
endFunction

function IntMap_SetString(int map, int _key, string value) global
    int data = __getDataObject(map)
    JIntMap.setStr(data, _key, value)
endFunction

function IntMap_SetInt(int map, int _key, int value) global
    int data = __getDataObject(map)
    JIntMap.setInt(data, _key, value)
endFunction

function IntMap_SetFloat(int map, int _key, float value) global
    int data = __getDataObject(map)
    JIntMap.setFlt(data, _key, value)
endFunction

function IntMap_SetForm(int map, int _key, Form value) global
    int data = __getDataObject(map)
    JIntMap.setForm(data, _key, value)
endFunction

function IntMap_SetObject(int map, int _key, int value) global
    int data = __getDataObject(map)
    JIntMap.setObj(data, _key, value)
endFunction

; ==========================================================
;                           Deque
; ==========================================================

int function Deque_Size(int deque) global
    return Object_Size(deque)
endFunction

bool function Deque_Empty(int deque) global
    return Deque_Size(deque) <= 0
endFunction

function Deque_Clear(int deque) global
    int data = __getDataObject(deque)
    JArray.clear(data)
endFunction

function Deque_PushFrontInt(int deque, int value) global
    int data = __getDataObject(deque)
    JArray.addInt(data, value, 0)
endFunction

function Deque_PushFrontFloat(int deque, float value) global
    int data = __getDataObject(deque)
    JArray.addFlt(data, value, 0)
endFunction

function Deque_PushFrontString(int deque, string value) global
    int data = __getDataObject(deque)
    JArray.addStr(data, value, 0)
endFunction

function Deque_PushFrontForm(int deque, Form value) global
    int data = __getDataObject(deque)
    JArray.addForm(data, value, 0)
endFunction

function Deque_PushFrontObject(int deque, int value) global
    int data = __getDataObject(deque)
    JArray.addObj(data, value, 0)
endFunction

function Deque_PushBackInt(int deque, int value) global
    int data = __getDataObject(deque)
    JArray.addInt(data, value, -1)
endFunction

function Deque_PushBackFloat(int deque, float value) global
    int data = __getDataObject(deque)
    JArray.addFlt(data, value, -1)
endFunction

function Deque_PushBackString(int deque, string value) global
    int data = __getDataObject(deque)
    JArray.addStr(data, value, -1)
endFunction

function Deque_PushBackForm(int deque, Form value) global
    int data = __getDataObject(deque)
    JArray.addForm(data, value, -1)
endFunction

function Deque_PushBackObject(int deque, int value) global
    int data = __getDataObject(deque)
    JArray.addObj(data, value, -1)
endFunction

function Deque_PopFront(int deque) global
    int data = __getDataObject(deque)
    JArray.eraseIndex(data, 0)
endFunction

function Deque_PopBack(int deque) global
    int data = __getDataObject(deque)
    JArray.eraseIndex(data, -1)
endFunction

int function Deque_PopFrontInt(int deque) global
    int data = __getDataObject(deque)

    int value = JArray.getInt(data, 0)
    JArray.eraseIndex(data, 0)
    return value
endFunction

float function Deque_PopFrontFloat(int deque) global
    int data = __getDataObject(deque)

    float value = JArray.getFlt(data, 0)
    JArray.eraseIndex(data, 0)
    return value
endFunction

string function Deque_PopFrontString(int deque) global
    int data = __getDataObject(deque)

    string value = JArray.getStr(data, 0)
    JArray.eraseIndex(data, 0)
    return value
endFunction

Form function Deque_PopFrontForm(int deque) global
    int data = __getDataObject(deque)

    Form value = JArray.getForm(data, 0)
    JArray.eraseIndex(data, 0)
    return value
endFunction

int function Deque_PopFrontObject(int deque) global
    int data = __getDataObject(deque)

    int value = JArray.getObj(data, 0)
    JArray.eraseIndex(data, 0)
    return value
endFunction

int function Deque_PopBackInt(int deque) global
    int data = __getDataObject(deque)

    int value = JArray.getInt(data, -1)
    JArray.eraseIndex(data, -1)
    return value
endFunction

float function Deque_PopBackFloat(int deque) global
    int data = __getDataObject(deque)

    float value = JArray.getFlt(data, -1)
    JArray.eraseIndex(data, -1)
    return value
endFunction

string function Deque_PopBackString(int deque) global
    int data = __getDataObject(deque)

    string value = JArray.getStr(data, -1)
    JArray.eraseIndex(data, -1)
    return value
endFunction

Form function Deque_PopBackForm(int deque) global
    int data = __getDataObject(deque)

    Form value = JArray.getForm(data, -1)
    JArray.eraseIndex(data, -1)
    return value
endFunction

int function Deque_PopBackObject(int deque) global
    int data = __getDataObject(deque)

    int value = JArray.getObj(data, -1)
    JArray.eraseIndex(data, -1)
    return value
endFunction

int function Deque_FrontInt(int deque) global
    int data = __getDataObject(deque)
    return JArray.getInt(data, 0)
endFunction

float function Deque_FrontFloat(int deque) global
    int data = __getDataObject(deque)
    return JArray.getFlt(data, 0)
endFunction

string function Deque_FrontString(int deque) global
    int data = __getDataObject(deque)
    return JArray.getStr(data, 0)
endFunction

Form function Deque_FrontForm(int deque) global
    int data = __getDataObject(deque)
    return JArray.getForm(data, 0)
endFunction

int function Deque_FrontObject(int deque) global
    int data = __getDataObject(deque)
    return JArray.getObj(data, 0)
endFunction

int function Deque_BackInt(int deque) global
    int data = __getDataObject(deque)
    return JArray.getInt(data, -1)
endFunction

float function Deque_BackFloat(int deque) global
    int data = __getDataObject(deque)
    return JArray.getFlt(data, -1)
endFunction

string function Deque_BackString(int deque) global
    int data = __getDataObject(deque)
    return JArray.getStr(data, -1)
endFunction

Form function Deque_BackForm(int deque) global
    int data = __getDataObject(deque)
    return JArray.getForm(data, -1)
endFunction

int function Deque_BackObject(int deque) global
    int data = __getDataObject(deque)
    return JArray.getObj(data, -1)
endFunction

; ==========================================================
;                           Queue
; ==========================================================

int function Queue_Size(int queue) global
    return Object_Size(queue)
endFunction

bool function Queue_Empty(int queue) global
    return Queue_Size(queue) <= 0
endFunction

function Queue_Clear(int queue) global
    int data = __getDataObject(queue)
    JArray.clear(data)
endFunction

function Queue_PushInt(int queue, int value) global
    Deque_PushFrontInt(queue, value)
endFunction

function Queue_PushFloat(int queue, float value) global
    Deque_PushFrontFloat(queue, value)
endFunction

function Queue_PushString(int queue, string value) global
    Deque_PushFrontString(queue, value)
endFunction

function Queue_PushForm(int queue, Form value) global
    Deque_PushFrontForm(queue, value)
endFunction

function Queue_PushObject(int queue, int value) global
    Deque_PushFrontObject(queue, value)
endFunction

function Queue_Pop(int queue) global
    Deque_PopFront(queue)
endFunction

int function Queue_PopInt(int queue) global
    return Deque_PopFrontInt(queue)
endFunction

float function Queue_PopFloat(int queue) global
    return Deque_PopFrontFloat(queue)
endFunction

string function Queue_PopString(int queue) global
    return Deque_PopFrontString(queue)
endFunction

Form function Queue_PopForm(int queue) global
    return Deque_PopFrontForm(queue)
endFunction

int function Queue_PopObject(int queue) global
    return Deque_PopFrontObject(queue)
endFunction

int function Queue_FrontInt(int queue) global
    return Deque_FrontInt(queue)
endFunction

float function Queue_FrontFloat(int queue) global
    return Deque_FrontFloat(queue)
endFunction

string function Queue_FrontString(int queue) global
    return Deque_FrontString(queue)
endFunction

Form function Queue_FrontForm(int queue) global
    return Deque_FrontForm(queue)
endFunction

int function Queue_FrontObject(int queue) global
    return Deque_FrontObject(queue)
endFunction

int function Queue_BackInt(int queue) global
    return Deque_BackInt(queue)
endFunction

float function Queue_BackFloat(int queue) global
    return Deque_BackFloat(queue)
endFunction

string function Queue_BackString(int queue) global
    return Deque_BackString(queue)
endFunction

Form function Queue_BackForm(int queue) global
    return Deque_BackForm(queue)
endFunction

int function Queue_BackObject(int queue) global
    return Deque_BackObject(queue)
endFunction


; ==========================================================
;                           Stack
; ==========================================================

int function Stack_Size(int stack) global
    return Object_Size(stack)
endFunction

bool function Stack_Empty(int stack) global
    return Stack_Size(stack) <= 0
endFunction

function Stack_Clear(int stack) global
    Object_Clear(stack)
endFunction

; TODO: Implement
function Stack_Swap(int stack1, int stack2) global
    int data1 = __getDataObject(stack1)
    int data2 = __getDataObject(stack2)
endFunction

int function Stack_TopInt(int stack) global
    int data = __getDataObject(stack)
    return JArray.getInt(data, 0)
endFunction

string function Stack_TopString(int stack) global
    int data = __getDataObject(stack)
    return JArray.getStr(data, 0)
endFunction

float function Stack_TopFloat(int stack) global
    int data = __getDataObject(stack)
    return JArray.getFlt(data, 0)
endFunction

Form function Stack_TopForm(int stack) global
    int data = __getDataObject(stack)
    return JArray.getForm(data, 0)
endFunction

int function Stack_TopObject(int stack) global
    int data = __getDataObject(stack)
    return JArray.getObj(data, 0)
endFunction

function Stack_PushInt(int stack, int value) global
    int data = __getDataObject(stack)
    JArray.addInt(data, value)
endFunction

function Stack_PushString(int stack, string value) global
    int data = __getDataObject(stack)
    JArray.addStr(data, value)
endFunction

function Stack_PushFloat(int stack, float value) global
    int data = __getDataObject(stack)
    JArray.addFlt(data, value)
endFunction

function Stack_PushForm(int stack, Form value) global
    int data = __getDataObject(stack)
    JArray.addForm(data, value)
endFunction

function Stack_PushObject(int stack, int value) global
    int data = __getDataObject(stack)
    JArray.addObj(data, value)
endFunction

int function Stack_PopInt(int stack) global
    int data = __getDataObject(stack)

    int size = JValue.count(data)
    if (size <= 0)
        ; Error
        return -1
    endif

    int lastElementIndex = (size - 1)
    int value = JArray.getInt(data, lastElementIndex)
    JArray.eraseIndex(data, lastElementIndex)
    return value
endFunction

string function Stack_PopString(int stack) global
    int data = __getDataObject(stack)

    int size = JValue.count(data)
    if (size <= 0)
        ; Error
        return ""
    endif

    int lastElementIndex = (size - 1)
    string value = JArray.getStr(data, lastElementIndex)
    JArray.eraseIndex(data, lastElementIndex)
    return value
endFunction

float function Stack_PopFloat(int stack) global
    int data = __getDataObject(stack)

    int size = JValue.count(data)
    if (size <= 0)
        ; Error
        return -1
    endif

    int lastElementIndex = (size - 1)
    float value = JArray.getFlt(data, lastElementIndex)
    JArray.eraseIndex(data, lastElementIndex)
    return value
endFunction

Form function Stack_PopForm(int stack) global
    int data = __getDataObject(stack)

    int size = JValue.count(data)
    if (size <= 0)
        ; Error
        return none
    endif

    int lastElementIndex = (size - 1)
    Form value = JArray.getForm(data, lastElementIndex)
    JArray.eraseIndex(data, lastElementIndex)
    return value
endFunction

int function Stack_PopObject(int stack) global
    int data = __getDataObject(stack)

    int size = JValue.count(data)
    if (size <= 0)
        ; Error
        return -1
    endif

    int lastElementIndex = (size - 1)
    int value = JArray.getObj(data, lastElementIndex)
    JArray.eraseIndex(data, lastElementIndex)
    return value
endFunction

int function Stack_Count(int stack) global
    int data = __getDataObject(stack)
    return JValue.count(data)
endFunction

; ==========================================================
;                           Pair
; ==========================================================

int function Pair_First() global
    return 0
endFunction

int function Pair_Second() global
    return 1
endFunction

int function Pair_Size(int pair) global
    int data = __getDataObject(pair)
    return FastArray_Size(data)
endFunction

int function Pair_MakeIntPair(int value1, int value2) global
    int pair = Pair()
    Pair_SetInt(Pair_First(), value1, pair)
    Pair_SetInt(Pair_Second(), value2, pair)
    return pair
endFunction

int function Pair_MakeFloatPair(float value1, float value2) global
    int pair = Pair()
    Pair_SetFloat(Pair_First(), value1, pair)
    Pair_SetFloat(Pair_Second(), value2, pair)
    return pair
endFunction

int function Pair_MakeStringPair(string value1, string value2) global
    int pair = Pair()
    Pair_SetString(Pair_First(), value1, pair)
    Pair_SetString(Pair_Second(), value2, pair)
    return pair
endFunction

int function Pair_MakeFormPair(Form value1, Form value2) global
    int pair = Pair()
    Pair_SetForm(Pair_First(), value1, pair)
    Pair_SetForm(Pair_Second(), value2, pair)
    return pair
endFunction

int function Pair_MakeObjectPair(int value1, int value2) global
    int pair = Pair()
    Pair_SetObject(Pair_First(), value1, pair)
    Pair_SetObject(Pair_Second(), value2, pair)
    return pair
endFunction

int function __pairSetBase(int pairElement, int pair) global
    int data = __getDataObject(pair)

    if (pairElement < 0 || pairElement > 1)
        ; Error, throw exception
        return -1
    endif

    return data
endFunction

function Pair_SetInt(int pairElement, int value, int pair) global
    int data = __pairSetBase(pairElement, pair)
    
    if (!data)
        return
    endif

    FastArray_SetInt(data, pairElement, value)
endFunction

function Pair_SetFloat(int pairElement, float value, int pair) global
    int data = __pairSetBase(pairElement, pair)
    
    if (!data)
        return
    endif

    FastArray_SetFloat(data, pairElement, value)
endFunction

function Pair_SetString(int pairElement, string value, int pair) global
    int data = __pairSetBase(pairElement, pair)
    
    if (!data)
        return
    endif

    FastArray_SetString(data, pairElement, value)
endFunction

function Pair_SetForm(int pairElement, Form value, int pair) global
    int data = __pairSetBase(pairElement, pair)
    
    if (!data)
        return
    endif

    FastArray_SetForm(data, pairElement, value)
endFunction

function Pair_SetObject(int pairElement, int value, int pair) global
    int data = __pairSetBase(pairElement, pair)
    
    if (!data)
        return
    endif

    FastArray_SetObject(data, pairElement, value)
endFunction

int function Pair_Int(int pairElement, int pair) global
    int data = __getDataObject(pair)
    
    if (!data)
        return -1
    endif

    return FastArray_GetInt(data, pairElement)
endFunction

float function Pair_Float(int pairElement, int pair) global
    int data = __getDataObject(pair)
    
    if (!data)
        return -1.0
    endif

    return FastArray_GetFloat(data, pairElement)
endFunction

string function Pair_String(int pairElement, int pair) global
    int data = __getDataObject(pair)
    
    if (!data)
        return ""
    endif

    return FastArray_GetString(data, pairElement)
endFunction

Form function Pair_Form(int pairElement, int pair) global
    int data = __getDataObject(pair)
    
    if (!data)
        return none
    endif

    return FastArray_GetForm(data, pairElement)
endFunction

int function Pair_Object(int pairElement, int pair) global
    int data = __getDataObject(pair)
    
    if (!data)
        return -1
    endif

    return FastArray_GetObject(data, pairElement)
endFunction

; ==========================================================
;                           Vector
; ==========================================================

int function Vector_Size(int vector) global
    int data = __getDataObject(vector)
    return FastArray_Size(data)
endFunction

function Vector_SetX(int vector, float value) global
    int data = __getDataObject(vector)
    FastArray_SetFloat(data, 0, value)
endFunction

function Vector_SetY(int vector, float value) global
    int data = __getDataObject(vector)
    FastArray_SetFloat(data, 1, value)
endFunction

function Vector_SetZ(int vector, float value) global
    int data = __getDataObject(vector)
    FastArray_SetFloat(data, 2, value)
endFunction

function Vector_SetW(int vector, float value) global
    int data = __getDataObject(vector)
    FastArray_SetFloat(data, 3, value)
endFunction

float function Vector_X(int vector) global
    int data = __getDataObject(vector)
    return FastArray_GetFloat(data, 0)
endFunction

float function Vector_Y(int vector) global
    int data = __getDataObject(vector)
    return FastArray_GetFloat(data, 1)
endFunction

float function Vector_Z(int vector) global
    int data = __getDataObject(vector)
    return FastArray_GetFloat(data, 2)
endFunction

float function Vector_W(int vector) global
    int data = __getDataObject(vector)
    return FastArray_GetFloat(data, 3)
endFunction

; ==========================================================
;                           Helpers
; ==========================================================

string function DebugObject(int object) global

endFunction

bool function __isValidObject(int object) global
    ; TODO: Implement
    return object != 0
endFunction

;/
    Creates and returns an object from a factory function if it does not exist.

    Object  @object: The actual object to assign to and perform validation on.
    Object  @objectFn: The object factory function to create this object.

    returns (Object): The resulting object created from the factory function.
/;
int function Object_CreateIfNotExists(int object, int objectFn) global
    if (!__isValidObject(object))
        object = objectFn
    endif

    return object
endFunction

bool function Object_Exists(int object) global
    return __isValidObject(object)
endFunction

;/
    Copies an object and returns a new object.

    Object  @object: The object to copy.
    bool?   @deepCopy: Whether to make a deep copy of the object (copies child objects).
    string? @params: The parameters to pass to the resulting object.

    returns (Object): The copied object.
/;
int function Copy(int sourceObject, bool deepCopy = true, string params = "{}") global
    if (deepCopy)
        JValue.deepCopy(sourceObject)
    else
        JValue.shallowCopy(sourceObject)
    endif
endFunction

;/
    Moves an object and returns the new object.

    Object  @object: The object to move.
    string? @params: The parameters to pass to the resulting object.

    returns (Object): The moved object.
/;
int function Move(int sourceObject, string params = "") global
    int newObj = Copy(sourceObject, true, params)
    delete(sourceObject)
endFunction

;/
    Object  @object: The object to check the type of.
/;
string function typeof(int object) global
    ; return Get(object, "metadata//type")
endFunction

int function __makeObjectFromSignature(string signature) global
endFunction

int function __makeParent(string params = "") global
    return JMap.object()
endFunction

int function __writeData(int object, int dataObject) global
    JMap.setObj(object, "data", dataObject)
    return __getDataObject(object)
endFunction

int function __writeMetadata(int object, string type) global
    if (__hasMetadata(object))
        ; Error
        return -1
    endif

    JMap.setObj(object, "metadata", JMap.object())
    JValue.solveStrSetter(object, ".metadata.type", type) ; later the type should be extracted from signature, and signature passed as param instead, example: Stack<int> (type is Stack)
    ; JValue.solveStrSetter(object, ".metadata.createdAt", RPB_Utility.GetDateTimeNow())

    return JMap.getObj(object, "metadata")
endFunction

int function __makeObject(int dataObject, string type) global
    __writeMetadata(dataObject, "stack")
    
endFunction

int function __invalidObject() global
    int obj = JMap.object()
    JMap.setInt(obj, "invalid", 1)

    return obj
endFunction

; TODO: Implement parsing
bool function __parseSignature(string signature, string type = "") global
    return true
endFunction

int function __getDataObject(int object) global
    return JMap.getObj(object, "data")
endFunction

int function __toBaseObject(int jcObject) global
    int obj = __makeParent()
    __writeData(obj, jcObject)
    return obj
endFunction

bool function __hasMetadata(int object) global
    return JMap.hasKey(object, "metadata")
endFunction

; U can be a Map, Queue, Stack, Deque, Array, and so can U+1, U+2, etc...
; T can be string, int, Form, ObjectReference, float(?)... as key. Should objects be supported as keys?
string function __mapSignature() global
    return "Map<T, U>"
endFunction

string function __arraySignature(int dimensions = 1) global
    string signature = "T"
    int i = 0
    while (i < dimensions)
        signature += "[]"
        i += 1
    endWhile
    
    return signature ; T[] ... i*[]
endFunction

string function __tupleSignature() global
    return "<T, U>"
endFunction

bool function __isComplexType(string signature) global
    string complexType = "Type<T, U>"
endFunction

bool function __isOfType(string signature, string type) global
endFunction

; ==========================================================
;                         Exceptions
; ==========================================================

int function __exceptionStorage() global
    ; return Map("<string>", "{ 'memory': { 'retain': true } }")
endFunction

function throw(int object, int exception) global
    Map_SetObject(__exceptionStorage(), "exception:" + object, exception)
endFunction

int function throwAndReturn(int object, int exception) global
    Map_SetObject(__exceptionStorage(), "exception:" + object, exception)
    return object
endFunction

int function GetException(int object) global
    return Map_GetObject(__exceptionStorage(), "exception:" + object)
endFunction

int function Exceptions(int object) global
    return Map_GetObject(object, "exceptions")
endFunction

bool function CatchException(int object, string exceptionId) global
    int exceptions = Exceptions(object)
    return Map_HasKey(exceptions, exceptionId)
endFunction

int function ExceptionCode(int exception) global
    return Map_GetInt(exception, "code")
endFunction

string function ExceptionMessage(int exception) global
    return Map_GetString(exception, "message")
endFunction

int function Exception(string type, string msg, int code) global
    ; return Map("<string>", "{ 'type': "+ type +", 'message': "+ msg +", 'code': "+ code +" }")
    int exceptionObj = Map("<string>")
    Map_SetString(exceptionObj, "type", type)
    Map_SetString(exceptionObj, "message", msg)
    Map_SetInt(exceptionObj, "code", code)
    return exceptionObj
endFunction

int function InvalidObjectException(string msg) global
    return Exception("InvalidObjectException", msg, 100)
endFunction

int function InvalidObjectParamsException(string msg) global
    return Exception("InvalidObjectParamsException", msg, 104)
endFunction

int function PathNotFoundException(string msg) global
    return Exception("PathNotFoundException", msg, 101)
endFunction

int function AttributeNotFoundException(string msg) global
    return Exception("AttributeNotFoundException", msg, 102)
endFunction

int function IndexOutOfBoundsException(string msg) global
    return Exception("IndexOutOfBoundsException", msg, 103)
endFunction

int function InvalidKeyException(string msg) global
    return Exception("InvalidKeyException", msg, 105)
endFunction