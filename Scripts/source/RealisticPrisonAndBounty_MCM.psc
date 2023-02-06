Scriptname RealisticPrisonAndBounty_MCM extends SKI_ConfigBase  

import RealisticPrisonAndBounty_Util

; ==============================================================================
; Constants
; ==============================================================================

bool property IS_DEBUG      = true autoreadonly
bool property ENABLE_TRACE  = false autoreadonly

; ==============================================================================
; Cached Option
int property CACHED_OPTION_INDEX    = 0 autoreadonly
int property CACHED_OPTION_NAME     = 1 autoreadonly
; ==============================================================================

; ==============================================================================
; Single Options
int property SINGLE_OPTION_INDEX    = 0 autoreadonly
; ==============================================================================
; Error Codes
int property GENERAL_ERROR     = -1500000 autoreadonly
int property ARRAY_NOT_EXIST   = -1500100 autoreadonly
int property OPTION_NOT_EXIST  = -1500200 autoreadonly
int property INVALID_VALUE     = -1500300 autoreadonly

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
int  property ESCAPE_DEFAULT_BOUNTY_PERCENT         = 15 autoreadonly
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
; Holds
int property INDEX_WHITERUN     = 0 autoreadonly
int property INDEX_WINTERHOLD   = 1 autoreadonly
int property INDEX_EASTMARCH    = 2 autoreadonly
int property INDEX_FALKREATH    = 3 autoreadonly
int property INDEX_HAAFINGAR    = 4 autoreadonly
int property INDEX_HJAALMARCH   = 5 autoreadonly
int property INDEX_THE_RIFT     = 6 autoreadonly
int property INDEX_THE_REACH    = 7 autoreadonly
int property INDEX_THE_PALE     = 8 autoreadonly
; ==============================================================================
; End Constants
; ==============================================================================

; Timescales
; =======================================
GlobalVariable property NormalTimescale auto
GlobalVariable property PrisonTimescale auto
; =======================================

string[] _holds

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
        Debug("GetHoldNames", "Allocated holds string[]", IS_DEBUG)
    endif

    return _holds
endFunction

int function GetHoldCount()
    if (! _holds)
        Warn("GetHoldCount", "_holds has not been initialized! (cannot retrieve count)")
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

int _currentOptionIndex = -1
int property CurrentOptionIndex
    int function get()
        if (_currentOptionIndex == -1)
            LogPropertyIf(self, "CurrentOptionIndex", "No index set, current option is of type SINGLE." + " (" + _currentOptionIndex + ")", IS_DEBUG, LOG_INFO())
        
        elseif (_currentOptionIndex < -1)
            LogProperty(self, "CurrentOptionIndex", "Value is undefined " + "(" + _currentOptionIndex + ")", LOG_ERROR())
        endif

        return _currentOptionIndex
    endFunction
endProperty

string property CurrentHold
    string function get()
        return _holds[CurrentOptionIndex]
    endFunction
endProperty

function InitializePages()
    Pages = new string[12]

    Pages[0] = "Whiterun"
    Pages[1] = "Winterhold"
    Pages[2] = "Eastmarch"
    Pages[3] = "Falkreath"
    Pages[4] = "Haafingar"
    Pages[5] = "Hjaalmarch"
    Pages[6] = "The Rift"
    Pages[7] = "The Reach"
    Pages[8] = "The Pale"

    ; Pages[0] = RealisticPrisonAndBounty_MCM_General.GetPageName()
    ; Pages[1] = RealisticPrisonAndBounty_MCM_Arrest.GetPageName()
    ; Pages[2] = RealisticPrisonAndBounty_MCM_Frisking.GetPageName()
    ; Pages[3] = RealisticPrisonAndBounty_MCM_Undress.GetPageName()
    ; Pages[4] = RealisticPrisonAndBounty_MCM_Clothing.GetPageName()
    ; Pages[5] = RealisticPrisonAndBounty_MCM_Prison.GetPageName()
    ; Pages[6] = RealisticPrisonAndBounty_MCM_Release.GetPageName()
    ; Pages[7] = RealisticPrisonAndBounty_MCM_Escape.GetPageName()
    ; Pages[8] = RealisticPrisonAndBounty_MCM_Bounty.GetPageName()
    ; Pages[9] = RealisticPrisonAndBounty_MCM_BHunters.GetPageName()
    ; Pages[10] = RealisticPrisonAndBounty_MCM_Leveling.GetPageName()
    ; Pages[11] = RealisticPrisonAndBounty_MCM_Status.GetPageName()
    ; Pages[12] = RealisticPrisonAndBounty_MCM_Whiterun.GetPageName()
