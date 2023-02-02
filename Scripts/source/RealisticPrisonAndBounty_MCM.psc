Scriptname RealisticPrisonAndBounty_MCM extends SKI_ConfigBase  

import RealisticPrisonAndBounty_Util

; ==============================================================================
; Constants
; ==============================================================================

bool property IS_DEBUG = false autoreadonly
bool property ENABLE_TRACE = false autoreadonly

; ==============================================================================
; MCM Option Flags
int property OPTION_ENABLED  = 0x00 autoreadonly
int property OPTION_DISABLED = 0x01 autoreadonly
; ==============================================================================

; ==============================================================================
; GENERAL
int property GENERAL_DEFAULT_ATTACK_ON_SIGHT_BOUNTY = 3000 autoreadonly

; ==============================================================================
; ARREST
int  property ARREST_DEFAULT_MIN_BOUNTY                     = 500 autoreadonly
int  property ARREST_DEFAULT_GUARANTEED_PAYABLE_BOUNTY      = 1500 autoreadonly
int  property ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY         = 1500 autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT  = 33 autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT     = 200 autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT   = 33 autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT      = 200 autoreadonly
bool property ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE         = true autoreadonly
bool property ARREST_DEFAULT_ALLOW_ARREST_TRANSFER          = true autoreadonly
bool property ARREST_DEFAULT_ALLOW_UNCONSCIOUS_ARREST       = true autoreadonly
int  property ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY            = 0 autoreadonly
int  property ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY            = 1000 autoreadonly
int  property ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY            = 4000 autoreadonly
; ==============================================================================
; FRISKING
bool property FRISKING_DEFAULT_ALLOW                            = true autoreadonly
int  property FRISKING_DEFAULT_MIN_BOUNTY                       = 500 autoreadonly
int  property FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY        = 1500 autoreadonly
int  property FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY           = 2000 autoreadonly
int  property FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE    = 33 autoreadonly
int  property FRISKING_DEFAULT_FRISK_THOROUGHNESS               = 400 autoreadonly
int  property FRISKING_DEFAULT_CONFISCATE_ITEMS                 = 3000 autoreadonly
bool property FRISKING_DEFAULT_STRIP_IF_STOLEN_FOUND            = true autoreadonly
int  property FRISKING_DEFAULT_NUMBER_STOLEN_ITEMS_REQUIRED     = 10 autoreadonly
; ==============================================================================
; UNDRESSING
bool property UNDRESSING_DEFAULT_ALLOW                  = true autoreadonly
int  property UNDRESSING_DEFAULT_MIN_BOUNTY             = 1500 autoreadonly
bool property UNDRESSING_DEFAULT_WHEN_DEFEATED          = true autoreadonly
bool property UNDRESSING_DEFAULT_AT_CELL                = true autoreadonly
bool property UNDRESSING_DEFAULT_AT_CHEST               = true autoreadonly
int  property UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY      = 3000 autoreadonly
bool property UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED   = true autoreadonly
int  property UNDRESSING_DEFAULT_STRIP_THOROUGHNESS     = 10 autoreadonly
bool property UNDRESSING_DEFAULT_ALLOW_CLOTHES          = false autoreadonly
int  property UNDRESSING_DEFAULT_REDRESS_BOUNTY         = 2000 autoreadonly
bool property UNDRESSING_DEFAULT_REDRESS_WHEN_DEFEATED  = true autoreadonly
bool property UNDRESSING_DEFAULT_REDRESS_AT_CELL        = true autoreadonly
bool property UNDRESSING_DEFAULT_REDRESS_AT_CHEST       = true autoreadonly
; ==============================================================================
; CLOTHING
bool property CLOTHING_DEFAULT_ALLOW_CLOTHES          = false autoreadonly
int  property CLOTHING_DEFAULT_REDRESS_BOUNTY         = 2000 autoreadonly
bool property CLOTHING_DEFAULT_REDRESS_WHEN_DEFEATED  = true autoreadonly
bool property CLOTHING_DEFAULT_REDRESS_AT_CELL        = true autoreadonly
bool property CLOTHING_DEFAULT_REDRESS_AT_CHEST       = true autoreadonly
; ==============================================================================
; PRISON
int    property PRISON_DEFAULT_TIMESCALE                    = 60 autoreadonly
int    property PRISON_DEFAULT_BOUNTY_TO_DAYS               = 100 autoreadonly
int    property PRISON_DEFAULT_MIN_SENTENCE_DAYS            = 10 autoreadonly
int    property PRISON_DEFAULT_MAX_SENTENCE_DAYS            = 365 autoreadonly
bool   property PRISON_DEFAULT_ALLOW_UNCONDITIONAL_PRISON   = false autoreadonly
bool   property PRISON_DEFAULT_SENTENCE_PAYS_BOUNTY         = false autoreadonly
bool   property PRISON_DEFAULT_FAST_FORWARD                 = true autoreadonly
int    property PRISON_DEFAULT_DAY_FAST_FORWARD             = 5 autoreadonly
bool   property PRISON_DEFAULT_HANDS_BOUND                  = false autoreadonly
int    property PRISON_DEFAULT_HANDS_BOUND_BOUNTY           = 4000 autoreadonly
bool   property PRISON_DEFAULT_HANDS_BOUND_RANDOMIZE        = true autoreadonly
string property PRISON_DEFAULT_CELL_LOCK_LEVEL              = "Expert" autoreadonly
; ==============================================================================
; RELEASE
bool property RELEASE_DEFAULT_GIVE_ITEMS_BACK           = true autoreadonly
int  property RELEASE_DEFAULT_GIVE_ITEMS_BACK_BOUNTY    = 0 autoreadonly
bool property RELEASE_DEFAULT_REDRESS                   = true autoreadonly
; ==============================================================================
; ESCAPE
int property ESCAPE_DEFAULT_BOUNTY_PERCENT          = 15 autoreadonly
int  property ESCAPE_DEFAULT_BOUNTY_FLAT            = 1000 autoreadonly
bool property ESCAPE_DEFAULT_ALLOW_SURRENDER        = true autoreadonly
bool property ESCAPE_DEFAULT_FRISK_ON_CAPTURE       = true autoreadonly
bool property ESCAPE_DEFAULT_UNDRESS_ON_CAPTURE     = true autoreadonly
; ==============================================================================
; BOUNTY
bool property BOUNTY_DEFAULT_GENERAL_ENABLE_DECAY   = true autoreadonly
bool property BOUNTY_DEFAULT_GENERAL_UPDATE_HOURS   = 1 autoreadonly
bool property BOUNTY_DEFAULT_ENABLE_DECAY           = true autoreadonly
bool property BOUNTY_DEFAULT_DECAY_IN_PRISON        = true autoreadonly
int  property BOUNTY_DEFAULT_BOUNTY_LOST_PERCENT    = 5 autoreadonly
int  property BOUNTY_DEFAULT_BOUNTY_LOST_FLAT       = 200 autoreadonly
; ==============================================================================
; BOUNTY HUNTERS
bool property BOUNTY_HUNTERS_DEFAULT_ENABLE            = true autoreadonly
bool property BOUNTY_HUNTERS_DEFAULT_ALLOW_OUTLAWS     = true autoreadonly
int  property BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY        = 2500 autoreadonly
int  property BOUNTY_HUNTERS_DEFAULT_MIN_BOUNTY_GROUP  = 6000 autoreadonly

