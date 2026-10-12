;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 7
Scriptname RPB_TIF_Arrest__000AD7C8 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_6
Function Fragment_6(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
RPB_Arrest.SetAsideBountyOnSubmission(Game.GetPlayer(), akSpeaker) ; first: no guard may see the bounty once this line ends
pTGRSS.TGArrestedCheck()
; The arrest from the line's beginning, not its end (above): the guard no longer walks off and comes back for it
float rpbStartedAt = RPB_Utility.CrimeLineStamp() ; the load this line began in: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
if (RPB_Utility.IsFrozenNPC(akSpeaker)) ; already marked frozen: a call into him below hangs (a killed frozen clone kept talking, 2026-10-05)
    return
endif
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoEnd", "A stretch in the Castle Dour Dungeon will straighten you right out.", 20, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; The arrest now starts at the line's beginning (the begin fragment): from here, the guard finished the line, walked
; off and came back for the arrest (the mod author, 2026-10-07)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property MS01  Auto  

TGRShellScript Property pTGRSS  Auto  
