scriptname RPB_ActiveMagicEffectContainer extends ReferenceAlias

;/
    TODO: Sort list after removing an element, or adding it.
/;

import RPB_Utility

; =========================================================
;                    string implementation                          
; =========================================================

int __dataIds
int __dataKeys  ; To store the keys, JMap sorts them alphabetically which makes it a pain to reindex, since it doesn't support the order of insertion
string[] __data

int function __string_get_available_index()
    int i = 0
    while (i < __data.Length)
        if (!__data[i])
            ; nextAvailableIndex = i
            return i
        endif
        i += 1
    endWhile
endFunction

function __string_clear()
    int arrayLength = JValue.count(__dataIds)

    int i = 0
    while (i < arrayLength)
        __data[i] = none
        i += 1
    endWhile

    JMap.clear(__dataIds)
endFunction

int[] function __string_get_indexes()
    return JArray.asIntArray(JMap.allValues(__dataIds))
endFunction

int function __string_get_length()
    return JValue.count(__dataIds)
endFunction

string function __string_get_key_for_index(int index)
    return JArray.getStr(__dataKeys, index)
    ; return JMap.getNthKey(__dataIds, index)
endFunction

int function __string_get_index_for_key(string elementKey)
    int index = JMap.getInt(__dataIds, elementKey)
    return index
endFunction

string function __string_get_value(int index)
    ; string elementKey = JMap.getNthKey(__dataIds, index)
    if (index < 0 || index >= JArray.count(__dataKeys))
        return none
    endif

    string elementKey   = JArray.getStr(__dataKeys, index)
    ; string elementKey   = JMap.getNthKey(__dataIds, index)
    int elementIndex    = JMap.getInt(__dataIds, elementKey)
    return __data[elementIndex]
endFunction

string function __string_get_value_by_key(string elementKey)
    int elementIndex = JMap.getInt(__dataIds, elementKey)
    return __data[elementIndex]
endFunction

string function __string_remove_element(string elementKey)
    int index = JMap.getInt(__dataIds, elementKey)
    string element = __data[index]

    DebugWithArgs("ActiveMagicEffectList::__string_remove_element", elementKey, "Removing " + __data[index])

    __data[index] = none                        ; Delete the Data
    JMap.removeKey(__dataIds, elementKey)       ; Delete the Index
    JArray.eraseString(__dataKeys, elementKey)  ; Delete the Key

    return element
endFunction


function __string_add_at(string element, string elementKey)
    if (!__dataIds || !__data)
        __dataIds   = JMap.object()
        __dataKeys  = JArray.object()
        JValue.retain(__dataIds)
        JValue.retain(__dataKeys)
        __data = new string[20]
    endif
    bool hasKey = JMap.hasKey(__dataIds, elementKey)

    if (!hasKey)
        int availableIndex = __string_get_available_index()
        if (!__data[availableIndex])
            __data[availableIndex] = element                    ; Assign the Data
            JMap.setInt(__dataIds, elementKey, availableIndex)  ; Assign the Index
            JArray.addStr(__dataKeys, elementKey)               ; Assign the Key
        endif
    endif
endFunction

function __string_shift_element_left(int index)
    if (index == 0)
        return
    endif

    __data[index - 1] = __data[index]
    __data[index] = none

    string elementKey = JMap.getNthKey(__dataIds, index)
    JMap.setInt(__dataIds, elementKey, (index - 1))
endFunction

function __string_list_data()
    int arrayLength = JValue.count(__dataIds)
    int[] mapIndices    = JArray.asIntArray(JMap.allValues(__dataIds))
    string[] mapKeys    = JArray.asStringArray(JMap.allKeys(__dataIds))
    string[] arrayKeys  = JArray.asStringArray(__dataKeys)
    
    LogNoType("Map Keys: " + mapKeys)
    LogNoType("Array Keys: " + arrayKeys)

    int i = 0
    while (i < arrayLength)
        string tabs = string_if (StringUtil.GetLength(__data[i]) >= 10, "\t\t", "\t\t\t")
        string keyFromArray = JArray.getStr(__dataKeys, i)
        string keyFromMap   = JMap.getNthKey(__dataIds, i)
        LogNoType(i + ": data["+i+"] = " + __data[i] + tabs + "(Key from Array: "+ keyFromArray +", Key from Map: "+ keyFromMap +")")
        i += 1
    endWhile
endFunction

;/
    Sorts the array in ascending order
