Scriptname RPB_Config extends Quest

import RPB_Utility
import PO3_SKSEFunctions
import Math

; ==========================================================
;                          Constants
; ==========================================================

bool property IS_DEBUG = false autoreadonly
bool property ENABLE_BENCHMARK = true autoreadonly

; ==========================================================
;                         API Related
; ==========================================================

float function GetVersion() global
    return 1.00
endFunction

string function GetPluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

string function GetModName() global
    return "Realistic Prison and Bounty"
endFunction

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

RPB_MCM property MCM
    RPB_MCM function get()
        return API.MCM
    endFunction
endProperty

RPB_Arrest property Arrest
    RPB_Arrest function get()
        return API.Arrest
    endFunction
endProperty

; ==========================================================
;                         Properties
; ==========================================================

string[] property Holds
    string[] function get()
        int cellsMap = RPB_Data.Unserialize()
        string[] _holds = JMap.allKeysPArray(cellsMap)
        return _holds
    endFunction
endProperty

string[] property Cities
    string[] function get()
        int citiesArray = JArray.object()
        int i = 0
        while (i < Holds.Length)
            int rootItem = RPB_Data.GetRootObject(Holds[i])
            ; string city = RPB_Data.GetPropertyOfTypeString(rootItem, Holds[i] + "//City")
            JArray.addStr(citiesArray, RPB_Data.Hold_GetCity(rootItem))
            i += 1
        endWhile

        return JArray.asStringArray(citiesArray)
    endFunction
endProperty

Actor property Player
    Actor function get()
        return Game.GetForm(0x00014) as Actor
    endFunction
endProperty

bool function IsInLocationFromHold(string hold)
; ; float x = StartBenchmark()

;     if (!miscVars.Exists("Locations["+ hold +"]"))
;         Error("Location does not exist for this hold.")
;         return false
;     endif

;     int i = 0
;     while (i < miscVars.GetLengthOf("Locations["+ hold +"]"))
;         Location holdLocation = miscVars.GetFormFromArray("Locations["+ hold +"]", i) as Location
;         ; As soon as the player is in any location for this hold, return.
;         if (Player.IsInLocation(holdLocation))
;             Debug("IsInLocationFromHold", "Player is in location: " + holdLocation.GetName() + " ("+ holdLocation.GetFormID() +")", MCM.IS_DEBUG)
;         ;    EndBenchmark(x, i + " iterations (IsLocationFromHold): returned true")

;             return true
;         endif
;         i += 1
;     endWhile
; ; EndBenchmark(x, i + " iterations (IsInLocationFromHold): returned false")

    return false
endFunction

bool function IsLocationFromHold(string hold, Location akLocation)
; float x = StartBenchmark()

;     int i = 0
;     while (i < miscVars.Exists("Locations["+ hold +"]"))
;         Location currentIteration = miscVars.GetFormFromArray("Locations["+ hold +"]", i) as Location
;         if (currentIteration == akLocation)
; ; EndBenchmark(x, i + " iterations (IsLocationFromHold): returned true")

;             return true
;         endif
;         i += 1
;     endWhile
; ; EndBenchmark(x, i + " iterations (IsInLocationFromHold): returned false")

    return false
endFunction

string function GetCurrentPlayerHoldLocationEx()
    int holdIndex = 0
    while (holdIndex < Holds.Length)
        int holdRootItem        = RPB_Data.GetRootObject(Holds[holdIndex])
        Form[] holdLocations    = RPB_Data.Hold_GetLocations(holdRootItem)

        int locationIndex = 0
        while (locationIndex < holdLocations.Length)
            Location holdLocation = holdLocations[locationIndex] as Location
            if (Player.IsInLocation(holdLocation))
                return Holds[holdIndex]
            endif
            locationIndex += 1
        endWhile
        holdIndex += 1

    endWhile

    return ""
endFunction

string function GetCurrentPlayerHoldLocation()
;    float x = StartBenchmark()

