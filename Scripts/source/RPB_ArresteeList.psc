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
    return parent.GetAt("Arrestee["+ akActor.GetFormID() +"]") as RPB_Arrestee
endFunction

RPB_Arrestee function AtIndex(int aiIndex)
    return parent.FromIndex(aiIndex) as RPB_Arrestee
endFunction

bool function Exists(RPB_Arrestee apArrestee)
    return self.AtKey(apArrestee.GetActor()) == apArrestee
endFunction

bool function Add(RPB_Arrestee apArresteeRef)
    parent.AddAt(apArresteeRef, self.GetArresteeID(apArresteeRef.GetActor()))
endFunction

function Remove(RPB_Arrestee apArrestee)
    protected_remove(self.GetArresteeID(apArrestee.GetActor()))
endFunction