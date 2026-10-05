;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname RPB_TIF_ArrestResist__00060C8B Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = RPB_Utility.CrimeLineStamp() ; the load this line began in: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
if (RPB_Utility.IsFrozenGuard(akSpeaker)) ; already marked frozen: a call into him below hangs (a killed frozen clone kept talking, 2026-10-05)
    return
endif
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoStart", "Then let me speed your passage to Sovngarde!", 15, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
