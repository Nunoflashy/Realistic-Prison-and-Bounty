;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname RPB_TIF_ArrestConfront__0002A37C Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = Utility.GetCurrentRealTime() ; when this line began: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
pCGS.GuildDiscount(akSpeaker)
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoStart", "By order of the Jarl, stop right there!", 10, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Message Property CrimeBountyMSG  Auto  
CrimeGuardsScript Property pCGS  Auto  
