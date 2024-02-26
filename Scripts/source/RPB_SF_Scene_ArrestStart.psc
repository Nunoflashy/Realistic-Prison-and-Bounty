;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 27
Scriptname RPB_SF_Scene_ArrestStart Extends Scene Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
self.SendModEvent("RPB_SceneEnd", "RPB_ArrestStart01")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_ArrestStart01")
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ArrestStart01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestStart01", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ArrestStart01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ArrestStart01", 3)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
