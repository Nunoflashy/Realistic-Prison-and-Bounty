scriptname RPB_ActorList extends RPB_ActiveMagicEffectContainer

import RPB_Memory

string function ListIdentifier() ; abstract
    return "ActorList"
endFunction

RPB_ActorBase function AtKeyEx(Actor akActor) ; virtual
    return self.__EntryOf(akActor)
endFunction

; ==========================================================
;              Actor -> key, without calling him
; ==========================================================

;/
    The lists are keyed by "<List>[<FormID>]", and building that key called GetFormID() on the actor: a frame per lookup
    (11 ms measured, test 157), and a lookup that waits forever on a frozen actor (2026-10-02). This index maps the actor
    (the Form itself, a JFormMap) to his key, so a lookup is a JContainers read (0.4 ms) and never calls into him. Kept
    up to date by Add/Remove; rebuilt once after every load from the entries themselves (each effect already holds its
    actor), so a save from before this index needs no conversion.
/;
int __actorToKey
float __actorIndexStamp

string function KeyOf(Actor akActor)
    if (!akActor)
        return ""
    endif
    self.__EnsureActorIndex()
    return JFormMap.getStr(__actorToKey, akActor)
endFunction

; The entry of @akActor, or none. An index entry whose element is gone is dropped
RPB_ActorBase function __EntryOf(Actor akActor)
    string elementKey = self.KeyOf(akActor)
    if (elementKey == "")
        return none
    endif
    RPB_ActorBase entry = parent.GetAt(elementKey) as RPB_ActorBase
    if (!entry)
        JFormMap.removeKey(__actorToKey, akActor)
    endif
    return entry
endFunction

function __IndexActor(Actor akActor, string asKey)
    if (!akActor || asKey == "")
        return
    endif
    self.__EnsureActorIndex()
    JFormMap.setStr(__actorToKey, akActor, asKey)
endFunction

function __UnindexActor(Actor akActor)
    if (akActor && __actorToKey)
        JFormMap.removeKey(__actorToKey, akActor)
    endif
endFunction

; Built when missing, and again once after each load (RPB_ConfigAlias stamps every load): calls no actor
function __EnsureActorIndex()
    float stamp = JDB.solveFlt(".rpb_root.loadStamp")
    if (__actorToKey && __actorIndexStamp == stamp)
        return
    endif
    if (!__actorToKey)
        __actorToKey = JValue.retain(JFormMap.object())
    else
        JFormMap.clear(__actorToKey)
    endif
    __actorIndexStamp = stamp
    int i = 0
    int total = Count
    while (i < total)
        RPB_ActorBase entry = FromIndex(i) as RPB_ActorBase
        string elementKey = GetKeyAtIndex(i)
        if (entry && elementKey != "")
            Actor entryActor = entry.GetActor()
            if (entryActor)
                JFormMap.setStr(__actorToKey, entryActor, elementKey)
            endif
        endif
        i += 1
    endWhile
endFunction

string function GetActorIdentifier(Actor akActor) ; virtual
endFunction

Form[] function GetActors()
    int actorArray = FastArray("<Form>")

    int i = 0
    while (i < Count)
        RPB_ActorBase actorRef = FromIndex(i) as RPB_ActorBase
        if (actorRef)
            FastArray_AddForm(actorArray, actorRef.GetActor())
        endif
        i += 1
    endWhile

    return FastArray_ToFormArray(actorArray)
endFunction

; RPB_ActorBase function AtIndex(int aiIndex)
;     return parent.FromIndex(aiIndex) as RPB_ActorBase
; endFunction

; bool function Exists(RPB_ActorBase apActor)
;     return self.AtKey(apActor.GetActor()) == apActor
; endFunction

; bool function Add(RPB_ActorBase apActor)
;     string elementKey = self.GetActorIdentifier(apActor.GetActor())
;     parent.AddElement(apActor, elementKey)
; endFunction

; function Remove(RPB_ActorBase apActor)
;     string elementKey = self.GetActorIdentifier(apActor.GetActor())
;     parent.RemoveElement(elementKey)
; endFunction