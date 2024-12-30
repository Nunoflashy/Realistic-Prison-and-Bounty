scriptname RPB_ArresteeList extends RPB_ActorList

string function ListIdentifier()
    return "ArresteeList"
endFunction

string function GetArresteeID(Actor akActor)
    return "Arrestee["+ akActor.GetFormID() +"]"
endFunction

RPB_Arrestee function AtKey(Actor akActor)
    string elementKey = self.GetArresteeID(akActor)
    return parent.GetAt(elementKey) as RPB_Arrestee
endFunction

RPB_Arrestee function AtIndex(int aiIndex)
    return parent.FromIndex(aiIndex) as RPB_Arrestee
endFunction

bool function Exists(RPB_Arrestee apArrestee)
    return self.AtKey(apArrestee.GetActor()) == apArrestee
endFunction

bool function Add(RPB_Arrestee apArrestee)
    string elementKey = self.GetArresteeID(apArrestee.GetActor())
    parent.AddElement(apArrestee, elementKey)
endFunction

function Remove(RPB_Arrestee apArrestee)
    string elementKey = self.GetArresteeID(apArrestee.GetActor())
    parent.RemoveElement(elementKey)

    Spell arresteeSpell = RPB_Utility.RPB_ArresteeSpell()
    apArrestee.RemoveSpell(arresteeSpell)

    apArrestee.RemoveAll()
endFunction


string function GetActorIdentifier(Actor akActor) ; override
    return "Arrestee["+ akActor.GetFormID() +"]"
endFunction

RPB_ActorBase function AtKeyEx(Actor akActor)
    string elementKey = self.GetActorIdentifier(akActor)
    return parent.GetAt(elementKey) as RPB_ActorBase
endFunction

; function Remove(RPB_ActorBase apArrestee)
;     parent.Remove(apArrestee)
;     Spell arresteeSpell = RPB_Utility.RPB_ArresteeSpell()
;     apArrestee.RemoveSpell(arresteeSpell)

;     (apArrestee as RPB_Arrestee).RemoveAll()
; endFunction