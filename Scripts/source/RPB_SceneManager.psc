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

RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

; ==========================================================
;                            Init
; ==========================================================

int __globalDefaults    ; JMap&
int __globals           ; JMap&
int __sceneContainer    ; JMap&
int __sceneToCategory   ; JMap&
int __sceneConfig       ; JMap&

function SceneManager()
    int map = RPB_Memory.Map("<string, Map<int, int[][]>>")
    ; RPB_Memory.Get(map, "[ 'key', 1 ]") ; R: Object<int[][]>
    ; RPB_Memory.Set(map, "[ 'key', 1 ], [[4, 10], [2, 4]]")
endFunction

function __allocateMemory()
    ; __sceneContainer    = objectNotExists(__sceneContainer,  FastMap(retain = true))
    ; __sceneToCategory   = objectNotExists(__sceneToCategory, FastMap(retain = true))
    ; __sceneConfig       = objectNotExists(__sceneConfig,     FastMap(retain = true))
    ; __globals           = objectNotExists(__globals,         FastMap(retain = true))
    ; __globalDefaults    = objectNotExists(__globalDefaults,  FastMap(retain = true))

    if (!__sceneContainer)
        __sceneContainer = JMap.object()
        JValue.retain(__sceneContainer, "SceneManager")
    endif

    if (!__sceneToCategory)
        __sceneToCategory = JMap.object()
        JValue.retain(__sceneToCategory, "SceneManager")
    endif

    if (!__sceneConfig)
        __sceneConfig = JMap.object()
        JValue.retain(__sceneConfig, "SceneManager")
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

    float sceneConfigBench = StartBenchmark()
    self.CreateSceneConfig()
    EndBenchmark(sceneConfigBench, "SceneManager::CreateSceneConfig")
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
    ; RPB_Memory.Set(map, "['Globals'], { 'asGlobalName': aiGlobalFormID }")
    ; RPB_Memory.Set(map, "['GlobalDefaults'], { 'asGlobalName': aiDefaultValue }")
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
event OnSceneStartHandleGlobals(string asSceneName, Form[] params)
    ; if (self.IsSceneOfType(asSceneName, CATEGORY_ESCORT_TO_JAIL))
    ;     self.SetGlobal("RPB_Scene_Action_CF01", 1) ; Enables some actions in escort to cell
    ; endif

    float sceneRefTypesBench = StartBenchmark()
    int i = 0
    string[] sceneRefTypes = self.GetSceneRefTypes(asSceneName)
    while (i < sceneRefTypes.Length)
        Form[] paramsOfType = self.GetSceneRefsOfType(asSceneName, sceneRefTypes[i])
        Debug("SceneManager::OnSceneStartHandleGlobals", "["+ sceneRefTypes[i] +"] "+ asSceneName +" Params: " + paramsOfType)
        i += 1
    endWhile
    EndBenchmark(sceneRefTypesBench, "SceneManager::GetSceneRefTypes")

    ; float sceneRefTypesBench = StartBenchmark()
    ; Form[] sceneRefs        = self.GetSceneRefs(asSceneName)
    ; Alias[] sceneAliases    = self.GetSceneAliases(asSceneName)
    ; Debug("SceneManager::OnSceneStartHandleGlobals", asSceneName +" Params: " + sceneRefs)
    ; Debug("SceneManager::OnSceneStartHandleGlobals", asSceneName +" Aliases: " + sceneAliases)
    ; EndBenchmark(sceneRefTypesBench, "SceneManager::GetSceneRefs")
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
    ; Map_SetInt(__sceneContainer, asSceneName, aiSceneFormID)

    if (asSceneCategory != "null")
        ; Map_SetString(__sceneToCategory, asSceneName, asSceneCategory)
        JMap.setStr(__sceneToCategory, asSceneName, asSceneCategory)
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

string function GetSceneType(string asSceneName)
    return JMap.getStr(__sceneToCategory, asSceneName)
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

function CreateSceneRefTypeConfig(string asScene, string asRefType, int[] akSceneAliasCount)
    bool sceneExists = JMap.hasKey(__sceneConfig, asScene)

    if (!sceneExists)
        JMap.setObj(__sceneConfig, asScene, JMap.object())
    endif

    int sceneRefTypesObj = JMap.getObj(__sceneConfig, asScene)

    if (!sceneRefTypesObj)
        EventManager.SendError("Cannot create the scene config for scene " + asScene + " (object does not exist!)", "SceneManager::CreateSceneRefTypeConfig")
        return
    endif

    ; Debug("SceneManager::CreateSceneRefTypeConfig", asScene + ": " + GetContainerList(sceneRefTypesObj))

    ; Get Alias ID from the specified config
    int aliasCount = akSceneAliasCount[0]
    int startIndex = akSceneAliasCount[1]

    int aliasIds = JArray.object()

    int i = 0
    while (i < (aliasCount - startIndex))
        ReferenceAlias a = self.GetRefAlias(asRefType, i)
        if (a)
            int aliasId = a.GetID()
            if (JArray.findInt(aliasIds, aliasId) == -1)
                JArray.addInt(aliasIds, aliasId)
            endif
        endif
        i += 1
    endWhile

    ; string args = "asScene: " + asScene + ", asRefType: " + asRefType + ", akSceneAliasCount: " + akSceneAliasCount
    ; DebugWithArgs("SceneManager::CreateSceneRefTypeConfig", args, asRefType + ": " + GetContainerList(aliasIds))

    JMap.setObj(sceneRefTypesObj, asRefType, aliasIds)
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
    int obj = JMap.getObj(__sceneConfig, asScene)
    int refTypes = JMap.allKeys(obj)

    int keyIndex = 0
    while (keyIndex < JValue.count(refTypes))
        string refTypeName = JArray.getStr(refTypes, keyIndex)
        int refTypeIds = JMap.getObj(obj, refTypeName) ; JArray&

        int valueIndex = 0
        while (valueIndex < JValue.count(refTypeIds))
            int id = JArray.getInt(refTypeIds, valueIndex)
            Alias a = self.GetAliasByID(id)
            if (!a || (refTypeName != a.GetName()))
                Debug("SceneManager::GetSceneRefTypesConfig", "Validating and removing ["+ valueIndex +"] (id: "+ id +") (Ref Type: "+ refTypeName +"), alias does not exist!")
                JArray.eraseIndex(refTypeIds, valueIndex)
            endif
            valueIndex += 1
        endWhile

        keyIndex += 1
    endWhile
