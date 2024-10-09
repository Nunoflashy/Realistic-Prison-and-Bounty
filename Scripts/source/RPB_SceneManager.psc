; scriptname RPB_SceneManager extends Quest

; import RPB_Config
; import RPB_Utility
; import RPB_Memory

; ; ==========================================================
; ;                      Script References
; ; ==========================================================

; RPB_API __api
; RPB_API property API
;     RPB_API function get()
;         if (__api)
;             return __api
;         endif

;         __api = RPB_API.GetSelf()
;         return __api
;     endFunction
; endProperty

; RPB_Config property Config
;     RPB_Config function get()
;         return API.Config
;     endFunction
; endProperty

; RPB_EventManager property EventManager
;     RPB_EventManager function get()
;         return API.EventManager
;     endFunction
; endProperty

; ; ==========================================================
; ;                            Init
; ; ==========================================================

; int __globalDefaults    ; JMap&
; int __globals           ; JMap&
; int __sceneContainer    ; JMap&
; int __sceneToCategory   ; JMap&
; int __sceneConfig       ; JMap&

; function SceneManager()
;     int map = RPB_Memory.Map("<string, Map<int, int[][]>>")
;     ; RPB_Memory.Get(map, "[ 'key', 1 ]") ; R: Object<int[][]>
;     ; RPB_Memory.Set(map, "[ 'key', 1 ], [[4, 10], [2, 4]]")
; endFunction

; function __allocateMemory()
;     ; __sceneContainer    = objectNotExists(__sceneContainer,  FastMap(retain = true))
;     ; __sceneToCategory   = objectNotExists(__sceneToCategory, FastMap(retain = true))
;     ; __sceneConfig       = objectNotExists(__sceneConfig,     FastMap(retain = true))
;     ; __globals           = objectNotExists(__globals,         FastMap(retain = true))
;     ; __globalDefaults    = objectNotExists(__globalDefaults,  FastMap(retain = true))

;     if (!__sceneContainer)
;         __sceneContainer = JMap.object()
;         JValue.retain(__sceneContainer, "SceneManager")
;     endif

;     if (!__sceneToCategory)
;         __sceneToCategory = JMap.object()
;         JValue.retain(__sceneToCategory, "SceneManager")
;     endif

;     if (!__sceneConfig)
;         __sceneConfig = JMap.object()
;         JValue.retain(__sceneConfig, "SceneManager")
;     endif

;     __sceneConfig = delete(__sceneConfig)
;     __sceneConfig = Object_CreateIfNotExists(__sceneConfig, Map("<string>"))
;     JValue.retain(__sceneConfig, "SceneManager")

;     Debug("SceneManager::AllocateMemory", "Object: " + GetContainerList(__sceneConfig))

;     if (!__globals)
;         __globals = JMap.object()
;         JValue.retain(__globals, "SceneManager")
;     endif

;     if (!__globalDefaults)
;         __globalDefaults = JMap.object()
;         JValue.retain(__globalDefaults, "SceneManager")
;     endif
; endFunction

; function __deallocateMemory()
;     JValue.releaseObjectsWithTag("SceneManager")
; endFunction

; function Initialize()
;     __allocateMemory()
;     self.SetupGlobals()
;     self.SetupScenes()

;     float sceneConfigBench = StartBenchmark()
;     self.CreateSceneConfig()
;     EndBenchmark(sceneConfigBench, "SceneManager::CreateSceneConfig")
; endFunction

; ; ==========================================================
; ;                          Globals
; ; ==========================================================

; int property GlobalCount
;     int function get()
;         return JValue.count(__globals)
;     endFunction
; endProperty

; function AddGlobal(string asGlobalName, int aiGlobalFormID, int aiDefaultValue = 0)
;     ; RPB_Memory.Set(map, "['Globals'], { 'asGlobalName': aiGlobalFormID }")
;     ; RPB_Memory.Set(map, "['GlobalDefaults'], { 'asGlobalName': aiDefaultValue }")
;     JMap.setInt(__globals, asGlobalName, aiGlobalFormID)
;     JMap.setInt(__globalDefaults, asGlobalName, aiDefaultValue)
; endFunction

; bool function HasGlobal(string asGlobal)
;     return JMap.hasKey(__globals, asGlobal)
; endFunction

; GlobalVariable function GetGlobal(string asGlobal)
;     if (!self.HasGlobal(asGlobal))
;         return none
;     endif

;     int globalFormId = JMap.getInt(__globals, asGlobal)
;     return GetFormFromMod(globalFormId) as GlobalVariable
; endFunction

; function SetGlobal(string asGlobal, int aiValue)
;     GlobalVariable g = self.GetGlobal(asGlobal)

;     if (g)
;         g.SetValueInt(aiValue)
;         Debug("SceneManager::SetGlobal", "Setting Global " + asGlobal + " to " + aiValue)
;     endif
; endFunction

; function ResetGlobal(string asGlobal)
;     GlobalVariable g = self.GetGlobal(asGlobal)

;     if (g)
;         int defaultValue = JMap.getInt(__globalDefaults, asGlobal)
;         g.SetValueInt(defaultValue)
;     endif
; endFunction

; function SetupGlobals()
;     ; Control Flow - Scene Dialogue
;     self.AddGlobal("RPB_Scene_Dialogue_CF01", 0x264B5)
;     self.AddGlobal("RPB_Scene_Dialogue_CF02", 0x264B6)
;     self.AddGlobal("RPB_Scene_Dialogue_CF03", 0x264B7)
;     self.AddGlobal("RPB_Scene_Dialogue_CF04", 0x264B8)
;     self.AddGlobal("RPB_Scene_Dialogue_CF05", 0x264B9)
;     self.AddGlobal("RPB_Scene_Dialogue_CF06", 0x264BA)
;     self.AddGlobal("RPB_Scene_Dialogue_CF07", 0x264BB)
;     self.AddGlobal("RPB_Scene_Dialogue_CF08", 0x264BC)
;     self.AddGlobal("RPB_Scene_Dialogue_CF09", 0x264BD)
;     self.AddGlobal("RPB_Scene_Dialogue_CF10", 0x264BE)
;     self.AddGlobal("RPB_Scene_Dialogue_CF11", 0x264BF)

;     ; Control Flow - Scene Actions
;     self.AddGlobal("RPB_Scene_Action_CF01", 0x264C0)
;     self.AddGlobal("RPB_Scene_Action_CF02", 0x264C1)
;     self.AddGlobal("RPB_Scene_Action_CF03", 0x264C2)
;     self.AddGlobal("RPB_Scene_Action_CF04", 0x264C3)
;     self.AddGlobal("RPB_Scene_Action_CF05", 0x264C4)
;     self.AddGlobal("RPB_Scene_Action_CF06", 0x264C5)
;     self.AddGlobal("RPB_Scene_Action_CF07", 0x264C6)
;     self.AddGlobal("RPB_Scene_Action_CF08", 0x264C7)
;     self.AddGlobal("RPB_Scene_Action_CF09", 0x264C8)
;     self.AddGlobal("RPB_Scene_Action_CF10", 0x264C9)
;     self.AddGlobal("RPB_Scene_Action_CF11", 0x264CA)
; endFunction

; function ResetGlobals()
;     int i = 0
;     int globalKeys = JMap.allKeys(__globals)

;     while (i < GlobalCount)
;         string globalKey = JArray.getStr(globalKeys, i)
;         int defaultValue = JMap.getInt(__globalDefaults, globalKey)
;         self.GetGlobal(globalKey).SetValueInt(defaultValue)
;         i += 1
;     endWhile

;     Debug("SceneManager::ResetGlobals", "Scene Globals have been reset to their default values.")
; endFunction

; ; ==========================================================
; ;                   Scene Phase Overriding
; ; ==========================================================

; GlobalVariable property RPB_SceneBlockNormalExecution
;     GlobalVariable function get()
;         return GetFormFromMod(0x14C3A) as GlobalVariable
;     endFunction
; endProperty

; GlobalVariable property RPB_SceneStartAtPhase
;     GlobalVariable function get()
;         return GetFormFromMod(0x14C39) as GlobalVariable
;     endFunction
; endProperty

; function StartSceneAtPhase(int phase)
;     RPB_SceneBlockNormalExecution.SetValueInt(1)
;     RPB_SceneStartAtPhase.SetValueInt(phase)
; endFunction

; function ResetSceneOverride()
;     RPB_SceneBlockNormalExecution.SetValueInt(0)
;     RPB_SceneStartAtPhase.SetValueInt(0)
; endFunction

; ; ==========================================================
; ;                    Scene Block Handling
; ; ==========================================================

; ; Right now only releases the AI for Scenes that retain it, however in some instances we actually want to release it,
; ; so this is here as a workaround. Later it should handle more things related to End of scene blocking.
; bool __resumeSceneBlocked
; function ResumeSceneBlocked()
;     __resumeSceneBlocked = true
; endFunction

; event OnResumeSceneBlocked()
;     string lastScene = JArray.getStr(__queuedScenes, -1) ; needs to be revised, returning empty, however it works for now
;     Debug("SceneManager::OnResumeSceneBlocked", "ResumeSceneBlocked: " + __resumeSceneBlocked + ", Current Scene: " + currentScene + ", Last Scene: " + lastScene + ", Condition: " + (currentScene == lastScene))
;     if (__resumeSceneBlocked && currentScene == lastScene)
;         ReleaseAI()
;         __resumeSceneBlocked = false
;     endif
; endEvent

; ; ==========================================================
; ;                           Scenes
; ; ==========================================================

; int property SceneCount
;     int function get()
;         return JValue.count(__sceneContainer)
;     endFunction
; endProperty

; function AddScene(string asSceneName, int aiSceneFormID, string asSceneCategory = "null")
;     JMap.setInt(__sceneContainer, asSceneName, aiSceneFormID)
;     ; Map_SetInt(__sceneContainer, asSceneName, aiSceneFormID)

;     if (asSceneCategory != "null")
;         ; Map_SetString(__sceneToCategory, asSceneName, asSceneCategory)
;         JMap.setStr(__sceneToCategory, asSceneName, asSceneCategory)
;     endif
; endFunction

; string function GetSceneNameByIndex(int aiIndex)
;     return JMap.getNthKey(__sceneContainer, aiIndex)
; endFunction

; int function GetSceneFormID(string asSceneName)
;     return JMap.getInt(__sceneContainer, asSceneName)
; endFunction

; string function GetSceneNameByFormID(int aiSceneFormID)
;     return JMap.getStr(__sceneContainer, aiSceneFormID)
; endFunction

; bool function SceneExists(string asSceneName)
;     return JMap.hasKey(__sceneContainer, asSceneName)
; endFunction

; ;/
;     Checks if a given Scene is of the specified type (category).

;     string  @asSceneName: The name of the Scene.
;     string  @asCategory: The category of which the Scene should be a part of.
; /;
; bool function IsSceneOfType(string asSceneName, string asCategory)
;     return JMap.getStr(__sceneToCategory, asSceneName) == asCategory
; endFunction

; string function GetSceneType(string asSceneName)
;     return JMap.getStr(__sceneToCategory, asSceneName)
; endFunction