/;
function __string_sort_data()
    int arrayLength = JArray.count(__dataKeys)
    string[] elements = __data
    int[] indices = JArray.asIntArray(JMap.allValues(__dataIds))

    int i = 0


    while (i < arrayLength)
        string elementKey       = self.__string_get_key_for_index(i)    
        int elementIndexInMap   = self.__string_get_index_for_key(elementKey) ; The actual index where the element is stored in elements[], not i

        string temporaryData    = elements[i] ; i = 0 -> __dataIds[1]
        int temporaryDataIndex  = JArray.findInt(JMap.allValues(__dataIds), i) ; Find i in __dataIds, so __dataIds[x] = i

        ; elements[i] = elements[elementIndexInMap]
        JMap.setInt(__dataIds, elementKey, i) ; Assign the i'th index to this element

        string keyForOppositeElement = self.__string_get_key_for_index(elementIndexInMap) ; i = 0 -> __dataIds[0] because elementIndexInMap was retrieved from __dataIds[1]
        JMap.setInt(__dataIds, keyForOppositeElement, elementIndexInMap)

        ; JArray.swapItems(JMap.allValues(__dataIds), temporaryDataIndex, i)
        ; indices = JArray.asIntArray(JMap.allValues(__dataIds))
        ; TODO: Get the element at the i'th index (not position in the map), so __dataIds index 0 for example (could be any position in the map), 
        ; assign that index to the i index (0), and swap the i 
        ; index (0) with the __dataIds index that was assigned. 
        ;/
            Example: __dataIds indices: [1, 0, 3, 2, 5, 4, 8, 6, 7]
            __dataIds[0] is i = 1
            __dataIds[1] is i = 0
            __dataIds[2] is i = 3
            __dataIds[3] is i = 2

            So, for i = 0, get __dataIds[1] index which is 0, assign it to __dataIds[0] which is 1, now assign __dataIds[0] to __dataIds[1] (essentially swap them)
            Keep doing this until the array looks like this: [0, 1, 2, 3, 4, 5, 6, 7], because the actual data is mapped to the index inside this array, the position
            does not really matter.
            This might imply using a find() function in the array searching for i, to get that element position in order to replace it.
            Then, to swap with the __dataIds index that was replaced, we may create a temporary int variable to hold the index that is to be swapped.
        /;
        i += 1
    endWhile
    elements = __data
    indices = JArray.asIntArray(JMap.allValues(__dataIds))
    Debug("ActiveMagicEffectList::__string_sort_data", "elements: " + elements)
    Debug("ActiveMagicEffectList::__string_sort_data", "indices: " + indices)

endFunction

function __string_reindex_data()
    int arrayLength = JArray.count(__dataKeys)
    string[] elements = __data

    Debug("ActiveMagicEffectList::__string_reindex_data", "elements: " + elements)
    int i = 0
    while (i < arrayLength)
        bool isEmptyElement = !elements[i] || elements[i] == "None" || elements[i] == ""
        string elementKey = self.__string_get_key_for_index(i)
        int indexInMap = self.__string_get_index_for_key(elementKey)

        if (isEmptyElement)
            string nextElementKey   = self.__string_get_key_for_index(i + 1)
            int nextElementIndex    = self.__string_get_index_for_key(nextElementKey)
            elements[i] = elements[nextElementIndex]
            elements[nextElementIndex] = none
            ; Assign new index to this key
            JMap.setInt(__dataIds, nextElementKey, i) ; No need to delete the index because it's mapped to the key, only change it
            Debug("ActiveMagicEffectList::__string_reindex_data", "elements: " + elements)
        endif

        ; ; Test Case
        ; if (indexInMap == 8)
        ;     elements[6] = elements[indexInMap] ; Shifts the actual data
        ;     elements[indexInMap] = none
        ;     ; Assign new index to this key
        ;     JMap.setInt(__dataIds, elementKey, 6) ; No need to delete the index because it's mapped to the key, only change it
        ;     int newIndexInMap = self.__string_get_index_for_key(elementKey)
        ;     Debug("ActiveMagicEffectList::__string_reindex_data", "elements["+6+"]: " + elements[6] + ", Element Key: " + elementKey + ", New Index in Map: " + newIndexInMap)
        ;     Debug("ActiveMagicEffectList::__string_reindex_data", "elements: " + elements)
        ; endif

        ; if (isEmptyElement)
        ;     Debug("ActiveMagicEffectList::__string_reindex_data", "elements["+indexInMap+"]: " + elements[indexInMap] + ", Element Key: " + elementKey + ", Index in Map: " + indexInMap)
        ; endif
        i += 1
    endWhile

endFunction

; function __string_reindex_data()
;     int arrayLength = JValue.count(__dataIds)
;     string[] elements = __data

