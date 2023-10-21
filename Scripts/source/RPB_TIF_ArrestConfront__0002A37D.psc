;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname RPB_TIF_ArrestConfront__0002A37D Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
pCGS.GuildDiscount(akSpeaker)
akSpeaker.SendModEvent("RPB_TopicInfoStart", "You have committed crimes against Skyrim and her people. What say you in your defense?", 10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
;akSpeaker.SendModEvent("RPB_SendArrestWait")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Message Property CrimeBountyMSG  Auto  

CrimeGuardsScript Property pCGS  Auto  