;     int holdIndex = 0
;     while (holdIndex < Holds.Length)
;         string hold = Holds[holdIndex]
;         int holdArrayLen = miscVars.GetLengthOf("Locations["+ hold +"]")
;         int locationIndex = 0
;         while (locationIndex < holdArrayLen)
;             Location holdLocation = miscVars.GetFormFromArray("Locations["+ hold +"]", locationIndex) as Location
;             if (Player.IsInLocation(holdLocation))
;             ;    EndBenchmark(x, (locationIndex * holdIndex) + " iterations (GetCurrentPlayerHoldLocation): returned " + Holds[holdIndex])

;                 return hold
;             endif
;             locationIndex += 1
;         endWhile
;         holdIndex += 1
;     endWhile
; ;    EndBenchmark(x, holdIndex + " iterations (GetCurrentPlayerHoldLocation): returned nothing")

    return ""
endFunction

string function GetHold(string city)
    ; return miscVars.GetString("Hold["+ city +"]")
endFunction

; string function GetCity(string hold)
;     return miscVars.GetString("City["+ hold +"]")
; endFunction

string function GetCity(string asHold)
    int holdRootItem = RPB_Data.GetRootObject(asHold)
    string city = RPB_Data.Hold_GetCity(holdRootItem)

    if (!city)
        RPB_Utility.Debug("Config::GetCity", "There's no City for Hold " + asHold + "!")
        return none
    endif

    return city
endFunction

string function GetCityNameFromHold(string hold)
    int holdToCityMap = JMap.object()

    JMap.setStr(holdToCityMap, "Whiterun", "Whiterun")
    JMap.setStr(holdToCityMap, "Winterhold", "Winterhold")
    JMap.setStr(holdToCityMap, "Eastmarch", "Windhelm")
    JMap.setStr(holdToCityMap, "Falkreath", "Falkreath")
    JMap.setStr(holdToCityMap, "Haafingar", "Solitude")
    JMap.setStr(holdToCityMap, "Hjaalmarch", "Morthal")
    JMap.setStr(holdToCityMap, "The Rift", "Riften")
    JMap.setStr(holdToCityMap, "The Reach", "Markarth")
    JMap.setStr(holdToCityMap, "The Pale", "Dawnstar")

    return JMap.getStr(holdToCityMap, hold)
endFunction

string function GetHoldNameFromCity(string city)
endFunction

Form function GetJailTeleportReleaseMarker(string hold)
    ; if (!miscVars.Exists("Jail::Release::Teleport["+ hold +"]"))
    ;     DebugError("Config::GetJailTeleportReleaseMarker", "The marker does not exist!")
    ;     return none
    ; endif

    ; return miscVars.GetForm("Jail::Release::Teleport["+ hold +"]")
endFunction

Form function GetJailPrisonerItemsContainer(string hold)
    ; if (!miscVars.Exists("Jail::Containers["+ hold +"]"))
    ;     DebugError("Config::GetJailPrisonerItemsContainer", "The container does not exist!")
    ;     return none
    ; endif
    
    ; return miscVars.GetForm("Jail::Containers["+ hold +"]")
endFunction

; To be refactored into the Jail or Imprisoned script
ObjectReference function GetRandomJailMarker(string hold)
    Form[] markers = RPB_Data.GetJailMarkers(hold) ; To be tested, probably not working now
    if (!markers)
        DebugError("Config::getJailMakers", "The markers do not exist!")
        return none
    endif

    int len = markers.length
    int markerIndex = Utility.RandomInt(0, len - 1)

    Debug("Config::GetRandomJailMarker", "Got Jail Cell " + (markerIndex + 1) + " (" + markers[markerIndex] + " [Index: "+ markerIndex +"]) marker for " + hold + "!")
    return markers[markerIndex] as ObjectReference
endFunction

Faction function GetFaction(string hold)
    int rootObject = RPB_Data.GetRootObject(hold)
    return RPB_Data.Hold_GetCrimeFaction(rootObject)
    ; if (miscVars.Exists("Faction::Crime["+ hold +"]"))
    ;     return miscVars.GetForm("Faction::Crime["+ hold +"]") as Faction
    ; endif

    ; return none
endFunction

; Temporary, to be implemented here later
Faction function GetCrimeFaction(string hold)
    return self.GetFaction(hold)
endFunction

int property FactionCount
    int function get()
        ; return miscVars.GetLengthOf("Factions")
    endFunction
endProperty

; ==========================================================
;                          General
; ==========================================================

