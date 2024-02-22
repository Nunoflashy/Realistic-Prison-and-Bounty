Scriptname RPB_MCM extends SKI_ConfigBase  

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
    ; if (Config.ShouldDisplaySentencePage())
        ; JArray.addStr(_pagesArray, "Sentence")
    ; endif
    RPB_Prison actorPrison; = RPB_Prison.GetPrisonForHold("Haafingar")
    string prisonName = actorPrison.Name
    int n = 0
    while (n < actorPrison.Prisoners.Count)
        string prisonerName = actorPrison.Prisoners.AtIndex(n).Name
        int prisonerFormID  = actorPrison.Prisoners.AtIndex(n).GetActor().GetFormID()
        RPB_Utility.Debug("MCM::InitializePages", "prisonerFormID: " + prisonerFormID)
        JArray.addStr(_pagesArray, "Sentence" + " - " + prisonerFormID)
        n += 1
    endWhile

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

    Trace("MCM::ToggleOption", "Set new value of " + !option + " for " + _key + "(OptionKey: "+ optionKey +")" + "(option_id: "+ optionId +")", true)
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
    ModName = RPB_Data.MCM_GetRootPropertyOfTypeString("Config", "Name")

    self.InitializePages()
    self.InitializeOptions()
    self.RegisterEvents()
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


function LoadMaximums()
    ; ; Initialize Maximums
    ; int maximumsObj     = RPB_Data.MCM_GetMaximumsObject()
    ; int maximumsCount   = JValue.count(maximumsObj)
    ; RPB_Utility.Debug("MCM::LoadMaximums", "Called")

    ; int optionIndex = 0
    ; while (optionIndex < maximumsCount)
    ;     string optionKey = JMap.getNthKey(maximumsObj, optionIndex)
        
    ;     if (JMap.valueType(maximumsObj, optionKey) == 5) ; object
    ;         int optionValueObject = JMap.getObj(maximumsObj, optionKey)
    ;         string dependsType          = JArray.getStr(optionValueObject, 0)
    ;         string dependsOption        = JArray.getStr(optionValueObject, 1)
    ;         float dependsOffset         = JArray.getFlt(optionValueObject, 2)
    ;         float dependsOptionValue    = self.GetOptionSliderValue(dependsOption) ; dependency option
    ;         ; float dependsOptionValue    = JMap.getFlt(maximumsObj, dependsOption) ; dependency option
    ;         RPB_Utility.Debug("MCM::LoadMaximums", "optionKey: " + optionKey + ", value: " + (dependsOptionValue + dependsOffset))
    ;         self.SetOptionMaximum(optionKey, dependsOptionValue + dependsOffset) ; set the value based on the dependency option

    ;     elseif (JMap.valueType(maximumsObj, optionKey) == 3 || JMap.valueType(maximumsObj, optionKey) == 2) ; float|int
    ;         float optionValue = JMap.getFlt(maximumsObj, optionKey)
    ;         RPB_Utility.Debug("MCM::LoadMaximums", "optionKey: " + optionKey + ", value: " + optionValue)
    ;         self.SetOptionMaximum(optionKey, optionValue)

    ;     endif
    ;     optionIndex += 1
    ; endWhile
endFunction

