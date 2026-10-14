;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname RPB_SF_Scene_PickUpWeapons01 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_PickUpWeapons01")
self.SendModEvent("RPB_ScenePlayingStart", "RPB_PickUpWeapons01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_PickUpWeapons01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_PickUpWeapons01", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_PickUpWeapons01", 2)
self.SendModEvent("RPB_SceneEnd", "RPB_PickUpWeapons01")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
