;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 12
Scriptname RPB_SF_Scene_EscortToCell02 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortToCell02", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortToCell02", 8)
self.SendModEvent("RPB_SceneEnd", "RPB_EscortToCell02")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortToCell02", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_EscortToCell02")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
