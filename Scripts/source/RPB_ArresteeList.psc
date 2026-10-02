scriptname RPB_ArresteeList extends RPB_ActorList

string function ListIdentifier()
    return "ArresteeList"
endFunction

string function GetArresteeID(Actor akActor)
    return "Arrestee["+ akActor.GetFormID() +"]"
endFunction

RPB_Arrestee function AtKey(Actor akActor)
    return self.__EntryOf(akActor) as RPB_Arrestee ; the actor index: no call into him
endFunction

RPB_Arrestee function AtIndex(int aiIndex)
    return parent.FromIndex(aiIndex) as RPB_Arrestee
endFunction

bool function Exists(RPB_Arrestee apArrestee)
    return self.AtKey(apArrestee.GetActor()) == apArrestee
endFunction

bool function Add(RPB_Arrestee apArrestee)
    Actor arresteeActor = apArrestee.GetActor()
    string elementKey = self.KeyOf(arresteeActor)
    if (elementKey == "")
        elementKey = self.GetArresteeID(arresteeActor) ; a new entry: his key built once
    endif

    ; A key that already exists holds the instance of an effect that ended (the actor unloaded and loaded again, which starts
    ; a new instance): point it at this live one instead of refusing the duplicate. Mirrors RPB_PrisonerList.Add() - this list
    ; had the same unconditional-add gap that RPB_CaptorList did, just not yet reported as its own error.
    if (parent.HasKey(elementKey))
        parent.ReplaceElement(apArrestee, elementKey)
    else
        parent.AddElement(apArrestee, elementKey)
    endif
    self.__IndexActor(arresteeActor, elementKey)
endFunction

function Remove(RPB_Arrestee apArrestee)
    Actor arresteeActor = apArrestee.GetActor()
    string elementKey = self.KeyOf(arresteeActor)
    if (elementKey == "")
        elementKey = self.GetArresteeID(arresteeActor)
    endif
    parent.RemoveElement(elementKey)
    self.__UnindexActor(arresteeActor)

    Spell arresteeSpell = RPB_Utility.RPB_ArresteeSpell()
    apArrestee.RemoveSpell(arresteeSpell)

    apArrestee.RemoveAll()
endFunction


string function GetActorIdentifier(Actor akActor) ; override
    return "Arrestee["+ akActor.GetFormID() +"]"
endFunction

RPB_ActorBase function AtKeyEx(Actor akActor)
    return self.__EntryOf(akActor)
endFunction

; function Remove(RPB_ActorBase apArrestee)
;     parent.Remove(apArrestee)
;     Spell arresteeSpell = RPB_Utility.RPB_ArresteeSpell()
;     apArrestee.RemoveSpell(arresteeSpell)

;     (apArrestee as RPB_Arrestee).RemoveAll()
; endFunction