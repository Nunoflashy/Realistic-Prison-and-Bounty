Scriptname RPB_MCM extends SKI_ConfigBase  

import RPB_Utility
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
; Value Types
int property TYPE_NO_VALUE  = 0 autoreadonly
int property TYPE_NONE      = 1 autoreadonly
int property TYPE_INT       = 2 autoreadonly
int property TYPE_FLOAT     = 3 autoreadonly
int property TYPE_FORM      = 4 autoreadonly
int property TYPE_OBJECT    = 5 autoreadonly
int property TYPE_STRING    = 6 autoreadonly

; ==============================================================================

int property OUTFIT_COUNT = 10 autoreadonly

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

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property miscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return config.miscVars
    endFunction
endProperty

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

int _escapeHandlingOptions
string[] property EscapeHandlingOptions
    string[] function get()
        if (JArray.count(_escapeHandlingOptions) == 0)
            _escapeHandlingOptions = JArray.object()

            JArray.addStr(_escapeHandlingOptions, "Bounty")
            JArray.addStr(_escapeHandlingOptions, "Sentence")
            JArray.addStr(_escapeHandlingOptions, "Bounty + Sentence")
            JArray.addStr(_escapeHandlingOptions, "Bounty + Sentence (Conditionally)")
        endif
        return JArray.asStringArray(_escapeHandlingOptions)
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
                LogProperty(self, "MCM::ClothingOutfits", "Outfit Name: " + outfitName)
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

string[] property LockLevels
    string[] function get()
        return RPB_Utility.GetLockLevels()
    endFunction
endProperty

string[] property Skills
    string[] function get()
        return RPB_Utility.GetAllSkills()
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
    if (!outfitObject)
        return
    endif

    string outfitPieceKey = outfitId + "::" + outfitBodyPart
    self.SetOptionInputValue(outfitPieceKey, outfitObject.GetName())

    miscVars.SetForm(outfitPieceKey, outfitObject, "clothing/outfits")
    Debug("AddOutfitPiece", "Added Outfit Piece: " + outfitObject.GetName() + " (FormID: " + outfitObject.GetFormID() + ") to Body Part: " + outfitBodyPart)
endFunction

function RemoveOutfitPiece(string outfitId, string outfitBodyPart)
    string outfitPieceKey = outfitId + "::" + outfitBodyPart
    self.SetOptionInputValue(outfitPieceKey, "")
    Armor outfitObject = miscVars.GetForm(outfitPieceKey) as Armor
    miscVars.SetForm(outfitPieceKey, none, "clothing/outfits")
    Debug("RemoveOutfitPiece", "Removed Outfit Piece: " + outfitObject.GetName() + " (FormID: " + outfitObject.GetFormID() +") from Body Part: " + outfitBodyPart)
endFunction

Armor function GetOutfitPart(string outfitId, string outfitBodyPart)
    ; return miscVars.GetForm(outfitId + "::" + outfitBodyPart, "clothing/outfits") as Armor
endFunction

;/
    Returns the outfit id from its name.

    string  @outfitName: The name of the outfit as set up in the name field through the MCM.
    returns: The outfit's id.
/;
string function GetOutfitIdentifier(string outfitName)
    ; return miscVars.GetString(outfitName, "clothing/outfits")
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

    JArray.addStr(_pagesArray, "Stats")

    JArray.addStr(_pagesArray, "")
    JArray.addStr(_pagesArray, "General")
    JArray.addStr(_pagesArray, "Skills")
    JArray.addStr(_pagesArray, "Clothing")
    JArray.addStr(_pagesArray, "")

    int i = 0
    while (i < config.Holds.Length)
        JArray.addStr(_pagesArray, config.Holds[i])
        i += 1
    endWhile

    JArray.addStr(_pagesArray, "")
    JArray.addStr(_pagesArray, "Maintenance")
    JArray.addStr(_pagesArray, "Debug")

    Debug("Pages::get", "Initialized array with a size of: " + JArray.count(_pagesArray))

    Pages = JArray.asStringArray(_pagesArray)
endFunction

;/
    Sets a dependency on an option in order to determine its state (flag).
    
    string  @option: The option to set the dependency on
    bool    @dependency: The condition this option must pass in order to have its state be ON (OFF if false)
    bool?   @storePersistently: Whether to save the state of the option in the save
/;
function SetOptionDependencyBool(string option, bool dependency, bool storePersistently = true)
    string optionKey = self.GetOptionAsStored(option)
    int optionId     = self.GetOption(optionKey)
    int flag         = int_if (dependency, OPTION_FLAG_NONE, OPTION_FLAG_DISABLED)

    parent.SetOptionFlags(optionId, flag)

    if (storePersistently)
        self.SetOptionState(optionKey, flag)
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
; bool function GetToggleOptionState(string page, string optionName)

; endFunction

bool function GetOptionToggleState(string option, string page = "")
    if (self.OptionHasValue(option, page))
        return self.GetOptionValueBool(option, page)
    else
        return self.GetOptionDefaultBool(option)
    endif
endFunction

;/
    Gets a slider option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [float]:    The option's value.
/;
float function GetOptionSliderValue(string option, string page = "")
    if (self.OptionHasValue(option, page))
        return self.GetOptionValueFloat(option, page)
    else
        return self.GetOptionDefaultFloat(option)
    endif
endFunction

;/
    Gets a menu option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [string]:    The option's value.
/;
string function GetOptionMenuValue(string option, string page = "")
    if (self.OptionHasValue(option, page))
        return self.GetOptionValueString(option, page)
    else
        return self.GetOptionDefaultString(option)
    endif
endFunction

;/
    Gets an input option's value.

    string      @page: The page where this option is rendered.
    string      @optionName: The name of the option to retrieve the value from.

    returns [string]:    The option's value.
/;
string function GetOptionInputValue(string option, string page = "")
    if (self.OptionHasValue(option, page))
        return self.GetOptionValueString(option, page)
    else
        return self.GetOptionDefaultString(option)
    endif
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
    Gets the identifier of an option like it is stored.

    string  @optionKey: The key of the option
    string? @page: The page where the option is located, CurrentPage is used if null.

    returns (string): The constructed string of how the option is stored.
/;
string function GetOptionAsStored(string optionKey, string page = "")
    if (page == "")
        return CurrentPage + "/" + optionKey
    else
        return page + "/" + optionKey
    endif
endFunction

;/
    Sets a toggle option on or off based on its state.

    string  @_key: The key of the option of which to change the state.
    bool?   @storePersistently: Whether to store the value in internal storage.
/;
function ToggleOption(string _key, bool storePersistently = true)
    string optionKey = self.GetOptionAsStored(_key)
    int optionId     = self.GetOption(optionKey)
    bool option      = bool_if (self.OptionHasValue(_key), self.GetOptionValueBool(_key), self.GetOptionDefaultBool(_key))

    parent.SetToggleOptionValue(optionId, !option)

    if (storePersistently)
        self.SetOptionValueBool(_key, !option)
    endif

    Trace("MCM::ToggleOption", "Set new value of " + !option + " for " + _key + "(OptionKey: "+ optionKey +")" + "(option_id: "+ optionId +")", true)
endFunction

; Option Rendering Functions
; ============================================================

;/
    Adds a header option displaying the passed in text
    and changing the current rendered category to the key.

    string  @text: The text to display on the header option
    string  @_key: The key to set the current category to
    int     @flags: The header option's flags
/;
function AddOptionCategoryKey(string text, string _key, int flags = 0)
    _currentRenderedCategory = _key
    AddHeaderOption(text, flags)
endFunction

;/
    Adds a header option displaying the passed in text
    and setting the current rendered category.

    string  @text: The text to display on the header option
    int     @flags: The header option's flags