function LoadDefaults()
    int optionsObj  = RPB_Data.MCM_GetOptionObject()
    int optionCount = JValue.count(optionsObj)

    int optionIndex = 0

    bool continue = false

    while (optionIndex < optionCount)
        string optionKey    = JMap.getNthKey(optionsObj, optionIndex) ; Current Option Key
        int optionMap       = JMap.getObj(optionsObj, optionKey) ; JMap&
        bool hasProperty    = JMap.hasKey(optionMap, "Default")

        if (!hasProperty)
            RPB_Utility.Error("There was an error loading the default value for option " + optionKey + ".")
            RPB_Utility.DebugError("MCM::LoadDefaults", "There was an error loading the default value for option " + optionKey + ".")
            continue = true
        endif

        if (!continue)
            bool hasDependency = JMap.valueType(optionMap, "Default") == 5 ; 5 = object type

            if (hasDependency)
                int defaultObject = JMap.getObj(optionMap, "Default")
                string dependencyOptionKey  = JArray.getStr(defaultObject, 0) ; [0] = Dependency Option
                float offset                = JArray.getFlt(defaultObject, 1) ; [1] = Option Offset
                bool hasOffset              = (offset as bool)
                float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)

                self.SetOptionDefaultFloat(optionKey, float_if (hasOffset, dependencyOptionValue + offset, dependencyOptionValue))

            else
                bool isFloat    = JMap.valueType(optionMap, "Default") == 3 ; 3 - float
                bool isInteger  = JMap.valueType(optionMap, "Default") == 2 ; 2 - int|bool
                bool isString   = JMap.valueType(optionMap, "Default") == 6 ; 6 - string
        
                if (isFloat)
                    float optionValue = JMap.getFlt(optionMap, "Default") ; int|float
                    self.SetOptionDefaultFloat(optionKey, optionValue)
                    RPB_Utility.DebugWithArgs("MCM::LoadDefaults", optionKey, "[float] Setting Default Value to: " + optionValue)
                
                elseif (isInteger)
                    int optionValue = JMap.getInt(optionMap, "Default") ; int|bool
                    self.SetOptionDefaultInt(optionKey, optionValue)
                    RPB_Utility.DebugWithArgs("MCM::LoadDefaults", optionKey, "[int] Setting Default Value to: " + optionValue)
        
                elseif (isString)
                    string optionValue = JMap.getStr(optionMap, "Default") ; string
                    self.SetOptionDefaultString(optionKey, optionValue)
                    RPB_Utility.DebugWithArgs("MCM::LoadDefaults", optionKey, "[string] Setting Default Value to: " + optionValue)
                endif
            endif
        endif


        continue = false
        optionIndex += 1
    endWhile
endFunction

; function LoadMaximumForOption(string optionKey)
;     ; Initialize Maximums
;     int maximumsObj     = RPB_Data.MCM_GetMaximumsObject()

;     bool isObject = JMap.valueType(maximumsObj, optionKey) == 5

;     if (isObject)
;         int optionValueObject       = JMap.getObj(maximumsObj, optionKey)
;         string dependsType          = JArray.getStr(optionValueObject, 0)
;         string dependsOption        = JArray.getStr(optionValueObject, 1)
;         float dependsOffset         = JArray.getFlt(optionValueObject, 2)
;         float dependsOptionValue    = self.GetOptionSliderValue(dependsOption) ; dependency option
;         self.SetOptionMaximum(optionKey, dependsOptionValue + dependsOffset) ; set the value based on the dependency option

;     else
;         float optionValue = JMap.getFlt(maximumsObj, optionKey)
;         self.SetOptionMaximum(optionKey, optionValue)
;     endif
; endFunction

function LoadMaximumForOption(string optionKey)
    int optionsObj       = RPB_Data.MCM_GetOptionObject()
    bool isValidOption   = JMap.valueType(optionsObj, optionKey) == 5 ; 5 = object type (All options are comprised of an object)

    if (!isValidOption)
        return
    endif

    string propertyType = "Maximum"

    int optionMap       = JMap.getObj(optionsObj, optionKey) ; JMap&
    bool hasProperty    = JMap.hasKey(optionMap, propertyType)

    if (!hasProperty)
        return
    endif

    bool hasDependency = JMap.valueType(optionMap, propertyType) == 5 ; 5 = object type

    if (hasDependency)
        ; Get dependency option key, get dependency option value, and get offset
        int maximumObject           = JMap.getObj(optionMap, propertyType) ; JArray
        string dependencyOptionKey  = JArray.getStr(maximumObject, 0) ; [0] = Dependency Option
        float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)
        float maximumOffset         = JArray.getFlt(maximumObject, 1) ; [1] = Option Offset
        bool hasOffset              = (maximumOffset as bool)
        float optionValue           = (float_if (hasOffset, dependencyOptionValue + maximumOffset, dependencyOptionValue))

        self.SetOptionMaximum(optionKey, optionValue)

        RPB_Utility.DebugWithArgs( \
            "MCM::LoadMaximumForOption", \ 
            optionKey, \ 
            "[Depends On "+ dependencyOptionKey + " (value: "+ (dependencyOptionValue as int) +")" + "] Setting Max Value to: " + optionValue \
        )
    else
        float optionValue = JMap.getFlt(optionMap, propertyType) ; int|float
        self.SetOptionMaximum(optionKey, optionValue)
        RPB_Utility.DebugWithArgs("MCM::LoadMaximumForOption", optionKey, "Setting Max Value to: " + optionValue)
    endif
