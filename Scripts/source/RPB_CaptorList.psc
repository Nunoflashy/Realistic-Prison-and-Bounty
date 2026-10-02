scriptname RPB_CaptorList extends RPB_ActorList

string function ListIdentifier()
    return "CaptorList"
endFunction

string function GetCaptorID(Actor akActor)
    return "Captor["+ akActor.GetFormID() +"]"
endFunction

RPB_Captor function AtKey(Actor akActor)
    return self.__EntryOf(akActor) as RPB_Captor ; the actor index: no call into him
endFunction

RPB_Captor function AtIndex(int aiIndex)
    return parent.FromIndex(aiIndex) as RPB_Captor
endFunction

bool function Exists(RPB_Captor apCaptor)
    return self.AtKey(apCaptor.GetActor()) == apCaptor
endFunction

bool function Add(RPB_Captor apCaptorRef)
    Actor captorActor = apCaptorRef.GetActor()
    string elementKey = self.KeyOf(captorActor)
    if (elementKey == "")
        elementKey = self.GetCaptorID(captorActor) ; a new entry: his key built once
    endif

    ; A key that already exists holds the instance of an effect that ended (the actor unloaded and loaded again, which starts
    ; a new instance): point it at this live one instead of refusing the duplicate. Mirrors RPB_PrisonerList.Add() - a guard's
    ; RPB_Captor instance is torn down and restarted by the same 3D-unload mechanism a prisoner's instance is.
    if (parent.HasKey(elementKey))
        parent.ReplaceElement(apCaptorRef, elementKey)
    else
        parent.AddElement(apCaptorRef, elementKey)
    endif
    self.__IndexActor(captorActor, elementKey)
endFunction

function Remove(RPB_Captor apCaptor)
    Actor captorActor = apCaptor.GetActor()
    string elementKey = self.KeyOf(captorActor)
    if (elementKey == "")
        elementKey = self.GetCaptorID(captorActor)
    endif
    protected_remove(elementKey)
    self.__UnindexActor(captorActor)
endFunction



string function GetActorIdentifier(Actor akActor) ; override
    return "Captor["+ akActor.GetFormID() +"]"
endFunction

RPB_ActorBase function AtKeyEx(Actor akActor)
    return self.__EntryOf(akActor)
endFunction