/;
function AddOptionCategory(string text, int flags = 0)
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
    int optionId
    int flags
    bool value

    string optionKey = CurrentRenderedCategory + "::" + _key

    bool optionHasState = self.OptionHasState(optionKey)
    bool optionHasValue = self.OptionHasValue(optionKey)

    if (optionHasState)
        flags = self.GetOptionState(optionKey)
    else
        flags = defaultFlags
    endif

    if (optionHasValue)
        value = self.GetOptionValueBool(optionKey)
    else
        if (defaultValueOverride > -1)
            value = defaultValueOverride
        else
            value = self.GetOptionDefaultBool(optionKey)
        endif
    endif

    optionId = AddToggleOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
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
    int optionId
    int flags
    string value

    string optionKey = CurrentRenderedCategory + "::" + _key

    bool optionHasState = self.OptionHasState(optionKey)
    bool optionHasValue = self.OptionHasValue(optionKey)

    if (optionHasState)
        flags = self.GetOptionState(optionKey)
    else
        flags = defaultFlags
    endif

    if (optionHasValue)
        value = self.GetOptionValueString(optionKey)
    else
        if (defaultValueOverride != "")
            value = defaultValueOverride
        else
            value = self.GetOptionDefaultString(optionKey)
        endif
    endif

    optionId = AddTextOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
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
    string optionKey = CurrentRenderedCategory + "::" + _key ; Whiterun::Current Bounty

    int value = config.actorVars.Get("[20]" + optionKey) ; [20]Whiterun::Current Bounty
    int optionId = AddTextOption(displayedText, value + " " + formatString, defaultFlags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
    endif

    Trace("MCM:AddOptionStatKey", "Option Key: " + optionKey + ", Value: " + value + ", Option ID: " + optionId)
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
    int optionId
    int flags
    float value

    string optionKey = CurrentRenderedCategory + "::" + _key

    bool optionHasState = self.OptionHasState(optionKey)
    bool optionHasValue = self.OptionHasValue(optionKey)

    if (optionHasState)
        flags = self.GetOptionState(optionKey)
    else
        flags = defaultFlags
    endif

    if (optionHasValue)
        value = self.GetOptionValueFloat(optionKey)
    else
        if (defaultValueOverride > -1.0)
            value = defaultValueOverride
        else
            value = self.GetOptionDefaultFloat(optionKey)
        endif
    endif

    optionId = AddSliderOption(displayedText, value, formatString, flags)

    if (!self.OptionExists(optionKey))
        DebugWithArgs("MCM::AddOptionSliderKey", "displayedText: " + displayedText + ", key: " + _key, "Option does not exist!")
        self.RegisterOption(optionKey, optionId)
    endif

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
    int optionId;           = AddSliderOption(displayedText, float_if (self.OptionHasValue(optionKey), value, defaultValue), formatString, int_if (self.OptionHasState(optionKey), flags, defaultFlags))
    int flags
    string value

    string optionKey = CurrentRenderedCategory + "::" + _key

    bool optionHasState = self.OptionHasState(optionKey)
    bool optionHasValue = self.OptionHasValue(optionKey)

    if (optionHasState)
        flags = self.GetOptionState(optionKey)
    else
        flags = defaultFlags
    endif

    if (optionHasValue)
        value = self.GetOptionValueString(optionKey)
    else
        if (defaultValueOverride != "")
            value = defaultValueOverride
        else
            value = self.GetOptionDefaultString(optionKey)
        endif
    endif

    optionId = AddMenuOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
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
    int optionId
    int flags
    string value

    string optionKey = CurrentRenderedCategory + "::" + _key

    bool optionHasState = self.OptionHasState(optionKey)
    bool optionHasValue = self.OptionHasValue(optionKey)

    if (optionHasState)
        flags = self.GetOptionState(optionKey)
    else
        flags = defaultFlags
    endif

    if (optionHasValue)
        value = self.GetOptionValueString(optionKey)
    else
        if (defaultValueOverride != "")
            value = defaultValueOverride
        else
            value = self.GetOptionDefaultString(optionKey)
        endif
    endif

    optionId = AddInputOption(displayedText, value, flags)

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
    endif

    return optionId
endFunction

int function AddOptionInput(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddOptionInputKey(text, text, defaultValueOverride, defaultFlags)
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
    string optionKey = self.GetOptionAsStored(option)
    int optionId     = self.GetOption(optionKey)

    ; Change the value of the slider option
    parent.SetSliderOptionValue(optionId, value, formatString)
    
    ; Store the value
    self.SetOptionValueFloat(option, value)

    Trace("SetOptionSliderValue", "Set new value of " + self.GetOptionValueFloat(option) + " for " + option + " (option_id: " + optionId + ")", true)
endFunction

;/
    Sets a menu option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
/;
function SetOptionMenuValue(string option, string value)
    string optionKey = self.GetOptionAsStored(option)
    int optionId     = self.GetOption(optionKey)
    
    ; Change the value of the menu option
    parent.SetMenuOptionValue(optionId, value)

    ; Store the value
    self.SetOptionValueString(option, value)

    Trace("SetOptionMenuValue", "Set new value of " + value + " for " + option + " (option_id: " + optionId + ")")
endFunction

;/
    Sets an input option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
/;
function SetOptionInputValue(string option, string value)
    string optionKey = self.GetOptionAsStored(option)
    int optionId     = self.GetOption(optionKey)

    ; Change the value of the input option
    parent.SetInputOptionValue(optionId, value)

    ; Store the value
    self.SetOptionValueString(option, value)

    Trace("SetOptionInputValue", "Set new value of " + value + " for " + option + " (option_id: " + optionId + ")")
endFunction

; ============================================================================
; Event Handling
; ============================================================================
event OnConfigInit()
    ModName = RPB_Data.MCM_GetRootPropertyOfTypeString("Config", "Name")

    self.InitializePages()
    self.InitializeOptions()
    self.RegisterEvents()
    self.LoadDefaults()
endEvent

event OnConfigOpen()
    self.InitializePages()
endEvent

string property RPB_CurrentPage auto

event OnPageReset(string page)
    RPB_MCM_Skills.Render(self)
    RPB_MCM_Holds.Render(self)
    RPB_MCM_General.Render(self)
    RPB_MCM_Clothing.Render(self)
    RPB_MCM_Debug.Render(self)
    RPB_MCM_Stats.Render(self)
endEvent

event OnOptionHighlight(int option)
    RPB_MCM_Skills.OnHighlight(self, option)
    RPB_MCM_Holds.OnHighlight(self, option)
    RPB_MCM_General.OnHighlight(self, option)
    RPB_MCM_Clothing.OnHighlight(self, option)
    RPB_MCM_Debug.OnHighlight(self, option)
    RPB_MCM_Stats.OnHighlight(self, option)
    RPB_MCM_Sentence.OnHighlight(self, option)
endEvent

event OnOptionDefault(int option)
    RPB_MCM_Skills.OnDefault(self, option)
    RPB_MCM_Holds.OnDefault(self, option)
    RPB_MCM_General.OnDefault(self, option)
    RPB_MCM_Clothing.OnDefault(self, option)
    RPB_MCM_Debug.OnDefault(self, option)
    RPB_MCM_Stats.OnDefault(self, option)
    RPB_MCM_Sentence.OnDefault(self, option)
endEvent

event OnOptionSelect(int option)
    RPB_MCM_Skills.OnSelect(self, option)
    RPB_MCM_Holds.OnSelect(self, option)
    RPB_MCM_General.OnSelect(self, option)
    RPB_MCM_Clothing.OnSelect(self, option)
    RPB_MCM_Debug.OnSelect(self, option)
    RPB_MCM_Stats.OnSelect(self, option)
    RPB_MCM_Sentence.OnSelect(self, option)
endEvent

event OnOptionSliderOpen(int option)
    RPB_MCM_Skills.OnSliderOpen(self, option)
    RPB_MCM_Holds.OnSliderOpen(self, option)
    RPB_MCM_General.OnSliderOpen(self, option)
    RPB_MCM_Clothing.OnSliderOpen(self, option)
    RPB_MCM_Debug.OnSliderOpen(self, option)
    RPB_MCM_Stats.OnSliderOpen(self, option)
    RPB_MCM_Sentence.OnSliderOpen(self, option)
endEvent

event OnOptionSliderAccept(int option, float value)
    RPB_MCM_Skills.OnSliderAccept(self, option, value)
    RPB_MCM_Holds.OnSliderAccept(self, option, value)
    RPB_MCM_General.OnSliderAccept(self, option, value)
    RPB_MCM_Clothing.OnSliderAccept(self, option, value)
    RPB_MCM_Debug.OnSliderAccept(self, option, value)
    RPB_MCM_Stats.OnSliderAccept(self, option, value)
    RPB_MCM_Sentence.OnSliderAccept(self, option, value)
endEvent

event OnOptionMenuOpen(int option)
    RPB_MCM_Skills.OnMenuOpen(self, option)
    RPB_MCM_Holds.OnMenuOpen(self, option)
    RPB_MCM_General.OnMenuOpen(self, option)
    RPB_MCM_Clothing.OnMenuOpen(self, option)
    RPB_MCM_Debug.OnMenuOpen(self, option)
    RPB_MCM_Stats.OnMenuOpen(self, option)
    RPB_MCM_Sentence.OnMenuOpen(self, option)
endEvent

event OnOptionMenuAccept(int option, int index)
    RPB_MCM_Skills.OnMenuAccept(self, option, index)
    RPB_MCM_Holds.OnMenuAccept(self, option, index)
    RPB_MCM_General.OnMenuAccept(self, option, index)
    RPB_MCM_Clothing.OnMenuAccept(self, option, index)
    RPB_MCM_Debug.OnMenuAccept(self, option, index)
    RPB_MCM_Stats.OnMenuAccept(self, option, index)
    RPB_MCM_Sentence.OnMenuAccept(self, option, index)
endEvent

event OnOptionInputOpen(int option)
    RPB_MCM_Skills.OnInputOpen(self, option)
    RPB_MCM_Holds.OnInputOpen(self, option)
    RPB_MCM_General.OnInputOpen(self, option)
    RPB_MCM_Clothing.OnInputOpen(self, option)
    RPB_MCM_Debug.OnInputOpen(self, option)
    RPB_MCM_Stats.OnInputOpen(self, option)
    RPB_MCM_Sentence.OnInputOpen(self, option)
endEvent

event OnOptionInputAccept(int option, string inputValue)
    RPB_MCM_Skills.OnInputAccept(self, option, inputValue)
    RPB_MCM_Holds.OnInputAccept(self, option, inputValue)
    RPB_MCM_General.OnInputAccept(self, option, inputValue)
    RPB_MCM_Clothing.OnInputAccept(self, option, inputValue)
    RPB_MCM_Debug.OnInputAccept(self, option, inputValue)
    RPB_MCM_Stats.OnInputAccept(self, option, inputValue)
    RPB_MCM_Sentence.OnInputAccept(self, option, inputValue)
endEvent

function SerializeOptions()
    JValue.writeToFile(generalContainer, "generalContainer.txt")
    miscVars.serialize("root", "miscVars_all.txt")
endFunction

; ============================================================================
;                               Option Functions
; ============================================================================

; Handling of options with additional behavior other than setting value,
; such as setting additional variables based on the Option.
event OnSliderOptionChanged(string eventName, string optionName, float optionValue, Form sender)
    if (optionName == "Bounty for Actions::Trespassing")
        Game.SetGameSettingInt("iCrimeGoldTrespass", optionValue as int)

        int settingValue = Game.GetGameSettingInt("iCrimeGoldTrespass")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Assault")
        Game.SetGameSettingInt("iCrimeGoldAttack", optionValue as int)
        
        int settingValue = Game.GetGameSettingInt("iCrimeGoldAttack")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Murder")
        Game.SetGameSettingInt("iCrimeGoldMurder", optionValue as int)
        
        int settingValue = Game.GetGameSettingInt("iCrimeGoldMurder")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Theft")
        Game.SetGameSettingFloat("fCrimeGoldSteal", optionValue)
        
        float settingValue = Game.GetGameSettingFloat("fCrimeGoldSteal")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Pickpocketing")
        Game.SetGameSettingInt("iCrimeGoldPickpocket", optionValue as int)
        
        int settingValue = Game.GetGameSettingInt("iCrimeGoldPickpocket")
        Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Horse Theft")
        
    elseif (optionName == "Bounty for Actions::Disturbing the Peace")

    endif
endEvent

function RegisterEvents()
    self.RegisterForModEvent("RPB_SliderOptionChanged", "OnSliderOptionChanged")
endFunction

;/
    Loads all of the option's properties from the config file.

    This function does not handle sanitizing user input, 
    as such, any input should be sanitized through the use of ValidateOption().
/;
function LoadOptionProperties(string asOption)
    self.LoadPropertyForOption(asOption, "Minimum")
    self.LoadPropertyForOption(asOption, "Maximum")
    self.LoadPropertyForOption(asOption, "Steps")
    self.LoadPropertyForOption(asOption, "Default")
endFunction

;/
    Validates all options that need validation, ensuring they follow a specific rule set.

    As such, any options that should have rules such as having its value less than / greater than
    or equal to another option, or a specific value, should be set here.
/;
function ValidateOption(string asOption)
    if (asOption == "General::Timescale" || \
        asOption == "General::TimescalePrison" || \
        asOption == "General::Arrest Elude Warning Time" || \
        asOption == "Infamy::Infamy Recognized Threshold" || \
        asOption == "Infamy::Infamy Known Threshold" || \
        asOption == "Frisking::Frisk Search Thoroughness" || \
        asOption == "Frisking::Minimum No. of Stolen Items Required" || \
        asOption == "Stripping::Minimum Sentence to Strip" || \
        asOption == "Stripping::Strip Search Thoroughness" || \
        asOption == "Jail::Bounty to Sentence" || \
        asOption == "Jail::Minimum Sentence" || \
        asOption == "Jail::Maximum Sentence" || \
        asOption == "Jail::Release Time (Minimum Hour)" || \
        asOption == "Jail::Release Time (Maximum Hour)" || \
        asOption == "Jail::Day to Fast Forward From" || \
        asOption == "Jail::Day to Start Losing Skills (Stat)" || \
        asOption == "Jail::Day to Start Losing Skills (Perk)" || \
        asOption == "Release::Minimum Bounty to Retain Items" || \
        asOption == "Escape::Escape Bounty (Bounty Condition)" || \
        asOption == "Escape::Escape Bounty (Sentence Condition)" || \
        asOption == "Clothing::Maximum Sentence to Clothe" \
    )
        EnsureOptionIsNotOfType(asOption, TYPE_STRING)
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1)
    endif

    if (asOption == "Frisking::Frisk Search Thoroughness" || \ 
        asOption == "Stripping::Strip Search Thoroughness" \ 
    )
        EnsureOptionValueGreaterThanOrEqualTo(asOption, 1)
        EnsureOptionValueLessThanOrEqualTo(asOption, 10)
    endif

    if (asOption == "Arrest::Maximum Payable Bounty (Chance)" || \ 
        asOption == "Jail::Maximum Payable Bounty (Chance)" || \
        asOption == "Jail::Chance to Lose Skills (Stat)" || \
        asOption == "Jail::Chance to Lose Skills (Perk)" \
    )
        EnsureOptionValueLessThanOrEqualTo(asOption, 100)
    endif

    if (asOption == "Jail::Release Time (Minimum Hour)" || \ 
        asOption == "Jail::Release Time (Maximum Hour)" \ 
    )
        EnsureOptionValueLessThanOrEqualTo(asOption, 24)
        EnsureOptionValueLessThanOptionValue( \ 
            asOptionOneKey  = "Jail::Release Time (Minimum Hour)", \ 
            asOptionTwoKey  = "Jail::Release Time (Maximum Hour)", \ 
            afValueToSet    = self.GetOptionValueFloat("Jail::Release Time (Maximum Hour)") - 1, \
            asValuePropertyType = "Maximum" \ 
        )
    endif

endFunction

function ValidateOptions()
    int obj         = JMap.allKeys(optionsDefaultValueMap) ; JArray& (string[])
    int optionCount = JValue.count(obj)

    int validatedOptions = 0

    int optionIndex = 0
    while (optionIndex < optionCount)
        string optionKey = JArray.getStr(obj, optionIndex)

        self.ValidateOption(optionKey)
        validatedOptions += 1
        optionIndex += 1
    endWhile

    Debug("MCM::ValidateOptions", "Validated " + validatedOptions + " options.")
endFunction

bool function IsValidPropertyType(string asPropertyType)
    return \
        asPropertyType == "Minimum" || \
        asPropertyType == "Maximum" || \
        asPropertyType == "Default" || \
        asPropertyType == "Steps" 
endFunction

string[] function GetPropertyTypes()
    int types = JArray.object()
    JArray.addStr(types, "Minimum")
    JArray.addStr(types, "Maximum")
    JArray.addStr(types, "Default")
    JArray.addStr(types, "Steps")

    return JArray.asStringArray(types)
endFunction

;/
    JMap&   @apOptionMap: The map containing the option's properties.
    string  @asPropertyType: The property to determine the value type of.

    returns (int): The value type of the specified property.
/;
int function DeterminePropertyValueType(int apOptionMap, string asPropertyType)
    int valueType = JMap.valueType(apOptionMap, asPropertyType)

    if (valueType == TYPE_OBJECT)
        ; Property specified is a dependency property, process it accordingly.
        int dependencyObject            = JMap.getObj(apOptionMap, asPropertyType)
        string dependencyOptionKey      = JArray.getStr(dependencyObject, 0)
        int dependencyOptionValueType   = JMap.valueType(optionsDefaultValueMap, dependencyOptionKey) ; Might change, since default option may not be defined yet
        
        ; Since all default number options are stored as float, determine here if it's float or int
        if (dependencyOptionValueType == TYPE_FLOAT)
            float originalValue     = JMap.getFlt(optionsDefaultValueMap, dependencyOptionKey)
            float fractionalPart    = originalValue - math.floor(originalValue)

            if (fractionalPart == 0.0)
                return TYPE_INT
            endif

            return TYPE_FLOAT
        endif
        
        return dependencyOptionValueType
            
    elseif (valueType == TYPE_FLOAT || valueType == TYPE_INT || valueType == TYPE_STRING)
        ; Simple property value type, just return it
        return valueType
    endif

    Error("There was an error determining the value type of the property.")
    DebugError("MCM::GetOptionValueTypeFromConfig", "[Property Type: "+ asPropertyType +"] There was an error determining the value type of the property.")
endFunction

; TODO: Check for dependency options value types
; TODO: Fix error, number dependency options are always considered float, even if they should be int (should be fixed with DeterminePropertyValueType())
int function GetOptionValueTypeFromConfig(string asOptionKey, bool abVerifyEveryProperty = true, string asReturnedPropertyTypeIfNotAllEqual = "")
    int optionsObj  = RPB_Data.MCM_GetOptionObject()
    int optionMap   = JMap.getObj(optionsObj, asOptionKey) ; JMap&

    ;/ 
        Check what properties it has,
        Assume that, if 4 properties exist, it is a number option,
        since those are: Minimum, Maximum, Default, Steps (and Minimum, Maximum only exist for number options).

        If there's only one property (Default), check whether it is of type string or bool.
    /;
    int propertyCount = JMap.count(optionMap)

    if (asOptionKey == "Infamy::Infamy Recognized Threshold")
        Debug("MCM::GetOptionValueTypeFromConfig", "Property Count: " + propertyCount)
    endif

    if (propertyCount == 4) ; Assuming Number Option
        int minimumPropertyValueType = self.DeterminePropertyValueType(optionMap, "Minimum")
        int maximumPropertyValueType = self.DeterminePropertyValueType(optionMap, "Maximum")
        int defaultPropertyValueType = self.DeterminePropertyValueType(optionMap, "Default")
        int stepsPropertyValueType   = self.DeterminePropertyValueType(optionMap, "Steps")

        DebugWithArgs( \ 
            "MCM::GetOptionValueTypeFromConfig",  "asOptionKey: " + asOptionKey, \ 
            "Value Types: \n" + \ 
            "\t - minimumPropertyValueType: " + minimumPropertyValueType + "\n" + \
            "\t - maximumPropertyValueType: " + maximumPropertyValueType + "\n" + \
            "\t - defaultPropertyValueType: " + defaultPropertyValueType + "\n" + \
            "\t - stepsPropertyValueType: " + stepsPropertyValueType + "\n" \
        )

        if (abVerifyEveryProperty)
            bool arePropertiesOfSameType = \
                minimumPropertyValueType == maximumPropertyValueType == \
                defaultPropertyValueType == stepsPropertyValueType

            if (arePropertiesOfSameType)
                return minimumPropertyValueType ; They are all the same, doesn't matter which to return
            else
                ; Return the value type specified, if it wasn't specified or is invalid, return the Minimum value type
                string propertyType = \
                    string_if ( \
                    self.IsValidPropertyType(asReturnedPropertyTypeIfNotAllEqual), \
                    asReturnedPropertyTypeIfNotAllEqual, "Minimum" \
                )

                int returnedValueType = JMap.valueType(optionMap, propertyType)

                ; if (returnedValueType == TYPE_OBJECT)
                ;     ; Selected property is a dependency, not a value, get its value.
                ;     int dependencyObject            = JMap.getObj(optionMap, propertyType)
                ;     string dependencyOptionKey      = JArray.getStr(dependencyObject, 0)
                ;     int dependencyOptionValueType   = JMap.valueType(optionsDefaultValueMap, dependencyOptionKey) ; Might change, since default option may be undefined still

                ;     return dependencyOptionValueType

                ;     ; ; Get the dependency property's value
                ;     ; if (dependencyOptionValueType == TYPE_FLOAT || dependencyOptionValueType == TYPE_INT)
                ;     ;     float dependencyOptionValue = self.GetNumberOptionPropertyValue(dependencyOptionKey, propertyType)
                ;     ;     float offset = JArray.getFlt(dependencyObject, 1)
                ;     ;     bool hasOffset = (offset as bool)

                ;     ;     float finalOptionValue = float_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
                ;     ;     return dependencyOptionValueType

                ;     ; elseif (dependencyOptionValueType == TYPE_STRING)
                ;     ;     string dependencyOptionValue = self.GetStringOptionPropertyValue(dependencyOptionKey, propertyType)
                ;     ;     return dependencyOptionValueType
                ;     ; endif

                ; endif

                Warn("The option ["+ asOptionKey +"] is most likely an invalid option, since not all property value types are the same!")
                DebugWarn("MCM::GetOptionValueTypeFromConfig", "[returned value type: "+ returnedValueType +"] ["+ propertyType +"] The option ["+ asOptionKey +"] is most likely an invalid option, since not all property value types are the same!")
                return returnedValueType
            endif
        endif

        return minimumPropertyValueType

    elseif (propertyCount == 1) ; String or Bool option
        string propertyType     = JMap.getNthKey(optionMap, 0)
        int propertyValueType   = JMap.valueType(optionMap, propertyType)

        return propertyValueType
    endif

    Error("There was an error retrieving the property value type of option [" + asOptionKey + "], make sure the option has a valid configuration!")
    DebugError("MCM::GetOptionValueTypeFromConfig", "There was an error retrieving the property value type of option [" + asOptionKey + "], make sure the option has a valid configuration!")
endFunction

;/
    Loads all options with the specified property type from the config file.
/;
function LoadOptionValues(string asPropertyType)
    int optionsObj  = RPB_Data.MCM_GetOptionObject()
    int optionCount = JValue.count(optionsObj)

    int optionIndex = 0
    bool continue   = false

    while (optionIndex < optionCount)
        string optionKey                = JMap.getNthKey(optionsObj, optionIndex) ; Current Option Key
        int optionMap                   = JMap.getObj(optionsObj, optionKey) ; JMap&
        bool hasPropertySpecified       = JMap.hasKey(optionMap, asPropertyType)

        if (!hasPropertySpecified)
            ; Determine if it's a string or bool option, if so, we shouldn't error, otherwise we should.
            bool hasMinimum = JMap.hasKey(optionMap, "Minimum")
            bool hasMaximum = JMap.hasKey(optionMap, "Maximum")
            bool hasSteps   = JMap.hasKey(optionMap, "Steps")
            bool hasDefault = JMap.hasKey(optionMap, "Default")
            bool hasNumberOptionProperties = hasMinimum && hasMaximum && hasSteps
            
            if (!hasNumberOptionProperties)
                ; String or Bool option
                Error("There was an error loading the option " + optionKey + ", there is no property to read!", !hasDefault)
                DebugError("MCM::LoadOptionValues", "There was an error loading the option " + optionKey + ", there is no property to read!", !hasDefault)
                continue = true
            endif
            
            if (!continue)
                Error("There was an error loading the "+ asPropertyType +" value for option [" + optionKey + "].")
                DebugError("MCM::LoadOptionValues", "There was an error loading the "+ asPropertyType +" value for option [" + optionKey + "].")
            endif
            continue = true
        endif

        if (!continue)
            bool hasDependency = JMap.valueType(optionMap, asPropertyType) == TYPE_OBJECT

            if (hasDependency)
                int propertyObject              = JMap.getObj(optionMap, asPropertyType)
                string dependencyOptionKey      = JArray.getStr(propertyObject, 0) ; [0] = Dependency Option
                int dependencyOptionValueType   = self.GetOptionValueTypeFromConfig(dependencyOptionKey)

                if (dependencyOptionValueType == TYPE_FLOAT || dependencyOptionValueType == TYPE_INT)
                    ; If of type int, cast it to float
                    float offset                = JArray.getFlt(propertyObject, 1) ; [1] = Option Offset
                    bool hasOffset              = (offset as bool)
                    float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)
                    float updatedValue          = float_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
                    self.SetNumberOptionPropertyValue(optionKey, asPropertyType, updatedValue)
                endif

            else
                bool isBool     = self.IsPropertyValueOfTypeBool(optionMap, asPropertyType)
                bool isFloat    = JMap.valueType(optionMap, asPropertyType) == TYPE_FLOAT
                bool isInteger  = JMap.valueType(optionMap, asPropertyType) == TYPE_INT 
                bool isString   = JMap.valueType(optionMap, asPropertyType) == TYPE_STRING

                if (isBool)
                    bool optionValue = JMap.getInt(optionMap, asPropertyType) as bool
                    self.SetBoolOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[bool] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)

                elseif (isInteger)
                    int optionValue = JMap.getInt(optionMap, asPropertyType) ; int|bool
                    self.SetNumberOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[int] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)
    
                elseif (isFloat)
                    float optionValue = JMap.getFlt(optionMap, asPropertyType) ; int|float
                    self.SetNumberOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[float] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)
                
                elseif (isString)
                    string optionValue = JMap.getStr(optionMap, asPropertyType) ; string
                    self.SetStringOptionPropertyValue(optionKey, asPropertyType, optionValue)
                    DebugWithArgs("MCM::LoadOptionValues", asPropertyType, "[string] Setting ["+ optionKey + "] " + asPropertyType +" Value to: " + optionValue)
                endif
            endif
        endif

        continue = false
        optionIndex += 1
    endWhile