;     ; int i = 0
;     ; while (i < arrayLength)
;     ;     ; Only shift if the element is none
;     ;     if (elements[i] == "None")
;     ;         ; Shift element left and assign new index to the key
;     ;         int shiftIndex = i + 1
;     ;         elements[i] = elements[shiftIndex]
;     ;         string elementKey = JArray.getStr(__dataKeys, shiftIndex)
;     ;         JMap.setInt(__dataIds, elementKey, i)

;     ;         Debug("ActiveMagicEffectList::__string_reindex_data", "Setting data["+ shiftIndex +"] ("+ elements[shiftIndex] +") to null (moved to data["+i+"])")
;     ;         elements[shiftIndex] = "None"
;     ;     endif
;     ;     i += 1
;     ; endWhile
;     int i = 0
;     int nextIndex = 0
;     while (i < arrayLength)
;         ; Only shift if the element is none
;         if (elements[i] != "None")
;             if (i != nextIndex)
;                 ; Shift element left and assign new index to the key
;                 int shiftIndex = i + 1
;                 elements[nextIndex] = elements[i]
;                 ; Debug("ActiveMagicEffectList::__string_reindex_data", "Setting data["+ shiftIndex +"] ("+ elements[shiftIndex] +") to null (moved to data["+i+"])")
;                 elements[i] = "None"

;                 ; Move the corresponding key to the nextIndex position
;                 string elementKey = JArray.getStr(__dataKeys, i)
;                 JMap.setInt(__dataIds, elementKey, nextIndex)
;                 JArray.setStr(__dataKeys, nextIndex, elementKey)
;                 JArray.setStr(__dataKeys, i, "None")
;             endif
;             nextIndex += 1
;         endif
;         i += 1
;     endWhile
; endFunction

; function __string_reindex_data()
;     int arrayLength = JValue.count(__dataIds)
;     int[] indexes   = JArray.asIntArray(JMap.allValues(__dataIds))

;     ; string firstElementKey = JMap.getNthKey(__dataIds, 0)
;     Debug("ActiveMagicEffectList::__private_reindex_data", "arrayLength: " + arrayLength)
;     Debug("ActiveMagicEffectList::__private_reindex_data", "indexes: " + indexes)

;     int i = 0
;     while (i < JValue.count(__dataIds))
;         ; string castElement = __data[i]
;         ; string elementKey = JMap.getNthKey(__dataIds, i)
;         ; int elementIndex  = JMap.getInt(__dataIds, elementKey)
;         ; Debug("ActiveMagicEffectList::__private_reindex_data", "["+i+"]: \t (Key: "+ elementKey +", Index: "+ elementIndex +")")
;         if (__data[i] == "None")
;             ; Shift element left and assign new index to the key
;             Debug("ActiveMagicEffectList::__private_reindex_data", "["+i+"]: "+__data[i]+" = "+(__data[i + 1]))
;             __data[i] = __data[i + 1]
;             __data[i + 1] = "None"
;             ; string nextElementKey = JMap.getNthKey(__dataIds, i) ; this doesn't make any sense, it works but it should be i + 1
;             string nextElementKey = JArray.getStr(__dataKeys, i) ; this doesn't make any sense, it works but it should be i + 1
;             JMap.removeKey(__dataIds, nextElementKey)
;             JMap.setInt(__dataIds, nextElementKey, i)
;             ; JArray.swapItems(__dataKeys, i + 1, i)
;             Debug("ActiveMagicEffectList::__private_reindex_data", "["+i+"]: \t Moving " + nextElementKey + " (index: "+ (i + 1) +") to index: " + i)
;             string keyWithNewIndex = JMap.getNthKey(__dataIds, i)
;             Debug("ActiveMagicEffectList::__private_reindex_data", "["+i+"]: \t New Key for "+ __data[i] +": "+ keyWithNewIndex + " - index: " + __string_get_index_for_key(keyWithNewIndex))
;         endif
;         i += 1
;     endWhile


;     indexes   = JArray.asIntArray(JMap.allValues(__dataIds))
; endFunction

; =========================================================

;/ @data ActiveMagicEffect[]: The actual data of the list /;
ActiveMagicEffect[] data

;/ @dataIds JMap&: A map of keys to the real indices used to access data[] /;
int dataIds

;/ @dataKeys JArray&: An array of the keys in order of insertion. /;
int dataKeys

;/ @cachedAvailableIndex int: The next available index that was cached previously. /;
int cachedAvailableIndex


int nextAvailableIndex


int property Count
    int function get()
        return self.GetSize()
    endFunction
endProperty


