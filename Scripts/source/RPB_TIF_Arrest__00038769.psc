;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname RPB_TIF_Arrest__00038769 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
RPB_Arrest.SetAsideBountyOnSubmission(Game.GetPlayer(), akSpeaker) ; first: no guard may see the bounty once this line ends
float rpbStartedAt = RPB_Utility.CrimeLineStamp() ; the load this line began in: a replay after a load is dropped
RPB_Utility.ProbeSpeaker(akSpeaker) ; before any call into him: a frozen speaker gets found, then silenced
; The dead-body quest ends here as its stage 20 would have, without that stage's vanilla jail
GetOwningQuest().Stop()
if (RPB_Utility.IsFrozenNPC(akSpeaker)) ; already marked frozen: a call into him below hangs
    return
endif
RPB_Utility.SendTopicInfoEvent("RPB_TopicInfoEnd", "You're smarter than you look.", 20, akSpeaker, rpbStartedAt)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; The dead-body accusation (WIDeadBody01: a guard finds a body near the player, "Let the law deal with this", then "Alright,
; you are now under arrest", which adds 100 bounty). Agreeing to go to jail ("You're smarter than you look.") set its stage
; 20, whose fragment sent the player to the vanilla jail and stopped the quest (2026-10-11, the mod author ended up there).
; RPB's arrest by the speaking guard instead, from the line's beginning as the other holds' "go to jail" lines, and the quest
; stopped here