endFunction

function LoadMinimumForOption(string optionKey)
    int optionsObj       = RPB_Data.MCM_GetOptionObject()
    bool isValidOption   = JMap.valueType(optionsObj, optionKey) == 5 ; 5 = object type (All options are comprised of an object)

    if (!isValidOption)
        return
    endif

    string propertyType = "Minimum"

    int optionMap       = JMap.getObj(optionsObj, optionKey) ; JMap&
    bool hasProperty    = JMap.hasKey(optionMap, propertyType)

    if (!hasProperty)
        return
    endif

    bool hasDependency = JMap.valueType(optionMap, propertyType) == 5 ; 5 = object type

    if (hasDependency)
        ; Get dependency option key, get dependency option value, and get offset
        int minimumObject           = JMap.getObj(optionMap, propertyType) ; JArray
        string dependencyOptionKey  = JArray.getStr(minimumObject, 0) ; [0] = Dependency Option
        float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)
        float minimumOffset         = JArray.getFlt(minimumObject, 1) ; [1] = Option Offset
        bool hasOffset              = (minimumOffset as bool)
        float optionValue           = (float_if (hasOffset, dependencyOptionValue + minimumOffset, dependencyOptionValue))

        self.SetOptionMinimum(optionKey, optionValue)

        RPB_Utility.DebugWithArgs( \
            "MCM::LoadMinimumForOption", \ 
            optionKey, \ 
            "[Depends On "+ dependencyOptionKey + " (value: "+ (dependencyOptionValue as int) +")" + "] Setting Min Value to: " + optionValue \
        )
    else
        float optionValue = JMap.getFlt(optionMap, propertyType) ; int|float
        self.SetOptionMinimum(optionKey, optionValue)
        RPB_Utility.DebugWithArgs("MCM::LoadMinimumForOption", optionKey, "Setting Min Value to: " + optionValue)
    endif
endFunction

function LoadDefaultForOption(string optionKey)
    int optionsObj       = RPB_Data.MCM_GetOptionObject()
    bool isValidOption   = JMap.valueType(optionsObj, optionKey) == 5 ; 5 = object type (All options are comprised of an object)

    if (!isValidOption)
        return
    endif

    string propertyType = "Default"

    int optionMap       = JMap.getObj(optionsObj, optionKey) ; JMap&
    bool hasProperty    = JMap.hasKey(optionMap, propertyType)

    if (!hasProperty)
        return
    endif

    bool hasDependency = JMap.valueType(optionMap, propertyType) == 5 ; 5 = object type

    if (hasDependency)
        ; Get dependency option key, get dependency option value, and get offset
        int propertyObject          = JMap.getObj(optionMap, propertyType) ; JArray
        string dependencyOptionKey  = JArray.getStr(propertyObject, 0) ; [0] = Dependency Option

        float offset        = JArray.getFlt(propertyObject, 1) ; [1] = Option Offset
        bool hasOffset      = (offset as bool)

        ; Float only since we have no way to check for a dependency option's type,
        ; and it wouldn't make sense to have a bool or string dependency, and float is implicitly cast to int
        ; if required.

        float optionValue = self.GetOptionSliderValue(dependencyOptionKey)
        self.SetOptionDefaultFloat(optionKey, float_if (hasOffset, optionValue + offset, optionValue))
        RPB_Utility.DebugWithArgs( \
            "MCM::LoadDefaultForOption", \ 
            optionKey, \ 
            "[Depends On "+ dependencyOptionKey + " (value: "+ (optionValue) +")" + "] Setting Default Value to: " + optionValue \
        )
    else
        bool isFloat    = JMap.valueType(optionMap, propertyType) == 3 ; 3 - float
        bool isInteger  = JMap.valueType(optionMap, propertyType) == 2 ; 2 - int|bool
        bool isString   = JMap.valueType(optionMap, propertyType) == 6 ; 6 - string

        if (isFloat)
            float optionValue = JMap.getFlt(optionMap, propertyType) ; int|float
            self.SetOptionDefaultFloat(optionKey, optionValue)
            RPB_Utility.DebugWithArgs("MCM::LoadDefaultForOption", optionKey, "[float] Setting Default Value to: " + optionValue)
        
        elseif (isInteger)
            int optionValue = JMap.getInt(optionMap, propertyType) ; int|bool
            self.SetOptionDefaultInt(optionKey, optionValue)
            RPB_Utility.DebugWithArgs("MCM::LoadDefaultForOption", optionKey, "[int] Setting Default Value to: " + optionValue)

        elseif (isString)
            string optionValue = JMap.getStr(optionMap, propertyType) ; string
            self.SetOptionDefaultString(optionKey, optionValue)
            RPB_Utility.DebugWithArgs("MCM::LoadDefaultForOption", optionKey, "[string] Setting Default Value to: " + optionValue)
        endif
    endif
