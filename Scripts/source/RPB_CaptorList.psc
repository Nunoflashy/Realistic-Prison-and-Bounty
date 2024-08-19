scriptname RPB_CaptorList extends RPB_ActiveMagicEffectContainer

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
    string elementKey = self.GetCaptorID(apCaptorRef.GetActor())
    parent.AddElement(apCaptorRef, elementKey)
endFunction

function Remove(RPB_Captor apCaptor)
    protected_remove(self.GetCaptorID(apCaptor.GetActor()))
endFunction