function __private_add_at(ActiveMagicEffect element, string elementKey)
    bool hasKey = JMap.hasKey(dataIds, elementKey)
    if (hasKey)
        return
    endif
    ; SetLoggingEnabled("DEBUG", false)
    ; SetLoggingEnabled("TRACE", false)

    int availableIndex = __private_getAvailableIndex()
endFunction

function AddAt(ActiveMagicEffect apActiveMagicEffect, string asKey)
    ; __private_add_at(apActiveMagicEffect, asKey)
    ; return
    ; Initialize array
    ; if (!dataIds || !data)
    ;     dataIds = JMap.object()
    ;     JValue.retain(dataIds)
    ;     data = new ActiveMagicEffect[128]
    ; endif

    if (self.HasKey(asKey))
        return
    endif

    ; possible point of slowdown since we iterate over all elements
    int availableIndex = __private_getAvailableIndex()
    ; SetLoggingEnabled("DEBUG", false)
    ; SetLoggingEnabled("TRACE", false)
    if (data[availableIndex] == none)
        data[availableIndex] = apActiveMagicEffect ; Assign AME to this index
        JMap.setInt(dataIds, asKey, availableIndex) ; Store the index at this key
        ; SetLoggingEnabled("DEBUG", true)
        ; SetLoggingEnabled("TRACE", true)
        Debug("ActiveMagicEffectList::Add", "Added ActiveMagicEffect: " + apActiveMagicEffect + " at index: " + availableIndex + " (key: "+ asKey +").")
        nextAvailableIndex = availableIndex
    endif
    ; SetLoggingEnabled("DEBUG", false)
    ; SetLoggingEnabled("TRACE", false)

    ; RPB_Utility.Debug("ActiveMAgicEffectList::AddAt", "data: " + data + ", self: " + GetOwningQuest())
endFunction

bool function HasKey(string asKey)
    return JMap.hasKey(dataIds, asKey)
endFunction

ActiveMagicEffect function GetAt(string asKey)
    if (!JMap.hasKey(dataIds, asKey))
        return none
    endif

    int arrayIndex = JMap.getInt(dataIds, asKey)

    Debug("ActiveMagicEffectList::GetAt", "Retrieved ActiveMagicEffect: " + data[arrayIndex] + " at index: " + arrayIndex + ", from key: " + asKey)
    return data[arrayIndex]
endFunction

ActiveMagicEffect function FromIndex(int aiIndex)
    ; TODO: Check for out of bounds
    return data[aiIndex]
endFunction


ActiveMagicEffect[] function GetAsArray()
    return data
endFunction

bool function __private_is_out_of_bounds(int index)
    int dataLength = JValue.count(dataIds)
    return (index < 0 || index > dataLength)
endFunction

int function __private_remove_element(string keyToRemove)
    int index = JMap.getInt(dataIds, keyToRemove)

    ; Remove the actual data from the array
    data[index] = none

    ; Remove the value of this Key from JMap
    JMap.removeKey(dataIds, keyToRemove)

    return index
endFunction

function __private_shift_element_left(int index)
    if (index == 0) ; can't shift [0] to the left
        return
    endif

    bool indexExists = JMap.getNthKey(dataIds, index) != ""
    if (indexExists && data[index] != none)
        data[index - 1] = data[index]

        string elementKey = JMap.getNthKey(dataIds, index)
        JMap.setInt(dataIds, elementKey, index - 1)
    endif
endFunction

function __private_reindex_data()
    ; SetLoggingEnabled("DEBUG", true)
    ; SetLoggingEnabled("TRACE", true)
    int arrayLength = JValue.count(dataIds)
    int[] indexes   = JArray.asIntArray(JMap.allValues(dataIds))

    ; string firstElementKey = JMap.getNthKey(dataIds, 0)
    Debug("ActiveMagicEffectList::__private_reindex_data", "arrayLength: " + arrayLength)
    Debug("ActiveMagicEffectList::__private_reindex_data", "indexes: " + indexes)

    RPB_Prisoner firstElement = data[0] as RPB_Prisoner
    Debug("ActiveMagicEffectList::__private_reindex_data", "0th index: " + firstElement.Name)

    int i = 0
    while (i < arrayLength)
        RPB_Prisoner castElement = data[i] as RPB_Prisoner
        string elementKey = JMap.getNthKey(dataIds, i)
        int elementIndex  = JMap.getInt(dataIds, elementKey)
        string tabs = string_if (StringUtil.GetLength(castElement.Name) >= 10, "\t", "\t\t")
        Debug("ActiveMagicEffectList::__private_reindex_data", "["+i+"]: " + castElement.Name + tabs + " (Key: "+ elementKey +", Index: "+ elementIndex +")")
        i += 1
    endWhile


    indexes   = JArray.asIntArray(JMap.allValues(dataIds))
    Debug("ActiveMagicEffectList::__private_reindex_data", "indexes: " + indexes)
    ; SetLoggingEnabled("DEBUG", false)
    ; SetLoggingEnabled("TRACE", false)