endFunction

function RemoveSceneRefType(string asScene, string asRefType)
    int sceneRefTypeMap = JMap.getObj(__sceneConfig, asScene)

    if (JMap.hasKey(sceneRefTypeMap, asRefType))
        JMap.removeKey(sceneRefTypeMap, asRefType)
    endif
endFunction

int function GetSceneRefTypesConfig(string asScene)
    return JMap.getObj(__sceneConfig, asScene) ; JMap&
endFunction

int function GetSceneRefsOfTypeObject(string asScene, string asRefType)
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene)
    return JMap.getObj(specifiedSceneConfig, asRefType) ; JArray<int>&
endFunction

Alias[] function GetSceneAliasesOfType(string asScene, string asRefType, bool abOnlyIncludeAliasesInUse = false)
    int refsOfType = self.GetSceneRefsOfTypeObject(asScene, asRefType)

    int refTypeCount    = JArray.getInt(refsOfType, 0)
    int refStartIndex   = JArray.getInt(refsOfType, 1)

    Alias[] aliasArr = Utility.CreateAliasArray(refTypeCount)

    int i = 0
    int aliasIndex = refStartIndex
    while (i < (refTypeCount - refStartIndex))
        Alias currentAlias = self.GetAliasByName(asRefType + aliasIndex)
        if (!abOnlyIncludeAliasesInUse || (abOnlyIncludeAliasesInUse && (currentAlias as ReferenceAlias).GetReference() != none))
            aliasArr[i] = currentAlias
        endif
        aliasIndex += 1
        i += 1
    endWhile

    return aliasArr
endFunction

;/
    string  @asScene: The scene to retrieve the reference types from.

    returns (string[]): All reference types used in the Scene.
/;
string[] function GetSceneRefTypes(string asScene)
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene)
    return JMap.allKeysPArray(specifiedSceneConfig)
endFunction

Alias[] function GetSceneAliases(string asScene)
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; JMap&
    int allRefTypeIds = JMap.allValues(specifiedSceneConfig) ; JArray&
    int explodedIds = JArray.object()
    int arrayLength = 0

    int i = 0
    while (i < JValue.count(allRefTypeIds))
        int typeArray = JArray.getObj(allRefTypeIds, i)
        if (typeArray)
            int k = 0
            while (k < JValue.count(typeArray))
                int id = JArray.getInt(typeArray, k)
                JArray.addInt(explodedIds, id)
                k += 1
            endWhile
            arrayLength += JValue.count(typeArray)
        endif
        i += 1
    endWhile

    if (arrayLength <= 0)
        EventManager.SendError("Could not retrieve any scene aliases for Scene " + asScene + " (no aliases found!)", "SceneManager::GetSceneAliases")
        return none
    endif

    Alias[] mergedAliases = Utility.CreateAliasArray(arrayLength)
    i = 0
    while (i < mergedAliases.Length)
        int id = JArray.getInt(explodedIds, i)
        mergedAliases[i] = self.GetAliasByID(id)
        i += 1
    endWhile

    ; DebugWithArgs("SceneManager::GetSceneAliases", asScene, \ 
    ;     "All Ref Types: " + GetContainerList(allRefTypeIds) + "," + \ 
    ;     "Merged Types: " + mergedAliases \
    ; )

    return mergedAliases
endFunction

Form[] function GetSceneRefs(string asScene)
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; JMap&
    ;/
        "Guards": [],
        "Prisoners": []
    /;

    int allRefTypeIds = JMap.allValues(specifiedSceneConfig) ; JArray&
    int mergedTypes = JArray.object()

    int i = 0
    while (i < JValue.count(allRefTypeIds))
        int typeArray = JArray.getObj(allRefTypeIds, i)
        if (typeArray)
            int k = 0
            while (k < JValue.count(typeArray))
                int id = JArray.getInt(typeArray, k)
                ReferenceAlias r = self.GetAliasByID(id) as ReferenceAlias
                ObjectReference ref = r.GetReference()
                if (ref != none)
                    JArray.addForm(mergedTypes, ref)
                endif
                k += 1
            endWhile
        endif
        i += 1
    endWhile

    ; DebugWithArgs("SceneManager::GetSceneRefs", asScene, \ 
    ;     "All Ref Types: " + GetContainerList(allRefTypeIds) + "," + \ 
    ;     "Merged Types: " + GetContainerList(mergedTypes) \
    ; )

    return JArray.asFormArray(mergedTypes)
