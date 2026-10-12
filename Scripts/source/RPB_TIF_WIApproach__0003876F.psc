;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname RPB_TIF_WIApproach__0003876F Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
RPB_Utility.SendWorldInteractionApproach(akSpeaker, GetOwningQuest())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; The dead-body accusation's opener (WIDeadBody01): the guard comes to the player, "You there! Wait a moment." A hook for
; now (RPB_EventManager.OnWorldInteractionApproach: logged and remembered); running off while he comes is meant to become
; eluding (the mod author, 2026-10-12)
