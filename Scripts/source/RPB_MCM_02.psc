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

string[] property HoldStatsTemplate
    string[] function get()
        return RPB_Data.MCM_GetChildPropertyOfTypeStringArray("Stats", "Hold", "Hold Stats")
    endFunction
endProperty

string[] property HoldStatsPlaceholders
    string[] function get()
        int placeholders = JArray.object()
        JArray.addStr(placeholders, "bounty")
        JArray.addStr(placeholders, "violent bounty")
        JArray.addStr(placeholders, "[bounty+violent bounty]")
        JArray.addStr(placeholders, "largest bounty")
        JArray.addStr(placeholders, "total bounty")
        JArray.addStr(placeholders, "times arrested")
        JArray.addStr(placeholders, "times frisked")
        JArray.addStr(placeholders, "arrests eluded")
        JArray.addStr(placeholders, "arrests resisted")
        JArray.addStr(placeholders, "bounties paid")

        return JArray.asStringArray(placeholders)
    endFunction
endProperty

string[] function ConstructHoldStatValues( \
int aiBounty, \
int aiViolentBounty,  \
int aiLargestBounty,  \
int aiTotalBounty,  \
int aiTimesArrested,  \
int aiTimesFrisked,  \
int aiArrestsEluded,  \
int aiArrestsResisted, \ 
int aiBountiesPaid \
)
    int values = JArray.object()
    JArray.addStr(values, aiBounty as string)
    JArray.addStr(values, aiViolentBounty as string)
    JArray.addStr(values, (aiBounty + aiViolentBounty) as string)
    JArray.addStr(values, aiLargestBounty as string)
    JArray.addStr(values, aiTotalBounty as string)
    JArray.addStr(values, aiTimesArrested as string)
    JArray.addStr(values, aiTimesFrisked as string)
    JArray.addStr(values, aiArrestsEluded as string)
    JArray.addStr(values, aiArrestsResisted as string)
    JArray.addStr(values, aiBountiesPaid as string)

    return JArray.asStringArray(values)
endFunction

string property ArrestHeaderTemplate
    string function get()
        return RPB_Data.MCM_GetArrestTemplate()
    endFunction
endProperty

string[] property ArrestHeaderPlaceholders
    string[] function get()
        int placeholders = JArray.object()
        JArray.addStr(placeholders, "hold")
        JArray.addStr(placeholders, "city")
        JArray.addStr(placeholders, "potential prison")
        JArray.addStr(placeholders, "arrestee")

        return JArray.asStringArray(placeholders)
    endFunction
endProperty

string[] function ConstructArrestHeaderValues( \ 
    string asArrestHold, \
    string asArrestCity, \
    string asPotentialPrisonName, \
    string asArresteeName \
)
    int values = JArray.object()
    JArray.addStr(values, asArrestHold)
    JArray.addStr(values, asArrestCity)
    JArray.addStr(values, asPotentialPrisonName)
    JArray.addStr(values, asArresteeName)
    return JArray.asStringArray(values)
endFunction

string property PrisonHeaderTemplate
    string function get()
        return RPB_Data.MCM_GetPrisonTemplate()
    endFunction
endProperty

string[] property PrisonHeaderPlaceholders
    string[] function get()
        int placeholders = JArray.object()
        JArray.addStr(placeholders, "hold")
        JArray.addStr(placeholders, "city")
        JArray.addStr(placeholders, "prison")
        JArray.addStr(placeholders, "cell")
        JArray.addStr(placeholders, "prisoner")

        return JArray.asStringArray(placeholders)
    endFunction
endProperty

string[] function ConstructPrisonHeaderValues( \ 
    string asPrisonHold, \
    string asPrisonCity, \
    string asPrisonName, \
    string asPrisonCell, \
    string asPrisonerName \
)
    int values = JArray.object()
    JArray.addStr(values, asPrisonHold)
    JArray.addStr(values, asPrisonCity)
    JArray.addStr(values, asPrisonName)
    JArray.addStr(values, asPrisonCell)
    JArray.addStr(values, asPrisonerName)
    return JArray.asStringArray(values)
