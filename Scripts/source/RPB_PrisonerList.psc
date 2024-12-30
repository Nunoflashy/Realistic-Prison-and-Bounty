scriptname RPB_PrisonerList extends RPB_ActorList

string function ListIdentifier()
    return "PrisonerList"
endFunction

string function GetPrisonerID(Actor akActor)
    return "Prisoner["+ akActor.GetFormID() +"]"
endFunction

RPB_Prisoner function AtKey(Actor akActor)
    string elementKey = self.GetPrisonerID(akActor)
    return parent.GetAt(elementKey) as RPB_Prisoner
endFunction

RPB_Prisoner function AtIndex(int aiIndex)
    return parent.FromIndex(aiIndex) as RPB_Prisoner
endFunction

bool function Exists(RPB_Prisoner apPrisoner)
    return self.AtKey(apPrisoner.GetActor()) == apPrisoner
endFunction

bool function Add(RPB_Prisoner apPrisonerRef)
    string elementKey = self.GetPrisonerID(apPrisonerRef.GetActor())
    parent.AddElement(apPrisonerRef, elementKey)
endFunction

function Remove(RPB_Prisoner apPrisoner)
    string elementKey = self.GetPrisonerID(apPrisoner.GetActor())

    RPB_Utility.Debug("PrisonerList::Remove", "Removed Prisoner " + apPrisoner + " ["+ apPrisoner.Name +"]")

    Spell prisonerSpell = RPB_Utility.RPB_PrisonerSpell()
    apPrisoner.RemoveSpell(prisonerSpell)

    ; apPrisoner.RemoveAll()
    ; apPrisoner.RemoveAll("Arrest") ; Needs to be reviewed, do we really want to delete Arrest-related category for Prisoners?

    parent.RemoveElement(elementKey)
endFunction



string function GetActorIdentifier(Actor akActor) ; override
    return "Prisoner["+ akActor.GetFormID() +"]"
endFunction

RPB_ActorBase function AtKeyEx(Actor akActor)
    string elementKey = self.GetActorIdentifier(akActor)
    return parent.GetAt(elementKey) as RPB_ActorBase
endFunction

; function Remove(RPB_ActorBase apPrisoner)
;     parent.Remove(apPrisoner)
;     Spell arresteeSpell = RPB_Utility.RPB_ArresteeSpell()

;     Spell prisonerSpell = RPB_Utility.RPB_PrisonerSpell()
;     (apPrisoner as RPB_Prisoner).RemoveSpell(prisonerSpell)

;     (apPrisoner as RPB_Prisoner).RemoveAll()
;     (apPrisoner as RPB_Prisoner).RemoveAll("Arrest") ; Needs to be reviewed, do we really want to delete Arrest-related category for Prisoners?
; endFunction