int property FreeTimescale
    int function get()
        return MCM.GetOptionSliderValue("General::Timescale", "General") as int
    endFunction
endProperty

int property JailedTimescale
    int function get()
        return MCM.GetOptionSliderValue("General::TimescalePrison", "General") as int
    endFunction
endProperty

float property BountyDecayUpdateInterval
    float function get()
        return MCM.GetOptionSliderValue("General::Bounty Decay (Update Interval)", "General")
    endFunction
endProperty

float property InfamyDecayUpdateInterval
    float function get()
        return MCM.GetOptionSliderValue("General::Infamy Decay (Update Interval)", "General")
    endFunction
endProperty

int property ArrestEludeWarningTime
    int function get()
        return MCM.GetOptionSliderValue("General::Arrest Elude Warning Time", "General") as int
    endFunction
endProperty

bool property ShouldDisplayArrestNotifications
    bool function get()
        return MCM.GetOptionToggleState("General::ArrestNotifications", "General")
    endFunction
endProperty

bool property ShouldDisplayJailNotifications
    bool function get()
        return MCM.GetOptionToggleState("General::JailedNotifications", "General")
    endFunction
endProperty

bool property ShouldDisplayBountyDecayNotifications
    bool function get()
        return MCM.GetOptionToggleState("General::BountyDecayNotifications", "General")
    endFunction
endProperty

bool property ShouldDisplayInfamyNotifications
    bool function get()
        return MCM.GetOptionToggleState("General::InfamyNotifications", "General")
    endFunction
endProperty

; ==========================================================
;                          Clothing
; ==========================================================

bool property HasNudeBodyModInstalled
    bool function get()
        return MCM.GetOptionToggleState("Configuration::NudeBodyModInstalled", "Clothing")
    endFunction
endProperty

bool property HasUnderwearBodyModInstalled
    bool function get()
        return MCM.GetOptionToggleState("Configuration::UnderwearModInstalled", "Clothing")
    endFunction
endProperty

int property UnderwearTopSlot
    int function get()
        return MCM.GetOptionSliderValue("Item Slots::Underwear (Top)", "Clothing") as int
    endFunction
endProperty

int property UnderwearBottomSlot
    int function get()
        return MCM.GetOptionSliderValue("Item Slots::Underwear (Bottom)", "Clothing") as int
    endFunction
endProperty

int function GetDelevelingSkillValue(string skillName)
    return MCM.GetOptionSliderValue("Deleveling::" + skillName, "Skills") as int
endFunction

int function GetSkillLevelCap(string skillName)
    return MCM.GetOptionSliderValue("Level Caps::" + skillName, "Skills") as int
endFunction

int function GetArrestRequiredBounty(string hold)
    return MCM.GetOptionSliderValue("Arrest::Minimum Bounty to Arrest", hold) as int
endFunction

int function GetArrestGuaranteedPayableBounty(string hold)
    return MCM.GetOptionSliderValue("Arrest::Guaranteed Payable Bounty", hold) as int
endFunction

int function GetArrestMaximumPayableBounty(string hold)
    return MCM.GetOptionSliderValue("Arrest::Maximum Payable Bounty", hold) as int
endFunction

int function GetArrestMaximumPayableChance(string hold)
    return MCM.GetOptionSliderValue("Arrest::Maximum Payable Bounty (Chance)", hold) as int
endFunction

float function GetArrestAdditionalBountyEludingFromCurrentBounty(string hold)
    return MCM.GetOptionSliderValue("Arrest::Additional Bounty when Eluding (%)", hold)
endFunction

int function GetArrestAdditionalBountyEludingFlat(string hold)
    return MCM.GetOptionSliderValue("Arrest::Additional Bounty when Eluding", hold) as int
endFunction

float function GetArrestAdditionalBountyResistingFromCurrentBounty(string hold)
    return MCM.GetOptionSliderValue("Arrest::Additional Bounty when Resisting (%)", hold)
endFunction

int function GetArrestAdditionalBountyResistingFlat(string hold)
    return MCM.GetOptionSliderValue("Arrest::Additional Bounty when Resisting", hold) as int
endFunction

