scriptname RPB_CaptorList extends RPB_ActiveMagicEffectContainer

; How many Captors are in the list
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

string function GetCaptorID(Actor akActor)
    return "Captor["+ akActor.GetFormID() +"]"
endFunction

RPB_Captor function AtKey(Actor akActor)
    return parent.GetAt("Captor["+ akActor.GetFormID() +"]") as RPB_Captor
endFunction

RPB_Captor function AtIndex(int aiIndex)
    return parent.FromIndex(aiIndex) as RPB_Captor
endFunction

bool function Exists(RPB_Captor apCaptor)
    return self.AtKey(apCaptor.GetActor()) == apCaptor
endFunction

bool function Add(RPB_Captor apCaptorRef)
    parent.AddAt(apCaptorRef, self.GetCaptorID(apCaptorRef.GetActor()))
endFunction

function Remove(RPB_Captor apCaptor)
    protected_remove(self.GetCaptorID(apCaptor.GetActor()))
endFunction