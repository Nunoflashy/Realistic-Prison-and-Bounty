Scriptname RealisticPrisonAndBounty_MCM extends SKI_ConfigBase  

import RealisticPrisonAndBounty_Util

; ==============================================================================
; Constants
; ==============================================================================

bool property IS_DEBUG = true autoreadonly

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

; FormLists
; =======================================
FormList property Arrest_AdditionalBountyWhenDefeatedFlat auto
; =======================================

; General
; =======================================
int   property oid_general_normalTimeScale auto
int[] property oid_general_attackOnSightBounty auto
; =======================================

; Arrest
; =======================================
int[] property oid_arrest_minimumBounty auto
int[] property oid_arrest_guaranteedPayableBounty auto
int[] property oid_arrest_maximumPayableBounty auto
int[] property oid_arrest_additionalBountyWhenResistingPercent auto
int[] property oid_arrest_additionalBountyWhenResistingFlat auto
int[] property oid_arrest_additionalBountyWhenDefeatedPercent auto
int[] property oid_arrest_additionalBountyWhenDefeatedFlat auto
int[] property oid_arrest_allowCivilianCapture auto
int[] property oid_arrest_allowArrestTransfer auto
int[] property oid_arrest_allowUnconsciousArrest auto
int[] property oid_arrest_unequipHandBounty auto
int[] property oid_arrest_unequipHeadBounty auto
int[] property oid_arrest_unequipFootBounty auto
; =======================================

; Frisking
; =======================================
int[] property oid_frisking_allow auto
int[] property oid_frisking_minimumBounty auto
int[] property oid_frisking_guaranteedPayableBounty auto
int[] property oid_frisking_maximumPayableBounty auto
int[] property oid_frisking_maximumPayableBountyChance auto
int[] property oid_frisking_friskSearchThoroughness auto
int[] property oid_frisking_confiscateStolenItems auto
int[] property oid_frisking_stripSearchStolenItems auto
int[] property oid_frisking_stripSearchStolenItemsNumber auto

bool[] property oid_frisking_allow_state auto
bool[] property oid_frisking_stripSearchStolenItems_state auto
; =======================================

; Undressing
; =======================================
int[] property oid_undressing_allow auto
int[] property oid_undressing_minimumBounty auto
int[] property oid_undressing_whenDefeated auto
int[] property oid_undressing_atCell auto
int[] property oid_undressing_atChest auto
int[] property oid_undressing_forcedUndressingMinBounty auto
int[] property oid_undressing_forcedUndressingWhenDefeated auto
int[] property oid_undressing_stripSearchThoroughness auto
int[] property oid_undressing_allowWearingClothes auto
int[] property oid_undressing_redressBounty auto
int[] property oid_undressing_redressWhenDefeated auto
int[] property oid_undressing_redressAtCell auto
int[] property oid_undressing_redressAtChest auto

bool[] property undressing_allow_state auto
; =======================================

; Prison
; =======================================
int   property oid_prison_prisonTimeScale auto
int[] property oid_prison_bountyToDays auto
int[] property oid_prison_minimumSentenceDays auto
int[] property oid_prison_maximumSentenceDays auto
int[] property oid_prison_allowBountylessImprisonment auto
int[] property oid_prison_sentencePaysBounty auto
int[] property oid_prison_fastForward auto
int[] property oid_prison_dayToFastForwardFrom auto
int[] property oid_prison_handsBoundInPrison auto
int[] property oid_prison_handsBoundMinimumBounty auto
int[] property oid_prison_handsBoundRandomize auto
int[] property oid_prison_cellLockLevel auto

bool[] property oid_prison_allowBountylessImprisonment_checked auto
bool[] property oid_prison_sentencePaysBounty_checked auto

; =======================================

; Release
; =======================================
int[] property oid_release_giveItemsBackOnRelease auto
int[] property oid_release_redressOnRelease auto
int[] property oid_release_giveItemsBackOnReleaseMaxBounty auto
int[] property oid_release_giveItemsBackOnDefeat auto
; =======================================

; Escape
; =======================================
int[] property oid_escape_escapeBountyPercent auto
int[] property oid_escape_escapeBountyFlat auto
int[] property oid_escape_allowSurrender auto
int[] property oid_escape_friskUponCapture auto
int[] property oid_escape_undressUponCapture auto
; =======================================

; Bounty
; =======================================
int   property oid_bounty_enableBountyDecayGeneral auto
int   property oid_bounty_updateInterval auto
int[] property oid_bounty_currentBounty auto
int[] property oid_bounty_largestBounty auto
int[] property oid_bounty_enableBountyDecay auto
int[] property oid_bounty_decayInPrison auto
int[] property oid_bounty_bountyLostPercent auto
int[] property oid_bounty_bountyLostFlat auto
; =======================================

