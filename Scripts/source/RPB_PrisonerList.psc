scriptname RPB_PrisonerList extends RPB_ActiveMagicEffectContainer

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
    parent.RemoveElement(elementKey)

    apPrisoner.RemoveAll()
    apPrisoner.RemoveAll("Arrest")
endFunction