endFunction

function reindex_data(string asKeyToRemove)
    int index       = JMap.getInt(dataIds, asKeyToRemove) ; index for this key to be used on data[]
    int[] indexes   = JArray.asIntArray(JMap.allValues(dataIds))
    int arrayLength = JValue.count(dataIds)

    Debug("ActiveMagicEffectList::reindex_data", "Removed Key: " + asKeyToRemove + " | Index: "+ index +" | data["+ index +"]: " + data[index])
    Debug("ActiveMagicEffectList::reindex_data", "\ndata: " + data + " | \nkeys: " + GetKeys() + " | \nindexes: " + indexes)

    int removedIndex = __private_remove_element(asKeyToRemove)

    int mapKeyCount = JValue.count(dataIds)
    
    int i = index
    while (i < mapKeyCount)
        if (i + 1 < mapKeyCount)
            data[i] = data[i + 1] ; shift left
            string elementKey = JMap.getNthKey(dataIds, i + 1)
            if (elementKey != "")
                JMap.setInt(dataIds, elementKey, i)
            endif
        else
            data[i] = none
        endif
        i += 1
    endWhile

    data[mapKeyCount - 1] = none

    ; int n = 0
    ; while (n < mapKeyCount - 1)
    ;     string elementKey = JMap.getNthKey(dataIds, n)
    ;     if (elementKey != "")
    ;         JMap.setInt(dataIds, elementKey, n)
    ;     endif
    ;     n += 1
    ; endWhile

    if (mapKeyCount > 1)
        string lastKey = JMap.getNthKey(dataIds, (mapKeyCount))
        if (lastKey != "")
            JMap.removeKey(dataIds, lastKey)
        endif
    endif

    ; int i = 1
    ; while (i < (data.Length - 1))
    ;     data[i] = data[i + 1] ; Shift element to the left

    ;     string nextElementKey = JMap.getNthKey(dataIds, (i + 1))
    ;     ; JMap.removeKey(dataIds, nextElementKey)
    ;     if (nextElementKey != "")
    ;         JMap.setInt(dataIds, nextElementKey, i)
    ;     endif

    ;     i += 1
    ; endWhile

    ; data[data.Length - 1] = none

    ; int n = 0
    ; while (n < data.Length)
    ;     string elementKey = JMap.getNthKey(dataIds, n)
    ;     if (JMap.getInt(dataIds, elementKey) == data.Length - 1)
    ;         JMap.removeKey(dataIds, elementKey)
    ;     endif
    ;     n += 1
    ; endWhile

    ; string lastKey = JMap.getNthKey(dataIds, (data.Length - 1))
    ; if (lastKey != "")
    ;     JMap.removeKey(dataIds, lastKey)
    ; endif

    ; ; B: [2, 3, 6, 5, 0, 8, 4, 7, 1]
    ; ; A: [2, 3, 6, 5, 0, 8, 7, 1]
    ; int i = 0
    ; while (i < arrayLength)
    ;     string elementKey       = JMap.getNthKey(dataIds, i)
    ;     int currentElement      = JMap.getInt(dataIds, elementKey) ; 2
    ;     bool hasCurrentElement  = JMap.valueType(dataIds, elementKey) != 0 ; true
    ;     if (hasCurrentElement && data[currentElement] == none) ;
    ;         data[currentElement] = data[currentElement + 1]
    ;         string nextKey = JMap.getNthKey(dataIds, currentElement + 1)
    ;         JMap.setInt(dataIds, nextKey, i)
    ;         JMap.removeKey(dataIds, nextKey)
    ;     endif
    ;     i += 1
    ; endWhile

    indexes   = JArray.asIntArray(JMap.allValues(dataIds))
    Debug("ActiveMagicEffectList::reindex_data", "\ndata: " + data + " | \nkeys: " + GetKeys() + " | \nindexes: " + indexes)

endFunction

