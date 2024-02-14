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
    return miscVars.GetForm(outfitId + "::" + outfitBodyPart, "clothing/outfits") as Armor
endFunction

;/
    Returns the outfit id from its name.

    string  @outfitName: The name of the outfit as set up in the name field through the MCM.
    returns: The outfit's id.
/;
string function GetOutfitIdentifier(string outfitName)
    return miscVars.GetString(outfitName, "clothing/outfits")
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
    ; if (Config.ShouldDisplaySentencePage())
        JArray.addStr(_pagesArray, "Sentence")
    ; endif
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
bool function GetToggleOptionState(string page, string optionName)
    return bool_if (self.OptionHasValue(optionName, page), self.GetOptionValueBool(optionName, page), self.GetOptionDefaultBool(optionName))
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
    return float_if (self.OptionHasValue(optionName, page), self.GetOptionValueFloat(optionName, page), self.GetOptionDefaultFloat(optionName))
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
    return string_if (self.OptionHasValue(optionName, page), self.GetOptionValueString(optionName, page), self.GetOptionDefaultString(optionName))
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
    return string_if (self.OptionHasValue(optionName, page), self.GetOptionValueString(optionName, page), self.GetOptionDefaultString(optionName))
endFunction

string function GetOptionInputValue(string option, string thePage = "")
    return GetInputOptionValue(thePage, option)
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

string function GetOptionAsStored(string optionKey, string page = "")
    return string_if (page == "", CurrentPage, page) + "/" + optionKey
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

    Debug("MCM::ToggleOption", "Set new value of " + !option + " for " + _key + "(OptionKey: "+ optionKey +")" + "(option_id: "+ optionId +")", true)
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
    string optionKey = CurrentRenderedCategory + "::" + _key
    
    bool defaultValue   = bool_if (defaultValueOverride > -1, defaultValueOverride, self.GetOptionDefaultBool(optionKey))
    bool value          = self.GetOptionValueBool(optionKey)
    int flags           = self.GetOptionState(optionKey)
    int optionId        = AddToggleOption(displayedText, bool_if (self.OptionHasValue(optionKey), value, defaultValue), int_if (self.OptionHasState(optionKey), flags, defaultFlags))

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
    string optionKey = CurrentRenderedCategory + "::" + _key

    string defaultValue   = string_if (defaultValueOverride != "", defaultValueOverride, self.GetOptionDefaultString(optionKey))
    string value          = self.GetOptionValueString(optionKey)
    int flags             = self.GetOptionState(optionKey)
    int optionId          = AddTextOption(displayedText, string_if (self.OptionHasValue(optionKey), value, defaultValue), int_if (self.OptionHasState(optionKey), flags, defaultFlags))

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
    string optionKey = CurrentRenderedCategory + "::" + _key

    float defaultValue     = float_if (defaultValueOverride > -1.0, defaultValueOverride, self.GetOptionDefaultFloat(optionKey))
    float value            = self.GetOptionValueFloat(optionKey)
    int flags              = self.GetOptionState(optionKey)
    int optionId           = AddSliderOption(displayedText, float_if (self.OptionHasValue(optionKey), value, defaultValue), formatString, int_if (self.OptionHasState(optionKey), flags, defaultFlags))
    
    if (!self.OptionExists(optionKey))
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
    string optionKey = CurrentRenderedCategory + "::" + _key

    string defaultValue         = string_if (defaultValueOverride != "", defaultValueOverride, self.GetOptionDefaultString(optionKey))
    string value                = self.GetOptionValueString(optionKey)
    int flags                   = self.GetOptionState(optionKey)
    int optionId                = AddMenuOption(displayedText, string_if (self.OptionHasValue(optionKey), value, defaultValue), int_if (self.OptionHasState(optionKey), flags, defaultFlags))

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
    string optionKey = CurrentRenderedCategory + "::" + _key

    if (defaultValueOverride)
        self.SetOptionDefaultString(optionKey, defaultValueOverride)
    endif
 
    string defaultValue         = self.GetOptionDefaultString(optionKey)
    string value                = self.GetOptionValueString(optionKey)
    int flags                   = self.GetOptionState(optionKey)
    int optionId                = AddInputOption(displayedText, string_if (self.OptionHasValue(optionKey), value, defaultValue), int_if (self.OptionHasState(optionKey), flags, defaultFlags))

    if (!self.OptionExists(optionKey))
        self.RegisterOption(optionKey, optionId)
    endif

    ; Debug("MCM::AddOptionInputKey", "Add " + optionKey)

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
    ModName = "Realistic Prison and Bounty"
    self.InitializePages()
    self.InitializeOptions()
    self.RegisterEvents()
