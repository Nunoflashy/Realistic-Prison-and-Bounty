scriptname RPB_SceneManager extends Quest

;/
@constants:
    int PHASE_START
    int PHASE_END
    string EVENT_RESTRAIN_BEGIN
    string EVENT_RESTRAINING
    string EVENT_RESTRAIN_END
    string EVENT_ARREST_BEGIN
    string EVENT_ARRESTING
    string EVENT_ARREST_END
    string EVENT_SURRENDER_BEGIN
    string EVENT_SURRENDERING
    string EVENT_SURRENDER_END
    string EVENT_ESCORT_BEGIN
    string EVENT_ESCORTING
    string EVENT_ESCORT_END
    string EVENT_FRISK_BEGIN
    string EVENT_FRISKING
    string EVENT_FRISK_END
    string EVENT_STRIP_BEGIN
    string EVENT_STRIPPING
    string EVENT_STRIP_END
    string EVENT_CLOTHING_BEGIN
    string EVENT_CLOTHING
    string EVENT_CLOTHING_END
    string EVENT_FORCED_STRIP_BEGIN
    string EVENT_FORCED_STRIPPING
    string EVENT_FORCED_STRIP_END
    string EVENT_ELUDE_BEGIN
    string EVENT_ARREST_PAYING_BOUNTY
    string EVENT_ARREST_PAY_BOUNTY_END
    string CATEGORY_ARREST_START
    string CATEGORY_SURRENDER
    string CATEGORY_ESCORT_TO_JAIL
    string CATEGORY_ESCORT_TO_CELL
    string CATEGORY_ESCORT_FROM_CELL
    string CATEGORY_FRISKING
    string CATEGORY_STRIPPING
    string CATEGORY_CLOTHING
    string CATEGORY_NO_CLOTHING
    string CATEGORY_PAYMENT_FAIL
    string CATEGORY_ELUDING
    string CATEGORY_RESTRAIN
    string CATEGORY_PAY_BOUNTY
    string SCENE_ARREST_START_01
    string SCENE_ARREST_START_02
    string SCENE_ARREST_START_03
    string SCENE_ARREST_START_04
    string SCENE_ARREST_START_PRISON_01
    string SCENE_SURRENDER_01
    string SCENE_GENERIC_ESCORT
    string SCENE_ESCORT_FROM_CELL
    string SCENE_ESCORT_TO_JAIL_01
    string SCENE_ESCORT_TO_JAIL_02
    string SCENE_ESCORT_TO_CELL_01
    string SCENE_ESCORT_TO_CELL_02
    string SCENE_ESCORT_TO_CELL_03
    string SCENE_STRIPPING_01
    string SCENE_STRIPPING_02
    string SCENE_FORCED_STRIPPING_START_01
    string SCENE_FORCED_STRIPPING_01
    string SCENE_FORCED_STRIPPING_02
    string SCENE_STRIPPING_START_01
    string SCENE_FRISKING
    string SCENE_GIVE_CLOTHING
    string SCENE_UNLOCK_CELL
    string SCENE_PAYMENT_FAIL
    string SCENE_NO_CLOTHING
    string SCENE_ELUDING_ARREST_01
    string SCENE_RESTRAIN_PRISONER_01
    string SCENE_RESTRAIN_PRISONER_02
    string SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY
    string SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE
    float SCENE_START_COMBAT_CAP_SECONDS
@references:
    RPB_API API
    RPB_Config Config
    RPB_EventManager EventManager
@properties:
    GlobalVariable RPB_SceneBlockNormalExecution
    GlobalVariable RPB_SceneStartAtPhase
    Scene UnlockCell
    Scene LockCell