endFunction

Form[] function GetSceneRefsOfType(string asScene, string asRefType)
    int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; JArray&
    int arrLen      = JValue.count(refsOfType)
    
    int boundReferences = JArray.object()
 
    int i = 0
    while (i < arrLen)
        int id = JArray.getInt(refsOfType, i)
        ReferenceAlias r = self.GetAliasByID(id) as ReferenceAlias
        ObjectReference ref = r.GetReference()
        if (ref != none)
            JArray.addForm(boundReferences, ref)
        endif
        i += 1
    endWhile

    ; int refTypeCount    = JArray.getInt(refsOfType, 0)
    ; int refStartIndex   = JArray.getInt(refsOfType, 1)

    ; int boundReferences = JArray.object()

    ; int i = 0
    ; int aliasIndex = refStartIndex
    ; while (i < (refTypeCount - refStartIndex))
    ;     ReferenceAlias currentAlias = self.GetRefAlias(asRefType, aliasIndex) as ReferenceAlias
    ;     ObjectReference aliasRef = currentAlias.GetReference()
    ;     ; DebugWithArgs( \ 
    ;     ;     "SceneManager::GetSceneRefsOfType", "asScene: " + asScene + ", asRefType: " + asRefType, \ 
    ;     ;     "Alias: " + currentAlias + "\n" + \
    ;     ;     "Reference: " + aliasRef + "\n" \
    ;     ; )
    ;     if (aliasRef != none)
    ;         JArray.addForm(boundReferences, aliasRef)
    ;     endif
    ;     aliasIndex += 1
    ;     i += 1
    ; endWhile

    ; DebugWithArgs("SceneManager::GetSceneRefsOfType", "asScene: " + asScene + ", asRefType: " + asRefType, \ 
    ;     GetContainerList(refsOfType) + "\n," + \ 
    ;     GetContainerList(boundReferences) + "\n," + \ 
    ;     "refTypeCount: " + refTypeCount + "\n" + \
    ;     "refStartIndex: " + refStartIndex \
    ; )
    
    return JArray.asFormArray(boundReferences)
endFunction

Form[] function BuildParams( \
    ObjectReference akRef1, \
    ObjectReference akRef2 = none, \
    ObjectReference akRef3 = none, \
    ObjectReference akRef4 = none, \
    ObjectReference akRef5 = none, \
    ObjectReference akRef6 = none, \
    ObjectReference akRef7 = none, \
    ObjectReference akRef8 = none, \
    ObjectReference akRef9 = none, \
    ObjectReference akRef10 = none \
)



endFunction

function CreateSceneConfig()
    ; Arrest Start
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_01, "Escort",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_01, "Escortee",    Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_02, "Escort",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_02, "Escortee",    Pair(2, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_03, "Escort",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_03, "Escortee",    Pair(2, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_04, "Escort",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_04, "Escortee",    Pair(2, 0))

    ; Arrest Start - Prison
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_PRISON_01, "Escort",   Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_START_PRISON_01, "Escortee", Pair(2, 0))

    ; Eluding Arrest
    self.CreateSceneRefTypeConfig(SCENE_ELUDING_ARREST_01, "Guard",   Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ELUDING_ARREST_01, "Eluder",  Pair(1, 0))

    ; Pay Bounty
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY, "Escort",   Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY, "Escortee", Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE, "Escort",    Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE, "Escortee",  Pair(1, 0))

    ; Restrain Prisoner
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_01, "Guard",     Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_01, "Prisoner",  Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_02, "Guard",     Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_02, "Prisoner",  Pair(1, 0))

    ; Escort to Jail
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Escort",    Pair(3, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Escortee",  Pair(10, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_02, "Escort",    Pair(3, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_02, "Escortee",  Pair(1, 0))

    ; Escort to Cell
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Escort",        Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Escortee",      Pair(3, 0)) ; refactor to Prisoner
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "CellDoor",      Pair(1, 0))
    ; self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "ExteriorCell",  Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Player_EscortLocation",  Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Guard_EscortLocation",  Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_02, "Guard",         Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_02, "Prisoner",      Pair(1, 0))

    ; Escort from Cell
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_FROM_CELL, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_FROM_CELL, "Prisoner",   Pair(1, 0))

    ; Frisking
    self.CreateSceneRefTypeConfig(SCENE_FRISKING, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_FRISKING, "Prisoner",   Pair(1, 0))

    ; Stripping
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_01, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_01, "Prisoner",   Pair(3, 0))
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_02, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_STRIPPING_02, "Prisoner",   Pair(3, 0))

    ; Forced Stripping
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_01, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_01, "Prisoner",   Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_02, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_02, "Prisoner",   Pair(1, 0))

    ; Give Clothing
    self.CreateSceneRefTypeConfig(SCENE_GIVE_CLOTHING, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_GIVE_CLOTHING, "Prisoner",   Pair(1, 0))

    ; No Clothing
    self.CreateSceneRefTypeConfig(SCENE_NO_CLOTHING, "Guard",      Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_NO_CLOTHING, "Prisoner",   Pair(4, 0))

    ; Surrender
    self.CreateSceneRefTypeConfig(SCENE_SURRENDER_01, "Surrenderer",        Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_SURRENDER_01, "SurrendererCaptor",  Pair(6, 0))
