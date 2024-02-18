Scriptname RPB_MCM_02 extends SKI_ConfigBase  

import RPB_Utility

; ==============================================================================
; Constants
; ==============================================================================

bool property IS_DEBUG      = false autoreadonly
bool property ENABLE_TRACE  = false autoreadonly

; ==============================================================================
; MCM Option Flags
int property OPTION_ENABLED  = 0x00 autoreadonly
int property OPTION_DISABLED = 0x01 autoreadonly
; ==============================================================================


RPB_PrisonManager __prisonManager
RPB_PrisonManager property PrisonManager
    RPB_PrisonManager function get()
        if (__prisonManager)
            return __prisonManager
        endif

        __prisonManager = RPB_API.GetPrisonManager()
        return __prisonManager
    endFunction
endProperty

string[] property Holds
    string[] function get()
        int cellsMap = RPB_Data.Unserialize()
        string[] _holds = JMap.allKeysPArray(cellsMap)
        return _holds
    endFunction
endProperty

bool function IsHoldCurrentPage()
    int i = 0
    while (i < Holds.Length)
        if (CurrentPage == Holds[i])
            return true
        endif
        i += 1
    endWhile
    return false
endFunction

function InitializePages()
    int _pagesArray = JArray.object()

    int i = 0
    while (i < Holds.Length)
        JArray.addStr(_pagesArray, Holds[i])
        i += 1
    endWhile

    JArray.addStr(_pagesArray, "")

    RPB_Prison actorPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    string prisonName = actorPrison.Name
    int n = 0
    while (n < actorPrison.Prisoners.Count)
        RPB_Prisoner prisoner = actorPrison.Prisoners.AtIndex(n)
        int prisonerFormID  = actorPrison.Prisoners.AtIndex(n).GetActor().GetFormID()
        RPB_Utility.Debug("MCM_02::InitializePages", "prisoner: " + prisoner)
        JArray.addStr(_pagesArray, "Prison - " + prisoner.Name + " (#"+ prisoner.Number +")")
        n += 1
    endWhile

    ; JArray.addStr(_pagesArray, "Prison - Quorya")

    Pages = JArray.asStringArray(_pagesArray)
endFunction

; ============================================================================
; Event Handling
; ============================================================================
event OnConfigInit()
    ; ModName = "R. Prison and Bounty - Stats"
    ; ModName = "Realistic Prison & B. - Stats"
    ; ModName = "Realistic Prison & B. - Stats"
    ; ModName = "RealisticPrison&Bounty - Stats"
    ModName = "RPB - Stats"

    self.InitializePages()
endEvent

event OnConfigOpen()
    self.InitializePages()
endEvent

event OnPageReset(string page)
    RPB_MCM_02_Holds.Render(self)

    RPB_Prison actorPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    int n = 0
    while (n < actorPrison.Prisoners.Count)
        RPB_Prisoner prisoner = actorPrison.Prisoners.AtIndex(n)
        string prisonerName = actorPrison.Prisoners.AtIndex(n).Name
        int prisonerFormID = actorPrison.Prisoners.AtIndex(n).GetActor().GetFormID()
        RPB_Utility.Debug("MCM_02::OnPageReset", "prisoner: " + prisoner)
        RPB_Utility.Debug("MCM_02::OnPageReset", "prisonerName: " + prisoner.Name)
        RPB_Utility.Debug("MCM_02::OnPageReset", "Prisoner Number: " + prisoner.Number)
        RPB_MCM_02_Prison.Render(self, prisoner)
        n += 1
    endWhile

    RPB_Utility.Debug("MCM_02::OnPageReset", "Page: " + page, true)
    RPB_Utility.Debug("MCM_02::OnPageReset", "self.CurrentPage: " + self.CurrentPage, true)
endEvent

event OnOptionHighlight(int option)
endEvent

event OnOptionDefault(int option)
endEvent

event OnOptionSelect(int option)
endEvent

event OnOptionSliderOpen(int option)
endEvent

event OnOptionSliderAccept(int option, float value)
endEvent

event OnOptionMenuOpen(int option)
endEvent

event OnOptionMenuAccept(int option, int index)
endEvent

event OnOptionInputOpen(int option)
endEvent

event OnOptionInputAccept(int option, string inputValue)
endEvent


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
endFunction

int function AddOptionText(string text, string defaultValueOverride = "", int defaultFlags = 0)
    return AddTextOption(text, defaultValueOverride, defaultFlags)
endFunction

;/
    Adds and renders a Stat Option with the possibility of specifying a Key for its storage.

    string      @displayedText: The text that will be displayed in the menu.
    string      @_key: The key to be used to set values to and from storage.

    returns:    The Option's ID.
/;
int function AddOptionStatKey(string displayedText, string _key, int defaultValueOverride = -1, string formatString = "{0}", int defaultFlags = 0)
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
endFunction

;/
    Sets a menu option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
/;
function SetOptionMenuValue(string option, string value)
endFunction

;/
    Sets an input option's value.

    string      @option: The name of the option to be changed.
    string      @value: The new value for the option.
/;
function SetOptionInputValue(string option, string value)
endFunction

string _currentRenderedCategory