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
int  property ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE  = 33 autoreadonly
bool property ARREST_DEFAULT_ALWAYS_ARREST_VIOLENT_CRIMES   = true autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT  = 33 autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT     = 200 autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT   = 33 autoreadonly
int  property ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT      = 200 autoreadonly
bool property ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE         = true autoreadonly
bool property ARREST_DEFAULT_ALLOW_ARREST_TRANSFER          = true autoreadonly
bool property ARREST_DEFAULT_ALLOW_UNCONSCIOUS_ARREST       = true autoreadonly
bool property ARREST_DEFAULT_ALLOW_UNCONDITIONAL_ARREST     = false autoreadonly
int  property ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY            = 0 autoreadonly
int  property ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY            = 1000 autoreadonly
int  property ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY            = 4000 autoreadonly
; ==============================================================================
; FRISKING
bool property FRISKING_DEFAULT_ALLOW                            = true autoreadonly
bool property FRISKING_DEFAULT_UNCONDITIONAL                    = false autoreadonly
int  property FRISKING_DEFAULT_MIN_BOUNTY                       = 500 autoreadonly
int  property FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY        = 1500 autoreadonly
int  property FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY           = 2000 autoreadonly
int  property FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE    = 33 autoreadonly
int  property FRISKING_DEFAULT_FRISK_THOROUGHNESS               = 10 autoreadonly
int  property FRISKING_DEFAULT_CONFISCATE_ITEMS                 = 3000 autoreadonly
bool property FRISKING_DEFAULT_STRIP_IF_STOLEN_FOUND            = true autoreadonly
int  property FRISKING_DEFAULT_NUMBER_STOLEN_ITEMS_REQUIRED     = 10 autoreadonly
; ==============================================================================
; UNDRESSING
bool    property UNDRESSING_DEFAULT_ALLOW                  = true autoreadonly
string  property UNDRESSING_DEFAULT_HANDLING_OPTION        = "Minimum Sentence" autoreadonly
int     property UNDRESSING_DEFAULT_MIN_BOUNTY             = 1500 autoreadonly
bool    property UNDRESSING_DEFAULT_WHEN_DEFEATED          = true autoreadonly
bool    property UNDRESSING_DEFAULT_AT_CELL                = true autoreadonly
bool    property UNDRESSING_DEFAULT_AT_CHEST               = true autoreadonly
int     property UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY      = 3000 autoreadonly
bool    property UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED   = true autoreadonly
int     property UNDRESSING_DEFAULT_STRIP_THOROUGHNESS     = 10 autoreadonly
; ==============================================================================
; CLOTHING
bool   property CLOTHING_DEFAULT_ALLOW_CLOTHES          = false autoreadonly
string property CLOTHING_DEFAULT_HANDLING_OPTION        = "Maximum Sentence" autoreadonly
int    property CLOTHING_DEFAULT_REDRESS_BOUNTY         = 2000 autoreadonly
bool   property CLOTHING_DEFAULT_REDRESS_WHEN_DEFEATED  = true autoreadonly
bool   property CLOTHING_DEFAULT_REDRESS_AT_CELL        = true autoreadonly
bool   property CLOTHING_DEFAULT_REDRESS_AT_CHEST       = true autoreadonly
string property CLOTHING_DEFAULT_PRISON_OUTFIT          = "Prisoner Outfit" autoreadonly
; ==============================================================================
; JAIL
int    property PRISON_DEFAULT_TIMESCALE                    = 60 autoreadonly
int    property PRISON_DEFAULT_BOUNTY_TO_SENTENCE           = 100 autoreadonly
int    property PRISON_DEFAULT_MIN_SENTENCE_DAYS            = 10 autoreadonly
int    property PRISON_DEFAULT_MAX_SENTENCE_DAYS            = 365 autoreadonly
bool   property PRISON_DEFAULT_UNCONDITIONAL_PRISON         = false autoreadonly
bool   property PRISON_DEFAULT_SENTENCE_PAYS_BOUNTY         = false autoreadonly
bool   property PRISON_DEFAULT_FAST_FORWARD                 = true autoreadonly
int    property PRISON_DEFAULT_DAY_FAST_FORWARD             = 5 autoreadonly
string property PRISON_DEFAULT_HANDLE_SKILL_LOSS            = "Random" autoreadonly
int    property PRISON_DEFAULT_DAY_START_LOSING_SKILLS      = 1 autoreadonly
int    property PRISON_DEFAULT_CHANCE_START_LOSING_SKILLS   = 100 autoreadonly
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

; ==============================================================================
; End Constants
; ==============================================================================

; Timescales
; =======================================
GlobalVariable property NormalTimescale auto
GlobalVariable property PrisonTimescale auto
; =======================================