endEvent

; event OnConfigOpen()
;     self.InitializePages()

;     ; if (Config.ShouldDisplaySentencePage())
;     ;     RPB_CurrentPage = "Sentence"
;     ;     self.OnPageReset(RPB_CurrentPage)
;     ; endif
; endEvent

string property RPB_CurrentPage auto
string previousPage

function RenderBasedOnPage(string page)
    if (page == "Stats")
        RealisticPrisonAndBounty_MCM_Stats.Render(self)

    elseif (page == "General")
        RealisticPrisonAndBounty_MCM_General.Render(self)

    elseif (page == "Deleveling")
        RealisticPrisonAndBounty_MCM_Delevel.Render(self)

    elseif (page == "Clothing")
        RealisticPrisonAndBounty_MCM_Clothing.Render(self)

    elseif (page == "Debug")
        RealisticPrisonAndBounty_MCM_Debug.Render(self)

    else ; Holds
        RealisticPrisonAndBounty_MCM_Holds.Render(self)
    endif
endFunction

event OnPageReset(string page)
    ; if (previousPage != "" && page == "")
    ;     self.RenderBasedOnPage(previousPage)
    ;     return
    ; endif

    ; if (page == "")
    ;     RPB_CurrentPage = "Sentence"
    ;     RPB_MCM_Sentence.Render(self)
    ; endif

    RealisticPrisonAndBounty_MCM_Delevel.Render(self)
    RealisticPrisonAndBounty_MCM_Holds.Render(self)
    RealisticPrisonAndBounty_MCM_General.Render(self)
    RealisticPrisonAndBounty_MCM_Clothing.Render(self)
    RealisticPrisonAndBounty_MCM_Debug.Render(self)
    RealisticPrisonAndBounty_MCM_Stats.Render(self)
    RPB_MCM_Sentence.Render(self)

    RPB_Utility.Debug("MCM::OnPageReset", "Page: " + page, true)

    previousPage = page
endEvent

