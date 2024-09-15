scriptname RPB_SceneManager extends Quest

import RPB_Config
import RPB_Utility

; ==========================================================
;                      Script References
; ==========================================================

RPB_API __api
RPB_API property API
    RPB_API function get()
        if (__api)
            return __api
        endif

        __api = RPB_API.GetSelf()
        return __api
    endFunction
endProperty

RPB_Config property Config
    RPB_Config function get()
        return API.Config
    endFunction
endProperty

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return API.Arrest
    endFunction
endProperty

RPB_PrisonManager property PrisonManager
    RPB_PrisonManager function get()
        return API.PrisonManager
    endFunction
endProperty

; ==========================================================
;                            Init
; ==========================================================

int __globalDefaults ; JMap&
int __globals ; JMap&
int __sceneContainer ; JMap&
int __sceneToCategory; JMap&
function __allocateMemory()
    if (!__sceneContainer)
        __sceneContainer = JMap.object()
        JValue.retain(__sceneContainer, "SceneManager")
    endif

    if (!__sceneToCategory)
        __sceneToCategory = JMap.object()
        JValue.retain(__sceneToCategory, "SceneManager")
    endif

    if (!__globals)
        __globals = JMap.object()
        JValue.retain(__globals, "SceneManager")
    endif

    if (!__globalDefaults)
        __globalDefaults = JMap.object()
        JValue.retain(__globalDefaults, "SceneManager")
    endif
endFunction

function __deallocateMemory()
    JValue.releaseObjectsWithTag("SceneManager")
endFunction

function Initialize()
    __allocateMemory()
    self.SetupGlobals()
    self.SetupScenes()
endFunction

; ==========================================================
;                          Globals
; ==========================================================

int property GlobalCount
    int function get()
        return JValue.count(__globals)
    endFunction
endProperty

function AddGlobal(string asGlobalName, int aiGlobalFormID, int aiDefaultValue = 0)
    JMap.setInt(__globals, asGlobalName, aiGlobalFormID)
    JMap.setInt(__globalDefaults, asGlobalName, aiDefaultValue)
endFunction

bool function HasGlobal(string asGlobal)
    return JMap.hasKey(__globals, asGlobal)
endFunction

GlobalVariable function GetGlobal(string asGlobal)
    if (!self.HasGlobal(asGlobal))
        return none
    endif

    int globalFormId = JMap.getInt(__globals, asGlobal)
    return GetFormFromMod(globalFormId) as GlobalVariable
endFunction

function SetGlobal(string asGlobal, int aiValue)
    GlobalVariable g = self.GetGlobal(asGlobal)

    if (g)
        g.SetValueInt(aiValue)
        Debug("SceneManager::SetGlobal", "Setting Global " + asGlobal + " to " + aiValue)
    endif
endFunction

function ResetGlobal(string asGlobal)
    GlobalVariable g = self.GetGlobal(asGlobal)

    if (g)
        int defaultValue = JMap.getInt(__globalDefaults, asGlobal)
        g.SetValueInt(defaultValue)
    endif
endFunction

function SetupGlobals()
    ; Control Flow - Scene Dialogue
    self.AddGlobal("RPB_Scene_Dialogue_CF01", 0x264B5)
    self.AddGlobal("RPB_Scene_Dialogue_CF02", 0x264B6)
    self.AddGlobal("RPB_Scene_Dialogue_CF03", 0x264B7)
    self.AddGlobal("RPB_Scene_Dialogue_CF04", 0x264B8)
    self.AddGlobal("RPB_Scene_Dialogue_CF05", 0x264B9)
    self.AddGlobal("RPB_Scene_Dialogue_CF06", 0x264BA)
    self.AddGlobal("RPB_Scene_Dialogue_CF07", 0x264BB)
    self.AddGlobal("RPB_Scene_Dialogue_CF08", 0x264BC)
    self.AddGlobal("RPB_Scene_Dialogue_CF09", 0x264BD)
    self.AddGlobal("RPB_Scene_Dialogue_CF10", 0x264BE)
    self.AddGlobal("RPB_Scene_Dialogue_CF11", 0x264BF)

    ; Control Flow - Scene Actions
    self.AddGlobal("RPB_Scene_Action_CF01", 0x264C0)
    self.AddGlobal("RPB_Scene_Action_CF02", 0x264C1)
    self.AddGlobal("RPB_Scene_Action_CF03", 0x264C2)
    self.AddGlobal("RPB_Scene_Action_CF04", 0x264C3)
    self.AddGlobal("RPB_Scene_Action_CF05", 0x264C4)
    self.AddGlobal("RPB_Scene_Action_CF06", 0x264C5)
    self.AddGlobal("RPB_Scene_Action_CF07", 0x264C6)
    self.AddGlobal("RPB_Scene_Action_CF08", 0x264C7)
    self.AddGlobal("RPB_Scene_Action_CF09", 0x264C8)
    self.AddGlobal("RPB_Scene_Action_CF10", 0x264C9)
    self.AddGlobal("RPB_Scene_Action_CF11", 0x264CA)
endFunction

function ResetGlobals()
    int i = 0
    int globalKeys = JMap.allKeys(__globals)

    while (i < GlobalCount)
        string globalKey = JArray.getStr(globalKeys, i)
        int defaultValue = JMap.getInt(__globalDefaults, globalKey)
        self.GetGlobal(globalKey).SetValueInt(defaultValue)
        i += 1
    endWhile

    Debug("SceneManager::ResetGlobals", "Scene Globals have been reset to their default values.")
endFunction

;/
    Handles customization of a Scene, either Enabling/Disabling dialogue or a particular Action.
    Scenes have conditions that depend on Scene_{Dialogue|Action}_CF* globals.

    These events set them for a Scene that could customize another Scene, for example.

    string  @asSceneName: The name of the scene to be customized.
/;
event OnSceneStartHandleGlobals(string asSceneName, ObjectReference[] params)
    if (self.IsSceneOfType(asSceneName, CATEGORY_ESCORT_TO_JAIL))
        self.SetGlobal("RPB_Scene_Action_CF01", 1) ; Enables some actions in escort to cell
    endif
endEvent

event OnScenePlayingHandleGlobals(string asSceneName, int aiSceneEventType, int aiScenePhase, ObjectReference[] params)
endEvent

event OnSceneEndHandleGlobals(string asSceneName, ObjectReference[] params)
    self.ResetGlobals()
endEvent

; ==========================================================
;                   Scene Phase Overriding
; ==========================================================

GlobalVariable property RPB_SceneBlockNormalExecution
    GlobalVariable function get()
        return GetFormFromMod(0x14C3A) as GlobalVariable
    endFunction
endProperty

GlobalVariable property RPB_SceneStartAtPhase
    GlobalVariable function get()
        return GetFormFromMod(0x14C39) as GlobalVariable
    endFunction
endProperty

function StartSceneAtPhase(int phase)
    RPB_SceneBlockNormalExecution.SetValueInt(1)
    RPB_SceneStartAtPhase.SetValueInt(phase)
endFunction

function ResetSceneOverride()
    RPB_SceneBlockNormalExecution.SetValueInt(0)
    RPB_SceneStartAtPhase.SetValueInt(0)
endFunction
; ==========================================================
;                           Scenes
; ==========================================================
Scene property UnlockCell auto
Scene property LockCell auto


int property SceneCount
    int function get()
        return JValue.count(__sceneContainer)
    endFunction
endProperty

function AddScene(string asSceneName, int aiSceneFormID, string asSceneCategory = "null")
    JMap.setInt(__sceneContainer, asSceneName, aiSceneFormID)

    if (asSceneCategory != "null")
        JMap.setStr(__sceneToCategory, asSceneName, asSceneCategory)
        ; Debug("SceneManager::AddScene", "Setting " + asSceneName + " category: " + asSceneCategory)

    endif
endFunction

string function GetSceneNameByIndex(int aiIndex)
    return JMap.getNthKey(__sceneContainer, aiIndex)
endFunction

int function GetSceneFormID(string asSceneName)
    return JMap.getInt(__sceneContainer, asSceneName)
endFunction

string function GetSceneNameByFormID(int aiSceneFormID)
    return JMap.getStr(__sceneContainer, aiSceneFormID)
endFunction

bool function SceneExists(string asSceneName)
    return JMap.hasKey(__sceneContainer, asSceneName)
endFunction

;/
    Checks if a given Scene is of the specified type (category).

    string  @asSceneName: The name of the Scene.
    string  @asCategory: The category of which the Scene should be a part of.
/;
bool function IsSceneOfType(string asSceneName, string asCategory)
    return JMap.getStr(__sceneToCategory, asSceneName) == asCategory
endFunction