function protected_remove(string asKey, bool dispel = true)
    int index = JMap.getInt(dataIds, asKey)
    int[] indexes = JArray.asIntArray(JMap.allValues(dataIds))

    ; Debug("ActiveMagicEffectList::protected_remove", "Removed Key: " + asKey + " | Index: "+ index +" | data["+ index +"]: " + data[index])
    ; Debug("ActiveMagicEffectList::protected_remove", "\ndata: " + data + " | \nkeys: " + GetKeys() + " | \nindexes: " + indexes)
    ; Debug("ActiveMagicEffectList::protected_remove", "___________________________________________________________________________________")
    if (dispel)
        data[index].Dispel()
    endif
    
    reindex_data(asKey)
    return

    ; data[index] = none
    ; JMap.removeKey(dataIds, asKey)

    ; Re-index data structure
    string prisonerKey  = JMap.getNthKey(dataIds, (index + 1)) ; Taarie
    int nextIndex       = JMap.getInt(dataIds, prisonerKey) ; 0
    bool indexExists    = JMap.valueType(dataIds, prisonerKey) != 0

    data[index]                 = none                              ; Remove current Element
    string removedPrisonerKey   = JMap.getNthKey(dataIds, index)    ; Key for the Element
    JMap.removeKey(dataIds, removedPrisonerKey)                     ; Remove key for element

    int i = index
    while (i < data.Length - 1)
        bool isInBounds = (i + 1) < data.Length
        data[i] = data[i + 1]
        if (isInBounds)
            string nextElementKey   = JMap.getNthKey(dataIds, i + 1)
            int removedValue        = JMap.getInt(dataIds, nextElementKey)
            JMap.removeKey(dataIds, nextElementKey)
            JMap.setInt(dataIds, nextElementKey, i)
            Debug("ActiveMagicEffectList::protected_remove", "Moved data["+ (i+1) +"] to data["+ i +"] ("+ nextElementKey +")")
            Debug("ActiveMagicEffectList::protected_remove", "Removed value: " + removedValue)
        endif
        i += 1
    endWhile

    data[data.Length - 1] = none
    Debug("ActiveMagicEffectList::protected_remove", "Deleted data["+(data.Length - 1)+"]")
    ; int n = index
    ; while (n < data.Length - 1)
    ;     string nextElementKey = JMap.getNthKey(dataIds, n + 1)
    ;     JMap.setInt(dataIds, nextElementKey, n)
    ;     n += 1
    ; endWhile

    string lastKey = JMap.getNthKey(dataIds, data.Length - 1)
    if (JMap.hasKey(dataIds, lastKey))
        JMap.removeKey(dataIds, lastKey)
        Debug("ActiveMagicEffectList::protected_remove", "Removed Key from data["+ (data.Length - 1) +"]: " + lastKey)
    endif

    ; if (data[index + 1] != none)
    ;     data[index] = data[index + 1]
    ;     string prisonerKey = JMap.getNthKey(dataIds, (index + 1))
    ;     JMap.setInt(dataIds, prisonerKey, index)
    ; else
    ;     data[index] = none
    ;     JMap.removeKey(dataIds, asKey)
    ; endif

    indexes = JArray.asIntArray(JMap.allValues(dataIds))
    Debug("ActiveMagicEffectList::protected_remove", "Removed Key: " + asKey + " | Index: "+ index +" | data["+ index +"]: " + data[index])
    Debug("ActiveMagicEffectList::protected_remove", "\ndata: " + data + " | \nkeys: " + GetKeys() + " | \nindexes: " + indexes)
endFunction

; function Remove(string asKey, bool dispel = true)
;     int index = JMap.getInt(dataIds, asKey)

;     if (dispel)
;         data[index].Dispel()
;     endif
    
;     data[index] = none
;     JMap.removeKey(dataIds, asKey)
; endFunction

; function AddAt(ActiveMagicEffect ame, int id)
;     self.Initialize()
;     if (data[nextAvailableIndex] == none)
;         JIntMap.setInt(dataIds, id, nextAvailableIndex)
;         data[nextAvailableIndex] = ame
;         nextAvailableIndex += 1
;         Debug(self, "ActiveMagicEffectList::Add", "Added ActiveMagicEffect: " + ame + " at index: " + nextAvailableIndex + " through nextAvailableIndex")

;     ; else
;     ;     int i = 0
;     ;     while (i < data.Length)
;     ;         if (data[i] == none)
;     ;             JIntMap.setInt(dataIds, id, i)
;     ;             data[i] = ame
;     ;             nextAvailableIndex = i + 1
;     ;             Debug(self, "ActiveMagicEffectList::AddAt", "Added ActiveMagicEffect: " + ame + " at index: " + i)
;     ;         endif
;     ;         i += 1
;     ;     endWhile
;     endif
; endFunction

; ActiveMagicEffect function GetAt(int id)
;     int arrayIndex = JIntMap.getInt(dataIds, id)
;     Debug(self, "ActiveMagicEffectList::Get", "Retrieved ActiveMagicEffect: " + data[arrayIndex] + " at index: " + arrayIndex)
;     return data[arrayIndex]
; endFunction