; Bounty Hunters
; =======================================
int[] property oid_bhunters_enableBountyHunters auto
int[] property oid_bhunters_allowOutlawBountyHunters auto
int[] property oid_bhunters_minimumBounty auto
int[] property oid_bhunters_bountyPosse auto
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
        Log(self, "MCM::GetHoldNames", "Allocated holds string[]", LOG_WARNING())
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
    Pages = new string[11]
    Pages[0] = RealisticPrisonAndBounty_MCM_General.GetPageName()
    Pages[1] = RealisticPrisonAndBounty_MCM_Arrest.GetPageName()
    Pages[2] = RealisticPrisonAndBounty_MCM_Frisking.GetPageName()
    Pages[3] = RealisticPrisonAndBounty_MCM_Undress.GetPageName()
    Pages[4] = RealisticPrisonAndBounty_MCM_Prison.GetPageName()
    Pages[5] = RealisticPrisonAndBounty_MCM_Release.GetPageName()
    Pages[6] = RealisticPrisonAndBounty_MCM_Escape.GetPageName()
    Pages[7] = RealisticPrisonAndBounty_MCM_Bounty.GetPageName()
    Pages[8] = RealisticPrisonAndBounty_MCM_BHunters.GetPageName()
    Pages[9] = RealisticPrisonAndBounty_MCM_Leveling.GetPageName()
    Pages[10] = RealisticPrisonAndBounty_MCM_Status.GetPageName()
endFunction

function SetDefaultTimescales()
    if (! NormalTimescale)
        NormalTimescale.SetValueInt(Game.GetGameSettingInt("TimeScale"))
        Log(self, "SetDefaultTimescales", "Timescale has been set = " + NormalTimescale.GetValueInt())
    endif
endFunction

function InitializeOptions()

; Timescale
; ============================================================

; ============================================================

; General
; ============================================================
    oid_general_attackOnSightBounty = new int[9]
; ============================================================

; Arrest
; ============================================================
    oid_arrest_minimumBounty = new int[9]
    oid_arrest_guaranteedPayableBounty = new int[9]
    oid_arrest_maximumPayableBounty = new int[9]
    oid_arrest_additionalBountyWhenResistingPercent = new int[9]
    oid_arrest_additionalBountyWhenResistingFlat = new int[9]
    oid_arrest_additionalBountyWhenDefeatedPercent = new int[9]
    oid_arrest_additionalBountyWhenDefeatedFlat = new int[9]
    oid_arrest_allowCivilianCapture = new int[9]
    oid_arrest_allowArrestTransfer = new int[9]
    oid_arrest_allowUnconsciousArrest = new int[9]
    oid_arrest_unequipHandBounty = new int[9]
    oid_arrest_unequipHeadBounty = new int[9]
    oid_arrest_unequipFootBounty = new int[9]
; ============================================================

; Frisking
; ============================================================
    oid_frisking_allow = new int[9]
    oid_frisking_minimumBounty = new int[9]
    oid_frisking_guaranteedPayableBounty = new int[9]
    oid_frisking_maximumPayableBounty = new int[9]
    oid_frisking_maximumPayableBountyChance = new int[9]
    oid_frisking_friskSearchThoroughness = new int[9]
    oid_frisking_confiscateStolenItems = new int[9]
    oid_frisking_stripSearchStolenItems = new int[9]
    oid_frisking_stripSearchStolenItemsNumber = new int[9]

    oid_frisking_allow_state = new bool[9]
    oid_frisking_stripSearchStolenItems_state = new bool[9]
; ============================================================

; Undressing
; ============================================================
    oid_undressing_allow = new int[9]
    oid_undressing_minimumBounty = new int[9]
    oid_undressing_whenDefeated = new int[9]
    oid_undressing_atCell = new int[9]
    oid_undressing_atChest = new int[9]
    oid_undressing_forcedUndressingMinBounty = new int[9]
    oid_undressing_forcedUndressingWhenDefeated = new int[9]
    oid_undressing_stripSearchThoroughness = new int[9]
    oid_undressing_allowWearingClothes = new int[9]
    oid_undressing_redressBounty = new int[9]
    oid_undressing_redressWhenDefeated = new int[9]
    oid_undressing_redressAtCell = new int[9]
    oid_undressing_redressAtChest = new int[9]

    undressing_allow_state = new bool[9]
; ============================================================

