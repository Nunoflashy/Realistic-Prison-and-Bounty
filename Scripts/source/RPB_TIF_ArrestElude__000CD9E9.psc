;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname RPB_TIF_ArrestElude__000CD9E9 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
pCGS.GuildDiscount(akSpeaker)
akSpeaker.SendModEvent("RPB_EludingArrest", "Dialogue")
;END CODE
EndFunction
;END FRAGMENT

Message Property CrimeBountyMSG  Auto  

CrimeGuardsScript Property pCGS  Auto  

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