int function GetArrestAdditionalBountyResisting(string hold)
    float bountyPercentModifier = GetPercentAsDecimal(GetArrestAdditionalBountyResistingFromCurrentBounty(hold))
    int bountyFlat              = GetArrestAdditionalBountyResistingFlat(hold)
    Faction crimeFaction        = GetFaction(hold)
    int bounty                  = floor(crimeFaction.GetCrimeGold() * bountyPercentModifier) + bountyFlat

    return bounty
endFunction

float function GetArrestAdditionalBountyDefeatedFromCurrentBounty(string hold)
    return MCM.GetOptionSliderValue("Arrest::Additional Bounty when Defeated (%)", hold)
endFunction
 
int function GetArrestAdditionalBountyDefeatedFlat(string hold)
    return MCM.GetOptionSliderValue("Arrest::Additional Bounty when Defeated", hold) as int
endFunction

int function GetArrestAdditionalBountyDefeated(string hold)
    float bountyPercentModifier = GetPercentAsDecimal(GetArrestAdditionalBountyDefeatedFromCurrentBounty(hold))
    int bountyFlat              = GetArrestAdditionalBountyDefeatedFlat(hold)
    Faction crimeFaction        = GetFaction(hold)
    int bounty                  = floor(crimeFaction.GetCrimeGold() * bountyPercentModifier) + bountyFlat
    
    return bounty
endFunction

bool function IsFriskingEnabled(string hold)
    return MCM.GetOptionToggleState("Frisking::Allow Frisking", hold)
endFunction

bool function IsFriskingUnconditional(string hold)
    return MCM.GetOptionToggleState("Frisking::Unconditional Frisking", hold)
endFunction

int function GetFriskingBountyRequired(string hold)
    return MCM.GetOptionSliderValue("Frisking::Minimum Bounty for Frisking", hold) as int
endFunction

int function GetFriskingThoroughness(string hold)
    return MCM.GetOptionSliderValue("Frisking::Frisk Search Thoroughness", hold) as int
endFunction

bool function IsFriskingStolenItemsConfiscated(string hold)
    return MCM.GetOptionToggleState("Frisking::Confiscate Stolen Items", hold)
endFunction

bool function IsFriskingStripSearchWhenStolenItemsFound(string hold)
    return MCM.GetOptionToggleState("Frisking::Strip Search if Stolen Items Found", hold)
endFunction

int function GetFriskingStolenItemsRequiredForStripping(string hold)
    return MCM.GetOptionSliderValue("Frisking::Minimum No. of Stolen Items Required", hold) as int
endFunction

bool function IsStrippingEnabled(string hold)
    return MCM.GetOptionToggleState("Stripping::Allow Stripping", hold)
endFunction

string function GetStrippingHandlingCondition(string hold)
    return MCM.GetOptionMenuValue("Stripping::Handle Stripping On", hold)
endFunction

bool function IsStrippingUnconditional(string hold)
    return MCM.GetOptionMenuValue("Stripping::Handle Stripping On", hold) == "Unconditionally"
endFunction

bool function IsStrippingBasedOnSentence(string hold)
    return MCM.GetOptionMenuValue("Stripping::Handle Stripping On", hold) == "Minimum Sentence"
endFunction

bool function IsStrippingBasedOnBounty(string hold)
    return MCM.GetOptionMenuValue("Stripping::Handle Stripping On", hold) == "Minimum Bounty"
endFunction

int function GetStrippingMinimumSentence(string hold)
    return MCM.GetOptionSliderValue("Stripping::Minimum Sentence to Strip", hold) as int
endFunction

int function GetStrippingMinimumBounty(string hold)
    return MCM.GetOptionSliderValue("Stripping::Minimum Bounty to Strip", hold) as int
endFunction

int function GetStrippingMinimumViolentBounty(string hold)
    return MCM.GetOptionSliderValue("Stripping::Minimum Violent Bounty to Strip", hold) as int
endFunction

bool function IsStrippedOnDefeat(string hold)
    return MCM.GetOptionToggleState("Stripping::Strip when Defeated", hold)
endFunction

int function GetStrippingThoroughness(string hold)
    return MCM.GetOptionSliderValue("Stripping::Strip Search Thoroughness", hold) as int
endFunction

; TODO: Work needed, testing needed
int function GetStrippingThoroughnessBountyModifier(string hold)
    int bountyValue = MCM.GetOptionSliderValue("Stripping::Strip Search Thoroughness Modifier", hold) as int

    if (bountyValue == 0)
        return 0
    endif

    return bountyValue