; ==============================================================================
; End Constants
; ==============================================================================


; Timescales
; =======================================
GlobalVariable property NormalTimescale auto
GlobalVariable property PrisonTimescale auto
; =======================================

string[] _holds

int property INDEX_WHITERUN     = 0 autoreadonly
int property INDEX_WINTERHOLD   = 1 autoreadonly
int property INDEX_EASTMARCH    = 2 autoreadonly
int property INDEX_FALKREATH    = 3 autoreadonly
int property INDEX_HAAFINGAR    = 4 autoreadonly
int property INDEX_HJAALMARCH   = 5 autoreadonly
int property INDEX_THE_RIFT     = 6 autoreadonly
int property INDEX_THE_REACH    = 7 autoreadonly
int property INDEX_THE_PALE     = 8 autoreadonly

string[] function GetHoldNames()
    if (! _holds)
        _holds = new string[9]
        _holds[0] = "Whiterun"
        _holds[1] = "Winterhold"
        _holds[2] = "Eastmarch"
        _holds[3] = "Falkreath"
        _holds[4] = "Haafingar"
        _holds[5] = "Hjaalmarch"
        _holds[6] = "The Rift"
        _holds[7] = "The Reach"
        _holds[8] = "The Pale"
        Debug(self, "MCM::GetHoldNames", "Allocated holds string[]", IS_DEBUG)
    endif

    return _holds
endFunction

int function GetHoldCount()
    if (! _holds)
        Warn(self, "GetHoldCount", "_holds has not been initialized! (cannot retrieve count)")
        return -1
    endif

    return _holds.Length
endFunction

int property LeftPanelIndex
    int function get()
        return 0
    endFunction
endProperty

int property RightPanelIndex
    int function get()
        return 5
    endFunction
endProperty

int property LeftPanelSize
    int function get()
        return RightPanelIndex
    endFunction
endProperty

int property RightPanelSize
    int function get()
        return _holds.Length
    endFunction
endProperty