@functions:
    function SceneManager()
    function AddGlobal(string asGlobalName, int aiGlobalFormID, int aiDefaultValue = 0)
    bool function HasGlobal(string asGlobal)
    GlobalVariable function GetGlobal(string asGlobal)
    function SetGlobal(string asGlobal, int aiValue)
    function ResetGlobal(string asGlobal)
    function SetupGlobals()
    function ResetGlobals()
    function StartSceneAtPhase(int phase)
    function ResetSceneOverride()
    function ResumeSceneBlocked()
    function AddScene(string asSceneName, int aiSceneFormID, string asSceneCategory = "null")
    string function GetSceneNameByIndex(int aiIndex)
    int function GetSceneFormID(string asSceneName)
    string function GetSceneNameByFormID(int aiSceneFormID)
    bool function SceneExists(string asSceneName)
    bool function IsSceneOfType(string asSceneName, string asCategory)
    string function GetSceneType(string asSceneName)
    function SetupScenes()
    function CreateSceneRefTypeConfig(string asScene, string asRefType, int aiAliasCount, int aiAliasStartIndex)
    function CacheSceneRefType(string asScene, string asRefType, int aiRefTypeIndex, int aiRefTypeID)
    function InvalidateSceneAliases(string asScene, string asRefType)
    function RemoveSceneRefType(string asScene, string asRefType)
    int function GetSceneRefTypesConfig(string asScene)
    int function GetSceneRefsOfTypeObject(string asScene, string asRefType)
    Alias[] function GetSceneAliasesOfType(string asScene, string asRefType, bool abOnlyIncludeAliasesInUse = false)
    ReferenceAlias function GetSceneNthAliasOfType(string asScene, string asRefType, int aiIndex = 0)
    string[] function GetSceneRefTypes(string asScene)
    Alias[] function GetSceneAliases(string asScene, bool abOnlyIncludeAliasesInUse = false)
    Form[] function GetSceneReferences(string asScene)
    Form[] function GetSceneReferencesOfType(string asScene, string asRefType)
    ObjectReference function GetSceneNthReferenceOfType(string asScene, string asRefType, int aiIndex = 0)
    function CreateSceneConfig()
    Scene function GetScene(string asSceneName)
    bool function IsIdle()
    int function GetCurrentPhase(string asScene)
    string function GetCurrentScene()
    bool function HasQueuedScenes()
    function PushScene(string asSceneName)
    string function PopScene()
    function QueueOrPlay(string asSceneName)
    function PlayQueued()
    bool function EndSceneWithActor(Actor akActor, string asReason)
    bool function HasQueuedSceneWithActor(Actor akActor)
    int function RemoveQueuedScenesWithActor(Actor akActor)
    function EndSceneEarly(string asScene, string asReason, bool abRunEndEvents = true)
    function ForceResetSceneState()
    function StopAllScenes(string asReason)
    ReferenceAlias function GetRefAlias(string aliasGroup, int index = 0)
    string function GetAliasName(string aliasName, int aliasIndex, bool checkForExistence = false)
    function SetPackageLockOnActor(Actor akActor)
    function UnsetPackageLockOnActor(Actor akActor)
    bool function SetPendingHoldOnActor(Actor akActor)
    function UnsetPendingHoldOnActor(Actor akActor)
    function ReleaseAlias(string aliasName, int aliasIndex = 0)
    function UnbindAliases(string asScene)
    function QueueAlias(ReferenceAlias apRefAlias, ObjectReference akRef, bool abBindAlias = true)
    function BindSceneAliasGroup(string asScene, string asAliasRefType, Form[] akRefs)
    function BindSceneAlias(string asScene, string asAliasRefType, ObjectReference akRef)
    function RestoreAliases(int aiAliases)
    function HandleSceneGlobalControlFlow(string asSceneType, string asScene)
    function StartScene(string asSceneName, int akSceneParameters, int aiStartingPhase = 1, bool abForceStart = false)
    function StartEscortToCell(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, RPB_CellDoor akJailCellDoor, ObjectReference akEscortWaitingMarker)
    function StartEscortToCell_02(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, ObjectReference akJailCellDoor, ObjectReference akEscortWaitingMarker)
    function StartEscortFromCell(Actor akGuard, Actor akPrisoner, ObjectReference akJailCellDoor, ObjectReference akJailChest)
    function StartEscortToJail(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akPrisonerChest)
    function EscortToJail(Actor akEscort, Form[] akEscortees, Form[] akDestinations)
    function StartStrippingStart(Actor akStripperGuard, Actor akStrippedPrisoner)
    function StartStripping(Actor akStripperGuard, Actor akStrippedPrisoner)
    function StartStripping_02(Actor akStripperGuard, Actor akStrippedPrisoner, ObjectReference akStripMarker = none)
    function StartFrisking(Actor akFriskerGuard, Actor akFriskedPrisoner)
    function StartGiveClothing(Actor akGuard, Actor akPrisoner)
    function StartBountyPaymentFail(Actor akGuard, Actor akPrisoner)
    function StartArrestStart01(Actor akGuard, Actor akPrisoner)
    function StartArrestStart02(Actor akGuard, Actor akPrisoner)
    function StartArrestStart03(Actor akGuard, Actor akPrisoner)
    function StartArrestStart04(Actor akGuard, Actor akPrisoner)
    function StartSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors, string asScene)
    function StartArrestScene(Actor akGuard, Actor akArrestee, string asScene)
    function StartEscortToJailScene(Actor akGuard, Actor akArrestee, string asScene)
    function StartArrestStartPrison_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    function StartRestrainPrisoner_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    function StartRestrainPrisoner_02(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    function StartNoClothing(Actor akGuard, Actor akPrisoner)
    function StartForcedStripping(Actor akGuard, Actor akPrisoner)
    function StartForcedStripping02(Actor akGuard, Actor akPrisoner)
    function StartEludingArrest(Actor akGuard, Actor akEluder)
    function StartArrestBountyPaymentFollowWillingly(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    function StartArrestPayBountyFollowByForce(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    string function GetSceneParametersDebugInfo(Scene sender, string sceneName)
@events:
    event OnResumeSceneBlocked()
    event OnSceneStart(string name, Scene sender)
    event OnScenePlaying(string name, int phaseEvent, int phase, Scene sender)
    event OnSceneEnd(string name, Scene sender)
    event OnAllScenesFinished()
/;

import RPB_Config
import RPB_Utility
import RPB_Memory

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

RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

; ==========================================================
;                            Init
; ==========================================================

int __globalDefaults    ; FastMap<string>
int __globals           ; FastMap<string>
int __sceneContainer    ; FastMap<string>
int __sceneToCategory   ; FastMap<string>
int __sceneConfig       ; FastMap<string>
int __queuedAliases     ; FastMap<int> - the aliases recorded for the Scene about to be queued
int __queuedScenes      ; Queue<string>
int __queuedSceneAliases ; JArray of FastMap<int>, in step with __queuedScenes: each queued Scene's own aliases

function SceneManager()
    __sceneContainer    = delete(__sceneContainer)
    __sceneToCategory   = delete(__sceneToCategory)
    __sceneConfig       = delete(__sceneConfig)
    __globals           = delete(__globals)
    __globalDefaults    = delete(__globalDefaults)
    __queuedScenes      = delete(__queuedScenes)
    __queuedAliases     = delete(__queuedAliases)

    __sceneContainer    = Object_CreateIfNotExists(__sceneContainer,  FastMap("<string>",   retain = true))
    __sceneToCategory   = Object_CreateIfNotExists(__sceneToCategory, FastMap("<string>",   retain = true))
    __sceneConfig       = Object_CreateIfNotExists(__sceneConfig,     FastMap("<string>",   retain = true))
    __globals           = Object_CreateIfNotExists(__globals,         FastMap("<string>",   retain = true))
    __globalDefaults    = Object_CreateIfNotExists(__globalDefaults,  FastMap("<string>",   retain = true))
    ; __queuedScenes      = Object_CreateIfNotExists(__queuedScenes,    Queue("<string>",     retain = true))
    __queuedAliases     = Object_CreateIfNotExists(__queuedAliases,   FastMap("<int>",      retain = true))

    self.SetupGlobals()
    self.SetupScenes()
    self.CreateSceneConfig()
endFunction

; ==========================================================
;                          Globals
; ==========================================================

function AddGlobal(string asGlobalName, int aiGlobalFormID, int aiDefaultValue = 0)
    FastMap_SetInt(__globals, asGlobalName, aiGlobalFormID)
    FastMap_SetInt(__globalDefaults, asGlobalName, aiDefaultValue)
endFunction

bool function HasGlobal(string asGlobal)
    return FastMap_HasKey(__globals, asGlobal)
endFunction

GlobalVariable function GetGlobal(string asGlobal)
    if (!self.HasGlobal(asGlobal))
        return none
    endif

    int globalFormId = FastMap_GetInt(__globals, asGlobal)
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
        int defaultValue = FastMap_GetInt(__globalDefaults, asGlobal)
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
    int globalKeys  = FastMap_Keys(__globals)
    int globalCount = FastMap_Size(__globals)

    int i = 0
    while (i < globalCount)
        string globalKey = FastArray_GetString(globalKeys, i)
        int defaultValue = FastMap_GetInt(__globalDefaults, globalKey)
        self.GetGlobal(globalKey).SetValueInt(defaultValue)
        i += 1
    endWhile

    Debug("SceneManager::ResetGlobals", "Scene Globals have been reset to their default values.")
endFunction


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
;                    Scene Block Handling
; ==========================================================

; Right now only releases the AI for Scenes that retain it, however in some instances we actually want to release it,
; so this is here as a workaround. Later it should handle more things related to End of scene blocking.
bool __resumeSceneBlocked
function ResumeSceneBlocked()
    __resumeSceneBlocked = true
endFunction

event OnResumeSceneBlocked()
    ; string lastScene = Queue_BackString(__queuedScenes) ; needs to be revised, returning empty, however it works for now
    string lastScene = JArray.getStr(__queuedScenes, -1) ; needs to be revised, returning empty, however it works for now
    Debug("SceneManager::OnResumeSceneBlocked", "ResumeSceneBlocked: " + __resumeSceneBlocked + ", Current Scene: " + currentScene + ", Last Scene: " + lastScene + ", Condition: " + (currentScene == lastScene))
    if (__resumeSceneBlocked && currentScene == lastScene)
        ReleaseAI()
        __resumeSceneBlocked = false
    endif
endEvent

; ==========================================================
;                           Scenes
; ==========================================================

Scene property UnlockCell auto
Scene property LockCell auto

function AddScene(string asSceneName, int aiSceneFormID, string asSceneCategory = "null")
    FastMap_SetInt(__sceneContainer, asSceneName, aiSceneFormID)

    if (asSceneCategory != "null")
        FastMap_SetString(__sceneToCategory, asSceneName, asSceneCategory)
    endif
endFunction

string function GetSceneNameByIndex(int aiIndex)
    return FastMap_GetNthKey(__sceneContainer, aiIndex)
endFunction

int function GetSceneFormID(string asSceneName)
    return FastMap_GetInt(__sceneContainer, asSceneName)
endFunction

string function GetSceneNameByFormID(int aiSceneFormID)
    return FastMap_GetString(__sceneContainer, aiSceneFormID)
endFunction

bool function SceneExists(string asSceneName)
    return FastMap_HasKey(__sceneContainer, asSceneName)
endFunction

;/
    Checks if a given Scene is of the specified type (category).

    string  @asSceneName: The name of the Scene.
    string  @asCategory: The category of which the Scene should be a part of.
/;
bool function IsSceneOfType(string asSceneName, string asCategory)
    return FastMap_GetString(__sceneToCategory, asSceneName) == asCategory
endFunction

string function GetSceneType(string asSceneName)
    return FastMap_GetString(__sceneToCategory, asSceneName)
endFunction

function SetupScenes()
    float x = StartBenchmark()

    self.AddScene(SCENE_ARREST_START_01,                        0xF569, CATEGORY_ARREST_START)      ; Arrest Start 01
    self.AddScene(SCENE_ARREST_START_02,                        0xFAF6, CATEGORY_ARREST_START)      ; Arrest Start 02
    self.AddScene(SCENE_ARREST_START_03,                        0x130DD, CATEGORY_ARREST_START)     ; Arrest Start 03
    self.AddScene(SCENE_ARREST_START_04,                        0x13663, CATEGORY_ARREST_START)     ; Arrest Start 04
    self.AddScene(SCENE_ARREST_START_PRISON_01,                 0x14C14, CATEGORY_ARREST_START)     ; Arrest Start Prison 01
    self.AddScene(SCENE_SURRENDER_01,                           0x26A2F, CATEGORY_SURRENDER)        ; Surrender 01
    self.AddScene(SCENE_ESCORT_TO_JAIL_01,                      0xF532, CATEGORY_ESCORT_TO_JAIL)    ; Escort to Jail
    self.AddScene(SCENE_ESCORT_TO_JAIL_02,                      0x17CDA, CATEGORY_ESCORT_TO_JAIL)   ; Escort to Jail 02
    self.AddScene(SCENE_ESCORT_TO_CELL_01,                      0xCF58, CATEGORY_ESCORT_TO_CELL)    ; Escort to Cell 01
    self.AddScene(SCENE_ESCORT_TO_CELL_04,                      0x2BAFF, CATEGORY_ESCORT_TO_CELL)   ; Escort to Cell 04 (a copy of 01, made without the CK)
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

    int sceneCount = FastMap_Size(__sceneContainer)
    string sceneListAsString = ""
    int i = 0

    while (i < sceneCount)
        sceneListAsString += "\t["+i+"]: "+ self.GetSceneNameByIndex(i) +"\n"
        i += 1
    endWhile
    EndBenchmark(x, "SetupScenes")
    Debug("SceneManager::SetupScenes", "Loaded "+ sceneCount +" Scenes: [\n" + sceneListAsString + "]")
endFunction



;/
    Creates a nested structure that contains a Scene's configuration related to
    their ReferenceAliases information.
/;
function CreateSceneRefTypeConfig(string asScene, string asRefType, int aiAliasCount, int aiAliasStartIndex)
    bool sceneExists     = FastMap_HasKey(__sceneConfig, asScene)
    int sceneRefTypesObj = FastMap_SetObject(__sceneConfig, asScene, FastMap("<string>"), condition = !sceneExists) ; FastMap<string>

    if (!sceneRefTypesObj)
        RPB_Utility.LogError("Cannot create the scene config for scene " + asScene + " (object does not exist!)", "SceneManager::CreateSceneRefTypeConfig")
        return
    endif

    int aliasIds = FastArray(retain = true)
    
    int i = aiAliasStartIndex
    while (i < aiAliasCount)
        ReferenceAlias a = self.GetRefAlias(asRefType, i)
        if (a)
            int aliasId = a.GetID()
            if (FastArray_FindInt(aliasIds, aliasId) == -1)
                FastArray_AddInt(aliasIds, aliasId)
            endif
        endif
        i += 1
    endWhile

    FastMap_SetObject(sceneRefTypesObj, asRefType, aliasIds)
endFunction

function CacheSceneRefType(string asScene, string asRefType, int aiRefTypeIndex, int aiRefTypeID)
    ; int map = object("map<string, map<int, int>>")
endFunction

; TODO: Invalidate non existant aliases
;/
    Goal is to solve this problem:
    Parameters: [
        [0]: [RPB_CellDoor < (0005E924)>] [FormID: 387364] [BaseID: 387357] [Name: Door] 
        [1]: [Actor < (0010C06D)>] [FormID: 1097837] [BaseID: 1097832] [Name: Imperial Soldier] 
        [2]: [Actor < (00000014)>] [FormID: 20] [BaseID: 7] [Name: Prisoner] 
        [3]: [Actor < (0010C06D)>] [FormID: 1097837] [BaseID: 1097832] [Name: Imperial Soldier] 
        [4]: [ObjectReference < (3401DDE1)>] [FormID: 872537569] [BaseID: 59] 
        [5]: [RPB_JailCell < (34003883)>] [FormID: 872429699] [BaseID: 59] [Name: Jail Cell] 
    ]

    Here [3] is a Ref Type ExteriorCell, which does not exist and is converted to 0 (false),
    Since there's a ReferenceAlias with ID 0 ([1] in this example), it gets set to that and finds the Reference bound to it,
    hence the duplication of [1] and [3].
/;
function InvalidateSceneAliases(string asScene, string asRefType)
    ; Rough implementation:
    ; Validate and remove invalid RefAlias IDs
    int obj      = FastMap_GetObject(__sceneConfig, asScene) ; FastMap<string>
    int refTypes = FastMap_Keys(obj) ; FastArray<string>

    int keyIndex = 0
    while (keyIndex < FastMap_Size(refTypes))
        string refTypeName = FastArray_GetString(refTypes, keyIndex)
        int refTypeIds = FastMap_GetObject(obj, refTypeName) ; FastArray<int>

        int valueIndex = 0
        while (valueIndex < FastArray_Size(refTypeIds))
            int id = FastArray_GetInt(refTypeIds, valueIndex)
            Alias a = self.GetAliasByID(id)
            if (!a || (refTypeName != a.GetName()))
                Debug("SceneManager::GetSceneRefTypesConfig", "Validating and removing ["+ valueIndex +"] (id: "+ id +") (Ref Type: "+ refTypeName +"), alias does not exist!")
                FastArray_Remove(refTypeIds, valueIndex)
            endif
            valueIndex += 1
        endWhile

        keyIndex += 1
    endWhile
endFunction

;/
    Removes this reference type from the Scene.

    string  @asScene: The name of the Scene.
    string  @asRefType: The reference type to remove.
/;
function RemoveSceneRefType(string asScene, string asRefType)
    int sceneRefTypeMap = self.GetSceneRefTypesConfig(asScene)

    if (FastMap_HasKey(sceneRefTypeMap, asRefType))
        FastMap_RemoveKey(sceneRefTypeMap, asRefType)
    endif
endFunction

;/
    string  @asScene: The name of the Scene.
    returns (FastMap<string>): The Scene reference config object of a specific Scene.
/;
int function GetSceneRefTypesConfig(string asScene)
    return FastMap_GetObject(__sceneConfig, asScene) ; FastMap<string>
endFunction

;/
    string @asScene: The name of the Scene.
    returns (FastArray<int>): The Scene reference config object of a specific Scene and reference type.
/;
int function GetSceneRefsOfTypeObject(string asScene, string asRefType)
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene)
    return FastMap_GetObject(specifiedSceneConfig, asRefType) ; FastArray<int>
endFunction

;/
    Retrieves the Scene's aliases of a specific reference type.

    string  @asScene: The name of the Scene.
    string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)
    bool?   @abOnlyIncludeAliasesInUse: Only include aliases that are currently in use.

    returns (Alias[]): The Scene's Aliases of a specific reference type.
/;
Alias[] function GetSceneAliasesOfType(string asScene, string asRefType, bool abOnlyIncludeAliasesInUse = false)
    int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; FastArray<int>
    int arrLen      = FastArray_Size(refsOfType)
    
    Alias[] aliasArr = Utility.CreateAliasArray(arrLen)
 
    int i = 0
    while (i < arrLen)
        int id = FastArray_GetInt(refsOfType, i)
        Alias currentAlias = self.GetAliasByID(id)
        if (!abOnlyIncludeAliasesInUse || (currentAlias as ReferenceAlias).GetReference() != none)
            aliasArr[i] = currentAlias
        endif
        i += 1
    endWhile

    return aliasArr
endFunction

;/
    Retrieves the Scene's nth Alias of a specific type.

    string  @asScene: The name of the Scene.
    string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)

    returns (ReferenceAlias): The Scene's Alias of a specific reference type.
