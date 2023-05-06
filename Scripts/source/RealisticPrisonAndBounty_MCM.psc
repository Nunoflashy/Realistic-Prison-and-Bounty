Scriptname RealisticPrisonAndBounty_MCM extends SKI_ConfigBase  

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

; ==============================================================================
; Constants
; ==============================================================================

bool property IS_DEBUG      = false autoreadonly
bool property ENABLE_TRACE  = false autoreadonly

; ==============================================================================
; Cached Option
int property CACHED_OPTION_INDEX    = 0 autoreadonly
int property CACHED_OPTION_NAME     = 1 autoreadonly

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

int property OUTFIT_COUNT = 10 autoreadonly

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

; Timescales
; =======================================
GlobalVariable property NormalTimescale auto
GlobalVariable property PrisonTimescale auto
; =======================================

; int _statList
; string[] property StatList
;     string[] function get()
;         if (JArray.count(_statList) == 0)
;             _statList = JArray.object()
;             JArray.addStr(_statList, "Current Bounty")
;             JArray.addStr(_statList, "Largest Bounty")
;             JArray.addStr(_statList, "Total Bounty")
;             JArray.addStr(_statList, "Times Arrested")
;             JArray.addStr(_statList, "Times Frisked")
;             JArray.addStr(_statList, "Fees Owed")
;             JArray.addStr(_statList, "Days in Jail")
;             JArray.addStr(_statList, "Longest Sentence")
;             JArray.addStr(_statList, "Times Jailed")
;             JArray.addStr(_statList, "Times Escaped")
;             JArray.addStr(_statList, "Times Stripped")
;             JArray.addStr(_statList, "Infamy Gained")
;         endif
;         return JArray.asStringArray(_statList)
;     endFunction
; endProperty

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
            
            JArray.addStr(_clothingOutfits, "Default")
            int i = 0
            while (i < 10)
                string currentOutfitCategory = "Outfit " + (i + 1)
                string outfitName = GetOptionInputValue(currentOutfitCategory + "::Name", "Clothing")
                JArray.addStr(_clothingOutfits, outfitName)
                i += 1
            endWhile
        endif
        return JArray.asStringArray(_clothingOutfits)
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

            Debug("Skills::get", "Initialized array with a size of: " + JArray.count(_skills))
        endif
        return JArray.asStringArray(_skills)
    endFunction
endProperty

bool function IsSelectedOption(string optionParam, string optionName) global
    return StringUtil.Find(optionParam, optionName) != -1
endFunction

bool function IsValidClothingForBodyPart(string bodyPart, int slotMask) global
    int validSlotMasks = JArray.object()

    if (bodyPart == "Head")
        JArray.addInt(validSlotMasks, 0x00000001)
        JArray.addInt(validSlotMasks, 0x00000002)
        JArray.addInt(validSlotMasks, 0x00001000)
        JArray.addInt(validSlotMasks, 0x00002000)
    elseif (bodyPart == "Body")
        JArray.addInt(validSlotMasks, 0x00000004)
        JArray.addInt(validSlotMasks, 0x00000002)
        JArray.addInt(validSlotMasks, 0x00001000)
    elseif (bodyPart == "Hands")
        JArray.addInt(validSlotMasks, 0x00000008)
    elseif (bodyPart == "Feet")
        JArray.addInt(validSlotMasks, 0x00000080)
    endif

    int combinedSlotMask
    int i = 0
    while (i < JArray.count(validSlotMasks))
        int currentSlotMask = JArray.getInt(validSlotMasks, i)
        combinedSlotMask += currentSlotMask
        if (currentSlotMask == slotMask || combinedSlotMask == slotMask)
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

function AddOutfitPiece(string outfitId, string outfitBodyPart, Armor outfitObject)
    string outfitKey = outfitId + "::" + outfitBodyPart
    
    ; Store outfit piece name in the input field
    SetOptionInputValue(outfitKey, outfitObject.GetName())

    ; Store persistently into the outfit list
    JMap.setForm(outfitsFormMap, outfitKey, outfitObject)
    Debug("AddOutfitPiece", "Added Outfit Piece: " + outfitObject.GetName() + " (FormID: " + outfitObject.GetFormID() + ") to Body Part: " + outfitBodyPart)
endFunction

function RemoveOutfitPiece(string outfitId, string outfitBodyPart)
    string outfitKey = outfitId + "::" + outfitBodyPart
    SetOptionInputValue(outfitKey, "")
    Armor outfitObject = JMap.getForm(outfitsFormMap, outfitKey) as Armor
    JMap.setForm(outfitsFormMap, outfitKey, none)
    Debug("RemoveOutfitPiece", "Removed Outfit Piece: " + outfitObject.GetName() + " (FormID: " + outfitObject.GetFormID() +") from Body Part: " + outfitBodyPart)
endFunction

Armor function GetOutfitPart(string outfitId, string outfitBodyPart)
    return JMap.getForm(outfitsFormMap, outfitId + "::" + outfitBodyPart) as Armor
endFunction

string _currentRenderedCategory
string property CurrentRenderedCategory
    string function get()
        return _currentRenderedCategory
    endFunction
endProperty

function SetRenderedCategory(string categoryName)
    _currentRenderedCategory = categoryName