endFunction

bool function IsClothingEnabled(string hold)
    return MCM.GetOptionToggleState("Clothing::Allow Clothing", hold)
endFunction

string function GetClothingHandlingCondition(string hold)
    return MCM.GetOptionMenuValue("Clothing::Handle Clothing On", hold)
endFunction

bool function IsClothingUnconditional(string hold)
    return MCM.GetOptionMenuValue("Clothing::Handle Clothing On", hold) == "Unconditionally"
endFunction

bool function IsClothingBasedOnSentence(string hold)
    return MCM.GetOptionMenuValue("Clothing::Handle Clothing On", hold) == "Maximum Sentence"
endFunction

bool function IsClothingBasedOnBounty(string hold)
    return MCM.GetOptionMenuValue("Clothing::Handle Stripping On", hold) == "Maximum Bounty"
endFunction

int function GetClothingMaximumSentence(string hold)
    return MCM.GetOptionSliderValue("Clothing::Maximum Sentence", hold) as int
endFunction

int function GetClothingMaximumBounty(string hold)
    return MCM.GetOptionSliderValue("Clothing::Maximum Bounty", hold) as int
endFunction

int function GetClothingMaximumViolentBounty(string hold)
    return MCM.GetOptionSliderValue("Clothing::Maximum Violent Bounty", hold) as int
endFunction

bool function IsClothedOnDefeat(string hold)
    return MCM.GetOptionToggleState("Clothing::When Defeated", hold)
endFunction

string function GetClothingOutfitIdentifier(string hold)
    string outfitName = self.GetClothingOutfitName(hold)
    return MCM.GetOutfitIdentifier(outfitName) ; Get mapped Outfit Name -> Outfit ID
endFunction

string function GetClothingOutfitName(string hold)
    return MCM.GetOptionMenuValue("Clothing::Outfit", hold)
endFunction

bool function UseDefaultOutfitAsFallback(string hold)
    return MCM.GetOptionToggleState("Clothing::Use Default Outfit as Fallback", hold)
endFunction

bool function IsClothingOutfitConditional(string hold)
    string holdOutfit = GetClothingOutfitIdentifier(hold)
    return MCM.GetOptionToggleState(holdOutfit + "::Conditional Outfit", "Clothing")
endFunction

bool function IsClothingOutfitConditionalFromID(string outfitId)
    return MCM.GetOptionToggleState(outfitId + "::Conditional Outfit", "Clothing")
endFunction

int function GetClothingOutfitMinimumBountyFromID(string outfitId)
    return MCM.GetOptionSliderValue(outfitId + "::Minimum Bounty", "Clothing") as int
endFunction

int function GetClothingOutfitMaximumBountyFromID(string outfitId)
    return MCM.GetOptionSliderValue(outfitId + "::Maximum Bounty", "Clothing") as int
endFunction

int function GetClothingOutfitMinimumBounty(string hold)
    string holdOutfit = GetClothingOutfitIdentifier(hold)
    return MCM.GetOptionSliderValue(holdOutfit + "::Minimum Bounty", "Clothing") as int
endFunction

int function GetClothingOutfitMaximumBounty(string hold)
    string holdOutfit = GetClothingOutfitIdentifier(hold)
    return MCM.GetOptionSliderValue(holdOutfit + "::Maximum Bounty", "Clothing") as int
endFunction

bool function IsInfamyEnabled(string hold)
    return MCM.GetOptionToggleState("Infamy::Enable Infamy", hold)
endFunction

float function GetInfamyGainedDailyFromArrestBounty(string hold)
    return MCM.GetOptionSliderValue("Infamy::Infamy Gained (%)", hold)
endFunction

int function GetInfamyGainedDaily(string hold)
    return MCM.GetOptionSliderValue("Infamy::Infamy Gained", hold) as int
endFunction

float function GetInfamyLostFromCurrentInfamy(string hold)
    return MCM.GetOptionSliderValue("Infamy::Infamy Lost (%)", hold)
endFunction

int function GetInfamyLost(string hold)
    return MCM.GetOptionSliderValue("Infamy::Infamy Lost", hold) as int
endFunction

