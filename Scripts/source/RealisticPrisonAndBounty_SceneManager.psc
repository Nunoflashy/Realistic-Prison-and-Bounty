scriptname RealisticPrisonAndBounty_SceneManager extends Quest

import RealisticPrisonAndBounty_Config
import RealisticPrisonAndBounty_Util

Idle property LockpickingIdle auto

; ==========================================================
;                           Scenes
; ==========================================================
Scene property GenericEscort auto
Scene property EscortToJail auto
Scene property EscortToCell auto
Scene property Frisking auto
Scene property Stripping auto
Scene property Stripping02 auto
Scene property UnlockCell auto
Scene property LockCell auto

Scene property RPB_Scene_Stripping02
    Scene function get()
        return Game.GetFormFromFile(0xEA60, GetPluginName()) as Scene
    endFunction
endProperty

Scene property GiveClothing
    Scene function get()
        return Game.GetFormFromFile(0xF52A, GetPluginName()) as Scene
    endFunction
endProperty


Scene property BountyPaymentFail
    Scene function get()
        return Game.GetFormFromFile(0xF54E, GetPluginName()) as Scene
    endFunction
endProperty

; ==========================================================
;                       Scene Names
; ==========================================================
string property SCENE_GENERIC_ESCORT    = "RPB_GenericEscort" autoreadonly
string property SCENE_ESCORT_TO_JAIL    = "RPB_EscortToJail" autoreadonly
string property SCENE_ESCORT_TO_CELL    = "RPB_EscortToCell" autoreadonly
string property SCENE_STRIPPING         = "RPB_Stripping" autoreadonly
string property SCENE_FRISKING          = "RPB_Frisking" autoreadonly
string property SCENE_GIVE_CLOTHING     = "RPB_GiveClothing" autoreadonly
string property SCENE_UNLOCK_CELL       = "RPB_UnlockCell" autoreadonly
string property SCENE_PAYMENT_FAIL      = "RPB_BountyPaymentFail" autoreadonly

int property SCENE_PLAYING_START    = 0 autoreadonly
int property SCENE_PLAYING_END      = 1 autoreadonly

; ==========================================================
;                     Scene Control Queue
; ==========================================================
Scene _previousScene
Scene _currentScene
Scene _nextScene

; ==========================================================
;                       Scene Aliases
; ==========================================================

; Possible Escortees
ReferenceAlias property Escortee auto
ReferenceAlias property Escortee02 auto
ReferenceAlias property Escortee03 auto
ReferenceAlias property Escortee04 auto
ReferenceAlias property Escortee05 auto
ReferenceAlias property Escortee06 auto
ReferenceAlias property Escortee07 auto
ReferenceAlias property Escortee08 auto
ReferenceAlias property Escortee09 auto
ReferenceAlias property Escortee10 auto

; Possible Escorts
ReferenceAlias property Escort auto
ReferenceAlias property Escort02 auto
ReferenceAlias property Escort03 auto

; Possible Escort locations for Escortees / Arrestees / Prisoners
ReferenceAlias property Player_EscortLocation auto
ReferenceAlias property Player_EscortLocation000 auto
ReferenceAlias property Player_EscortLocation001 auto
ReferenceAlias property Player_EscortLocation002 auto
ReferenceAlias property Player_EscortLocation003 auto
ReferenceAlias property Player_EscortLocation004 auto
ReferenceAlias property Player_EscortLocation005 auto
ReferenceAlias property Player_EscortLocation006 auto
ReferenceAlias property Player_EscortLocation007 auto
ReferenceAlias property Player_EscortLocation008 auto
ReferenceAlias property Player_EscortLocation009 auto

; Possible Escort locations for Escorts / Guards
ReferenceAlias property Guard_EscortLocation auto
ReferenceAlias property Guard_EscortLocation02 auto
ReferenceAlias property Guard_EscortLocation03 auto

; Possible Prisoners
ReferenceAlias property Prisoner auto
ReferenceAlias property Prisoner000
    ReferenceAlias function get()
        return self.GetAliasByName("Prisoner000") as ReferenceAlias
    endFunction
endProperty

ReferenceAlias property Prisoner001
    ReferenceAlias function get()
        return self.GetAliasByName("Prisoner001") as ReferenceAlias
    endFunction
endProperty

ReferenceAlias property Prisoner002
    ReferenceAlias function get()
        return self.GetAliasByName("Prisoner002") as ReferenceAlias
    endFunction
endProperty

; Possible guards for searching simultaneously (Stripping / Frisking)
ReferenceAlias property SearcherGuard auto
ReferenceAlias property SearcherGuard02 auto
ReferenceAlias property SearcherGuard03 auto