endFunction

int function GetGlobalTimescale()
    return Game.GetGameSettingInt("Timescale")
endFunction

int function GetOptionValue(string page, string optionName, int index)
    float startBench = StartBenchmark()
    string _key = page + "::" + optionName

    int optionsArray = __getOptionsArrayAtKey(_key)  ; Array of option maps for each index
    int _container = JArray.getObj(optionsArray, index)
    int containerKey = JIntMap.getNthKey(_container,  0)
    int containerValue = JIntMap.getInt(_container, containerKey)

    EndBenchmark(startBench)
    Debug("GetOptionValue", "Get Option Value: optionsMap["+ containerKey +"] = " + containerValue)
    Debug("GetOptionValue", "Page: " + page + ", Option Name: " + optionName + ", Index: " + index)

    return containerValue
endFunction


function UpdateIndex(int optionId)
    int cachedOption = __findCachedOption(optionId)

    if (cachedOption != INVALID_VALUE)
        _currentOptionIndex = __getCachedOptionIndex(cachedOption)
        return
    endif

    ; Cache not found, proceed with the slow approach
    __updateIndexSlowInternal(optionId)
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

function ToggleOption(string _key, bool storePersistently = true)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == ARRAY_NOT_EXIST)
        return ; Array does not exist
    endif

    int index = int_if (__isSingleOption(_array), SINGLE_OPTION_INDEX, CurrentOptionIndex) ; Single options will have 0 index
    int _container = JArray.getObj(_array, index) 
    Trace("ToggleOption", "[" + _key +"] " + "Container: " + _container + ", Array: " + _array, ENABLE_TRACE)

    int i = 0
    while (i < JArray.count(_array))
        int _containerKey = JIntMap.nextKey(_container)
        bool _containerValue = JIntMap.getInt(_container, _containerKey) as bool
        Trace("ToggleOption", "[" + _key +"] " + "Key: " + _containerKey + ", Value: " + _containerValue, ENABLE_TRACE)

        if (i == index)
            JIntMap.setInt(_container, _containerKey, (!_containerValue) as int) ; Toggle value
            SetToggleOptionValue(_containerKey, !_containerValue)
            Trace("ToggleOption", "[" + _key +"] " + "Container: " + _container  + ", Container Key: " + _containerKey + " (" + i + " iterations)", ENABLE_TRACE)
            Trace("ToggleOption", "Set new value of " + !_containerValue + " to Option ID " + _containerKey + " for key " + _key, ENABLE_TRACE)
            return
        endif
        i += 1
    endWhile

endFunction


;/
    Adds and renders a Toggle Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @overrideKey: The key to be used to set values to and from storage.
    bool        @defaultValue: The default value before being rendered for the first time.
    int         @index: The index of where to render this option in storage. (-1 means it is a Single Option)

    returns:    The option's ID.
/;
int function AddOptionToggleWithKey(string displayedText, string overrideKey, bool defaultValue, int index = -1)
    string optionKey    = __makeOptionKey(overrideKey)          ; optionKey = Undressing::Allow Undressing
    string cacheKey     = __makeCacheOptionKey(overrideKey)     ; cacheKey  = Allow Undressing

    int value           = __getBoolOptionValue(optionKey, int_if (index == -1, SINGLE_OPTION_INDEX, index)) ; if index was not set, this is a single option.
    int optionId        = AddToggleOption(displayedText, bool_if (value < GENERAL_ERROR, defaultValue, (value as bool)))
    
    if (!__optionExists(optionKey, optionId))
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, __createOptionBool(optionId, defaultValue), index)
    endif

    return optionId
endFunction

int function AddOptionToggle(string text, bool defaultValue, int index = -1)
    return AddOptionToggleWithKey(text, text, defaultValue, index)
endFunction

;/
    Adds and renders a Slider Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @overrideKey: The key to be used to set values to and from storage.
    float       @defaultValue: The default value before being rendered for the first time.
    int         @index: The index of where to render this option in storage. (-1 means it is a Single Option)

    returns:    The option's ID.
/;
int function AddOptionSliderWithKey(string displayedText, string overrideKey, float defaultValue, int index = -1)
    string optionKey        = __makeOptionKey(overrideKey)          ; optionKey = Undressing::Allow Undressing
    string cacheKey         = __makeCacheOptionKey(overrideKey)     ; cacheKey  = Allow Undressing

    float value             = __getFloatOptionValue(optionKey, int_if (index == -1, SINGLE_OPTION_INDEX, index)) ; if index was not set, this is a single option.
    int optionId            = AddSliderOption(displayedText, float_if (value < GENERAL_ERROR, defaultValue, value))
    
    if (!__optionExists(optionKey, optionId))
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, __createOptionFloat(optionId, defaultValue), index)
    endif

    return optionId