endFunction

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
    if (API.Arrest.Arrestees.Count > 0)
        JArray.addStr(_pagesArray, "Check Arrestee")
    endif

    JArray.addStr(_pagesArray, "Check Prisoner")
    JArray.addStr(_pagesArray, "Check Hold Info for Prisoner")

    Pages = JArray.asStringArray(_pagesArray)
endFunction

int property PLAYER_INFO_NONE     = 0 autoreadonly
int property PLAYER_INFO_ARRESTED = 1 autoreadonly
int property PLAYER_INFO_PRISONER = 2 autoreadonly

int function GetPlayerArrestStatus()
    Actor player = Game.GetForm(0x14) as Actor

    bool isImprisoned = RPB_StorageVars.GetBoolOnForm("Imprisoned", player, "Jail")
    if (isImprisoned)
        return PLAYER_INFO_PRISONER
    endif

    bool isArrested = RPB_StorageVars.GetBoolOnForm("Arrested", player, "Arrest")
    if (isArrested)
        return PLAYER_INFO_ARRESTED
    endif

    return PLAYER_INFO_NONE
endFunction

; ============================================================================
; Event Handling
; ============================================================================
event OnConfigInit()
    ModName = RPB_Data.MCM_GetRootPropertyOfTypeString("Stats", "Name")

    self.InitializePages()
endEvent

event OnConfigOpen()
    self.InitializePages()
endEvent

event OnPageReset(string page)
    if (page == "")
        int playerArrestStatus = self.GetPlayerArrestStatus()
        Actor player = Game.GetForm(0x14) as Actor

        if (playerArrestStatus == PLAYER_INFO_PRISONER)
            RPB_Prison playerPrison = PrisonManager.FindPrisonByPrisoner(player)
            if (playerPrison == none)
                return ; No Prison
            endif
    
            RPB_Prisoner playerPrisoner = playerPrison.GetPrisonerReference(player)
            if (playerPrisoner == none)
                return ; No Prisoner
            endif

            RPB_MCM_02_Prison.Render(self, playerPrisoner)

        elseif (playerArrestStatus == PLAYER_INFO_ARRESTED)
            RPB_Arrestee playerArresteeRef = API.Arrest.AwaitArresteeReference(player)
            RPB_MCM_02_Prison.RenderArrest(self, playerArresteeRef)
        endif

    elseif (page == "Check Arrestee")
        RPB_UIInterface uilib = (Game.GetForm(0x14) as Form) as RPB_UIInterface
        string selectedHold = uilib.ShowHoldList(abMustHaveArrestees = true, abSkipListOnSingleResult = true, asListTitle = "Select Arrest Hold")

        if (!selectedHold)
            return
        endif

        RPB_Arrestee selectedArrestee = uilib.ShowArresteeList(selectedHold, asListTitle = "Select Arrestee for " + selectedHold)
        if (selectedArrestee == none)
            return
        endif

        RPB_MCM_02_Prison.RenderArrest(self, selectedArrestee)
        return

    elseif (page == "Check Prisoner")
        RPB_Utility.Debug("MCM_02::OnPageReset", "Page: " + page + " - Check Prisoner")
        RPB_UIInterface uilib = (Game.GetForm(0x14) as Form) as RPB_UIInterface

        RPB_Prison selectedPrison = uilib.ShowPrisonList(abSkipListOnSingleResult = true)
        if (selectedPrison == none)
            return
        endif

        RPB_Prisoner selectedPrisoner = uilib.ShowPrisonerList(selectedPrison, true, "Select Prisoner in " + selectedPrison.Name)
        if (selectedPrisoner == none)
            return
        endif

        RPB_MCM_02_Prison.Render(self, selectedPrisoner)
        return

    elseif (page == "Check Hold Info for Prisoner")
        RPB_UIInterface uilib = (Game.GetForm(0x14) as Form) as RPB_UIInterface

        RPB_Prison selectedPrison = uilib.ShowPrisonList(abSkipListOnSingleResult = true)
        if (selectedPrison == none)
            return
        endif

        RPB_Prisoner selectedPrisoner = uilib.ShowPrisonerList(selectedPrison, true, "Select Prisoner in " + selectedPrison.Name)
        if (selectedPrisoner == none)
            return
        endif

        RPB_MCM_02_Holds.NPC_RenderPrisons(self, selectedPrisoner)
    endif

    RPB_MCM_02_Holds.Render(self)
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