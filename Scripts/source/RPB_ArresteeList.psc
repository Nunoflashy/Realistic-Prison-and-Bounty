scriptname RPB_ArresteeList extends RPB_ActiveMagicEffectContainer

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