function SetupScenes()
    float x = StartBenchmark()

    self.AddScene(SCENE_ARREST_START_01,                        0xF569, CATEGORY_ARREST_START)      ; Arrest Start 01
    self.AddScene(SCENE_ARREST_START_02,                        0xFAF6, CATEGORY_ARREST_START)      ; Arrest Start 02
    self.AddScene(SCENE_ARREST_START_03,                        0x130DD, CATEGORY_ARREST_START)     ; Arrest Start 03
    self.AddScene(SCENE_ARREST_START_04,                        0x13663, CATEGORY_ARREST_START)     ; Arrest Start 04
    self.AddScene(SCENE_ARREST_START_PRISON_01,                 0x14C14, CATEGORY_ARREST_START)     ; Arrest Start Prison 01
    self.AddScene(SCENE_ESCORT_TO_JAIL_01,                      0xF532, CATEGORY_ESCORT_TO_JAIL)    ; Escort to Jail
    self.AddScene(SCENE_ESCORT_TO_JAIL_02,                      0x17CDA, CATEGORY_ESCORT_TO_JAIL)   ; Escort to Jail 02
    self.AddScene(SCENE_ESCORT_TO_CELL_01,                      0xCF58, CATEGORY_ESCORT_TO_CELL)    ; Escort to Cell 01
    self.AddScene(SCENE_ESCORT_TO_CELL_02,                      0x1367D, CATEGORY_ESCORT_TO_CELL)   ; Escort to Cell 02
    self.AddScene(SCENE_ESCORT_FROM_CELL,                       0x115E6, CATEGORY_ESCORT_FROM_CELL) ; Escort from Cell
    ; self.AddScene(SCENE_SEARCH_START,                         0xF55C)     ; SearchStart
    self.AddScene(SCENE_FRISKING,                               0xCF5A, CATEGORY_FRISKING)          ; Frisking
    self.AddScene(SCENE_STRIPPING_START_01,                     0xF561, CATEGORY_STRIPPING)         ; Stripping Start
    self.AddScene(SCENE_STRIPPING_01,                           0xCF59, CATEGORY_STRIPPING)         ; Stripping
    self.AddScene(SCENE_STRIPPING_02,                           0xEA60, CATEGORY_STRIPPING)         ; Stripping 02
    self.AddScene(SCENE_FORCED_STRIPPING_01,                    0xF587, CATEGORY_STRIPPING)         ; Forced Stripping 01
    self.AddScene(SCENE_FORCED_STRIPPING_02,                    0x120A9, CATEGORY_STRIPPING)        ; Forced Stripping 02
    self.AddScene(SCENE_GIVE_CLOTHING,                          0xF52A, CATEGORY_CLOTHING)          ; Give Clothing
    self.AddScene(SCENE_NO_CLOTHING,                            0xF571, CATEGORY_NO_CLOTHING)       ; No Clothing
    self.AddScene(SCENE_PAYMENT_FAIL,                           0xF54E, CATEGORY_PAYMENT_FAIL)      ; Bounty Payment Fail
    self.AddScene(SCENE_ELUDING_ARREST_01,                      0x12613, CATEGORY_ELUDING)          ; Eluding Arrest
    self.AddScene(SCENE_RESTRAIN_PRISONER_01,                   0x15702, CATEGORY_RESTRAIN)         ; Restrain Prisoner 01
    self.AddScene(SCENE_RESTRAIN_PRISONER_02,                   0x15C66, CATEGORY_RESTRAIN)         ; Restrain Prisoner 02
    self.AddScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY,     0x1776B, CATEGORY_PAY_BOUNTY)       ; Pay Bounty Follow Willingly
    self.AddScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE,      0x1776E, CATEGORY_PAY_BOUNTY)       ; Pay Bounty Follow By Force

    string sceneListAsString = ""
    int i = 0
    while (i < SceneCount)
        ; sceneListAsString += "\t["+i+"]: "+ JMap.getNthKey(__sceneContainer, i) +"\n"
        sceneListAsString += "\t["+i+"]: "+ self.GetSceneNameByIndex(i) +"\n"
        i += 1
    endWhile
    EndBenchmark(x, "SetupScenes")
    Debug("SceneManager::SetupScenes", "Loaded "+ SceneCount +" Scenes: [\n" + sceneListAsString + "]")
endFunction

Scene function GetScene(string asSceneName)
    if (!self.SceneExists(asSceneName))
        Error("SceneManager::GetScene", "Scene " + asSceneName + " does not exist!")
        return none
    endif

    ; Debug("SceneManager::GetScene", "Scenes: " + SceneCount)
    ; return Game.GetFormFromFile(JMap.getInt(__sceneContainer, asSceneName), GetPluginasSceneName()) as Scene
    return GetFormFromMod(self.GetSceneFormID(asSceneName)) as Scene
endFunction


; ==========================================================
;                      Scene Event Types
; ==========================================================

; Type of Event during OnScenePlaying
int property PHASE_START    = 0 autoreadonly
int property PHASE_END      = 1 autoreadonly

; ==========================================================
;                       Scene Categories
; ==========================================================

string property CATEGORY_ARREST_START       = "RPB_ArrestStart" autoreadonly
string property CATEGORY_ESCORT_TO_JAIL     = "RPB_EscortToJail" autoreadonly
string property CATEGORY_ESCORT_TO_CELL     = "RPB_EscortToCell" autoreadonly
string property CATEGORY_ESCORT_FROM_CELL   = "RPB_EscortFromCell" autoreadonly
string property CATEGORY_FRISKING           = "RPB_Frisking" autoreadonly
string property CATEGORY_STRIPPING          = "RPB_Stripping" autoreadonly
string property CATEGORY_CLOTHING           = "RPB_Clothing" autoreadonly
string property CATEGORY_NO_CLOTHING        = "RPB_NoClothing" autoreadonly
string property CATEGORY_PAYMENT_FAIL       = "RPB_PaymentFail" autoreadonly
string property CATEGORY_ELUDING            = "RPB_Eluding" autoreadonly
string property CATEGORY_RESTRAIN           = "RPB_Restrain" autoreadonly
string property CATEGORY_PAY_BOUNTY         = "RPB_ArrestPayBounty" autoreadonly

; ==========================================================
;                         Scene Names
; ==========================================================

string property SCENE_ARREST_START_01                       = "RPB_ArrestStart01" autoreadonly
string property SCENE_ARREST_START_02                       = "RPB_ArrestStart02" autoreadonly
string property SCENE_ARREST_START_03                       = "RPB_ArrestStart03" autoreadonly
string property SCENE_ARREST_START_04                       = "RPB_ArrestStart04" autoreadonly
string property SCENE_ARREST_START_PRISON_01                = "RPB_ArrestStartPrison01" autoreadonly
string property SCENE_GENERIC_ESCORT                        = "RPB_GenericEscort" autoreadonly
string property SCENE_ESCORT_FROM_CELL                      = "RPB_EscortFromCell" autoreadonly
string property SCENE_ESCORT_TO_JAIL_01                     = "RPB_EscortToJail01" autoreadonly
string property SCENE_ESCORT_TO_JAIL_02                     = "RPB_EscortToJail02" autoreadonly
string property SCENE_ESCORT_TO_CELL_01                     = "RPB_EscortToCell01" autoreadonly
string property SCENE_ESCORT_TO_CELL_02                     = "RPB_EscortToCell02" autoreadonly
string property SCENE_ESCORT_TO_CELL_03                     = "RPB_EscortToCell03" autoreadonly
string property SCENE_STRIPPING_01                          = "RPB_Stripping01" autoreadonly
string property SCENE_STRIPPING_02                          = "RPB_Stripping02" autoreadonly
string property SCENE_FORCED_STRIPPING_START_01             = "RPB_ForcedStrippingStart01" autoreadonly
string property SCENE_FORCED_STRIPPING_01                   = "RPB_ForcedStripping01" autoreadonly
string property SCENE_FORCED_STRIPPING_02                   = "RPB_ForcedStripping02" autoreadonly
string property SCENE_STRIPPING_START_01                    = "RPB_StrippingStart01" autoreadonly
string property SCENE_FRISKING                              = "RPB_Frisking" autoreadonly
string property SCENE_GIVE_CLOTHING                         = "RPB_GiveClothing" autoreadonly
string property SCENE_UNLOCK_CELL                           = "RPB_UnlockCell" autoreadonly
string property SCENE_PAYMENT_FAIL                          = "RPB_BountyPaymentFail" autoreadonly
string property SCENE_NO_CLOTHING                           = "RPB_NoClothing" autoreadonly
string property SCENE_ELUDING_ARREST_01                     = "RPB_EludingArrest01" autoreadonly
string property SCENE_RESTRAIN_PRISONER_01                  = "RPB_RestrainPrisoner01" autoreadonly
string property SCENE_RESTRAIN_PRISONER_02                  = "RPB_RestrainPrisoner02" autoreadonly
string property SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY    = "RPB_ArrestPayBountyFollowWillingly" autoreadonly
string property SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE     = "RPB_ArrestPayBountyFollowByForce" autoreadonly

; ==========================================================
;                     Management Events
; ==========================================================

event OnAllScenesFinished()
    Debug("SceneManager::OnAllScenesFinished", "Resetting current scene!")
    currentScene = ""

    self.ResetGlobals()
endEvent

; ==========================================================
;                     Scene Control Queue
; ==========================================================

int __queuedScenes
bool __isScenePlaying
string currentScene

bool function HasQueuedScenes()
    return JArray.count(__queuedScenes) > 0
endFunction

;/
    Pushes a Scene into the queue.

    string  @asSceneName: The name of the scene.