endFunction

;/
    Returns the option's name without the category associated with it.

    e.g: Stripping::Allow Stripping as the option will return "Allow Stripping"
/;
string function GetOptionNameNoCategory(string option) global
    int startIndex = StringUtil.Find(option, "::") + 2 ; +2 to skip double colon, start after Category::
    return StringUtil.Substring(option, startIndex)
endFunction

;/
    Returns the option's category without its name.

    e.g: Stripping::Allow Stripping as the option will return "Stripping"
/;
string function GetOptionCategory(string optionWithCategory) global
    int len = StringUtil.Find(optionWithCategory, "::") ; Outfit 1::Equipped Outfit
    return StringUtil.Substring(optionWithCategory, 0, len) ; Outfit 1
endFunction

bool function IsStatOption(string option)
    return CurrentPage == "Stats"
endFunction

bool function IsHoldCurrentPage()
    int i = 0
    while (i < config.Holds.Length)
        if (CurrentPage == config.Holds[i])
            return true
        endif
        i += 1
    endWhile
    return false
endFunction

function InitializePages()
    int _pagesArray = JArray.object()

    JArray.addStr(_pagesArray, "General")
    JArray.addStr(_pagesArray, "Stats")
    JArray.addStr(_pagesArray, "Clothing")
    JArray.addStr(_pagesArray, "")

    int i = 0
    while (i < config.Holds.Length)
        JArray.addStr(_pagesArray, config.Holds[i])
        i += 1
    endWhile

    JArray.addStr(_pagesArray, "")
    JArray.addStr(_pagesArray, "Debug")

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


string function __getStatOptionFormatString(string optionName)
    if (StringUtil.Find(optionName, "Bounty") != -1)
        return "Bounty"
    elseif (StringUtil.Find(optionName, "Times") != -1)
        return "Times"
    elseif (StringUtil.Find(optionName, "Days") != -1 || StringUtil.Find(optionName, "Sentence") != -1)
        return "Days"
    elseif (StringUtil.Find(optionName, "Fees") != -1)
        return "Gold"
    elseif (StringUtil.Find(optionName, "Infamy") != -1)
        return "Infamy"
    endif
endFunction


; ============================================================
; Option Getters
; ============================================================

;/
    Gets a toggle option's state.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the state from.

    returns [bool]:    The option's state.
/;
bool function GetToggleOptionState(string page, string optionName)
    string _key = __makeOptionKeyFromPage(page, optionName, includeCurrentCategory = false)

    if (!JMap.hasKey(optionsMap, _key))
        ; Option not loaded yet (MCM page not loaded), so load default value for this option.
        return __getBoolOptionDefault(optionName)
    endif

    return __getBoolOptionValue(_key)
endFunction

bool function GetOptionToggleState(string option, string thePage = "")
    return GetToggleOptionState(thePage, option)
endFunction

;/
    Gets a slider option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [float]:    The option's value.
/;
float function GetSliderOptionValue(string page, string optionName)
    string _key = __makeOptionKeyFromPage(page, optionName, includeCurrentCategory = false)

    if (!JMap.hasKey(optionsMap, _key))
        ; Option not loaded yet (MCM page not loaded), so load default value for this option.
        return __getFloatOptionDefault(optionName)
    endif

    return __getFloatOptionValue(_key)
endFunction

float function GetOptionSliderValue(string option, string thePage = "")
    return GetSliderOptionValue(thePage, option)
endFunction

;/
    Gets a menu option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [string]:    The option's value.
/;
string function GetMenuOptionValue(string page, string optionName)
    string _key = __makeOptionKeyFromPage(page, optionName, includeCurrentCategory = false)

    if (!JMap.hasKey(optionsMap, _key))
        ; Option not loaded yet (MCM page not loaded), so load default value for this option.
        return __getStringOptionDefault(optionName)
    endif

    return __getStringOptionValue(_key)
endFunction

string function GetOptionMenuValue(string option, string thePage = "")
    return GetMenuOptionValue(thePage, option)
endFunction

;/
    Gets an input option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [string]:    The option's value.
/;
string function GetInputOptionValue(string page, string optionName)
    string _key = __makeOptionKeyFromPage(page, optionName, includeCurrentCategory = false)

    if (!JMap.hasKey(optionsMap, _key))
        ; Option not loaded yet (MCM page not loaded), so load default value for this option.
        return __getStringOptionDefault(optionName)
    endif

    return __getStringOptionValue(_key)
endFunction

string function GetOptionInputValue(string option, string thePage = "")
    return GetInputOptionValue(thePage, option)
endFunction

;/
    Gets a stat option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [int]:    The option's value.
/;
int function GetStatOptionValue(string page, string option)
    string _key = __makeOptionKeyFromPage(page, option, includeCurrentCategory = false)
    Debug("GetStatOptionValue", "_key: " + _key)

    if (!JMap.hasKey(optionsMap, _key))
        ; Option not loaded yet (MCM page not loaded), so load default value for this option.
        return __getIntOptionDefault(option)
    endif

    return __getIntOptionValue(_key)
endFunction

int function GetOptionStatValue(string option, string thePage = "")
    return GetStatOptionValue(thePage, option)
endFunction

