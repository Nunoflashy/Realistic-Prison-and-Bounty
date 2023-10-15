;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 28
Scriptname RPB_SF_Scene_ForcedStripping02 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
; Phase 5
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ForcedStripping02", 5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_22
Function Fragment_22()
;BEGIN CODE
; Phase 8
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ForcedStripping02", 8)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
; Phase 3
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ForcedStripping02", 3)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
; Phase 1
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ForcedStripping02", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
; Phase 5
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ForcedStripping02", 5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_24
Function Fragment_24()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ForcedStripping02", 4)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_26
Function Fragment_26()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ForcedStripping02", 4)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
; Phase 3
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ForcedStripping02", 3)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
; Phase 1
self.SendModEvent("RPB_SceneStart", "RPB_ForcedStripping02")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
; Phase 8
self.SendModEvent("RPB_SceneEnd", "RPB_ForcedStripping02")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
