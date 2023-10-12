scriptname RealisticPrisonAndBounty_EventManager extends Quest

import RealisticPrisonAndBounty_Config
import RealisticPrisonAndBounty_Util

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property arrest
    RealisticPrisonAndBounty_Arrest function get()
        return config.arrest
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property jail
    RealisticPrisonAndBounty_Jail function get()
        return config.jail
    endFunction
endProperty

RealisticPrisonAndBounty_SceneManager property sceneManager
    RealisticPrisonAndBounty_SceneManager function get()
        return config.sceneManager
    endFunction
endProperty

function RegisterEvents()
    RegisterForModEvent("RPB_SceneStart", "OnSceneStart")
    RegisterForModEvent("RPB_ScenePlayingStart", "OnScenePlayingStart")
    RegisterForModEvent("RPB_ScenePlayingEnd", "OnScenePlayingEnd")
    RegisterForModEvent("RPB_SceneEnd", "OnSceneEnd")

    ; temp
    RegisterForModEvent("RPB_PackageEnd", "OnPackageEnd")
    RegisterForModEvent("RPB_PackageStart", "OnPackageStart")
endFunction

; ==========================================================
;                        Scene Events
; ==========================================================

event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    sceneManager.OnSceneStart(sceneName, (sender as Scene))
endEvent

event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    sceneManager.OnScenePlaying(sceneName, sceneManager.SCENE_PLAYING_START, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    sceneManager.OnScenePlaying(sceneName, sceneManager.SCENE_PLAYING_END, (scenePhaseFlt as int), (sender as Scene))
endEvent

event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    sceneManager.OnSceneEnd(sceneName, (sender as Scene))
endEvent

; ==========================================================
;                        Package Events
; ==========================================================

; event OnPackageEnd(string eventName, string packageName, float unusedFlt, Form sender)
;     ObjectReference[] data = new ObjectReference[10]

;     data[0] = Guard_EscortLocation.GetReference()
;     data[1] = Escort.GetActorReference()

;     ; AIPackageManager.OnPackageEnd(packageName, data, (sender as Package))
; endEvent


; event OnPackageStart(string eventName, string packageName, float unusedFlt, Form sender)
;     ObjectReference[] data = new ObjectReference[10]

;     data[0] = Guard_EscortLocation.GetReference()
;     data[1] = Escort.GetActorReference()

;     ; AIPackageManager.OnPackageStart(packageName, data, (sender as Package))
; endEvent


; AIPackageManager.psc
; event OnPackageStart(string packageName, ObjectReference[] data, Package sender)
;     ; if (packageName == "RPB_LockCellDoor")
;     ;     OrientRelative(data[1], data[0], afRotZ = 180)
;     ; endif
; endEvent

; event OnPackageEnd(string packageName, ObjectReference[] data, Package sender)
;     ; if (packageName == "RPB_LockCellDoor")
;     ;     data[0].SetLockLevel(100)
;     ;     data[0].Lock()
;     ; endif
; endEvent