RealisticPrisonAndBounty_EventManager property eventManager
    RealisticPrisonAndBounty_EventManager function get()
        return Game.GetFormFromFile(0xEA67, GetPluginName()) as RealisticPrisonAndBounty_EventManager
    endFunction
endProperty

function RegisterEvents()
    RegisterForModEvent("RPB_SceneStart", "OnSceneStart")
    RegisterForModEvent("RPB_ScenePlayingStart", "OnScenePlayingStart")
    RegisterForModEvent("RPB_ScenePlayingEnd", "OnScenePlayingEnd")
    RegisterForModEvent("RPB_SceneEnd", "OnSceneEnd")
endFunction

function QueueNext(Scene akScene)
    if (akScene == None)
        Warn(self, "SceneManager::QueueNext", "Scene is none, returning...")
        return
    endif

    _nextScene = akScene
endFunction

function PreviousScene()
    _previousScene.ForceStart()
endFunction

function NextScene()
    if (_nextScene != None)
        _nextScene.ForceStart()
    endif
endFunction

function ClearAliases()
    BindAliasTo(Escortee, none)
    BindAliasTo(Escort, none)
    BindAliasTo(Player_EscortLocation, none)
    BindAliasTo(Guard_EscortLocation, none)
    BindAliasTo(Prisoner, none)
    BindAliasTo(SearcherGuard, none)
endFunction

ObjectReference[] function GetSceneParameters(string sceneName)
    ObjectReference[] data = new ObjectReference[10]
    ; int i = 0
    ; while (i < data.Length)
    ;     ReferenceAlias currentEscort = self.GetAliasByName("Escort00" + i) as ReferenceAlias
    ;     if (currentEscort != None)
    ;         data[i] = currentEscort.GetReference()
    ;     endif
    ;     i += 1
    ; endWhile

    if (sceneName == SCENE_ESCORT_TO_CELL)
        data[0] = Escort.GetActorReference()
        data[1] = Escortee.GetActorReference()
        data[2] = Escortee02.GetActorReference()
        data[3] = Escortee03.GetActorReference()

    elseif (sceneName == SCENE_ESCORT_TO_JAIL)
        data[0] = Escort.GetActorReference()
        data[1] = Escortee.GetActorReference()
        data[2] = Escortee02.GetActorReference()
        data[3] = Escortee03.GetActorReference()

    elseif (sceneName == SCENE_STRIPPING)
        data[0] = SearcherGuard.GetActorReference()
        data[1] = Prisoner.GetActorReference()
        data[2] = Prisoner000.GetActorReference()
        data[3] = Prisoner001.GetActorReference()

    elseif (sceneName == SCENE_FRISKING)
        data[0] = SearcherGuard.GetActorReference()
        data[1] = Prisoner.GetActorReference()

    elseif (sceneName == SCENE_GIVE_CLOTHING)
        data[0] = SearcherGuard.GetActorReference()
        data[1] = Prisoner.GetActorReference()

    elseif (sceneName == SCENE_PAYMENT_FAIL)
        data[0] = SearcherGuard.GetActorReference()
        data[1] = Prisoner.GetActorReference()
    endif

    return data
endFunction

string function GetSceneParametersDebugInfo(string sceneName, ObjectReference[] data)
    string debugInfo = ""

    int i = 0
    while (i < data.Length)
        if (data[i] != None)
            string baseId     = data[i].GetBaseObject().GetFormID()
            string objectName = data[i].GetBaseObject().GetName()
            debugInfo += "\t data["+i+"]: " + data[i] + " (BaseID: " + baseId + ", Name: " + objectName + ")" + "\n"
        endif
        i += 1
    endWhile

    debugInfo += "]"

    return "Scene: " + sceneName + "\nParameters: [\n" + debugInfo
endFunction

event OnSceneStart(string eventName, string sceneName, float unusedFlt, Form sender)
    ObjectReference[] data = self.GetSceneParameters(sceneName)

    eventManager.OnSceneStart(sceneName, data, (sender as Scene))
endEvent

