;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 15
Scriptname RPB_SF_Scene_EscortFromCell Extends Scene Hidden

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
self.SendModEvent("RPB_ScenePlayingEnd", "RPB_EscortFromCell", 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_EscortFromCell")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