; function SetupScenes()
;     self.AddScene(SCENE_ARREST_START_01,                        0xF569, CATEGORY_ARREST_START)      ; Arrest Start 01
;     self.AddScene(SCENE_ARREST_START_02,                        0xFAF6, CATEGORY_ARREST_START)      ; Arrest Start 02
;     self.AddScene(SCENE_ARREST_START_03,                        0x130DD, CATEGORY_ARREST_START)     ; Arrest Start 03
;     self.AddScene(SCENE_ARREST_START_04,                        0x13663, CATEGORY_ARREST_START)     ; Arrest Start 04
;     self.AddScene(SCENE_ARREST_START_PRISON_01,                 0x14C14, CATEGORY_ARREST_START)     ; Arrest Start Prison 01
;     self.AddScene(SCENE_SURRENDER_01,                           0x26A2F, CATEGORY_SURRENDER)        ; Surrender 01
;     self.AddScene(SCENE_ESCORT_TO_JAIL_01,                      0xF532, CATEGORY_ESCORT_TO_JAIL)    ; Escort to Jail
;     self.AddScene(SCENE_ESCORT_TO_JAIL_02,                      0x17CDA, CATEGORY_ESCORT_TO_JAIL)   ; Escort to Jail 02
;     self.AddScene(SCENE_ESCORT_TO_CELL_01,                      0xCF58, CATEGORY_ESCORT_TO_CELL)    ; Escort to Cell 01
;     self.AddScene(SCENE_ESCORT_TO_CELL_02,                      0x1367D, CATEGORY_ESCORT_TO_CELL)   ; Escort to Cell 02
;     self.AddScene(SCENE_ESCORT_FROM_CELL,                       0x115E6, CATEGORY_ESCORT_FROM_CELL) ; Escort from Cell
;     ; self.AddScene(SCENE_SEARCH_START,                         0xF55C)     ; SearchStart
;     self.AddScene(SCENE_FRISKING,                               0xCF5A, CATEGORY_FRISKING)          ; Frisking
;     self.AddScene(SCENE_STRIPPING_START_01,                     0xF561, CATEGORY_STRIPPING)         ; Stripping Start
;     self.AddScene(SCENE_STRIPPING_01,                           0xCF59, CATEGORY_STRIPPING)         ; Stripping
;     self.AddScene(SCENE_STRIPPING_02,                           0xEA60, CATEGORY_STRIPPING)         ; Stripping 02
;     self.AddScene(SCENE_FORCED_STRIPPING_01,                    0xF587, CATEGORY_STRIPPING)         ; Forced Stripping 01
;     self.AddScene(SCENE_FORCED_STRIPPING_02,                    0x120A9, CATEGORY_STRIPPING)        ; Forced Stripping 02
;     self.AddScene(SCENE_GIVE_CLOTHING,                          0xF52A, CATEGORY_CLOTHING)          ; Give Clothing
;     self.AddScene(SCENE_NO_CLOTHING,                            0xF571, CATEGORY_NO_CLOTHING)       ; No Clothing
;     self.AddScene(SCENE_PAYMENT_FAIL,                           0xF54E, CATEGORY_PAYMENT_FAIL)      ; Bounty Payment Fail
;     self.AddScene(SCENE_ELUDING_ARREST_01,                      0x12613, CATEGORY_ELUDING)          ; Eluding Arrest
;     self.AddScene(SCENE_RESTRAIN_PRISONER_01,                   0x15702, CATEGORY_RESTRAIN)         ; Restrain Prisoner 01
;     self.AddScene(SCENE_RESTRAIN_PRISONER_02,                   0x15C66, CATEGORY_RESTRAIN)         ; Restrain Prisoner 02
;     self.AddScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY,     0x1776B, CATEGORY_PAY_BOUNTY)       ; Pay Bounty Follow Willingly
;     self.AddScene(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE,      0x1776E, CATEGORY_PAY_BOUNTY)       ; Pay Bounty Follow By Force

;     string sceneListAsString = ""
;     int i = 0
;     while (i < SceneCount)
;         ; sceneListAsString += "\t["+i+"]: "+ JMap.getNthKey(__sceneContainer, i) +"\n"
;         sceneListAsString += "\t["+i+"]: "+ self.GetSceneNameByIndex(i) +"\n"
;         i += 1
;     endWhile

;     Debug("SceneManager::SetupScenes", "Loaded "+ SceneCount +" Scenes: [\n" + sceneListAsString + "]")
; endFunction

; function CreateSceneRefTypeConfig(string asScene, string asRefType, int[] akSceneAliasCount)
;     bool sceneExists = Map_HasKey(__sceneConfig, asScene)

;     if (!sceneExists)
;         Map_SetObject(__sceneConfig, asScene, JMap.object())
;     endif

;     int sceneRefTypesObj = Map_GetObject(__sceneConfig, asScene)

;     if (!sceneRefTypesObj)
;         EventManager.SendError("Cannot create the scene config for scene " + asScene + " (object does not exist!)", "SceneManager::CreateSceneRefTypeConfig")
;         return
;     endif

;     ; Debug("SceneManager::CreateSceneRefTypeConfig", asScene + ": " + GetContainerList(sceneRefTypesObj))

;     ; Get Alias ID from the specified config
;     int aliasCount = akSceneAliasCount[0]
;     int startIndex = akSceneAliasCount[1]

;     int aliasIds = Array("<int>")

;     int i = 0
;     while (i < (aliasCount - startIndex))
;         ReferenceAlias a = self.GetRefAlias(asRefType, i)
;         if (a)
;             int aliasId = a.GetID()
;             if (JArray.findInt(aliasIds, aliasId) == -1)
;                 JArray.addInt(aliasIds, aliasId)
;             endif
;         endif
;         i += 1
;     endWhile

;     ; string args = "asScene: " + asScene + ", asRefType: " + asRefType + ", akSceneAliasCount: " + akSceneAliasCount
;     ; DebugWithArgs("SceneManager::CreateSceneRefTypeConfig", args, asRefType + ": " + GetContainerList(aliasIds))

;     Map_SetObject(sceneRefTypesObj, asRefType, aliasIds)
; endFunction

; ;/
;     Creates a nested structure that contains a Scene's configuration related to
;     their ReferenceAliases information.
; /;
; ; function CreateSceneRefTypeConfig(string asScene, string asRefType, int[] akSceneAliasCount)
; ;     bool sceneExists = JMap.hasKey(__sceneConfig, asScene)

; ;     if (!sceneExists)
; ;         JMap.setObj(__sceneConfig, asScene, JMap.object())
; ;     endif

; ;     int sceneRefTypesObj = JMap.getObj(__sceneConfig, asScene)

; ;     if (!sceneRefTypesObj)
; ;         EventManager.SendError("Cannot create the scene config for scene " + asScene + " (object does not exist!)", "SceneManager::CreateSceneRefTypeConfig")
; ;         return
; ;     endif

; ;     ; Debug("SceneManager::CreateSceneRefTypeConfig", asScene + ": " + GetContainerList(sceneRefTypesObj))

; ;     ; Get Alias ID from the specified config
; ;     int aliasCount = akSceneAliasCount[0]
; ;     int startIndex = akSceneAliasCount[1]

; ;     int aliasIds = JArray.object()

; ;     int i = 0
; ;     while (i < (aliasCount - startIndex))
; ;         ReferenceAlias a = self.GetRefAlias(asRefType, i)
; ;         if (a)
; ;             int aliasId = a.GetID()
; ;             if (JArray.findInt(aliasIds, aliasId) == -1)
; ;                 JArray.addInt(aliasIds, aliasId)
; ;             endif
; ;         endif
; ;         i += 1
; ;     endWhile

; ;     ; string args = "asScene: " + asScene + ", asRefType: " + asRefType + ", akSceneAliasCount: " + akSceneAliasCount
; ;     ; DebugWithArgs("SceneManager::CreateSceneRefTypeConfig", args, asRefType + ": " + GetContainerList(aliasIds))

; ;     JMap.setObj(sceneRefTypesObj, asRefType, aliasIds)
; ; endFunction

; function CacheSceneRefType(string asScene, string asRefType, int aiRefTypeIndex, int aiRefTypeID)
;     ; int map = object("map<string, map<int, int>>")
; endFunction

; ; TODO: Invalidate non existant aliases
; ;/
;     Goal is to solve this problem:
;     Parameters: [
;         [0]: [RPB_CellDoor < (0005E924)>] [FormID: 387364] [BaseID: 387357] [Name: Door] 
;         [1]: [Actor < (0010C06D)>] [FormID: 1097837] [BaseID: 1097832] [Name: Imperial Soldier] 
;         [2]: [Actor < (00000014)>] [FormID: 20] [BaseID: 7] [Name: Prisoner] 
;         [3]: [Actor < (0010C06D)>] [FormID: 1097837] [BaseID: 1097832] [Name: Imperial Soldier] 
;         [4]: [ObjectReference < (3401DDE1)>] [FormID: 872537569] [BaseID: 59] 
;         [5]: [RPB_JailCell < (34003883)>] [FormID: 872429699] [BaseID: 59] [Name: Jail Cell] 
;     ]

;     Here [3] is a Ref Type ExteriorCell, which does not exist and is converted to 0 (false),
;     Since there's a ReferenceAlias with ID 0 ([1] in this example), it gets set to that and finds the Reference bound to it,
;     hence the duplication of [1] and [3].
; /;
; function InvalidateSceneAliases(string asScene, string asRefType)
;     ; Rough implementation:
;     ; Validate and remove invalid RefAlias IDs
;     int obj = JMap.getObj(__sceneConfig, asScene)
;     int refTypes = JMap.allKeys(obj)

;     int keyIndex = 0
;     while (keyIndex < JValue.count(refTypes))
;         string refTypeName = JArray.getStr(refTypes, keyIndex)
;         int refTypeIds = JMap.getObj(obj, refTypeName) ; JArray&

;         int valueIndex = 0
;         while (valueIndex < JValue.count(refTypeIds))
;             int id = JArray.getInt(refTypeIds, valueIndex)
;             Alias a = self.GetAliasByID(id)
;             if (!a || (refTypeName != a.GetName()))
;                 Debug("SceneManager::GetSceneRefTypesConfig", "Validating and removing ["+ valueIndex +"] (id: "+ id +") (Ref Type: "+ refTypeName +"), alias does not exist!")
;                 JArray.eraseIndex(refTypeIds, valueIndex)
;             endif
;             valueIndex += 1
;         endWhile

;         keyIndex += 1
;     endWhile
; endFunction

; function RemoveSceneRefType(string asScene, string asRefType)
;     int sceneRefTypeMap = JMap.getObj(__sceneConfig, asScene)

;     if (JMap.hasKey(sceneRefTypeMap, asRefType))
;         JMap.removeKey(sceneRefTypeMap, asRefType)
;     endif
; endFunction

; int function GetSceneRefTypesConfig(string asScene)
;     return JMap.getObj(__sceneConfig, asScene) ; JMap&
; endFunction

; int function GetSceneRefsOfTypeObject(string asScene, string asRefType)
;     int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene)
;     return JMap.getObj(specifiedSceneConfig, asRefType) ; JArray<int>&
; endFunction

; Alias[] function GetSceneAliasesOfType(string asScene, string asRefType, bool abOnlyIncludeAliasesInUse = false)
;     int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; JArray&
;     int arrLen      = JValue.count(refsOfType)
    
;     Alias[] aliasArr = Utility.CreateAliasArray(arrLen)
 
