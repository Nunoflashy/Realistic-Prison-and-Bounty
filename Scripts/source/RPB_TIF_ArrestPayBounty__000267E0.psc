;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname RPB_TIF_ArrestPayBounty__000267E0 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = Utility.GetCurrentRealTime() ; when this line began: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoEnd", "Smart man. Now come along with us. We'll take any stolen goods, and you'll be free to go. After you pay the fine, of course.", 12, akSpeaker, rpbStartedAt)
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