endFunction

int function AddOptionSlider(string text, float defaultValue, int index = -1)
    return AddOptionSliderWithKey(text, text, defaultValue, index)
endFunction

;/
    Adds and renders a Menu Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @overrideKey: The key to be used to set values to and from storage.
    string      @defaultValue: The default value before being rendered for the first time.
    int         @index: The index of where to render this option in storage. (-1 means it is a Single Option)

    returns:    The option's ID.
/;
int function AddOptionMenuWithKey(string displayedText, string overrideKey, string defaultValue, int index = -1)
    string optionKey        = __makeOptionKey(overrideKey)          ; optionKey = Undressing::Allow Undressing
    string cacheKey         = __makeCacheOptionKey(overrideKey)     ; cacheKey  = Allow Undressing

    string value            = __getStringOptionValue(optionKey, int_if (index == -1, SINGLE_OPTION_INDEX, index)) ; if index was not set, this is a single option.
    int optionId            = AddMenuOption(displayedText, string_if (value < GENERAL_ERROR, defaultValue, value))
    
    if (!__optionExists(optionKey, optionId))
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, __createOptionString(optionId, defaultValue), index)
    endif

    return optionId
endFunction

int function AddOptionMenu(string text, string defaultValue, int index = -1)
    return AddOptionMenuWithKey(text, text, defaultValue, index)
endFunction


int function GetOptionFromMap(string _key)
    float startTime = StartBenchmark()

    int optionsArray = __getOptionsArrayAtKey(_key) ; Get the array inside the map

    if (optionsArray == ARRAY_NOT_EXIST)
        Trace("GetOptionFromMap", "Key: " + _key + " does not exist in the map, returning...", ENABLE_TRACE)
        return ARRAY_NOT_EXIST
    endif

    int i = 0
    while (i < __getOptionsCount(optionsArray))
        ; Get the map inside the array at i
        int _container      = __getOption(optionsArray, i)
        int _containerKey   = __getOptionKey(_container)
        int _containerValue = __getOptionValue(_container, _containerKey)

        string _hold = GetHoldNames()[i]

        Trace("GetOptionFromMap", "[" + _hold + "] " + "\t[ARRAY ID: " + optionsArray + " (" + _key + ")] " + "_container id: " + _container + " (key: " + _containerKey + ", value: " + (_containerValue) + ")", ENABLE_TRACE)

        i += 1
    endWhile

    ; EndBenchmark(startTime)

    return -1 ; OPTION_NOT_FOUND
endFunction

;/
    Retrieves the option specified by the key for the current option index,
    the index is invisible to the user and will update based on where the cursor is in the menu to account for all holds.

    e.g: GetOption(Undressing::Allow Undressing) with a CurrentOptionIndex of 0, will retrieve that option for Whiterun,
    whereas with the index set to 1, it will retrieve Winterhold's instead.

    string  @_key: The key to retrieve the option from.
    returns: The option's id on success, -1 on failure.
 /;
 int function GetOption(string _key)
    string _formattedKey = CurrentPage + "::" + _key ; Append current page to allow retrieving options simply by name
    int optionArray = __getOptionsArrayAtKey(_formattedKey) ; Get the array for this key

    if (optionArray == ARRAY_NOT_EXIST)
        Error("GetOption", "Key: " + _key + " does not exist in the map, returning...")
        return ARRAY_NOT_EXIST
    endif

    int _optionMap = __getOption(optionArray, CurrentOptionIndex)

    if (_optionMap == 0)
        Error("GetOption", "Container: " + _optionMap + " does not exist at key " + _key + ", returning...")
        return OPTION_NOT_EXIST
    endif

    int _optionId       = __getOptionKey(_optionMap)
    int _optionValue    = __getOptionValue(_optionMap, _optionId)

    Trace("GetOption", "[CurrentOptionIndex: " + CurrentOptionIndex + "] Returned Option ID: " + _optionId + ", with value: " + _optionValue, ENABLE_TRACE)
    return _optionId
endFunction

;/
    Gets a slider option's value.

    string      @option: The name of the option to retrieve the value from.

    returns:    The option's value
/;
int function GetOptionSliderValue(string option)
    string _key = __makeOptionKey(option)
    return __getIntOptionValue(_key, CurrentOptionIndex) ; TODO: case for Single Options (-1 index)
endFunction

