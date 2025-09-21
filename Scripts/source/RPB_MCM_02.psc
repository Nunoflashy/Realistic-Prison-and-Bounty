Scriptname RPB_MCM_02 extends SKI_ConfigBase  

import RPB_Utility
import RPB_Memory

; ==========================================================
;                         Constants
; ==========================================================

bool property IS_DEBUG      = false autoreadonly
bool property ENABLE_TRACE  = false autoreadonly

; MCM Option Flags
int property OPTION_ENABLED  = 0x00 autoreadonly
int property OPTION_DISABLED = 0x01 autoreadonly

; MCM Page Names
string property MCM_PAGE_CHECK_ARRESTEE_INFO = "Check Arrestee" autoreadonly
string property MCM_PAGE_CHECK_PRISONER_INFO = "Check Prisoner" autoreadonly
string property MCM_PAGE_CHECK_HOLD_INFO_FOR_ACTOR = "Check Hold Info for Actor" autoreadonly

; ==========================================================
;                     Script References
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

; ==========================================================

string[] property Holds
    string[] function get()
        return API.Config.Holds
    endFunction
endProperty

string[] property HoldStatsTemplate
    string[] function get()
        return RPB_Data.MCM_GetChildPropertyOfTypeStringArray("Stats", "Hold", "Hold Stats")
    endFunction
endProperty

string[] property HoldStatsPlaceholders
    string[] function get()
        return String_Explode( \ 
            "bounty," + \
            "violent bounty," + \
            "[bounty+violent bounty]," + \
            "largest bounty," + \
            "total bounty," + \
            "times arrested," + \
            "times frisked," + \
            "arrests eluded," + \
            "arrests resisted," + \
            "bounties paid" \
        )
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
    return String_Explode( \ 
        aiBounty + "," + \
        aiViolentBounty + "," + \
        (aiBounty + aiViolentBounty) + "," + \
        aiLargestBounty + "," + \
        aiTotalBounty + "," + \
        aiTimesArrested + "," + \
        aiTimesFrisked + "," + \
        aiArrestsEluded + "," + \
        aiArrestsResisted + "," + \
        aiBountiesPaid \
    )
endFunction

string property ArrestHeaderTemplate
    string function get()
        return RPB_Data.MCM_GetArrestTemplate()
    endFunction
endProperty

string[] property ArrestHeaderPlaceholders
    string[] function get()
        return String_Explode( \ 
            "hold," + \
            "city," + \
            "potential prison," + \
            "arrestee" \
        )
    endFunction
endProperty

string[] function ConstructArrestHeaderValues( \ 
    string asArrestHold, \
    string asArrestCity, \
    string asPotentialPrisonName, \
    string asArresteeName \
)
    return String_Explode( \ 
        asArrestHold + "," + \
        asArrestCity + "," + \
        asPotentialPrisonName + "," + \
        asArresteeName \
    )
endFunction

string property PrisonHeaderTemplate
    string function get()
        return RPB_Data.MCM_GetPrisonTemplate()
    endFunction
endProperty

string[] property PrisonHeaderPlaceholders
    string[] function get()
        return String_Explode( \ 
            "hold," + \
            "city," + \
            "prison," + \
            "cell," + \
            "prisoner" \
        )
    endFunction
endProperty

string[] function ConstructPrisonHeaderValues( \ 
    string asPrisonHold, \
    string asPrisonCity, \
    string asPrisonName, \
    string asPrisonCell, \
    string asPrisonerName \
)
    return String_Explode( \ 
        asPrisonHold + "," + \
        asPrisonCity + "," + \
        asPrisonName + "," + \
        asPrisonCell + "," + \
        asPrisonerName \
    )
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
    string PAGE_SEPARATOR = " ,"
    Pages = String_Explode( \ 
        String_Implode(Holds) + "," + \
        string_if (API.Arrest.Arrestees.Count > 0 || API.PrisonManager.HasPrisonsWithPrisoners, PAGE_SEPARATOR) + \
        string_if (API.Arrest.Arrestees.Count > 0, MCM_PAGE_CHECK_ARRESTEE_INFO + ",")+ \
        string_if (API.PrisonManager.HasPrisonsWithPrisoners, MCM_PAGE_CHECK_PRISONER_INFO + ",")+ \
        string_if (API.PrisonManager.HasPrisonsWithPrisoners, MCM_PAGE_CHECK_HOLD_INFO_FOR_ACTOR) \
    )
endFunction

int property PLAYER_INFO_NONE     = 0 autoreadonly
int property PLAYER_INFO_ARRESTED = 1 autoreadonly
int property PLAYER_INFO_PRISONER = 2 autoreadonly

int function GetPlayerArrestStatus()
    Actor player = Game.GetForm(0x14) as Actor

    bool isImprisoned = RPB_StorageVars.GetBoolOnReference("Imprisoned", player, "Jail")
    if (isImprisoned)
        return PLAYER_INFO_PRISONER
    endif

    bool isArrested = RPB_StorageVars.GetBoolOnReference("Arrested", player, "Arrest")
    if (isArrested)
        return PLAYER_INFO_ARRESTED
    endif

    return PLAYER_INFO_NONE
endFunction

function RenderDefaultPage()
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
endFunction

function RenderSelectedActorHoldInfo()
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
endFunction

function RenderSelectedArresteeInfo()
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
endFunction

function RenderSelectedPrisonerInfo()
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
endFunction



; ============================================================================
; Event Handling
; ============================================================================
event OnConfigInit()
    ModName = RPB_Data.MCM_GetRootPropertyOfTypeString("Stats", "Name")

    self.InitializePages()
endEvent

event OnConfigOpen()
    Debug("PrisonManager::InitializePages", "Holds: " + Holds)

    self.InitializePages()
endEvent

event OnPageReset(string page)
    if (page == "")
        self.RenderDefaultPage()
        return

    elseif (page == MCM_PAGE_CHECK_ARRESTEE_INFO)
        self.RenderSelectedArresteeInfo()
        return

    elseif (page == MCM_PAGE_CHECK_PRISONER_INFO)
        RPB_Utility.Debug("MCM_02::OnPageReset", "Page: " + page + " - Check Prisoner")
        self.RenderSelectedPrisonerInfo()
        return

    elseif (page == MCM_PAGE_CHECK_HOLD_INFO_FOR_ACTOR)
        self.RenderSelectedActorHoldInfo()
        return
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

; ==========================================================
;                         private
; ==========================================================

string _currentRenderedCategory