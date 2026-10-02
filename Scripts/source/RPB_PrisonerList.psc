scriptname RPB_PrisonerList extends RPB_ActorList

string function ListIdentifier()
    return "PrisonerList"
endFunction

string function GetPrisonerID(Actor akActor)
    return "Prisoner["+ akActor.GetFormID() +"]"
endFunction

RPB_Prisoner function AtKey(Actor akActor)
    return self.__EntryOf(akActor) as RPB_Prisoner ; the actor index: no call into him
endFunction

RPB_Prisoner function AtIndex(int aiIndex)
    return parent.FromIndex(aiIndex) as RPB_Prisoner
endFunction

bool function Exists(RPB_Prisoner apPrisoner)
    return self.AtKey(apPrisoner.GetActor()) == apPrisoner
endFunction

bool function Add(RPB_Prisoner apPrisonerRef)
    Actor prisonerActor = apPrisonerRef.GetActor()
    string elementKey = self.KeyOf(prisonerActor)
    if (elementKey == "")
        elementKey = self.GetPrisonerID(prisonerActor) ; a new entry: his key built once
    endif

    ; A key that already exists holds the instance of an effect that ended (the actor unloaded and loaded again, which starts
    ; a new instance): point it at this live one instead of refusing the duplicate.
    if (parent.HasKey(elementKey))
        parent.ReplaceElement(apPrisonerRef, elementKey)
    else
        parent.AddElement(apPrisonerRef, elementKey)
    endif
    self.__IndexActor(prisonerActor, elementKey)
endFunction

function Remove(RPB_Prisoner apPrisoner)
    Actor prisonerActor = apPrisoner.GetActor()
    string elementKey = self.KeyOf(prisonerActor)
    if (elementKey == "")
        elementKey = self.GetPrisonerID(prisonerActor)
    endif

    RPB_Utility.Debug("PrisonerList::Remove", "Removed Prisoner " + apPrisoner + " ["+ apPrisoner.Name +"]")

    Spell prisonerSpell = RPB_Utility.RPB_PrisonerSpell()
    apPrisoner.RemoveSpell(prisonerSpell)

    ; apPrisoner.RemoveAll()
    ; apPrisoner.RemoveAll("Arrest") ; Needs to be reviewed, do we really want to delete Arrest-related category for Prisoners?

    parent.RemoveElement(elementKey)
    self.__UnindexActor(prisonerActor)
endFunction



string function GetActorIdentifier(Actor akActor) ; override
    return "Prisoner["+ akActor.GetFormID() +"]"
endFunction

RPB_ActorBase function AtKeyEx(Actor akActor)
    return self.__EntryOf(akActor)
endFunction

; function Remove(RPB_ActorBase apPrisoner)
;     parent.Remove(apPrisoner)
;     Spell arresteeSpell = RPB_Utility.RPB_ArresteeSpell()

;     Spell prisonerSpell = RPB_Utility.RPB_PrisonerSpell()
;     (apPrisoner as RPB_Prisoner).RemoveSpell(prisonerSpell)

;     (apPrisoner as RPB_Prisoner).RemoveAll()
;     (apPrisoner as RPB_Prisoner).RemoveAll("Arrest") ; Needs to be reviewed, do we really want to delete Arrest-related category for Prisoners?
; endFunction