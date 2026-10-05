;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname RPB_TIF_Arrest__00020F99 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
RPB_Arrest.SetAsideBountyOnSubmission(Game.GetPlayer(), akSpeaker) ; first: no guard may see the bounty once this line ends
pTGRSS.TGArrestedCheck()
akSpeaker.SendModEvent("RPB_SendArrestWaitStop")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = RPB_Utility.CrimeLineStamp() ; the load this line began in: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
if (RPB_Utility.IsFrozenGuard(akSpeaker)) ; already marked frozen: a call into him below hangs (a killed frozen clone kept talking, 2026-10-05)
    return
endif
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoEnd", "Ha, enjoy The Chill.", 20, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Winterhold's "go to jail" line: vanilla sent the player to its own jail here (SendPlayerToJail, and allied the jail's
; faction); RPB's arrest takes over instead, like the other holds' lines. The properties are vanilla's, kept so the line's
; script data stays as vanilla filled it
ObjectReference Property JailMarker  Auto
TGRShellScript Property pTGRSS  Auto
Faction Property WinterholdJailFaction  Auto
Faction Property PlayerFaction  Auto
