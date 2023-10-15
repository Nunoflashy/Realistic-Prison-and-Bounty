;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname RPB_SF_Scene_ForcedStripping01 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
self.SendModEvent("RPB_SceneEnd", "RPB_ForcedStripping01")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ForcedStripping01", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingStart", "RPB_ForcedStripping01", 2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_ForcedStripping01", 2)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
