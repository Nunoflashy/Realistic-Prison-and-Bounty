;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname RPB_TIF_ArrestResist__00038767 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = RPB_Utility.CrimeLineStamp() ; the load this line began in: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
; The dead-body quest ends here as its stage 200 would have, without that stage's bare StartCombat: RPB's resist instead
GetOwningQuest().Stop()
if (RPB_Utility.IsFrozenNPC(akSpeaker)) ; already marked frozen: a call into him below hangs
    return
endif
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoStart", "Resisting arrest will mean your death.", 15, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; The dead-body accusation's resist answer (WIDeadBody01, "Resisting arrest will mean your death."): its stage 200 had the
; guard start combat and the quest stop. RPB's resisting arrest instead (its bounty and hostility, as the other holds'
; resist lines), the quest stopped here