int _prisonSkillHandlingOptions
string[] property PrisonSkillHandlingOptions
    string[] function get()
        if (JArray.count(_prisonSkillHandlingOptions) == 0)
            _prisonSkillHandlingOptions = JArray.object()

            JArray.addStr(_prisonSkillHandlingOptions, "All Skills")
            JArray.addStr(_prisonSkillHandlingOptions, "All Stat Skills (Health, Stamina, Magicka)")
            JArray.addStr(_prisonSkillHandlingOptions, "All Perk Skills")
            JArray.addStr(_prisonSkillHandlingOptions, "1x Random Stat Skill")
            JArray.addStr(_prisonSkillHandlingOptions, "1x Random Perk Skill")
            JArray.addStr(_prisonSkillHandlingOptions, "Random")
        endif
        return JArray.asStringArray(_prisonSkillHandlingOptions)
    endFunction
endProperty

int _undressingHandlingOptions
string[] property UndressingHandlingOptions
    string[] function get()
        if (JArray.count(_undressingHandlingOptions) == 0)
            _undressingHandlingOptions = JArray.object()

            JArray.addStr(_undressingHandlingOptions, "Minimum Bounty")
            JArray.addStr(_undressingHandlingOptions, "Minimum Sentence")
            JArray.addStr(_undressingHandlingOptions, "Unconditionally")
        endif
        return JArray.asStringArray(_undressingHandlingOptions)
    endFunction
endProperty

int _clothingHandlingOptions
string[] property ClothingHandlingOptions
    string[] function get()
        if (JArray.count(_clothingHandlingOptions) == 0)
            _clothingHandlingOptions = JArray.object()

            JArray.addStr(_clothingHandlingOptions, "Maximum Bounty")
            JArray.addStr(_clothingHandlingOptions, "Maximum Sentence")
            JArray.addStr(_clothingHandlingOptions, "Unconditionally")
        endif
        return JArray.asStringArray(_clothingHandlingOptions)
    endFunction
endProperty

int _clothingOutfits
string[] property ClothingOutfits
    string[] function get()
        if (JArray.count(_clothingOutfits) == 0)
            _clothingOutfits = JArray.object()
            JValue.retain(_clothingOutfits)
        endif

    endFunction
endProperty

int function GetOptionIndexFromKey(string[] _array, string _key) global
    int internalContainer = JArray.objectWithStrings(_array)
    return JArray.findStr(internalContainer, _key)
endFunction

int _lockLevels
string[] property LockLevels
    string[] function get()
        if (JArray.count(_locklevels) == 0)
            _lockLevels = JArray.object()
            ; JValue.retain(_lockLevels)
            JArray.addStr(_lockLevels, "Novice")
            JArray.addStr(_lockLevels, "Apprentice")
            JArray.addStr(_lockLevels, "Adept")
            JArray.addStr(_lockLevels, "Expert")
            JArray.addStr(_lockLevels, "Master")
            JArray.addStr(_lockLevels, "Requires Key")

            Debug("LockLevels::get", "Initialized array with a size of: " + JArray.count(_lockLevels))
        endif
        return JArray.asStringArray(_lockLevels)
    endFunction
endProperty

int _skills
string[] property Skills
    string[] function get()
        if (JArray.count(_skills) == 0)
            _skills = JArray.object()

            JArray.addStr(_skills, "Max. Health")
            JArray.addStr(_skills, "Max. Stamina")
            JArray.addStr(_skills, "Max. Magicka")
            JArray.addStr(_skills, "Heavy Armor")
            JArray.addStr(_skills, "Light Armor")
            JArray.addStr(_skills, "Sneak")
            JArray.addStr(_skills, "One-Handed")
            JArray.addStr(_skills, "Two-Handed")
            JArray.addStr(_skills, "Archery")
            JArray.addStr(_skills, "Block")
            JArray.addStr(_skills, "Smithing")
            JArray.addStr(_skills, "Speechcraft")
            JArray.addStr(_skills, "Pickpocketing")
            JArray.addStr(_skills, "Lockpicking")
            JArray.addStr(_skills, "Alteration")
            JArray.addStr(_skills, "Conjuration")
            JArray.addStr(_skills, "Destruction")
            JArray.addStr(_skills, "Illusion")
            JArray.addStr(_skills, "Restoration")
            JArray.addStr(_skills, "Enchanting")
            JArray.addStr(_skills, "Alchemy")

            Debug("Skills::get", "Initialized array with a size of: " + JArray.count(_lockLevels))
        endif
        return JArray.asStringArray(_skills)
    endFunction
endProperty

string _currentRenderedCategory
string property CurrentRenderedCategory
    string function get()
        return _currentRenderedCategory
    endFunction
endProperty

function ResetRenderedCategory()
    _currentRenderedCategory = ""
endFunction

function SetRenderedCategory(string categoryName)
    _currentRenderedCategory = categoryName
endFunction

string function GetOptionNameWithoutCategory(string option)
    int startIndex = StringUtil.Find(option, "::") + 2 ; +2 to skip double colon, start after Category::
    return StringUtil.Substring(option, startIndex)
