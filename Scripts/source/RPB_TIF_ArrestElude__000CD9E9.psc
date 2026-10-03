;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname RPB_TIF_ArrestElude__000CD9E9 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = RPB_Utility.CrimeLineStamp() ; the load this line began in: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
pCGS.GuildDiscount(akSpeaker)
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoEnd", "Wait... I know you", 6, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

Message Property CrimeBountyMSG  Auto  

CrimeGuardsScript Property pCGS  Auto  

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
