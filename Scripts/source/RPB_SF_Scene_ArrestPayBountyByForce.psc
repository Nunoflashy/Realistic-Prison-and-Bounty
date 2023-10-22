;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname RPB_SF_Scene_ArrestPayBountyByForce Extends Scene Hidden

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
self.SendModEvent("RPB_SceneEnd", "RPB_ArrestPayBountyFollowByForce")
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestPayBountyFollowByForce", 5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestPayBountyFollowByForce", 3)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_ArrestPayBountyFollowByForce")
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ArrestPayBountyFollowByForce", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestPayBountyFollowByForce", 1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