endFunction

function LoadDefaults()
    self.LoadOptionValues("Default")
endFunction

function LoadMinimums()
    self.LoadOptionValues("Minimum")
endFunction

function LoadMaximums()
    self.LoadOptionValues("Maximum")
endFunction

function LoadSteps()
    self.LoadOptionValues("Steps")
endFunction

;/
    Sets the value for a specific property of a string option.
/;
function SetStringOptionPropertyValue(string asOptionKey, string asProperty, string asValue)
    if (asProperty == "Default")
        self.SetOptionDefaultString(asOptionKey, asValue)
    endif
endFunction

;/
    Sets the value for a specific property of a bool option.
/;
function SetBoolOptionPropertyValue(string asOptionKey, string asProperty, bool abValue)
    if (asProperty == "Default") ; bool only has Default property for now
        self.SetOptionDefaultBool(asOptionKey, abValue)
    endif
endFunction

;/
    Sets the value for a specific property of a number option.
/;
function SetNumberOptionPropertyValue(string asOptionKey, string asProperty, float afValue)
    if (asProperty == "Minimum")
        self.SetOptionMinimum(asOptionKey, afValue)

    elseif (asProperty == "Maximum")
        self.SetOptionMaximum(asOptionKey, afValue)

    elseif (asProperty == "Default")
        self.SetOptionDefaultFloat(asOptionKey, afValue)

    elseif (asProperty == "Steps")
        self.SetOptionSteps(asOptionKey, afValue)
    endif
