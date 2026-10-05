;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname RPB_TIF_ArrestPayBounty__00060C89 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = RPB_Utility.CrimeLineStamp() ; the load this line began in: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
if (RPB_Utility.IsFrozenGuard(akSpeaker)) ; already marked frozen: a call into him below hangs (a killed frozen clone kept talking, 2026-10-05)
    return
endif
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoEnd", "Smart woman. Now come along with us. We'll take any stolen goods, and you'll be free to go. After you pay the fine, of course.", 12, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
;
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