;/
    Sets a slider's multiple options with just a single call.

    float   @minRange: The minimum value for this slider
    float   @maxRange: The maximum value for this slider
    float   @intervalSteps: The value used to determine how much to increment or decrement by each time.
    float   @defaultValue: The slider's default value. (Hotkey: R)
    float   @startValue: The slider's start value, the one that is shown when seeing this option for the first time.
/;
function SetSliderOptions(float minRange, float maxRange, float intervalSteps = 1.0, float defaultValue = 1.0, float startValue = 1.0)
    SetSliderDialogRange(minRange, maxRange)
    SetSliderDialogInterval(intervalSteps)
    SetSliderDialogDefaultValue(defaultValue)
    SetSliderDialogStartValue(startValue)
endFunction

;/
    Sets a toggle option on or off based on its state.

    string  @_key: The key of the option of which to change the state.
    bool    @storePersistently: Whether to store the value in internal storage.
/;
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


; Option Rendering Functions
; ============================================================

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
    int         @defaultValueOverride: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionToggleKey(string displayedText, string _key, int defaultValueOverride = -1, int defaultFlags = 0)
    string optionKey    = __makeOptionKey(_key)             ; optionKey = Whiterun::Undressing::Allow Undressing
    string cacheKey     = __makeCacheOptionKey(_key)        ; cacheKey  = Undressing::Allow Undressing
    
    bool defaultValue   = int_if (defaultValueOverride > -1, defaultValueOverride, __getIntOptionDefault(cacheKey)) as bool
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