endFunction

bool function GetBoolOptionPropertyValue(string asOptionKey, string asPropertyType)
    if (asPropertyType == "Default")
        self.GetOptionDefaultBool(asOptionKey)
    endif
    
    Error("There was an error retrieving the "+ asPropertyType +" value of option " + asOptionKey)
    DebugError("MCM::GetBoolOptionPropertyValue", "[bool] There was an error retrieving the "+ asPropertyType +" value of option " + asOptionKey)
    return -1
endFunction


float function GetNumberOptionPropertyValue(string asOptionKey, string asProperty)
    if (asProperty == "Minimum")
        self.GetOptionMinimum(asOptionKey)

    elseif (asProperty == "Maximum")
        self.GetOptionMaximum(asOptionKey)

    elseif (asProperty == "Default")
        self.GetOptionDefaultFloat(asOptionKey)

    elseif (asProperty == "Steps")
        self.GetOptionSteps(asOptionKey)
    endif

    return -1
endFunction

string function GetStringOptionPropertyValue(string asOptionKey, string asProperty)
    if (asProperty == "Default")
        return self.GetOptionDefaultString(asOptionKey)
    endif

    return none
endFunction


;/
    Determines if an integer option is of type bool,
    this must be done because both ints and bools are represented
    as ints internally.

    JMap&   @apOptionMap: The map containing the option's properties
    string  @asPropertyType: The type to check from the property

    returns (bool): Whether this option is of type bool or not.