endFunction

function LoadStepsForOption(string optionKey)
    int optionsObj       = RPB_Data.MCM_GetOptionObject()
    bool isValidOption   = JMap.valueType(optionsObj, optionKey) == 5 ; 5 = object type (All options are comprised of an object)

    if (!isValidOption)
        return
    endif

    ; Get Maximums
    int optionMap       = JMap.getObj(optionsObj, optionKey) ; JMap&
    bool hasProperty    = JMap.hasKey(optionMap, "Steps")

    if (!hasProperty)
        return
    endif

    float steps = JMap.getFlt(optionMap, "Steps")
    self.SetOptionSteps(optionKey, steps)
    RPB_Utility.DebugWithArgs( \
        "MCM::LoadStepsForOption", \ 
        optionKey, \ 
        "Setting Steps Value to: " + steps \
    )
endFunction

function LoadPropertyForOption(string asOptionKey, string asPropertyType)
    int optionsObj       = RPB_Data.MCM_GetOptionObject()
    bool isValidOption   = JMap.valueType(optionsObj, asOptionKey) == 5 ; 5 = object type (All options are comprised of an object)

    if (!isValidOption)
        return
    endif

    ; Get Maximums
    int optionMap       = JMap.getObj(optionsObj, asOptionKey) ; JMap&
    bool hasProperty    = JMap.hasKey(optionMap, asPropertyType)

    if (!hasProperty)
        return
    endif

    bool hasDependency = JMap.valueType(optionMap, asPropertyType) == 5 ; 5 = object type

    if (hasDependency)
        ; Get dependency option key, get dependency option value, and get offset
        int minimumObject           = JMap.getObj(optionMap, asPropertyType) ; JArray
        string dependencyOptionKey  = JArray.getStr(minimumObject, 0) ; [0] = Dependency Option
        float dependencyOptionValue = self.GetOptionSliderValue(dependencyOptionKey)
        float minimumOffset         = JArray.getFlt(minimumObject, 1) ; [1] = Option Offset
        bool hasOffset              = (minimumOffset as bool)
        float optionValue           = (float_if (hasOffset, dependencyOptionValue + minimumOffset, dependencyOptionValue))

        self.SetOptionMinimum(asOptionKey, optionValue)

        RPB_Utility.DebugWithArgs( \
            "MCM::LoadMinimumForOption", \ 
            asOptionKey, \ 
            "[Depends On "+ dependencyOptionKey + " (value: "+ (dependencyOptionValue as int) +")" + "] Setting Min Value to: " + optionValue \
        )
    else
        float optionValue = JMap.getFlt(optionMap, asPropertyType) ; int|float
        self.SetOptionMinimum(asOptionKey, optionValue)
        RPB_Utility.DebugWithArgs("MCM::LoadMinimumForOption", asOptionKey, "Setting Min Value to: " + optionValue)
    endif
