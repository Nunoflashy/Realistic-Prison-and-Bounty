;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname RPB_SF_Scene_ArrestPayBountyWillingly Extends Scene Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
self.SendModEvent("RPB_SceneEnd", "RPB_ArrestPayBountyFollowWillingly")
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestPayBountyFollowWillingly", 3)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
