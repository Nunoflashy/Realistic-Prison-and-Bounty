;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 22
Scriptname RPB_SF_Scene_ArrestStartPrison01 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ArrestStartPrison01", 4)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestStartPrison01", 5)
self.SendModEvent("RPB_SceneEnd", "RPB_ArrestStartPrison01")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestStartPrison01", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestStartPrison01", 4)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestStartPrison01", 3)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestStartPrison01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ArrestStartPrison01", 5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ArrestStartPrison01", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_ArrestStartPrison01")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ArrestStartPrison01", 3)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