; int function GetArrayIndex(int id)
;     return JIntMap.getInt(dataIds, id)
; endFunction

; function Remove(int id, bool dispel = true)
;     int index = self.GetArrayIndex(id)

;     if (dispel)
;         data[index].Dispel()
;     endif
    
;     data[index] = none
;     JIntMap.removeKey(dataIds, id)
; endFunction

function Initialize()
    if (!dataIds || !data)
        dataIds = JIntMap.object()
        data = new ActiveMagicEffect[100]
    endif
    Debug("ActiveMagicEffectList::Initialize", "Initialized list")
endFunction

event OnInit()
    Debug("ActiveMagicEffectList::OnInit", "OnInit")
    dataIds = JMap.object()
    JValue.retain(dataIds)
    data = new ActiveMagicEffect[128]
endEvent


; =========================================================
;                          public                          
; =========================================================

int function GetSize()
    return JValue.count(dataIds)
endFunction

bool function IsEmpty()
    return JValue.count(dataIds) <= 0
endFunction

string[] function GetKeys()
    return JMap.allKeysPArray(dataIds)
endFunction

string function GetValuesAsString()
    int valueCount = JMap.count(dataIds)
    string values = ""

    int i = 0
    while (i < valueCount)
        bool hasNextElement = data[i + 1] != none
        values += (data[i] as string) + string_if (hasNextElement, ", ")
        i += 1
    endWhile

    return "["+ values +"]"
endFunction

function AddElement(ActiveMagicEffect element, string elementKey)
    bool keyExists = JMap.hasKey(dataIds, elementKey)

    if (keyExists)
        Error("Element "+ elementKey +" already exists, cannot add it again!")
        return
    endif

    int availableIndex = __private_getAvailableIndex()
    
    if (!data[availableIndex])
        data[availableIndex] = element                      ; Assign the Data
        JMap.setInt(dataIds, elementKey, availableIndex)    ; Assign the index to the key
        JArray.addStr(dataKeys, elementKey)                 ; Assign the Key
    endif
endFunction

function RemoveElement(string elementKey, bool dispel = true)
    int index = JMap.getInt(dataIds, elementKey)

    if (dispel)
        data[index].Dispel()
    endif

    bool isLastElement = __private_moveLastElementToIndex(index)

    if (isLastElement)
        data[index] = none
    endif

    JMap.removeKey(dataIds, elementKey)         ; Delete the Index
    JArray.eraseString(dataKeys, elementKey)    ; Delete the Key

    ; ; Only if the current element is not the last
    ; if (index < (size - 1))
    ;     ; Reorder the last element to this index
    ;     data[index] = data[size - 1]
    ;     data[size - 1] = none
    ;     int oldElementIndex = __private_getIndexFromPosition(size - 1)
    ;     string newElementKey = __private_getKeyForIndex(oldElementIndex)
    ;     __private_changeElementIndex(newElementKey, index)
    ; else
    ;     data[index] = none ; Delete the Data, this is the last element
    ; endif

    ; JMap.removeKey(dataIds, elementKey)         ; Delete the Index
    ; JArray.eraseString(dataKeys, elementKey)    ; Delete the Key


    ; __private_reindex()
endFunction

; =========================================================
;                         protected                        
; =========================================================

function __protected_addAtKey(ActiveMagicEffect element, string elementKey)
endFunction

function __protected_addAtIndex(ActiveMagicEffect element, int elementIndex)
endFunction

function __protected_removeElement(string keyToRemove)
endFunction

ActiveMagicEffect function __protected_fromIndex(int index)
endFunction

ActiveMagicEffect function __protected_fromKey(string keyElement)
endFunction

function __protected_listData()
    int arrayLength         = JValue.count(dataIds)
    int[] mapIndices        = JArray.asIntArray(JMap.allValues(dataIds))
    string[] elementKeys    = JArray.asStringArray(JMap.allKeys(dataIds))

    LogNoType("Element Keys: " + elementKeys)

    int i = 0
    while (i < arrayLength)
        string tabs = string_if (StringUtil.GetLength(data[i]) >= 10, "\t\t", "\t\t\t")
        string keyFromMap   = JMap.getNthKey(dataIds, i)
        int indexFromMap    = __private_getIndexFromPosition(i)
        LogNoType(i + ": data["+indexFromMap+"] = " + data[indexFromMap] + tabs + "(Key: "+ keyFromMap +")")
        i += 1
    endWhile
endFunction

; =========================================================
;                          private                         
; =========================================================

int[] function __private_getIndices()
    return JArray.asIntArray(JMap.allValues(dataIds))
