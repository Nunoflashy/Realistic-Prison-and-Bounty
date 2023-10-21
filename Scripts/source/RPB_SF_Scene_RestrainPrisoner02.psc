;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 10
Scriptname RPB_SF_Scene_RestrainPrisoner02 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_RestrainPrisoner02")
self.SendModEvent("RPB_ScenePlayingStart", "RPB_RestrainPrisoner02", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_RestrainPrisoner02", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_RestrainPrisoner02", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_RestrainPrisoner02", 1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