;/
    Sets a slider option's value.

    string      @option: The name of the option to be changed.
    float       @value: The new value for the option.
/;
function SetOptionSliderValue(string option, float value)
    string _key = CurrentPage + "::" + option
    int optionId = GetOption(option)

    ; Change the value of the slider
    SetSliderOptionValue(optionId, value)

    ; Store the value
    __setFloatOptionValue(_key, value, CurrentOptionIndex)
endFunction

;/
    Retrieves the option's key (how it's stored in the save) from its id.

    int @optionId: The option's id.

    returns: The key for the option passed in. : string
/;
string function GetKeyFromOption(int optionId)
    float s = StartBenchmark()
    int _optionsArray = __getCacheOptionsAtPage(CurrentPage) ; Array with all options for page

    int i = 0
    while (i < __getCachedOptionsCount(_optionsArray))
        int keyHolder       = __getCacheOption(_optionsArray, i) ; JIntMap { key: optionId, value: [index, optionName] }
        int containerKey    = __getCacheOptionKey(keyHolder) ; Option Key
        int containerValue  = __getCacheOptionValue(keyHolder, containerKey);  Array: [index, optionName]

        if (optionId == containerKey)
            ; We can get the option key string now!
            string optionName = __getCachedOptionName(containerValue)
            EndBenchmark(s)
            int index = JArray.getInt(containerValue, CACHED_OPTION_INDEX)
            Trace("GetKeyFromOption", "Found match for key: " + optionName + " (Option ID: " +  optionId + "), index: " + index, ENABLE_TRACE)
            return optionName
        endif

        i += 1
    endWhile
    EndBenchmark(s)
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
            Info("GetOptionFromMap", "[" + _hold + "] " + "\t[ARRAY ID: " + _keyArray + " (" + _key + ")] " + "container id: " + _optionContainer + " (key: " + _optionKey + ", value: " + (_optionValue) + ")", IS_DEBUG)
            arrayIndex += 1
        endWhile
        keyIndex += 1
    endWhile
endFunction

; Event Handling
; ============================================================================
event OnConfigInit()
    ModName = "Realistic Prison and Bounty"
    InitializePages()

    __initializeOptionsMap()
    __initializeCacheMap()
endEvent

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
    RealisticPrisonAndBounty_MCM_Whiterun.Render(self)
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
    RealisticPrisonAndBounty_MCM_Whiterun.OnHighlight(self, option)

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
    
    ; if (IS_DEBUG)
    ;     string optionKey = GetKeyFromOption(option)
    ;     Debug(self, "MCM::OnOptionSelect", "Option ID: " + option + " (" + optionKey + ")")
    ; endif

    ; GetOptionFromMap(GetKeyFromOption(option))
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

    ; if (IS_DEBUG)
    ;     string optionKey = GetKeyFromOption(option)
    ;     Debug(self, "MCM::OnOptionSliderOpen", "Option ID: " + option + " (" + optionKey + ")")
    ; endif

    ; GetOptionFromMap(GetKeyFromOption(option))


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

    ; if (IS_DEBUG)
    ;     string optionKey = GetKeyFromOption(option)
    ;     Debug(self, "MCM::OnOptionMenuOpen", "Option ID: " + option + " (" + optionKey + ")")
    ; endif

    ; GetOptionFromMap(GetKeyFromOption(option))

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


; ============================================================================
;                                   private
; ============================================================================

; ============================================================================
;                               Logging Functions

function Trace(string caller, string logInfo, bool condition = true)
    RealisticPrisonAndBounty_Util.Trace(self, CurrentPage + "::" + caller, logInfo, condition)
endFunction

function Debug(string caller, string logInfo, bool condition = true)
    RealisticPrisonAndBounty_Util.Debug(self, CurrentPage + "::" + caller, logInfo, condition)
endFunction

function Info(string caller, string logInfo, bool condition = true)
    RealisticPrisonAndBounty_Util.Info(self, CurrentPage + "::" + caller, logInfo, condition)
endFunction

function Warn(string caller, string logInfo, bool condition = true)
    RealisticPrisonAndBounty_Util.Warn(self, CurrentPage + "::" + caller, logInfo, condition)
endFunction

function Error(string caller, string logInfo, bool condition = true)
    RealisticPrisonAndBounty_Util.Error(self, CurrentPage + "::" + caller, logInfo, condition)
endFunction

