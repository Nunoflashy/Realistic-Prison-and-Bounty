;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 29
Scriptname RPB_SF_Scene_EscortToCell01 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_27
Function Fragment_27()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortToCell01", 5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortToCell01", 4)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_EscortToCell01")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortToCell01", 6)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_23
Function Fragment_23()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_EscortToCell01", 7)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortToCell01", 3)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_21
Function Fragment_21()
;BEGIN CODE
self.SendModEvent("RPB_SceneEnd", "RPB_EscortToCell01")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