int function GetInfamyRecognizedThreshold(string hold)
    return MCM.GetOptionSliderValue("Infamy::Infamy Recognized Threshold", hold) as int
endFunction

int function GetInfamyKnownThreshold(string hold)
    return MCM.GetOptionSliderValue("Infamy::Infamy Known Threshold", hold) as int
endFunction

int function GetInfamyGainModifier(string hold, string infamyLevel = "Recognized")
    return MCM.GetOptionSliderValue(string_if (infamyLevel == "Recognized", "Infamy::Infamy Gain Modifier (Recognized)", "Infamy::Infamy Gain Modifier (Known)"), hold) as int
endFunction

bool function IsBountyDecayEnabled(string hold)
    return MCM.GetOptionToggleState("Bounty Decaying::Enable Bounty Decaying", hold)
endFunction

; TODO: Finish conditions for this function
bool function IsBountyDecayableAsCriminal(string hold)
    return isBountyDecayEnabled(hold) && isInfamyEnabled(hold) && MCM.GetOptionToggleState("Bounty Decaying::Decay if Known as Criminal", hold)
endFunction

float function GetBountyDecayLostFromCurrentBounty(string hold)
    return MCM.GetOptionSliderValue("Bounty Decaying::Bounty Lost (%)", hold)
endFunction

int function GetBountyDecayLostBounty(string hold)
    return MCM.GetOptionSliderValue("Bounty Decaying::Bounty Lost", hold) as int
endFunction

float function GetAdditionalCharge(string hold, string charge)
    return MCM.GetOptionSliderValue("Additional Charges::" + charge, hold)
endFunction

bool function IsJailUnconditional(string hold)
    return MCM.GetOptionToggleState("Jail::Unconditional Imprisonment", hold)
endFunction

int function GetJailGuaranteedPayableBounty(string hold)
    return MCM.GetOptionSliderValue("Jail::Guaranteed Payable Bounty", hold) as int
endFunction

int function GetJailMaximumPayableBounty(string hold)
    return MCM.GetOptionSliderValue("Jail::Maximum Payable Bounty", hold) as int
endFunction

int function GetJailMaximumPayableChance(string hold)
    return MCM.GetOptionSliderValue("Jail::Maximum Payable Bounty (Chance)", hold) as int
endFunction

int function GetJailBountyExchange(string hold)
    return MCM.GetOptionSliderValue("Jail::Bounty Exchange", hold) as int
endFunction

int function GetJailBountyToSentence(string hold)
    return MCM.GetOptionSliderValue("Jail::Bounty to Sentence", hold) as int
endFunction

int function GetJailMinimumSentence(string hold)
    return MCM.GetOptionSliderValue("Jail::Minimum Sentence", hold) as int
endFunction

int function GetJailMaximumSentence(string hold)
    return MCM.GetOptionSliderValue("Jail::Maximum Sentence", hold) as int
endFunction

int function GetJailCellSearchThoroughness(string hold)
    return MCM.GetOptionSliderValue("Jail::Cell Search Thoroughness", hold) as int
endFunction

string function GetJailCellDoorLockLevel(string hold)
    return MCM.GetOptionMenuValue("Jail::Cell Lock Level", hold)
endFunction

int function GetJailReleaseTimeMinimumHour(string hold)
    return MCM.GetOptionSliderValue("Jail::Release Time (Minimum Hour)", hold) as int
endFunction

int function GetJailReleaseTimeMaximumHour(string hold)
    return MCM.GetOptionSliderValue("Jail::Release Time (Maximum Hour)", hold) as int
endFunction

bool function IsReleaseAllowedOnWeekends(string hold)
    return MCM.GetOptionToggleState("Jail::Allow Release on Weekends", hold)
endFunction

bool function IsJailFastForwardEnabled(string hold)
    return MCM.GetOptionToggleState("Jail::Fast Forward", hold)
endFunction

int function GetJailFastForwardDay(string hold)
    return MCM.GetOptionSliderValue("Jail::Day to fast forward from", hold) as int
endFunction

string function GetJailHandleSkillLoss(string hold)
    return MCM.GetOptionMenuValue("Jail::Handle Skill Loss", hold)
endFunction