; Prison
; ============================================================
    oid_prison_bountyToDays = new int[9]
    oid_prison_minimumSentenceDays = new int[9]
    oid_prison_maximumSentenceDays = new int[9]
    oid_prison_allowBountylessImprisonment = new int[9]
    oid_prison_sentencePaysBounty = new int[9]
    oid_prison_fastForward = new int[9]
    oid_prison_dayToFastForwardFrom = new int[9]
    oid_prison_handsBoundInPrison = new int[9]
    oid_prison_handsBoundMinimumBounty = new int[9]
    oid_prison_handsBoundRandomize = new int[9]
    oid_prison_cellLockLevel = new int[9]

    oid_prison_allowBountylessImprisonment_checked = new bool[9]
    oid_prison_sentencePaysBounty_checked = new bool[9]
; ============================================================

; Release
; ============================================================
    oid_release_giveItemsBackOnRelease = new int[9]
    oid_release_redressOnRelease = new int[9]
    oid_release_giveItemsBackOnReleaseMaxBounty = new int[9]
    oid_release_giveItemsBackOnDefeat = new int[9]
; ============================================================

; Escape
; ============================================================
    oid_escape_escapeBountyPercent = new int[9]
    oid_escape_escapeBountyFlat = new int[9]
    oid_escape_allowSurrender = new int[9]
    oid_escape_friskUponCapture = new int[9]
    oid_escape_undressUponCapture = new int[9]
; ============================================================

; Bounty
; ============================================================
    oid_bounty_currentBounty = new int[9]
    oid_bounty_largestBounty = new int[9]
    oid_bounty_enableBountyDecay = new int[9]
    oid_bounty_decayInPrison = new int[9]
    oid_bounty_bountyLostPercent = new int[9]
    oid_bounty_bountyLostFlat = new int[9]
; ============================================================

; Bounty Hunters
; ============================================================
    oid_bhunters_enableBountyHunters = new int[9]
    oid_bhunters_allowOutlawBountyHunters = new int[9]
    oid_bhunters_minimumBounty = new int[9]
    oid_bhunters_bountyPosse = new int[9]
; ============================================================


endFunction


; IO Functions
; ============================================================

function LoadData()

endFunction

function SaveData()

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

function SetOptionToggleDefault(int optionId, bool value)
    if (GetOptionIntValue(optionId) == -1)
        SetOptionValueBool(optionId, value)
        SetToggleOptionValue(optionId, value)
    endif
endFunction

function SetOptionSliderDefault(int optionId, float value)
    if (GetOptionIntValue(optionId) == -1)
        SetOptionValueFloat(optionId, value)
        SetSliderOptionValue(optionId, value)
    endif
endFunction

function SetOptionMenuDefault(int optionId, string value)
    if (GetOptionIntValue(optionId) == -1)
        SetOptionValueString(optionId, value)
        SetMenuOptionValue(optionId, value)
    endif
endFunction

; ============================================================

;/
    Add a toggle option with the specified parameters,
    and assign its stored value to it

    returns the optionId passed
/;
int function AddToggleOptionWithValue(string text, int optionId, int flags = 0)
    AddToggleOption(text, GetOptionIntValue(optionId), flags)
    return optionId
endFunction

;/
    Add a slider option with the specified parameters,
    and assign its stored value to it

    returns the optionId passed
/;
int function AddSliderOptionWithValue(string text, int optionId, string format = "{0}", int flags = 0)
    AddSliderOption(text, GetOptionIntValue(optionId), format, flags)
    return optionId
endFunction

int function AtCurrent(int[] optionList)
    return optionList[CurrentOptionIndex]
endFunction

; ;/ 
;     Sets the enabled flag to an option based on its ID if it the dependency is met, disabled otherwise.
;     The option could be a toggle that depends on another toggle,
;     in which case, if the dependency toggle is not met, the option will not be enabled.

;     returns true if the option was enabled, false if the option was disabled.
; /;   
; bool function SetOptionDependencyBool(int optionId, bool dependency, bool storePersistently = true)
;     int enabled  = OPTION_FLAG_NONE
;     int disabled = OPTION_FLAG_DISABLED

;     SetOptionFlags(optionId, int_if (dependency, enabled, disabled))

    
;     if (dependency)
;         return true
;     endif

;     return false
; endFunction

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

    ; LogProperty(self, "SetOptionDependencyBool", "Value is " + "(" + _currentOptionIndex + ")", LOG_WARNING())

    SetOptionFlags(optionIdList[CurrentOptionIndex], int_if (dependency, enabled, disabled))


    if (dependency)
        return true
    endif

    return false
endFunction