/;
ReferenceAlias function GetSceneNthAliasOfType(string asScene, string asRefType, int aiIndex = 0)
    int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; FastArray<int>
    int id = FastArray_GetInt(refsOfType, aiIndex)

    return self.GetAliasByID(id) as ReferenceAlias
endFunction

;/
    string  @asScene: The scene to retrieve the reference types from.

    returns (string[]): All reference types used in the Scene.
/;
string[] function GetSceneRefTypes(string asScene)
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene)
    return FastMap_KeysAsPapyrusArray(specifiedSceneConfig)
endFunction

;/
    Retrieves all the Scene's aliases.

    string  @asScene: The name of the Scene.
    bool?   @abOnlyIncludeAliasesInUse: Whether to only include aliases that are currently bound.

    returns (Alias[]): All of a Scene's aliases.
/;
Alias[] function GetSceneAliases(string asScene, bool abOnlyIncludeAliasesInUse = false)
    float s = StartBenchmark()
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; FastMap<string>
    int allRefTypeIds        = FastMap_Values(specifiedSceneConfig) ; FastArray<int>

    Alias[] buffer = Utility.CreateAliasArray(128)
    int aliasIndex = 0

    ; I hate this nesting, but I can't extract this due to performance...
    int i = 0
    while (i < FastArray_Size(allRefTypeIds))
        int typeArray = FastArray_GetObject(allRefTypeIds, i)
        if (typeArray)
            int k = 0
            while (k < FastArray_Size(typeArray))
                int id = FastArray_GetInt(typeArray, k)
                ReferenceAlias refAlias = self.GetAliasByID(id) as ReferenceAlias 
                if (!abOnlyIncludeAliasesInUse || refAlias.GetReference() != none)
                    if (aliasIndex < buffer.Length) ; prevent buffer overflow
                        buffer[aliasIndex] = refAlias
                        aliasIndex += 1
                        Debug("SceneMNager::GetSceneAliases", "id: " + id + ", refAlias: " + refAlias.GetName())
                    endif
                endif
                k += 1
            endWhile
        endif
        i += 1
    endWhile

    if (aliasIndex <= 0)
        RPB_Utility.LogError("Could not retrieve any scene aliases for Scene " + asScene + " (no aliases found!)", "SceneManager::GetSceneAliases")
        return none
    endif

    Alias[] mergedAliases = Utility.CreateAliasArray(aliasIndex)

    i = 0
    while (i < mergedAliases.Length)
        mergedAliases[i] = buffer[i]
        i += 1
    endWhile

    EndBenchmark(s, "SceneManager::GetSceneAliases("+ asScene +")")
    return mergedAliases
endFunction

;/
    Retrieves all of a Scene's references that are currently bound to a ReferenceAlias.

    string  @asScene: The name of the Scene.

    returns (Form[]): All of a Scene's references.
/;
Form[] function GetSceneReferences(string asScene)
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; FastMap<string, int[]>

    int allRefTypeIds   = FastMap_Values(specifiedSceneConfig) ; FastArray<int>
    int mergedTypes     = FastArray("<Form>")

    int i = 0
    while (i < FastArray_Size(allRefTypeIds))
        int typeArray = FastArray_GetObject(allRefTypeIds, i) ; FastArray<int>
        if (typeArray)
            int k = 0
            while (k < FastArray_Size(typeArray))
                int id = FastArray_GetInt(typeArray, k)
                ReferenceAlias r = self.GetAliasByID(id) as ReferenceAlias
                ObjectReference ref = r.GetReference()
                if (ref != none)
                    FastArray_AddForm(mergedTypes, ref)
                endif
                k += 1
            endWhile
        endif
        i += 1
    endWhile

    return FastArray_ToFormArray(mergedTypes)
endFunction

;/
    Retrieves the Scene references of a specific type that are currently bound to a ReferenceAlias.

    string  @asScene: The name of the Scene.
    string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)

    returns (Form[]): The Scene's references of a specific reference type.
/;
Form[] function GetSceneReferencesOfType(string asScene, string asRefType)
    int refsOfType = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; FastArray<int>
    int boundReferences = FastArray("<Form>")
 
    int i = 0
    while (i < FastArray_Size(refsOfType))
        int id = FastArray_GetInt(refsOfType, i)
        ObjectReference ref = (self.GetAliasByID(id) as ReferenceAlias).GetReference()

        if (ref != none)
            FastArray_AddForm(boundReferences, ref)
        endif

        i += 1
    endWhile
    
    return FastArray_ToFormArray(boundReferences)
endFunction

;/
    Retrieves the Scene's nth reference of a specific type that is currently bound to a ReferenceAlias.

    string  @asScene: The name of the Scene.
    string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)
    int?    @aiIndex: The index of the reference to retrieve.

    returns (ObjectReference): The Scene's reference of a specific reference type.
/;
ObjectReference function GetSceneNthReferenceOfType(string asScene, string asRefType, int aiIndex = 0)
    int refsOfType = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; FastArray<int>

    int id = FastArray_GetInt(refsOfType, aiIndex)
    ObjectReference ref = (self.GetAliasByID(id) as ReferenceAlias).GetReference()

    if (ref != none)
        return ref
    endif

    return none
endFunction

;/
    Handles the Scenes' configuration related to the ReferenceAlias they have,
    where each one starts (index) and how many there are for every Scene.
/;
function CreateSceneConfig()
    float sceneConfigBench = StartBenchmark()

    ; Arrest Start
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_01, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_01, "Escortee", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_02, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_02, "Escortee", 2, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_03, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_03, "Escortee", 2, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_04, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_04, "Escortee", 2, 0)

    ; Arrest Start - Prison
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_PRISON_01, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_PRISON_01, "Escortee", 2, 0)

    ; Eluding Arrest
    self.CreateSceneRefTypeConfig(SCENE_ELUDING_ARREST_01, "Guard",  1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ELUDING_ARREST_01, "Eluder", 1, 0)

    ; Pay Bounty
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY, "Escortee", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE, "Escort",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE, "Escortee",  1, 0)

    ; Restrain Prisoner
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_01, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_01, "Prisoner", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_02, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_02, "Prisoner", 1, 0)

    ; Escort to Jail
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Escort",   3, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Escortee", 10, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Player_EscortLocation", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Guard_EscortLocation",  1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_02, "Escort",   3, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_02, "Escortee", 1, 0)

    ; Escort to Cell
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Escortee", 3, 0) ; refactor to Prisoner
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "CellDoor", 1, 0)
    ; self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "ExteriorCell",  1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Player_EscortLocation", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Guard_EscortLocation",  1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_04, "Escort",   1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_04, "Escortee", 3, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_04, "CellDoor", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_04, "Player_EscortLocation", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_04, "Guard_EscortLocation",  1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_02, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_02, "Prisoner", 1, 0)

    ; Escort from Cell
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_FROM_CELL, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_FROM_CELL, "Prisoner", 1, 0)

    ; Frisking
    self.CreateSceneRefTypeConfig(SCENE_FRISKING, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_FRISKING, "Prisoner", 1, 0)

    ; Stripping
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_01, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_01, "Prisoner", 3, 0)
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_02, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_02, "Prisoner", 3, 0)

    ; Forced Stripping
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_01, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_01, "Prisoner", 1, 0)
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_02, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_02, "Prisoner", 1, 0)

    ; Give Clothing
    self.CreateSceneRefTypeConfig(SCENE_GIVE_CLOTHING, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_GIVE_CLOTHING, "Prisoner", 1, 0)

    ; No Clothing
    self.CreateSceneRefTypeConfig(SCENE_NO_CLOTHING, "Guard",    1, 0)
    self.CreateSceneRefTypeConfig(SCENE_NO_CLOTHING, "Prisoner", 4, 0)

    ; Surrender
    self.CreateSceneRefTypeConfig(SCENE_SURRENDER_01, "Surrenderer",       1, 0)
    self.CreateSceneRefTypeConfig(SCENE_SURRENDER_01, "SurrendererCaptor", 6, 0)

    EndBenchmark(sceneConfigBench, "SceneManager::CreateSceneConfig")
endFunction

;/
    Retrieves a Scene by its configured name.

    string  @asSceneName: The name of the Scene

    returns (Scene): The actual Scene object for this scene.
/;
Scene function GetScene(string asSceneName)
    if (!self.SceneExists(asSceneName))
        Error("SceneManager::GetScene", "Scene " + asSceneName + " does not exist!")
        return none
    endif

    return GetFormFromMod(self.GetSceneFormID(asSceneName)) as Scene
endFunction

; ==========================================================
;                      Scene Event Types
; ==========================================================

; Type of Event during OnScenePlaying
int property PHASE_START    = 0 autoreadonly
int property PHASE_END      = 1 autoreadonly

; ==========================================================
;                        Scene Events
; ==========================================================

string property EVENT_RESTRAIN_BEGIN        = "RestrainBegin" autoreadonly
string property EVENT_RESTRAINING           = "Restraining" autoreadonly
string property EVENT_RESTRAIN_END          = "RestrainEnd" autoreadonly
string property EVENT_ARREST_BEGIN          = "ArrestBegin" autoreadonly
string property EVENT_ARRESTING             = "Arresting" autoreadonly
string property EVENT_ARREST_END            = "ArrestEnd" autoreadonly
string property EVENT_SURRENDER_BEGIN       = "SurrenderBegin" autoreadonly
string property EVENT_SURRENDERING          = "Surrendering" autoreadonly
string property EVENT_SURRENDER_END         = "SurrenderEnd" autoreadonly
string property EVENT_ESCORT_BEGIN          = "EscortBegin" autoreadonly
string property EVENT_ESCORTING             = "Escorting" autoreadonly
string property EVENT_ESCORT_END            = "EscortEnd" autoreadonly
string property EVENT_FRISK_BEGIN           = "FriskBegin" autoreadonly
string property EVENT_FRISKING              = "Frisking" autoreadonly
string property EVENT_FRISK_END             = "FriskEnd" autoreadonly
string property EVENT_STRIP_BEGIN           = "StripBegin" autoreadonly
string property EVENT_STRIPPING             = "Stripping" autoreadonly
string property EVENT_STRIP_END             = "StripEnd" autoreadonly
string property EVENT_CLOTHING_BEGIN        = "ClothingBegin" autoreadonly
string property EVENT_CLOTHING              = "Clothing" autoreadonly
string property EVENT_CLOTHING_END          = "ClothingEnd" autoreadonly
string property EVENT_FORCED_STRIP_BEGIN    = "ForcedStripBegin" autoreadonly
string property EVENT_FORCED_STRIPPING      = "ForcedStripping" autoreadonly
string property EVENT_FORCED_STRIP_END      = "ForcedStripEnd" autoreadonly
string property EVENT_ELUDE_BEGIN           = "EludeTrigger" autoreadonly
string property EVENT_ARREST_PAYING_BOUNTY  = "ArrestPayBountyBegin" autoreadonly
string property EVENT_ARREST_PAY_BOUNTY_END = "ArrestPayBountyEnd" autoreadonly