endFunction

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
        self.RestoreAliases()
        self.GetScene(nextScene).Start() ; Play the Scene
        currentScene = nextScene
        Debug("SceneManager::PlayQueued", "Setting current scene: " + nextScene)

    endif
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

ReferenceAlias function GetEscort(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Escort", "Escort" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetEscortee(int index = 0)
    return self.GetAliasByName(string_if (index == 0, "Escortee", "Escortee" + index)) as ReferenceAlias
endFunction

ReferenceAlias function GetSurrenderer(int index = 0)
    return self.GetAliasByName("Surrenderer_" + index) as ReferenceAlias
endFunction

ReferenceAlias function GetSurrendererCaptor(int index = 0)
    return self.GetAliasByName("SurrendererCaptor_" + index) as ReferenceAlias
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

int __queuedAliases
function BindAlias(ReferenceAlias apRefAlias, ObjectReference akRef)
    ; Queue the alias
    if (!__queuedAliases)
        __queuedAliases = JIntMap.object()
        JValue.retain(__queuedAliases)
    endif

    if (akRef)
        RPB_Utility.BindAliasTo(apRefAlias, akRef) ; in case there arent any scenes, bind directly
        int id = apRefAlias.GetID()
        JIntMap.setForm(__queuedAliases, id, akRef)
        Debug("SceneManager::BindAlias", "Bound " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") with reference: " + akRef)
    endif

    EventManager.SendWarning("Alias " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") has not been assigned to any reference!", "SceneManager::BindAlias", akRef == none)
endFunction

function RestoreAliases()
    int aliasIds    = JIntMap.allKeys(__queuedAliases)
    int aliasRefs   = JIntMap.allValues(__queuedAliases)

    int i = 0
    while (i < JValue.count(aliasIds))
        int id                 = JArray.getInt(aliasIds, i)
        ObjectReference ref    = JArray.getForm(aliasRefs, i) as ObjectReference

        ReferenceAlias refAlias = self.GetAliasByID(id) as ReferenceAlias
        Debug("SceneManager::RestoreAliases", "Restored " + refAlias.GetName() + " (id: "+ refAlias.GetID() +") with reference: " + ref)

        RPB_Utility.BindAliasTo(refAlias, ref)
        i += 1
    endWhile

    ; Possible ISSUE: Might clear the Aliases of the Scene after the queued scene (3rd Scene in the queue, since the 2nd scene will have the Aliases queued from the first call), needs to be tested
    JIntMap.clear(__queuedAliases)
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

;/
    Returns all of the scene passed parameters as a Form[].
/;
Form[] function GetSceneParameters(string asScene)
    return self.GetSceneRefs(asScene)
endFunction

string function GetSceneParametersDebugInfo(Scene sender, string sceneName, Form[] params)
    string debugInfo = ""
    bool emptyParams = true

    int i = 0
    while (i < params.Length)
        ObjectReference param = params[i] as ObjectReference
        if (param != none)
            string baseId     = "[BaseID: " + param.GetBaseObject().GetFormID() + "] "
            string formId     = "[FormID: " + param.GetFormID() + "] "
            
            string objectBaseName   = param.GetBaseObject().GetName()
            string objectClassName  = param.GetName()
            string whichNameProperty = string_if (objectClassName != "", objectClassName, objectBaseName)
            string objectName = "[Name: " + whichNameProperty + "] "
            emptyParams = false

            debugInfo += "\t["+i+"]: " + param + " " + formId + baseId + string_if (objectName != "[Name: ] ", objectName) + "\n"
        endif
        i += 1
    endWhile
    
    if (emptyParams)
        return sceneName + " " + sender + " - No Parameters, Scene expected: " + params.Length + " parameters!" ; " - No Parameters, Scene expected: need a way to find scene required params
    endif

    return sceneName + " " + sender + "\nParameters: [\n" + debugInfo + "]"
endFunction

event OnSceneStart(string name, Scene sender)
    Form[] params   = self.GetSceneParameters(name)
    string type     = self.GetSceneType(name)

    self.OnSceneStartHandleGlobals(name, params)

    if (type == CATEGORY_ARREST_START)
        Actor escort     = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] arrestees = self.GetSceneRefsOfType(name, "Escortee")

        EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_JAIL)
        Actor escort     = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] arrestees = self.GetSceneRefsOfType(name, "Escortee")

        self.SetGlobal("RPB_Scene_Action_CF01", 1) ; Enables some actions in escort to cell
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_CELL)
        Actor escort     = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_02) ; override
            escort      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
            prisoners   = self.GetSceneRefsOfType(name, "Prisoner")
        endif
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, prisoners, escort)

    elseif (type == CATEGORY_ESCORT_FROM_CELL)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, prisoners, guard)

    elseif (type == CATEGORY_FRISKING)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_FRISK_BEGIN, prisoners, guard)

    elseif (type == CATEGORY_STRIPPING)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")

        string secondaryEvent = string_if (name == SCENE_STRIPPING_02, "Undress to Underwear", "null")

        EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIP_BEGIN, prisoners, guard, secondaryEvent)

    elseif (type == CATEGORY_ELUDING)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Actor eluder     = self.GetSceneRefsOfType(name, "Eluder")[0] as Actor

        EventManager.SendArrestSceneEvent(name, EVENT_ELUDE_BEGIN, eluder, guard, "Dialogue")
    endif

    Debug("SceneManager::OnSceneStart", self.GetSceneParametersDebugInfo(sender, name, params))
    ; Info(self.GetSceneParametersDebugInfo(sender, name, params))