function InitializePages()
    Pages = new string[12]
    Pages[0] = RealisticPrisonAndBounty_MCM_General.GetPageName()
    Pages[1] = RealisticPrisonAndBounty_MCM_Arrest.GetPageName()
    Pages[2] = RealisticPrisonAndBounty_MCM_Frisking.GetPageName()
    Pages[3] = RealisticPrisonAndBounty_MCM_Undress.GetPageName()
    Pages[4] = RealisticPrisonAndBounty_MCM_Clothing.GetPageName()
    Pages[5] = RealisticPrisonAndBounty_MCM_Prison.GetPageName()
    Pages[6] = RealisticPrisonAndBounty_MCM_Release.GetPageName()
    Pages[7] = RealisticPrisonAndBounty_MCM_Escape.GetPageName()
    Pages[8] = RealisticPrisonAndBounty_MCM_Bounty.GetPageName()
    Pages[9] = RealisticPrisonAndBounty_MCM_BHunters.GetPageName()
    Pages[10] = RealisticPrisonAndBounty_MCM_Leveling.GetPageName()
    Pages[11] = RealisticPrisonAndBounty_MCM_Status.GetPageName()
endFunction

function SetDefaultTimescales()
    if (! NormalTimescale)
        NormalTimescale.SetValueInt(Game.GetGameSettingInt("TimeScale"))
        Log(self, "SetDefaultTimescales", "Timescale has been set = " + NormalTimescale.GetValueInt())
    endif
endFunction

int function __findCachedOption(int optionId)
    int _optionsArray = JMap.getObj(cacheMap, CurrentPage)

    int i = 0
    while (i < JArray.count(_optionsArray))
        int keyHolder       = JArray.getObj(_optionsArray, i)
        int containerKey    = JIntMap.getNthKey(keyHolder, 0)
        int containerValue  = JIntMap.getInt(keyHolder, containerKey)

        if (optionId == containerValue)
            Debug(self, "MCM::__findCachedOption", "Found cached option at index " + containerKey + ", option: " + containerValue)
            return containerKey
        endif
        i += 1
    endWhile
    
    Warn(self, "__findCachedOption", "Could not find a cached option for " + CurrentPage + "::" + optionId + "!")
    return -1
endFunction

function UpdateIndex(int optionId)
    ; float start = StartBenchmark()

    int cachedOption = __findCachedOption(optionId)
    if (cachedOption != -1)
        _currentOptionIndex = cachedOption
        ; EndBenchmark(start)
        return
    endif

    ; Cache not found, proceed with the slow approach
    string[] optionKeys = JMap.allKeysPArray(optionsMap)

    int optionIndex = 0
    while (optionIndex < optionKeys.Length)
        string optionKey = optionKeys[optionIndex]

        Debug(self, "UpdateIndex", "Key is " + optionKey + ", updating index...", IS_DEBUG)
        int _optionsArray = JMap.getObj(optionsMap, optionKey) ; optionsMap[undressing::allowUndressing]

        int i = 0
        while (i < JArray.count(_optionsArray))
            ; Get containers inside the array (Option Maps)
            int _container = JArray.getObj(_optionsArray, i)
            int _containerKey = JIntMap.nextKey(_container)
            int _containerValue = JIntMap.getInt(_container, _containerKey)

            if (_containerKey == optionId)
                __addOptionCache(optionId, i) ; Create cache for this option at this index, for next time
                _currentOptionIndex = i
                return
            endif
            i += 1
        endWhile
        optionIndex += 1
    endWhile
    ; EndBenchmark(start)
endFunction

; ============================================================


; Utility Functions
; ============================================================

function SetSliderOptions(float minRange, float maxRange, float intervalSteps = 1.0, float defaultValue = 1.0, float startValue = 1.0)
    SetSliderDialogRange(minRange, maxRange)
    SetSliderDialogInterval(intervalSteps)
    SetSliderDialogDefaultValue(defaultValue)
    SetSliderDialogStartValue(startValue)
endFunction

; ============================================================

;/
    Sets a flag to an option for the current index (the hold) based on its ID.
    If the dependency is met, the flag will be ENABLED, otherwise it will be DISABLED.

    The option could be a toggle, that depends on another toggle, in which case
    the toggle passed in will only be ENABLED if the dependency toggle is active.

    returns true if the option from optionIdList was ENABLED, false if the option was DISABLED.
/;
bool function SetOptionDependencyBool(int[] optionIdList, bool dependency, bool storePersistently = true)
    int enabled  = OPTION_FLAG_NONE
    int disabled = OPTION_FLAG_DISABLED

    ; LogProperty(self, "SetOptionDependencyBool", "Value is " + "(" + _currentOptionIndex + ")", LOG_WARN())

    SetOptionFlags(optionIdList[CurrentOptionIndex], int_if (dependency, enabled, disabled))


    if (dependency)
        return true
    endif

    return false
endFunction