; ==========================================================
;                       Scene Categories
; ==========================================================

string property CATEGORY_ARREST_START       = "RPB_ArrestStart" autoreadonly
string property CATEGORY_SURRENDER          = "RPB_Surrender" autoreadonly
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
string property SCENE_SURRENDER_01                          = "RPB_Surrender01" autoreadonly
string property SCENE_GENERIC_ESCORT                        = "RPB_GenericEscort" autoreadonly
string property SCENE_ESCORT_FROM_CELL                      = "RPB_EscortFromCell" autoreadonly
string property SCENE_ESCORT_TO_JAIL_01                     = "RPB_EscortToJail01" autoreadonly
string property SCENE_ESCORT_TO_JAIL_02                     = "RPB_EscortToJail02" autoreadonly
string property SCENE_ESCORT_TO_CELL_01                     = "RPB_EscortToCell01" autoreadonly
string property SCENE_ESCORT_TO_CELL_04                     = "RPB_EscortToCell04" autoreadonly

; The escort to the cell in use: 01, or its CK-free copy 04 while the test switch is on (test 151)
string function EscortToCellSceneName()
    if (RPB_Utility.IsEscortToCell04ForTest())
        return SCENE_ESCORT_TO_CELL_04
    endif
    return SCENE_ESCORT_TO_CELL_01
endFunction
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
;                     Scene Control Queue
; ==========================================================

bool __isScenePlaying
string currentScene
string __lastEndedScene ; the last Scene whose end I received, see PlayQueued()

; Nothing playing through the queue and nothing waiting in it. My own state: the engine can still report a Scene as
; playing after it sent its end (see PlayQueued()).
bool function IsIdle()
    return !__isScenePlaying && JArray.count(__queuedScenes) == 0
endFunction

; The Scene I'm playing through the queue, "" when none
; The last phase @asScene started (1-based, as OnScenePlaying numbers them), 0 if it isn't the Scene that last started one
string __phaseScene
int __phase
int function GetCurrentPhase(string asScene)
    if (asScene != __phaseScene)
        return 0
    endif
    return __phase
endFunction

string function GetCurrentScene()
    if (__isScenePlaying || self.__IsCurrentSceneRunning())
        return currentScene
    endif
    return ""
endFunction

; The engine's word for the Scene I last started (the flag alone once said "nothing" while an escort Scene still ran)
bool function __IsCurrentSceneRunning()
    if (currentScene == "")
        return false
    endif
    Scene sceneObject = self.GetScene(currentScene)
    return sceneObject && sceneObject.IsPlaying()
endFunction

bool function HasQueuedScenes()
    Debug("Scene DEBUG: ["+ currentScene +"] SceneManager::HasQueuedScenes", "HasQueuedScenes: " + (JArray.count(__queuedScenes) > 0) + " ("+ JArray.count(__queuedScenes) +" scenes)")
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

    if (!__queuedSceneAliases)
        __queuedSceneAliases = JArray.object()
        JValue.retain(__queuedSceneAliases, "RPB_SceneManager")
    endif

    Debug("Scene DEBUG: ["+ currentScene +"] SceneManager::PushScene", "Pushing Scene: " + asSceneName)
    JArray.addStr(__queuedScenes, asSceneName)

    ; This Scene's own aliases travel with it, so a later queue call can't overwrite them (they used to live in one
    ; shared map, bound on the spot, even into a Scene still playing for someone else)
    JArray.addObj(__queuedSceneAliases, JValue.shallowCopy(__queuedAliases))
    Object_Clear(__queuedAliases)
endFunction

; Takes the oldest queued Scene's aliases out of the queue (retained: the caller releases it), 0 if there are none
int function __PopSceneAliases()
    if (JArray.count(__queuedSceneAliases) == 0)
        return 0
    endif

    int aliases = JArray.getObj(__queuedSceneAliases, 0)
    JValue.retain(aliases, "RPB_SceneManager_Popped")
    JArray.eraseIndex(__queuedSceneAliases, 0)
    return aliases
endFunction

; Empties the Scene queue together with each entry's aliases
function __ClearSceneQueue()
    if (__queuedScenes)
        JValue.release(__queuedScenes)
    endif
    __queuedScenes = JArray.object()
    JValue.retain(__queuedScenes, "RPB_SceneManager")

    if (__queuedSceneAliases)
        JValue.release(__queuedSceneAliases)
    endif
    __queuedSceneAliases = JArray.object()
    JValue.retain(__queuedSceneAliases, "RPB_SceneManager")
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
    Debug("Scene DEBUG: ["+ currentScene +"] SceneManager::PopScene", "Popping Scene: " + sceneName)
    return sceneName
endFunction

;/
    Queues a Scene, or plays it if the queue is empty.

    string  @asSceneName: The name of the Scene to queue up or play.
/;
function QueueOrPlay(string asSceneName)
    ; __isScenePlaying can drift from reality if an earlier Scene's flow was interrupted in a way that never reached
    ; OnSceneEnd (a real, recurring failure mode across this codebase's own history - stalled escorts, guard deaths,
    ; multi-guard dialogue races, each fixed on its own, but any one of them, before its fix landed, could leave this
    ; flag stuck true forever - it only ever clears in OnSceneEnd or ForceResetSceneState()). Left unchecked, every
    ; future arrest just silently queues behind a Scene that isn't actually running anymore, with no error and no
    ; log - confirmed as a real, reproduced cause of confrontation Scenes intermittently never starting at all.
    ; Self-heal here instead of trusting the tracked flag blindly.
    if (__isScenePlaying && currentScene != "" && !self.GetScene(currentScene).IsPlaying())
        RPB_Utility.LogWarn("SceneManager: __isScenePlaying said '" + currentScene + "' was still playing, but it wasn't - self-healing before queuing " + asSceneName, "SceneManager::QueueOrPlay")
        __isScenePlaying = false
        self.__ClearSceneQueue() ; also clear whatever stale entries piled up behind the desynced flag
    endif

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

    int nextAliases = self.__PopSceneAliases()
    string nextScene = self.PopScene()

    if (nextScene != "")
        self.RestoreAliases(nextAliases)

        ; An escort for an actor who is gone (deleted, disabled, dead) never ends, and since every Scene shares these
        ; aliases it keeps driving whoever the next ones bind (a test's teardown deleted a prisoner mid prison flow: its
        ; queued escort to the cell started anyway, and every confrontation after it stalled). Not started at all.
        string queuedType = self.GetSceneType(nextScene)
        if (queuedType == CATEGORY_ESCORT_TO_JAIL || queuedType == CATEGORY_ESCORT_TO_CELL)
            Actor queuedEscortee = self.GetSceneNthReferenceOfType(nextScene, "Escortee") as Actor
            if (!queuedEscortee || queuedEscortee.IsDeleted() || queuedEscortee.IsDisabled() || queuedEscortee.IsDead())
                Info("SceneManager: " + nextScene + " dropped: its escortee " + queuedEscortee + " is gone")
                __isScenePlaying = false
                if (nextAliases)
                    JValue.release(nextAliases)
                endif
                self.PlayQueued()
                return
            endif
        endif
        Debug("Scene DEBUG: ["+ currentScene +"] SceneManager::PlayQueued", "Playing Scene: " + nextScene)
        Scene sceneObject = self.GetScene(nextScene)

        ; The engine can still report a Scene as playing after it sent me its end (seen with the confrontation Scene when
        ; its escortee was already imprisoned and unloaded: still playing 38s later). Start() on it is then silently
        ; ignored, and the arrest waiting on it only recovered ~9s later through its own retry (which stops the Scene and
        ; tries again). I do the same right away, and only for the Scene whose end I already received, so a Scene still
        ; genuinely running is never touched.
        if (nextScene == __lastEndedScene && sceneObject.IsPlaying())
            Debug("SceneManager::PlayQueued", nextScene + " still counts as playing after its end, stopping that instance before starting it again")
            sceneObject.Stop()
            float stopWaitStart = Utility.GetCurrentRealTime()
            while (sceneObject.IsPlaying() && (Utility.GetCurrentRealTime() - stopWaitStart) < 1.0)
                Utility.Wait(0.1)
            endWhile
        endif

        __lastStartedScene = ""
        string nextSceneType = self.GetSceneType(nextScene)
        bool isEscortScene = nextSceneType == CATEGORY_ESCORT_TO_JAIL || nextSceneType == CATEGORY_ESCORT_TO_CELL
        if (!(nextSceneType == CATEGORY_ESCORT_TO_JAIL && RPB_Utility.IsEscortStartForcedToFail())) ; test-only: an escort to jail that never starts
            sceneObject.Start() ; Play the Scene
        endif
        currentScene = nextScene

        ; The engine can refuse a Start() silently (seen with an escort Scene whose arrestee was still in combat: no start,
        ; ever), which used to leave the arrest stuck and this queue waiting for an end that never comes. A Scene that
        ; starts is playing within a frame or two; give it a few seconds, then treat it as failed.
        float startWaitStart = Utility.GetCurrentRealTime()
        while (!sceneObject.IsPlaying() && __lastStartedScene != nextScene && (Utility.GetCurrentRealTime() - startWaitStart) < 3.0)
            Utility.Wait(0.1)
        endWhile

        ; A Scene refused because its actors are still fighting isn't a failure yet: a large fight can take minutes, and
        ; teleporting past it would skip a Scene that can still play. I wait while either actor is in combat, up to a cap,
        ; then start it again (a refused Start() is never retried by the engine) and give it the usual few seconds.
        ; Escort Scenes only: the confrontation handles a fight itself (Arrestee.AwaitConfrontationScene goes pending).
        if (isEscortScene && !sceneObject.IsPlaying() && __lastStartedScene != nextScene && currentScene == nextScene)
            Actor escort    = self.GetSceneNthReferenceOfType(nextScene, "Escort") as Actor
            Actor escortee  = self.GetSceneNthReferenceOfType(nextScene, "Escortee") as Actor
            float combatWaitStart = Utility.GetCurrentRealTime()
            bool waitedForCombat = false
            bool uncuffedInFight = false
            while (!uncuffedInFight && !sceneObject.IsPlaying() && __lastStartedScene != nextScene && currentScene == nextScene && ((escort && escort.IsInCombat()) || (escortee && escortee.IsInCombat())) && (Utility.GetCurrentRealTime() - combatWaitStart) < SCENE_START_COMBAT_CAP_SECONDS)
                if (!waitedForCombat)
                    waitedForCombat = true
                    ; An arrestee never cuffed: the fight stopped the confrontation (the engine ends it when combat starts)
                    ; before its "Handcuff" step. Nothing was done to them yet, so they go free rather than be escorted
                    ; uncuffed once the fight is over. Escort to jail only: at the prison a stripped prisoner is uncuffed on
                    ; purpose.
                    if (escortee && nextSceneType == CATEGORY_ESCORT_TO_JAIL && RPB_API.GetArrest().Arrestees.AtKey(escortee) && !RPB_Utility.IsCuffed(escortee))
                        uncuffedInFight = true
                    else
                        Info("SceneManager: " + nextScene + " can't start while " + escort + " / " + escortee + " are in combat, waiting for the fight to end")
                        if (escortee && escortee == Game.GetPlayer())
                            RPB_Utility.HoldPlayerCuffed() ; cuffed and waiting: free to take cover, not locked in place
                        endif
                    endif
                endif
                if (!uncuffedInFight)
                    Utility.Wait(1.0)
                endif
            endWhile

            if (uncuffedInFight)
                Info("SceneManager: " + nextScene + " dropped: " + escortee + " was never cuffed and a fight broke out, the arrest is cancelled")
                ; The queue's own state first, as for a Scene that never started, so the cancel below only drops this actor's
                ; queued Scenes instead of ending "the current one" from inside this call
                __isScenePlaying = false
                currentScene = ""
                if (nextAliases)
                    JValue.release(nextAliases)
                endif
                RPB_Recovery.CancelArrest(escortee, "a fight broke out before the cuffs")
                self.PlayQueued()
                return
            endif

            bool fightOver = !((escort && escort.IsInCombat()) || (escortee && escortee.IsInCombat()))
            if (waitedForCombat && fightOver && currentScene == nextScene)
                ; The player back under AI before the Scene starts: started while they weren't AI-driven, its package never
                ; applied to them and they stood still while the guard walked off
                if (escortee && escortee == Game.GetPlayer())
                    RetainAI(true)
                    escortee.EvaluatePackage()
                endif
                sceneObject.Start()
                startWaitStart = Utility.GetCurrentRealTime()
                while (!sceneObject.IsPlaying() && __lastStartedScene != nextScene && currentScene == nextScene && (Utility.GetCurrentRealTime() - startWaitStart) < 3.0)
                    Utility.Wait(0.1)
                endWhile
                Info("SceneManager: " + nextScene + " after waiting " + ((Utility.GetCurrentRealTime() - combatWaitStart) as int) + "s for the fight: started " + (sceneObject.IsPlaying() || __lastStartedScene == nextScene))
            elseif (waitedForCombat)
                Info("SceneManager: " + nextScene + " gave up after " + ((Utility.GetCurrentRealTime() - combatWaitStart) as int) + "s, the fight is still on")
            endif
        endif

        if (!sceneObject.IsPlaying() && __lastStartedScene != nextScene && currentScene == nextScene)
            DebugWarn("SceneManager::PlayQueued", nextScene + " never started, moving on")
            EventManager.OnSceneStartFailed(nextScene)
            __isScenePlaying = false
            currentScene = ""
            if (nextAliases)
                JValue.release(nextAliases)
            endif
            self.PlayQueued()
            return
        endif
    endif

    if (nextAliases)
        JValue.release(nextAliases)
    endif
