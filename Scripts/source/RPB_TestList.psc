scriptname RPB_TestList extends ObjectReference hidden

import Utility
import RPB_Utility

;/ @data: string: The actual data of the list /;
string[] data

;/ @dataIds JMap&: A map of keys to the real indices used to access data[] /;
int dataIds

;/ @dataKeys JArray&: An array of the keys in order of insertion. /;
int dataKeys

;/ @cachedAvailableIndex int: The next available index that was cached previously. /;
int cachedAvailableIndex

bool function isEmpty()
    return JValue.count(dataIds) <= 0
endFunction

int function getListLength()
    return JValue.count(dataIds)
endFunction

int function __private_get_available_index()
    int i = 0
    while (i < data.Length)
        if (!data[i])
            return i
        endif
        i += 1
    endWhile
endFunction

function __private_clear()
    int arrayLength = JValue.count(dataIds)

    int i = 0
    while (i < arrayLength)
        data[i] = none
        i += 1
    endWhile

    JMap.clear(dataIds)
endFunction

int[] function __private_get_indices()
    return JArray.asIntArray(JMap.allValues(dataIds))
endFunction

string[] function __private_get_elements()
    return data
endFunction

string[] function __private_get_keys()
    return JArray.asStringArray(JMap.allKeys(dataIds))
endFunction

; Returns the element's old index
int function __private_change_element_index(string elementKey, int newIndex)
    int oldIndex = JMap.getInt(dataIds, elementKey)
    JMap.setInt(dataIds, elementKey, newIndex)

    return oldIndex
endFunction

string function __private_list_indices_relation_to_keys()
    ; Example element relation: 1: Prisoner[104610]
    int arrayLength         = __private_get_length()
    int[] elementsIndices   = __private_get_indices()

    string retval = "["

    int i = 0
    while (i < arrayLength)
        int elementIndex        = __private_get_index_from_position(i)
        string elementKey       = __private_get_key_for_index(elementIndex)
        string elementRelation  = elementsIndices[i] + ": " + elementKey
        if (i < (arrayLength - 1))
            elementRelation += ", "
        endif
        retval += elementRelation
        i += 1
    endWhile

    return retval + "]"
endFunction

int function __private_get_length()
    return JValue.count(dataIds)
endFunction

string function __private_get_key_for_index(int index)
    return JArray.getStr(dataKeys, index)
    return JMap.getNthKey(dataIds, index)
endFunction

int function __private_get_index_for_key(string elementKey)
    int index = JMap.getInt(dataIds, elementKey)
    return index
endFunction

int function __private_get_index_from_position(int indexPosition)
    int index = JArray.findInt(JMap.allValues(dataIds), indexPosition)
    return index
endFunction

string function __private_get_value_by_index(int index)
    ; if (index < 0 || index >= JArray.count(dataIds))
    ;     return none
    ; endif

    if (index < 0 || index >= JArray.count(dataKeys))
        return none
    endif

    ; string elementKey   = JMap.getNthKey(dataIds, index)
    string elementKey   = JArray.getStr(dataKeys, index)
    int elementIndex    = JMap.getInt(dataIds, elementKey)

    return data[elementIndex]
endFunction

string function __private_get_value_by_key(string elementKey)
    int elementIndex = JMap.getInt(dataIds, elementKey)
    return data[elementIndex]
endFunction

function __private_add_at(string element, string elementKey)
    bool keyExists = JMap.hasKey(dataIds, elementKey)

    if (keyExists)
        Error("Element "+ elementKey +" already exists, cannot add it again!")
        return
    endif

    int availableIndex = __private_get_available_index()
    
    if (!data[availableIndex])
        data[availableIndex] = element                      ; Assign the Data
        JMap.setInt(dataIds, elementKey, availableIndex)    ; Assign the index to the key
        JArray.addStr(dataKeys, elementKey)                 ; Assign the Key
    endif
endFunction