event OnScenePlayingStart(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    int phase = scenePhaseFlt as int
    ObjectReference[] data = self.GetSceneParameters(sceneName)

    eventManager.OnScenePlaying(sceneName, SCENE_PLAYING_START, phase, data, (sender as Scene))
endEvent

event OnScenePlayingEnd(string eventName, string sceneName, float scenePhaseFlt, Form sender)
    int phase = scenePhaseFlt as int
    ObjectReference[] data = self.GetSceneParameters(sceneName)

    eventManager.OnScenePlaying(sceneName, SCENE_PLAYING_END, phase, data, (sender as Scene))
endEvent

event OnSceneEnd(string eventName, string sceneName, float unusedFlt, Form sender)
    ObjectReference[] data = self.GetSceneParameters(sceneName)

    ; self.ClearAliases()
    ; self.NextScene()
    eventManager.OnSceneEnd(sceneName, data, (sender as Scene))
endEvent

ReferenceAlias function GetAvailableAlias(string aliasType)
    if (aliasType == "Prisoner")
        ReferenceAlias currentTraversedAlias = Prisoner

        if (currentTraversedAlias.GetReference() == None)
            return currentTraversedAlias
        endif
    endif
endFunction

function StartEscortToCell(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, ObjectReference akJailCellDoor)
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(Escort, akEscortLeader)

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(Escortee, akEscortedPrisoner)

    ; Bind the prisoner's destination point, the jail cell
    BindAliasTo(Player_EscortLocation, akJailCellMarker)

    ; Bind the guard's destination point, the jail cell door
    BindAliasTo(Guard_EscortLocation, akJailCellDoor)

    EscortToCell.Start()
endFunction

function StartEscortToJail(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akPrisonerChest)
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(Escort, akEscortLeader)
    BindAliasTo(Escortee02, none)
    BindAliasTo(Escortee03, none)

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(Escortee, akEscortedPrisoner)

    ; Bind the destination point, the chest
    BindAliasTo(Player_EscortLocation, akPrisonerChest)

    ; Bind the guard's destination point, the jail cell door
    BindAliasTo(Guard_EscortLocation, akPrisonerChest)

    Debug(self, "StartEscortToJail", "Aliases: [ \n" + \
    "akEscortLeader: " + akEscortLeader + "(Object: "+ akEscortLeader.GetName() +")\n" + \
    "akEscortedPrisoner: " + akEscortedPrisoner + "(Object: "+ akEscortedPrisoner.GetName() +")\n" + \
    "Escort: " + Escort + "(Object: "+ Escort.GetReference() +")\n" + \
    "Escortee: " + Escortee + "(Object: "+ Escortee.GetReference() +")\n" + \
    "Player_EscortLocation: " + Player_EscortLocation + "(Object: "+ Player_EscortLocation.GetReference() + ", " + Player_EscortLocation.GetReference().GetName() +")\n" + \
"]")

    EscortToJail.Start()
endFunction

function StartMultipleEscortsToJail(Actor akEscortLeader, Actor[] akEscortedPrisoners, ObjectReference akPrisonerChest)
    ; Bind the leader to its alias to lead the escort scene
    BindAliasTo(Escort, akEscortLeader)

    ; Bind the prisoners to their aliases to be escorted
    int i = 0
    while (i < akEscortedPrisoners.Length)
        BindAliasTo(self.GetAliasByName("Escortee" + i) as ReferenceAlias, akEscortedPrisoners[i])
        i += 1
    endWhile

    ; Bind the destination point, the chest
    BindAliasTo(Player_EscortLocation, akPrisonerChest)

    ; Bind the destination point, the chest
    BindAliasTo(Guard_EscortLocation, akPrisonerChest)
endFunction

function StartStripping(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAliasTo(SearcherGuard, akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAliasTo(Prisoner, akStrippedPrisoner)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAliasTo(Prisoner000, Escortee02.GetActorReference())
    BindAliasTo(Prisoner001, Escortee03.GetActorReference())

    RPB_Scene_Stripping02.Start()
endFunction

function StartFrisking(Actor akFriskerGuard, Actor akFriskedPrisoner)
    ; Bind the guard to be the one performing the frisk search
    BindAliasTo(SearcherGuard, akFriskerGuard)

    ; Bind the Prisoner to be the actor being frisk searched
    BindAliasTo(Prisoner, akFriskedPrisoner)

    Frisking.Start()
endFunction

function StartGiveClothing(Actor akGuard, Actor akPrisoner)
    ; Bind the guard to be the one giving clothing
    BindAliasTo(SearcherGuard, akGuard)

    ; Bind the Prisoner to be the actor being given clothing
    BindAliasTo(Prisoner, akPrisoner)

    GiveClothing.Start()
endFunction

function StartUnlockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAliasTo(Escort, akGuard)
    BindAliasTo(Guard_EscortLocation, akJailCellDoor)

    UnlockCell.Start()
endFunction

function StartLockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAliasTo(Escort, akGuard)
    BindAliasTo(Guard_EscortLocation, akJailCellDoor)

    LockCell.Start()
endFunction

function StartBountyPaymentFail(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(SearcherGuard, akGuard)

    ; Bind the Prisoner, who's trying to pay the bounty
    BindAliasTo(Prisoner, akPrisoner)

    BountyPaymentFail.Start()
endFunction