/;
bool function IsPropertyValueOfTypeBool(int apOptionMap, string asPropertyType)
    bool isInteger = JMap.valueType(apOptionMap, asPropertyType) == TYPE_INT 

    if (isInteger)
        int propertyCount   = JValue.count(apOptionMap)
        int optionValue     = JMap.getInt(apOptionMap, asPropertyType) ; int|bool

        ; Since int options usually have 4 properties, and bools only have one (Default),
        ; it's safe to assume that if it only has that one property, it is a bool option.
        ; If the values are only 0 or 1, and it meets the one property criteria, it most likely is a bool option.
        bool isBool = (propertyCount == 1) && (asPropertyType == "Default") && (optionValue == 0 || optionValue == 1)
        
        return isBool
    endif

    return false
endFunction

;/
    Internal helper function to load options with their respective
    property values.

    Property types include: Default, Minimum, Maximum, Steps

    string  @asOptionKey: The key of the option
    string  @asPropertyType: The type of property to load the values into the option
    JMap&   @apOptionObject: The object containing the option's properties
/;
function __internal_loadPropertyForOption( \
    string asOptionKey, \
    string asPropertyType, \
    int apOptionObject \
)
    int optionMap           = apOptionObject; JMap&
    int propertyValueType   = JMap.valueType(optionMap, asPropertyType)

    if (propertyValueType == TYPE_INT)
        int optionValue = JMap.getInt(optionMap, asPropertyType)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, optionValue)
        DebugWithArgs("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, "[int] Setting "+ asPropertyType +" Value to: " + optionValue)

    elseif (propertyValueType == TYPE_FLOAT)
        float optionValue = JMap.getFlt(optionMap, asPropertyType)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, optionValue)
        DebugWithArgs("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, "[float] Setting "+ asPropertyType +" Value to: " + optionValue)

    elseif (propertyValueType == TYPE_STRING)
        string optionValue = JMap.getStr(optionMap, asPropertyType)
        self.SetStringOptionPropertyValue(asOptionKey, asPropertyType, optionValue)
        DebugWithArgs("MCM::LoadPropertyForOption", "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, "[string] Setting "+ asPropertyType +" Value to: " + optionValue)

    elseif (propertyValueType == TYPE_FORM)
        Form optionValue = JMap.getForm(optionMap, asPropertyType)


    elseif (propertyValueType == TYPE_OBJECT)
        ; Handle children object nesting
        int optionValue = JMap.getObj(optionMap, asPropertyType)

    else
        Error("There was an error determining the value type of the option " + "[" + asOptionKey + "].")
        DebugError("MCM::LoadPropertyForOption", "There was an error determining the value type of the option " + "[" + asOptionKey + "].")
    endif
endFunction

;/
    Internal helper function to load options with their respective
    property values when they have a dependency requirement.

    Property types include: Default, Minimum, Maximum, Steps

    string  @asOptionKey: The key of the option
    string  @asPropertyType: The type of property to load the values into the option
    JArray& @apDependencyObject: The object containing the dependency option's relevant properties to modify the option
/;
function __internal_loadPropertyForOptionWithDependency( \
    string asOptionKey, \
    string asPropertyType, \
    int apDependencyObject \
)
    int dependencyObject            = apDependencyObject; JArray& (Dependency Array)
    string dependencyOptionKey      = JArray.getStr(dependencyObject, 0) ; [0] = Dependency Option

    ; Get the dependency value type from the default value of the dependency option.
    ; The default option must first be initialized for this to work.
    int dependencyOptionValueType   = JMap.valueType(optionsDefaultValueMap, dependencyOptionKey)

    ; Assume the Option is of the same type as the Dependency Option
    if (dependencyOptionValueType == TYPE_INT)
        int dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey) as int
        int offset      = JArray.getInt(dependencyObject, 1) ; [1] = Option Offset
        bool hasOffset  = (offset as bool)

        int finalOptionValue = int_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, finalOptionValue)
        DebugWithArgs( \
            "MCM::LoadPropertyForOption", \ 
            "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, \ 
            "[int] [depends on: "+ dependencyOptionKey + " (value: "+ dependencyOptionValue +")" +"] Setting "+ asPropertyType +" Value to: " + finalOptionValue \
        )

    elseif (dependencyOptionValueType == TYPE_FLOAT)
        float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)
        float offset    = JArray.getFlt(dependencyObject, 1) ; [1] = Option Offset
        bool hasOffset  = (offset as bool)

        float finalOptionValue = float_if (hasOffset, (dependencyOptionValue + offset), dependencyOptionValue)
        self.SetNumberOptionPropertyValue(asOptionKey, asPropertyType, finalOptionValue)
        DebugWithArgs( \
            "MCM::LoadPropertyForOption", \ 
            "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, \ 
            "[float] [depends on: "+ dependencyOptionKey + " (value: "+ dependencyOptionValue +")" +"] Setting "+ asPropertyType +" Value to: " + finalOptionValue \
        )
    elseif (dependencyOptionValueType == TYPE_STRING)
        string dependencyOptionValue = self.GetOptionMenuValue(dependencyOptionKey)
        self.SetStringOptionPropertyValue(asOptionKey, asPropertyType, dependencyOptionValue)
        DebugWithArgs( \
            "MCM::LoadPropertyForOption", \ 
            "asOptionKey: " + asOptionKey + ", asPropertyType: " + asPropertyType, \ 
            "[string] [depends on: "+ dependencyOptionKey + " (value: "+ dependencyOptionValue +")" +"] Setting "+ asPropertyType +" Value to: " + dependencyOptionValue \
        )
    elseif (dependencyOptionValueType == TYPE_FORM)

    elseif (dependencyOptionValueType == TYPE_OBJECT)

    else
        Error("There was an error determining the value type of the dependency option " + dependencyOptionKey)
        DebugError("MCM::LoadPropertyForOption", "There was an error determining the value type of the dependency option " + dependencyOptionKey)
    endif
