;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 16
Scriptname RPB_SF_Scene_Surrender01 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_Surrender01")
self.SendModEvent("RPB_ScenePlayingStart", "RPB_Surrender01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_Surrender01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_Surrender01", 2)
self.SendModEvent("RPB_SceneEnd", "RPB_Surrender01")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_Surrender01", 2)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