bool function SetOptionDependencyBoolSingle(int optionId, bool dependency, bool storePersistently = true)
    int enabled  = OPTION_FLAG_NONE
    int disabled = OPTION_FLAG_DISABLED

    ; Log(self, "SetOptionDependencyBoolSingle", "Value is " + "(" + _currentOptionIndex + ")", LOG_WARN())

    SetOptionFlags(optionId, int_if (dependency, enabled, disabled))
    ; Log(self, "SetOptionDependencyBoolSingle", "optionId " + "(" + _currentOptionIndex + ")", LOG_WARN())


    if (dependency)
        return true
    endif

    return false
endFunction

;/
    Toggles the specified option by id, optionally stores it persistently into the save

    returns the toggle state after it has been toggled.
/;
; bool function ToggleOption(int optionId, bool storePersistently = true)
;     bool optionState = GetOptionIntValue(optionId)
    
;     ; Set the toggle option value (display checked or unchecked)
;     ; If the option was checked, uncheck it and vice versa.
;     SetToggleOptionValue(optionId, bool_if (optionState, false, true))

;     ; string _key = GetKeyFromOption(optionId)

;     ; Store the value persistently
;     if (storePersistently)
;         SetOptionValueBool(optionId, bool_if (optionState, false, true))
;     endif

;     ; Return the inverse since that's what we stored it as when we toggled.
;     return ! optionState
; endFunction

int _currentOptionIndex = -1
int property CurrentOptionIndex
    int function get()
        if (_currentOptionIndex < 0)
            LogProperty(self, "CurrentOptionIndex", "Value is undefined " + "(" + _currentOptionIndex + ")", LOG_ERROR())
        endif

        return _currentOptionIndex
    endFunction
endProperty


event OnConfigInit()
    ModName = "Realistic Prison and Bounty"
    InitializePages()

    optionsMap = JMap.object()
    JValue.retain(optionsMap)

    cacheMap = JMap.object()
    JValue.retain(cacheMap)
endEvent

int optionsMap
int cacheMap

;/
    Example array of option maps:
    If the array has an ID of 3, and the maps have their respective ID (4, 6, 8, 10, 12)
    3:  [
            4:  [1026 => true]
            6:  [1028 => false]
            8:  [1054 => true]
            10: [1086 => true]
            12: [1110 => false]
        ]
/;
bool function IsOptionInArray(int arrayID, int optionID)
    int i = 0
    while (i < JArray.count(arrayID))
        int _container = JArray.getObj(arrayID, i) ; Gets the container inside the array at i
        int _containerKey = JIntMap.nextKey(_container) ; Gets the container's next key for each iteration

        if (_containerKey == optionID)
            ; We found the option map inside the array
            return true
        endif
        i += 1
    endWhile
    
    Trace(self, "MCM::IsOptionInArray", "Array does not exist or has no items!", i == 0 && ENABLE_TRACE)
    Trace(self, "MCM::IsOptionInArray", "Option not found in array!", i != 0 && ENABLE_TRACE)

    return false
endFunction

bool function __getBoolOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == -1)
        return false ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    bool _containerValue = JIntMap.getInt(_container, _containerKey) as bool

    Trace(self, "__getBoolOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)

    return _containerValue
endFunction

int function __getIntOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == -1)
        return -1 ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    int _containerValue = JIntMap.getInt(_container, _containerKey)

    Trace(self, "MCM::__getFloatOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)
    return _containerValue
endFunction

float function __getFloatOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == -1)
        return -1 ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    float _containerValue = JIntMap.getFlt(_container, _containerKey)

    Trace(self, "MCM::__getFloatOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)
    return _containerValue
endFunction

string function __getStringOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == -1)
        return -1 ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    string _containerValue = JIntMap.getStr(_container, _containerKey)

    Trace(self, "MCM::__getFloatOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)
    return _containerValue
endFunction

function SetBoolOptionValue(string _key, bool value)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == -1)
        return ; Array does not exist
    endif

    int _container = JArray.getObj(_array, CurrentOptionIndex)
    int _containerKey = JIntMap.getNthKey(_container, 0)

    JIntMap.setInt(_container, _containerKey, value as int)
    SetToggleOptionValue(_containerKey, value)

    bool retrievedValue = JIntMap.getInt(_container, _containerKey)

    Trace(self, "SetBoolOptionValue", "Set new value of " + (retrievedValue as bool) + " to Option ID " + _containerKey + " for key " + _key, ENABLE_TRACE)
endFunction

function ToggleOption(string _key)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == -1)
        return ; Array does not exist
    endif

    int _container = JArray.getObj(_array, CurrentOptionIndex)
    int i = 0
    while (i < JArray.count(_array))
        int _containerKey = JIntMap.nextKey(_container)
        bool _containerValue = JIntMap.getInt(_container, _containerKey) as bool
        if (i == CurrentOptionIndex)
            JIntMap.setInt(_container, _containerKey, (!_containerValue) as int) ; Toggle value
            SetToggleOptionValue(_containerKey, !_containerValue)
            Debug(self, "ToggleOption", "[" + _key +"] " + "Container: " + _container  + ", Container Key: " + _containerKey + " (" + i + " iterations)", IS_DEBUG)
            Debug(self, "ToggleOption", "Set new value of " + !_containerValue + " to Option ID " + _containerKey + " for key " + _key, IS_DEBUG)
            return
        endif
        i += 1
    endWhile

