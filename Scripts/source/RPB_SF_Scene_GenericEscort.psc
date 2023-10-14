;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname RPB_SF_Scene_GenericEscort Extends Scene Hidden

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
self.SendModEvent("RPB_SceneEnd", "RPB_EscortToJail")
debug.notification("Arrived at Jail")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
self.SendModEvent("RPB_SceneEnd", "RPB_EscortToJail")
debug.notification("Arrived at Jail")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
self.SendModEvent("RPB_SceneStart", "RPB_EscortToJail")
debug.notification("Begun Escort to Jail")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;WARNING: Script name in fragment (RPB_Scene_SF_GenericEscort) does not match auto-generated script (SF_RPB_Scene_GenericEscort_0200CF57)
;Source NOT loaded
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