endFunction

ActiveMagicEffect[] function __private_getElements()
    return data
endFunction

string[] function __private_getKeys()
    return JArray.asStringArray(JMap.allKeys(dataIds))
endFunction

string function __private_getKeyForIndex(int index)
    return JMap.getNthKey(dataIds, index)
    ; return JArray.getStr(dataKeys, index)
endFunction

int function __private_get_indexForKey(string elementKey)
    int index = JMap.getInt(dataIds, elementKey)
    return index
endFunction

int function __private_getIndexFromPosition(int indexPosition)
    int index = JArray.findInt(JMap.allValues(dataIds), indexPosition)
    return index
endFunction

ActiveMagicEffect function __private_getValueByIndex(int index)
    if (index < 0 || index >= JArray.count(dataKeys))
        return none
    endif

    string elementKey   = JMap.getNthKey(dataIds, index)
    ; string elementKey   = JArray.getStr(dataKeys, index)
    int elementIndex    = JMap.getInt(dataIds, elementKey)

    return data[elementIndex]
endFunction

ActiveMagicEffect function __private_getValueByKey(string elementKey)
    int elementIndex = JMap.getInt(dataIds, elementKey)
    return data[elementIndex]
endFunction

; Returns the element's old index
int function __private_changeElementIndex(string elementKey, int newIndex)
    int oldIndex = JMap.getInt(dataIds, elementKey)
    JMap.setInt(dataIds, elementKey, newIndex)

    return oldIndex
endFunction

;/
    Moves the last element in the list to the position specified by @index.

    int @index: The index in the list to move the last element to.

    returns (bool): true if @index is the last element, false otherwise. 
/;
bool function __private_moveLastElementToIndex(int index)
    int size  = self.GetSize()
    bool isLastElement = index >= size - 1

    if (isLastElement)
        return true
    endif

    data[index] = data[size - 1]
    data[size - 1] = none

    ; Get the last element index
    int oldElementIndex = __private_getIndexFromPosition(size - 1)

    ; Get the key for last element
    string elementKey   = __private_getKeyForIndex(oldElementIndex)

    ; Refresh the index mapping used to access data[] (changes last element index to @index)
    __private_changeElementIndex(elementKey, index)

    return false
endFunction

string function __private_listIndicesRelationToKeys()
    ; Example element relation: 1: Prisoner[104610]
    int arrayLength         = self.GetSize()
    int[] elementsIndices   = __private_getIndices()

    string retval = "["

    int i = 0
    while (i < arrayLength)
        int elementIndex        = __private_getIndexFromPosition(i)
        string elementKey       = __private_getKeyForIndex(elementIndex)
        string elementRelation  = elementsIndices[i] + ": " + elementKey
        if (i < (arrayLength - 1))
            elementRelation += ", "
        endif
        retval += elementRelation
        i += 1
    endWhile

    return retval + "]"
endFunction

int function __private_getAvailableIndex()
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

function __private_reindex()
    int arrayLength = JValue.count(dataIds)

    int i = 0
    while (i < arrayLength)
        bool isEmptyElement = !data[i] || data[i] == "None" || data[i] == ""
        string elementKey   = __private_getKeyForIndex(i)
        int indexInMap      = __private_get_indexForKey(elementKey)

        if (isEmptyElement)
            string nextElementKey   = __private_getKeyForIndex(i + 1)
            int nextElementIndex    = __private_get_indexForKey(nextElementKey)

            data[i] = data[nextElementIndex]        ; Assign the next element to this
            JMap.setInt(dataIds, nextElementKey, i) ; Assign new index to this key, no need to delete the index because it's mapped to the key, only change it
            data[nextElementIndex] = none

            ; Debug("TestList::__private_reindex", "Shifted "+ data[i] + " from index " + nextElementIndex + " to index " + i + " | " + data)
        endif
        i += 1
    endWhile
endFunction

function __private_sort(string fnSortCallback)
    ; Implement the function callback on a state's OnBeginState and then return
endFunction

function __private_alloc()
endFunction

function __private_dealloc()
endFunction

function __private_initialize()
    if (!data || !dataIds)
        dataIds     = JMap.object()
        dataKeys    = JArray.object()

        JValue.retain(dataIds)
        JValue.retain(dataKeys)

        data = new ActiveMagicEffect[20]
    endif
endFunction

bool __isInitialized

; =========================================================
;                           Events                         
; =========================================================

event OnElementAdded(ActiveMagicEffect element, string elementKey, int elementIndex)
endEvent

event OnElementRemoved(ActiveMagicEffect element, string elementKey, int elementIndex)
endEvent