endFunction

function EnsureOptionLessThan(string asOptionOneKey, string asOptionTwoKey)
    float optionOneValue = self.GetOptionSliderValue(asOptionOneKey)
    float optionTwoValue = self.GetOptionSliderValue(asOptionTwoKey)

    if (optionOneValue > optionTwoValue)
        self.SetOptionSliderValue(asOptionOneKey, optionTwoValue - 1)
    endif
endFunction

function EnsureOptionGreaterThan(string asOptionOneKey, string asOptionTwoKey)
    float optionOneValue = self.GetOptionSliderValue(asOptionOneKey)
    float optionTwoValue = self.GetOptionSliderValue(asOptionTwoKey)

    if (optionOneValue < optionTwoValue)
        self.SetOptionSliderValue(asOptionOneKey, optionTwoValue + 1)
    endif
endFunction

function EnsureOptionNotGreaterThan(string asOptionKey, float afValue, float afValueToSet = 0.0)
    float optionOneValue = self.GetOptionSliderValue(asOptionKey)

    if (optionOneValue > afValue)
        self.SetOptionSliderValue(asOptionKey, float_if (afValueToSet, afValueToSet, afValue - 1))
    endif
endFunction

function EnsureOptionNotLessThan(string asOptionKey, float afValue, float afValueToSet = 0.0)
    float optionOneValue = self.GetOptionSliderValue(asOptionKey)

    if (optionOneValue < afValue)
        self.SetOptionSliderValue(asOptionKey, float_if (afValueToSet, afValueToSet, afValue + 1))
    endif
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

    optionsMinimumValueMap  = JMap.object() ; Minimum values for options
    optionsMaximumValueMap  = JMap.object() ; Maximum values for options

    ; JValue.retain(optionsValueMap)
    ; JValue.retain(optionsStateMap)
    ; JValue.retain(optionsDefaultValueMap)
    ; JValue.retain(optionsFromKeyToIdMap)
    ; JValue.retain(optionsFromIdToKeyMap)
    JValue.retain(generalContainer)
    JValue.retain(optionsMaximumValueMap)
    JValue.retain(optionsMinimumValueMap)

    JMap.setObj(generalContainer, "options/value", optionsValueMap)
    JMap.setObj(generalContainer, "options/state", optionsStateMap)
    JMap.setObj(generalContainer, "options/default", optionsDefaultValueMap)
    JMap.setObj(generalContainer, "options/id/from-key-to-id", optionsFromKeyToIdMap)
    JMap.setObj(generalContainer, "options/id/from-id-to-key", optionsFromIdToKeyMap)
    JMap.setObj(generalContainer, "clothing/outfits", miscVars.GetHandle("clothing/outfits"))
endFunction

int optionsValueMap
int optionsStateMap
int optionsDefaultValueMap
int optionsMinimumValueMap
int optionsMaximumValueMap
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

function SetOptionMinimum(string optionKey, float value)
    RPB_StorageVars.SetFloatOnForm(optionKey, self, value, "MCM/Minimum")
endFunction

float function GetOptionMinimum(string optionKey)
    return RPB_StorageVars.GetFloatOnForm(optionKey, self, "MCM/Minimum")
endFunction

function SetOptionMaximum(string optionKey, float value)
    RPB_StorageVars.SetFloatOnForm(optionKey, self, value, "MCM/Maximum")
    JMap.setFlt(optionsMaximumValueMap, optionKey, value)
endFunction

float function GetOptionMaximum(string optionKey)
    return RPB_StorageVars.GetFloatOnForm(optionKey, self, "MCM/Maximum")
    return JMap.getFlt(optionsMaximumValueMap, optionKey)
endFunction

function SetOptionSteps(string optionKey, float value)
    RPB_StorageVars.SetFloatOnForm(optionKey, self, value, "MCM/Steps")
endFunction

float function GetOptionSteps(string optionKey)
    return RPB_StorageVars.GetFloatOnForm(optionKey, self, "MCM/Steps")
endFunction