endFunction

;/
    Gets the options array at the specified key from the underlying internal map.

    string  @_key: The key to retrieve the array from.
    bool    @handleError: Whether to handle and log errors when retrieving the array.

    returns: the array containing the options at @_key, or -1 on failure if @handleError is true. 
/;
int function __getOptionsArrayAtKey(string _key, bool handleError = true)
    int _array = JMap.getObj(optionsMap, _key)
    if (_array == 0 && handleError)
        Error(self, "MCM::__getOptionsArrayAtKey", "__getOptionsArrayAtKey(" + _key + "): Container does not exist! (this error is normal the first time the MCM is rendered)")
        return -1
    endif

    return _array
endFunction

bool function __unloadOption(string _key)
    float startTime = StartBenchmark()

    int keyHolder = __getOptionsArrayAtKey(_key)

    if (keyHolder == -1)
        return false ; Array does not exist
    endif

    JDB.solveObjSetter(".storage::options::" + _key, keyHolder)
    JMap.setObj(optionsMap, _key, 0)
    EndBenchmark(startTime)
    Debug(self, "__unloadOption", "Finished execution")

    return true
endFunction

bool function __loadOption(string _key)
    float startTime = StartBenchmark()

    int option = JDB.solveObj(".storage::options::" + _key)
    JMap.setObj(optionsMap, _key, option)

    EndBenchmark(startTime)
    Debug(self, "__loadOption", "Finished execution")
    return option
endFunction


function __unloadAllOptionsExceptPage(string page)
    string[] keys = JMap.allKeysPArray(optionsMap)

    int keyIndex = 0
    while (keyIndex < keys.Length)
        string _key = keys[keyIndex]
        int keyHolder = __getOptionsArrayAtKey(_key, false)

        if (StringUtil.Find(page, _key) == -1)
            if (!keyHolder)
                Debug(self, "__unloadAllOptionsExceptPage", "The key " + _key + " does not exist.", IS_DEBUG)
            else
                __unloadOption(_key)
            endif
        else
            Debug(self, "__unloadAllOptionsExceptPage", "Key " + _key + " is part of page, ignoring unload...", IS_DEBUG)
        endif
        keyIndex += 1
    endWhile


endFunction

function __unloadAllOptions()
    string[] keys = JMap.allKeysPArray(optionsMap)

    int keyIndex = 0
    while (keyIndex < keys.Length)
        string _key = keys[keyIndex]
        int keyHolder = __getOptionsArrayAtKey(_key, false)

        if (!keyHolder)
            Debug(self, "__unloadAllOptions", "The key " + _key + " does not exist.", IS_DEBUG)
        else
            __unloadOption(_key)
        endif
        keyIndex += 1
    endWhile
endFunction

;/
    Adds the specified option container to an array at the specified key to the underlying internal map.

    string  @_key: The key to add the option into.
    int     @optionContainer: The option to be added.
/;
function __addOptionAtKey(string _key, int optionContainer)
    int _array = __getOptionsArrayAtKey(_key, false)

    if (_array == 0)
        Trace(self, "MCM::__addOptionAtKey", "Array at key " + _key + " does not exist yet, created ARRAY with ID: " + _array, ENABLE_TRACE)
        _array = JArray.object()
    endif

    ; Add option container map to array
    JArray.addObj(_array, optionContainer)

    Trace(self, "MCM::__addOptionAtKey", "Adding MAP ID: " + optionContainer + " to ARRAY ID: " + _array, ENABLE_TRACE)
    Trace(self, "MCM::__addOptionAtKey", "Adding ARRAY ID: " + _array + " to optionsMap[" +_key + "]", ENABLE_TRACE)
    Debug(self, "MCM::__addOptionAtKey", "Adding Option " + optionContainer + " to " + "[" +_key + "]", IS_DEBUG)

    ; Add the array containing all containers related to _key to the map at _key
    JMap.setObj(optionsMap, _key, _array)
endFunction

;/
    Adds caching to the specified option when updating anything based on its Option ID.
    The cache should contain all of the page's Option ID's with their respective index,
    hence, this function should be used when rendering multiple options for a page.

    int     @optionId: The option's id to be cached.
    int     @index: The index to bind to this option to know what to update.
/;
function __addOptionCache(int optionId, int index)
    int _cacheArray = JMap.getObj(cacheMap, CurrentPage)
    if (!_cacheArray)
        _cacheArray = JArray.object()
    endif
    
    JArray.addObj(_cacheArray, __createPairInt(index, optionId))
    JMap.setObj(cacheMap, CurrentPage, _cacheArray)