function __private_remove_at(string elementKey)
    int index = JMap.getInt(dataIds, elementKey)
    string element = data[index]

    ; DebugWithArgs("TestList::__private_remove_at", elementKey, "Removing " + data[index])

    data[index] = none                          ; Delete the Data
    JMap.removeKey(dataIds, elementKey)         ; Delete the Index
    JArray.eraseString(dataKeys, elementKey)    ; Delete the Key
endFunction

function __private_initialize()
    if (!data || !dataIds)
        dataIds     = JMap.object()
        dataKeys    = JArray.object()

        JValue.retain(dataIds)
        JValue.retain(dataKeys)

        data = new string[20]
    endif
endFunction

function __private_reindex()
    int arrayLength = JValue.count(dataIds)

    int i = 0
    while (i < arrayLength)
        bool isEmptyElement = !data[i] || data[i] == "None" || data[i] == ""
        string elementKey   = __private_get_key_for_index(i)
        int indexInMap      = __private_get_index_for_key(elementKey)

        if (isEmptyElement)
            string nextElementKey   = __private_get_key_for_index(i + 1)
            int nextElementIndex    = __private_get_index_for_key(nextElementKey)

            data[i] = data[nextElementIndex]        ; Assign the next element to this
            JMap.setInt(dataIds, nextElementKey, i) ; Assign new index to this key, no need to delete the index because it's mapped to the key, only change it
            data[nextElementIndex] = none

            ; Debug("TestList::__private_reindex", "Shifted "+ data[i] + " from index " + nextElementIndex + " to index " + i + " | " + data)
        endif
        i += 1
    endWhile
endFunction

function __private_sort()
    int arrayLength = JValue.count(dataIds)
    int[] indices   = JArray.asIntArray(JMap.allValues(dataIds))

    int i = 0
    while (i < arrayLength)
        string elementKey   = __private_get_key_for_index(i)            ; Get the key in the i'th position: [0, 4, 3, 6, 2]; i = 1 then x = 4 
        int elementIndex    = __private_get_index_for_key(elementKey)   ; Get the index from the key located in the i'th position

        string tempData     = data[i] ; i = 0 -> dataIds[1]
        int tempDataIndex   = JArray.findInt(JMap.allValues(dataIds), i) ; find i in dataIds, so dataIds[x] = i

        Debug("TestList::__private_sort", i + ": elementIndex: " + elementIndex + ", tempDataIndex: " + tempDataIndex)

        ; Assign the i'th index to this element
        JMap.setInt(dataIds, elementKey, i)

        string oppositeElementKey = __private_get_key_for_index(elementIndex) ; i = 0 -> dataIds[0] because elementIndex was retrieved from dataIds[1]
        JMap.setInt(dataIds, oppositeElementKey, elementIndex)

        Debug("TestList::__private_sort", i + ": Swapping " + elementKey + " (index: "+ elementIndex +") with " + oppositeElementKey + " (index: "+ tempDataIndex +")")

        i += 1
    endWhile

    indices = JArray.asIntArray(JMap.allValues(dataIds))
    Debug("TestList::__private_sort", "data: " + data)
    ; Debug("TestList::__private_sort", "indices: " + indices)
endFunction

function __private_list_data()
    int arrayLength         = JValue.count(dataIds)
    int[] mapIndices        = JArray.asIntArray(JMap.allValues(dataIds))
    string[] elementKeys    = JArray.asStringArray(JMap.allKeys(dataIds))

    LogNoType("Element Keys: " + elementKeys)

    int i = 0
    while (i < arrayLength)
        string tabs = string_if (StringUtil.GetLength(data[i]) >= 10, "\t\t", "\t\t\t")
        string keyFromMap   = JMap.getNthKey(dataIds, i)
        int indexFromMap    = __private_get_index_from_position(i)
        LogNoType(i + ": data["+indexFromMap+"] = " + data[indexFromMap] + tabs + "(Key: "+ keyFromMap +")")
        i += 1
    endWhile
endFunction