/;
function PushScene(string asSceneName)
    if (!__queuedScenes)
        __queuedScenes = JArray.object()
        JValue.retain(__queuedScenes, "RPB_SceneManager")
    endif

    JArray.addStr(__queuedScenes, asSceneName)
endFunction

;/
    Removes a Scene from the queue, and returns its name.

    returns (string): The name of the removed Scene
/;
string function PopScene()
    if (!self.HasQueuedScenes())
        self.OnAllScenesFinished()
        return ""
    endif

    string sceneName = JArray.getStr(__queuedScenes, 0)
    JArray.eraseIndex(__queuedScenes, 0)
    return sceneName
endFunction

;/
    Queues a Scene, or plays it if the queue is empty.

    string  @asSceneName: The name of the Scene to queue up or play.
/;
function QueueOrPlay(string asSceneName)
    int queuedSceneCount = JArray.count(__queuedScenes)

    ; Queue Scene
    self.PushScene(asSceneName)

    if (!__isScenePlaying)
        self.PlayQueued() ; play the 1st scene if the queue was empty
    endif
endFunction

;/
    Plays the next Scene in the queue if there's any.
    This is invoked OnSceneEnd() to ensure that the previous Scene finishes.
/;
function PlayQueued()
    if (!self.HasQueuedScenes())
        self.OnAllScenesFinished()
        return
    endif

    ; Scene is now playing
    __isScenePlaying = true

    string nextScene = self.PopScene()

    if (nextScene != "")
        self.GetScene(nextScene).Start() ; Play the Scene
        currentScene = nextScene
        Debug("SceneManager::PlayQueued", "Setting current scene: " + nextScene)

    endif
endFunction

; ==========================================================
;                       Scene Aliases
; ==========================================================

ReferenceAlias function GetRefAlias(string aliasGroup, int index = 0)
    string refAliasGroup = string_if (index == 0, aliasGroup, aliasGroup + index)
    return self.GetAliasByName(refAliasGroup) as ReferenceAlias
endFunction

