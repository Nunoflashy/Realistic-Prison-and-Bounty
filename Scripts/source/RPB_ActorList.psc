scriptname RPB_ActorList extends RPB_ActiveMagicEffectContainer

import RPB_Memory

string function ListIdentifier() ; abstract
    return "ActorList"
endFunction

RPB_Actor function AtKeyEx(Actor akActor) ; virtual
endFunction

string function GetActorIdentifier(Actor akActor) ; virtual
endFunction

Form[] function GetActors()
    int actorArray = FastArray("<Form>")

    int i = 0
    while (i < Count)
        RPB_Actor actorRef = FromIndex(i) as RPB_Actor
        if (actorRef)
            FastArray_AddForm(actorArray, actorRef.GetActor())
        endif
        i += 1
    endWhile

    return FastArray_ToFormArray(actorArray)
endFunction

; RPB_Actor function AtIndex(int aiIndex)
;     return parent.FromIndex(aiIndex) as RPB_Actor
; endFunction

; bool function Exists(RPB_Actor apActor)
;     return self.AtKey(apActor.GetActor()) == apActor
; endFunction

; bool function Add(RPB_Actor apActor)
;     string elementKey = self.GetActorIdentifier(apActor.GetActor())
;     parent.AddElement(apActor, elementKey)
; endFunction

; function Remove(RPB_Actor apActor)
;     string elementKey = self.GetActorIdentifier(apActor.GetActor())
;     parent.RemoveElement(elementKey)
; endFunction