endFunction

bool __endingEarly

; Ends the Scene I'm playing if @akActor is one of its references (RPB_Recovery). True if one was ended.
; Its end events are not run: a reset or a test teardown must not trigger what the Scene's end would (an escort's end strips
; the prisoner at the jail - that once overwrote the belongings manifest of an actor being reset).
bool function EndSceneWithActor(Actor akActor, string asReason)
    if (!akActor)
        return false
    endif

    ; Its queued Scenes first: ending the current one starts the next in line, which could be one of theirs (a test's
    ; teardown once started the escort of an actor it was deleting)
    int removed = self.RemoveQueuedScenesWithActor(akActor)

    ; Current by my flag or by the engine: one just started may not report IsPlaying() yet
    if (currentScene == "" || !(__isScenePlaying || self.__IsCurrentSceneRunning()))
        return removed > 0
    endif

    string sceneName = currentScene
    Form[] refs = self.GetSceneReferences(sceneName)
    if (!refs || refs.Find(akActor) < 0)
        return removed > 0
    endif

    self.EndSceneEarly(sceneName, asReason, abRunEndEvents = false)
    return true
endFunction

; Whether a queued (not yet started) Scene has @akActor among its aliases: an escort waiting its turn, not a stalled one
bool function HasQueuedSceneWithActor(Actor akActor)
    int i = JArray.count(__queuedSceneAliases) - 1
    while (i >= 0)
        int aliases = JArray.getObj(__queuedSceneAliases, i)
        if (aliases && JArray.findForm(FastIntMap_Values(aliases), akActor) >= 0)
            return true
        endif
        i -= 1
    endWhile
    return false
endFunction

; Drops every queued (not yet started) Scene that has @akActor among its aliases. Returns how many.
int function RemoveQueuedScenesWithActor(Actor akActor)
    int removed = 0
    int i = JArray.count(__queuedSceneAliases) - 1
    while (i >= 0)
        int aliases = JArray.getObj(__queuedSceneAliases, i)
        if (aliases && JArray.findForm(FastIntMap_Values(aliases), akActor) >= 0)
            Debug("SceneManager::RemoveQueuedScenesWithActor", "Dropping queued " + JArray.getStr(__queuedScenes, i) + ": " + akActor + " is leaving the Scenes")
            JArray.eraseIndex(__queuedScenes, i)
            JArray.eraseIndex(__queuedSceneAliases, i)
            removed += 1
        endif
        i -= 1
    endWhile
    return removed
endFunction
string __lastStartedScene ; the last Scene whose start I received, see PlayQueued()

; How long PlayQueued() keeps re-sending Start() to a Scene refused because its actors are in combat
float property SCENE_START_COMBAT_CAP_SECONDS = 120.0 autoreadonly

;/
    Ends @asScene now, through the same path as its natural end (OnSceneEnd: its end event, the next queued Scene,
    the flags and globals), for a Scene whose remaining phases no longer matter. Only if it's the Scene I'm playing
    and the engine still has it playing.
/;
function EndSceneEarly(string asScene, string asReason, bool abRunEndEvents = true)
    if (__endingEarly || asScene != currentScene)
        return
    endif

    Scene sceneObject = self.GetScene(asScene)
    if (!sceneObject)
        return
    endif

    bool enginePlaying = sceneObject.IsPlaying()
    if (!enginePlaying && !__isScenePlaying)
        return ; neither I nor the engine has it running: nothing to end
    endif

    __endingEarly = true
    Debug("SceneManager::EndSceneEarly", "Ending " + asScene + " early: " + asReason)
    ; One the engine doesn't report yet (just started) is only finished on my side; Stop() is for a running one
    if (enginePlaying)
        sceneObject.Stop()
        float stopWaitStart = Utility.GetCurrentRealTime()
        while (sceneObject.IsPlaying() && (Utility.GetCurrentRealTime() - stopWaitStart) < 1.0)
            Utility.Wait(0.1)
        endWhile
    endif

    ; A stopped Scene never reaches the phase that sends its end, so this is its only end. Without its end events when the
    ; caller says so: only the queue moves on.
    if (abRunEndEvents)
        self.OnSceneEnd(asScene, sceneObject)
    else
        self.__FinishScene(asScene)
    endif
    __endingEarly = false
endFunction

;/
    Last-resort safety valve for a Scene that stalled and was never confirmed to actually be playing (no OnSceneStart/
    OnScenePlaying/OnSceneEnd ever arrived for it). __isScenePlaying only ever clears in OnSceneEnd, so a Start() that
    silently failed can wedge it true forever, quietly blocking every future QueueOrPlay call mod-wide. I only call this
    after a caller (see RPB_Arrestee.AwaitConfrontationScene) has already exhausted its own retry attempts - never in the
    middle of a retry, since this also drops anything still queued behind the stalled Scene, including Scenes that have
    nothing to do with the stalled one.
/;
function ForceResetSceneState()
    Error("SceneManager::ForceResetSceneState", "Force-resetting scene state (was: '" + currentScene + "', playing: " + __isScenePlaying + ", " + JArray.count(__queuedScenes) + " queued) after a stalled Scene exhausted its retries")
    __isScenePlaying = false
    currentScene = ""
    self.__ClearSceneQueue()
endFunction

;/
    Stops every RPB Scene the engine still plays and forgets the queue: for tests' teardown and recovery, when a Scene may
    be left driving the shared aliases for an actor who is gone (one was, and every later confrontation stalled behind it).
    The queue goes first, so a stopped Scene's end can't start the next one.
/;
function StopAllScenes(string asReason)
    __isScenePlaying = false
    currentScene = ""
    self.__ClearSceneQueue()

    string[] sceneNames = FastMap_KeysAsPapyrusArray(__sceneToCategory)
    int stopped = 0
    int i = 0
    while (i < sceneNames.Length)
        Scene sceneObject = self.GetScene(sceneNames[i])
        if (sceneObject && sceneObject.IsPlaying())
            sceneObject.Stop()
            stopped += 1
        endif
        i += 1
    endWhile

    __isScenePlaying = false
    currentScene = ""
    self.ResetGlobals()
    Info("SceneManager: stopped " + stopped + " Scene(s) still playing (" + asReason + ")")
endFunction

; ==========================================================
;                       Scene Aliases
; ==========================================================

ReferenceAlias function GetRefAlias(string aliasGroup, int index = 0)
    if (aliasGroup == "Surrenderer" || aliasGroup == "SurrendererCaptor")
        string refAliasGroup = aliasGroup + "_" + index
        return self.GetAliasByName(refAliasGroup) as ReferenceAlias
    endif

    string refAliasGroup = string_if (index == 0, aliasGroup, aliasGroup + index)
    return self.GetAliasByName(refAliasGroup) as ReferenceAlias
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

;/
    Sets a package lock on the specified Actor.
    This is used for specific escort scenes where the behavior is overridden by the vanilla AI,
    resulting in weirdness sometimes when escorting an Arrestee to the jail, for example.

    After both the Arrestee and the Escort reach the jail, the Arrestee will have its behavior bound by the "Cell Package",
    whereas the Escort will not, so they will revert to their default AI behavior and try to exit the Scene, which then makes it so
    that the Arrestee will follow (should not happen).

    The point of this package lock is to make sure that the Escort does not leave the Scene until it is unset 
    (works exactly the same as a Cell Package, they use the same package under the hood).

    This makes it possible for the Escort to lead a Scene without any weird behaviors until the package lock is unset.
    The package must be unset, otherwise the Escort will be stuck in place forever.

    Actor   @akActor: The actor to set the package lock on.
/;
function SetPackageLockOnActor(Actor akActor)
    if (RPB_Utility.IsPackageLockDisabled())
        Debug("SceneManager::SetPackageLockOnActor", "Package lock disabled (test 140), not binding " + akActor)
        return
    endif
    string packageAliasGroup = "PKG_Lock_0"
    int packageIndex = 1
    ReferenceAlias packageLock = self.GetRefAlias(packageAliasGroup, packageIndex)

    while (packageLock.GetReference() != none && packageIndex <= 5)
        Debug("SceneManager::SetPackageLockOnActor", "Shouldn't even enter here")
        packageLock = self.GetRefAlias(packageAliasGroup, packageIndex)
        packageIndex += 1
    endWhile

    if (packageLock.GetReference()) ; Package already in use
        ; Error
        RPB_Utility.LogWarn("There was a problem assigning a package lock to the Actor " + akActor + "!", "SceneManager::SetPackageLockOnActor")
        return
    endif

    ; Debug("SceneManager::SetPackageLockOnActor", "Alias: " + packageLock + ", ID: " + packageLock.GetID())

    BindAliasTo(packageLock, akActor)
    RPB_StorageVars.SetIntOnReference("Package Lock", akActor, packageLock.GetID())
    RPB_Utility.ProbeGuardAfterBurst(akActor, "package lock bound")
    RPB_Utility.LogInfo("Bound package lock to Actor " + akActor + " successfully!", "SceneManager::SetPackageLockOnActor")
endFunction

;/
    Unsets the package lock on the specified Actor if they have one.
    Actor   @akActor: The actor to unset the package lock from.