event OnOptionHighlight(int option)
    RealisticPrisonAndBounty_MCM_Delevel.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Holds.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_General.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnHighlight(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnHighlight(self, option)
    RPB_MCM_Sentence.OnHighlight(self, option)

    Trace("MCM::OnHighlight", "Option ID: " + option, true)
    ; Trace("initDefaults", "Times Stripped in Haafingar: " + actorVars.Get("[20]Haafingar::Times Stripped"), true)
endEvent

event OnOptionDefault(int option)
    RealisticPrisonAndBounty_MCM_Delevel.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Holds.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_General.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnDefault(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnDefault(self, option)
    RPB_MCM_Sentence.OnDefault(self, option)

endEvent

event OnOptionSelect(int option)
    RealisticPrisonAndBounty_MCM_Delevel.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Holds.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_General.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnSelect(self, option)
    RPB_MCM_Sentence.OnSelect(self, option)

endEvent

event OnOptionSliderOpen(int option)
    RealisticPrisonAndBounty_MCM_Delevel.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Holds.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnSliderOpen(self, option)
    RPB_MCM_Sentence.OnSliderOpen(self, option)

endEvent

event OnOptionSliderAccept(int option, float value)
    RealisticPrisonAndBounty_MCM_Delevel.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Holds.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_General.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Clothing.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Debug.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Stats.OnSliderAccept(self, option, value)
    RPB_MCM_Sentence.OnSliderAccept(self, option, value)
endEvent

event OnOptionMenuOpen(int option)
    RealisticPrisonAndBounty_MCM_Delevel.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Holds.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnMenuOpen(self, option)
    RPB_MCM_Sentence.OnMenuOpen(self, option)

endEvent

event OnOptionMenuAccept(int option, int index)
    RealisticPrisonAndBounty_MCM_Delevel.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Holds.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_General.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Clothing.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Debug.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Stats.OnMenuAccept(self, option, index)
    RPB_MCM_Sentence.OnMenuAccept(self, option, index)
endEvent

event OnOptionInputOpen(int option)
    RealisticPrisonAndBounty_MCM_Delevel.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_Holds.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_General.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_Clothing.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_Debug.OnInputOpen(self, option)
    RealisticPrisonAndBounty_MCM_Stats.OnInputOpen(self, option)
    RPB_MCM_Sentence.OnInputOpen(self, option)
endEvent

event OnOptionInputAccept(int option, string inputValue)
    RealisticPrisonAndBounty_MCM_Delevel.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_Holds.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_General.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_Clothing.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_Debug.OnInputAccept(self, option, inputValue)
    RealisticPrisonAndBounty_MCM_Stats.OnInputAccept(self, option, inputValue)
    RPB_MCM_Sentence.OnInputAccept(self, option, inputValue)
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

        ; int settingValue = Game.GetGameSettingInt("iCrimeGoldTrespass")
        ; RPB_Utility.Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Assault")
        Game.SetGameSettingInt("iCrimeGoldAttack", optionValue as int)
        
        int settingValue = Game.GetGameSettingInt("iCrimeGoldAttack")
        RPB_Utility.Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Murder")
        Game.SetGameSettingInt("iCrimeGoldMurder", optionValue as int)
        
        ; int settingValue = Game.GetGameSettingInt("iCrimeGoldMurder")
        ; RPB_Utility.Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Theft")
        Game.SetGameSettingFloat("fCrimeGoldSteal", optionValue)
        
        ; float settingValue = Game.GetGameSettingFloat("fCrimeGoldSteal")
        ; RPB_Utility.Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Pickpocketing")
        Game.SetGameSettingInt("iCrimeGoldPickpocket", optionValue as int)
        
        ; int settingValue = Game.GetGameSettingInt("iCrimeGoldPickpocket")
        ; RPB_Utility.Debug("MCM::General::OnOptionSliderAccept", optionName + " value: " + settingValue)

    elseif (optionName == "Bounty for Actions::Lockpicking")
        
    elseif (optionName == "Bounty for Actions::Disturbing the Peace")

    endif
endEvent

function RegisterEvents()
    self.RegisterForModEvent("RPB_SliderOptionChanged", "OnSliderOptionChanged")
endFunction

function CreatePageOption(string page)
    miscVars.CreateStringMap("options/value/" + page)
    miscVars.CreateStringMap("options/state/" + page)
    miscVars.CreateIntegerMap("options/id/from-id-to-key/" + page)
    miscVars.CreateStringMap("options/id/from-key-to-id/" + page)

    miscVars.AddToContainer("options/value/", "options/value/" + page)
    miscVars.AddToContainer("options/state", "options/state/" + page)
    miscVars.AddToContainer("options/id", "options/id/from-key-to-id/" + page)
    miscVars.AddToContainer("options/id", "options/id/from-id-to-key/" + page)
endFunction

function InitializeOptions()
; ============================================================================
;                                   Values
; ============================================================================
    optionsValueMap         = JMap.object() ; To hold each option's value

; ============================================================================
;                                   ID's
; ============================================================================
    optionsFromKeyToIdMap   = JMap.object() ; Identify options from key to id
    optionsFromIdToKeyMap   = JIntMap.object() ; Identify options from id to key

; ============================================================================
;                                State (Flags)
; ============================================================================
    optionsStateMap         = JMap.object() ; To hold each option's state (Enabled, Disabled)

; ============================================================================
;                               Default Values
; ============================================================================
    optionsDefaultValueMap  = JMap.object() ; Default values for options
    generalContainer        = JMap.object() ; To hold all containers (temporary)

    ; JValue.retain(optionsValueMap)
    ; JValue.retain(optionsStateMap)
    ; JValue.retain(optionsDefaultValueMap)
    ; JValue.retain(optionsFromKeyToIdMap)
    ; JValue.retain(optionsFromIdToKeyMap)
    JValue.retain(generalContainer)

    JMap.setObj(generalContainer, "options/value", optionsValueMap)
    JMap.setObj(generalContainer, "options/state", optionsStateMap)
    JMap.setObj(generalContainer, "options/default", optionsDefaultValueMap)
    JMap.setObj(generalContainer, "options/id/from-key-to-id", optionsFromKeyToIdMap)
    JMap.setObj(generalContainer, "options/id/from-id-to-key", optionsFromIdToKeyMap)
    JMap.setObj(generalContainer, "clothing/outfits", miscVars.GetHandle("clothing/outfits"))

    self.SetOptionDefaultFloat("General::Update Interval", 20)
    self.SetOptionDefaultFloat("General::Bounty Decay (Update Interval)", 4)
    self.SetOptionDefaultFloat("General::Infamy Decay (Update Interval)", 1)
    self.SetOptionDefaultFloat("General::Timescale", 20)
    self.SetOptionDefaultFloat("General::TimescalePrison", 60)
    self.SetOptionDefaultFloat("General::Arrest Elude Warning Time", 4.0)
    self.SetOptionDefaultBool("General::ArrestNotifications", true)
    self.SetOptionDefaultBool("General::JailedNotifications", true)
    self.SetOptionDefaultBool("General::BountyDecayNotifications", true)
    self.SetOptionDefaultBool("General::InfamyNotifications", true)

    ; Bounty for Actions
    self.SetOptionDefaultFloat("Bounty for Actions::Trespassing", 300)
    self.SetOptionDefaultFloat("Bounty for Actions::Assault", 800)
    self.SetOptionDefaultFloat("Bounty for Actions::Theft", 1.7)
    self.SetOptionDefaultFloat("Bounty for Actions::Pickpocketing", 200)
    self.SetOptionDefaultFloat("Bounty for Actions::Lockpicking", 100)
    self.SetOptionDefaultFloat("Bounty for Actions::Disturbing the Peace", 100)

    ; Clothing::Configuration
    self.SetOptionDefaultBool("Configuration::NudeBodyModInstalled", false)
    self.SetOptionDefaultBool("Configuration::UnderwearModInstalled", false)

    ; Clothing::Item Slots
    self.SetOptionDefaultFloat("Item Slots::Underwear (Top)", 56)
    self.SetOptionDefaultFloat("Item Slots::Underwear (Bottom)", 52)

    ; Arrest
    self.SetOptionDefaultFloat("Arrest::Minimum Bounty to Arrest", 500)
    self.SetOptionDefaultFloat("Arrest::Guaranteed Payable Bounty", 1500)
    self.SetOptionDefaultFloat("Arrest::Maximum Payable Bounty", 2500)
    self.SetOptionDefaultFloat("Arrest::Maximum Payable Bounty (Chance)", 33)
    self.SetOptionDefaultBool("Arrest::Always Arrest for Violent Crimes", true)
    self.SetOptionDefaultFloat("Arrest::Additional Bounty when Eluding (%)", 5)
    self.SetOptionDefaultFloat("Arrest::Additional Bounty when Eluding", 200)
    self.SetOptionDefaultFloat("Arrest::Additional Bounty when Resisting (%)", 33)
    self.SetOptionDefaultFloat("Arrest::Additional Bounty when Resisting", 200)
    self.SetOptionDefaultFloat("Arrest::Additional Bounty when Defeated (%)", 33)
    self.SetOptionDefaultFloat("Arrest::Additional Bounty when Defeated", 500)
    self.SetOptionDefaultBool("Arrest::Allow Civilian Capture", true)
    self.SetOptionDefaultBool("Arrest::Allow Unconscious Arrest", true)
    self.SetOptionDefaultBool("Arrest::Allow Unconditional Arrest", false)
    self.SetOptionDefaultFloat("Arrest::Unequip Hand Garments", 0)
    self.SetOptionDefaultFloat("Arrest::Unequip Head Garments", 1000)
    self.SetOptionDefaultFloat("Arrest::Unequip Foot Garments", 4000)

    ; Frisking
    self.SetOptionDefaultBool("Frisking::Allow Frisking", true)
    self.SetOptionDefaultBool("Frisking::Unconditional Frisking", false)
    self.SetOptionDefaultFloat("Frisking::Minimum Bounty for Frisking", 500)
    self.SetOptionDefaultFloat("Frisking::Frisk Search Thoroughness", 10)
    self.SetOptionDefaultBool("Frisking::Confiscate Stolen Items", true)
    self.SetOptionDefaultBool("Frisking::Strip Search if Stolen Items Found", true)
    self.SetOptionDefaultFloat("Frisking::Minimum No. of Stolen Items Required", 10)

    ; Stripping
    self.SetOptionDefaultBool("Stripping::Allow Stripping", true)
    self.SetOptionDefaultString("Stripping::Handle Stripping On", "Minimum Sentence")
    self.SetOptionDefaultFloat("Stripping::Minimum Bounty to Strip", 1500)
    self.SetOptionDefaultFloat("Stripping::Minimum Violent Bounty to Strip", 1500)
    self.SetOptionDefaultFloat("Stripping::Minimum Sentence to Strip", 15)
    self.SetOptionDefaultBool("Stripping::Strip when Defeated", true)
    self.SetOptionDefaultFloat("Stripping::Strip Search Thoroughness", 10)

    ; Clothing
    self.SetOptionDefaultBool("Clothing::Allow Clothing", false)
    self.SetOptionDefaultString("Clothing::Handle Clothing On", "Maximum Sentence")
    self.SetOptionDefaultFloat("Clothing::Maximum Bounty", 1500)
    self.SetOptionDefaultFloat("Clothing::Maximum Violent Bounty", 1500)
    self.SetOptionDefaultFloat("Clothing::Maximum Sentence", 100)
    self.SetOptionDefaultBool("Clothing::When Defeated", true)
    self.SetOptionDefaultString("Clothing::Outfit", "Default")
    
    ; Jail
    self.SetOptionDefaultBool("Jail::Unconditional Imprisonment", false)
    self.SetOptionDefaultFloat("Jail::Guaranteed Payable Bounty", 2000)
    self.SetOptionDefaultFloat("Jail::Maximum Payable Bounty", 4000)
    self.SetOptionDefaultFloat("Jail::Maximum Payable Bounty (Chance)", 20)
    self.SetOptionDefaultFloat("Jail::Bounty Exchange", 50)
    self.SetOptionDefaultFloat("Jail::Bounty to Sentence", 100)
    self.SetOptionDefaultFloat("Jail::Minimum Sentence", 10)
    self.SetOptionDefaultFloat("Jail::Maximum Sentence", 365)
    self.SetOptionDefaultBool("Jail::Sentence pays Bounty", false)
    self.SetOptionDefaultFloat("Jail::Cell Search Thoroughness", 10)
    self.SetOptionDefaultString("Jail::Cell Lock Level", "Adept")
    self.SetOptionDefaultBool("Jail::Fast Forward", true)
    self.SetOptionDefaultFloat("Jail::Day to Fast Forward From", 5)
    self.SetOptionDefaultString("Jail::Handle Skill Loss", "1x Random Perk Skill")
    self.SetOptionDefaultInt("Jail::Day to Start Losing Skills (Stat)", 0)
    self.SetOptionDefaultInt("Jail::Day to Start Losing Skills (Perk)", 5)
    self.SetOptionDefaultInt("Jail::Chance to Lose Skills (Stat)", 0)
    self.SetOptionDefaultInt("Jail::Chance to Lose Skills (Perk)", 80)
    self.SetOptionDefaultFloat("Jail::Recognized Criminal Penalty", 100)
    self.SetOptionDefaultFloat("Jail::Known Criminal Penalty", 100)
    self.SetOptionDefaultFloat("Jail::Minimum Bounty to Trigger", 2500)

    ; Additional Charges
    self.SetOptionDefaultFloat("Additional Charges::Bounty for Impersonation", 1700)
    self.SetOptionDefaultFloat("Additional Charges::Bounty for Enemy of Hold", 2000)
    self.SetOptionDefaultFloat("Additional Charges::Bounty for Stolen Items", 700)
    self.SetOptionDefaultFloat("Additional Charges::Bounty for Stolen Item", 75)
    self.SetOptionDefaultFloat("Additional Charges::Bounty for Contraband", 600)
    self.SetOptionDefaultFloat("Additional Charges::Bounty for Cell Key", 2200)
    
    ; Release
    ; self.SetOptionDefaultBool("Release::Enable Release Fees", false)
    ; self.SetOptionDefaultFloat("Release::Chance for Event", 80)
    ; self.SetOptionDefaultFloat("Release::Minimum Bounty to owe Fees", 0)
    ; self.SetOptionDefaultFloat("Release::Release Fees (%)", 15)
    ; self.SetOptionDefaultFloat("Release::Release Fees", 0)
    ; self.SetOptionDefaultFloat("Release::Days Given to Pay", 10)
    self.SetOptionDefaultBool("Release::Enable Item Retention", true)
    self.SetOptionDefaultFloat("Release::Minimum Bounty to Retain Items", 0)
    self.SetOptionDefaultBool("Release::Auto Re-Dress on Release", true)

    ; Escape
    self.SetOptionDefaultFloat("Escape::Escape Bounty (%)", 15)
    self.SetOptionDefaultFloat("Escape::Escape Bounty", 1000)
    self.SetOptionDefaultBool("Escape::Allow Surrendering", true)
    self.SetOptionDefaultBool("Escape::Frisk Search upon Captured", true)
    self.SetOptionDefaultBool("Escape::Strip Search upon Captured", true)

    ; Bounty Decaying
    self.SetOptionDefaultBool("Bounty Decaying::Enable Bounty Decaying", true)
    self.SetOptionDefaultBool("Bounty Decaying::Decay while in Prison", true)
    self.SetOptionDefaultFloat("Bounty Decaying::Bounty Lost (%)", 5)
    self.SetOptionDefaultFloat("Bounty Decaying::Bounty Lost", 200)

    ; Bounty Hunting
    self.SetOptionDefaultBool("Bounty Hunting::Enable Bounty Hunters", true)
    self.SetOptionDefaultBool("Bounty Hunting::Allow Outlaw Bounty Hunters", true)
    self.SetOptionDefaultFloat("Bounty Hunting::Minimum Bounty", 2500)
    self.SetOptionDefaultFloat("Bounty Hunting::Bounty (Posse)", 6000)

    ; Infamy
    self.SetOptionDefaultBool("Infamy::Enable Infamy", true)
    self.SetOptionDefaultFloat("Infamy::Infamy Gained (%)", 0.02)
    self.SetOptionDefaultFloat("Infamy::Infamy Gained", 40)
    self.SetOptionDefaultFloat("Infamy::Infamy Recognized Threshold", 1000)
    self.SetOptionDefaultFloat("Infamy::Infamy Known Threshold", 6000)
    self.SetOptionDefaultFloat("Infamy::Infamy Lost (%)", 0.01)
    self.SetOptionDefaultFloat("Infamy::Infamy Lost", 20)
endFunction

int optionsValueMap
int optionsStateMap
int optionsDefaultValueMap
int optionsFromKeyToIdMap
int optionsFromIdToKeyMap
int generalContainer


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

function SetOptionValueBool(string optionKey, bool value, string page = "")
    ; options/value/Whiterun/Stripping::Allow Stripping
    JMap.setInt(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey, value as int)
endFunction

function SetOptionValueInt(string optionKey, int value, string page = "")
    JMap.setInt(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey, value)
endFunction

function SetOptionValueFloat(string optionKey, float value, string page = "")
    JMap.setFlt(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey, value)
    ; Debug("MCM::SetOptionValueFloat", "Set " + string_if (page == "", CurrentPage, page) + "/" + optionKey + " value to: " + value, true)
endFunction

function SetOptionValueString(string optionKey, string value, string page = "")
    JMap.setStr(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey, value)
endFunction

bool function OptionExists(string optionKey, string page = "")
    return JMap.hasKey(optionsFromKeyToIdMap, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

bool function OptionHasValue(string optionKey, string page = "")
    return JMap.hasKey(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

bool function OptionHasState(string optionKey, string page = "")
    return JMap.hasKey(optionsStateMap, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

function RegisterOption(string optionKey, int optionId, string page = "")
    ; For bi-directional identification (option-key to option-id and option-id to option-key)
    JMap.setInt(optionsFromKeyToIdMap, string_if (page == "", CurrentPage, page) + "/" + optionKey, optionId)
    JIntMap.setStr(optionsFromIdToKeyMap, optionId, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

function SetOptionState(string optionKey, int optionState, string page = "")
    JMap.setInt(optionsStateMap, optionKey, optionState)
endFunction

bool function GetOptionValueBool(string optionKey, string page = "")
    return JMap.getInt(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey) as bool
endFunction

int function GetOptionValueInt(string optionKey, string page = "")
    return JMap.getInt(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

float function GetOptionValueFloat(string optionKey, string page = "")
    return JMap.getFlt(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

string function GetOptionValueString(string optionKey, string page = "")
    return JMap.getStr(optionsValueMap, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

int function GetOptionState(string optionKey, string page = "")
    return JMap.getInt(optionsStateMap, string_if (page == "", CurrentPage, page) + "/" + optionKey)
endFunction

function SetOptionDefaultBool(string optionKey, bool value)
    JMap.setInt(optionsDefaultValueMap, optionKey, value as int)
endFunction

function SetOptionDefaultInt(string optionKey, int value)
    JMap.setInt(optionsDefaultValueMap, optionKey, value)
endFunction

function SetOptionDefaultFloat(string optionKey, float value)
    JMap.setFlt(optionsDefaultValueMap, optionKey, value)
endFunction

function SetOptionDefaultString(string optionKey, string value)
    JMap.setStr(optionsDefaultValueMap, optionKey, value)
endFunction

bool function GetOptionDefaultBool(string optionKey)
    return JMap.getInt(optionsDefaultValueMap, optionKey) as bool
endFunction

int function GetOptionDefaultInt(string optionKey)
    return JMap.getInt(optionsDefaultValueMap, optionKey)
endFunction

float function GetOptionDefaultFloat(string optionKey)
    return JMap.getFlt(optionsDefaultValueMap, optionKey)
endFunction

string function GetOptionDefaultString(string optionKey)
    return JMap.getStr(optionsDefaultValueMap, optionKey)
endFunction