endFunction

int _pagesArray
function InitializePages()
    _pagesArray = JArray.object()

    JArray.addStr(_pagesArray, "General")
    ; JArray.addStr(_pagesArray, "Outfits")
    JArray.addStr(_pagesArray, "")
    JArray.addStr(_pagesArray, "Whiterun")
    JArray.addStr(_pagesArray, "Winterhold")
    JArray.addStr(_pagesArray, "Eastmarch")
    JArray.addStr(_pagesArray, "Falkreath")
    JArray.addStr(_pagesArray, "Haafingar")
    JArray.addStr(_pagesArray, "Hjaalmarch")
    JArray.addStr(_pagesArray, "The Rift")
    JArray.addStr(_pagesArray, "The Reach")
    JArray.addStr(_pagesArray, "The Pale")

    Debug("Pages::get", "Initialized array with a size of: " + JArray.count(_pagesArray))

    Pages = JArray.asStringArray(_pagesArray)
endFunction

bool function SetOptionDependencyBool(string option, bool dependency, bool storePersistently = true)
    string optionKey = __makeOptionKey(option, includeCurrentCategory = false)

    int enabled  = OPTION_FLAG_NONE
    int disabled = OPTION_FLAG_DISABLED
    int optionId = GetOption(option)
    int flag = int_if (dependency, enabled, disabled)

    SetOptionFlags(optionId, flag)

    if (storePersistently)
        JMap.setInt(optionsFlagMap, optionKey, flag)
    endif
endFunction

int function GetGlobalTimescale()
    return Game.GetGameSettingInt("Timescale")
endFunction

string function GetOptionFormatString(string optionName)
    if (StringUtil.Find(optionName, "Bounty") != -1)
        return "Bounty"
    elseif (StringUtil.Find(optionName, "Times") != -1)
        return "Times"
    elseif (StringUtil.Find(optionName, "Days") != -1 || StringUtil.Find(optionName, "Sentence") != -1)
        return "Days"
    endif
endFunction

function IncrementStat(string hold, string statName)
    string _key = "Stats::" + statName

    int value = GetOptionStatValue(_key, hold)
    int newValue = value + 1
    string formatString = GetOptionFormatString(statName)

    SetOptionStatValue(_key, newValue, formatString)
    Debug("IncrementStat", "Incrementing Stat: " + statName + " Old: " + value + ", New: " + newValue + ", FormatString: " + formatString)
endFunction

function DecrementStat(string hold, string statName)
    string _key = "Stats::" + statName

    int value = GetOptionStatValue(_key, hold)
    int newValue = value - 1
    string formatString = GetOptionFormatString(statName)

    SetOptionStatValue(_key, newValue, formatString)
    Debug("DecrementStat", "Decrementing Stat: " + statName + " Old: " + value + ", New: " + newValue + ", FormatString: " + formatString)
endFunction

int function GetToggleOptionValue(string page, string optionName)
    float startBench = StartBenchmark()
    string _key = page + "::" + optionName

    int optionsArray = __getOptionsArrayAtKey(_key)  ; Array of option maps for each index
    int _container = JArray.getObj(optionsArray, 0)
    int containerKey = JIntMap.getNthKey(_container,  0)
    int containerValue = JIntMap.getInt(_container, containerKey)

    EndBenchmark(startBench)
    return containerValue
endFunction

float function GetSliderOptionValue(string page, string optionName)
    float startBench = StartBenchmark()
    string _key = page + "::" + optionName

    int optionsArray = __getOptionsArrayAtKey(_key)  ; Array of option maps for each index
    int _container = JArray.getObj(optionsArray, 0)
    int containerKey = JIntMap.getNthKey(_container,  0)
    float containerValue = JIntMap.getFlt(_container, containerKey)

    EndBenchmark(startBench)
    return containerValue
endFunction

string function GetMenuOptionValue(string page, string optionName)
    float startBench = StartBenchmark()
    string _key = page + "::" + optionName

    int optionsArray = __getOptionsArrayAtKey(_key)  ; Array of option maps for each index
    int _container = JArray.getObj(optionsArray, 0)
    int containerKey = JIntMap.getNthKey(_container,  0)
    string containerValue = JIntMap.getStr(_container, containerKey)

    EndBenchmark(startBench)
    return containerValue
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

    int _container = JArray.getObj(_array, 0)
    int _containerKey = JIntMap.nextKey(_container)
    bool _containerValue = JIntMap.getInt(_container, _containerKey) as bool

    JIntMap.setInt(_container, _containerKey, (!_containerValue) as int) ; Toggle value
    SetToggleOptionValue(_containerKey, !_containerValue)
    Debug("ToggleOption", "Set new value of " + !_containerValue + " for " + _key + " (option_id: " + _containerKey + ")")
endFunction

int function AddOptionCategoryKey(string text, string _key, int flags = 0)
    _currentRenderedCategory = _key
    AddHeaderOption(text, flags)
