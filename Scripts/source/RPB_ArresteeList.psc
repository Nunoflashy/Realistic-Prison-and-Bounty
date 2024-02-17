scriptname RPB_ArresteeList extends RPB_ActiveMagicEffectContainer

; How many arrestees are in the list
int property Count
    int function get()
        int containerSize = parent.GetSize()
        int _count = 0
        int i = 0
        while (i < containerSize)
            if (self.AtIndex(i) != none)
                _count += 1
            endif
            i += 1
        endWhile

        return _count
    endFunction
endProperty

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
    parent.AddAt(apArrestee, elementKey)
endFunction

function Remove(RPB_Arrestee apArrestee)
    string elementKey = self.GetArresteeID(apArrestee.GetActor())
    protected_remove(elementKey)

    apArrestee.Arrest_RemoveAll()
endFunction