endEvent

event OnScenePlaying(string name, int phaseEvent, int phase, Scene sender)
    string type = self.GetSceneType(name)

    Debug("SceneManager::OnScenePlaying", name + " " + sender + ": " + string_if (phaseEvent == PHASE_START, "(Start)", "(End)") + " Phase " + phase)

    if (type == CATEGORY_ARREST_START)
        Actor escort        = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] arrestees    = self.GetSceneRefsOfType(name, "Escortee")

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
        Actor escort     = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_01)
            if (phase == 7 && phaseEvent == PHASE_START)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Lock Cell")

            elseif (phase == 4 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Unlock Cell")

            elseif (phase == 5 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Release from Captor")
            endif

        elseif (name == SCENE_ESCORT_TO_CELL_02)
            escort      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
            prisoners   = self.GetSceneRefsOfType(name, "Prisoner")

            if (phase == 1 && phaseEvent == PHASE_END)
                ; Make prisoner put their hands behind their back
                OrientRelative(prisoners[0] as Actor, escort, afRotZ = 180)
                Debug.SendAnimationEvent(prisoners[0] as Actor, "ZazAPC001")

            elseif (phase == 2 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Restrain Prisoner")

            elseif (phase == 8 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Lock Cell")
            endif
        endif

    elseif (type == CATEGORY_ESCORT_FROM_CELL)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")

        if (name == SCENE_ESCORT_FROM_CELL)
            if (phase == 1 && phaseEvent == PHASE_END)
                EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORTING, prisoners, guard)
            endif
        endif

    elseif (type == CATEGORY_STRIPPING)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")

        if (name == SCENE_STRIPPING_01)
            EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIPPING, prisoners, guard)

        elseif (name == SCENE_STRIPPING_02)
            EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIPPING, prisoners, guard)

            if (phase == 6 && phaseEvent == PHASE_START) ; Remove Underwear
                
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
        Form[] surrendererCaptors   = self.GetSceneRefsOfType(name, "SurrendererCaptor")
        Actor surrenderer           = self.GetSceneRefsOfType(name, "Surrenderer")[0] as Actor

        if (name == SCENE_SURRENDER_01)
            if (phase == 2 && phaseEvent == PHASE_START)
                EventManager.SendSurrenderSceneEvent(name, EVENT_SURRENDER_BEGIN, surrenderer, none, "null", surrendererCaptors)
            endif
        endif

    elseif (type == CATEGORY_PAY_BOUNTY)
        Actor escort        = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] arrestees    = self.GetSceneRefsOfType(name, "Escortee")

        if (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
            if (phase == 3 && phaseEvent == PHASE_END)
                EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_PAYING_BOUNTY, arrestees, escort, "Hands Behind Back")
            endif
        endif

    elseif (type == CATEGORY_RESTRAIN)
        Actor guard     = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")

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

    if (type == CATEGORY_ARREST_START)
        Actor escort     = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] arrestees = self.GetSceneRefsOfType(name, "Escortee")

        string secondaryEvent = string_if (name == SCENE_ARREST_START_PRISON_01, "Arrest in Prison", "null")

        EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_END, arrestees, escort, secondaryEvent)

    elseif (type == CATEGORY_ESCORT_TO_JAIL)
        Actor escort     = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] arrestees = self.GetSceneRefsOfType(name, "Escortee")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_CELL)
        Actor escort     = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_02) ; override
            escort      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
            prisoners   = self.GetSceneRefsOfType(name, "Prisoner")
        endif
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort)

    elseif (type == CATEGORY_ESCORT_FROM_CELL)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, guard)

    elseif (type == CATEGORY_STRIPPING)
        Actor guard      = self.GetSceneRefsOfType(name, "Guard")[0] as Actor
        Form[] prisoners = self.GetSceneRefsOfType(name, "Prisoner")

        string secondaryEvent = "null"

        if (name == SCENE_STRIPPING_01)
            secondaryEvent = "Restrain Prisoner"
        
        elseif (name == SCENE_FORCED_STRIPPING_01)
            secondaryEvent = "Stand Up (Lie Down)"

        elseif (name == SCENE_FORCED_STRIPPING_02)
            secondaryEvent = "Stand Up (Kneel)"
        endif

        EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIP_END, prisoners, guard, secondaryEvent)

    elseif (type == CATEGORY_SURRENDER)
        Actor surrendererCaptor = self.GetSceneRefsOfType(name, "SurrendererCaptor")[0] as Actor
        Actor surrenderer       = self.GetSceneRefsOfType(name, "Surrenderer")[0] as Actor

        EventManager.SendSurrenderSceneEvent(name, EVENT_SURRENDER_END, surrenderer, surrendererCaptor)

    elseif (type == CATEGORY_PAY_BOUNTY)
        Actor escort   = self.GetSceneRefsOfType(name, "Escort")[0] as Actor
        Actor escortee = self.GetSceneRefsOfType(name, "Escortee")[0] as Actor

        string secondaryEvent = "null"

        if (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
            secondaryEvent = "Follow Willingly"
        
        elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
            secondaryEvent = "Escort by Force"
        endif

        EventManager.SendArrestSceneEvent(name, EVENT_ARREST_PAY_BOUNTY_END, escortee, escort, secondaryEvent)
    endif

    self.ResetSceneOverride()

    Form[] params = self.GetSceneParameters(name)
    Debug("SceneManager::OnSceneEnd", self.GetSceneParametersDebugInfo(sender, name, params))
    ; Info(self.GetSceneParametersDebugInfo(sender, name, params))

    self.UnbindAliases(name)
    self.PlayQueued()
    __isScenePlaying = false ; Scene has finished playing
    self.ResetGlobals()
    self.OnResumeSceneBlocked()
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
    BindAlias(self.GetEscort(), akEscortLeader)

    ; Bind the prisoner to its alias to be escorted
    BindAlias(self.GetEscortee(), akEscortedPrisoner)

    ; BindAlias(self.GetEscortee(1), self.GetPrisoner(1).GetReference()) ; TODO: Support for multiple Actor arrest/escorting

    ; Bind the prisoner's destination point, the jail cell
    BindAlias(self.GetPrisonerLocation(), akJailCellMarker)

    ; Bind the the jail cell door
    BindAlias(self.GetCellDoor(), akJailCellDoor)

    ObjectReference waitingEscortMarker = akEscortWaitingMarker
    if (waitingEscortMarker == none)
        waitingEscortMarker = akJailCellDoor
    endif

    ; Bind the guard waiting marker
    BindAlias(self.GetGuardLocation(), waitingEscortMarker)

    self.QueueOrPlay(SCENE_ESCORT_TO_CELL_01)
    ; self.GetScene(SCENE_ESCORT_TO_CELL_01).Start()
    ; EscortToCell.Start()
endFunction

function StartEscortToCell_02(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, ObjectReference akJailCellDoor, ObjectReference akEscortWaitingMarker)
    ; Bind the captor to its alias to lead the escort scene
    BindAlias(self.GetGuard(), akEscortLeader)

    ; Bind the prisoner to its alias to be escorted
    BindAlias(self.GetPrisoner(), akEscortedPrisoner)

    ; Bind the prisoner's destination point, the jail cell
    BindAlias(self.GetCell(), akJailCellMarker)

    ; Bind the guard's destination point, the jail cell door
    BindAlias(self.GetCellDoor(), akJailCellDoor)

    ObjectReference waitingEscortMarker = akEscortWaitingMarker
    ; if (waitingEscortMarker == none)
    ;     waitingEscortMarker = akJailCellDoor
    ; endif
    
    ; Bind the guard waiting marker
    BindAlias(self.GetGuardLocation(), waitingEscortMarker)

    self.QueueOrPlay(SCENE_ESCORT_TO_CELL_02)
    ; self.GetScene(SCENE_ESCORT_TO_CELL_02).Start()
    ; EscortToCell_02.Start()
endFunction

function StartEscortFromCell(Actor akGuard, Actor akPrisoner, ObjectReference akJailCellDoor, ObjectReference akJailChest)
    Debug("SceneManager::StartEscortFromCell", "Starting Scene " + self.GetScene(SCENE_ESCORT_FROM_CELL) +", params: ["+ akGuard + "," + akPrisoner + "," + akJailCellDoor + "," + akJailChest + "]")
    ; Bind the captor to its alias to lead the escort scene
    BindAlias(self.GetGuard(), akGuard)

    ; Bind the prisoner to its alias to be escorted
    BindAlias(self.GetPrisoner(), akPrisoner)

    BindAlias(self.GetPrisonerLocation(), akJailChest)

    BindAlias(self.GetGuardLocation(), akJailCellDoor)

    self.QueueOrPlay(SCENE_ESCORT_FROM_CELL)
    ; self.GetScene(SCENE_ESCORT_FROM_CELL).Start()
    ; EscortFromCell.Start()
endFunction

function StartEscortToJail(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akPrisonerChest)
    ; Bind the captor to its alias to lead the escort scene
    BindAlias(self.GetEscort(), akEscortLeader)
    ; BindAlias(self.GetEscortee(1), GetNearestActor(akEscortedPrisoner, 9000))
    ; BindAlias(self.GetEscortee(2), GetNearestActor(akEscortedPrisoner, 9000))

    ; Bind the prisoner to its alias to be escorted
    BindAlias(self.GetEscortee(), akEscortedPrisoner)

    ; Bind the destination point, the chest
    BindAlias(self.GetPrisonerLocation(), akPrisonerChest)

    ; Bind the guard's destination point, the jail cell door
    BindAlias(self.GetGuardLocation(), akPrisonerChest)

    self.QueueOrPlay(SCENE_ESCORT_TO_JAIL_01)
    ; self.GetScene(SCENE_ESCORT_TO_JAIL_01).Start()
    ; EscortToJail.Start()
endFunction

function StartMultipleEscortsToJail(Actor akEscortLeader, Actor[] akEscortedPrisoners, ObjectReference akPrisonerChest)
    ; Bind the leader to its alias to lead the escort scene
    BindAlias(self.GetEscort(), akEscortLeader)

    ; Bind the prisoners to their aliases to be escorted
    int i = 0
    while (i < akEscortedPrisoners.Length)
        BindAlias(self.GetAliasByName("Escortee" + i) as ReferenceAlias, akEscortedPrisoners[i])
        i += 1
    endWhile

    ; Bind the destination point, the chest
    BindAlias(self.GetPrisonerLocation(), akPrisonerChest)

    ; Bind the destination point, the chest
    BindAlias(self.GetGuardLocation(), akPrisonerChest)
endFunction

function StartStrippingStart(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAlias(self.GetGuard(), akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAlias(self.GetPrisoner(), akStrippedPrisoner)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAlias(self.GetPrisoner(1), self.GetEscortee(1).GetActorReference())
    BindAlias(self.GetPrisoner(2), self.GetEscortee(2).GetActorReference())
    BindAlias(self.GetPrisoner(3), self.GetEscortee(3).GetActorReference())

    self.QueueOrPlay(SCENE_STRIPPING_START_01)
    ; self.GetScene(SCENE_STRIPPING_START_01).Start()

    ; StrippingStart.Start()
endFunction

function StartStripping(Actor akStripperGuard, Actor akStrippedPrisoner)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAlias(self.GetGuard(), akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAlias(self.GetPrisoner(), akStrippedPrisoner)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAlias(self.GetPrisoner(1), self.GetEscortee(1).GetActorReference())
    BindAlias(self.GetPrisoner(2), self.GetEscortee(2).GetActorReference())

    self.QueueOrPlay(SCENE_STRIPPING_01)
    ; self.GetScene(SCENE_STRIPPING_01).Start()
    ; Stripping.Start()
endFunction

function StartStripping_02(Actor akStripperGuard, Actor akStrippedPrisoner, ObjectReference akStripMarker = none)
    ; Bind the guard to be the one performing the strip search / undressing
    BindAlias(self.GetGuard(), akStripperGuard)

    ; Bind the Prisoner to be the actor being strip searched / undressed
    BindAlias(self.GetPrisoner(), akStrippedPrisoner)

    BindAlias(self.GetGuardLocation(), akStripMarker)
    BindAlias(self.GetPrisonerLocation(), akStripMarker)

    ; Bind the other Prisoners to also be strip searched / undressed
    BindAlias(self.GetPrisoner(1), self.GetEscortee(1).GetActorReference())
    BindAlias(self.GetPrisoner(2), self.GetEscortee(2).GetActorReference())

    self.QueueOrPlay(SCENE_STRIPPING_02)
    ; self.GetScene(SCENE_STRIPPING_02).Start()
    ; Stripping_02.Start()
endFunction

function StartFrisking(Actor akFriskerGuard, Actor akFriskedPrisoner)
    ; Bind the guard to be the one performing the frisk search
    BindAlias(self.GetGuard(), akFriskerGuard)

    ; Bind the Prisoner to be the actor being frisk searched
    BindAlias(self.GetPrisoner(), akFriskedPrisoner)

    self.QueueOrPlay(SCENE_FRISKING)
    ; self.GetScene(SCENE_FRISKING).Start()
    ; Frisking.Start()
endFunction

function StartGiveClothing(Actor akGuard, Actor akPrisoner)
    ; Bind the guard to be the one giving clothing
    BindAlias(self.GetGuard(), akGuard)

    ; Bind the Prisoner to be the actor being given clothing
    BindAlias(self.GetPrisoner(), akPrisoner)

    self.QueueOrPlay(SCENE_GIVE_CLOTHING)
    ; self.GetScene(SCENE_GIVE_CLOTHING).Start()
    ; GiveClothing.Start()
endFunction

function StartUnlockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAlias(self.GetEscort(), akGuard)
    BindAlias(self.GetGuardLocation(), akJailCellDoor)

    ; UnlockCell.Start()
endFunction

function StartLockDoor(Actor akGuard, ObjectReference akJailCellDoor)
    BindAlias(self.GetEscort(), akGuard)
    BindAlias(self.GetGuardLocation(), akJailCellDoor)

    ; LockCell.Start()
endFunction

function StartBountyPaymentFail(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAlias(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's trying to pay the bounty
    BindAlias(self.GetPrisoner(), akPrisoner)

    self.QueueOrPlay(SCENE_PAYMENT_FAIL)
    ; self.GetScene(SCENE_PAYMENT_FAIL).Start()
    ; BountyPaymentFail.Start()
endFunction

function StartArrestStart01(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAlias(self.GetEscort(), akGuard)

    ; Bind the Prisoner, who's getting arrested
    BindAlias(self.GetEscortee(), akPrisoner)

    ; ArrestStart01.Start()

    self.QueueOrPlay(SCENE_ARREST_START_01)
    ; self.GetScene(SCENE_ARREST_START_01).Start()
endFunction

function StartArrestStart02(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAlias(self.GetEscort(), akGuard)

    ; Bind the Prisoner, who's getting arrested
    BindAlias(self.GetEscortee(), akPrisoner)

    self.QueueOrPlay(SCENE_ARREST_START_02)
    ; self.GetScene(SCENE_ARREST_START_02).Start()
    ; ArrestStart02.Start()
endFunction

function StartArrestStart03(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAlias(self.GetEscort(), akGuard)

    ; Bind the Prisoner, who's getting arrested
    BindAlias(self.GetEscortee(), akPrisoner)

    self.QueueOrPlay(SCENE_ARREST_START_03)
    ; self.GetScene(SCENE_ARREST_START_03).Start()
endFunction

function StartArrestStart04(Actor akGuard, Actor akPrisoner)
    ; Bind the captor
    BindAlias(self.GetCaptor(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAlias(self.GetArrestee(), akPrisoner)

    self.QueueOrPlay(SCENE_ARREST_START_04)
    ; self.GetScene(SCENE_ARREST_START_04).Start()
    ; ArrestStart04.Start()
endFunction

function StartSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors, string asScene)
    BindAlias(self.GetSurrenderer(), akSurrenderer)

    int i = 0
    while (i < akSurrendererCaptors.Length)
        BindAlias(self.GetSurrendererCaptor(i), akSurrendererCaptors[i])
        i += 1
    endWhile
    
    ; self.StartScene(asScene, 0)
    self.QueueOrPlay(asScene)
endFunction

function StartArrestScene(Actor akGuard, Actor akArrestee, string asScene)
    ; Bind the captor
    BindAlias(self.GetEscort(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAlias(self.GetEscortee(), akArrestee)
    
    self.QueueOrPlay(asScene)
    ; self.GetScene(asScene).Start()
endFunction

function StartEscortToJailScene(Actor akGuard, Actor akArrestee, string asScene)
    ; Bind the captor
    BindAlias(self.GetEscort(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAlias(self.GetEscortee(), akArrestee)

    self.QueueOrPlay(asScene)
    ; self.GetScene(asScene).Start()
endFunction

function StartArrestStartPrison_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    ; Bind the captor
    BindAlias(self.GetEscort(), akGuard)

    ; Bind the Arrestee, who's getting arrested
    BindAlias(self.GetEscortee(), akPrisoner)

    self.StartSceneAtPhase(aiStartingPhase)
    ; self.GetScene(SCENE_ARREST_START_PRISON_01).Start()
    self.QueueOrPlay(SCENE_ARREST_START_PRISON_01)
endFunction

function StartRestrainPrisoner_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    BindAlias(self.GetGuard(), akGuard)
    BindAlias(self.GetPrisoner(), akPrisoner)

    self.StartSceneAtPhase(aiStartingPhase)
    ; self.GetScene(SCENE_RESTRAIN_PRISONER_01).Start()
    self.QueueOrPlay(SCENE_RESTRAIN_PRISONER_01)

endFunction

function StartRestrainPrisoner_02(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
    BindAlias(self.GetGuard(), akGuard)
    BindAlias(self.GetPrisoner(), akPrisoner)

    self.StartSceneAtPhase(aiStartingPhase)
    ; self.GetScene(SCENE_RESTRAIN_PRISONER_02).Start()
    self.QueueOrPlay(SCENE_RESTRAIN_PRISONER_02)
endFunction

function StartNoClothing(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAlias(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's undressed and given no clothing
    BindAlias(self.GetPrisoner(), akPrisoner)

    self.QueueOrPlay(SCENE_NO_CLOTHING)
    ; self.GetScene(SCENE_NO_CLOTHING).Start()
    ; NoClothing.Start()
endFunction

function StartForcedStripping(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAlias(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's about to be stripped
    BindAlias(self.GetPrisoner(), akPrisoner)
    
    self.QueueOrPlay(SCENE_FORCED_STRIPPING_01)
    ; self.GetScene(SCENE_FORCED_STRIPPING_01).Start()
    ; ForcedStripping01.Start()
endFunction

function StartForcedStripping02(Actor akGuard, Actor akPrisoner)
    ; Bind the guard
    BindAlias(self.GetGuard(), akGuard)

    ; Bind the Prisoner, who's about to be stripped
    BindAlias(self.GetPrisoner(), akPrisoner)

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
    BindAlias(self.GetGuard(), akGuard)

    ; Bind the Eluder, who is eluding arrest
    BindAlias(self.GetEluder(), akEluder)

    Debug("SceneManager::StartEludingArrest", "Scene: "+ self.GetScene(SCENE_ELUDING_ARREST_01) +" Params ["+ akGuard + ", " + akEluder + "] | Aliases: ["+ self.GetGuard() + ", " + self.GetEluder() + "]")

    self.QueueOrPlay(SCENE_ELUDING_ARREST_01)
    ; self.GetScene(SCENE_ELUDING_ARREST_01).Start()
    ; EludingArrest.Start()
endFunction

function StartArrestBountyPaymentFollowWillingly(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    BindAlias(self.GetEscort(), akEscort)
    BindAlias(self.GetEscortee(), akEscortee)
    BindAlias(self.GetGuardLocation(), akEscortLocation)
    BindAlias(self.GetPrisonerLocation(), akEscortLocation)

    self.QueueOrPlay(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
    ; self.GetScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY).Start()
endFunction

function StartArrestPayBountyFollowByForce(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
    BindAlias(self.GetEscort(), akEscort)
    BindAlias(self.GetEscortee(), akEscortee)
    BindAlias(self.GetGuardLocation(), akEscortLocation)
    BindAlias(self.GetPrisonerLocation(), akEscortLocation)

    self.QueueOrPlay(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
    ; self.GetScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE).Start()
endFunction