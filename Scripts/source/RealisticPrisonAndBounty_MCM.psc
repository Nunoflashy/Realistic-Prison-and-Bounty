Scriptname RealisticPrisonAndBounty_MCM extends SKI_ConfigBase  

import RealisticPrisonAndBounty_Util

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

GlobalVariable property Arrest_MinimumBounty_Whiterun auto
GlobalVariable property Arrest_MinimumBounty_Winterhold auto
GlobalVariable property Arrest_MinimumBounty_Eastmarch auto
GlobalVariable property Arrest_MinimumBounty_Falkreath auto
GlobalVariable property Arrest_MinimumBounty_Haafingar auto
GlobalVariable property Arrest_MinimumBounty_Hjaalmarch auto
GlobalVariable property Arrest_MinimumBounty_TheRift auto
GlobalVariable property Arrest_MinimumBounty_TheReach auto
GlobalVariable property Arrest_MinimumBounty_ThePale auto
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

; int property oid_frisking_allow auto
; int property oid_frisking_minimumBounty auto
; int property oid_frisking_guaranteedPayableBounty auto
; int property oid_frisking_maximumPayableBounty auto
; int property oid_frisking_maximumPayableBountyChance auto
; int property oid_frisking_friskSearchThoroughness auto
; int property oid_frisking_confiscateStolenItems auto
; int property oid_frisking_stripSearchStolenItems auto
; int property oid_frisking_stripSearchStolenItemsNumber auto

int property oid_frisking_stripSearchStolenItems_Value auto

GlobalVariable property Frisking_MinimumBounty_Whiterun auto
GlobalVariable property Frisking_MinimumBounty_Winterhold auto
GlobalVariable property Frisking_MinimumBounty_Eastmarch auto
GlobalVariable property Frisking_MinimumBounty_Falkreath auto
GlobalVariable property Frisking_MinimumBounty_Haafingar auto
GlobalVariable property Frisking_MinimumBounty_Hjaalmarch auto
GlobalVariable property Frisking_MinimumBounty_TheRift auto
GlobalVariable property Frisking_MinimumBounty_TheReach auto
GlobalVariable property Frisking_MinimumBounty_ThePale auto
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

int function GetLeftIndex()
    return 0
endFunction

; {Returns the index of the hold where the right panel starts}
int function GetRightIndex()
    return 5
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

int map


; bool function SetToggleState(int oid, int checked)
;     if (! map)
;         map = JMap.object()
;     endif

;     JMap.setInt(map, "prison_" + oid, oid_prison_sentencePaysBounty)
; endFunction

; bool function GetToggleState(int oid)
;     int data = JMap.getInt(map, "prison_" + oid)
;     return 
; endFunction

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
    ; NormalTimescale = Game.GetFormFromFile(0x2851, "RealisticPrisonAndBounty.esp") as GlobalVariable
    ; PrisonTimescale = Game.GetFormFromFile(0x2850, "RealisticPrisonAndBounty.esp") as GlobalVariable

    ; SetDefaultTimescales()
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

    ; oid_frisking_allow                          = JIntMap.object()
    ; oid_frisking_minimumBounty                  = JIntMap.object()
    ; oid_frisking_guaranteedPayableBounty        = JIntMap.object()
    ; oid_frisking_maximumPayableBounty           = JIntMap.object()
    ; oid_frisking_maximumPayableBountyChance     = JIntMap.object()
    ; oid_frisking_friskSearchThoroughness        = JIntMap.object()
    ; oid_frisking_confiscateStolenItems          = JIntMap.object()
    ; oid_frisking_stripSearchStolenItems         = JIntMap.object()
    ; oid_frisking_stripSearchStolenItemsNumber   = JIntMap.object()

    ; JValue.retain(oid_frisking_allow)
    ; JValue.retain(oid_frisking_minimumBounty)
    ; JValue.retain(oid_frisking_guaranteedPayableBounty)
    ; JValue.retain(oid_frisking_maximumPayableBounty)
    ; JValue.retain(oid_frisking_maximumPayableBountyChance)
    ; JValue.retain(oid_frisking_friskSearchThoroughness)
    ; JValue.retain(oid_frisking_confiscateStolenItems)
    ; JValue.retain(oid_frisking_stripSearchStolenItems)
    ; JValue.retain(oid_frisking_stripSearchStolenItemsNumber)

    oid_frisking_allow_state = new bool[9]
    oid_frisking_stripSearchStolenItems_state = new bool[9]
    oid_frisking_stripSearchStolenItems_Value = JIntMap.object()
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

; ============================================================

int property list_frisking_minimumBounty auto
int property map_frisking auto
int property whiterun_options auto

bool function SetOptionAtIndex(int index, string category, string option, int value)
    string[] holds = GetHoldNames()
    return JDB.solveIntSetter("." + holds[index] + "." + category + "." + option, value, true)