;     int i = 0
;     while (i < arrLen)
;         int id = JArray.getInt(refsOfType, i)
;         Alias currentAlias = self.GetAliasByID(id)
;         if (!abOnlyIncludeAliasesInUse || (currentAlias as ReferenceAlias).GetReference() != none)
;             aliasArr[i] = currentAlias
;         endif
;         i += 1
;     endWhile

;     return aliasArr
; endFunction

; ;/
;     Retrieves the Scene's nth Alias of a specific type.

;     string  @asScene: The name of the Scene.
;     string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)

;     returns (ReferenceAlias): The Scene's Alias of a specific reference type.
; /;
; ReferenceAlias function GetSceneNthAliasOfType(string asScene, string asRefType, int aiIndex = 0)
;     int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; JArray&
;     int id = JArray.getInt(refsOfType, aiIndex)

;     return self.GetAliasByID(id) as ReferenceAlias
; endFunction

; ;/
;     string  @asScene: The scene to retrieve the reference types from.

;     returns (string[]): All reference types used in the Scene.
; /;
; string[] function GetSceneRefTypes(string asScene)
;     int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene)
;     return JMap.allKeysPArray(specifiedSceneConfig)
; endFunction

; ;/
;     Retrieves all of a Scene's aliases.

;     string  @asScene: The name of the Scene.
;     bool?   @abOnlyIncludeAliasesInUse: Whether to only include aliases that are currently bound.

;     returns (Alias[]): All of a Scene's aliases.
; /;
; Alias[] function GetSceneAliases(string asScene, bool abOnlyIncludeAliasesInUse = false)
;     float s = StartBenchmark()
;     int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; JMap&
;     int allRefTypeIds = JMap.allValues(specifiedSceneConfig) ; JArray&

;     Alias[] buffer = Utility.CreateAliasArray(128)
;     int aliasIndex = 0

;     ; I hate this nesting, but I can't extract this due to performance...
;     int i = 0
;     while (i < JValue.count(allRefTypeIds))
;         int typeArray = JArray.getObj(allRefTypeIds, i)
;         if (typeArray)
;             int k = 0
;             while (k < JValue.count(typeArray))
;                 int id = JArray.getInt(typeArray, k)
;                 ReferenceAlias refAlias = self.GetAliasByID(id) as ReferenceAlias 
;                 if (!abOnlyIncludeAliasesInUse || refAlias.GetReference() != none)
;                     if (aliasIndex < buffer.Length) ; prevent buffer overflow
;                         buffer[aliasIndex] = refAlias
;                         aliasIndex += 1
;                     endif
;                 endif
;                 k += 1
;             endWhile
;         endif
;         i += 1
;     endWhile

;     if (aliasIndex <= 0)
;         EventManager.SendError("Could not retrieve any scene aliases for Scene " + asScene + " (no aliases found!)", "SceneManager::GetSceneAliases")
;         return none
;     endif

;     Alias[] mergedAliases = Utility.CreateAliasArray(aliasIndex)

;     i = 0
;     while (i < mergedAliases.Length)
;         mergedAliases[i] = buffer[i]
;         i += 1
;     endWhile

;     EndBenchmark(s, "SceneManager::GetSceneAliases("+ asScene +")")
;     return mergedAliases
; endFunction

; ;/
;     Retrieves all of a Scene's references that are currently bound to a ReferenceAlias.

;     string  @asScene: The name of the Scene.

;     returns (Form[]): All of a Scene's references.
; /;
; ; Form[] function GetSceneReferences(string asScene)
; ;     int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; JMap&
; ;     ;/
; ;         "Guards": [],
; ;         "Prisoners": []
; ;     /;

; ;     int allRefTypeIds = JMap.allValues(specifiedSceneConfig) ; JArray&
; ;     int mergedTypes = JArray.object()

; ;     int i = 0
; ;     while (i < JValue.count(allRefTypeIds))
; ;         int typeArray = JArray.getObj(allRefTypeIds, i)
; ;         if (typeArray)
; ;             int k = 0
; ;             while (k < JValue.count(typeArray))
; ;                 int id = JArray.getInt(typeArray, k)
; ;                 ReferenceAlias r = self.GetAliasByID(id) as ReferenceAlias
; ;                 ObjectReference ref = r.GetReference()
; ;                 if (ref != none)
; ;                     JArray.addForm(mergedTypes, ref)
; ;                 endif
; ;                 k += 1
; ;             endWhile
; ;         endif
; ;         i += 1
; ;     endWhile

; ;     return JArray.asFormArray(mergedTypes)
; ; endFunction

; Form[] function GetSceneReferences(string asScene)
;     int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; JMap&

;     int allRefTypeIds   = Map_Values(specifiedSceneConfig) ; JArray&
;     int mergedTypes     = FastArray("<Form>") ; std::array<Form>(4)
;     ; Map_SetObject(mapObject, "Gata", Object("Map <int, Form>"))
;     ; int nestedMap = Map_GetObject(mapObject, "Gata") ; Map <int, Form>
;     ; Map_GetForm(nestedMap, 4)


;     int i = 0
;     while (i < Size(allRefTypeIds))
;         int typeArray = Array_GetObject(allRefTypeIds, i) ; Array<int>
;         if (typeArray)
;             int k = 0
;             while (k < Size(typeArray))
;                 int id = Array_GetInt(typeArray, k)
;                 ReferenceAlias r = self.GetAliasByID(id) as ReferenceAlias
;                 ObjectReference ref = r.GetReference()
;                 if (ref != none)
;                     Array_AddForm(mergedTypes, ref)
;                 endif
;                 k += 1
;             endWhile
;         endif
;         i += 1
;     endWhile

;     return Array_AsFormArray(mergedTypes)
; endFunction

; ;/
;     Retrieves the Scene references of a specific type that are currently bound to a ReferenceAlias.

;     string  @asScene: The name of the Scene.
;     string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)

;     returns (Form[]): The Scene's references of a specific reference type.
; /;
; Form[] function GetSceneReferencesOfType(string asScene, string asRefType)
;     int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; JArray&
;     int arrLen      = JValue.count(refsOfType)
    
;     int boundReferences = JArray.object()
 
;     int i = 0
;     while (i < arrLen)
;         int id = JArray.getInt(refsOfType, i)
;         ReferenceAlias r = self.GetAliasByID(id) as ReferenceAlias
;         ObjectReference ref = r.GetReference()
;         if (ref != none)
;             JArray.addForm(boundReferences, ref)
;         endif
;         i += 1
;     endWhile
    
;     return JArray.asFormArray(boundReferences)
; endFunction

; ;/
;     Retrieves the Scene's nth reference of a specific type that is currently bound to a ReferenceAlias.

;     string  @asScene: The name of the Scene.
;     string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)

;     returns (ObjectReference): The Scene's reference of a specific reference type.
; /;
; ObjectReference function GetSceneNthReferenceOfType(string asScene, string asRefType, int aiIndex = 0)
;     int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; JArray&

;     int id = JArray.getInt(refsOfType, aiIndex)
;     ReferenceAlias r = self.GetAliasByID(id) as ReferenceAlias
;     ObjectReference ref = r.GetReference()
;     if (ref != none)
;         return ref
;     endif

;     return none
; endFunction

; ;/
;     Handles the Scenes' configuration related to the ReferenceAlias they have,
;     where each one starts (index) and how many there are for every Scene.
; /;
; function CreateSceneConfig()
;     ; Arrest Start
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_01, "Escort",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_01, "Escortee",    Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_02, "Escort",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_02, "Escortee",    Pair(2, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_03, "Escort",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_03, "Escortee",    Pair(2, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_04, "Escort",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_04, "Escortee",    Pair(2, 0))

;     ; Arrest Start - Prison
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_PRISON_01, "Escort",   Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_START_PRISON_01, "Escortee", Pair(2, 0))

;     ; Eluding Arrest
;     self.CreateSceneRefTypeConfig(SCENE_ELUDING_ARREST_01, "Guard",   Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ELUDING_ARREST_01, "Eluder",  Pair(1, 0))

;     ; Pay Bounty
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY, "Escort",   Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY, "Escortee", Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE, "Escort",    Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE, "Escortee",  Pair(1, 0))

;     ; Restrain Prisoner
;     self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_01, "Guard",     Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_01, "Prisoner",  Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_02, "Guard",     Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_RESTRAIN_PRISONER_02, "Prisoner",  Pair(1, 0))

;     ; Escort to Jail
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Escort",    Pair(3, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Escortee",  Pair(10, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Player_EscortLocation",  Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Guard_EscortLocation",  Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_02, "Escort",    Pair(3, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_02, "Escortee",  Pair(1, 0))

;     ; Escort to Cell
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Escort",        Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Escortee",      Pair(3, 0)) ; refactor to Prisoner
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "CellDoor",      Pair(1, 0))
;     ; self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "ExteriorCell",  Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Player_EscortLocation",  Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_01, "Guard_EscortLocation",  Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_02, "Guard",         Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_CELL_02, "Prisoner",      Pair(1, 0))

;     ; Escort from Cell
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_FROM_CELL, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_ESCORT_FROM_CELL, "Prisoner",   Pair(1, 0))

;     ; Frisking
;     self.CreateSceneRefTypeConfig(SCENE_FRISKING, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_FRISKING, "Prisoner",   Pair(1, 0))

;     ; Stripping
;     self.CreateSceneRefTypeConfig(SCENE_STRIPPING_01, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_STRIPPING_01, "Prisoner",   Pair(3, 0))
;     self.CreateSceneRefTypeConfig(SCENE_STRIPPING_02, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_STRIPPING_02, "Prisoner",   Pair(3, 0))

;     ; Forced Stripping
;     self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_01, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_01, "Prisoner",   Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_02, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_FORCED_STRIPPING_02, "Prisoner",   Pair(1, 0))

;     ; Give Clothing
;     self.CreateSceneRefTypeConfig(SCENE_GIVE_CLOTHING, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_GIVE_CLOTHING, "Prisoner",   Pair(1, 0))

;     ; No Clothing
;     self.CreateSceneRefTypeConfig(SCENE_NO_CLOTHING, "Guard",      Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_NO_CLOTHING, "Prisoner",   Pair(4, 0))

;     ; Surrender
;     self.CreateSceneRefTypeConfig(SCENE_SURRENDER_01, "Surrenderer",        Pair(1, 0))
;     self.CreateSceneRefTypeConfig(SCENE_SURRENDER_01, "SurrendererCaptor",  Pair(6, 0))
; endFunction

; ;/
;     Retrieves a Scene by its configured name.

;     string  @asSceneName: The name of the Scene

;     returns (Scene): The actual Scene object for this scene.
; /;
; Scene function GetScene(string asSceneName)
;     if (!self.SceneExists(asSceneName))
;         Error("SceneManager::GetScene", "Scene " + asSceneName + " does not exist!")
;         return none
;     endif

;     return GetFormFromMod(self.GetSceneFormID(asSceneName)) as Scene
; endFunction

; ; ==========================================================
; ;                      Scene Event Types
; ; ==========================================================

; ; Type of Event during OnScenePlaying
; int property PHASE_START    = 0 autoreadonly
; int property PHASE_END      = 1 autoreadonly

; ; ==========================================================
; ;                        Scene Events
; ; ==========================================================

