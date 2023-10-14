;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname RPB_SF_Scene_Stripping01 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_Stripping")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
; SendModEvent("RPB_UndressActor")
self.SendModEvent("RPB_SceneEnd", "RPB_Stripping")
debug.notification("Called from within the Scene SF Script")
debug.notification("Started Stripping Scene: Phase 2")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