int function GetJailDayToStartLosingSkillsOfType(string hold, string skillType)
    if (skillType == "Stat" || skillType == "Perk")
        return MCM.GetOptionSliderValue("Jail::Day to Start Losing Skills ("+ skillType +")", hold) as int
    endif
endFunction

int function GetJailChanceToLoseSkillsDailyOfType(string hold, string skillType)
    if (skillType == "Stat" || skillType == "Perk")
        return MCM.GetOptionSliderValue("Jail::Chance to Lose Skills ("+ skillType +")", hold) as int
    endif
endFunction

float function GetJailRecognizedCriminalPenalty(string hold)
    return MCM.GetOptionSliderValue("Jail::Recognized Criminal Penalty", hold)
endFunction

float function GetJailKnownCriminalPenalty(string hold)
    return MCM.GetOptionSliderValue("Jail::Known Criminal Penalty", hold)
endFunction

int function GetJailBountyToTriggerCriminalPenalty(string hold)
    return MCM.GetOptionSliderValue("Jail::Minimum Bounty to Trigger", hold) as int
endFunction

bool function IsJailReleaseFeesEnabled(string hold)
    return MCM.GetOptionToggleState("Release::Enable Release Fees", hold)
endFunction

int function GetReleaseChanceForReleaseFeesEvent(string hold)
    return MCM.GetOptionSliderValue("Release::Chance for Event", hold) as int
endFunction

int function GetReleaseBountyToOweFees(string hold)
    return MCM.GetOptionSliderValue("Release::Minimum Bounty to owe Fees", hold) as int
endFunction

float function GetReleaseReleaseFeesFromBounty(string hold)
    return MCM.GetOptionSliderValue("Release::Release Fees (%)", hold)
endFunction

int function GetReleaseReleaseFeesFlat(string hold)
    return MCM.GetOptionSliderValue("Release::Release Fees", hold) as int
endFunction

int function GetReleaseDaysGivenToPayReleaseFees(string hold)
    return MCM.GetOptionSliderValue("Release::Days Given to Pay", hold) as int
endFunction

bool function IsItemRetentionEnabledOnRelease(string hold)
    return MCM.GetOptionToggleState("Release::Enable Item Retention", hold)
endFunction

int function GetReleaseBountyToRetainItems(string hold)
    return MCM.GetOptionSliderValue("Release::Minimum Bounty to Retain Items", hold) as int
endFunction

bool function IsAutoDressingEnabledOnRelease(string hold)
    return MCM.GetOptionToggleState("Release::Auto Re-Dress on Release", hold)
endFunction

string function GetEscapeHandlingCondition(string hold)
    return MCM.GetOptionMenuValue("Escape::Handle Escape On", hold)
endFunction

float function GetEscapedBountyFromCurrentArrest(string hold)
    return MCM.GetOptionSliderValue("Escape::Escape Bounty (%)", hold)
endFunction

int function GetEscapedBountyFlat(string hold)
    return MCM.GetOptionSliderValue("Escape::Escape Bounty", hold) as int
endFunction

float function GetEscapedBountySentenceMultiplier(string hold)
    return MCM.GetOptionSliderValue("Escape::Escape Bounty (Sentence)", hold)
endFunction

int function GetEscapeBountySentenceDays(string hold)
    return MCM.GetOptionSliderValue("Escape::Escape Bounty (Sentence Days)", hold) as int
endFunction

int function GetEscapeBountyCondition(string hold)
    return MCM.GetOptionSliderValue("Escape::Escape Bounty (Bounty Condition)", hold) as int
endFunction

int function GetEscapeBountySentenceCondition(string hold)
    return MCM.GetOptionSliderValue("Escape::Escape Bounty (Sentence Condition)", hold) as int
endFunction

int function GetEscapeBountyFallbackBounty(string hold)
    return MCM.GetOptionSliderValue("Escape::Fallback Bounty", hold) as int
endFunction

bool function IsTimeServedAccountedForOnEscape(string hold)
    return MCM.GetOptionToggleState("Escape::Account for Time Served", hold)
endFunction

bool function IsSurrenderEnabledOnEscape(string hold)
    return MCM.GetOptionToggleState("Escape::Allow Surrendering", hold)
endFunction

bool function ShouldFriskOnEscape(string hold)
    return MCM.GetOptionToggleState("Escape::Frisk Search upon Captured", hold)