; ============================================================================
;                               Option Functions
;/
     Stores every Option in the menu.
     This is a map of arrays, which themselves contain maps of options.

     The map is implemented as follows:
     optionsMap[optionKey] : StringMap = [
        {key: optionId, value: optionValue}, : IntMap
        {key: optionId, value: optionValue}, : IntMap
        {key: optionId, value: optionValue}, : IntMap
        ...
     ]

     Example:
     optionsMap[undressing::allowUndressing] = [
        {key: 1026, value: true},
        {key: 1028, value: true},
        {key: 1030, value: false},
        ...
     ]
/;
int optionsMap

function __initializeOptionsMap()
    optionsMap = JMap.object()
    JValue.retain(optionsMap)
endFunction

;/
    Internal function to add any type of option to storage and cache.

    string      @displayedText: The text that is displayed for the option in the menu.
    int         @optionId: The option's id when created.
    string      @optionKey: The key used to refer to this option (Usually same as displayedText).
    string      @cacheKey: The key used to refer to this option when caching.
    JIntMap     @optionContainer: The structure containing the option's key, as well as its other various values.
    int         @index: The index in the internal array of where to store this option.
/;
function __addOptionInternal(string displayedText, int optionId, string optionKey, string cacheKey, int optionContainer, int index = -1)
    Debug("__addOptionInternal", "Option (ID: " + optionId + ", Key: " + optionKey + "), Cache (ID: " + optionId + ", Key: "+ cacheKey +") [index: "+ index +"] does not exist, creating it...", IS_DEBUG)
    __addOptionAtKey(optionKey, optionContainer)
    __addOptionCache(optionId, cacheKey, index)
endFunction

;/
    Retrieves a bool value for a specified option from the internal storage.

    string      @_key: The key of the option to retrieve the value from.
    int         @index: The index in the array of the option to retrieve.

    returns:    If the option exists and has a bool value, returns the value, otherwise returns < GENERAL_ERROR.