/;
function UnsetPackageLockOnActor(Actor akActor)
    int packageId = RPB_StorageVars.GetIntOnReference("Package Lock", akActor)
    ReferenceAlias packageLock = self.GetAliasByID(packageId) as ReferenceAlias

    if (packageId && !packageLock)
        RPB_Utility.LogError("There was an error unsetting the package lock for Actor " + akActor + ", the package does not exist!", "SceneManager::UnsetPackageLockOnActor")
        return
    endif

    UnbindAlias(packageLock)
    RPB_StorageVars.DeleteVariableOnReference("Package Lock", akActor)
    RPB_Utility.LogInfo("Unbound package lock from Actor " + akActor + " successfully!", "SceneManager::UnsetPackageLockOnActor")
    ; Guards froze around this moment (every freeze so far): a probe tells when one does
    RPB_Utility.ProbeGuardAfterBurst(akActor, "package lock unbound")
endFunction


;/
    Binds @akActor to a free PendingHold_0N alias (N = 1..3), whose package (RPB_PendingHoldPackage: stay in place, Ignore
    Combat, No Combat Alert) holds a pending arrestee still and out of the fight next to them - script calls alone
    couldn't stop their AI drawing weapons at it. False if no alias is free (or the aliases don't exist yet), in which
    case the script-only hold is all there is.
/;
bool function SetPendingHoldOnActor(Actor akActor)
    if (!akActor)
        return false
    endif

    ; The package is needed: without it the held NPC drew her weapon in 4 of 5 runs (test 130). One actor per alias
    ; (Skyrim has no collection aliases), so every PendingHold_NN the plugin has is used: PendingHold_01, _02 and so on,
    ; up to the first number missing. More holds at once = more aliases in the CK, no script change.
    int i = 1
    ReferenceAlias hold = self.__PendingHoldAlias(i)
    while (hold)
        if (!hold.GetReference())
            BindAliasTo(hold, akActor)
            RPB_StorageVars.SetIntOnReference("Pending Hold Alias", akActor, hold.GetID())
            akActor.EvaluatePackage()
            return true
        endif
        i += 1
        hold = self.__PendingHoldAlias(i)
    endWhile

    RPB_Utility.LogWarn("No free PendingHold alias for " + akActor + " (all " + (i - 1) + " in use), holding it by script only", "SceneManager::SetPendingHoldOnActor")
    return false
endFunction

; PendingHold_01 .. PendingHold_09, PendingHold_10 ..
ReferenceAlias function __PendingHoldAlias(int aiNumber)
    if (aiNumber < 10)
        return self.GetAliasByName("PendingHold_0" + aiNumber) as ReferenceAlias
    endif
    return self.GetAliasByName("PendingHold_" + aiNumber) as ReferenceAlias
endFunction

; Unbinds @akActor's PendingHold alias. Only when one is recorded: an unrecorded id reads 0, a Scene alias.
function UnsetPendingHoldOnActor(Actor akActor)
    if (!akActor)
        return
    endif

    int holdId = RPB_StorageVars.GetIntOnReference("Pending Hold Alias", akActor)
    if (!holdId)
        return
    endif

    ReferenceAlias hold = self.GetAliasByID(holdId) as ReferenceAlias
    if (hold && hold.GetReference() == akActor)
        UnbindAlias(hold)
    endif
    RPB_StorageVars.DeleteVariableOnReference("Pending Hold Alias", akActor)
    akActor.EvaluatePackage()
endFunction

function ReleaseAlias(string aliasName, int aliasIndex = 0)
    string finalName = self.GetAliasName(aliasName, aliasIndex , true)
    ReferenceAlias refAlias = self.GetAliasByName(finalName) as ReferenceAlias

    if (refAlias != none)
        BindAliasTo(refAlias, none)
    endif
endFunction

;/
    Unbinds all aliases of a particular Scene.
/;
function UnbindAliases(string asScene)
    Alias[] sceneAliases = self.GetSceneAliases(asScene)

    int i = 0
    while (i < sceneAliases.Length)
        ReferenceAlias refAlias = sceneAliases[i] as ReferenceAlias
        ObjectReference ref = refAlias.GetReference()
        if (ref)
            UnbindAlias(refAlias)
            DebugWithArgs("SceneManager::UnbindAliases", asScene, "Unbound " + refAlias.GetName() + " (id: "+ refAlias.GetID() +") containing reference: " + ref)
        endif
        i += 1
    endWhile
endFunction


;/                                                                                       
    Queues an Alias for binding, optionally directly binding it if @abBindAlias is true.

    ReferenceAlias  @apRefAlias: The Alias to use as binder.
    ObjectReference @akRef: The reference to bind to the Alias.
    bool?           @abBindAlias: Whether to directly bind the reference to the Alias.
/;
function QueueAlias(ReferenceAlias apRefAlias, ObjectReference akRef, bool abBindAlias = true)
    if (!akRef)
        RPB_Utility.LogError("The reference received is none! (cannot queue Alias)", "SceneManager::QueueAlias")
        return
    endif

    ; Only recorded: the Scene's own entry in the queue takes it (PushScene), and it's bound right before that Scene starts
    ; (PlayQueued). Binding here filled the aliases of the same Scene while it was still playing for someone else, so
    ; that Scene's end reported the wrong actors (abBindAlias is kept so existing calls compile; it no longer binds).
    int id = apRefAlias.GetID()
    FastIntMap_SetForm(__queuedAliases, id, akRef)
    Debug("SceneManager::QueueAlias", "Queued " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") with reference: " + FastIntMap_GetForm(__queuedAliases, id))

    Debug("SceneManager::QueueAlias", "__queuedAliases: " + GetContainerList(__queuedAliases))

    RPB_Utility.LogWarn("Alias " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") has not been assigned to any reference!", "SceneManager::QueueAlias", akRef == none)
endFunction

;/
    Binds the received References to a specific type of Alias for the Scene.

    string  @asScene: The scene of which to bind the references to.
    string  @asAliasRefType: The group name of the Aliases (Escort, Escortee, Prisoner...)
    Form[]  @akRefs: The references to bind to their respective alias group.
/;
function BindSceneAliasGroup(string asScene, string asAliasRefType, Form[] akRefs)
    Alias[] aliasesInGroup = self.GetSceneAliasesOfType(asScene, asAliasRefType)

    if (!aliasesInGroup)
        RPB_Utility.LogError("Could not retrieve the Scene's Aliases of type " + asAliasRefType + ", cannot bind!", "SceneManager::BindSceneAliasGroup")
        return
    endif

    int refCount    = akRefs.Length 
    int aliasCount  = aliasesInGroup.Length
    int iterations  = min(refCount, aliasCount) as int

    int i = 0
    while (i < iterations)
        if (akRefs[i])
            self.QueueAlias(aliasesInGroup[i] as ReferenceAlias, akRefs[i] as ObjectReference)
        endif
        i += 1
    endWhile

    RPB_Utility.LogWarn("Received references are more than the available Aliases in the Scene! (Scene: "+ asScene +") (Alias Group: "+ asAliasRefType +") (Received: "+ refCount +", Available Aliases: "+ aliasCount +")", "SceneManager::BindSceneAliasGroup", refCount > aliasCount)
    RPB_Utility.LogInfo("Received less references than the available Aliases in the Scene. (Scene: "+ asScene +") (Alias Group: "+ asAliasRefType +") (Received: "+ refCount +", Available Aliases: "+ aliasCount +")", "SceneManager::BindSceneAliasGroup", aliasCount > refCount)
endFunction

;/
    Binds the received Reference to a specific type of Alias for the Scene.

    string           @asScene: The scene of which to bind the references to.
    string           @asAliasRefType: The group name of the Aliases (Escort, Escortee, Prisoner...)
    ObjectReference  @akRef: The reference to bind to its respective alias group.
/;
function BindSceneAlias(string asScene, string asAliasRefType, ObjectReference akRef)
    Alias[] aliasesInGroup = self.GetSceneAliasesOfType(asScene, asAliasRefType)

    if (!aliasesInGroup)
        RPB_Utility.LogError("Could not retrieve the Scene's Aliases of type " + asAliasRefType + ", cannot bind!", "SceneManager::BindSceneAlias")
        return
    endif

    int iterations  = 1

    int i = 0
    while (i < iterations)
        if (akRef)
            self.QueueAlias(aliasesInGroup[i] as ReferenceAlias, akRef)
        endif
        i += 1
    endWhile
endFunction

;/
    Restores all of the currently queued Aliases.
    This means that every Alias (along with its Reference), will be re-bound.

    Possible ISSUE: Might clear the Aliases of the Scene after the queued scene (3rd Scene in the queue, 
        since the 2nd scene will have the Aliases queued from the first call, but then cleared for the 3rd (which were already queued)), needs to be tested
    Confirmed ISSUE: It is indeed the case, the 3rd scene doesn't get the Aliases (if they were the same as the 2nd scene), and therefore fails to run.
/;
function RestoreAliases(int aiAliases)
    if (!aiAliases)
        return
    endif

    int aliasIds    = FastIntMap_Keys(aiAliases)   ; FastArray<int>
    int aliasRefs   = FastIntMap_Values(aiAliases) ; FastArray<Form>

    Debug("SceneManager::RestoreAliases", "Restoring " + FastArray_Size(aliasIds) + " Aliases (ids: "+ GetContainerList(aliasIds) +") with references: " + GetContainerList(aliasRefs))
    
    int i = 0
    while (i < FastArray_Size(aliasIds))
        int id                 = FastArray_GetInt(aliasIds, i)
        ObjectReference ref    = FastArray_GetForm(aliasRefs, i) as ObjectReference

        ReferenceAlias refAlias = self.GetAliasByID(id) as ReferenceAlias
        Debug("SceneManager::RestoreAliases", "Restored " + refAlias.GetName() + " (id: "+ refAlias.GetID() +") with reference: " + ref)

        RPB_Utility.BindAliasTo(refAlias, ref)
        i += 1
    endWhile
endFunction

; ==========================================================
;                    Scene Event Handlers
; ==========================================================

;/
    Handles customization of a Scene, either Enabling/Disabling Dialogue or a particular Action.
    Scenes that have conditions that depend on Scene_{Dialogue|Action}_CF* Globals.

    These global events set them for a scene that could customize another scene, for example.

    If a control flow global variable must be set on a particular Scene,
    the @asScene parameter can be used to specify the exact scene, instead of relying on just the type.

    string  @asSceneType: The type this Scene falls under.
    string  @asScene: The name of the Scene.
/;
function HandleSceneGlobalControlFlow(string asSceneType, string asScene)
    if (asSceneType == CATEGORY_ARREST_START)
    elseif (asSceneType == CATEGORY_ESCORT_TO_JAIL)
        self.SetGlobal("RPB_Scene_Action_CF01", 1) ; Enables some actions in EscortToCell
    elseif (asSceneType == CATEGORY_ESCORT_TO_CELL)
    elseif (asSceneType == CATEGORY_ESCORT_FROM_CELL)
    elseif (asSceneType == CATEGORY_FRISKING)
    elseif (asSceneType == CATEGORY_STRIPPING)
    elseif (asSceneType == CATEGORY_ELUDING)
    endif
endFunction

; function test()
;     int array = Array("<string>")

;     if (array != -1)
;         ; things
;     else
;         int exceptions = Exceptions(array)

;         if (CatchException(exceptions, "InvalidObjectException"))
;             int e = GetException(exceptions, "InvalidObjectException")
;             Error(ExceptionMessage(e))
;         endif
;     endif
; endFunction