endFunction

;/
    Loads an option with its respective property value.

    string  @asOptionKey: The key of the option
    string  @asPropertyType: The type of property to load the values into the option
/;
function LoadPropertyForOption(string asOptionKey, string asPropertyType)
    int optionsObj      = RPB_Data.MCM_GetOptionObject()
    bool isObject       = JMap.valueType(optionsObj, asOptionKey) == TYPE_OBJECT ; object type (All options are comprised of an object)
    bool isValidOption  = isObject

    if (!isValidOption)
        DebugError("MCM::LoadPropertyForOption", "The option " + asOptionKey + " does not exist!")
        Error("The option " + asOptionKey + " does not exist!")
        return
    endif

    int optionMap           = JMap.getObj(optionsObj, asOptionKey) ; JMap&
    bool propertyExists     = JMap.hasKey(optionMap, asPropertyType)

    if (!propertyExists)
        DebugError("MCM::LoadPropertyForOption", "There was an error loading the property " + asPropertyType + " for the option " + asOptionKey)
        Error("There was an error loading the property " + asPropertyType + " for the option " + asOptionKey)
        return
    endif

    int propertyValueType   = JMap.valueType(optionMap, asPropertyType)
    bool hasDependency      = (propertyValueType == TYPE_OBJECT)

    if (hasDependency)
        int dependencyObject = JMap.getObj(optionMap, asPropertyType) ; JArray& (Dependency Array)
        __internal_loadPropertyForOptionWithDependency(asOptionKey, asPropertyType, dependencyObject)
        return
    else
        __internal_loadPropertyForOption(asOptionKey, asPropertyType, optionMap)
        return
    endif

    DebugError("MCM::LoadPropertyForOption", "There was an unknown error loading the property " + asPropertyType + " for option " + asOptionKey)
    Error("There was an unknown error loading the property " + asPropertyType + " for option " + asOptionKey)
endFunction

; ============================================================================
;                             Validation Functions
; ============================================================================