ReferenceAlias function GetEscort(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Escort", "Escort" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetEscortee(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Escortee", "Escortee" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetAvailableEscortee()
    int i = 0
    while (i < 10)
        ReferenceAlias currentEscorteeAlias = self.GetEscortee(i)
        if (currentEscorteeAlias == none)
            return currentEscorteeAlias
        endif
        i += 1
    endWhile

    return none
endFunction

ReferenceAlias function GetEluder(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Eluder", "Eluder" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetDetainee(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Detainee", "Detainee" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetArrestee(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Arrestee", "Arrestee" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetGuard(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Guard", "Guard" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetCaptor(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Captor", "Captor" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetPrisoner(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Prisoner", "Prisoner" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetCell(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Cell", "Cell" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetCellDoor(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "CellDoor", "CellDoor" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetGuardLocation(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Guard_EscortLocation", "Guard_EscortLocation" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetPrisonerLocation(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Player_EscortLocation", "Player_EscortLocation" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetEscorteeLocation(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Player_EscortLocation", "Player_EscortLocation" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetGuardWaitingSpot(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "GuardWaitingSpot", "GuardWaitingSpot" + index)) as ReferenceAlias
endFunction

string function GetAliasName(string aliasName, int aliasIndex, bool checkForExistence = false)
    string finalName
    if (aliasIndex == 0)
        finalName = aliasName
    else
        finalName = aliasName + aliasIndex
    endif

    if (checkForExistence && self.GetAliasByName(finalName) == none)
        Debug("SceneManager::GetAliasByName", "Alias " + finalName + " does not exist!")
        return ""
    endif

    return finalName
endFunction


function ReleaseAlias(string aliasName, int aliasIndex = 0)
    string finalName = self.GetAliasName(aliasName, aliasIndex , true)
    ReferenceAlias refAlias = self.GetAliasByName(finalName) as ReferenceAlias

    if (refAlias != none)
        BindAliasTo(refAlias, none)
    endif
endFunction

function ReleaseAliasesFromScene(string sceneName)
    ; Get all aliases from a Scene, and release them.
    ObjectReference[] sceneParams = self.GetSceneParameters(sceneName)
    int i = 0
    while (i < sceneParams.Length)
        if (sceneParams[i] != none)
            
        endif
        i += 1
    endWhile
endFunction

; Right now only releases the AI for Scenes that retain it, however in some instances we actually want to release it,
; so this is here as a workaround. Later it should handle more things related to End of scene blocking.
bool __resumeSceneBlocked
function ResumeSceneBlocked()
    __resumeSceneBlocked = true
endFunction

event OnResumeSceneBlocked()
    string lastScene = JArray.getStr(__queuedScenes, -1) ; needs to be revised, returning empty, however it works for now
    Debug("SceneManager::OnResumeSceneBlocked", "ResumeSceneBlocked: " + __resumeSceneBlocked + ", Current Scene: " + currentScene + ", Last Scene: " + lastScene + ", Condition: " + (currentScene == lastScene))
    if (__resumeSceneBlocked && currentScene == lastScene)
        ReleaseAI()
        __resumeSceneBlocked = false
    endif
endEvent

; Possible Escorts
; Possible Escort locations for Escortees / Arrestees / Prisoners
; Possible Escort locations for Escorts / Guards
; Possible guards for searching simultaneously (Stripping / Frisking)

function AddRefsToScene(string asSceneName, string asRefAliasGroup, int aiRefCount = 1)
    int refKeyMap = JMap.object()

    JMap.setForm(refKeyMap, "Escort",       self.GetEscort().GetReference())
    JMap.setForm(refKeyMap, "Escortee",     self.GetEscortee().GetReference())
    JMap.setForm(refKeyMap, "Guard",        self.GetGuard().GetReference())
    JMap.setForm(refKeyMap, "Prisoner",     self.GetPrisoner().GetReference())

    int i = 0
    while (i < aiRefCount)
        if (asRefAliasGroup == "Escort")
            
        endif
        i += 1
    endWhile
endFunction

; int sceneParamsMap
; ObjectReference[] function GetSceneParams(string asSceneName)
;     int sceneParams = JMap.getObj(sceneParamsMap, asSceneName) ; JMap containing Params

;     int i = 0
;     while (i < JValue.count(sceneParams))
;         ; Get the map for this Scene

;     endWhile
; endFunction

; int function GetSceneParams(string asSceneName)
;     int params = JMap.object()

;     int escortCount = 0
;     int escortIndex = 0

;     while (escortIndex < escortCount)
;         string escortKey = string_if (escortIndex == 0, "Escort", "Escort" + escortIndex)
;         ObjectReference object = self.GetEscort(escortIndex).GetReference()
;         if (object)
;             JMap.setForm(params, escortKey, object)
;         endif
;         escortIndex += 1
;     endWhile

;     ; JMap.setForm(params, "Escort", self.GetEscort().GetReference().GetBaseObject())
; endFunction

ObjectReference[] function GetSceneParameters(string sceneName)
    ObjectReference[] params = new ObjectReference[10]

    ; self.AddRefsToScene(SCENE_ARREST_START_01, "Escort", 3)
    ; self.AddRefsToScene(SCENE_ARREST_START_01, "Escortee", 9)
        
    if (sceneName == SCENE_ARREST_START_01)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()

    elseif (sceneName == SCENE_ARREST_START_02)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()

    elseif (sceneName == SCENE_ARREST_START_03)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()

    elseif (sceneName == SCENE_ARREST_START_04)
        params[0] = self.GetCaptor().GetActorReference()
        params[1] = self.GetArrestee().GetActorReference()

    elseif (sceneName == SCENE_ARREST_START_PRISON_01)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()


    elseif (sceneName == SCENE_ESCORT_TO_CELL_01)
        ;/
            self.AddEscort(1)
            self.AddEscortee(3)
        /;
        ; params[0] = self.GetEscort().GetActorReference()
        ; params[1] = self.GetEscortee().GetActorReference()
        ; params[2] = self.GetEscortee(1).GetActorReference()
        ; params[3] = self.GetEscortee(2).GetActorReference()
        ; params[4] = self.GetCell().GetReference()
        ; params[5] = self.GetGuardLocation().GetReference()

        ; params[0] = self.GetEscort().GetActorReference()
        ; params[1] = self.GetEscortee().GetActorReference()
        ; params[2] = self.GetEscortee(1).GetActorReference()
        ; params[3] = self.GetEscortee(2).GetActorReference()
        ; params[4] = self.GetPrisonerLocation().GetReference()
        ; params[5] = self.GetGuardLocation().GetReference()

        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()
        params[2] = self.GetEscortee(1).GetActorReference()
        params[3] = self.GetEscortee(2).GetActorReference()
        params[4] = self.GetPrisonerLocation().GetReference()
        params[5] = self.GetCellDoor().GetReference()
        params[6] = self.GetGuardLocation().GetReference()

        RPB_StorageVars.SetIntOnForm("Escort",   params[0], 0)
        RPB_StorageVars.SetIntOnForm("Escortee", params[1], 0)
        RPB_StorageVars.SetIntOnForm("Escortee", params[2], 1)
        RPB_StorageVars.SetIntOnForm("Escortee", params[3], 2)

    elseif (sceneName == SCENE_ESCORT_TO_CELL_02)
        params[0] = self.GetGuard().GetReference()
        params[1] = self.GetPrisoner().GetReference()
        params[2] = self.GetCell().GetReference()
        params[3] = self.GetCellDoor().GetReference()

    elseif (sceneName == SCENE_ESCORT_FROM_CELL)
        params[0] = self.GetGuard().GetReference()
        params[1] = self.GetPrisoner().GetReference()
        params[2] = self.GetGuardLocation().GetReference()
        params[3] = self.GetPrisonerLocation().GetReference()

    elseif (sceneName == SCENE_ESCORT_TO_JAIL_01)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()
        params[2] = self.GetEscortee(1).GetActorReference()
        params[3] = self.GetEscortee(2).GetActorReference()

    elseif (sceneName == SCENE_ESCORT_TO_JAIL_02)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()

    elseif (sceneName == SCENE_STRIPPING_01)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()
        params[2] = self.GetPrisoner(1).GetActorReference()
        params[3] = self.GetPrisoner(2).GetActorReference()

    elseif (sceneName == SCENE_STRIPPING_02)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()
        params[2] = self.GetPrisoner(1).GetActorReference()
        params[3] = self.GetPrisoner(2).GetActorReference()

    elseif (sceneName == SCENE_FRISKING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_GIVE_CLOTHING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_PAYMENT_FAIL)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_NO_CLOTHING)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()
        params[2] = self.GetPrisoner(1).GetActorReference()
        params[3] = self.GetPrisoner(2).GetActorReference()
        params[4] = self.GetPrisoner(3).GetActorReference()

    elseif (sceneName == SCENE_FORCED_STRIPPING_01)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_FORCED_STRIPPING_02)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetPrisoner().GetActorReference()

    elseif (sceneName == SCENE_ELUDING_ARREST_01)
        params[0] = self.GetGuard().GetActorReference()
        params[1] = self.GetEluder().GetActorReference()

    elseif (sceneName == SCENE_RESTRAIN_PRISONER_01)
        params[0] = self.GetGuard().GetReference()
        params[1] = self.GetPrisoner().GetReference()

    elseif (sceneName == SCENE_RESTRAIN_PRISONER_02)
        params[0] = self.GetGuard().GetReference()
        params[1] = self.GetPrisoner().GetReference()

    elseif (sceneName == SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()
        params[2] = self.GetGuardLocation().GetReference()
        params[3] = self.GetPrisonerLocation().GetReference()

    elseif (sceneName == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
        params[0] = self.GetEscort().GetActorReference()
        params[1] = self.GetEscortee().GetActorReference()
        params[2] = self.GetGuardLocation().GetReference()
        params[3] = self.GetPrisonerLocation().GetReference()

    endif

    return params
endFunction

string function GetSceneParametersDebugInfo(Scene sender, string sceneName, ObjectReference[] params)
    string debugInfo = ""
    bool emptyParams = true

    int i = 0
    while (i < params.Length)
        if (params[i] != none)
            string baseId     = "[BaseID: " + params[i].GetBaseObject().GetFormID() + "] "
            string formId     = "[FormID: " + params[i].GetFormID() + "] "
            
            string objectBaseName   = params[i].GetBaseObject().GetName()
            string objectClassName  = params[i].GetName()
            string whichNameProperty = string_if (objectClassName != "", objectClassName, objectBaseName)
            string objectName = "[Name: " + whichNameProperty + "] "
            emptyParams = false

            debugInfo += "\t["+i+"]: " + params[i] + " " + formId + baseId + string_if (objectName != "[Name: ] ", objectName) + "\n"
        endif
        i += 1
    endWhile
    
    if (emptyParams)
        return sceneName + " " + sender + " - No Parameters, Scene expected: " + params.Length + " parameters!" ; " - No Parameters, Scene expected: need a way to find scene required params
    endif

    return sceneName + " " + sender + "\nParameters: [\n" + debugInfo + "]"
endFunction

event OnSceneStart(string name, Scene sender)
    ObjectReference[] params = self.GetSceneParameters(name)

    self.OnSceneStartHandleGlobals(name, params)

    if (name == SCENE_ARREST_START_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        ; if (JMap.hasKey(container, name))
        ; int sceneParams = JMap.getObj(sceneParamsMap, name)
        ; JMap.getForm(sceneParams, "Escort") ; Get all escorts for this Scene

        RetainAI(escortee == config.Player)

        ; arrest.OnArrestStart()

    elseif (name == SCENE_ARREST_START_02)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RetainAI(escortee == config.Player)

    elseif (name == SCENE_ARREST_START_03)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RetainAI(escortee == config.Player)

    elseif (name == SCENE_ARREST_START_04)

    elseif (name == SCENE_ARREST_START_PRISON_01)
        Actor captor   = params[0] as Actor
        Actor arrestee = params[1] as Actor

        RetainAI(arrestee == Config.Player)

    elseif (name == SCENE_ESCORT_TO_CELL_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(escortee)

        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != escort)
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                prisoner.SetForm("EscortGuard", escort, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "EscortBegin", prisoner) ; possibly needs to be reviewed, it's being called 4 times for one prisoner
            endif
            i += 1
        endWhile

    elseif (name == SCENE_ESCORT_TO_CELL_02)
        Actor guard                 = params[0] as Actor
        Actor prisonerActor         = params[1] as Actor
        ObjectReference jailCell    = params[2]
        ObjectReference cellDoor    = params[3]

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisonerActor)

        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != guard)
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                prisoner.SetForm("EscortGuard", guard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "EscortBegin", prisoner)
            endif
            i += 1
        endWhile

    elseif (name == SCENE_ESCORT_FROM_CELL)
        Actor guard             = params[0] as Actor
        Actor prisonerActor     = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisonerActor)


        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != guard)
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                prisoner.SetForm("EscortGuard", guard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "EscortBegin", prisoner)
            endif
            i += 1
        endWhile

    elseif (name == SCENE_ESCORT_TO_JAIL_01)
        Actor escort        = params[0] as Actor
        Actor escortee      = params[1] as Actor
        Actor escortee02    = params[2] as Actor
        Actor escortee03    = params[3] as Actor

        self.SetGlobal("RPB_SceneDialogueEnabled1", 1) ; Used for certain dialogue

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(escortee) ; TODO: Escortee may not be a prisoner yet (BUG?)

        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != escort)
                if (!prison.Prisoners.AtKey(params[i] as Actor))
                    prison.FireFallbackActorEventOnScene(name, "EscortBegin", params[i] as Actor, "Make Prisoner")
                    ; RPB_Prisoner prisoner = prison.MakePrisoner(params[i] as Actor)
                    ; prisoner.SetSentence()
                    ; prison.RegisterPrisoner(prisoner)
                endif
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                prisoner.SetForm("EscortGuard", escort, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "EscortBegin", prisoner)
            endif
            i += 1
        endWhile

    elseif (name == SCENE_ESCORT_TO_JAIL_02)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(escortee)


        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != escort)
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor) ; Only the escortees can be Prisoners
                prisoner.SetForm("EscortGuard", escort, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "EscortBegin", prisoner)
            endif
            i += 1
        endWhile

    elseif (name == SCENE_STRIPPING_01)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor
        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)

        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != stripperGuard)
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                prisoner.SetForm("StripperGuard", stripperGuard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "StripBegin", prisoner)
            endif
            i += 1
        endWhile

    elseif (name == SCENE_STRIPPING_02)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)

        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != stripperGuard)
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                if (!prisoner)
                    RPB_Prisoner firstStrippedPrisonerRef = prison.AwaitPrisonerReference(strippedPrisoner)
                    RPB_StorageVars.SetIntOnForm("Sentence", params[i] as Actor, firstStrippedPrisonerRef.Sentence, "Temporary::Imprisoned")
                    prison.FireFallbackActorEventOnScene(name, "StripBegin", params[i] as Actor, "Make Prisoner")
                    prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                endif
                prisoner.SetForm("StripperGuard", stripperGuard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "StripBegin", prisoner, "Undress to Underwear")
            endif
            i += 1
        endWhile

    elseif (name == SCENE_FORCED_STRIPPING_02)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)


        int i = 0
        while (i < params.Length)
            if (params[i] != none && params[i] != stripperGuard)
                RetainAI(params[i] == Config.Player)
                ; RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                ; prisoner.SetForm("StripperGuard", stripperGuard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                ; prison.FirePrisonerEventOnScene(name, "StripBegin", prisoner)
                ; prison.OnPrisonerStripBegin(prisoner, stripperGuard)
            endif
            i += 1
        endWhile

        
        ; jail.OnStripBegin(stripperGuard, strippedPrisoner)

    elseif (name == SCENE_FRISKING)
        Actor searcherGuard     = params[0] as Actor
        Actor searchedPrisoner  = params[1] as Actor

        RetainAI(searchedPrisoner == config.Player)
        
        ; jail.OnFriskBegin(searcherGuard, searchedPrisoner)

    elseif (name == SCENE_PAYMENT_FAIL)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        RetainAI(prisoner == config.Player)
        
        ; jail.OnBountyPaymentFailed(guard, prisoner)

    elseif (name == SCENE_ELUDING_ARREST_01)
        Actor guard     = params[0] as Actor
        Actor eluder    = params[1] as Actor

        Arrest.OnArrestEludeTriggered(guard, "Dialogue")

    elseif (name == SCENE_RESTRAIN_PRISONER_01)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

    elseif (name == SCENE_RESTRAIN_PRISONER_02)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

    elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
        Actor escort                    = params[0] as Actor
        Actor escortee                  = params[1] as Actor
        ObjectReference escortLocation  = params[2]

    elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
        Actor escort                    = params[0] as Actor
        Actor escortee                  = params[1] as Actor
        ObjectReference escortLocation  = params[2]

    endif

    Debug("SceneManager::OnSceneStart", self.GetSceneParametersDebugInfo(sender, name, params))
    Info(self.GetSceneParametersDebugInfo(sender, name, params))
endEvent

event OnScenePlaying(string name, int phaseEvent, int phase, Scene sender)
    ObjectReference[] params = self.GetSceneParameters(name)
    self.OnScenePlayingHandleGlobals(name, phaseEvent, phase, params)

    ; Debug("SceneManager::OnScenePlaying", string_if (phaseEvent == PHASE_START, "(Start) Playing", "(End) Played") + " Phase " + phase + " of " + name)
    Debug("SceneManager::OnScenePlaying", name + " " + sender + ": " + string_if (phaseEvent == PHASE_START, "(Start)", "(End)") + " Phase " + phase)

    if (name == SCENE_ARREST_START_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)
        arrestee.SetForm("Escort", escort, arrestee.DestroyPropertyOnState("Imprisoned"))

        if (phaseEvent == PHASE_START)
        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                ; Make arrestee put hands behind their back
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Hands Behind Back")
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Handcuff")
            endif
        endif

    elseif (name == SCENE_ARREST_START_02)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)
        arrestee.SetForm("Escort", escort, "Temporary::Imprisoned")

        if (phaseEvent == PHASE_START)
            if (phase == 3)
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Handcuff")
            endif

        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                ; Make Arrestee turn around and put hands behind the back
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Hands Behind Back")
            endif
        endif

    elseif (name == SCENE_ARREST_START_03)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)
        arrestee.SetForm("Escort", escort, "Temporary::Imprisoned")

        if (phaseEvent == PHASE_START)
            if (phase == 4)
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Handcuff") ; TODO: Change this to ArrestMiddle
            endif

        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                ; OrientRelative(escortee, escort)
                ; Debug.SendAnimationEvent(escortee, "ZazAPC018")
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Kneel Down")
            endif
        endif

    elseif (name == SCENE_ARREST_START_04)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)
        arrestee.SetForm("Escort", escort, "Temporary::Imprisoned")

        if (phaseEvent == PHASE_START)

        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                ; Make arrestee lie down
                ; Debug.SendAnimationEvent(arrestee, "ZazAPC011")
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Lie Down")
            elseif (phase == 6)
                ; Make arrestee get up (by restraining the animation is canceled)
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Handcuff") ; TODO: Change this to ArrestEnd
                ; Arrest.OnArresting(captor, arrestee)
            endif
        endif

    elseif (name == SCENE_ARREST_START_PRISON_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)
        arrestee.SetForm("Escort", escort, "Temporary::Imprisoned")

        if (phaseEvent == PHASE_START)

        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                ; Make arrestee put their hands behind the back
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Hands Behind Back")
                ; OrientRelative(arrestee, captor)
                ; Debug.SendAnimationEvent(arrestee, "ZazAPC001")
            elseif (phase == 2)
                ; Restrain
                ; Arrest.OnArresting(captor, arrestee)
                Arrest.FireArresteeEventOnScene(name, "ArrestStart", arrestee, "Handcuff")
            endif
        endif

    elseif (name == SCENE_ESCORT_TO_CELL_01)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor
        ; ObjectReference jailCell  = params[4]
        RPB_JailCell jailCell  = params[4] as RPB_JailCell
        RPB_CellDoor cellDoor  = params[5] as RPB_CellDoor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisoner)
        RPB_Prisoner prisonerReference = prison.AwaitPrisonerReference(prisoner)
        prisonerReference.SetForm("EscortGuard", guard, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)
        prisonerReference.SetForm("CellDoor", cellDoor, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)


        if (phaseEvent == PHASE_START)
            if (phase == 4)
            elseif (phase == 5)
            elseif (phase == 7)
                prison.FirePrisonerEventOnScene(name, "EscortEnd", prisonerReference, "Lock Cell Door")
            endif
            
        elseif (phaseEvent == PHASE_END)
            if (phase == 3)
                ; Put XMarker on this spot, which is where the guard is waiting before obstructing the cell
                ; ObjectReference guardWaitingSpotMarker = GetFormFromMod(0x15700) as ObjectReference
                ; guard.PlaceAtMe(guardWaitingSpotMarker)
                ; BindAliasTo(self.GetGuardWaitingSpot(), guardWaitingSpotMarker)
                ; Debug("SceneManager::OnScenePlaying", "Placed GuardWaitingSpotMarker: " + guardWaitingSpotMarker + " near " + guard)
                ; Debug("SceneManager::OnScenePlaying", "GuardWaitingSpotMarker Alias: " + self.GetGuardWaitingSpot() + " References ("+ self.GetGuardWaitingSpot() .GetReference() +")")


            elseif (phase == 4)
                prison.FirePrisonerEventOnScene(name, "EscortEnd", prisonerReference, "Unlock Cell Door")

            elseif (phase == 5)
                ; Jail.OnEscortToCellDoorOpen(guard, prisoner)
                prison.FirePrisonerEventOnScene(name, "Escorting", prisonerReference, "Release from Captor")

            elseif (phase == 6)

            endif
        endif

    elseif (name == SCENE_ESCORT_TO_CELL_02)
        Actor guard                 = params[0] as Actor
        Actor prisoner              = params[1] as Actor
        ObjectReference jailCell    = params[2]
        ObjectReference cellDoor    = params[3]


        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisoner)

        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(prisoner)

        if (phaseEvent == PHASE_START)
        elseif(phaseEvent == PHASE_END)
            if (phase == 1)
                ; Make prisoner put their hands behind their back
                OrientRelative(prisoner, guard, afRotZ = 180)
                Debug.SendAnimationEvent(prisoner, "ZazAPC001")
            elseif (phase == 2)
                ; Restrain prisoner
                prison.RestrainPrisoner(prisonerReference) ; Later the jail script should have a restrain method too, as this is not the arrest, but imprisonment
            elseif (phase == 8)
                ; Lock cell
                cellDoor.SetLockLevel(100)
                cellDoor.SetOpen(false)
                cellDoor.Lock()
            endif
        endif

    elseif (name == SCENE_ESCORT_FROM_CELL)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        if (phaseEvent == PHASE_START)
            
        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                RetainAI(prisoner == config.Player)
            endif

        endif

    elseif (name == SCENE_ESCORT_TO_JAIL_01)

        if (phaseEvent == PHASE_START)
        elseif (phaseEvent == PHASE_END)
        endif

    elseif (name == SCENE_ESCORT_TO_JAIL_02)

        if (phaseEvent == PHASE_START)
        elseif (phaseEvent == PHASE_END)
        endif

    elseif (name == SCENE_STRIPPING_01)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RetainAI(strippedPrisoner == config.Player)

    elseif (name == SCENE_STRIPPING_02)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)

        int i = 0
        while (i < params.Length)
            Actor currentPrisoner = params[i] as Actor
            if (currentPrisoner != none && currentPrisoner != stripperGuard)
                RetainAI(params[i] == Config.Player)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(params[i] as Actor)
                ; prison.OnPrisonerStripBegin(prisoner, stripperGuard)
                Debug("SceneManager::OnScenePlaying", "SCENE_STRIPPING_02 -> strippedPrisoner: " + currentPrisoner + ", prison: " + prison.Name + ", prisoner: " + prisoner)

                if (phaseEvent == PHASE_START)
                    if (phase == 2)
        
                    elseif (phase == 6) ; Remove Underwear
                        ; prisoner.SetForm("StripperGuard", stripperGuard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                        ; prison.FirePrisonerEventOnScene(name, "StripMiddle", prisoner, "Remove Underwear")
                    endif
                    
                elseif (phaseEvent == PHASE_END)

                endif
            endif
            i += 1
        endWhile


    elseif (name == SCENE_FORCED_STRIPPING_02)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison               = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)
        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(strippedPrisoner)

        prisonerReference.SetForm("StripperGuard", stripperGuard, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)

        if (phaseEvent == PHASE_START)

        elseif (phaseEvent == PHASE_END)
            if (phase == 1) ; Make Prisoner lie down
                prison.FirePrisonerEventOnScene(name, "StripMiddle", prisonerReference, "Lie Down")

            elseif (phase == 3) ; Undress lower body
                prison.FirePrisonerEventOnScene(name, "StripMiddle", prisonerReference, "Undress Lower Body")

            elseif (phase == 5) ; Make Prisoner sit down
                prison.FirePrisonerEventOnScene(name, "StripMiddle", prisonerReference, "Sit Down")

            elseif (phase == 7) ; Undress upper body
                prison.FirePrisonerEventOnScene(name, "StripMiddle", prisonerReference, "Undress Upper Body")
            endif
        endif

    elseif (name == SCENE_FRISKING)

        if (phaseEvent == PHASE_START)
        elseif (phaseEvent == PHASE_END)
        endif

    elseif (name == SCENE_GIVE_CLOTHING)

        if (phaseEvent == PHASE_START)
        elseif (phaseEvent == PHASE_END)
        endif

    elseif (name == SCENE_UNLOCK_CELL)

        if (phaseEvent == PHASE_START)
        elseif (phaseEvent == PHASE_END)
        endif


    elseif (name == SCENE_FORCED_STRIPPING_01)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)
        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(strippedPrisoner)

        prisonerReference.SetForm("StripperGuard", stripperGuard, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)

        if (phaseEvent == PHASE_START)
            
        elseif (phaseEvent == PHASE_END)
            if (phase == 0)
                
            endif

            if (phase == 1) ; Make Prisoner lie down
                prison.FirePrisonerEventOnScene(name, "StripMiddle", prisonerReference, "Lie Down")

            elseif (phase == 2) ; Remove Clothing (Keep Underwear)
                prison.FirePrisonerEventOnScene(name, "StripMiddle", prisonerReference, "Undress to Underwear")

            elseif (phase == 3) ; Remove Underwear
                prison.FirePrisonerEventOnScene(name, "StripMiddle", prisonerReference, "Remove Underwear")
            endif
        endif

    elseif (name == SCENE_RESTRAIN_PRISONER_01)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisoner)

        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(prisoner)


        if (phaseEvent == PHASE_START)
            
        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                Debug.SendAnimationEvent(prisoner, "IdleWarmHands") ; Give hands to the guard

            elseif (phase == 2)
                ; Jail.RestrainPrisoner(prisoner, abRestrainInFront = true)
                prison.RestrainPrisoner(prisonerReference, true)

            endif
        endif

    elseif (name == SCENE_RESTRAIN_PRISONER_02)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisoner)

        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(prisoner)

        if (phaseEvent == PHASE_START)
            
        elseif (phaseEvent == PHASE_END)
            if (phase == 1)
                Debug.SendAnimationEvent(prisoner, "ZazAPC001") ; Make prisoner put their hands behind the back

            elseif (phase == 2)
                ; Jail.RestrainPrisoner(prisoner)
                prison.RestrainPrisoner(prisonerReference)
            endif
        endif

    elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
        Actor escort                    = params[0] as Actor
        Actor escortee                  = params[1] as Actor
        ObjectReference escortLocation  = params[2]

    elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
        Actor escort                    = params[0] as Actor
        Actor escortee                  = params[1] as Actor
        ObjectReference escortLocation  = params[2]

        if (phaseEvent == PHASE_START)
            
        elseif (phaseEvent == PHASE_END)
            if (phase == 3)
                RetainAI(escortee == Config.Player)
                OrientRelative(escortee, escort, afRotZ = 180)
                Debug.SendAnimationEvent(escortee, "ZazAPC001") ; Make arrestee put their hands behind the back
                Arrest.RestrainArrestee(escortee)
            endif
        endif

    endif
