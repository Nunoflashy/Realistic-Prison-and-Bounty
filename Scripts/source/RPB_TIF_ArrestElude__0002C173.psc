;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname RPB_TIF_ArrestElude__0002C173 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
float rpbStartedAt = Utility.GetCurrentRealTime() ; when this line began: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoEnd", "Sheathe your weapons and come quietly!", 7, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