endFunction

;/
    Creates a pair structure for integers.

    int     @first: The first element in the pair.
    int     @second: The second element in the pair.

    returns: The pair as a container ID.
/;
int function __createPairInt(int first, int second)
    int _container = JIntMap.object()
    JIntMap.setInt(_container, first, second)
    return _container
endFunction

;/
    Creates a container (JIntMap) with the specified optionId and a bool value.

    int     @optionId: The id of the option to be created.
    bool    @value: The default value of the option.
    
    returns: The container's id.
/;
int function __createOptionBool(int optionId, bool value)
    int _container = __createPairInt(optionId, (value as int))
    Debug(self, "MCM::__createOptionBool", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", IS_DEBUG)
    return _container
endFunction

;/
    Creates a container (JIntMap) with the specified optionId and an int value.

    int     @optionId: The id of the option to be created.
    int    @value: The default value of the option.
    
    returns: The container's id.
/;
int function __createOptionInt(int optionId, int value)
    int _container = __createPairInt(optionId, value)
    Debug(self, "MCM::__createOptionInt", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")")
    return _container
endFunction

;/
    Creates a container (JIntMap) with the specified optionId and a float value.

    int     @optionId: The id of the option to be created.
    float   @value: The default value of the option.
    
    returns: The container's id.
/;
int function __createOptionFloat(int optionId, float value)
    int _container = JIntMap.object()
    JIntMap.setFlt(_container, optionId, value)

    Debug(self, "MCM::__createOptionFloat", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", IS_DEBUG)
    return _container
endFunction

;/
    Creates a container (JIntMap) with the specified optionId and a string value.

    int     @optionId: The id of the option to be created.
    string  @value: The default value of the option.
    
    returns: The container's id.
/;
int function __createOptionString(int optionId, string value)
    int _container = JIntMap.object()
    JIntMap.setStr(_container, optionId, value)

    Debug(self, "MCM::__createOptionString", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", IS_DEBUG)
    return _container
endFunction

int function AddOptionToggle(string text, bool defaultValue)
    return AddOptionToggleEx(text, defaultValue, 0)
endFunction

int function AddOptionSlider(string text, float defaultValue)
    return AddOptionSliderEx(text, defaultValue, 0)
endFunction

int function AddOptionMenu(string text, string defaultValue)
    return AddOptionMenuEx(text, defaultValue, 0)
endFunction
;/
    Add to map:
    optionsMap["undressing::allowUndressing"] = 3
    where 3 is the container containing all the options related to this key
    
    3 (array): [10, 11, 12, 13, 14]: where 10 through 14 are maps to their respective options.
    10-14 (int map): key: 1026, value: true
/;
int function AddOptionToggleEx(string text, bool defaultValue, int index)
    string _key = CurrentPage + "::" + TrimString(text) ; undressing::allowUndressing
    bool value = __getBoolOptionValue(_key, index)
    int optionId = AddToggleOption(text, bool_if (value != -1, value, defaultValue))
    
    int mapArray = __getOptionsArrayAtKey(_key, false)

    Trace(self, "MCM::AddOptionToggleEx", "Array ID " + mapArray + " exists in optionsMap[" +_key + "]", mapArray != 0 && ENABLE_TRACE)

    ; Does this option map exist in the array?
    if (mapArray && IsOptionInArray(mapArray, optionId))
        Trace(self, "AddOptionToggleEx", "Option ID " + optionId + " already exists in map inside Array ID " + mapArray + ", returning...", ENABLE_TRACE)
        return optionId
    endif

    __addOptionAtKey(_key, __createOptionBool(optionId, defaultValue))
    __addOptionCache(optionId, index)

    Debug(self, "MCM::AddOptionToggleEx", "cacheMap["+ CurrentPage +"]: " + "{" + index + ": " + optionId + "}")
    return optionId
endFunction

int function AddOptionSliderEx(string text, float defaultValue, int index)
    string _key = CurrentPage + "::" + TrimString(text) ; undressing::minimumBountyToUndress
    float value = __getFloatOptionValue(_key, index)
    int optionId = AddSliderOption(text, float_if (value != -1, value, defaultValue))
    
    int mapArray = __getOptionsArrayAtKey(_key, false)

    Trace(self, "MCM::AddOptionSliderEx", "Array ID " + mapArray + " exists in optionsMap[" +_key + "]", mapArray != 0 && ENABLE_TRACE)

    ; Does this option map exist in the array?
    if (mapArray && IsOptionInArray(mapArray, optionId))
        Trace(self, "AddOptionSliderEx", "Option ID " + optionId + " already exists in map inside Array ID " + mapArray + ", returning...", ENABLE_TRACE)
        return optionId
    endif

    __addOptionAtKey(_key, __createOptionFloat(optionId, defaultValue))
    __addOptionCache(optionId, index)

    Debug(self, "MCM::AddOptionSliderEx", "cacheMap["+ CurrentPage +"]: " + "{" + index + ": " + optionId + "}")

    return optionId
endFunction

int function AddOptionMenuEx(string text, string defaultValue, int index)
    string _key = CurrentPage + "::" + TrimString(text) ; prison::cellDoorLockLevel
    string value = __getStringOptionValue(_key, index)
    int optionId = AddMenuOption(text, string_if (value != -1, value, defaultValue))
    
    int mapArray = __getOptionsArrayAtKey(_key, false)

    Trace(self, "MCM::AddOptionMenuEx", "Array ID " + mapArray + " exists in optionsMap[" +_key + "]", mapArray != 0 && ENABLE_TRACE)

    ; Does this option map exist in the array?
    if (mapArray && IsOptionInArray(mapArray, optionId))
        Debug(self, "AddOptionMenuEx", "Option ID " + optionId + " already exists in map inside Array ID " + mapArray + ", returning...")
        return optionId
    endif

    __addOptionAtKey(_key, __createOptionString(optionId, defaultValue))
    __addOptionCache(optionId, index)

    Debug(self, "MCM::AddOptionMenuEx", "cacheMap["+ CurrentPage +"]: " + "{" + index + ": " + optionId + "}")

    return optionId
endFunction

int function GetOptionFromMap(string _key)
    float startTime = StartBenchmark()

    int arrayInsideMap = JMap.getObj(optionsMap, _key) ; Get the array inside the map
    bool keyExists = arrayInsideMap != 0

    if (!keyExists)
        Debug(self, "MCM::GetOptionFromMap", "Key: " + _key + " does not exist in the map, returning...", IS_DEBUG)
        return -1
    endif

    int i = 0
    while (i < JArray.count(arrayInsideMap))
        ; Get the map inside the array at i
        int _container      = JArray.getObj(arrayInsideMap, i)
        int _containerKey   = JIntMap.nextKey(_container)
        int _containerValue = JIntMap.getInt(_container, _containerKey)

        string _hold = GetHoldNames()[i]

        Debug(self, "MCM::GetOptionFromMap", "[" + _hold + "] " + "\t[ARRAY ID: " + arrayInsideMap + " (" + _key + ")] " + "_container id: " + _container + " (key: " + _containerKey + ", value: " + (_containerValue) + ")", IS_DEBUG)

        i += 1
    endWhile

    Debug(self, "MCM::GetOptionFromMap", "Returned OPTION_NOT_FOUND", IS_DEBUG)
    ; EndBenchmark(startTime)

    return -1 ; OPTION_NOT_FOUND
endFunction

;/
    Retrieves the option specified by the key for the current option index,
    the index is invisible to the user and will update based on where the cursor is in the menu to account for all holds.

    e.g: GetOption(undressing::allowUndressing) with a CurrentOptionIndex of 0, will retrieve that option for Whiterun,
    whereas with the index set to 1, it will retrieve Winterhold's instead.

    string  @_key: The key to retrieve the option from.
    returns: The option's id on success, -1 on failure.
 /;
int function GetOption(string _key)
    int optionArray = __getOptionsArrayAtKey(_key) ; Get the array for this key

    if (optionArray == -1)
        Error(self, "MCM::GetOptionCurrentIndex", "Key: " + _key + " does not exist in the map, returning...")
        return -1
    endif

    int _optionMap = JArray.getObj(optionArray, CurrentOptionIndex)

    if (_optionMap == 0)
        Error(self, "MCM::GetOptionCurrentIndex", "Container: " + _optionMap + " does not exist at key " + _key + ", returning...")
        return -1
    endif

    int _optionId  = JIntMap.getNthKey(_optionMap, 0)
    int _optionValue = JIntMap.getInt(_optionMap, _optionId)

    Debug(self, "MCM::GetOptionCurrentIndex", "[CurrentOptionIndex: " + CurrentOptionIndex + "] Returned Option ID: " + _optionId + ", with value: " + _optionValue, IS_DEBUG)
    return _optionId
endFunction

;/
    Retrieves the option's key from its id.

    int @optionId: The option's id.
    returns: The key for the option passed in.
/;
string function GetKeyFromOption(int optionId)
    string[] keys = JMap.allKeysPArray(optionsMap)

    int keyIndex = 0
    while (keyIndex < keys.Length)
        string _key = keys[keyIndex]

        ; Search all containers inside this key till we find optionId
        int _array = JMap.getObj(optionsMap, _key)

        int arrayIndex = 0
        while (arrayIndex < JArray.count(_array))
            int _container      = JArray.getObj(_array, arrayIndex)
            int _containerKey   = JIntMap.getNthKey(_container, 0)

            if (_containerKey == optionId)
                Debug(self, "GetKeyFromOption", "Found match for key: " + _key + " (Option ID: " +  optionId + ")", IS_DEBUG)
                return _key
            endif
            arrayIndex += 1
        endWhile
        keyIndex += 1
    endWhile
endFunction

function ListOptionMap()
    string[] keys = JMap.allKeysPArray(optionsMap)

    int keyIndex = 0
    while (keyIndex < keys.Length)
        string _key = keys[keyIndex]
        int _keyArray = JMap.getObj(optionsMap, _key)
        
        int arrayIndex = 0
        while (arrayIndex < JArray.count(_keyArray))
            int _optionContainer = JArray.getObj(_keyArray, arrayIndex)
            int _optionKey       = JIntMap.getNthKey(_optionContainer, 0)
            int _optionValue     = JIntMap.getInt(_optionContainer, _optionKey)

            string _hold = GetHoldNames()[arrayIndex]
            Info(self, "MCM::GetOptionFromMap", "[" + _hold + "] " + "\t[ARRAY ID: " + _keyArray + " (" + _key + ")] " + "container id: " + _optionContainer + " (key: " + _optionKey + ", value: " + (_optionValue) + ")", IS_DEBUG)
            arrayIndex += 1
        endWhile
        keyIndex += 1
    endWhile
endFunction

; Event Handling
; ============================================================================
event OnPageReset(string page)
    RealisticPrisonAndBounty_MCM_General.Render(self)
    RealisticPrisonAndBounty_MCM_Arrest.Render(self)
    RealisticPrisonAndBounty_MCM_Frisking.Render(self)
    RealisticPrisonAndBounty_MCM_Undress.Render(self)
    RealisticPrisonAndBounty_MCM_Clothing.Render(self)
    RealisticPrisonAndBounty_MCM_Prison.Render(self)
    RealisticPrisonAndBounty_MCM_Release.Render(self)
    RealisticPrisonAndBounty_MCM_Escape.Render(self)
    RealisticPrisonAndBounty_MCM_Bounty.Render(self)
    RealisticPrisonAndBounty_MCM_BHunters.Render(self)
    RealisticPrisonAndBounty_MCM_Leveling.Render(self)
    RealisticPrisonAndBounty_MCM_Status.Render(self)
endEvent

event OnOptionHighlight(int option)
    RealisticPrisonAndBounty_MCM_General.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Arrest.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Frisking.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Undress.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Prison.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Status.OnHighlight(self, option)
endEvent

event OnOptionDefault(int option)
    RealisticPrisonAndBounty_MCM_General.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Arrest.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Frisking.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Undress.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Prison.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnDefault(self, option)
    ; RealisticPrisonAndBounty_MCM_Status.OnDefault(self, option)
endEvent

event OnOptionSelect(int option)
    RealisticPrisonAndBounty_MCM_General.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Arrest.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Frisking.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Undress.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Prison.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnSelect(self, option)
    ; RealisticPrisonAndBounty_MCM_Status.OnDefault(self, option)
    
    if (IS_DEBUG)
        string optionKey = GetKeyFromOption(option)
        Debug(self, "MCM::OnOptionSelect", "Option ID: " + option + " (" + optionKey + ")")
    endif

    GetOptionFromMap(GetKeyFromOption(option))
endEvent



event OnOptionSliderOpen(int option)
    RealisticPrisonAndBounty_MCM_General.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Arrest.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Frisking.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Undress.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Prison.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Status.OnSliderOpen(self, option)

    if (IS_DEBUG)
        string optionKey = GetKeyFromOption(option)
        Debug(self, "MCM::OnOptionSliderOpen", "Option ID: " + option + " (" + optionKey + ")")
    endif

    GetOptionFromMap(GetKeyFromOption(option))


endEvent

event OnOptionSliderAccept(int option, float value)
    RealisticPrisonAndBounty_MCM_General.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Arrest.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Frisking.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Undress.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Clothing.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Prison.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Release.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Escape.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Bounty.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_BHunters.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Leveling.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Status.OnSliderAccept(self, option, value)
endEvent

event OnOptionMenuOpen(int option)
    RealisticPrisonAndBounty_MCM_General.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Arrest.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Frisking.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Undress.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Prison.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnMenuOpen(self, option)
    ; RealisticPrisonAndBounty_MCM_Status.OnMenuOpen(self, option)

    if (IS_DEBUG)
        string optionKey = GetKeyFromOption(option)
        Debug(self, "MCM::OnOptionMenuOpen", "Option ID: " + option + " (" + optionKey + ")")
    endif

    GetOptionFromMap(GetKeyFromOption(option))

endEvent

event OnOptionMenuAccept(int option, int index)
    RealisticPrisonAndBounty_MCM_General.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Arrest.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Frisking.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Undress.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Clothing.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Prison.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Release.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Escape.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Bounty.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_BHunters.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Leveling.OnMenuAccept(self, option, index)
    ; RealisticPrisonAndBounty_MCM_Status.OnMenuOpen(self, option)
endEvent

; ============================================================================