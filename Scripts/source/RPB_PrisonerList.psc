scriptname RPB_PrisonerList extends RPB_ActiveMagicEffectContainer

; How many prisoners are in the list
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
    parent.AddAt(apPrisonerRef, elementKey)
endFunction

function Remove(RPB_Prisoner apPrisoner)
    string elementKey = self.GetPrisonerID(apPrisoner.GetActor())
    protected_remove(elementKey)

    apPrisoner.Prison_RemoveAll()
    apPrisoner.Prison_RemoveAll("Arrest")