int function AddOptionToggle(string text, int defaultValueOverride = -1, int defaultFlags = 0)
    return AddOptionToggleKey(text, text, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders a Text Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    string       @defaultValueOverride: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionTextKey(string displayedText, string _key, string defaultValueOverride = "", int defaultFlags = 0)
    string optionKey            = __makeOptionKey(_key)         ; optionKey = Statistics::Whiterun::Current Bounty
    string cacheKey             = __makeCacheOptionKey(_key)    ; cacheKey = Whiterun::Current Bounty

    string defaultValue         = string_if (defaultValueOverride != "", defaultValueOverride, __getStringOptionDefault(cacheKey))
    string value                = __getStringOptionValue(optionKey)
    int flags                   = __getOptionFlag(optionKey)
    int optionId                = AddTextOption(displayedText, string_if (value == "", defaultValue, value), int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags))

    if (!__optionExists(optionKey, optionId))
        int option = __createOptionString(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionText(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddOptionTextKey(text, text, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders a Stat Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.

    returns:    The Option's ID.
/;
int function AddOptionStatKey(string displayedText, string _key, int defaultValueOverride = -1, string formatString = "{0}", int defaultFlags = 0)
    string optionKey            = __makeOptionKey(_key)         ; optionKey = Whiterun::Stats::Current Bounty
    string cacheKey             = __makeCacheOptionKey(_key)    ; cacheKey = Stats::Current Bounty

    int defaultValue            = int_if (defaultValueOverride != -1, defaultValueOverride, __getIntOptionDefault(cacheKey))
    int value                   = __getIntOptionValue(optionKey)
    int flags                   = __getOptionFlag(optionKey)
    int optionId                = AddTextOption(displayedText, int_if (value < GENERAL_ERROR, defaultValue, value) + " " + formatString, flags)

    ; Trace("AddOptionStatKey", "["+ _key +"] "+"Flags: " + int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags) + ", Value: " + string_if (value < GENERAL_ERROR, defaultValue, value))

    if (!__optionExists(optionKey, optionId))
        int option = __createOptionInt(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionStat(string text, int defaultValueOverride = -1, string formatString = "{0}", int defaultFlags = 0)
    return AddOptionStatKey(text, text, defaultValueOverride, formatString, defaultFlags)
endFunction

;/
    Adds and renders a Slide Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    float       @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionSliderKey(string displayedText, string _key, string formatString = "{0}", float defaultValueOverride = -1.0, int defaultFlags = 0)
    string optionKey        = __makeOptionKey(_key)         ; optionKey = Whiterun::Undressing::Allow Undressing
    string cacheKey         = __makeCacheOptionKey(_key)    ; cacheKey  = Undressing::Allow Undressing

    float defaultValue      = float_if (defaultValueOverride > -1.0, defaultValueOverride, __getFloatOptionDefault(cacheKey))
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

int function AddOptionSlider(string text, string formatString = "{0}", float defaultValueOverride = -1.0, int defaultFlags = 0)
    return AddOptionSliderKey(text, text, formatString, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders a Menu Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.
    string      @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionMenuKey(string displayedText, string _key, string defaultValueOverride = "", int defaultFlags = 0)
    string optionKey        = __makeOptionKey(_key)             ; optionKey = Whiterun::Undressing::Allow Undressing
    string cacheKey         = __makeCacheOptionKey(_key)        ; cacheKey  = Undressing::Allow Undressing

    string defaultValue     = string_if (defaultValueOverride != "", defaultValueOverride, __getStringOptionDefault(cacheKey))
    string value            = __getStringOptionValue(optionKey)
    int flags               = __getOptionFlag(optionKey)
    int optionId            = AddMenuOption(displayedText, string_if (value == "", defaultValue, value), int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags))
    
    if (!__optionExists(optionKey, optionId))
        int option = __createOptionString(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionMenu(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddOptionMenuKey(text, text, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders an Input Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the input.
    string      @_key: The key to be used to set values to and from storage.
    string      @defaultValue: The default value before being rendered for the first time.

    returns:    The Option's ID.
/;
int function AddOptionInputKey(string displayedText, string _key, string defaultValueOverride = "-", int defaultFlags = 0)
    string optionKey        = __makeOptionKey(_key)             ; optionKey = Clothing::Outfit X::Body
    string cacheKey         = __makeCacheOptionKey(_key)        ; cacheKey  = Outfit X::Body

    string defaultValue     = string_if (defaultValueOverride != "-", defaultValueOverride, __getStringOptionDefault(cacheKey))
    string value            = __getStringOptionValue(optionKey)
    int flags               = __getOptionFlag(optionKey)
    int optionId            = AddInputOption(displayedText, string_if (value == "", defaultValue, value), int_if (flags == OPTION_NOT_EXIST, defaultFlags, flags))
    
    if (!__optionExists(optionKey, optionId))
        int option = __createOptionString(optionId, defaultValue)
        __addOptionInternal(displayedText, optionId, optionKey, cacheKey, option, flags)
    endif

    return optionId
endFunction

int function AddOptionInput(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddOptionInputKey(text, text, defaultValueOverride, defaultFlags)
endFunction

; ============================================================

;/
    Retrieves the option specified by the key.

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

    Trace("GetOption", "Returned Option ID: " + _optionId + ", with value: " + _optionValue)
    return _optionId
endFunction

function SetFlags(string option, int flags)
    int optionId = GetOption(option)
    SetOptionFlags(optionId, flags)
endFunction

; ============================================================
; Option Setters
; ============================================================

;/
    Sets a slider option's value.

    string      @option: The name of the option to be changed.
    float       @value: The new value for the option.
    string      @formatString: The format string used when displaying the option.
/;
function SetOptionSliderValue(string option, float value, string formatString = "{0}")
    string _key = CurrentPage + "::" + option
    int optionId = GetOption(option)

    ; Change the value of the slider
    SetSliderOptionValue(optionId, value, formatString)

    ; Store the value
    __setFloatOptionValue(_key, value)

    Trace("SetOptionSliderValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
endFunction

;/
    Sets a stat option's value.

    string      @option: The name of the option to be changed.
    int         @value: The new value for the option.
/;
; function SetOptionStatValue(string option, int value)
;     string _key = CurrentPage + "::" + option
;     int optionId = GetOption(option)

;     ; Get the correct format string for this stat option
;     string formatString = __getStatOptionFormatString(option)

;     ; Change the value of the text option
;     SetTextOptionValue(optionId, value + " " + formatString)

;     ; Store the value
;     __setIntOptionValue(_key, value)

;     Debug("SetOptionStatValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
; endFunction

function SetOptionStatValue(string option, int value)
    string _key = "Stats::" + option ; option = Hold::Stat (The Rift::Infamy Gained)
    int optionId = GetOption(option)

    ; int currentValue = GetStatOptionValue("Stats", option)

    ; Get the correct format string for this stat option
    string formatString = __getStatOptionFormatString(option)

    ; Change the value of the text option
    SetTextOptionValue(optionId, value + " " + formatString)

    ; Store the value
    __setIntOptionValue(_key, value)

    Debug("SetOptionStatValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
    ; Debug("SetOptionStatValue", "Stats["+ _key +"]: " + "{ currentValue: " + currentValue  + ", value: " + value + " }")
endFunction

; function SetStat(string hold, string statName, int value)
;     string _key = hold + "::" + statName
;     int currentValue = GetStatOptionValue("Stats", _key)
    
;     if (currentValue == OPTION_NOT_EXIST)
;         Error("MCM", "Stats["+ _key +"]: The stat does not exist!")
;         return    
;     endif

;     SetOptionStatValue(_key, value)

;     Debug("SetStat", "Stats["+ _key +"]: " + "{ currentValue: " + currentValue  + ", value: " + value + " }")
; endFunction

;/
    Sets a menu option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
/;
function SetOptionMenuValue(string option, string value)
    string _key = CurrentPage + "::" + option
    int optionId = GetOption(option)

    ; Change the value of the menu option
    SetMenuOptionValue(optionId, value)

    ; Store the value
    __setStringOptionValue(_key, value)

    Trace("SetOptionMenuValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
endFunction

;/
    Sets an input option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
/;
function SetOptionInputValue(string option, string value)
    string _key = CurrentPage + "::" + option
    int optionId = GetOption(option)

    ; Change the value of the menu option
    SetInputOptionValue(optionId, value)

    ; Store the value
    __setStringOptionValue(_key, value)

    Trace("SetOptionInputValue", "Set new value of " + value + " for " + _key + " (option_id: " + optionId + ")")
endFunction

string function GetKeyFromOption(int optionId)
    int _currentPageArray = __getCacheOptionsAtPage(CurrentPage)

    int i = 0
    while (i < JValue.count(_currentPageArray))
        int optionMap       = __getCacheOption(_currentPageArray, i)
        int optionKey       = __getCacheOptionKey(optionMap)

        if (optionId == optionKey)
            string optionValue  = __getCacheOptionValue(optionMap, optionKey)
            Trace("GetKeyFromOption", "Found matching key for Option ID " + optionKey + "! Key is: " + optionValue)
            return optionValue ; We found the key that matches the option id.
        endif

        i += 1
    endWhile
endFunction

; Event Handling
; ============================================================================
event OnConfigInit()
    ModName = "Realistic Prison and Bounty"
    InitializePages()

    __initializeOptionsMap()
    __initializeOptionDefaults()
    __initializeCacheMap()
    __initializeOutfitsMap()
endEvent

event OnPageReset(string page)
    RealisticPrisonAndBounty_MCM_Holds.Render(self)
    RealisticPrisonAndBounty_MCM_General.Render(self)
    RealisticPrisonAndBounty_MCM_Clothing.Render(self)
    RealisticPrisonAndBounty_MCM_Debug.Render(self)
    RealisticPrisonAndBounty_MCM_Stats.Render(self)

    ; IncrementStat(page, "Times Arrested")
    ; IncrementStat(page, "Times Jailed")

    Debug("MCM::OnPageReset", "Additional Bounty when Resisting: " + config.GetArrestAdditionalBountyResisting(page))

    if (config.GetArrestAdditionalBountyResisting(page) >= 1000)
        Debug("MCM::OnPageReset", "Moving player to jail cell in " + page)
        ObjectReference jailXMarker = config.GetRandomJailMarker(page)
        config.Player.MoveTo(jailXMarker)
        SendModEvent("PlayerArrestBegin")
    endif
endEvent

event OnOptionHighlight(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_General.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnHighlight(self, option)
endEvent

event OnOptionDefault(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_General.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnDefault(self, option)
endEvent

event OnOptionSelect(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_General.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnSelect(self, option)
endEvent

event OnOptionSliderOpen(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnSliderOpen(self, option)
endEvent

event OnOptionSliderAccept(int option, float value)
    RealisticPrisonAndBounty_MCM_Holds.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_General.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Clothing.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Debug.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Stats.OnSliderAccept(self, option, value)
endEvent

event OnOptionMenuOpen(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnMenuOpen(self, option)
endEvent

event OnOptionMenuAccept(int option, int index)
    RealisticPrisonAndBounty_MCM_Holds.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_General.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Clothing.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Debug.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Stats.OnMenuAccept(self, option, index)
endEvent

event OnOptionInputOpen(int option)
    RealisticPrisonAndBounty_MCM_Holds.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnInputOpen(self, option)
endEvent

event OnOptionInputAccept(int option, string inputValue)
    RealisticPrisonAndBounty_MCM_Holds.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_General.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_Clothing.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_Debug.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_Stats.OnInputAccept(self, option, inputValue)
endEvent

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
;                                   private
; ============================================================================
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
int optionDefaultsMap

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

function __initializeOptionDefaults()
    optionDefaultsMap = JMap.object()
    JValue.retain(optionDefaultsMap) ; may not be needed

    ; General
    JMap.setFlt(optionDefaultsMap, "General::Update Interval", 10)
    JMap.setFlt(optionDefaultsMap, "General::Bounty Decay (Update Interval)", 4)
    JMap.setFlt(optionDefaultsMap, "General::Infamy Decay (Update Interval)", 1)
    JMap.setFlt(optionDefaultsMap, "General::Timescale", 20)
    JMap.setFlt(optionDefaultsMap, "General::TimescalePrison", 60)
    JMap.setInt(optionDefaultsMap, "General::ArrestNotifications", 1)
    JMap.setInt(optionDefaultsMap, "General::JailedNotifications", 0)
    JMap.setInt(optionDefaultsMap, "General::BountyDecayNotifications", 0)
    JMap.setInt(optionDefaultsMap, "General::InfamyNotifications", 0)

    ; Stats dont have defaults, only storage
    JMap.setInt(optionsMap, "Stats::The Rift::Infamy Gained", 20)

    ; Bounty for Actions
    JMap.setFlt(optionDefaultsMap, "Bounty for Actions::Trespassing", 300)
    JMap.setFlt(optionDefaultsMap, "Bounty for Actions::Assault", 800)
    JMap.setFlt(optionDefaultsMap, "Bounty for Actions::Theft", 1.7)
    JMap.setFlt(optionDefaultsMap, "Bounty for Actions::Pickpocketing", 200)
    JMap.setFlt(optionDefaultsMap, "Bounty for Actions::Lockpicking", 100)
    JMap.setFlt(optionDefaultsMap, "Bounty for Actions::Disturbing the Peace", 100)

    ; Clothing::Configuration
    JMap.setInt(optionDefaultsMap, "Configuration::NudeBodyModInstalled", false as int)
    JMap.setInt(optionDefaultsMap, "Configuration::UnderwearModInstalled", false as int)

    ; Clothing::Item Slots
    JMap.setFlt(optionDefaultsMap, "Item Slots::Underwear (Top)", 56)
    JMap.setFlt(optionDefaultsMap, "Item Slots::Underwear (Bottom)", 52)

    ; Arrest
    JMap.setFlt(optionDefaultsMap, "Arrest::Minimum Bounty to Arrest", 500)
    JMap.setFlt(optionDefaultsMap, "Arrest::Guaranteed Payable Bounty", 1500)
    JMap.setFlt(optionDefaultsMap, "Arrest::Maximum Payable Bounty", 2500)
    JMap.setFlt(optionDefaultsMap, "Arrest::Maximum Payable Bounty (Chance)", 33)
    JMap.setInt(optionDefaultsMap, "Arrest::Always Arrest for Violent Crimes", true as int)
    JMap.setFlt(optionDefaultsMap, "Arrest::Additional Bounty when Resisting (%)", 33)
    JMap.setFlt(optionDefaultsMap, "Arrest::Additional Bounty when Resisting", 200)
    JMap.setFlt(optionDefaultsMap, "Arrest::Additional Bounty when Defeated (%)", 33)
    JMap.setFlt(optionDefaultsMap, "Arrest::Additional Bounty when Defeated", 500)
    JMap.setInt(optionDefaultsMap, "Arrest::Allow Civilian Capture", true as int)
    JMap.setInt(optionDefaultsMap, "Arrest::Allow Unconscious Arrest", true as int)
    JMap.setInt(optionDefaultsMap, "Arrest::Allow Unconditional Arrest", false as int)
    JMap.setFlt(optionDefaultsMap, "Arrest::Unequip Hand Garments", 0)
    JMap.setFlt(optionDefaultsMap, "Arrest::Unequip Head Garments", 1000)
    JMap.setFlt(optionDefaultsMap, "Arrest::Unequip Foot Garments", 4000)

    ; Frisking
    JMap.setInt(optionDefaultsMap, "Frisking::Allow Frisking", true as int)
    JMap.setInt(optionDefaultsMap, "Frisking::Unconditional Frisking", false as int)
    JMap.setFlt(optionDefaultsMap, "Frisking::Minimum Bounty for Frisking", 500)
    JMap.setFlt(optionDefaultsMap, "Frisking::Frisk Search Thoroughness", 10)
    JMap.setInt(optionDefaultsMap, "Frisking::Confiscate Stolen Items", true as int)
    JMap.setInt(optionDefaultsMap, "Frisking::Strip Search if Stolen Items Found", true as int)
    JMap.setFlt(optionDefaultsMap, "Frisking::Minimum No. of Stolen Items Required", 10)

    ; Stripping
    JMap.setInt(optionDefaultsMap, "Stripping::Allow Stripping", true as int)
    JMap.setStr(optionDefaultsMap, "Stripping::Handle Stripping On", "Minimum Sentence")
    JMap.setFlt(optionDefaultsMap, "Stripping::Minimum Bounty to Strip", 1500)
    JMap.setFlt(optionDefaultsMap, "Stripping::Minimum Violent Bounty to Strip", 1500)
    JMap.setFlt(optionDefaultsMap, "Stripping::Minimum Sentence to Strip", 15)
    JMap.setInt(optionDefaultsMap, "Stripping::Strip when Defeated", true as int)
    JMap.setFlt(optionDefaultsMap, "Stripping::Strip Search Thoroughness", 10)

    ; Clothing
    JMap.setInt(optionDefaultsMap, "Clothing::Allow Clothing", false as int)
    JMap.setStr(optionDefaultsMap, "Clothing::Handle Clothing On", "Maximum Sentence")
    JMap.setFlt(optionDefaultsMap, "Clothing::Maximum Bounty", 1500)
    JMap.setFlt(optionDefaultsMap, "Clothing::Maximum Violent Bounty", 1500)
    JMap.setFlt(optionDefaultsMap, "Clothing::Maximum Sentence", 100)
    JMap.setInt(optionDefaultsMap, "Clothing::When Defeated", true as int)
    JMap.setStr(optionDefaultsMap, "Clothing::Outfit", "Default")
    
    ; Jail
    JMap.setInt(optionDefaultsMap, "Jail::Unconditional Imprisonment", false as int)
    JMap.setFlt(optionDefaultsMap, "Jail::Guaranteed Payable Bounty", 2000)
    JMap.setFlt(optionDefaultsMap, "Jail::Maximum Payable Bounty", 4000)
    JMap.setFlt(optionDefaultsMap, "Jail::Maximum Payable Bounty (Chance)", 20)
    JMap.setFlt(optionDefaultsMap, "Jail::Bounty Exchange", 50)
    JMap.setFlt(optionDefaultsMap, "Jail::Bounty to Sentence", 100)
    JMap.setFlt(optionDefaultsMap, "Jail::Minimum Sentence", 10)
    JMap.setFlt(optionDefaultsMap, "Jail::Maximum Sentence", 365)
    JMap.setInt(optionDefaultsMap, "Jail::Sentence pays Bounty", false as int)
    JMap.setFlt(optionDefaultsMap, "Jail::Cell Search Thoroughness", 10)
    JMap.setStr(optionDefaultsMap, "Jail::Cell Lock Level", "Adept")
    JMap.setInt(optionDefaultsMap, "Jail::Fast Forward", true as int)
    JMap.setFlt(optionDefaultsMap, "Jail::Day to Fast Forward From", 5)
    JMap.setStr(optionDefaultsMap, "Jail::Handle Skill Loss", "Random")
    JMap.setFlt(optionDefaultsMap, "Jail::Day to Start Losing Skills", 5)
    JMap.setFlt(optionDefaultsMap, "Jail::Chance to Lose Skills", 100)
    JMap.setFlt(optionDefaultsMap, "Jail::Recognized Criminal Penalty", 100)
    JMap.setFlt(optionDefaultsMap, "Jail::Known Criminal Penalty", 100)
    JMap.setFlt(optionDefaultsMap, "Jail::Minimum Bounty to Trigger", 2500)

    ; Additional Charges
    JMap.setFlt(optionDefaultsMap, "Additional Charges::Bounty for Impersonation", 1700)
    JMap.setFlt(optionDefaultsMap, "Additional Charges::Bounty for Enemy of Hold", 2000)
    JMap.setFlt(optionDefaultsMap, "Additional Charges::Bounty for Stolen Items", 700)
    JMap.setFlt(optionDefaultsMap, "Additional Charges::Bounty for Stolen Item", 75)
    JMap.setFlt(optionDefaultsMap, "Additional Charges::Bounty for Contraband", 600)
    JMap.setFlt(optionDefaultsMap, "Additional Charges::Bounty for Cell Key", 2200)
    
    ; Release
    JMap.setInt(optionDefaultsMap, "Release::Enable Release Fees", false as int)
    JMap.setFlt(optionDefaultsMap, "Release::Chance for Event", 80)
    JMap.setFlt(optionDefaultsMap, "Release::Minimum Bounty to owe Fees", 0)
    JMap.setFlt(optionDefaultsMap, "Release::Release Fees (%)", 15)
    JMap.setFlt(optionDefaultsMap, "Release::Release Fees", 0)
    JMap.setFlt(optionDefaultsMap, "Release::Days Given to Pay", 10)
    JMap.setInt(optionDefaultsMap, "Release::Enable Item Retention", true as int)
    JMap.setFlt(optionDefaultsMap, "Release::Minimum Bounty to Retain Items", 0)
    JMap.setInt(optionDefaultsMap, "Release::Auto Re-Dress on Release", true as int)

    ; Escape
    JMap.setFlt(optionDefaultsMap, "Escape::Escape Bounty (%)", 15)
    JMap.setFlt(optionDefaultsMap, "Escape::Escape Bounty", 1000)
    JMap.setInt(optionDefaultsMap, "Escape::Allow Surrendering", true as int)
    JMap.setInt(optionDefaultsMap, "Escape::Frisk Search upon Captured", true as int)
    JMap.setInt(optionDefaultsMap, "Escape::Strip Search upon Captured", true as int)

    ; Bounty Decaying
    JMap.setInt(optionDefaultsMap, "Bounty Decaying::Enable Bounty Decaying", true as int)
    JMap.setInt(optionDefaultsMap, "Bounty Decaying::Decay while in Prison", true as int)
    JMap.setFlt(optionDefaultsMap, "Bounty Decaying::Bounty Lost (%)", 5)
    JMap.setFlt(optionDefaultsMap, "Bounty Decaying::Bounty Lost", 200)

    ; Bounty Hunting
    JMap.setInt(optionDefaultsMap, "Bounty Hunting::Enable Bounty Hunters", true as int)
    JMap.setInt(optionDefaultsMap, "Bounty Hunting::Allow Outlaw Bounty Hunters", true as int)
    JMap.setFlt(optionDefaultsMap, "Bounty Hunting::Minimum Bounty", 2500)
    JMap.setFlt(optionDefaultsMap, "Bounty Hunting::Bounty (Posse)", 6000)

    ; Infamy
    JMap.setInt(optionDefaultsMap, "Infamy::Enable Infamy", true as int)
    JMap.setFlt(optionDefaultsMap, "Infamy::Infamy Gained (%)", 0.02)
    JMap.setFlt(optionDefaultsMap, "Infamy::Infamy Gained", 40)
    JMap.setFlt(optionDefaultsMap, "Infamy::Infamy Recognized Threshold", 1000)
    JMap.setFlt(optionDefaultsMap, "Infamy::Infamy Known Threshold", 6000)
    JMap.setFlt(optionDefaultsMap, "Infamy::Infamy Lost (%)", 0.01)
    JMap.setFlt(optionDefaultsMap, "Infamy::Infamy Lost", 20)

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
    ; Trace("__addOptionInternal", "Option (ID: " + optionId + ", Key: " + optionKey + "), Cache (ID: " + optionId + ", Key: "+ cacheKey +") does not exist, creating it...")
    __addOptionAtKey(optionKey, optionContainer)
    __addOptionCache(optionId, cacheKey)
    __setOptionFlag(optionKey, flags)
endFunction

;/
    Retrieves the default bool value of an option from the internal storage.
    string      @optionName: The name of the option to retrieve the value from.

    Example optionName: Stripping::Allow Stripping
    Option names do not take into consideration the page they are rendered in, only the category and name itself.

    returns: The default value of the option passed in, if the option does not exist, returns OPTION_NOT_EXIST.
/;
bool function __getBoolOptionDefault(string optionName)
    return __getIntOptionDefault(optionName) as bool
endFunction

;/
    Retrieves the default int value of an option from the internal storage.
    string      @optionName: The name of the option to retrieve the value from.

    Example optionName: Stripping::Allow Stripping
    Option names do not take into consideration the page they are rendered in, only the category and name itself.

    returns: The default value of the option passed in, if the option does not exist, returns OPTION_NOT_EXIST.
/;
int function __getIntOptionDefault(string optionName)
    if (JMap.hasKey(optionDefaultsMap, optionName))
        return JMap.getInt(optionDefaultsMap, optionName)
    endif

    return OPTION_NOT_EXIST
endFunction

;/
    Retrieves the default float value of an option from the internal storage.
    string      @optionName: The name of the option to retrieve the value from.

    Example optionName: Stripping::Allow Stripping
    Option names do not take into consideration the page they are rendered in, only the category and name itself.

    returns: The default value of the option passed in, if the option does not exist, returns OPTION_NOT_EXIST.
/;
float function __getFloatOptionDefault(string optionName)
    if (JMap.hasKey(optionDefaultsMap, optionName))
        return JMap.getFlt(optionDefaultsMap, optionName)
    endif

    return OPTION_NOT_EXIST
endFunction

;/
    Retrieves the default string value of an option from the internal storage.
    string      @optionName: The name of the option to retrieve the value from.

    Example optionName: Stripping::Allow Stripping
    Option names do not take into consideration the page they are rendered in, only the category and name itself.

    returns: The default value of the option passed in, if the option does not exist, returns OPTION_NOT_EXIST.
/;
string function __getStringOptionDefault(string optionName)
    if (JMap.hasKey(optionDefaultsMap, optionName))
        return JMap.getStr(optionDefaultsMap, optionName)
    endif

    return OPTION_NOT_EXIST
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

    ; Trace("__getBoolOptionValue", "[" + _key + "] OptionID: " + _containerKey + ", Value: " + _containerValue)

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

    ; Trace("__getIntOptionValue", "[" + _key + "] OptionID: " + _containerKey + ", Value: " + _containerValue)
    return _containerValue
endFunction

int function __getOptionFlag(string _key)
    if (JMap.hasKey(optionsFlagMap, _key))
        int value = JMap.getInt(optionsFlagMap, _key)
        ; Trace("__getOptionFlag", "Found key: " + _key + ", value: " + value)
        return value
    endif

    return OPTION_NOT_EXIST
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

    ; Trace("__getStringOptionValue", "[" + _key + "] OptionID: " + _containerKey + ", Value: " + _containerValue)
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
    JIntMap.setInt(_container, _containerKey, value)
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
    string      @value: The new value for this option
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
    int dataArray = JMap.getObj(optionsMap, _key)
    if (dataArray == 0 && handleError)
        Trace("__getOptionsArrayAtKey", "__getOptionsArrayAtKey(" + _key + "): Container does not exist! (this error is normal the first time the MCM is rendered)")
        return ARRAY_NOT_EXIST
    endif

    return dataArray
endFunction

;/
    Adds the specified option container to an array at the specified key to the underlying internal map.

    string  @_key: The location key where the option array will be placed in the map.
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
    int dataArray = __getOptionsArrayAtKey(_key, false)

    if (dataArray == 0)
        dataArray = JArray.object()
        Trace("__addOptionAtKey", "Array at key " + _key + " does not exist yet, created ARRAY with ID: " + dataArray)
    endif

    ; Add option container map to array
    JArray.addObj(dataArray, optionContainer)

    ; Trace("__addOptionAtKey", "Adding MAP ID: " + optionContainer + " to ARRAY ID: " + dataArray, ENABLE_TRACE)
    ; Trace("__addOptionAtKey", "Adding ARRAY ID: " + dataArray + " to optionsMap[" +_key + "]")
    ; Trace("__addOptionAtKey", "Adding Option " + optionContainer + " to " + "[" +_key + "]", ENABLE_TRACE)

    ; Add the array containing all containers related to _key to the map at _key
    JMap.setObj(optionsMap, _key, dataArray)
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
        return string_if(page == "", CurrentPage, page) + "::" + CurrentRenderedCategory + "::" + displayedText
    else
        return string_if(page == "", CurrentPage, page) + "::" + displayedText
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
    ; Trace("__createOptionBool", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", ENABLE_TRACE)
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
    ; Trace("__createOptionInt", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")")
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

    ; Trace("__createOptionFloat", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", ENABLE_TRACE)
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

    ; Trace("__createOptionString", "Created MAP ID: " + _container + ", adding Option (id: " + optionId + ", value: " + value + ")", ENABLE_TRACE)
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
    return CurrentRenderedCategory + "::" + displayedText ; Undressing::Allow Undressing
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

        if (_containerKey == optionId)
            return true
        endif
        i += 1
    endWhile

    ; Trace("__optionExists", "Execution end, did not find key", ENABLE_TRACE)
    ; Trace("__optionExists", "Array does not exist or has no items!", i == 0 && ENABLE_TRACE)
    ; Trace("__optionExists", "Option not found in array!", i != 0 && ENABLE_TRACE)

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

int outfitsFormMap

function __initializeOutfitsMap()
    outfitsFormMap = JMap.object()
    JValue.retain(outfitsFormMap)
endFunction

; ============================================================================
;                                   end private
; ============================================================================