endEvent

event OnSceneEnd(string name, Scene sender)
    ObjectReference[] params = self.GetSceneParameters(name)

    if (name == SCENE_ARREST_START_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)

        arrestee.SetForm("Escort", escort, arrestee.DestroyPropertyOnState("Imprisoned"))
        Arrest.FireArresteeEventOnScene(name, "ArrestEnd", arrestee)

        ; arrest.OnArrestStart(escort, escortee)

    elseif (name == SCENE_ARREST_START_02)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)

        arrestee.SetForm("Escort", escort, arrestee.DestroyPropertyOnState("Imprisoned"))
        Arrest.FireArresteeEventOnScene(name, "ArrestEnd", arrestee)

    elseif (name == SCENE_ARREST_START_03)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)

        arrestee.SetForm("Escort", escort, arrestee.DestroyPropertyOnState("Imprisoned"))
        Arrest.FireArresteeEventOnScene(name, "ArrestEnd", arrestee)

    elseif (name == SCENE_ARREST_START_04)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)

        arrestee.SetForm("Escort", escort, arrestee.DestroyPropertyOnState("Imprisoned"))
        Arrest.FireArresteeEventOnScene(name, "ArrestEnd", arrestee)

    elseif (name == SCENE_ARREST_START_PRISON_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Arrestee arrestee = Arrest.AwaitArresteeReference(escortee)

        arrestee.SetForm("Escort", escort, arrestee.DestroyPropertyOnState("Imprisoned"))
        Arrest.FireArresteeEventOnScene(name, "ArrestEnd", arrestee, "Arrest in Prison")

    elseif (name == SCENE_ESCORT_TO_CELL_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor
        RPB_JailCell jailCell  = params[4] as RPB_JailCell
        RPB_CellDoor cellDoor  = params[5] as RPB_CellDoor

        ReleaseAI(escortee == Config.Player)

        ; cellDoor.Lock()

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(escortee)
        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(escortee)

        prisonerReference.SetForm("EscortGuard", escort, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)
        prison.FirePrisonerEventOnScene(name, "EscortEnd", prisonerReference)

    elseif (name == SCENE_ESCORT_TO_CELL_02)
        Actor guard                 = params[0] as Actor
        Actor prisoner              = params[1] as Actor
        ObjectReference jailCell    = params[2] as Actor
        ObjectReference cellDoor    = params[3] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisoner)

        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(prisoner)
        prisonerReference.SetForm("EscortGuard", guard, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)
        prison.FirePrisonerEventOnScene(name, "EscortEnd", prisonerReference)
        ReleaseAI(prisoner == Config.Player)

    elseif (name == SCENE_ESCORT_FROM_CELL)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(prisoner)

        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(prisoner)
        prisonerReference.SetForm("EscortGuard", guard, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)
        prison.FirePrisonerEventOnScene(name, "EscortEnd", prisonerReference)
        ReleaseAI(prisoner == Config.Player)

    elseif (name == SCENE_ESCORT_TO_JAIL_01)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(escortee)


        int i = 0
        while (i < params.Length)
            if (params[i] != None && params[i] != escort)
                RPB_Actor actorReference = prison.AwaitPrisonerReference(escortee)
                if (actorReference == none)
                    actorReference = Arrest.AwaitArresteeReference(params[i] as Actor)

                    RPB_Arrestee arrestee = actorReference as RPB_Arrestee
                    arrestee.SetForm("EscortGuard", escort, "Temporary::Imprisoned")
                    Arrest.FireArresteeEventOnScene(name, "EscortEnd", arrestee)
                    
                    Debug("["+ SCENE_ESCORT_TO_JAIL_01 +"] SceneManager::OnSceneEnd", "params["+i+"] = " + params[i])
                    Debug("["+ SCENE_ESCORT_TO_JAIL_01 +"] SceneManager::OnSceneEnd", "Arrestee: " + arrestee + ", Actor: " + actorReference + ", Escort: " + arrestee.GetForm("EscortGuard", "Temporary::Imprisoned"))
                
                else
                    RPB_Prisoner prisonerReference = actorReference as RPB_Prisoner

                    if (prisonerReference == none)
                        prisonerReference = prison.MakePrisoner(params[i] as Actor)
                        Debug("["+ SCENE_ESCORT_TO_JAIL_01 +"] SceneManager::OnSceneEnd", "Making arrestee a prisoner... ["+ prisonerReference +"]")
                        ; prisonerReference.UnequipAll()
                    endif
                    prisonerReference.SetForm("EscortGuard", escort, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)
                    prison.FirePrisonerEventOnScene(name, "EscortEnd", prisonerReference)
                endif

            endif
            i += 1
        endWhile

    elseif (name == SCENE_ESCORT_TO_JAIL_02)
        Actor escort   = params[0] as Actor
        Actor escortee = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(escortee)

        RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(escortee)
        prisonerReference.SetForm("EscortGuard", escort, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)
        prison.FirePrisonerEventOnScene(name, "EscortEnd", prisonerReference)

        ; prison.OnEscortPrisonerToJailEnd(prisonerReference, escort)

    elseif (name == SCENE_STRIPPING_01)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)


        int i = 0
        while (i < params.Length)
            if (params[i] != None && params[i] != stripperGuard && params[i] as Actor)
                RPB_Prisoner prisonerReference  = prison.AwaitPrisonerReference(params[i] as Actor)
                prisonerReference.SetForm("StripperGuard", stripperGuard, prisonerReference.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "StripEnd", prisonerReference, "Restrain Prisoner")
            endif
            i += 1
        endWhile

    elseif (name == SCENE_STRIPPING_02)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)


        int i = 0
        while (i < params.Length)
            Actor currentPrisoner = params[i] as Actor
            if (currentPrisoner != none && currentPrisoner != stripperGuard)
                RPB_Prisoner prisoner = prison.AwaitPrisonerReference(currentPrisoner)
                Debug("SceneManager::OnScenePlaying", "Prisoner Keys: " + prison.Prisoners.GetKeys() + ", prisoner: " + prisoner)
                prisoner.SetForm("StripperGuard", stripperGuard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                prison.FirePrisonerEventOnScene(name, "StripEnd", prisoner)
            endif
            i += 1
        endWhile

    elseif (name == SCENE_FORCED_STRIPPING_02)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)

        RPB_Prisoner prisoner  = prison.AwaitPrisonerReference(strippedPrisoner)
        prisoner.SetForm("StripperGuard", stripperGuard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
        prison.FirePrisonerEventOnScene(name, "StripEnd", prisoner, "Stand Up (Kneel)")

    elseif (name == SCENE_FRISKING)
        Actor searcherGuard     = params[0] as Actor
        Actor searchedPrisoner  = params[1] as Actor

        ; jail.OnFriskEnd(searcherGuard, searchedPrisoner)

    elseif (name == SCENE_GIVE_CLOTHING)
        Actor searcherGuard     = params[0] as Actor
        Actor searchedPrisoner  = params[1] as Actor

        ReleaseAI(searchedPrisoner == config.Player)

        ; jail.OnClothingGiven(searcherGuard, searchedPrisoner)

    elseif (name == SCENE_PAYMENT_FAIL)
        Actor guard     = params[0] as Actor
        Actor prisoner  = params[1] as Actor

        ; jail.OnBountyPaymentFailed(guard, prisoner)


    elseif (name == SCENE_FORCED_STRIPPING_01)
        Actor stripperGuard     = params[0] as Actor
        Actor strippedPrisoner  = params[1] as Actor

        RPB_Prison prison = PrisonManager.FindPrisonByPrisoner(strippedPrisoner)

        RPB_Prisoner prisoner  = prison.AwaitPrisonerReference(strippedPrisoner)
        prisoner.SetForm("StripperGuard", stripperGuard, prisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
        prison.FirePrisonerEventOnScene(name, "StripEnd", prisoner, "Stand Up (Lie Down)")

        ; strippedPrisoner.SetAV("Paralysis", 0)
        ; Debug.SendAnimationEvent(strippedPrisoner, "IdleLayDownExit")
        Debug("SceneManager::OnSceneEnd", "Reached Forced Stripping block")

    elseif (name == SCENE_ELUDING_ARREST_01)
        Actor guard     = params[0] as Actor
        Actor eluder    = params[1] as Actor

    elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
        Actor escort                    = params[0] as Actor
        Actor escortee                  = params[1] as Actor
        ObjectReference escortLocation  = params[2]

        Arrest.OnArrestPayBountyEnd(escort, escortee, escort.GetCrimeFaction(), false)

    elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
        Actor escort                    = params[0] as Actor
        Actor escortee                  = params[1] as Actor
        ObjectReference escortLocation  = params[2]

        Arrest.OnArrestPayBountyEnd(escort, escortee, escort.GetCrimeFaction(), true)
        ReleaseAI(escortee == Config.Player)
    endif

    self.ResetSceneOverride()

    Debug("SceneManager::OnSceneEnd", self.GetSceneParametersDebugInfo(sender, name, params))
    Info(self.GetSceneParametersDebugInfo(sender, name, params))

    self.PlayQueued()
    __isScenePlaying = false ; Scene has finished playing
    self.OnResumeSceneBlocked()
    self.OnSceneEndHandleGlobals(name, params)
endEvent

function StartScene(string asSceneName, int akSceneParameters, int aiStartingPhase = 1, bool abForceStart = false)
    if (!self.SceneExists(asSceneName))
        Error("SceneManager::StartScene", "Tried to start Scene " + asSceneName + ": Scene does not exist!")
        return
    endif

    Scene sceneObject = self.GetScene(asSceneName)

    if (sceneObject.IsPlaying() && !abForceStart)
        Debug("SceneManager::StartScene", "Scene " + sceneObject + " is currently playing, aborting call!")
        return
    endif

    ; Setup parameters

    ; Setup starting phase
    self.StartSceneAtPhase(aiStartingPhase)

    if (abForceStart)
        sceneObject.ForceStart()
    
    else
        sceneObject.Start()
    endif
endFunction

function StartEscortToCell(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, RPB_CellDoor akJailCellDoor, ObjectReference akEscortWaitingMarker)
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(self.GetEscort(), akEscortLeader)

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(self.GetEscortee(), akEscortedPrisoner)

    ; BindAliasTo(self.GetEscortee(1), self.GetPrisoner(1).GetReference()) ; TODO: Support for multiple Actor arrest/escorting

    ; Bind the prisoner's destination point, the jail cell
    BindAliasTo(self.GetPrisonerLocation(), akJailCellMarker)

    ; Bind the the jail cell door
    BindAliasTo(self.GetCellDoor(), akJailCellDoor)

    ObjectReference waitingEscortMarker = akEscortWaitingMarker
    if (waitingEscortMarker == none)
        waitingEscortMarker = akJailCellDoor
    endif

    ; Bind the guard waiting marker
    BindAliasTo(self.GetGuardLocation(), waitingEscortMarker)

    self.QueueOrPlay(SCENE_ESCORT_TO_CELL_01)
    ; self.GetScene(SCENE_ESCORT_TO_CELL_01).Start()
    ; EscortToCell.Start()
endFunction

function StartEscortToCell_02(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, ObjectReference akJailCellDoor, ObjectReference akEscortWaitingMarker)
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(self.GetGuard(), akEscortLeader)

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(self.GetPrisoner(), akEscortedPrisoner)

    ; Bind the prisoner's destination point, the jail cell
    BindAliasTo(self.GetCell(), akJailCellMarker)

    ; Bind the guard's destination point, the jail cell door
    BindAliasTo(self.GetCellDoor(), akJailCellDoor)

    ObjectReference waitingEscortMarker = akEscortWaitingMarker
    ; if (waitingEscortMarker == none)
    ;     waitingEscortMarker = akJailCellDoor
    ; endif
    
    ; Bind the guard waiting marker
    BindAliasTo(self.GetGuardLocation(), waitingEscortMarker)

    self.QueueOrPlay(SCENE_ESCORT_TO_CELL_02)
    ; self.GetScene(SCENE_ESCORT_TO_CELL_02).Start()
    ; EscortToCell_02.Start()
endFunction

function StartEscortFromCell(Actor akGuard, Actor akPrisoner, ObjectReference akJailCellDoor, ObjectReference akJailChest)
    Debug("SceneManager::StartEscortFromCell", "Starting Scene " + self.GetScene(SCENE_ESCORT_FROM_CELL) +", params: ["+ akGuard + "," + akPrisoner + "," + akJailCellDoor + "," + akJailChest + "]")
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(self.GetGuard(), akGuard)

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(self.GetPrisoner(), akPrisoner)

    BindAliasTo(self.GetPrisonerLocation(), akJailChest)

    BindAliasTo(self.GetGuardLocation(), akJailCellDoor)

    self.QueueOrPlay(SCENE_ESCORT_FROM_CELL)
    ; self.GetScene(SCENE_ESCORT_FROM_CELL).Start()
    ; EscortFromCell.Start()
endFunction

function StartEscortToJail(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akPrisonerChest)
    ; Bind the captor to its alias to lead the escort scene
    BindAliasTo(self.GetEscort(), akEscortLeader)
    ; BindAliasTo(self.GetEscortee(1), GetNearestActor(akEscortedPrisoner, 9000))
    ; BindAliasTo(self.GetEscortee(2), GetNearestActor(akEscortedPrisoner, 9000))

    ; Bind the prisoner to its alias to be escorted
    BindAliasTo(self.GetEscortee(), akEscortedPrisoner)

    ; Bind the destination point, the chest
    BindAliasTo(self.GetPrisonerLocation(), akPrisonerChest)

    ; Bind the guard's destination point, the jail cell door
    BindAliasTo(self.GetGuardLocation(), akPrisonerChest)

    self.QueueOrPlay(SCENE_ESCORT_TO_JAIL_01)
    ; self.GetScene(SCENE_ESCORT_TO_JAIL_01).Start()
    ; EscortToJail.Start()
endFunction

function StartMultipleEscortsToJail(Actor akEscortLeader, Actor[] akEscortedPrisoners, ObjectReference akPrisonerChest)
    ; Bind the leader to its alias to lead the escort scene
    BindAliasTo(self.GetEscort(), akEscortLeader)

    ; Bind the prisoners to their aliases to be escorted
    int i = 0
    while (i < akEscortedPrisoners.Length)
        BindAliasTo(self.GetAliasByName("Escortee" + i) as ReferenceAlias, akEscortedPrisoners[i])
        i += 1
    endWhile

    ; Bind the destination point, the chest
    BindAliasTo(self.GetPrisonerLocation(), akPrisonerChest)

    ; Bind the destination point, the chest
    BindAliasTo(self.GetGuardLocation(), akPrisonerChest)
endFunction

function StartStrippingStart(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAliasTo(self.GetGuard(), akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAliasTo(self.GetPrisoner(), akStrippedPrisoner)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAliasTo(self.GetPrisoner(1), self.GetEscortee(1).GetActorReference())
    BindAliasTo(self.GetPrisoner(2), self.GetEscortee(2).GetActorReference())
    BindAliasTo(self.GetPrisoner(3), self.GetEscortee(3).GetActorReference())

    self.QueueOrPlay(SCENE_STRIPPING_START_01)
    ; self.GetScene(SCENE_STRIPPING_START_01).Start()

    ; StrippingStart.Start()
endFunction

function StartStripping(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAliasTo(self.GetGuard(), akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAliasTo(self.GetPrisoner(), akStrippedPrisoner)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAliasTo(self.GetPrisoner(1), self.GetEscortee(1).GetActorReference())
    BindAliasTo(self.GetPrisoner(2), self.GetEscortee(2).GetActorReference())

    self.QueueOrPlay(SCENE_STRIPPING_01)
    ; self.GetScene(SCENE_STRIPPING_01).Start()
    ; Stripping.Start()
endFunction

function StartStripping_02(Actor akStripperGuard, Actor akStrippedPrisoner, ObjectReference akStripMarker = none)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAliasTo(self.GetGuard(), akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAliasTo(self.GetPrisoner(), akStrippedPrisoner)

    BindAliasTo(self.GetGuardLocation(), akStripMarker)
    BindAliasTo(self.GetPrisonerLocation(), akStripMarker)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAliasTo(self.GetPrisoner(1), self.GetEscortee(1).GetActorReference())
    BindAliasTo(self.GetPrisoner(2), self.GetEscortee(2).GetActorReference())

    self.QueueOrPlay(SCENE_STRIPPING_02)
    ; self.GetScene(SCENE_STRIPPING_02).Start()
    ; Stripping_02.Start()
endFunction

function StartFrisking(Actor akFriskerGuard, Actor akFriskedPrisoner)
    ; Bind the guard to be the one performing the frisk search
    BindAliasTo(self.GetGuard(), akFriskerGuard)

    ; Bind the Prisoner to be the actor being frisk searched
    BindAliasTo(self.GetPrisoner(), akFriskedPrisoner)

    self.QueueOrPlay(SCENE_FRISKING)
    ; self.GetScene(SCENE_FRISKING).Start()
    ; Frisking.Start()
endFunction

function StartGiveClothing(Actor akGuard, Actor akPrisoner)
    ; Bind the guard to be the one giving clothing
    BindAliasTo(self.GetGuard(), akGuard)

    ; Bind the Prisoner to be the actor being given clothing
    BindAliasTo(self.GetPrisoner(), akPrisoner)

    self.QueueOrPlay(SCENE_GIVE_CLOTHING)
    ; self.GetScene(SCENE_GIVE_CLOTHING).Start()
    ; GiveClothing.Start()
endFunction

function StartUnlockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAliasTo(self.GetEscort(), akGuard)
    BindAliasTo(self.GetGuardLocation(), akJailCellDoor)

    ; UnlockCell.Start()
endFunction

function StartLockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAliasTo(self.GetEscort(), akGuard)
    BindAliasTo(self.GetGuardLocation(), akJailCellDoor)

    ; LockCell.Start()
endFunction

function StartBountyPaymentFail(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's trying to pay the bounty
    BindAliasTo(self.GetPrisoner(), akPrisoner)

    self.QueueOrPlay(SCENE_PAYMENT_FAIL)
    ; self.GetScene(SCENE_PAYMENT_FAIL).Start()
    ; BountyPaymentFail.Start()
endFunction

function StartArrestStart01(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(self.GetEscort(), akGuard)

    ; Bind the Prisoner, who's getting arrested
    BindAliasTo(self.GetEscortee(), akPrisoner)

    ; ArrestStart01.Start()

    self.QueueOrPlay(SCENE_ARREST_START_01)
    ; self.GetScene(SCENE_ARREST_START_01).Start()
endFunction

function StartArrestStart02(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(self.GetEscort(), akGuard)

    ; Bind the Prisoner, who's getting arrested
    BindAliasTo(self.GetEscortee(), akPrisoner)

    self.QueueOrPlay(SCENE_ARREST_START_02)
    ; self.GetScene(SCENE_ARREST_START_02).Start()
    ; ArrestStart02.Start()
endFunction

function StartArrestStart03(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(self.GetEscort(), akGuard)

    ; Bind the Prisoner, who's getting arrested
    BindAliasTo(self.GetEscortee(), akPrisoner)

    self.QueueOrPlay(SCENE_ARREST_START_03)
    ; self.GetScene(SCENE_ARREST_START_03).Start()
endFunction

function StartArrestStart04(Actor akGuard, Actor akPrisoner)
    ; Bind the captor
    BindAliasTo(self.GetCaptor(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAliasTo(self.GetArrestee(), akPrisoner)

    self.QueueOrPlay(SCENE_ARREST_START_04)
    ; self.GetScene(SCENE_ARREST_START_04).Start()
    ; ArrestStart04.Start()
endFunction

function StartArrestScene(Actor akGuard, Actor akArrestee, string asScene)
    ; Bind the captor
    BindAliasTo(self.GetEscort(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAliasTo(self.GetEscortee(), akArrestee)
    
    self.QueueOrPlay(asScene)
    ; self.GetScene(asScene).Start()
endFunction

function StartEscortToJailScene(Actor akGuard, Actor akArrestee, string asScene)
    ; Bind the captor
    BindAliasTo(self.GetEscort(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAliasTo(self.GetEscortee(), akArrestee)

    self.QueueOrPlay(asScene)
    ; self.GetScene(asScene).Start()
endFunction

function StartArrestStartPrison_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    ; Bind the captor
    BindAliasTo(self.GetEscort(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAliasTo(self.GetEscortee(), akPrisoner)

    self.StartSceneAtPhase(aiStartingPhase)
    ; self.GetScene(SCENE_ARREST_START_PRISON_01).Start()
    self.QueueOrPlay(SCENE_ARREST_START_PRISON_01)
endFunction

function StartRestrainPrisoner_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    BindAliasTo(self.GetGuard(), akGuard)
    BindAliasTo(self.GetPrisoner(), akPrisoner)

    self.StartSceneAtPhase(aiStartingPhase)
    ; self.GetScene(SCENE_RESTRAIN_PRISONER_01).Start()
    self.QueueOrPlay(SCENE_RESTRAIN_PRISONER_01)

endFunction

function StartRestrainPrisoner_02(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    BindAliasTo(self.GetGuard(), akGuard)
    BindAliasTo(self.GetPrisoner(), akPrisoner)

    self.StartSceneAtPhase(aiStartingPhase)
    ; self.GetScene(SCENE_RESTRAIN_PRISONER_02).Start()
    self.QueueOrPlay(SCENE_RESTRAIN_PRISONER_02)
endFunction

function StartNoClothing(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's undressed and given no clothing
    BindAliasTo(self.GetPrisoner(), akPrisoner)

    self.QueueOrPlay(SCENE_NO_CLOTHING)
    ; self.GetScene(SCENE_NO_CLOTHING).Start()
    ; NoClothing.Start()
endFunction

function StartForcedStripping(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's about to be stripped
    BindAliasTo(self.GetPrisoner(), akPrisoner)
    
    self.QueueOrPlay(SCENE_FORCED_STRIPPING_01)
    ; self.GetScene(SCENE_FORCED_STRIPPING_01).Start()
    ; ForcedStripping01.Start()
endFunction

function StartForcedStripping02(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAliasTo(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's about to be stripped
    BindAliasTo(self.GetPrisoner(), akPrisoner)

    self.QueueOrPlay(SCENE_FORCED_STRIPPING_02)
    ; self.GetScene(SCENE_FORCED_STRIPPING_02).Start()
    ; ForcedStripping02.Start()
endFunction

function StartEludingArrest(Actor akGuard, Actor akEluder)
    if (self.GetScene(SCENE_ELUDING_ARREST_01).IsPlaying())
        Debug("SceneManager::StartEludingArrest", "Scene is currently playing, aborting call!")
        return
    endif

    ; Bind the guard
    BindAliasTo(self.GetGuard(), akGuard)

    ; Bind the Eluder, who is eluding arrest
    BindAliasTo(self.GetEluder(), akEluder)

    Debug("SceneManager::StartEludingArrest", "Scene: "+ self.GetScene(SCENE_ELUDING_ARREST_01) +" Params ["+ akGuard + ", " + akEluder + "] | Aliases: ["+ self.GetGuard() + ", " + self.GetEluder() + "]")

    self.QueueOrPlay(SCENE_ELUDING_ARREST_01)
    ; self.GetScene(SCENE_ELUDING_ARREST_01).Start()
    ; EludingArrest.Start()
endFunction

function StartArrestBountyPaymentFollowWillingly(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    BindAliasTo(self.GetEscort(), akEscort)
    BindAliasTo(self.GetEscortee(), akEscortee)
    BindAliasTo(self.GetGuardLocation(), akEscortLocation)
    BindAliasTo(self.GetPrisonerLocation(), akEscortLocation)

    self.QueueOrPlay(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
    ; self.GetScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY).Start()
endFunction

function StartArrestPayBountyFollowByForce(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    BindAliasTo(self.GetEscort(), akEscort)
    BindAliasTo(self.GetEscortee(), akEscortee)
    BindAliasTo(self.GetGuardLocation(), akEscortLocation)
    BindAliasTo(self.GetPrisonerLocation(), akEscortLocation)

    self.QueueOrPlay(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
    ; self.GetScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE).Start()
endFunction