; string property EVENT_RESTRAIN_BEGIN        = "RestrainBegin" autoreadonly
; string property EVENT_RESTRAINING           = "Restraining" autoreadonly
; string property EVENT_RESTRAIN_END          = "RestrainEnd" autoreadonly
; string property EVENT_ARREST_BEGIN          = "ArrestBegin" autoreadonly
; string property EVENT_ARRESTING             = "Arresting" autoreadonly
; string property EVENT_ARREST_END            = "ArrestEnd" autoreadonly
; string property EVENT_SURRENDER_BEGIN       = "SurrenderBegin" autoreadonly
; string property EVENT_SURRENDERING          = "Surrendering" autoreadonly
; string property EVENT_SURRENDER_END         = "SurrenderEnd" autoreadonly
; string property EVENT_ESCORT_BEGIN          = "EscortBegin" autoreadonly
; string property EVENT_ESCORTING             = "Escorting" autoreadonly
; string property EVENT_ESCORT_END            = "EscortEnd" autoreadonly
; string property EVENT_FRISK_BEGIN           = "FriskBegin" autoreadonly
; string property EVENT_FRISKING              = "Frisking" autoreadonly
; string property EVENT_FRISK_END             = "FriskEnd" autoreadonly
; string property EVENT_STRIP_BEGIN           = "StripBegin" autoreadonly
; string property EVENT_STRIPPING             = "Stripping" autoreadonly
; string property EVENT_STRIP_END             = "StripEnd" autoreadonly
; string property EVENT_CLOTHING_BEGIN        = "ClothingBegin" autoreadonly
; string property EVENT_CLOTHING              = "Clothing" autoreadonly
; string property EVENT_CLOTHING_END          = "ClothingEnd" autoreadonly
; string property EVENT_FORCED_STRIP_BEGIN    = "ForcedStripBegin" autoreadonly
; string property EVENT_FORCED_STRIPPING      = "ForcedStripping" autoreadonly
; string property EVENT_FORCED_STRIP_END      = "ForcedStripEnd" autoreadonly
; string property EVENT_ELUDE_BEGIN           = "EludeTrigger" autoreadonly
; string property EVENT_ARREST_PAYING_BOUNTY  = "ArrestPayBountyBegin" autoreadonly
; string property EVENT_ARREST_PAY_BOUNTY_END = "ArrestPayBountyEnd" autoreadonly

; ; ==========================================================
; ;                       Scene Categories
; ; ==========================================================

; string property CATEGORY_ARREST_START       = "RPB_ArrestStart" autoreadonly
; string property CATEGORY_SURRENDER          = "RPB_Surrender" autoreadonly
; string property CATEGORY_ESCORT_TO_JAIL     = "RPB_EscortToJail" autoreadonly
; string property CATEGORY_ESCORT_TO_CELL     = "RPB_EscortToCell" autoreadonly
; string property CATEGORY_ESCORT_FROM_CELL   = "RPB_EscortFromCell" autoreadonly
; string property CATEGORY_FRISKING           = "RPB_Frisking" autoreadonly
; string property CATEGORY_STRIPPING          = "RPB_Stripping" autoreadonly
; string property CATEGORY_CLOTHING           = "RPB_Clothing" autoreadonly
; string property CATEGORY_NO_CLOTHING        = "RPB_NoClothing" autoreadonly
; string property CATEGORY_PAYMENT_FAIL       = "RPB_PaymentFail" autoreadonly
; string property CATEGORY_ELUDING            = "RPB_Eluding" autoreadonly
; string property CATEGORY_RESTRAIN           = "RPB_Restrain" autoreadonly
; string property CATEGORY_PAY_BOUNTY         = "RPB_ArrestPayBounty" autoreadonly

; ; ==========================================================
; ;                         Scene Names
; ; ==========================================================

; string property SCENE_ARREST_START_01                       = "RPB_ArrestStart01" autoreadonly
; string property SCENE_ARREST_START_02                       = "RPB_ArrestStart02" autoreadonly
; string property SCENE_ARREST_START_03                       = "RPB_ArrestStart03" autoreadonly
; string property SCENE_ARREST_START_04                       = "RPB_ArrestStart04" autoreadonly
; string property SCENE_ARREST_START_PRISON_01                = "RPB_ArrestStartPrison01" autoreadonly
; string property SCENE_SURRENDER_01                          = "RPB_Surrender01" autoreadonly
; string property SCENE_GENERIC_ESCORT                        = "RPB_GenericEscort" autoreadonly
; string property SCENE_ESCORT_FROM_CELL                      = "RPB_EscortFromCell" autoreadonly
; string property SCENE_ESCORT_TO_JAIL_01                     = "RPB_EscortToJail01" autoreadonly
; string property SCENE_ESCORT_TO_JAIL_02                     = "RPB_EscortToJail02" autoreadonly
; string property SCENE_ESCORT_TO_CELL_01                     = "RPB_EscortToCell01" autoreadonly
; string property SCENE_ESCORT_TO_CELL_02                     = "RPB_EscortToCell02" autoreadonly
; string property SCENE_ESCORT_TO_CELL_03                     = "RPB_EscortToCell03" autoreadonly
; string property SCENE_STRIPPING_01                          = "RPB_Stripping01" autoreadonly
; string property SCENE_STRIPPING_02                          = "RPB_Stripping02" autoreadonly
; string property SCENE_FORCED_STRIPPING_START_01             = "RPB_ForcedStrippingStart01" autoreadonly
; string property SCENE_FORCED_STRIPPING_01                   = "RPB_ForcedStripping01" autoreadonly
; string property SCENE_FORCED_STRIPPING_02                   = "RPB_ForcedStripping02" autoreadonly
; string property SCENE_STRIPPING_START_01                    = "RPB_StrippingStart01" autoreadonly
; string property SCENE_FRISKING                              = "RPB_Frisking" autoreadonly
; string property SCENE_GIVE_CLOTHING                         = "RPB_GiveClothing" autoreadonly
; string property SCENE_UNLOCK_CELL                           = "RPB_UnlockCell" autoreadonly
; string property SCENE_PAYMENT_FAIL                          = "RPB_BountyPaymentFail" autoreadonly
; string property SCENE_NO_CLOTHING                           = "RPB_NoClothing" autoreadonly
; string property SCENE_ELUDING_ARREST_01                     = "RPB_EludingArrest01" autoreadonly
; string property SCENE_RESTRAIN_PRISONER_01                  = "RPB_RestrainPrisoner01" autoreadonly
; string property SCENE_RESTRAIN_PRISONER_02                  = "RPB_RestrainPrisoner02" autoreadonly
; string property SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY    = "RPB_ArrestPayBountyFollowWillingly" autoreadonly
; string property SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE     = "RPB_ArrestPayBountyFollowByForce" autoreadonly

; ; ==========================================================
; ;                     Scene Control Queue
; ; ==========================================================

; int __queuedScenes
; bool __isScenePlaying
; string currentScene

; bool function HasQueuedScenes()
;     return JArray.count(__queuedScenes) > 0
; endFunction

; ;/
;     Pushes a Scene into the queue.

;     string  @asSceneName: The name of the scene.
; /;
; function PushScene(string asSceneName)
;     if (!__queuedScenes)
;         __queuedScenes = JArray.object()
;         JValue.retain(__queuedScenes, "RPB_SceneManager")
;     endif

;     ; Stack_PushString(__queuedScenes, asScenName)
;     JArray.addStr(__queuedScenes, asSceneName)
; endFunction

; ;/
;     Removes a Scene from the queue, and returns its name.

;     returns (string): The name of the removed Scene
; /;
; string function PopScene()
;     if (!self.HasQueuedScenes())
;         self.OnAllScenesFinished()
;         return ""
;     endif

;     ; return Stack_PopString(__queuedScenes)
;     string sceneName = JArray.getStr(__queuedScenes, 0)
;     JArray.eraseIndex(__queuedScenes, 0)
;     return sceneName
; endFunction

; ;/
;     Queues a Scene, or plays it if the queue is empty.

;     string  @asSceneName: The name of the Scene to queue up or play.
; /;
; function QueueOrPlay(string asSceneName)
;     int queuedSceneCount = JArray.count(__queuedScenes)

;     ; Queue Scene
;     self.PushScene(asSceneName)

;     if (!__isScenePlaying)
;         self.PlayQueued() ; play the 1st scene if the queue was empty
;     endif
; endFunction

; ;/
;     Plays the next Scene in the queue if there's any.
;     This is invoked OnSceneEnd() to ensure that the previous Scene finishes.
; /;
; function PlayQueued()
;     if (!self.HasQueuedScenes())
;         self.OnAllScenesFinished()
;         return
;     endif

;     ; Scene is now playing
;     __isScenePlaying = true

;     string nextScene = self.PopScene()

;     if (nextScene != "")
;         ; self.RestoreAliases()
;         self.GetScene(nextScene).Start() ; Play the Scene
;         currentScene = nextScene
;         Debug("SceneManager::PlayQueued", "Setting current scene: " + nextScene)

;     endif
; endFunction

; ; ==========================================================
; ;                       Scene Aliases
; ; ==========================================================

; ReferenceAlias function GetRefAlias(string aliasGroup, int index = 0)
;     if (aliasGroup == "Surrenderer" || aliasGroup == "SurrendererCaptor")
;         string refAliasGroup = aliasGroup + "_" + index
;         return self.GetAliasByName(refAliasGroup) as ReferenceAlias
;     endif

;     string refAliasGroup = string_if (index == 0, aliasGroup, aliasGroup + index)
;     return self.GetAliasByName(refAliasGroup) as ReferenceAlias
; endFunction

; string function GetAliasName(string aliasName, int aliasIndex, bool checkForExistence = false)
;     string finalName
;     if (aliasIndex == 0)
;         finalName = aliasName
;     else
;         finalName = aliasName + aliasIndex
;     endif

;     if (checkForExistence && self.GetAliasByName(finalName) == none)
;         Debug("SceneManager::GetAliasByName", "Alias " + finalName + " does not exist!")
;         return ""
;     endif

;     return finalName
; endFunction

; function ReleaseAlias(string aliasName, int aliasIndex = 0)
;     string finalName = self.GetAliasName(aliasName, aliasIndex , true)
;     ReferenceAlias refAlias = self.GetAliasByName(finalName) as ReferenceAlias

;     if (refAlias != none)
;         BindAliasTo(refAlias, none)
;     endif
; endFunction

; ;/
;     Unbinds all aliases of a particular Scene.
; /;
; function UnbindAliases(string asScene)
;     Alias[] sceneAliases = self.GetSceneAliases(asScene)

;     int i = 0
;     while (i < sceneAliases.Length)
;         ReferenceAlias refAlias = sceneAliases[i] as ReferenceAlias
;         ObjectReference ref = refAlias.GetReference()
;         if (ref)
;             UnbindAlias(refAlias)
;             DebugWithArgs("SceneManager::UnbindAliases", asScene, "Unbound " + refAlias.GetName() + " (id: "+ refAlias.GetID() +") containing reference: " + ref)
;         endif
;         i += 1
;     endWhile
; endFunction

; int __queuedAliases

; ;/                                                                                       
;     Queues an Alias for binding, optionally directly binding it if @abBindAlias is true.

;     ReferenceAlias  @apRefAlias: The Alias to use as binder.
;     ObjectReference @akRef: The reference to bind to the Alias.
;     bool?           @abBindAlias: Whether to directly bind the reference to the Alias.
; /;
; function QueueAlias(ReferenceAlias apRefAlias, ObjectReference akRef, bool abBindAlias = true)
;     if (!akRef)
;         EventManager.SendError("The reference received is none! (cannot queue Alias)", "SceneManager::QueueAlias")
;         return
;     endif

