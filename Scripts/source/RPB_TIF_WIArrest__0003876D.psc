;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname RPB_TIF_WIArrest__0003876D Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
GetOwningQuest().SetStage(10) ; vanilla's: the 100 bounty of the accusation
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
RPB_Utility.SendWorldInteractionArrestAnswer(akSpeaker, GetOwningQuest(), 10)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; The dead-body accusation's arrest ("Doesn't scare me." -> "Alright, you are now under arrest."): vanilla's stage 10 (the
; bounty) kept. Then the player answers: go to jail (RPB's arrest, RPB_TIF_Arrest__00038769) or resist
; (RPB_TIF_ArrestResist__00038767). Leaving the dialogue instead counts as resisting (the mod author, 2026-10-12): watched
; from this line's end (RPB_EventManager.OnWorldInteractionArrestAnswer)