bool function SetOptionDependencyBoolSingle(int optionId, bool dependency, bool storePersistently = true)
    int enabled  = OPTION_FLAG_NONE
    int disabled = OPTION_FLAG_DISABLED

    ; Log(self, "SetOptionDependencyBoolSingle", "Value is " + "(" + _currentOptionIndex + ")", LOG_WARNING())

    SetOptionFlags(optionId, int_if (dependency, enabled, disabled))
    ; Log(self, "SetOptionDependencyBoolSingle", "optionId " + "(" + _currentOptionIndex + ")", LOG_WARNING())


    if (dependency)
        return true
    endif

    return false
endFunction

; bool function SetDependencyBoolOnCurrentOption(int[] optionList, bool dependency, bool storePersistently = true)
;     SetOptionDependencyBool(optionList[CurrentOptionIndex], dependency, storePersistently)
; endFunction

int function GetCurrentOptionValue(int[] optionList)
    return GetOptionIntValue(optionList[CurrentOptionIndex])
endFunction

;/
    Toggles the specified option by id, optionally stores it persistently into the save

    returns the toggle state after it has been toggled.
/;
bool function ToggleOption(int optionId, bool storePersistently = true)
    bool optionState = GetOptionIntValue(optionId)
    
    ; Set the toggle option value (display checked or unchecked)
    ; If the option was checked, uncheck it and vice versa.
    SetToggleOptionValue(optionId, bool_if (optionState, false, true))

    ; string _key = GetKeyFromOption(optionId)

    ; Store the value persistently
    if (storePersistently)
        SetOptionValueBool(optionId, bool_if (optionState, false, true))
    endif

    ; Return the inverse since that's what we stored it as when we toggled.
    return ! optionState
endFunction

int _currentOptionIndex
int property CurrentOptionIndex
    int function get()
        if (_currentOptionIndex < 0)
            LogProperty(self, "CurrentOptionIndex", "Value is undefined " + "(" + _currentOptionIndex + ")", LOG_ERROR())
        endif

        return _currentOptionIndex
    endFunction
endProperty

int function GetOptionInListByOID(int[] optionList, int optionId)
    int i = 0
    while (i < GetHoldCount())
        if (optionList[i] == optionId)
            _currentOptionIndex = i
            return optionId
        endif
        i += 1
    endWhile

    return -1
endFunction

int function GetOptionInListByID(int[] optionList, int optionId)
    int i = 0
    while (i < optionList.Length)
        if (optionList[i] == optionId)
            _currentOptionIndex = i
            return optionId
        endif
        i += 1
    endWhile

    return -1
endFunction

int function GetCurrentHoldOption(int[] optionList)
    return optionList[CurrentOptionIndex]
endFunction

event OnConfigInit()
    ModName = "Realistic Prison and Bounty"
    InitializePages()
    InitializeOptions()
endEvent

; Event Handling
; ============================================================================
event OnPageReset(string page)
    RealisticPrisonAndBounty_MCM_General.Render(self)
    RealisticPrisonAndBounty_MCM_Arrest.Render(self)
    RealisticPrisonAndBounty_MCM_Frisking.Render(self)
    RealisticPrisonAndBounty_MCM_Undress.Render(self)
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
    RealisticPrisonAndBounty_MCM_Prison.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnSelect(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnSelect(self, option)
    ; RealisticPrisonAndBounty_MCM_Status.OnDefault(self, option)
endEvent



event OnOptionSliderOpen(int option)
    RealisticPrisonAndBounty_MCM_General.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Arrest.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Frisking.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Undress.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Prison.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnSliderOpen(self, option)
    RealisticPrisonAndBounty_MCM_Status.OnSliderOpen(self, option)
endEvent

event OnOptionSliderAccept(int option, float value)
    RealisticPrisonAndBounty_MCM_General.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Arrest.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Frisking.OnSliderAccept(self, option, value)
    RealisticPrisonAndBounty_MCM_Undress.OnSliderAccept(self, option, value)
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
    RealisticPrisonAndBounty_MCM_Prison.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Release.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Escape.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Bounty.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_BHunters.OnMenuOpen(self, option)
    RealisticPrisonAndBounty_MCM_Leveling.OnMenuOpen(self, option)
    ; RealisticPrisonAndBounty_MCM_Status.OnMenuOpen(self, option)
endEvent

event OnOptionMenuAccept(int option, int index)
    RealisticPrisonAndBounty_MCM_General.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Arrest.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Frisking.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Undress.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Prison.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Release.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Escape.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Bounty.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_BHunters.OnMenuAccept(self, option, index)
    RealisticPrisonAndBounty_MCM_Leveling.OnMenuAccept(self, option, index)
    ; RealisticPrisonAndBounty_MCM_Status.OnMenuOpen(self, option)
endEvent

; ============================================================================