;     if (!__queuedAliases)
;         __queuedAliases = JIntMap.object()
;         JValue.retain(__queuedAliases)
;     endif

;     int id = apRefAlias.GetID()
;     JIntMap.setForm(__queuedAliases, id, akRef)
;     Debug("SceneManager::QueueAlias", "Bound " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") with reference: " + akRef)

;     if (abBindAlias)
;         RPB_Utility.BindAliasTo(apRefAlias, akRef)
;     endif

;     EventManager.SendWarning("Alias " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") has not been assigned to any reference!", "SceneManager::QueueAlias", akRef == none)
; endFunction

; ;/
;     Binds the received References to a specific type of Alias for the Scene.

;     string  @asScene: The scene of which to bind the references to.
;     string  @asAliasRefType: The group name of the Aliases (Escort, Escortee, Prisoner...)
;     Form[]  @akRefs: The references to bind to their respective alias group.
; /;
; function BindSceneAliasGroup(string asScene, string asAliasRefType, Form[] akRefs)
;     Alias[] aliasesInGroup = self.GetSceneAliasesOfType(asScene, asAliasRefType)

;     if (!aliasesInGroup)
;         EventManager.SendError("Could not retrieve the Scene's Aliases of type " + asAliasRefType + ", cannot bind!", "SceneManager::BindSceneAliasGroup")
;         return
;     endif

;     int refCount    = akRefs.Length 
;     int aliasCount  = aliasesInGroup.Length
;     int iterations  = min(refCount, aliasCount) as int

;     int i = 0
;     while (i < iterations)
;         if (akRefs[i])
;             self.QueueAlias(aliasesInGroup[i] as ReferenceAlias, akRefs[i] as ObjectReference)
;         endif
;         i += 1
;     endWhile

;     EventManager.SendWarning("Received references are more than the available Aliases in the Scene! (Scene: "+ asScene +") (Alias Group: "+ asAliasRefType +") (Received: "+ refCount +", Available Aliases: "+ aliasCount +")", "SceneManager::BindSceneAliasGroup", refCount > aliasCount)
;     EventManager.SendInfo("Received less references than the available Aliases in the Scene. (Scene: "+ asScene +") (Alias Group: "+ asAliasRefType +") (Received: "+ refCount +", Available Aliases: "+ aliasCount +")", "SceneManager::BindSceneAliasGroup", aliasCount > refCount)
; endFunction

; ;/
;     Binds the received Reference to a specific type of Alias for the Scene.

;     string           @asScene: The scene of which to bind the references to.
;     string           @asAliasRefType: The group name of the Aliases (Escort, Escortee, Prisoner...)
;     ObjectReference  @akRef: The reference to bind to its respective alias group.
; /;
; function BindSceneAlias(string asScene, string asAliasRefType, ObjectReference akRef)
;     Alias[] aliasesInGroup = self.GetSceneAliasesOfType(asScene, asAliasRefType)

;     if (!aliasesInGroup)
;         EventManager.SendError("Could not retrieve the Scene's Aliases of type " + asAliasRefType + ", cannot bind!", "SceneManager::BindSceneAlias")
;         return
;     endif

;     int aliasCount  = aliasesInGroup.Length
;     int iterations  = 1

;     int i = 0
;     while (i < iterations)
;         if (akRef)
;             self.QueueAlias(aliasesInGroup[i] as ReferenceAlias, akRef)
;         endif
;         i += 1
;     endWhile
; endFunction

; ;/
;     Restores all of the currently queued Aliases.
;     This means that every Alias (along with its Reference), will be re-bound.

;     Possible ISSUE: Might clear the Aliases of the Scene after the queued scene (3rd Scene in the queue, 
;         since the 2nd scene will have the Aliases queued from the first call, but then cleared for the 3rd (which were already queued)), needs to be tested
;     Confirmed ISSUE: It is indeed the case, the 3rd scene doesn't get the Aliases (if they were the same as the 2nd scene), and therefore fails to run.
; /;
; function RestoreAliases()
;     int aliasIds    = JIntMap.allKeys(__queuedAliases)
;     int aliasRefs   = JIntMap.allValues(__queuedAliases)

;     int i = 0
;     while (i < JValue.count(aliasIds))
;         int id                 = JArray.getInt(aliasIds, i)
;         ObjectReference ref    = JArray.getForm(aliasRefs, i) as ObjectReference

;         ReferenceAlias refAlias = self.GetAliasByID(id) as ReferenceAlias
;         Debug("SceneManager::RestoreAliases", "Restored " + refAlias.GetName() + " (id: "+ refAlias.GetID() +") with reference: " + ref)

;         RPB_Utility.BindAliasTo(refAlias, ref)
;         i += 1
;     endWhile

;     ; Possible ISSUE: Might clear the Aliases of the Scene after the queued scene (3rd Scene in the queue, since the 2nd scene will have the Aliases queued from the first call), needs to be tested
;     JIntMap.clear(__queuedAliases)
; endFunction

; ; ==========================================================
; ;                    Scene Event Handlers
; ; ==========================================================

; ;/
;     Handles customization of a Scene, either Enabling/Disabling Dialogue or a particular Action.
;     Scenes that have conditions that depend on Scene_{Dialogue|Action}_CF* Globals.

;     These global events set them for a scene that could customize another scene, for example.

;     If a control flow global variable must be set on a particular Scene,
;     the @asScene parameter can be used to specify the exact scene, instead of relying on just the type.

;     string  @asSceneType: The type this Scene falls under.
;     string  @asScene: The name of the Scene.
; /;
; function HandleSceneGlobalControlFlow(string asSceneType, string asScene)
;     if (asSceneType == CATEGORY_ARREST_START)
;     elseif (asSceneType == CATEGORY_ESCORT_TO_JAIL)
;         self.SetGlobal("RPB_Scene_Action_CF01", 1) ; Enables some actions in EscortToCell
;     elseif (asSceneType == CATEGORY_ESCORT_TO_CELL)
;     elseif (asSceneType == CATEGORY_ESCORT_FROM_CELL)
;     elseif (asSceneType == CATEGORY_FRISKING)
;     elseif (asSceneType == CATEGORY_STRIPPING)
;     elseif (asSceneType == CATEGORY_ELUDING)
;     endif
; endFunction

; ; function test()
; ;     int array = Array("<string>")

; ;     if (array != -1)
; ;         ; things
; ;     else
; ;         int exceptions = Exceptions(array)

; ;         if (CatchException(exceptions, "InvalidObjectException"))
; ;             int e = GetException(exceptions, "InvalidObjectException")
; ;             Error(ExceptionMessage(e))
; ;         endif
; ;     endif
; ; endFunction

; event OnSceneStart(string name, Scene sender)
;     float stackStart = StartBenchmark()
;     self.RestoreAliases()

;     Form[] params   = self.GetSceneReferences(name)
;     Alias[] aliases = self.GetSceneAliases(name, true)
;     string type     = self.GetSceneType(name)

;     ; float sceneRefTypesBench = StartBenchmark()
;     ; int i = 0
;     ; string[] sceneRefTypes = self.GetSceneRefTypes(name)
;     ; while (i < sceneRefTypes.Length)
;     ;     Form[] paramsOfType = self.GetSceneReferencesOfType(name, sceneRefTypes[i])
;     ;     DebugWithArgs("SceneManager::OnSceneStart", name, "["+ sceneRefTypes[i] +"] "+ name +" Params: " + paramsOfType)
;     ;     i += 1
;     ; endWhile
;     ; EndBenchmark(sceneRefTypesBench, "SceneManager::OnSceneStart")

;     self.HandleSceneGlobalControlFlow(type, name)

;     if (type == CATEGORY_ARREST_START)
;         Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")

;         EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort)

;     elseif (type == CATEGORY_ESCORT_TO_JAIL)
;         Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")
        
;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, arrestees, escort)

;     elseif (type == CATEGORY_ESCORT_TO_CELL)
;         Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

;         if (name == SCENE_ESCORT_TO_CELL_02) ; override
;             escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;             prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")
;         endif

;         DebugWithArgs("SceneManager::OnSceneStart", name, "escort: " + escort + ", prisoners: " + prisoners)
        
;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, prisoners, escort)

;     elseif (type == CATEGORY_ESCORT_FROM_CELL)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")
        
;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, prisoners, guard)

;     elseif (type == CATEGORY_FRISKING)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")
        
;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_FRISK_BEGIN, prisoners, guard)

;     elseif (type == CATEGORY_STRIPPING)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

;         string secondaryEvent = string_if (name == SCENE_STRIPPING_02, "Undress to Underwear", "null")

;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIP_BEGIN, prisoners, guard, secondaryEvent)

;     elseif (type == CATEGORY_ELUDING)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Actor eluder     = self.GetSceneNthReferenceOfType(name, "Eluder") as Actor

;         EventManager.SendArrestSceneEvent(name, EVENT_ELUDE_BEGIN, eluder, guard, "Dialogue")
;     endif

;     Debug("SceneManager::OnSceneStart", self.GetSceneParametersDebugInfo(sender, name))
;     EndBenchmark(stackStart, "SceneManager::OnSceneStart EVENT STACK -> " + name)
; endEvent

; event OnScenePlaying(string name, int phaseEvent, int phase, Scene sender)
;     string type = self.GetSceneType(name)

;     Debug("SceneManager::OnScenePlaying", name + " " + sender + ": " + string_if (phaseEvent == PHASE_START, "(Start)", "(End)") + " Phase " + phase)

;     if (type == CATEGORY_ARREST_START)
;         Actor escort        = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] arrestees    = self.GetSceneReferencesOfType(name, "Escortee")

;         if (name == SCENE_ARREST_START_01)
;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Hands Behind Back")
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")
;             endif

;         elseif (name == SCENE_ARREST_START_02)
;             if (phase == 3 && phaseEvent == PHASE_START)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")

