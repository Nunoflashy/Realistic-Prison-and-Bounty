scriptname RPB_ActiveMagicEffectContainer extends Quest

;/
    TODO: Sort list after removing an element, or adding it.
/;

import RealisticPrisonAndBounty_Util

int dataIds
ActiveMagicEffect[] data = none

int nextAvailableIndex

; TODO: Implement method to retrieve size of specific key category (Arrest, Prisoner, Captor, etc)
int function GetSize()
    return data.Length
endFunction

int function GetAvailableIndex()
    int i = 0
    while (i < data.Length)
        if (data[i] == none)
            ; nextAvailableIndex = i
            return i
        endif
        i += 1
    endWhile
endFunction

string[] function GetKeys()
    return JMap.allKeysPArray(dataIds)
endFunction

function AddAt(ActiveMagicEffect apActiveMagicEffect, string asKey)
    ; Initialize array
    ; if (!dataIds || !data)
    ;     dataIds = JMap.object()
    ;     JValue.retain(dataIds)
    ;     data = new ActiveMagicEffect[128]
    ; endif

    ; int availableIndex = self.GetAvailableIndex()

    if (data[nextAvailableIndex] == none)
        data[nextAvailableIndex] = apActiveMagicEffect ; Assign AME to this index
        JMap.setInt(dataIds, asKey, nextAvailableIndex) ; Store the index at this key
        ; Debug(self, "ActiveMagicEffectList::Add", "Added ActiveMagicEffect: " + apActiveMagicEffect + " at index: " + nextAvailableIndex + ".")
        nextAvailableIndex += 1
    endif
endFunction

ActiveMagicEffect function GetAt(string asKey)
    int arrayIndex = JMap.getInt(dataIds, asKey)
    ; Debug(self, "ActiveMagicEffectList::Get", "Retrieved ActiveMagicEffect: " + data[arrayIndex] + " at index: " + arrayIndex + ", from key: " + asKey)
    return data[arrayIndex]
endFunction

ActiveMagicEffect[] function GetAsArray()
    return data
endFunction

function Remove(string asKey, bool dispel = true)
    int index = JMap.getInt(dataIds, asKey)

    if (dispel)
        data[index].Dispel()
    endif
    
    data[index] = none
    JMap.removeKey(dataIds, asKey)
endFunction

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
    Debug(self, "ActiveMagicEffectList::Initialize", "Initialized list")
endFunction

event OnInit()
    Debug(self, "ActiveMagicEffectList::OnInit", "OnInit")
    dataIds = JMap.object()
    JValue.retain(dataIds)
    data = new ActiveMagicEffect[128]
endEvent