endFunction

string property StoragePrefix
    string function get()
        return ".__REALISTIC_PRISON_AND_BOUNTY__."
    endFunction
endProperty

bool function SetOptionOID(int oid, int value)
    return JDB.solveIntSetter(StoragePrefix + "OPTION_ID." + oid, value, true)
endFunction

bool function SetOptionStringValue(int oid, string value)
    return JDB.solveStrSetter(StoragePrefix + "OPTION_ID." + oid, value, true)
endFunction

bool function SetOptionIntValue(int oid, int value)
    return JDB.solveIntSetter(StoragePrefix + "OPTION_ID." + oid, value, true)
endFunction

bool function SetOptionBoolValue(int oid, bool value)
    return JDB.solveIntSetter(StoragePrefix + "OPTION_ID." + oid, value as int, true)
endFunction

int function GetOptionOID(int oid)
    return JDB.solveInt(StoragePrefix + "OPTION_ID." + oid)
endFunction

int function GetOptionAtIndex(int index, string category, string option)
    string[] holds = GetHoldNames()

    return JDB.solveInt("." + holds[index] + "." + category + "." + option)
endFunction

; Returns the OptionID of the object at list[index]
int function GetOptionValue(int list, int index)
    return JIntMap.getInt(list, index)
endFunction

; Sets the OptionID to list[index]
function SetOptionValue(int list, int index, int value)
    JIntMap.setInt(list, index, value)
endFunction

event OnConfigInit()
    ModName = "Realistic Prison and Bounty"
    InitializePages()
    InitializeOptions()

    map_frisking = JMap.object()
    JValue.retain(map_frisking)

    ; JMap.setInt(map_frisking, "minimumBounty", 500)
    ; JMap.setInt(map_frisking, "guaranteedPayableBounty", 1000)
    ; JMap.setInt(map_frisking, "maximumPayableBounty", 2000)
    list_frisking_minimumBounty = JArray.object()
    whiterun_options = JMap.object()

    int x = 0
    int DEFAULT_MINIMUM_BOUNTY = 1000
    while (x < 9)
        JArray.addInt(list_frisking_minimumBounty, DEFAULT_MINIMUM_BOUNTY)
        x += 1
    endWhile

    ; int i = 0
    ; while (i < 9)
    ;     JMap.setObj(map_frisking, "minimumBounty", list_frisking_minimumBounty)
    ;     JMap.setInt(map_frisking, "minimumBounty", 500)
    ;     JMap.setInt(map_frisking, "guaranteedPayableBounty", 1000)
    ;     JMap.setInt(map_frisking, "maximumPayableBounty", 2000)
    ;     i += 1
    ; endWhile

    JDB.solveIntSetter(".whiterun.frisking.minimumBounty", 1000, true)
    JDB.solveIntSetter(".winterhold.frisking.minimumBounty", 782, true)

    SetOptionAtIndex(0, "frisking", "minimumBounty", 1784)
    SetOptionAtIndex(1, "frisking", "minimumBounty", 2502)

    ; list_oid_frisking_allow = JIntMap.object()
    ; JValue.retain(list_oid_frisking_allow, "RPB")

    ; int whiterunMinimumBounty = JDB.solveInt(".whiterun.frisking.minimumBounty")
    ; int winterholdMinimumBounty = JDB.solveInt(".winterhold.frisking.minimumBounty")
    ; int whiterunMinimumBounty = GetOptionAtIndex(0, "frisking", "minimumBounty")
    ; int winterholdMinimumBounty = GetOptionAtIndex(1, "frisking", "minimumBounty")

    ; Log(self, "This", "whiterunMinimumBounty = " + whiterunMinimumBounty)
    ; Log(self, "This", "winterholdMinimumBounty = " + winterholdMinimumBounty)



    ; int minBounty = JMap.getInt(map_frisking, "minimumBounty")
    ; int guaranteedPayableBounty = JMap.getInt(map_frisking, "guaranteedPayableBounty")
    ; int maximumPayableBounty = JMap.getInt(map_frisking, "maximumPayableBounty")

    JValue.writeToFile(map_frisking, "jmap.txt")
    
    ; Log(self, "OnConfigInit", "minBounty = " + minBounty + "\n" + "guaranteedPayableBounty = " + guaranteedPayableBounty + "\n" + "maximumPayableBounty = " + maximumPayableBounty)

    ; list_frisking_minimumBounty = JArray.object()
    ; JValue.retain(list_frisking_minimumBounty, "RealisticPrisonAndBounty")

    ; int i = 0
    ; ; _holds = GetHoldNames()
    ; int DEFAULT_MINIMUM_BOUNTY = 1000
    ; while (i < 9)
    ;     JArray.addInt(list_frisking_minimumBounty, DEFAULT_MINIMUM_BOUNTY)
    ;     i += 1
    ; endWhile

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