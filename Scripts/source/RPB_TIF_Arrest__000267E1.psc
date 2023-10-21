;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname RPB_TIF_Arrest__000267E1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_6
Function Fragment_6(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
pTGRSS.TGArrestedCheck()
akSpeaker.SendModEvent("RPB_SendArrestWaitStop")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
akSpeaker.SendModEvent("RPB_TopicInfoEnd", "I guess you're smarter than you look.", 20)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

TGRShellScript Property pTGRSS  Auto  