;             elseif (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Hands Behind Back")
;             endif

;         elseif (name == SCENE_ARREST_START_03)
;             if (phase == 4 && phaseEvent == PHASE_START)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")

;             elseif (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Kneel Down")
;             endif

;         elseif (name == SCENE_ARREST_START_04)
;             if (phase == 1 && phaseEvent == PHASE_START)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Lie Down")

;             elseif (phase == 6 && phaseEvent == PHASE_END)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")
;             endif

;         elseif (name == SCENE_ARREST_START_PRISON_01)
;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Hands Behind Back")

;             elseif (phase == 2 && phaseEvent == PHASE_END)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort, "Handcuff")
;             endif
;         endif

;     elseif (type == CATEGORY_ESCORT_TO_JAIL)
;         ; No Events

;     elseif (type == CATEGORY_ESCORT_TO_CELL)
;         Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

;         if (name == SCENE_ESCORT_TO_CELL_01)
;             if (phase == 7 && phaseEvent == PHASE_START)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Lock Cell")

;             elseif (phase == 4 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Unlock Cell")

;             elseif (phase == 5 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort, "Release from Captor")
;             endif

;         elseif (name == SCENE_ESCORT_TO_CELL_02)
;             escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;             prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")

;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Hands Behind Back")

;             elseif (phase == 2 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Restrain Prisoner")

;             elseif (phase == 8 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneEvent(name, EVENT_ESCORT_END, prisoners[0] as Actor, escort, "Lock Cell")
;             endif
;         endif

;     elseif (type == CATEGORY_ESCORT_FROM_CELL)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

;         if (name == SCENE_ESCORT_FROM_CELL)
;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORTING, prisoners, guard)
;             endif
;         endif

;     elseif (type == CATEGORY_STRIPPING)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

;         if (name == SCENE_STRIPPING_01)
;             EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIPPING, prisoners, guard)

;         elseif (name == SCENE_STRIPPING_02)
;             EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIPPING, prisoners, guard)

;             if (phase == 6 && phaseEvent == PHASE_START) ; Remove Underwear
                
;             endif

;         elseif (name == SCENE_FORCED_STRIPPING_01)
;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Lie Down")

;             elseif (phase == 2 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Undress to Underwear")

;             elseif (phase == 3 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Remove Underwear")
;             endif

;         elseif (name == SCENE_FORCED_STRIPPING_02)
;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Lie Down")

;             elseif (phase == 3 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Undress Lower Body")

;             elseif (phase == 5 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Sit Down")

;             elseif (phase == 7 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_FORCED_STRIPPING, prisoners, guard, "Undress Upper Body")
;             endif
;         endif

;     elseif (type == CATEGORY_SURRENDER)
;         Form[] surrendererCaptors   = self.GetSceneReferencesOfType(name, "SurrendererCaptor")
;         Actor surrenderer           = self.GetSceneNthReferenceOfType(name, "Surrenderer") as Actor

;         if (name == SCENE_SURRENDER_01)
;             if (phase == 3 && phaseEvent == PHASE_START)
;                 EventManager.SendSurrenderSceneEvent(name, EVENT_SURRENDER_BEGIN, surrenderer, none, "null", surrendererCaptors)
;             endif
;         endif

;     elseif (type == CATEGORY_PAY_BOUNTY)
;         Actor escort        = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] arrestees    = self.GetSceneReferencesOfType(name, "Escortee")

;         if (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
;             if (phase == 3 && phaseEvent == PHASE_END)
;                 EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_PAYING_BOUNTY, arrestees, escort, "Hands Behind Back")
;             endif
;         endif

;     elseif (type == CATEGORY_RESTRAIN)
;         Actor guard     = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

;         if (name == SCENE_RESTRAIN_PRISONER_01)
;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_BEGIN, prisoners, guard, "Hands in Front")

;             elseif (phase == 2 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_END, prisoners, guard)
;             endif

;         elseif (name == SCENE_RESTRAIN_PRISONER_02)
;             if (phase == 1 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_BEGIN, prisoners, guard, "Hands Behind Back")

;             elseif (phase == 2 && phaseEvent == PHASE_END)
;                 EventManager.SendPrisonSceneBulkEvent(name, EVENT_RESTRAIN_END, prisoners, guard)
;             endif
;         endif

;     endif

; endEvent

; event OnSceneEnd(string name, Scene sender)
;     string type = self.GetSceneType(name)

;     if (type == CATEGORY_ARREST_START)
;         Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")

;         string secondaryEvent = string_if (name == SCENE_ARREST_START_PRISON_01, "Arrest in Prison", "null")

;         EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_END, arrestees, escort, secondaryEvent)

;     elseif (type == CATEGORY_ESCORT_TO_JAIL)
;         Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")
        
;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, arrestees, escort)

;     elseif (type == CATEGORY_ESCORT_TO_CELL)
;         Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

;         if (name == SCENE_ESCORT_TO_CELL_02) ; override
;             escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;             prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")
;         endif
        
;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, escort)

;     elseif (type == CATEGORY_ESCORT_FROM_CELL)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")
        
;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, prisoners, guard)

;     elseif (type == CATEGORY_STRIPPING)
;         Actor guard      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
;         Form[] prisoners = self.GetSceneReferencesOfType(name, "Prisoner")

;         string secondaryEvent = "null"

;         if (name == SCENE_STRIPPING_01)
;             secondaryEvent = "Restrain Prisoner"
        
;         elseif (name == SCENE_FORCED_STRIPPING_01)
;             secondaryEvent = "Stand Up (Lie Down)"

;         elseif (name == SCENE_FORCED_STRIPPING_02)
;             secondaryEvent = "Stand Up (Kneel)"
;         endif

;         EventManager.SendPrisonSceneBulkEvent(name, EVENT_STRIP_END, prisoners, guard, secondaryEvent)

;     elseif (type == CATEGORY_SURRENDER)
;         Actor surrendererCaptor = self.GetSceneNthReferenceOfType(name, "SurrendererCaptor") as Actor
;         Actor surrenderer       = self.GetSceneNthReferenceOfType(name, "Surrenderer") as Actor
;         Debug("SceneManager::OnSceneEnd", "surrendererCaptor: " + surrendererCaptor + ", surrenderer: " + surrenderer)

;         EventManager.SendSurrenderSceneEvent(name, EVENT_SURRENDER_END, surrenderer, surrendererCaptor)

;     elseif (type == CATEGORY_PAY_BOUNTY)
;         Actor escort   = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
;         Actor escortee = self.GetSceneNthReferenceOfType(name, "Escortee") as Actor

;         string secondaryEvent = "null"

;         if (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY)
;             secondaryEvent = "Follow Willingly"
        
;         elseif (name == SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE)
;             secondaryEvent = "Escort by Force"
;         endif

;         EventManager.SendArrestSceneEvent(name, EVENT_ARREST_PAY_BOUNTY_END, escortee, escort, secondaryEvent)
;     endif
    
;     self.ResetSceneOverride()
;     float paramsBenchmark = StartBenchmark()
;     Form[] params = self.GetSceneReferences(name)
;     EndBenchmark(paramsBenchmark, "SceneManager::OnSceneEnd::GetSceneReferences() NEW")
;     Alias[] aliases = self.GetSceneAliases(name, true)
;     Debug("SceneManager::OnSceneEnd", self.GetSceneParametersDebugInfo(sender, name))
;     Debug("SceneManager::OnSceneEnd", "Ended Scene: " + name)

;     ; self.UnbindAliases(name) ; (Need to fix this, since they get unbound after they should, for now, uncommented) ERROR: EventManager::SendPrisonSceneBulkEvent() -> No prisoners provided for bulk scene event!
;     self.PlayQueued()
;     __isScenePlaying = false ; Scene has finished playing
;     self.ResetGlobals()
;     self.OnResumeSceneBlocked()
; endEvent

; event OnAllScenesFinished()
;     Debug("SceneManager::OnAllScenesFinished", "Resetting current scene!")
;     currentScene = ""

;     self.ResetGlobals()
; endEvent

; ; ==========================================================
; ;                       Scene Starters
; ; ==========================================================

; function StartScene(string asSceneName, int akSceneParameters, int aiStartingPhase = 1, bool abForceStart = false)
;     if (!self.SceneExists(asSceneName))
;         Error("SceneManager::StartScene", "Tried to start Scene " + asSceneName + ": Scene does not exist!")
;         return
;     endif

;     Scene sceneObject = self.GetScene(asSceneName)

;     if (sceneObject.IsPlaying() && !abForceStart)
;         Debug("SceneManager::StartScene", "Scene " + sceneObject + " is currently playing, aborting call!")
;         return
;     endif

;     ; Setup parameters

;     ; Setup starting phase
;     self.StartSceneAtPhase(aiStartingPhase)

;     if (abForceStart)
;         sceneObject.ForceStart()
    
;     else
;         sceneObject.Start()
;     endif
; endFunction


; function StartEscortToCell(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, RPB_CellDoor akJailCellDoor, ObjectReference akEscortWaitingMarker)
;     ObjectReference waitingEscortMarker = akEscortWaitingMarker
;     if (waitingEscortMarker == none)
;         waitingEscortMarker = akJailCellDoor
;     endif

;     Debug("SceneManager::StartEscortToCell", "akEscortLeader: " + akEscortLeader + ", akEscortedPrisoner: " + akEscortedPrisoner)

;     string name = SCENE_ESCORT_TO_CELL_01
;     self.BindSceneAlias(name, "Escort", akEscortLeader)
;     self.BindSceneAlias(name, "Escortee", akEscortedPrisoner)
;     self.BindSceneAlias(name, "CellDoor", akJailCellDoor)
;     self.BindSceneAlias(name, "Player_EscortLocation", akJailCellMarker)
;     self.BindSceneAlias(name, "Guard_EscortLocation", waitingEscortMarker)
;     self.QueueOrPlay(name)
; endFunction

; function StartEscortToCell_02(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akJailCellMarker, ObjectReference akJailCellDoor, ObjectReference akEscortWaitingMarker)
;     ObjectReference waitingEscortMarker = akEscortWaitingMarker
;     if (waitingEscortMarker == none)
;         waitingEscortMarker = akJailCellDoor
;     endif

;     string name = SCENE_ESCORT_TO_CELL_02
;     self.BindSceneAlias(name, "Guard", akEscortLeader)
;     self.BindSceneAlias(name, "Prisoner", akEscortedPrisoner)
;     self.BindSceneAlias(name, "CellDoor", akJailCellDoor)
;     self.BindSceneAlias(name, "Cell", akJailCellMarker)
;     self.BindSceneAlias(name, "Guard_EscortLocation", waitingEscortMarker)
;     self.QueueOrPlay(name)
; endFunction

; function StartEscortFromCell(Actor akGuard, Actor akPrisoner, ObjectReference akJailCellDoor, ObjectReference akJailChest)
;     Debug("SceneManager::StartEscortFromCell", "Starting Scene " + self.GetScene(SCENE_ESCORT_FROM_CELL) +", params: ["+ akGuard + "," + akPrisoner + "," + akJailCellDoor + "," + akJailChest + "]")
;     string name = SCENE_ESCORT_FROM_CELL
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.BindSceneAlias(name, "Player_EscortLocation", akJailChest)
;     self.BindSceneAlias(name, "Guard_EscortLocation", akJailCellDoor)
;     self.QueueOrPlay(name)
; endFunction

; function StartEscortToJail(Actor akEscortLeader, Actor akEscortedPrisoner, ObjectReference akPrisonerChest)
;     string name = SCENE_ESCORT_TO_JAIL_01
;     self.BindSceneAlias(name, "Escort", akEscortLeader)
;     self.BindSceneAlias(name, "Escortee", akEscortedPrisoner)
;     self.BindSceneAlias(name, "Player_EscortLocation", akPrisonerChest)
;     self.BindSceneAlias(name, "Guard_EscortLocation", akPrisonerChest)
;     self.QueueOrPlay(name)
; endFunction

; function EscortToJail(Actor akEscort, Form[] akEscortees, Form[] akDestinations)
;     string name = SCENE_ESCORT_TO_JAIL_01

;     self.BindSceneAlias(name, "Escort", akEscort)
;     self.BindSceneAliasGroup(name, "Escortee", akEscortees)
;     self.BindSceneAliasGroup(name, "Player_EscortLocation", akDestinations)
;     self.BindSceneAliasGroup(name, "Guard_EscortLocation", akDestinations)

;     self.QueueOrPlay(name)
; endFunction

