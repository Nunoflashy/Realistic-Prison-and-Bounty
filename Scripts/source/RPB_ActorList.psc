scriptname RPB_ActorList extends RPB_ActiveMagicEffectContainer

import RPB_Memory

string function ListIdentifier() ; abstract
    return "ActorList"
endFunction

RPB_ActorBase function AtKeyEx(Actor akActor) ; virtual
    ; string elementKey = self.GetActorIdentifier(akActor)
    return parent.GetAt(akActor) as RPB_ActorBase
endFunction

string function GetActorIdentifier(Actor akActor) ; virtual
endFunction

Form[] function GetActors()
    int actorArray = FastArray("<Form>")

    int i = 0
    while (i < Count)
        RPB_ActorBase actorRef = FromIndex(i) as RPB_ActorBase
        if (actorRef)
            FastArray_AddForm(actorArray, actorRef.GetActor())
        endif
        i += 1
    endWhile

    return FastArray_ToFormArray(actorArray)
endFunction

; RPB_ActorBase function AtIndex(int aiIndex)
;     return parent.FromIndex(aiIndex) as RPB_ActorBase
; endFunction

; bool function Exists(RPB_ActorBase apActor)
;     return self.AtKey(apActor.GetActor()) == apActor
; endFunction

; bool function Add(RPB_ActorBase apActor)
;     string elementKey = self.GetActorIdentifier(apActor.GetActor())
;     parent.AddElement(apActor, elementKey)
; endFunction

; function Remove(RPB_ActorBase apActor)
;     string elementKey = self.GetActorIdentifier(apActor.GetActor())
;     parent.RemoveElement(elementKey)
; endFunction