event OnSceneStart(string name, Scene sender)
    __lastStartedScene = name
    Form[] params   = self.GetSceneReferences(name)
    string type     = self.GetSceneType(name)

    Debug("SceneManager::OnSceneStart", "Starting Scene: " + name)

    self.HandleSceneGlobalControlFlow(type, name)

    if (type == CATEGORY_ARREST_START)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")

        EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_JAIL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")

        self.SetGlobal("RPB_Scene_Action_CF01", 1) ; Enables some actions in escort to cell
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_CELL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_02) ; override
            escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
            prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")
        endif
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, prisoners, escort)

    elseif (type == CATEGORY_ESCORT_FROM_CELL)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, prisoners, guard)

    elseif (type == CATEGORY_FRISKING)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_FRISK_BEGIN, prisoners, guard)

    elseif (type == CATEGORY_STRIPPING)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

        string secondaryEvent = string_if (name == SCENE_STRIPPING_02, "Undress to Underwear", "null")

        EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIP_BEGIN, prisoners, guard, secondaryEvent)

    elseif (type == CATEGORY_ELUDING)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Actor eluder     = self.GetSceneNthReferenceOfType(name, "Eluder") as Actor

        EventManager.SendArrestSceneEvent(name, EVENT_ELUDE_BEGIN, eluder, guard, "Dialogue")
    endif

    ; Only with DEBUG on: the text is built before Debug() checks, with native calls on every Scene actor (a broken one
    ; blocked the Scene flow right here)
    if (IsDebuggingEnabled())
        Debug("SceneManager::OnSceneStart", self.GetSceneParametersDebugInfo(sender, name))
    endif
endEvent