endFunction

int function AddOptionCategory(string text, int flags = 0)
    _currentRenderedCategory = text
    AddHeaderOption(text, flags)
endFunction


;/
    Adds and renders a Toggle Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    bool        @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionToggleKey(string displayedText, string _key, bool defaultValue, int defaultFlags = 0)
    string optionKey    = __makeOptionKey(_key)             ; optionKey = Whiterun::Undressing::Allow Undressing
    string cacheKey     = __makeCacheOptionKey(_key)        ; cacheKey  = Undressing::Allow Undressing
    
    int value           = __getBoolOptionValue(optionKey)
    int flags           = __getOptionFlag(optionKey)
    int optionId        = AddToggleOption(displayedText, bool_if (value < GENERAL_ERROR, defaultValue, value as bool), int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags))

    ; Trace("AddOptionToggleKey", "["+ _key +"] "+"Flags: " + int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags) + ", Value: " + bool_if (value < GENERAL_ERROR, defaultValue, value as bool))

    if (!__optionExists(optionKey, optionId))
        int option = __createOptionBool(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionToggle(string text, bool defaultValue, int defaultFlags = 0)
    return AddOptionToggleKey(text, text, defaultValue, defaultFlags)
endFunction

int function AddOptionTextKey(string displayedText, string _key, string defaultValue, int defaultFlags = 0)
    string optionKey            = __makeOptionKey(_key)         ; optionKey = Statistics::Whiterun::Current Bounty
    string cacheKey             = __makeCacheOptionKey(_key)    ; cacheKey = Whiterun::Current Bounty

    Debug("AddOptionTextKey", "OptionKey: " + optionKey + ", CacheKey: " + cacheKey)

    string value                = __getStringOptionValue(optionKey)
    int flags                   = __getOptionFlag(optionKey)
    int optionId                = AddTextOption(displayedText, string_if (value == "", defaultValue, value), int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags))

    if (!__optionExists(optionKey, optionId))
        int option = __createOptionString(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionText(string text, string defaultValue, int defaultFlags = 0)
    return AddOptionTextKey(text, text, defaultValue, defaultFlags)
endFunction

int function AddOptionStatKey(string displayedText, string _key, int defaultValue, string formatString, int defaultFlags = 0)
    string optionKey            = __makeOptionKey(_key)         ; optionKey = Whiterun::Stats::Current Bounty
    string cacheKey             = __makeCacheOptionKey(_key)    ; cacheKey = Stats::Current Bounty

    int value       = __getIntOptionValue(optionKey)
    int flags       = __getOptionFlag(optionKey)
    int optionId    = AddTextOption(displayedText, int_if (value < GENERAL_ERROR, defaultValue, value) + " " + formatString, flags)

    if (!__optionExists(optionKey, optionId))
        int option = __createOptionInt(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionStat(string text, int defaultValue, string formatString, int defaultFlags = 0)
    return AddOptionStatKey(text, text, defaultValue, formatString, defaultFlags)
endFunction

;/
    Adds and renders a Slide Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    float       @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionSliderKey(string displayedText, string _key, float defaultValue, string formatString = "{0}", int defaultFlags = 0)
    string optionKey        = __makeOptionKey(_key)         ; optionKey = Whiterun::Undressing::Allow Undressing
    string cacheKey         = __makeCacheOptionKey(_key)    ; cacheKey  = Undressing::Allow Undressing

    float value             = __getFloatOptionValue(optionKey)
    int flags               = __getOptionFlag(optionKey)
    int optionId            = AddSliderOption(displayedText, float_if (value < GENERAL_ERROR, defaultValue, value), formatString, int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags))
    
    if (!__optionExists(optionKey, optionId))
        int option = __createOptionFloat(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    ; Trace("AddOptionSliderKey", "["+ _key +"] "+"Flags: " + int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags) + ", Value: " + float_if (value < GENERAL_ERROR, defaultValue, value))


    return optionId
endFunction

int function AddOptionSlider(string text, float defaultValue, string formatString = "{0}", int defaultFlags = 0)
    return AddOptionSliderKey(text, text, defaultValue, formatString, defaultFlags)
endFunction

;/
    Adds and renders a Menu Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    string      @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionMenuKey(string displayedText, string _key, string defaultValue, int defaultFlags = 0)
    string optionKey        = __makeOptionKey(_key)             ; optionKey = Whiterun::Undressing::Allow Undressing
    string cacheKey         = __makeCacheOptionKey(_key)        ; cacheKey  = Undressing::Allow Undressing

    string value            = __getStringOptionValue(optionKey)
    int flags               = __getOptionFlag(optionKey)
    int optionId            = AddMenuOption(displayedText, string_if (value == "", defaultValue, value), int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags))
    
    if (!__optionExists(optionKey, optionId))
        int option = __createOptionString(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionMenu(string text, string defaultValue, int defaultFlags = 0)
    return AddOptionMenuKey(text, text, defaultValue, defaultFlags)
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

        string _hold = CurrentPage

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
    returns: The option's id on success, < GENERAL_ERROR on failure.
 /;
 int function GetOption(string _key)
    string _formattedKey = CurrentPage + "::" + _key ; Append current page to allow retrieving options simply by name
    int optionArray = __getOptionsArrayAtKey(_formattedKey) ; Get the array for this key

    if (optionArray == ARRAY_NOT_EXIST)
        Error("GetOption","Option " + _key + " does not exist, returning...")
        return ARRAY_NOT_EXIST
    endif

    int _optionMap = __getOption(optionArray, 0)

    if (_optionMap == 0)
        Error("GetOption", "Container: " + _optionMap + " does not exist at key " + _key + ", returning...")
        return OPTION_NOT_EXIST
    endif

    int _optionId       = __getOptionKey(_optionMap)
    int _optionValue    = __getOptionValue(_optionMap, _optionId)

    Trace("GetOption", "Returned Option ID: " + _optionId + ", with value: " + _optionValue, ENABLE_TRACE)
    return _optionId
endFunction

;/
    Gets a toggle option's state.

    string      @option: The name of the option to retrieve the value from.

    returns:    The option's value
/;
bool function GetOptionToggleState(string option)
    string _key = __makeOptionKey(option, includeCurrentCategory = false)
    return __getBoolOptionValue(_key)
endFunction

;/
    Gets a slider option's value.

    string      @option: The name of the option to retrieve the value from.

    returns:    The option's value
/;
float function GetOptionSliderValue(string option, string thePage = "")
    string _page = string_if (thePage == "", CurrentPage, thePage)
    string _key = __makeOptionKeyFromPage(_page, option, includeCurrentCategory = false)
    return __getFloatOptionValue(_key)
endFunction

int function GetOptionStatValue(string option, string thePage = "")
    string _page = string_if (thePage == "", CurrentPage, thePage)
    string _key = __makeOptionKeyFromPage(_page, option, includeCurrentCategory = false)
    return __getIntOptionValue(_key)
endFunction

string function GetOptionMenuValue(string option, string thePage = "")
    string _page = string_if (thePage == "", CurrentPage, thePage)
    string _key = __makeOptionKeyFromPage(_page, option, includeCurrentCategory = false)
    return __getStringOptionValue(_key)
endFunction


function SetFlags(string option, int flags)
    int optionId = GetOption(option)
    SetOptionFlags(optionId, flags)
endFunction

;/
    Sets a slider option's value.

    string      @option: The name of the option to be changed.
    float       @value: The new value for the option.
/;
function SetOptionSliderValue(string option, float value, string formatString = "{0}")
    string _key = CurrentPage + "::" + option
    int optionId = GetOption(option)

    ; Change the value of the slider
    SetSliderOptionValue(optionId, value, formatString)

    ; Store the value
    __setFloatOptionValue(_key, value)

    Debug("SetOptionSliderValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
endFunction

function SetOptionStatValue(string option, int value, string formatString = "{0}")
    string _key = CurrentPage + "::" + option
    int optionId = GetOption(option)

    ; Change the value of the text option
    SetTextOptionValue(optionId, value + " " + formatString)

    ; Store the value
    __setIntOptionValue(_key, value)

    Debug("SetOptionStatValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
endFunction

function SetOptionMenuValue(string option, string value)
    string _key = CurrentPage + "::" + option
    int optionId = GetOption(option)

    ; Change the value of the menu option
    SetMenuOptionValue(optionId, value)

    ; Store the value
    __setStringOptionValue(_key, value)

    Debug("SetOptionMenuValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
endFunction

string function GetKeyFromOption(int optionId)
    float s = StartBenchmark()
    int _currentPageArray = __getCacheOptionsAtPage(CurrentPage)

    int i = 0
    while (i < JValue.count(_currentPageArray))
        int optionMap       = __getCacheOption(_currentPageArray, i)
        int optionKey       = __getCacheOptionKey(optionMap)

        if (optionId == optionKey)
            string optionValue  = __getCacheOptionValue(optionMap, optionKey)
            EndBenchmark(s)
            Trace("GetKeyFromOption", "Found matching key for Option ID " + optionKey + "! Key is: " + optionValue)
            return optionValue ; We found the key that matches the option id.
        endif

        i += 1
    endWhile

    EndBenchmark(s)
endFunction

; function ListOptionMap()
;     string[] keys = JMap.allKeysPArray(optionsMap)

;     int keyIndex = 0
;     while (keyIndex < keys.Length)
;         string _key = keys[keyIndex]
;         int _keyArray = JMap.getObj(optionsMap, _key)
        
;         int arrayIndex = 0
;         while (arrayIndex < JArray.count(_keyArray))
;             int _optionContainer = JArray.getObj(_keyArray, arrayIndex)
;             int _optionKey       = JIntMap.getNthKey(_optionContainer, 0)
;             int _optionValue     = JIntMap.getInt(_optionContainer, _optionKey)

;             string _hold = GetHoldNames()[arrayIndex]
;             Info("GetOptionFromMap", "[" + _hold + "] " + "\t[ARRAY ID: " + _keyArray + " (" + _key + ")] " + "container id: " + _optionContainer + " (key: " + _optionKey + ", value: " + (_optionValue) + ")", IS_DEBUG)
;             arrayIndex += 1
;         endWhile
;         keyIndex += 1
;     endWhile
; endFunction

; Event Handling
; ============================================================================
event OnConfigInit()
    ModName = "Realistic Prison and Bounty"
    InitializePages()

    __initializeOptionsMap()
    __initializeCacheMap()
endEvent

event OnPageReset(string page)
    RealisticPrisonAndBounty_MCM_Holds.Render(self)
    RealisticPrisonAndBounty_MCM_General.Render(self)
endEvent

event OnOptionHighlight(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_General.OnHighlight(self, option)
endEvent

event OnOptionDefault(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_General.OnDefault(self, option)
endEvent

event OnOptionSelect(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_General.OnSelect(self, option)
endEvent

event OnOptionSliderOpen(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnSliderOpen(self, option)
endEvent

event OnOptionSliderAccept(int option, float value)
    RealisticPrisonAndBounty_MCM_Holds.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_General.OnSliderAccept(self, option, value)
endEvent

event OnOptionMenuOpen(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnMenuOpen(self, option)
endEvent

event OnOptionMenuAccept(int option, int index)
    RealisticPrisonAndBounty_MCM_Holds.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_General.OnMenuAccept(self, option, index)
endEvent


; ============================================================================
;                                   private
; ============================================================================

; ============================================================================
;                               Logging Functions

function Trace(string caller, string logInfo, bool condition = false)
    RealisticPrisonAndBounty_Util.Trace(self, CurrentPage + "::" + caller, logInfo, condition || ENABLE_TRACE)
endFunction

function Debug(string caller, string logInfo, bool condition = false)
    RealisticPrisonAndBounty_Util.Debug(self, CurrentPage + "::" + caller, logInfo, condition || IS_DEBUG)
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
     optionsMap[page::optionKey] : StringMap = [
        {key: optionId, value: optionValue}, : IntMap
        {key: optionId, value: optionValue}, : IntMap
        {key: optionId, value: optionValue}, : IntMap
        ...
     ]

     Example:
     optionsMap[whiterun::undressing::allowUndressing] = [
        {key: 1026, value: true},
        {key: 1028, value: true},
        {key: 1030, value: false},
        ...
     ]
/;
int optionsMap

;/
    Stores every option's flags.
    Map implementation:
        optionsFlagMap[Page::OptionKey] = Flag

    Example:
        optionsFlagMap[whiterun::undressing::allowUndressing] = 1 (OPTION_DISABLED)
        optionsFlagMap[whiterun::frisking::allowFrisking]     = 0 (OPTION_ENABLED)
/;
int optionsFlagMap

function __initializeOptionsMap()
    optionsMap = JMap.object()
    JValue.retain(optionsMap)

    optionsFlagMap = JMap.object()
    JValue.retain(optionsFlagMap)
endFunction

;/
    Internal function to add any type of option to storage and cache.

    string      @displayedText: The text that is displayed for the option in the menu.
    int         @optionId: The option's id when created.
    string      @optionKey: The key used to refer to this option (Usually same as displayedText).
    string      @cacheKey: The key used to refer to this option when caching.
    JIntMap     @optionContainer: The structure containing the option's key, as well as its other various values.
    int         @flags: The stored flags used for this option.
/;
function __addOptionInternal(string displayedText, int optionId, string optionKey, string cacheKey, int optionContainer, int flags)
    Debug("__addOptionInternal", "Option (ID: " + optionId + ", Key: " + optionKey + "), Cache (ID: " + optionId + ", Key: "+ cacheKey +") does not exist, creating it...", IS_DEBUG)
    __addOptionAtKey(optionKey, optionContainer)
    __addOptionCache(optionId, cacheKey)
    __setOptionFlag(optionKey, flags)
endFunction

;/
    Retrieves a bool value for a specified option from the internal storage.
    string      @_key: The key of the option to retrieve the value from.

    returns:    If the option exists and has a bool value, returns the value, otherwise returns < GENERAL_ERROR.
/;
int function __getBoolOptionValue(string _key)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == ARRAY_NOT_EXIST)
        return ARRAY_NOT_EXIST ; Array does not exist
    endif

    int _container = JArray.getObj(_array, 0)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    bool _containerValue = JIntMap.getInt(_container, _containerKey) as bool

    if (_container == 0)
        return OPTION_NOT_EXIST ; Option does not exist
    endif

    Trace("__getBoolOptionValue", "[" + _key + "] OptionID: " + _containerKey + ", Value: " + _containerValue)

    return (_containerValue as int)
endFunction

;/
    Retrieves an int value for a specified option from the internal storage.
    string      @_key: The key of the option to retrieve the value from.

    returns:    If the option exists and has an int value, returns the value, otherwise returns < GENERAL_ERROR.
/;
int function __getIntOptionValue(string _key)
    int _array = __getOptionsArrayAtKey(_key)

    if (_array == ARRAY_NOT_EXIST)
        return ARRAY_NOT_EXIST ; Array does not exist
    endif

    int _container = JArray.getObj(_array, 0)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    int _containerValue = JIntMap.getInt(_container, _containerKey)

    if (_container == 0)
        return OPTION_NOT_EXIST ; Option does not exist
    endif

    Trace("__getIntOptionValue", "[" + _key + "] OptionID: " + _containerKey + ", Value: " + _containerValue)
    return _containerValue
endFunction

int function __getOptionFlag(string _key)
    if (JMap.hasKey(optionsFlagMap, _key))
        int value = JMap.getInt(optionsFlagMap, _key)
        ; Trace("__getOptionFlag", "Found key: " + _key + ", value: " + value)
        return value
    endif
    return OPTION_NOT_EXIST
    ; int value = JMap.getInt(optionsFlagMap, _key)
    ; return value
endFunction

;/
    Retrieves a float value for a specified option from the internal storage.
    string      @_key: The key of the option to retrieve the value from.

    returns:    If the option exists and has a float value, returns the value, otherwise returns < GENERAL_ERROR.
/;
float function __getFloatOptionValue(string _key)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ARRAY_NOT_EXIST ; Array does not exist
    endif

    int _container = JArray.getObj(_array, 0)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    float _containerValue = JIntMap.getFlt(_container, _containerKey)

    if (_container == 0)
        return OPTION_NOT_EXIST ; Option does not exist
    endif

    ; Trace("__getFloatOptionValue", "[" + _key + "] OptionID: " + _containerKey + ", Value: " + _containerValue)
    return _containerValue
endFunction

;/
    Retrieves a string value for a specified option from the internal storage.
    string      @_key: The key of the option to retrieve the value from.

    returns:    If the option exists and has a string value, returns the value, otherwise returns empty string.
/;
string function __getStringOptionValue(string _key)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ""
    endif

    int _container = JArray.getObj(_array, 0)
    int _containerKey = JIntMap.getNthKey(_container, 0)
    string _containerValue = JIntMap.getStr(_container, _containerKey)

    if (_container == 0)
        return ""
    endif

    Trace("__getStringOptionValue", "[" + _key + "] OptionID: " + _containerKey + ", Value: " + _containerValue)
    return _containerValue
endFunction 

;/
    Sets an option's value (int-based options only) in storage.

    string      @_key: The option's key.
    int       @value: The new value for this option
/;
function __setIntOptionValue(string _key, int value)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ; Array does not exist
    endif

    int _container = JArray.getObj(_array, 0)

    if (_container == 0)
        return ; Option does not exist
    endif

    int _containerKey = JIntMap.getNthKey(_container, 0)
    JIntMap.setFlt(_container, _containerKey, value)
endFunction

;/
    Sets an option's value (float-based options only) in storage.

    string      @_key: The option's key.
    float       @value: The new value for this option
/;
function __setFloatOptionValue(string _key, float value)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ; Array does not exist
    endif

    int _container = JArray.getObj(_array, 0)

    if (_container == 0)
        return ; Option does not exist
    endif

    int _containerKey = JIntMap.getNthKey(_container, 0)
    JIntMap.setFlt(_container, _containerKey, value)
endFunction

;/
    Sets an option's value (string-based options only) in storage.

    string      @_key: The option's key.
    string       @value: The new value for this option
/;
function __setStringOptionValue(string _key, string value)
    int _array = __getOptionsArrayAtKey(_key)
    if (_array == ARRAY_NOT_EXIST)
        return ; Array does not exist
    endif

    int _container = JArray.getObj(_array, 0)

    if (_container == 0)
        return ; Option does not exist
    endif

    int _containerKey = JIntMap.getNthKey(_container, 0)
    JIntMap.setStr(_container, _containerKey, value)
endFunction

function __setOptionFlag(string _key, int flag)
    JMap.setInt(optionsFlagMap, _key, flag)
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
        ; Error("__getOptionsArrayAtKey", "__getOptionsArrayAtKey(" + _key + "): Container does not exist! (this error is normal the first time the MCM is rendered)")
        return ARRAY_NOT_EXIST
    endif

    return _array
endFunction

;/
    Adds the specified option container to an array at the specified key to the underlying internal map.

    int     @optionContainer: The option to be added.

    structure:
        optionsMap[CurrentPage::Category::OptionName] = [
            { key: optionName, value: [optionId, value] } : optionContainer,
            { key: optionName, value: [optionId, value] } : optionContainer,
            { key: optionName, value: [optionId, value] } : optionContainer,
            { key: optionName, value: [optionId, value] } : optionContainer,
            ...
        ]
/;

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
    Trace("__addOptionAtKey", "Adding ARRAY ID: " + _array + " to optionsMap[" +_key + "]")
    Trace("__addOptionAtKey", "Adding Option " + optionContainer + " to " + "[" +_key + "]", ENABLE_TRACE)

    ; Add the array containing all containers related to _key to the map at _key
    JMap.setObj(optionsMap, _key, _array)
endFunction

;/
    Creates a key for an option based on the displayed text.

    string      @displayedText: The option's displayed text in the menu.

    returns:    The key based on the text passed in.
/;
string function __makeOptionKey(string displayedText, bool includeCurrentCategory = true)
    if (includeCurrentCategory)
        return CurrentPage + "::" + CurrentRenderedCategory + "::" + displayedText
    else
        return CurrentPage + "::" + displayedText
    endif
endFunction

;/
    Creates a key for an option based on the displayed text from the specified page.

    string      @page: The page to create the key from.
    string      @displayedText: The option's displayed text in the menu.

    returns:    The key based on the text passed in.
/;
string function __makeOptionKeyFromPage(string page, string displayedText, bool includeCurrentCategory = true)
    if (includeCurrentCategory)
        return page + "::" + CurrentRenderedCategory + "::" + displayedText
    else
        return page + "::" + displayedText
    endif
endFunction

;/
    Creates a container (JIntMap) with the specified optionId and a bool value.
    int     @optionId: The id of the option to be created.
    bool    @value: The default value of the option.
    
    returns: The container's id.
/;
int function __createOptionBool(int optionId, bool value)
    int _container = JIntMap.object()
    JIntMap.setInt(_container, optionId, value as int)
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
    int _container = JIntMap.object()
    JIntMap.setInt(_container, optionId, value)
    Trace("__createOptionInt", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")")
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


; ============================================================================
;                               Caching Functions
;/
    Stores the cache of every Option ID in the menu.
    This map contains an array for every page existing in the menu,
    each page array will contain all Option ID's and their respective index for that particular page.

    Implementation:
    cacheMap[PageName] : StringMap = [
        { key: optionId, value: optionName }, : IntMap
        { key: optionId, value: optionName }, : IntMap
        { key: optionId, value: optionName }, : IntMap
        ...
    ]
    
    Example:
    cacheMap[Whiterun] = [
        { key: 1771, value: "Undressing::Allow Undressing" },
        { key: 1786, value: "Undressing::Undress at Cell" },
        { key: 1764, value: "Undressing::Strip Search Thoroughness" },
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

    returns:    The option's value. : string 
        optionName
/;
string function __getCacheOptionValue(int cachedOption, int cachedOptionKey)
    return JIntMap.getStr(cachedOption, cachedOptionKey)
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
    ; Undressing::Allow Undressing
    return CurrentRenderedCategory + "::" + displayedText
endFunction

;/
    Checks if the option passed by id exists in the option list.

    string  @_key: The option's key at the time of creation.
    int     @optionId: The option's id to be checked.

    returns: true if the option exists, false otherwise.
/;
bool function __optionExists(string _key, int optionId)
    int optionArray = __getOptionsArrayAtKey(_key)

    if (optionArray == ARRAY_NOT_EXIST)
        return false
    endif

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
    Adds caching to the specified option when updating anything based on its Option ID.
    The cache should contain all of the page's Option ID's with their respective index,
    hence, this function should be used when rendering multiple options for a page.

    int     @optionId: The option's id to be cached.
    string  @optionName: The name of the option.

/;
function __addOptionCache(int optionId, string optionName)
    ;/
    cacheMap[Whiterun] = 
    [
        { key: 1026, value: Undressing::Allow Undressing }
        { key: 1028, value: Undressing::Minimum Bounty to Undress }
        ...
        { key: 1126, value: Prison::Minimum Sentence }
        { key: 1127, value: Prison::Maximum Sentence }
        ...
    ]
/;
    ; Get the array for the current page, if it exists.
    int _cachePageArray = JMap.getObj(cacheMap, CurrentPage)
    if (!_cachePageArray)
        _cachePageArray = JArray.object()
    endif

    ; Option container
    int _optionContainer = JIntMap.object()
    JIntMap.setStr(_optionContainer, optionId, optionName)

    ; Add option to array
    JArray.addObj(_cachePageArray, _optionContainer)

    ; Add array with options belonging to page to cache map
    JMap.setObj(cacheMap, CurrentPage, _cachePageArray)

    Trace("__addOptionCache", "Created cache option: " + "(key: " + optionId + ", value: "+ optionName +")")
endFunction

; ============================================================================
;                                   end private
; ============================================================================