;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname RPB_TIF_ArrestPayBounty__0003ADAE Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; take stolen goods, but don't send to jail
; akSpeaker.GetCrimeFaction().PlayerPayCrimeGold(True, False)
akSpeaker.SendModEvent("RPB_TopicInfoEnd", "Good enough. I'll just confiscate any stolen goods you're carrying, then you're free to go.", 11)
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