; function StartStrippingStart(Actor akStripperGuard, Actor akStrippedPrisoner)
;     ; TODO: add the remaining prisoners
;     string name = SCENE_STRIPPING_START_01
;     self.BindSceneAlias(name, "Guard", akStripperGuard)
;     self.BindSceneAlias(name, "Prisoner", akStrippedPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartStripping(Actor akStripperGuard, Actor akStrippedPrisoner)
;     string name = SCENE_STRIPPING_01
;     self.BindSceneAlias(name, "Guard", akStripperGuard)
;     self.BindSceneAlias(name, "Prisoner", akStrippedPrisoner)
;     ; self.BindSceneAlias(name, "Guard_EscortLocation", akStripMarker) ; Needs to be added
;     ; self.BindSceneAlias(name, "Player_EscortLocation", akStripMarker) ; Needs to be added
;     self.QueueOrPlay(name)
; endFunction

; function StartStripping_02(Actor akStripperGuard, Actor akStrippedPrisoner, ObjectReference akStripMarker = none)
;     string name = SCENE_STRIPPING_02
;     self.BindSceneAlias(name, "Guard", akStripperGuard)
;     self.BindSceneAlias(name, "Prisoner", akStrippedPrisoner)
;     self.BindSceneAlias(name, "Guard_EscortLocation", akStripMarker)
;     self.BindSceneAlias(name, "Player_EscortLocation", akStripMarker)
;     self.QueueOrPlay(name)
; endFunction

; function StartFrisking(Actor akFriskerGuard, Actor akFriskedPrisoner)
;     string name = SCENE_FRISKING
;     self.BindSceneAlias(name, "Guard", akFriskerGuard)
;     self.BindSceneAlias(name, "Prisoner", akFriskedPrisoner)
;     ; self.BindSceneAlias(name, "Guard_EscortLocation", akFriskMarker) ; Needs to be added
;     ; self.BindSceneAlias(name, "Player_EscortLocation", akFriskMarker) ; Needs to be added
;     self.QueueOrPlay(name)
; endFunction

; function StartGiveClothing(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_GIVE_CLOTHING
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartBountyPaymentFail(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_PAYMENT_FAIL
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestStart01(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_ARREST_START_01
;     self.BindSceneAlias(name, "Escort", akGuard)
;     self.BindSceneAlias(name, "Escortee", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestStart02(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_ARREST_START_02
;     self.BindSceneAlias(name, "Escort", akGuard)
;     self.BindSceneAlias(name, "Escortee", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestStart03(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_ARREST_START_03
;     self.BindSceneAlias(name, "Escort", akGuard)
;     self.BindSceneAlias(name, "Escortee", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestStart04(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_ARREST_START_04
;     self.BindSceneAlias(name, "Captor", akGuard) ; needs to be changed to Escort
;     self.BindSceneAlias(name, "Escortee", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartSurrenderScene(Actor akSurrenderer, Actor[] akSurrendererCaptors, string asScene)
;     string name = SCENE_SURRENDER_01
;     self.BindSceneAliasGroup(name, "SurrendererCaptor", RPB_Utility.ActorToFormArray(akSurrendererCaptors))
;     self.BindSceneAlias(name, "Surrenderer", akSurrenderer)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestScene(Actor akGuard, Actor akArrestee, string asScene)
;     string name = asScene
;     self.BindSceneAlias(name, "Escort", akGuard)
;     self.BindSceneAlias(name, "Escortee", akArrestee)
;     self.QueueOrPlay(name)
; endFunction

; function StartEscortToJailScene(Actor akGuard, Actor akArrestee, string asScene)
;     string name = asScene
;     self.BindSceneAlias(name, "Escort", akGuard)
;     self.BindSceneAlias(name, "Escortee", akArrestee)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestStartPrison_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
;     string name = SCENE_ARREST_START_PRISON_01
;     self.BindSceneAlias(name, "Escort", akGuard)
;     self.BindSceneAlias(name, "Escortee", akPrisoner)
;     self.StartSceneAtPhase(aiStartingPhase)
;     self.QueueOrPlay(name)
; endFunction

; function StartRestrainPrisoner_01(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
;     string name = SCENE_RESTRAIN_PRISONER_01
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.StartSceneAtPhase(aiStartingPhase)
;     self.QueueOrPlay(name)
; endFunction

; function StartRestrainPrisoner_02(Actor akGuard, Actor akPrisoner, int aiStartingPhase = 1)
;     string name = SCENE_RESTRAIN_PRISONER_02
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.StartSceneAtPhase(aiStartingPhase)
;     self.QueueOrPlay(name)
; endFunction

; function StartNoClothing(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_NO_CLOTHING
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartForcedStripping(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_FORCED_STRIPPING_01
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartForcedStripping02(Actor akGuard, Actor akPrisoner)
;     string name = SCENE_FORCED_STRIPPING_02
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Prisoner", akPrisoner)
;     self.QueueOrPlay(name)
; endFunction

; function StartEludingArrest(Actor akGuard, Actor akEluder)
;     if (self.GetScene(SCENE_ELUDING_ARREST_01).IsPlaying())
;         Debug("SceneManager::StartEludingArrest", "Scene is currently playing, aborting call!")
;         return
;     endif

;     string name = SCENE_ELUDING_ARREST_01
;     self.BindSceneAlias(name, "Guard", akGuard)
;     self.BindSceneAlias(name, "Eluder", akEluder)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestBountyPaymentFollowWillingly(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
;     string name = SCENE_ARREST_PAY_BOUNTY_FOLLOW_WILLINGLY
;     self.BindSceneAlias(name, "Escort", akEscort)
;     self.BindSceneAlias(name, "Escortee", akEscortee)
;     self.BindSceneAlias(name, "Guard_EscortLocation", akEscortLocation)
;     self.BindSceneAlias(name, "Player_EscortLocation", akEscortLocation)
;     self.QueueOrPlay(name)
; endFunction

; function StartArrestPayBountyFollowByForce(Actor akEscort, Actor akEscortee, ObjectReference akEscortLocation)
;     string name = SCENE_ARREST_PAY_BOUNTY_FOLLOW_BY_FORCE
;     self.BindSceneAlias(name, "Escort", akEscort)
;     self.BindSceneAlias(name, "Escortee", akEscortee)
;     self.BindSceneAlias(name, "Guard_EscortLocation", akEscortLocation)
;     self.BindSceneAlias(name, "Player_EscortLocation", akEscortLocation)
;     self.QueueOrPlay(name)
; endFunction


; ; ==========================================================
; ;                           Debug
; ; ==========================================================

; string function GetSceneParametersDebugInfo(Scene sender, string sceneName)
;     Form[] params   = self.GetSceneReferences(sceneName)
;     Alias[] aliases = self.GetSceneAliases(sceneName, true)

;     string debugInfo = ""
;     bool emptyParams = true

;     int i = 0
;     while (i < params.Length)
;         ObjectReference param = params[i] as ObjectReference
;         if (param != none)
;             ReferenceAlias paramBinder = aliases[i] as ReferenceAlias
;             string paramBinderSignature = "["+ paramBinder.GetName() +" < ("+ paramBinder.GetID() +")>]"
;             string baseId     = "[BaseID: " + param.GetBaseObject().GetFormID() + "] "
;             string formId     = "[FormID: " + param.GetFormID() + "] "
            
;             string objectBaseName   = param.GetBaseObject().GetName()
;             string objectClassName  = param.GetName()
;             string whichNameProperty = string_if (objectClassName != "", objectClassName, objectBaseName)
;             string objectName = "[Name: " + whichNameProperty + "] "
;             emptyParams = false

;             debugInfo += "\t["+i+"]: " + paramBinderSignature + " " + param + " " + formId + baseId + string_if (objectName != "[Name: ] ", objectName) + "\n"
;         endif
;         i += 1
;     endWhile
    
;     if (emptyParams)
;         return sceneName + " " + sender + " - No Parameters, Scene expected: " + params.Length + " parameters!" ; " - No Parameters, Scene expected: need a way to find scene required params
;     endif

;     return sceneName + " " + sender + "\nParameters: [\n" + debugInfo + "]"
; endFunction

scriptname RPB_SceneManager extends Quest

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
int __queuedAliases     ; FastMap<int>
int __queuedScenes      ; Queue<string>

function SceneManager()
    ; int map = RPB_Memory.Map("<string, Map<int, int[][]>>")
    ; RPB_Memory.Get(map, "[ 'key', 1 ]") ; R: Object<int[][]>
    ; RPB_Memory.Set(map, "[ 'key', 1 ], [[4, 10], [2, 4]]")

    __sceneContainer    = Object_CreateIfNotExists(__sceneContainer,  FastMap("<string>",   retain = true))
    __sceneToCategory   = Object_CreateIfNotExists(__sceneToCategory, FastMap("<string>",   retain = true))
    __sceneConfig       = Object_CreateIfNotExists(__sceneConfig,     FastMap("<string>",   retain = true))
    __globals           = Object_CreateIfNotExists(__globals,         FastMap("<string>",   retain = true))
    __globalDefaults    = Object_CreateIfNotExists(__globalDefaults,  FastMap("<string>",   retain = true))
    __queuedScenes      = Object_CreateIfNotExists(__queuedScenes,    FastArray("<string>", retain = true))
    __queuedAliases     = Object_CreateIfNotExists(__queuedAliases,   FastMap("<int>",      retain = true))
endFunction

function __allocateMemory()
    __sceneContainer    = Object_CreateIfNotExists(__sceneContainer,  FastMap("<string>",   retain = true))
    __sceneToCategory   = Object_CreateIfNotExists(__sceneToCategory, FastMap("<string>",   retain = true))
    __sceneConfig       = Object_CreateIfNotExists(__sceneConfig,     FastMap("<string>",   retain = true))
    __globals           = Object_CreateIfNotExists(__globals,         FastMap("<string>",   retain = true))
    __globalDefaults    = Object_CreateIfNotExists(__globalDefaults,  FastMap("<string>",   retain = true))
    __queuedScenes      = Object_CreateIfNotExists(__queuedScenes,    Queue("<string>",     retain = true))
    __queuedAliases     = Object_CreateIfNotExists(__queuedAliases,   FastMap("<int>",      retain = true))
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

function AddGlobal(string asGlobalName, int aiGlobalFormID, int aiDefaultValue = 0)
    ; RPB_Memory.Set(map, "['Globals'], { 'asGlobalName': aiGlobalFormID }")
    ; RPB_Memory.Set(map, "['GlobalDefaults'], { 'asGlobalName': aiDefaultValue }")
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
    string lastScene = Queue_BackString(__queuedScenes) ; needs to be revised, returning empty, however it works for now
    Debug("SceneManager::OnResumeSceneBlocked", "ResumeSceneBlocked: " + __resumeSceneBlocked + ", Current Scene: " + currentScene + ", Last Scene: " + lastScene + ", Condition: " + (currentScene == lastScene))
    if (__resumeSceneBlocked && currentScene == lastScene)
        ReleaseAI()
        __resumeSceneBlocked = false
    endif
endEvent

; ==========================================================
;                           Scenes
; ==========================================================

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

    int sceneCount = FastMap_Size(__sceneContainer)
    string sceneListAsString = ""
    int i = 0
    while (i < sceneCount)
        sceneListAsString += "\t["+i+"]: "+ self.GetSceneNameByIndex(i) +"\n"
        i += 1
    endWhile

    Debug("SceneManager::SetupScenes", "Loaded "+ sceneCount +" Scenes: [\n" + sceneListAsString + "]")
endFunction



;/
    Creates a nested structure that contains a Scene's configuration related to
    their ReferenceAliases information.
/;
function CreateSceneRefTypeConfig(string asScene, string asRefType, int[] akSceneAliasCount)
    bool sceneExists     = FastMap_HasKey(__sceneConfig, asScene)
    int sceneRefTypesObj = FastMap_SetObject(__sceneConfig, asScene, FastMap("<string>"), condition = !sceneExists) ; FastMap<string>

    if (!sceneRefTypesObj)
        EventManager.SendError("Cannot create the scene config for scene " + asScene + " (object does not exist!)", "SceneManager::CreateSceneRefTypeConfig")
        return
    endif

    ; Get Alias ID from the specified config
    int aliasCount = akSceneAliasCount[0]
    int startIndex = akSceneAliasCount[1]

    int aliasIds = FastArray(retain = true)

    int i = 0
    while (i < (aliasCount - startIndex))
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
    int obj = FastMap_GetObject(__sceneConfig, asScene)
    int refTypes = JMap.allKeys(obj)

    int keyIndex = 0
    while (keyIndex < JValue.count(refTypes))
        string refTypeName = JArray.getStr(refTypes, keyIndex)
        int refTypeIds = FastMap_GetObject(obj, refTypeName) ; JArray&

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
    int refsOfType  = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; JArray&
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
        EventManager.SendError("Could not retrieve any scene aliases for Scene " + asScene + " (no aliases found!)", "SceneManager::GetSceneAliases")
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
    int specifiedSceneConfig = self.GetSceneRefTypesConfig(asScene) ; Map<string, int[]>

    int allRefTypeIds   = FastMap_Values(specifiedSceneConfig) ; Array<int>
    int mergedTypes     = FastArray("<Form>") ; std::array<Form>(4)

    int i = 0
    while (i < FastArray_Size(allRefTypeIds))
        int typeArray = FastArray_GetObject(allRefTypeIds, i) ; Array<int>
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

    return FastArray_ToPapyrusFormArray(mergedTypes)
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
    
    return FastArray_ToPapyrusFormArray(boundReferences)
endFunction

;/
    Retrieves the Scene's nth reference of a specific type that is currently bound to a ReferenceAlias.

    string  @asScene: The name of the Scene.
    string  @asRefType: The type of the scene reference (Escort, Escortee, Guard, Prisoner, etc...)
    int?    @aiIndex: The index of the reference to retrieve.

    returns (ObjectReference): The Scene's reference of a specific reference type.
/;
ObjectReference function GetSceneNthReferenceOfType(string asScene, string asRefType, int aiIndex = 0)
    int refsOfType = self.GetSceneRefsOfTypeObject(asScene, asRefType) ; JArray&

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
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Player_EscortLocation",  Pair(1, 0))
    self.CreateSceneRefTypeConfig(SCENE_ESCORT_TO_JAIL_01, "Guard_EscortLocation",  Pair(1, 0))
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

bool function HasQueuedScenes()
    return !Queue_Empty(__queuedScenes)
endFunction

;/
    Pushes a Scene into the queue.

    string  @asSceneName: The name of the scene.
/;
function PushScene(string asSceneName)
    Queue_PushString(__queuedScenes, asSceneName)
endFunction

;/
    Removes a Scene from the queue, and returns its name.

    returns (string): The name of the removed Scene
/;
string function PopScene()
    return Queue_PopString(__queuedScenes)
endFunction

;/
    Queues a Scene, or plays it if the queue is empty.

    string  @asSceneName: The name of the Scene to queue up or play.
/;
function QueueOrPlay(string asSceneName)
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
        EventManager.SendError("The reference received is none! (cannot queue Alias)", "SceneManager::QueueAlias")
        return
    endif

    int id = apRefAlias.GetID()
    FastIntMap_SetForm(__queuedAliases, id, akRef)
    Debug("SceneManager::QueueAlias", "Bound " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") with reference: " + FastIntMap_GetForm(__queuedAliases, id))

    if (abBindAlias)
        RPB_Utility.BindAliasTo(apRefAlias, akRef)
    endif

    Debug("SceneManager::QueueAlias", "__queuedAliases: " + GetContainerList(__queuedAliases))

    EventManager.SendWarning("Alias " + apRefAlias.GetName() + " (id: "+ apRefAlias.GetID() +") has not been assigned to any reference!", "SceneManager::QueueAlias", akRef == none)
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
        EventManager.SendError("Could not retrieve the Scene's Aliases of type " + asAliasRefType + ", cannot bind!", "SceneManager::BindSceneAliasGroup")
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

    EventManager.SendWarning("Received references are more than the available Aliases in the Scene! (Scene: "+ asScene +") (Alias Group: "+ asAliasRefType +") (Received: "+ refCount +", Available Aliases: "+ aliasCount +")", "SceneManager::BindSceneAliasGroup", refCount > aliasCount)
    EventManager.SendInfo("Received less references than the available Aliases in the Scene. (Scene: "+ asScene +") (Alias Group: "+ asAliasRefType +") (Received: "+ refCount +", Available Aliases: "+ aliasCount +")", "SceneManager::BindSceneAliasGroup", aliasCount > refCount)
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
        EventManager.SendError("Could not retrieve the Scene's Aliases of type " + asAliasRefType + ", cannot bind!", "SceneManager::BindSceneAlias")
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
function RestoreAliases()
    int aliasIds    = FastIntMap_Keys(__queuedAliases)   ; FastArray<int>
    int aliasRefs   = FastIntMap_Values(__queuedAliases) ; FastArray<Form>

    ; Debug("SceneManager::RestoreAliases", "Restoring " + FastArray_Size(aliasIds) + " Aliases (ids: "+ GetContainerList(aliasIds) +") with references: " + GetContainerList(aliasRefs))
    
    int i = 0
    while (i < FastArray_Size(aliasIds))
        int id                 = FastArray_GetInt(aliasIds, i)
        ObjectReference ref    = FastArray_GetForm(aliasRefs, i) as ObjectReference
        ; Debug("SceneManager::RestoreAliases", "Restoring Alias (id: "+ id +") with reference: " + ref)

        ReferenceAlias refAlias = self.GetAliasByID(id) as ReferenceAlias
        ; Debug("SceneManager::RestoreAliases", "Restored " + refAlias.GetName() + " (id: "+ refAlias.GetID() +") with reference: " + ref)

        RPB_Utility.BindAliasTo(refAlias, ref)
        i += 1
    endWhile

    ; Possible ISSUE: Might clear the Aliases of the Scene after the queued scene (3rd Scene in the queue, since the 2nd scene will have the Aliases queued from the first call), needs to be tested
    Object_Clear(__queuedAliases)
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
    float stackStart = StartBenchmark()
    self.RestoreAliases()

    Form[] params   = self.GetSceneReferences(name)
    Alias[] aliases = self.GetSceneAliases(name, true)
    string type     = self.GetSceneType(name)

    ; float sceneRefTypesBench = StartBenchmark()
    ; int i = 0
    ; string[] sceneRefTypes = self.GetSceneRefTypes(name)
    ; while (i < sceneRefTypes.Length)
    ;     Form[] paramsOfType = self.GetSceneReferencesOfType(name, sceneRefTypes[i])
    ;     DebugWithArgs("SceneManager::OnSceneStart", name, "["+ sceneRefTypes[i] +"] "+ name +" Params: " + paramsOfType)
    ;     i += 1
    ; endWhile
    ; EndBenchmark(sceneRefTypesBench, "SceneManager::OnSceneStart")

    self.HandleSceneGlobalControlFlow(type, name)

    if (type == CATEGORY_ARREST_START)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")

        EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_BEGIN, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_JAIL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_BEGIN, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_CELL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_02) ; override
            escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
            prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")
        endif

        DebugWithArgs("SceneManager::OnSceneStart", name, "escort: " + escort + ", prisoners: " + prisoners)
        
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

    Debug("SceneManager::OnSceneStart", self.GetSceneParametersDebugInfo(sender, name))
    EndBenchmark(stackStart, "SceneManager::OnSceneStart EVENT STACK -> " + name)
endEvent

event OnScenePlaying(string name, int phaseEvent, int phase, Scene sender)
    string type = self.GetSceneType(name)

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

        if (name == SCENE_ESCORT_TO_CELL_01)
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

    if (type == CATEGORY_ARREST_START)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")

        string secondaryEvent = string_if (name == SCENE_ARREST_START_PRISON_01, "Arrest in Prison", "null")

        EventManager.SendArrestSceneBulkEvent(name, EVENT_ARREST_END, arrestees, escort, secondaryEvent)

    elseif (type == CATEGORY_ESCORT_TO_JAIL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] arrestees = self.GetSceneReferencesOfType(name, "Escortee")
        
        EventManager.SendPrisonSceneBulkEvent(name, EVENT_ESCORT_END, arrestees, escort)

    elseif (type == CATEGORY_ESCORT_TO_CELL)
        Actor escort     = self.GetSceneNthReferenceOfType(name, "Escort") as Actor
        Form[] prisoners = self.GetSceneReferencesOfType(name, "Escortee")

        if (name == SCENE_ESCORT_TO_CELL_02) ; override
            escort      = self.GetSceneNthReferenceOfType(name, "Guard") as Actor
            prisoners   = self.GetSceneReferencesOfType(name, "Prisoner")
        endif
        
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
    
    self.ResetSceneOverride()
    float paramsBenchmark = StartBenchmark()
    Form[] params = self.GetSceneReferences(name)
    EndBenchmark(paramsBenchmark, "SceneManager::OnSceneEnd::GetSceneReferences() NEW")
    Alias[] aliases = self.GetSceneAliases(name, true)
    Debug("SceneManager::OnSceneEnd", self.GetSceneParametersDebugInfo(sender, name))
    Debug("SceneManager::OnSceneEnd", "Ended Scene: " + name)

    ; self.UnbindAliases(name) ; (Need to fix this, since they get unbound after they should, for now, uncommented) ERROR: EventManager::SendPrisonSceneBulkEvent() -> No prisoners provided for bulk scene event!
    self.PlayQueued()
    __isScenePlaying = false ; Scene has finished playing
    self.ResetGlobals()
    self.OnResumeSceneBlocked()
endEvent

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

    Debug("SceneManager::StartEscortToCell", "akEscortLeader: " + akEscortLeader + ", akEscortedPrisoner: " + akEscortedPrisoner)

    string name = SCENE_ESCORT_TO_CELL_01
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

    int i = 0
    while (i < params.Length)
        ObjectReference param = params[i] as ObjectReference
        if (param != none)
            ReferenceAlias paramBinder = aliases[i] as ReferenceAlias
            string paramBinderSignature = "["+ paramBinder.GetName() +" < ("+ paramBinder.GetID() +")>]"
            string baseId     = "[BaseID: " + param.GetBaseObject().GetFormID() + "] "
            string formId     = "[FormID: " + param.GetFormID() + "] "
            
            string objectBaseName   = param.GetBaseObject().GetName()
            string objectClassName  = param.GetName()
            string whichNameProperty = string_if (objectClassName != "", objectClassName, objectBaseName)
            string objectName = "[Name: " + whichNameProperty + "] "
            emptyParams = false

            debugInfo += "\t["+i+"]: " + paramBinderSignature + " " + param + " " + formId + baseId + string_if (objectName != "[Name: ] ", objectName) + "\n"
        endif
        i += 1
    endWhile
    
    if (emptyParams)
        return sceneName + " " + sender + " - No Parameters, Scene expected: " + params.Length + " parameters!" ; " - No Parameters, Scene expected: need a way to find scene required params
    endif

    return sceneName + " " + sender + "\nParameters: [\n" + debugInfo + "]"
endFunction