function EnsureOptionValueComparison(string asOptionKey, string asValuePropertyType, float afConditionValue, string asComparisonOperator = "<", float afValueToSet = 0.0, string asCallerName = "")
    float updatedValue
    float value
    bool condition

    if (asValuePropertyType == "Default")
        value = self.GetOptionDefaultFloat(asOptionKey)
        
    elseif (asValuePropertyType == "Current")
        value = self.GetOptionValueFloat(asOptionKey)

    elseif (asValuePropertyType == "Minimum")
        value = self.GetOptionMinimum(asOptionKey)

    elseif (asValuePropertyType == "Maximum")
        value = self.GetOptionMaximum(asOptionKey)

    elseif (asValuePropertyType == "Steps")
        value = self.GetOptionSteps(asOptionKey)
    endif

    if (asComparisonOperator == "<")
        condition = (value < afConditionValue)

    elseif (asComparisonOperator == ">") ; Ensure option is less than or equal to
        condition = (value > afConditionValue)

    elseif (asComparisonOperator == "<=") ; Ensure option is greater than but not equal to
        condition = (value <= afConditionValue)

    elseif (asComparisonOperator == ">=") ; Ensure option is less than but not equal to
        condition = (value >= afConditionValue)

    elseif (asComparisonOperator == "==") ; Ensure option is not equal to
        condition = (value == afConditionValue)

    elseif (asComparisonOperator == "!=") ; Ensure option is equal to
        condition = (value != afConditionValue)
    endif


    if (condition)
        float newValue

        if (asComparisonOperator == "<")
            newValue = float_if (afValueToSet, max(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == ">")
            newValue = float_if (afValueToSet, min(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == "<=")
            newValue = float_if (afValueToSet, max(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == ">=")
            newValue = float_if (afValueToSet, min(afConditionValue, afValueToSet), afConditionValue)
    
        elseif (asComparisonOperator == "==")
    
        elseif (asComparisonOperator == "!=")

        endif

        if (asValuePropertyType == "Default")
            self.SetOptionDefaultFloat(asOptionKey, newValue)
            
        elseif (asValuePropertyType == "Current")
            self.SetOptionValueFloat(asOptionKey, newValue)
    
        elseif (asValuePropertyType == "Minimum")
            self.SetOptionMinimum(asOptionKey, newValue)
    
        elseif (asValuePropertyType == "Maximum")
            self.SetOptionMaximum(asOptionKey, newValue)
    
        elseif (asValuePropertyType == "Steps")
            self.SetOptionSteps(asOptionKey, newValue)
        endif
    
        updatedValue = newValue
    endif

    Error("Validation failed for the "+ asValuePropertyType +" Property for Option [" + asOptionKey + "]!", (updatedValue as bool))
    DebugError(asCallerName, "["+ asValuePropertyType +"] Validation failed for Option [" + asOptionKey + "], setting value to " + updatedValue + ".", (updatedValue as bool))
endFunction

function EnsureOptionNotNull(string asOptionKey, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionNotNull", "Function called but there's no implementation!")
endFunction

function EnsureOptionIsNull(string asOptionKey, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionIsNull", "Function called but there's no implementation!")
endFunction

function EnsureOptionIsOfType(string asOptionKey, int aiOptionValueType, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionIsOfType", "Function called but there's no implementation!")
endFunction

function EnsureOptionIsNotOfType(string asOptionKey, int aiOptionValueType, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionIsNotOfType", "Function called but there's no implementation!")
endFunction

function EnsureOptionValueEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionValueEqualTo", "Function called but there's no implementation!")
endFunction

function EnsureOptionValueNotEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    DebugWarn("MCM::EnsureOptionValueNotEqualTo", "Function called but there's no implementation!")
endFunction

function EnsureOptionValueLessThan(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, ">=", afValueToSet, "MCM::EnsureOptionValueLessThan")
endFunction

function EnsureOptionValueLessThanOrEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    if (self.IsValidPropertyType(asValuePropertyType))
        EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, ">", afValueToSet, "MCM::EnsureOptionValueLessThanOrEqualTo")
        return
    endif

    string[] propertyTypes = self.GetPropertyTypes()
    int typeIndex = 0
    while (typeIndex < propertyTypes.Length)
        EnsureOptionValueComparison(asOptionKey, propertyTypes[typeIndex], afConditionValue, ">", afValueToSet, "MCM::EnsureOptionValueLessThanOrEqualTo")
        typeIndex += 1
    endWhile
endFunction

function EnsureOptionValueGreaterThan(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, "<=", afValueToSet, "MCM::EnsureOptionValueGreaterThan")
endFunction

function EnsureOptionValueGreaterThanOrEqualTo(string asOptionKey, float afConditionValue, float afValueToSet = 0.0, string asValuePropertyType = "")
    if (self.IsValidPropertyType(asValuePropertyType))
        EnsureOptionValueComparison(asOptionKey, asValuePropertyType, afConditionValue, "<", afValueToSet, "MCM::EnsureOptionValueGreaterThanOrEqualTo")
        return
    endif

    string[] propertyTypes = self.GetPropertyTypes()
    int typeIndex = 0
    while (typeIndex < propertyTypes.Length)
        EnsureOptionValueComparison(asOptionKey, propertyTypes[typeIndex], afConditionValue, "<", afValueToSet, "MCM::EnsureOptionValueGreaterThanOrEqualTo")
        typeIndex += 1
    endWhile
endFunction

function EnsureOptionValueLessThanOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, ">=", afValueToSet, "MCM::EnsureOptionValueLessThanOptionValue")
endFunction

function EnsureOptionValueLessThanOrEqualToOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, ">", afValueToSet, "MCM::EnsureOptionValueLessThanOrEqualToOptionValue")
endFunction

function EnsureOptionValueGreaterThanOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, "<=", afValueToSet, "MCM::EnsureOptionValueGreaterThanOptionValue")
endFunction

function EnsureOptionValueGreaterThanOrEqualToOptionValue(string asOptionOneKey, string asOptionTwoKey, float afValueToSet = 0.0, string asValuePropertyType = "")
    float propertyTwoValue

    if (asValuePropertyType == "Default")
        propertyTwoValue = self.GetOptionDefaultFloat(asOptionTwoKey)
        
    elseif (asValuePropertyType == "Current")
        propertyTwoValue = self.GetOptionValueFloat(asOptionTwoKey)

    elseif (asValuePropertyType == "Minimum")
        propertyTwoValue = self.GetOptionMinimum(asOptionTwoKey)

    elseif (asValuePropertyType == "Maximum")
        propertyTwoValue = self.GetOptionMaximum(asOptionTwoKey)

    elseif (asValuePropertyType == "Steps")
        propertyTwoValue = self.GetOptionSteps(asOptionTwoKey)
    endif

    EnsureOptionValueComparison(asOptionOneKey, asValuePropertyType, propertyTwoValue, "<", afValueToSet, "MCM::EnsureOptionValueGreaterThanOrEqualToOptionValue")
endFunction

; ============================================================================

function InitializeOptions()
; ============================================================================
;                                   Values
; ============================================================================
    optionsValueMap         = JMap.object() ; To hold each option's value

; ============================================================================
;                                   ID's
; ============================================================================
    optionsFromKeyToIdMap   = JMap.object()     ; Identify options from key to id
    optionsFromIdToKeyMap   = JIntMap.object()  ; Identify options from id to key

; ============================================================================
;                                State (Flags)
; ============================================================================
    optionsStateMap         = JMap.object() ; To hold each option's state (Enabled, Disabled)

; ============================================================================
;                               Default Values
; ============================================================================
    optionsDefaultValueMap  = JMap.object() ; Default values for options

; ============================================================================
;                              Min/Max/Step Values
; ============================================================================
    optionsMinimumValueMap  = JMap.object() ; Minimum values for options
    optionsMaximumValueMap  = JMap.object() ; Maximum values for options
    optionsStepsValueMap    = JMap.object() ; Interval Steps values for options

    ; Persist the Options and assign them to a general container (this will persist the child objects)
    generalContainer = JMap.object()
    JValue.retain(generalContainer, "RPB_MCM01")

    JMap.setObj(generalContainer, "options/value", optionsValueMap)
    JMap.setObj(generalContainer, "options/state", optionsStateMap)
    JMap.setObj(generalContainer, "options/default", optionsDefaultValueMap)
    JMap.setObj(generalContainer, "options/minimum", optionsMinimumValueMap)
    JMap.setObj(generalContainer, "options/maximum", optionsMaximumValueMap)
    JMap.setObj(generalContainer, "options/steps", optionsStepsValueMap)
    JMap.setObj(generalContainer, "options/id/from-key-to-id", optionsFromKeyToIdMap)
    JMap.setObj(generalContainer, "options/id/from-id-to-key", optionsFromIdToKeyMap)
endFunction


int optionsValueMap         ; Holds the value for all options
int optionsStateMap         ; Holds the state for all options (enabled, disabled)
int optionsDefaultValueMap  ; Holds the default values for all options
int optionsMinimumValueMap  ; Holds the minimum values for all options
int optionsMaximumValueMap  ; Holds the maximum values for all options
int optionsStepsValueMap    ; Holds the interval steps (how much to increment, or decrement by) values for all options
int optionsFromKeyToIdMap   ; Holds the identifier to identify an option from Key to ID
int optionsFromIdToKeyMap   ; Holds the identifier to identify an option from ID to Key
int generalContainer        ; Holds every option container and persists them


; ============================================================================
;                             Option Setters/Getters
; ============================================================================

;/
    Retrieves the option key specified from its option id.

    int     @optionId: The option id to retrieve the key from.
    bool?   @includePageInKey: Whether to include the page name and delimiter in the returned key.

    returns: The option's key.
 /;
 string function GetKeyFromOption(int optionId, bool includePageInKey = true)
    string optionKey = JIntMap.getStr(optionsFromIdToKeyMap, optionId)

    if (!includePageInKey)
        int indexOfDelimiter = StringUtil.Find(optionKey, "/")
        return StringUtil.Substring(optionKey, indexOfDelimiter + 1)
    endif

    return optionKey
endFunction

;/
    Retrieves the option specified by the key.

    string  @_key: The key to retrieve the option from.
    returns: The option's id.
 /;
int function GetOption(string optionKey)
    return JMap.getInt(optionsFromKeyToIdMap, optionKey)
endFunction

;/
    Sets the value of a bool-type option.

    string  @asOptionKey: The key of the option.
    bool    @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueBool(string optionKey, bool value, string page = "")
    ; options/value/Whiterun/Stripping::Allow Stripping
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    JMap.setInt(optionsValueMap, optionAsStored, value as int)
endFunction

;/
    Sets the value of an int option.

    string  @asOptionKey: The key of the option.
    int     @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueInt(string optionKey, int value, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    JMap.setInt(optionsValueMap, optionAsStored, value)
endFunction

;/
    Sets the value of a float option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueFloat(string optionKey, float value, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    JMap.setFlt(optionsValueMap, optionAsStored, value)
endFunction

;/
    Sets the value of a string option.

    string  @asOptionKey: The key of the option.
    string  @value: The value to assign to this option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionValueString(string optionKey, string value, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    JMap.setStr(optionsValueMap, optionAsStored, value)
endFunction

;/
    Checks if the option exists in storage.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function OptionExists(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.hasKey(optionsFromKeyToIdMap, optionAsStored)
endFunction

;/
    Checks if the option has any value associated with it.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function OptionHasValue(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.hasKey(optionsValueMap, optionAsStored)
endFunction

;/
    Checks if the option has any state associated with it (Enabled, Disabled).

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function OptionHasState(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.hasKey(optionsStateMap, optionAsStored)
endFunction

;/
    Registers an option in storage.
    Both the Option Key and Option ID are stored in order
    to identify the option in both ways.

    string  @asOptionKey: The key of the option.
    int     @optionId: The ID of the option at the time of render.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function RegisterOption(string optionKey, int optionId, string page = "")
    ; For bi-directional identification (option-key to option-id and option-id to option-key)
    string optionAsStored = self.GetOptionAsStored(optionKey, page)

    JMap.setInt(optionsFromKeyToIdMap, optionAsStored, optionId)
    JIntMap.setStr(optionsFromIdToKeyMap, optionId, optionAsStored)
endFunction

;/
    Sets an option's state value

    string  @asOptionKey: The key of the option.
    int     @optionState: The state to assign to the option (Enabled, Disabled).
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
function SetOptionState(string optionKey, int optionState, string page = "")
    JMap.setInt(optionsStateMap, optionKey, optionState)
endFunction

;/
    Retrieves the value of a bool option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
bool function GetOptionValueBool(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.getInt(optionsValueMap, optionAsStored) as bool
endFunction

;/
    Retrieves the value of an int option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
int function GetOptionValueInt(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.getInt(optionsValueMap, optionAsStored)
endFunction

;/
    Retrieves the value of a float option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
float function GetOptionValueFloat(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.getFlt(optionsValueMap, optionAsStored)
endFunction

;/
    Retrieves the value of a string option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
string function GetOptionValueString(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.getStr(optionsValueMap, optionAsStored)
endFunction

;/
    Retrieves the current state of the option.

    string  @asOptionKey: The key of the option.
    string? @page: The page where the option is rendered (will be CurrentPage if null).
/;
int function GetOptionState(string optionKey, string page = "")
    string optionAsStored = self.GetOptionAsStored(optionKey, page)
    return JMap.getInt(optionsStateMap, optionAsStored)
endFunction

;/
    Sets the default value of a bool option.

    string  @asOptionKey: The key of the option.
    bool    @value: The value to set.
/;
function SetOptionDefaultBool(string optionKey, bool value)
    JMap.setInt(optionsDefaultValueMap, optionKey, value as int)
endFunction

;/
    Sets the default value of an int option.

    string  @asOptionKey: The key of the option.
    int     @value: The value to set.
/;
function SetOptionDefaultInt(string optionKey, int value)
    JMap.setInt(optionsDefaultValueMap, optionKey, value)
endFunction

;/
    Sets the default value of a float option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to set.
/;
function SetOptionDefaultFloat(string optionKey, float value)
    JMap.setFlt(optionsDefaultValueMap, optionKey, value)
endFunction
;/
    Sets the default value of a string option.

    string  @asOptionKey: The key of the option.
    string  @value: The value to set.
/;
function SetOptionDefaultString(string optionKey, string value)
    JMap.setStr(optionsDefaultValueMap, optionKey, value)
endFunction

;/
    Retrieves the default value of a bool option.

    string  @asOptionKey: The key of the option.
/;
bool function GetOptionDefaultBool(string optionKey)
    return JMap.getInt(optionsDefaultValueMap, optionKey) as bool
endFunction

;/
    Retrieves the default value of an int option.

    string  @asOptionKey: The key of the option.
/;
int function GetOptionDefaultInt(string optionKey)
    return JMap.getInt(optionsDefaultValueMap, optionKey)
endFunction

;/
    Retrieves the default value of a float option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionDefaultFloat(string optionKey)
    return JMap.getFlt(optionsDefaultValueMap, optionKey)
endFunction

;/
    Retrieves the default value of a string option.

    string  @asOptionKey: The key of the option.
/;
string function GetOptionDefaultString(string optionKey)
    return JMap.getStr(optionsDefaultValueMap, optionKey)
endFunction

;/
    Sets the minimum value of an option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to set
/;
function SetOptionMinimum(string optionKey, float value)
    JMap.setFlt(optionsMinimumValueMap, optionKey, value)
endFunction

;/
    Sets the maximum value of an option.

    string  @asOptionKey: The key of the option.
    float   @value: The value to set
/;
function SetOptionMaximum(string optionKey, float value)
    JMap.setFlt(optionsMaximumValueMap, optionKey, value)
endFunction

;/
    Sets the interval steps value of an option (how much to increment or decrement by each step).

    string  @asOptionKey: The key of the option.
    float   @value: The value to set
/;
function SetOptionSteps(string optionKey, float value)
    JMap.setFlt(optionsStepsValueMap, optionKey, value)
endFunction

;/
    Retrieves the minimum value of an option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionMinimum(string optionKey)
    return JMap.getFlt(optionsMinimumValueMap, optionKey)
endFunction

;/
    Retrieves the maximum value of an option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionMaximum(string optionKey)
    return JMap.getFlt(optionsMaximumValueMap, optionKey)
endFunction

;/
    Retrieves the interval steps value of an option.

    string  @asOptionKey: The key of the option.
/;
float function GetOptionSteps(string optionKey)
    return JMap.getFlt(optionsStepsValueMap, optionKey)
endFunction