endFunction

bool function ShouldStripOnEscape(string hold)
    return MCM.GetOptionToggleState("Escape::Strip Search upon Captured", hold)
endFunction

float function GetChargeBountyForImpersonation(string hold)
    return MCM.GetOptionSliderValue("Additional Charges::Bounty for Impersonation", hold)
endFunction

float function GetChargeBountyForEnemyOfHold(string hold)
    return MCM.GetOptionSliderValue("Additional Charges::Bounty for Enemy of Hold", hold)
endFunction

float function GetChargeBountyForStolenItems(string hold)
    return MCM.GetOptionSliderValue("Additional Charges::Bounty for Stolen Items", hold)
endFunction

float function GetChargeBountyForStolenItemFromItemValue(string hold)
    return MCM.GetOptionSliderValue("Additional Charges::Bounty for Stolen Item", hold)
endFunction

float function GetChargeBountyForContraband(string hold)
    return MCM.GetOptionSliderValue("Additional Charges::Bounty for Contraband", hold)
endFunction

float function GetChargeBountyForCellKey(string hold)
    return MCM.GetOptionSliderValue("Additional Charges::Bounty for Cell Key", hold)
endFunction

function IncrementInfamy(string hold, int incrementBy)
    int currentInfamy = GetInfamyGained(hold)
    string option = hold + "::Infamy Gained"
    ; MCM.SetOptionStatValue(option, currentInfamy + incrementBy)
    NotifyInfamy("You have gained " + incrementBy + " Infamy in " + hold)
endFunction

function DecrementInfamy(string hold, int decrementBy)
    int currentInfamy = GetInfamyGained(hold)
    string option = hold + "::Infamy Gained"
    ; MCM.SetOptionStatValue(option, currentInfamy - decrementBy)
endFunction

; TODO: Change how the stat is parsed
int function GetInfamyGained(string hold)
    ; return actorVars.GetInfamy(self.GetFaction(hold), Player)
    ; return MCM.GetStatOptionValue("Stats", hold + "::Infamy Gained")
endFunction

bool function IsInfamyRecognized(string hold)
    return isInfamyEnabled(hold) && getInfamyGained(hold) >= getInfamyRecognizedThreshold(hold)
endFunction

bool function IsInfamyKnown(string hold)
    return isInfamyEnabled(hold) && getInfamyGained(hold) >= getInfamyKnownThreshold(hold)
endFunction

bool function HasBountyInHold(string hold)
    Faction crimeFaction = GetFaction(hold)
    if (!crimeFaction)
        Error("The faction does not exist. " + "(Hold: " + hold + ")")
        return false
    endif

    return crimeFaction.GetCrimeGold() > 0
endFunction

function NotifyArrest(string msg, bool condition = true)
    if (ShouldDisplayArrestNotifications && condition)
        debug.notification(msg)
    endif
endFunction

function NotifyJail(string msg, bool condition = true)
    if (ShouldDisplayJailNotifications && condition)
        debug.notification(msg)
    endif
endFunction

function NotifyBounty(string msg, bool condition = true)
    if (ShouldDisplayBountyDecayNotifications && condition)
        debug.notification(msg)
    endif
endFunction

function NotifyInfamy(string msg, bool condition = true)
    if (ShouldDisplayInfamyNotifications && condition)
        debug.notification(msg)
    endif
endFunction

bool function IsBountyDecayable(string hold)
    bool isDecayable = false

    if (isBountyDecayableAsCriminal(hold) && !isInfamyKnown(hold))
        isDecayable = true
    elseif (isBountyDecayEnabled(hold))
        isDecayable = true
    endif

    return isDecayable
endFunction

Armor function GetOutfitPart(string hold, string bodyPart)
    string holdOutfitIdentifier = GetClothingOutfitIdentifier(hold)

    ; DebugWithArgs("Config::GetOutfitPart", "hold: " + hold + ", bodyPart: " + bodyPart, "outfitIdentifier: " + holdOutfitIdentifier + ", outfitPart: " + MCM.GetOutfitPart(holdOutfitIdentifier, bodyPart))

    return MCM.GetOutfitPart(holdOutfitIdentifier, bodyPart)
endFunction