/;
int function __getBoolOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == ARRAY_NOT_EXIST)
        return ARRAY_NOT_EXIST ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    bool _containerValue = JIntMap.getInt(_container, _containerKey) as bool

    if (_container == 0)
        return OPTION_NOT_EXIST ; Option does not exist
    endif

    Trace("__getBoolOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)

    return (_containerValue as int)
endFunction

;/
    Retrieves an int value for a specified option from the internal storage.

    string      @_key: The key of the option to retrieve the value from.
    int         @index: The index in the array of the option to retrieve.

    returns:    If the option exists and has an int value, returns the value, otherwise returns < GENERAL_ERROR.
/;
int function __getIntOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == ARRAY_NOT_EXIST)
        return ARRAY_NOT_EXIST ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    int _containerValue = JIntMap.getInt(_container, _containerKey)

    if (_container == 0)
        return OPTION_NOT_EXIST ; Option does not exist
    endif

    Trace("__getFloatOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)
    return _containerValue
endFunction

;/
    Retrieves a float value for a specified option from the internal storage.

    string      @_key: The key of the option to retrieve the value from.
    int         @index: The index in the array of the option to retrieve.

    returns:    If the option exists and has a float value, returns the value, otherwise returns < GENERAL_ERROR.
/;
float function __getFloatOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ARRAY_NOT_EXIST ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    float _containerValue = JIntMap.getFlt(_container, _containerKey)

    if (_container == 0)
        return OPTION_NOT_EXIST ; Option does not exist
    endif

    Trace("__getFloatOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)
    return _containerValue
endFunction

;/
    Retrieves a string value for a specified option from the internal storage.

    string      @_key: The key of the option to retrieve the value from.
    int         @index: The index in the array of the option to retrieve.

    returns:    If the option exists and has a string value, returns the value, otherwise returns < GENERAL_ERROR.
/;
string function __getStringOptionValue(string _key, int index)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ARRAY_NOT_EXIST ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    string _containerValue = JIntMap.getStr(_container, _containerKey)

    if (_container == 0)
        return OPTION_NOT_EXIST ; Option does not exist
    endif

    Trace("__getFloatOptionValue", "[" + _key + " (" + index + ")] " + "CT: " + _container + ", CT_KEY: " + _containerKey + ", CT_VALUE: " + _containerValue, ENABLE_TRACE)
    return _containerValue
endFunction

;/
    Sets an option's value (float-based options only) in storage.

    string      @_key: The option's key.
    float       @value: The new value for this option
    int         @index: The index of where this option is rendered in storage.
/;
function __setFloatOptionValue(string _key, float value, int index)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ; Array does not exist
    endif

    int _container = JArray.getObj(_array, index)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    float _containerValue = JIntMap.getFlt(_container, _containerKey)

    JIntMap.setFlt(_container, _containerKey, value)

    if (_container == 0)
        return ; Option does not exist
    endif
endFunction

;/
    Gets the options array at the specified key from the underlying internal map.

    string  @_key: The key to retrieve the array from.
    bool    @handleError: Whether to handle and log errors when retrieving the array.

    returns: the array containing the options at @_key, or ARRAY_NOT_EXIST on failure if @handleError is true. 
/;
int function __getOptionsArrayAtKey(string _key, bool handleError = true)
    int _array = JMap.getObj(optionsMap, _key)
    if (_array == 0 && handleError)
        Error("__getOptionsArrayAtKey", "__getOptionsArrayAtKey(" + _key + "): Container does not exist! (this error is normal the first time the MCM is rendered)")
        return ARRAY_NOT_EXIST
    endif

    return _array
endFunction

;/
    Adds the specified option container to an array at the specified key to the underlying internal map.

    string  @_key: The key to add the option into.
    int     @optionContainer: The option to be added.
/;
function __addOptionAtKey(string _key, int optionContainer)
    int _array = __getOptionsArrayAtKey(_key, false)

    if (_array == 0)
        _array = JArray.object()
        Trace("__addOptionAtKey", "Array at key " + _key + " does not exist yet, created ARRAY with ID: " + _array, ENABLE_TRACE)
    endif

    ; Add option container map to array
    JArray.addObj(_array, optionContainer)

    Trace("__addOptionAtKey", "Adding MAP ID: " + optionContainer + " to ARRAY ID: " + _array, ENABLE_TRACE)
    Trace("__addOptionAtKey", "Adding ARRAY ID: " + _array + " to optionsMap[" +_key + "]", ENABLE_TRACE)
    Trace("__addOptionAtKey", "Adding Option " + optionContainer + " to " + "[" +_key + "]", ENABLE_TRACE)

    ; Add the array containing all containers related to _key to the map at _key
    JMap.setObj(optionsMap, _key, _array)
endFunction

;/
    Creates a key for an option based on the displayed text.

    string      @displayedText: The option's displayed text in the menu.

    returns:    The key based on the text passed in.
/;
string function __makeOptionKey(string displayedText)
    return CurrentPage + "::" + displayedText
endFunction

;/
    Creates a container (JIntMap) with the specified optionId and a bool value.

    int     @optionId: The id of the option to be created.
    bool    @value: The default value of the option.
    
    returns: The container's id.
/;
int function __createOptionBool(int optionId, bool value)
    int _container = __createPairInt(optionId, (value as int))
    Trace("__createOptionBool", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", ENABLE_TRACE)
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
    Debug("__createOptionInt", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")")
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

    Trace("__createOptionFloat", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", ENABLE_TRACE)
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

    Trace("__createOptionString", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", ENABLE_TRACE)
    return _container
endFunction

;/
    Retrieves the option from the specified options container at a particular index.

    JIntMap[]   @cacheOptionsContainer: The container with all the options for the specified page.
    int         @optionIndex: The index of the item to retrieve from the container.

    returns:    The option inside @cacheOptionsContainer at @optionIndex. : JIntMap
        { key: optionId, value: optionValue }
/;
int function __getOption(int optionsContainer, int optionIndex)
    return JArray.getObj(optionsContainer, optionIndex)
endFunction

;/
    Retrieves the key of the passed in option.

    JIntMap     @option: The option passed in.

    returns:    The option's key, which is the Option ID. : int
/;
int function __getOptionKey(int option)
    return JIntMap.getNthKey(option, 0)
endFunction

;/
    Retrieves the value of the passed in option at the specified key.
    JIntMap     @option: The option passed in.
    int         @optionKey: The option's key.

    returns:    The option's value. : int
/;
int function __getOptionValue(int option, int optionKey)
    return JIntMap.getInt(option, optionKey)
endFunction


;/
    Retrieves the amount of options in the container.
    JArray      @optionsArray: The array containing all the options for the parent map.

    returns:    The amount of options for this option.
/;
int function __getOptionsCount(int optionsArray)
    return JArray.count(optionsArray)
endFunction

;/
    Checks whether the option is a single option.

    Example of a single option container:
    optionsMap[clothing::Allow Wearing Clothes (Cidhna Mine)] = [
        {key: 1319, value: true}
     ]

     Cached option:
     cacheMap[clothing] = [
        { key: 1319, value: [Allow Wearing Clothes (Cidhna Mine), -1] } 
        -1 index means single option
     ]

     JArray    @array: The container with the option.

     returns: true if it's a single option, false otherwise.
/;
bool function __isSingleOption(int _array)
    return JArray.count(_array) == 1
endFunction

function __updateIndexSlowInternal(int optionId)
    ; Cache not found, proceed with the slow approach
    string[] optionKeys = JMap.allKeysPArray(optionsMap)

    int optionIndex = 0
    while (optionIndex < optionKeys.Length)
        string optionKey = optionKeys[optionIndex]

        Trace("__updateIndexSlowInternal", "Key is " + optionKey + ", updating index...", ENABLE_TRACE)
        int _optionsArray = JMap.getObj(optionsMap, optionKey) ; optionsMap[undressing::allowUndressing]

        int i = 0
        while (i < JArray.count(_optionsArray))
            ; Get containers inside the array (Option Maps)
            int _container = JArray.getObj(_optionsArray, i)
            int _containerKey = JIntMap.nextKey(_container)
            int _containerValue = JIntMap.getInt(_container, _containerKey)

            if (_containerKey == optionId)
                __addOptionCache(optionId, optionKey, i) ; Create cache for this option at this index, for next time (TODO: test this optionKey)
                Info("__updateIndexSlowInternal", "Created cache option for ID: " + optionId + ", Name: " + optionKey + ", index: " + i)
                _currentOptionIndex = i
                return
            endif
            i += 1
        endWhile
        optionIndex += 1
    endWhile
endFunction
; ============================================================================
;                               Utility Functions
;/
    Creates a pair structure for integers.

    int     @first: The first element in the pair.
    int     @second: The second element in the pair.

    returns: The pair as a container ID. : JIntMap
/;
int function __createPairInt(int first, int second)
    int _container = JIntMap.object()
    JIntMap.setInt(_container, first, second)
    return _container
endFunction

;/
    Creates a pair structure for bools.

    bool     @first: The first element in the pair.
    bool     @second: The second element in the pair.

    returns: The pair as a container ID. : JIntMap
/;
int function __createPairBool(bool first, bool second)
    return __createPairInt((first as int), (second as int))
endFunction


; ============================================================================
;                               Caching Functions
;/
    Stores the cache of every Option ID in the menu.
    This map contains an array for every page existing in the menu,
    each page array will contain all Option ID's and their respective index for that particular page.

    Implementation:
    cacheMap[PageName] : StringMap = [
        { key: optionId, value: [index, optionName] }, : IntMap
        { key: optionId, value: [index, optionName] }, : IntMap
        { key: optionId, value: [index, optionName] }, : IntMap
        ...
    ]
    
    Example:
    cacheMap[Undressing] = [
        { key: 1771, value: [1, "Allow Undressing"] },
        { key: 1786, value: [4, "Undress at Cell"] },
        { key: 1764, value: [2, "Strip Search Thoroughness"] },
        ...
    ]
/;
int cacheMap

function __initializeCacheMap()
    cacheMap = JMap.object()
    JValue.retain(cacheMap)
endFunction

;/
    Retrieves the root array of cached options for a particular page in the menu.

    string  @page: The page to retrieve the options from.

    returns: An array containing all option maps for the page. : JIntMap[]
        [
            { key: optionId, value: [index, optionName] },
            { key: optionId, value: [index, optionName] },
            { key: optionId, value: [index, optionName] },
            ...
        ]
/;
int function __getCacheOptionsAtPage(string page)
    return JMap.getObj(cacheMap, page)
endFunction

;/
    Retrieves the cached option from the specified options container at a particular index.

    JIntMap[]   @cacheOptionsContainer: The container with all the options for the specified page.
    int         @optionIndex: The index of the item to retrieve from the container.

    returns:    The option inside @cacheOptionsContainer at @optionIndex. : JIntMap
        { key: optionId, value: [index, optionName] }
/;
int function __getCacheOption(int cacheOptionsContainer, int optionIndex)
    return JArray.getObj(cacheOptionsContainer, optionIndex)
endFunction

;/
    Retrieves the key of the passed in option.

    JIntMap     @cachedOption: The option passed in.

    returns:    The option's key, which is the Option ID. : int
/;
int function __getCacheOptionKey(int cachedOption)
    return JIntMap.getNthKey(cachedOption, 0)
endFunction

;/
    Retrieves the value of the passed in option at the specified key.
    JIntMap     @cachedOption: The option passed in.
    int         @cachedOptionKey: The option's key.

    returns:    The option's value. : JArray 
        [index, optionName]
/;
int function __getCacheOptionValue(int cachedOption, int cachedOptionKey)
    return JIntMap.getObj(cachedOption, cachedOptionKey)
endFunction

;/
    Retrieves the nested cache option which is the index of the option.

    JIntMap     @cachedOptionValue: The map containing the nested values.

    returns:    The index of the option. : int
/;
int function __getCachedOptionIndex(int cachedOptionValue)
    return JArray.getInt(cachedOptionValue, CACHED_OPTION_INDEX)
endFunction

;/
    Retrieves the nested cache option which is the name of the option.

    JIntMap     @cachedOptionValue: The map containing the nested values.
    
    returns:    The name of the option. : string
/;
string function __getCachedOptionName(int cachedOptionValue)
    return JArray.getStr(cachedOptionValue, CACHED_OPTION_NAME)
endFunction

;/
    Retrieves the amount of cached options in the page container.
    JArray      @cachedOptionsArray: The array containing all the cached options for the parent map.

    returns:    The amount of cached options for this page.
/;
int function __getCachedOptionsCount(int cachedOptionsArray)
    return JArray.count(cachedOptionsArray)
endFunction

;/
    Placeholder function for a future change of the cache key.
/;
string function __makeCacheOptionKey(string displayedText)
    return displayedText
endFunction

;/
    Checks if the option passed by id exists in the option list.

    string  @_key: The option's key at the time of creation.
    int     @optionId: The option's id to be checked.

    returns: true if the option exists, false otherwise.
/;
bool function __optionExists(string _key, int optionId)
    int optionArray = __getOptionsArrayAtKey(_key)

    int i = 0
    while (i < __getOptionsCount(optionArray))
        int _container      = __getOption(optionArray, i) ; Gets the container inside the array at i
        int _containerKey   = __getOptionKey(_container) ; Gets the container's next key for each iteration

        if (_containerKey == optionID)
            return true
        endif
        i += 1
    endWhile

    Trace("__optionExists", "Execution end, did not find key", ENABLE_TRACE)
    Trace("__optionExists", "Array does not exist or has no items!", i == 0 && ENABLE_TRACE)
    Trace("__optionExists", "Option not found in array!", i != 0 && ENABLE_TRACE)

    return false
endFunction

;/
    Finds the cached option by its ID if it exists in the Cache Map.
    The search is performed on the CurrentPage from the cache map to avoid any unnecessary slowdowns.
    Traverses through the IntMaps in the CurrentPage array inside CacheMap until it finds the optionId,
    which then retrieves the value from that optionId key container

    int     @optionId: The option's ID.

    returns: The container with the option's name and index. : Array
        [index, optionName]

    Cache Map implementation:
    cacheMap[CurrentPage] = [
        { key: optionId, value: [index, optionName] } : IntMap
    ]
/;
int function __findCachedOption(int optionId)
    int _cacheOptions = __getCacheOptionsAtPage(CurrentPage)

    int i = 0
    while (i < JArray.count(_cacheOptions))
        int option          = __getCacheOption(_cacheOptions, i) ; JIntMap { key: optionId, value: [index, optionName] }
        int optionKey       = __getCacheOptionKey(option) ; int optionId

        if (optionId == optionKey)
            return __getCacheOptionValue(option, optionKey) ; Array: [index, optionName]
        endif
        i += 1
    endWhile
    
    Warn("__findCachedOption", "Could not find a cached option for " + CurrentPage + "::" + optionId + "!")
    return INVALID_VALUE
endFunction

;/
    Adds caching to the specified option when updating anything based on its Option ID.
    The cache should contain all of the page's Option ID's with their respective index,
    hence, this function should be used when rendering multiple options for a page.

    int     @optionId: The option's id to be cached.
    int     @index: The index to bind to this option to know what to update.
/;
function __addOptionCache(int optionId, string optionName, int index)
    int _cacheArray = JMap.getObj(cacheMap, CurrentPage)
    if (!_cacheArray)
        _cacheArray = JArray.object()
    endif

    JArray.addObj(_cacheArray, __createCachedOptionContainer(optionId, optionName, index))
    JMap.setObj(cacheMap, CurrentPage, _cacheArray)
endFunction

int function __createCachedOptionContainer(int optionId, string optionName, int index)
    int _container = JIntMap.object()
    int _nameIndexArray = JArray.object()
    JArray.addInt(_nameIndexArray, index)
    JArray.addStr(_nameIndexArray, optionName)
    JIntMap.setObj(_container, optionId, _nameIndexArray) ; { key: optionId, value: [index, optionName] }

    Trace("__createCachedOptionContainer", "Created cached option container: " + "{ key: "+ optionId +", value: ["+ optionName +", " + index + "]}", ENABLE_TRACE)

    return _container
endFunction


; ============================================================================
;                                   end private
; ============================================================================