event OnScenePlaying(string name, int phaseEvent, int phase, Scene sender)
    string type = self.GetSceneType(name)
    ; A phase's end is the next one's start: some Scenes only report ends (RPB_EscortToCell01 has no start event for its
    ; walk into the cell), and counting starts only put the walk-in at the lock
    __phaseScene = name
    if (phaseEvent == PHASE_START)
        __phase = phase
    else
        __phase = phase + 1
    endif

    Debug("SceneManager::OnScenePlaying", name + " " + sender + ": " + string_if (phaseEvent == PHASE_START, "(Start)", "(End)") + " Phase " + phase)

    if (type == CATEGORY_ARREST_START)
        Actor escort        = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees    = self.GetSceneReferencesOfType(name, "Escortee")

        if (name == SCENE_ARREST_START_01)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Hands Behind Back")
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")
            endif

        elseif (name == SCENE_ARREST_START_02)
            if (phase == 3 && phaseEvent == PHASE_START)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")

            elseif (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Hands Behind Back")
            endif

        elseif (name == SCENE_ARREST_START_03)
            if (phase == 4 && phaseEvent == PHASE_START)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")

            elseif (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Kneel Down")
            endif

        elseif (name == SCENE_ARREST_START_04)
            if (phase == 1 && phaseEvent == PHASE_START)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Lie Down")

            elseif (phase == 6 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")
            endif

        elseif (name == SCENE_ARREST_START_PRISON_01)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Hands Behind Back")

            elseif (phase == 2 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")
            endif
        endif

    elseif (type == CATEGORY_ESCORT_TO_JAIL)
        ; No Events

    elseif (type == CATEGORY_ESCORT_TO_CELL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_01 || name == SCENE_ESCORT_TO_CELL_04)
            if (phase == 7 && phaseEvent == PHASE_START)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Lock Cell")

            elseif (phase == 4 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Unlock Cell")

            elseif (phase == 5 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Release from Captor")
            endif

        elseif (name == SCENE_ESCORT_TO_CELL_02)
            escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
            prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")

            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Hands Behind Back")

            elseif (phase == 2 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Restrain Prisoner")

            elseif (phase == 8 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Lock Cell")
            endif
        endif

    elseif (type == CATEGORY_ESCORT_FROM_CELL)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

        if (name == SCENE_ESCORT_FROM_CELL)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORTING, prisoners, guard)
            endif
        endif

    elseif (type == CATEGORY_STRIPPING)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

        if (name == SCENE_STRIPPING_01)
            EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIPPING, prisoners, guard)

        elseif (name == SCENE_STRIPPING_02)
            EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIPPING, prisoners, guard)

            if (phase == 6 && phaseEvent == PHASE_START) ; Remove Underwear
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIPPING, prisoners, guard, "Remove Underwear")
            endif

        elseif (name == SCENE_FORCED_STRIPPING_01)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Lie Down")

            elseif (phase == 2 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Undress to Underwear")

            elseif (phase == 3 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Remove Underwear")
            endif

        elseif (name == SCENE_FORCED_STRIPPING_02)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Lie Down")

            elseif (phase == 3 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Undress Lower Body")

            elseif (phase == 5 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Sit Down")

            elseif (phase == 7 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Undress Upper Body")
            endif
        endif

    elseif (type == CATEGORY_SURRENDER)
        Form[] surrendererCaptors   = self.GetSceneReferencesOfType(name, "SurrendererCaptor")
        Actor surrenderer           = self.GetSceneNthReferenceOfType(name, "Surrenderer") as Actor

        if (name == SCENE_SURRENDER_01)
            if (phase == 3 && phaseEvent == PHASE_START)
                EventManager.SendSurrenderSceneEvent(name, EVENT_SURRENDER_BEGIN, surrenderer, none, "null", surrendererCaptors)
            endif
        endif

    elseif (type == CATEGORY_PAY_BOUNTY)
        Actor escort        = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees    = self.GetSceneReferencesOfType(name, "Escortee")

        if (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
            if (phase == 3 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_PAYING_BOUNTY, arrestees, escort, "Hands Behind Back")
            endif
        endif

    elseif (type == CATEGORY_RESTRAIN)
        Actor guard     = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

        if (name == SCENE_RESTRAIN_PRISONER_01)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_BEGIN, prisoners, guard, "Hands in Front")

            elseif (phase == 2 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_END, prisoners, guard)
            endif

        elseif (name == SCENE_RESTRAIN_PRISONER_02)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_BEGIN, prisoners, guard, "Hands Behind Back")

            elseif (phase == 2 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_END, prisoners, guard)
            endif
        endif

    endif

endEvent

event OnSceneEnd(string name, Scene sender)
    string type = self.GetSceneType(name)
    Actor lockAfterFinish = none ; the escort to jail's guard, locked once this Scene is fully over (see below)
    self.__EndSceneBookkeeping(name) ; over before its events start the next one (see __EndSceneBookkeeping)

    if (type == CATEGORY_ARREST_START)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")

        string secondaryEvent = string_if (name == SCENE_ARREST_START_PRISON_01, "Arrest in Prison", "null")

        EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_END, arrestees, escort, secondaryEvent)

    elseif (type == CATEGORY_ESCORT_TO_JAIL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")
        
        ; The package lock (unset at the escort to the cell's end) goes on after __FinishScene below, not here: bound here,
        ; the guard was forced into it while still in this Scene's Escort alias mid-end, and in two reproductions he turned
        ; uncallable within that same second (every call on him then waits forever)
        lockAfterFinish = escort
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_CELL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_02) ; override
            escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
            prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")
        endif
        
        self.UnsetPackageLockOnActor(escort) ; Needs to be reviewed, since the Escort may not be the one from the "Escort to Jail" scene, where the package is set
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort)

    elseif (type == CATEGORY_ESCORT_FROM_CELL)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, guard)

    elseif (type == CATEGORY_STRIPPING)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

        string secondaryEvent = "null"

        if (name == SCENE_STRIPPING_01)
            secondaryEvent = "Restrain Prisoner"
        
        elseif (name == SCENE_FORCED_STRIPPING_01)
            secondaryEvent = "Stand Up (Lie Down)"

        elseif (name == SCENE_FORCED_STRIPPING_02)
            secondaryEvent = "Stand Up (Kneel)"
        endif

        EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIP_END, prisoners, guard, secondaryEvent)

    elseif (type == CATEGORY_CLOTHING)
        Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
        Actor prisoner = self.GetSceneNthReferenceOfType(name, "Prisoner") as Actor

        if (name == SCENE_GIVE_CLOTHING)
            
        endif

        EventManager.SendPrisonSceneEvent(name, EVENT_CLOTHING_END, prisoner, guard)

    elseif (type == CATEGORY_SURRENDER)
        Actor surrendererCaptor = self.GetSceneNthReferenceOfType(name, "SurrendererCaptor") as Actor
        Actor surrenderer       = self.GetSceneNthReferenceOfType(name, "Surrenderer") as Actor
        Debug("SceneManager::OnSceneEnd", "surrendererCaptor: " + surrendererCaptor + ", surrenderer: " + surrenderer)

        EventManager.SendSurrenderSceneEvent(name, EVENT_SURRENDER_END, surrenderer, surrendererCaptor)

    elseif (type == CATEGORY_PAY_BOUNTY)
        Actor escort   = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Actor escortee = self.GetSceneNthReferenceOfType(name, "Escortee") as Actor

        string secondaryEvent = "null"

        if (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
            secondaryEvent = "Follow Willingly"
        
        elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
            secondaryEvent = "Escort by Force"
        endif

        EventManager.SendArrestSceneEvent(name, EVENT_ARREST_PAY_BOUNTY_END, escortee, escort, secondaryEvent)
    endif

    ; Only for the debug line: reading every alias costs 43-360ms per Scene end, and ran with DEBUG off too
    if (IsDebuggingEnabled())
        Debug("SceneManager::OnSceneEnd", self.GetSceneParametersDebugInfo(sender, name))
    endif
    Debug("SceneManager::OnSceneEnd", "Ended Scene: " + name)

    ; self.UnbindAliases(name) ; (Need to fix this, since they get unbound after they should, for now, uncommented) ERROR: EventManager::SendPrisonSceneBulkEvent() -> No prisoners provided for bulk scene event!
    self.__PlayNextIfIdle()

    if (lockAfterFinish)
        RPB_Utility.GuardMark(lockAfterFinish, "binding the package lock (escort to jail over)")
        self.SetPackageLockOnActor(lockAfterFinish)
        RPB_Utility.GuardMark(lockAfterFinish, "package lock bound")
    endif
endEvent

;/
    The queue's side of a Scene ending: the flag and the control-flow globals are reset BEFORE the next queued Scene
    starts. The flag used to be cleared after PlayQueued(), so a Scene started from another's end (confrontation -> escort)
    was marked "not playing" while it ran: the next arrest's Scene started on top of it, on the same shared aliases, and
    the leftover escort Scene walked the new pair off (tests 106/107 polluting each other). The globals were likewise reset
    after the next Scene had started, wiping what it had just been given.
/;
function __FinishScene(string asScene)
    self.__EndSceneBookkeeping(asScene)
    self.__PlayNextIfIdle()
endFunction

;/
    A Scene is over: marked so before its end events run (OnSceneEnd), so what those events start is the current Scene.
    They used to run first: the escort to jail's end started the strip and queued the escort to the cell, then the end's
    own bookkeeping cleared the flag and popped the escort to the cell on top of the strip (the guard in two Scenes, the
    escort stalling at the cell door). The engine usually refused that second Start() while the strip had the guard; with
    the game paused at that moment both took hold. The flag only clears for this Scene (or none): another Scene started
    meanwhile stays playing.
/;
function __EndSceneBookkeeping(string asScene)
    self.ResetSceneOverride()
    __lastEndedScene = asScene
    if (currentScene == asScene || currentScene == "")
        __isScenePlaying = false
    endif
    self.ResetGlobals()
endFunction

; The next queued Scene, unless the ending Scene's own events already started one
function __PlayNextIfIdle()
    if (!__isScenePlaying)
        self.PlayQueued()
    endif
    self.OnResumeSceneBlocked()
endFunction

event OnAllScenesFinished()
    Debug("SceneManager::OnAllScenesFinished", "Resetting current scene!")
    currentScene = ""

    self.ResetGlobals()
endEvent

; ==========================================================
;                       Scene Starters
; ==========================================================

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
    ObjectReference waitingEscortMarker = akEscortWaitingMarker
    if (waitingEscortMarker == none)
        waitingEscortMarker = akJailCellDoor
    endif

    string name = self.EscortToCellSceneName()
    Debug("SceneManager::StartEscortToCell", name + ": akEscortLeader: " + akEscortLeader + ", akEscortedPrisoner: " + akEscortedPrisoner)

    self.BindSceneAlias(name, "Escort", akEscortLeader)
    self.BindSceneAlias(name, "Escortee", akEscortedPrisoner)
    self.BindSceneAlias(name, "CellDoor", akJailCellDoor)
    self.BindSceneAlias(name, "Player_EscortLocation", akJailCellMarker)
    self.BindSceneAlias(name, "Guard_EscortLocation", waitingEscortMarker)
    self.QueueOrPlay(name)
endFunction

function StartEscortToCell_02(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, ObjectReference akJailCellDoor, ObjectReference akEscortWaitingMarker)
    ObjectReference waitingEscortMarker = akEscortWaitingMarker
    if (waitingEscortMarker == none)
        waitingEscortMarker = akJailCellDoor
    endif

    string name = SCENE_ESCORT_TO_CELL_02
    self.BindSceneAlias(name, "Guard", akEscortLeader)
    self.BindSceneAlias(name, "Prisoner", akEscortedPrisoner)
    self.BindSceneAlias(name, "CellDoor", akJailCellDoor)
    self.BindSceneAlias(name, "Cell", akJailCellMarker)
    self.BindSceneAlias(name, "Guard_EscortLocation", waitingEscortMarker)
    self.QueueOrPlay(name)
endFunction

function StartEscortFromCell(Actor akGuard, Actor akPrisoner, ObjectReference akJailCellDoor, ObjectReference akJailChest)
    Debug("SceneManager::StartEscortFromCell", "Starting Scene " + self.GetScene(SCENE_ESCORT_FROM_CELL) +", params: ["+ akGuard + "," + akPrisoner + "," + akJailCellDoor + "," + akJailChest + "]")
    string name = SCENE_ESCORT_FROM_CELL
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.BindSceneAlias(name, "Player_EscortLocation", akJailChest)
    self.BindSceneAlias(name, "Guard_EscortLocation", akJailCellDoor)
    self.QueueOrPlay(name)
endFunction

function StartEscortToJail(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akPrisonerChest)
    string name = SCENE_ESCORT_TO_JAIL_01
    self.BindSceneAlias(name, "Escort", akEscortLeader)
    self.BindSceneAlias(name, "Escortee", akEscortedPrisoner)
    self.BindSceneAlias(name, "Player_EscortLocation", akPrisonerChest)
    self.BindSceneAlias(name, "Guard_EscortLocation", akPrisonerChest)
    self.QueueOrPlay(name)
endFunction

function EscortToJail(Actor akEscort, Form[] akEscortees, Form[] akDestinations)
    string name = SCENE_ESCORT_TO_JAIL_01

    self.BindSceneAlias(name, "Escort", akEscort)
    self.BindSceneAliasGroup(name, "Escortee", akEscortees)
    self.BindSceneAliasGroup(name, "Player_EscortLocation", akDestinations)
    self.BindSceneAliasGroup(name, "Guard_EscortLocation", akDestinations)

    self.QueueOrPlay(name)
endFunction

function StartStrippingStart(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; TODO: add the remaining prisoners
    string name = SCENE_STRIPPING_START_01
    self.BindSceneAlias(name, "Guard", akStripperGuard)
    self.BindSceneAlias(name, "Prisoner", akStrippedPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartStripping(Actor akStripperGuard, Actor akStrippedPrisoner)
    string name = SCENE_STRIPPING_01
    self.BindSceneAlias(name, "Guard", akStripperGuard)
    self.BindSceneAlias(name, "Prisoner", akStrippedPrisoner)
    ; self.BindSceneAlias(name, "Guard_EscortLocation", akStripMarker) ; Needs to be added
    ; self.BindSceneAlias(name, "Player_EscortLocation", akStripMarker) ; Needs to be added
    self.QueueOrPlay(name)
endFunction

function StartStripping_02(Actor akStripperGuard, Actor akStrippedPrisoner, ObjectReference akStripMarker = none)
    string name = SCENE_STRIPPING_02
    self.BindSceneAlias(name, "Guard", akStripperGuard)
    self.BindSceneAlias(name, "Prisoner", akStrippedPrisoner)
    self.BindSceneAlias(name, "Guard_EscortLocation", akStripMarker)
    self.BindSceneAlias(name, "Player_EscortLocation", akStripMarker)
    self.QueueOrPlay(name)
endFunction

function StartFrisking(Actor akFriskerGuard, Actor akFriskedPrisoner)
    string name = SCENE_FRISKING
    self.BindSceneAlias(name, "Guard", akFriskerGuard)
    self.BindSceneAlias(name, "Prisoner", akFriskedPrisoner)
    ; self.BindSceneAlias(name, "Guard_EscortLocation", akFriskMarker) ; Needs to be added
    ; self.BindSceneAlias(name, "Player_EscortLocation", akFriskMarker) ; Needs to be added
    self.QueueOrPlay(name)
endFunction

function StartGiveClothing(Actor akGuard, Actor akPrisoner)
    string name = SCENE_GIVE_CLOTHING
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartBountyPaymentFail(Actor akGuard, Actor akPrisoner)
    string name = SCENE_PAYMENT_FAIL
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartArrestStart01(Actor akGuard, Actor akPrisoner)
    string name = SCENE_ARREST_START_01
    self.BindSceneAlias(name, "Escort", akGuard)
    self.BindSceneAlias(name, "Escortee", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartArrestStart02(Actor akGuard, Actor akPrisoner)
    string name = SCENE_ARREST_START_02
    self.BindSceneAlias(name, "Escort", akGuard)
    self.BindSceneAlias(name, "Escortee", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartArrestStart03(Actor akGuard, Actor akPrisoner)
    string name = SCENE_ARREST_START_03
    self.BindSceneAlias(name, "Escort", akGuard)
    self.BindSceneAlias(name, "Escortee", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartArrestStart04(Actor akGuard, Actor akPrisoner)
    string name = SCENE_ARREST_START_04
    self.BindSceneAlias(name, "Captor", akGuard) ; needs to be changed to Escort
    self.BindSceneAlias(name, "Escortee", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors, string asScene)
    string name = SCENE_SURRENDER_01
    self.BindSceneAliasGroup(name, "SurrendererCaptor", RPB_Utility.ActorToFormArray(akSurrendererCaptors))
    self.BindSceneAlias(name, "Surrenderer", akSurrenderer)
    self.QueueOrPlay(name)
endFunction

function StartArrestScene(Actor akGuard, Actor akArrestee, string asScene)
    string name = asScene
    self.BindSceneAlias(name, "Escort", akGuard)
    self.BindSceneAlias(name, "Escortee", akArrestee)
    self.QueueOrPlay(name)
endFunction

function StartEscortToJailScene(Actor akGuard, Actor akArrestee, string asScene)
    string name = asScene
    self.BindSceneAlias(name, "Escort", akGuard)
    self.BindSceneAlias(name, "Escortee", akArrestee)
    self.QueueOrPlay(name)
endFunction

function StartArrestStartPrison_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    string name = SCENE_ARREST_START_PRISON_01
    self.BindSceneAlias(name, "Escort", akGuard)
    self.BindSceneAlias(name, "Escortee", akPrisoner)
    self.StartSceneAtPhase(aiStartingPhase)
    self.QueueOrPlay(name)
endFunction

function StartRestrainPrisoner_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    string name = SCENE_RESTRAIN_PRISONER_01
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.StartSceneAtPhase(aiStartingPhase)
    self.QueueOrPlay(name)
endFunction

function StartRestrainPrisoner_02(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    string name = SCENE_RESTRAIN_PRISONER_02
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.StartSceneAtPhase(aiStartingPhase)
    self.QueueOrPlay(name)
endFunction

function StartNoClothing(Actor akGuard, Actor akPrisoner)
    string name = SCENE_NO_CLOTHING
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartForcedStripping(Actor akGuard, Actor akPrisoner)
    string name = SCENE_FORCED_STRIPPING_01
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartForcedStripping02(Actor akGuard, Actor akPrisoner)
    string name = SCENE_FORCED_STRIPPING_02
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Prisoner", akPrisoner)
    self.QueueOrPlay(name)
endFunction

function StartEludingArrest(Actor akGuard, Actor akEluder)
    if (self.GetScene(SCENE_ELUDING_ARREST_01).IsPlaying())
        Debug("SceneManager::StartEludingArrest", "Scene is currently playing, aborting call!")
        return
    endif

    string name = SCENE_ELUDING_ARREST_01
    self.BindSceneAlias(name, "Guard", akGuard)
    self.BindSceneAlias(name, "Eluder", akEluder)
    self.QueueOrPlay(name)
endFunction

function StartArrestBountyPaymentFollowWillingly(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    string name = SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY
    self.BindSceneAlias(name, "Escort", akEscort)
    self.BindSceneAlias(name, "Escortee", akEscortee)
    self.BindSceneAlias(name, "Guard_EscortLocation", akEscortLocation)
    self.BindSceneAlias(name, "Player_EscortLocation", akEscortLocation)
    self.QueueOrPlay(name)
endFunction

function StartArrestPayBountyFollowByForce(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    string name = SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE
    self.BindSceneAlias(name, "Escort", akEscort)
    self.BindSceneAlias(name, "Escortee", akEscortee)
    self.BindSceneAlias(name, "Guard_EscortLocation", akEscortLocation)
    self.BindSceneAlias(name, "Player_EscortLocation", akEscortLocation)
    self.QueueOrPlay(name)
endFunction


; ==========================================================
;                           Debug
; ==========================================================

string function GetSceneParametersDebugInfo(Scene sender, string sceneName)
    Form[] params   = self.GetSceneReferences(sceneName)
    Alias[] aliases = self.GetSceneAliases(sceneName, true)

    string debugInfo = ""
    bool emptyParams = true

    ; The refs only, no calls on them (form IDs, base, names used to be read here): a Scene actor gone uncallable made this
    ; debug line wait forever, in OnSceneEnd before __FinishScene, and the next Scene never started. The ref's own text
    ; already carries its form ID.
    int i = 0
    while (i < params.Length)
        ObjectReference param = params[i] as ObjectReference
        if (param != none)
            ReferenceAlias paramBinder = aliases[i] as ReferenceAlias
            string paramBinderSignature = "["+ paramBinder.GetName() +" < ("+ paramBinder.GetID() +")>]"
            emptyParams = false

            debugInfo += "\t["+i+"]: " + paramBinderSignature + " " + param + "\n"
        endif
        i += 1
    endWhile
    
    if (emptyParams)
        return sceneName + " " + sender + " - No Parameters, Scene expected: " + params.Length + " parameters!" ; " - No Parameters, Scene expected: need a way to find scene required params
    endif

    return sceneName + " " + sender + "\nParameters: [\n" + debugInfo + "]"
endFunction
