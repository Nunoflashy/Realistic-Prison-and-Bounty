Scriptname RealisticPrisonAndBounty_Config extends Quest

import RPB_Utility
import PO3_SKSEFunctions
import Math

; ==============================================================================
; Constants
; ==============================================================================

bool property IS_DEBUG = false autoreadonly
bool property ENABLE_BENCHMARK = true autoreadonly

float function GetVersion() global
    return 1.00
endFunction

string function GetPluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

string function GetModName() global
    return "Realistic Prison and Bounty"
endFunction

Form property mainAPI
    Form function get()
        return Game.GetFormFromFile(0x3DF8, GetPluginName())
    endFunction
endProperty

RPB_API                                 property API auto
RPB_MCM                                 property MCM auto
RealisticPrisonAndBounty_Arrest         property Arrest auto
RealisticPrisonAndBounty_Jail           property Jail auto
RealisticPrisonAndBounty_ArrestVars     property ArrestVars auto
RealisticPrisonAndBounty_ActorVars      property ActorVars auto
RealisticPrisonAndBounty_MiscVars       property MiscVars auto
RealisticPrisonAndBounty_SceneManager   property SceneManager auto
RealisticPrisonAndBounty_EventManager   property EventManager auto


; Called from ConfigAlias
bool function HandleEvents()
; ==========================================================
;                     EventManager Events
; ==========================================================
    eventManager.RegisterEvents()

    return true
endFunction

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

bool function SetPrisons()
    RPB_PrisonManager prisonManager = GetFormFromMod(0x1B825) as RPB_PrisonManager

    int i = 0
    bool break = false
    while (i < Holds.Length && !break)
        if (!prisonManager.InitializePrisonConfig(Holds[i]))
            break = true
        endif
        i += 1
    endWhile

    return true
endFunction

bool function SetJailTeleportReleaseLocations()
    miscVars.SetForm("Jail::Release::Teleport[Whiterun]", Game.GetFormEx(0x3EF19)) ; FormID Invalid
    miscVars.SetForm("Jail::Release::Teleport[Eastmarch]", Game.GetFormEx(0x3EF19)) ; FormID Invalid
    miscVars.SetForm("Jail::Release::Teleport[Falkreath]", Game.GetFormEx(0x3EF19)) ; FormID Invalid
    miscVars.SetForm("Jail::Release::Teleport[Haafingar]", Game.GetFormEx(0x3EF19))
    miscVars.SetForm("Jail::Release::Teleport[Hjaalmarch]", Game.GetFormEx(0x3EF19)) ; FormID Invalid
    miscVars.SetForm("Jail::Release::Teleport[The Rift]", Game.GetFormEx(0x3EF19)) ; FormID Invalid
    miscVars.SetForm("Jail::Release::Teleport[The Pale]", Game.GetFormEx(0x3EF19)) ; FormID Invalid

    return true
endFunction

bool function SetJailPrisonerContainers()
    miscVars.SetForm("Jail::Containers[Whiterun]", Game.GetFormEx(0x3EEFF)) ; FormID Invalid
    miscVars.SetForm("Jail::Containers[Eastmarch]", Game.GetFormEx(0x3EEFF)) ; FormID Invalid
    miscVars.SetForm("Jail::Containers[Falkreath]", Game.GetFormEx(0x3EEFF)) ; FormID Invalid
    miscVars.SetForm("Jail::Containers[Haafingar]", Game.GetFormEx(0x3EEFF))
    miscVars.SetForm("Jail::Containers[Hjaalmarch]", Game.GetFormEx(0x3EEFF)) ; FormID Invalid
    miscVars.SetForm("Jail::Containers[The Rift]", Game.GetFormEx(0x3EEFF)) ; FormID Invalid
    miscVars.SetForm("Jail::Containers[The Pale]", Game.GetFormEx(0x3EEFF)) ; FormID Invalid

    return true
endFunction

bool function SetHoldLocations()
    if (miscVars.Exists("Locations"))
        return true
    endif

    miscVars.AddFormToArray("Locations[Whiterun]", Game.GetForm(0x00018A56))
    miscVars.AddFormToArray("Locations[Whiterun]", Game.GetForm(0x00016772))

    miscVars.AddFormToArray("Locations[Winterhold]", Game.GetForm(0x00018A51))
    miscVars.AddFormToArray("Locations[Winterhold]", Game.GetForm(0x0001676B))

    miscVars.AddFormToArray("Locations[Eastmarch]", Game.GetForm(0x00018A57))
    miscVars.AddFormToArray("Locations[Eastmarch]", Game.GetForm(0x0001676A))

    miscVars.AddFormToArray("Locations[Falkreath]", Game.GetForm(0x00018A49))
    miscVars.AddFormToArray("Locations[Falkreath]", Game.GetForm(0x0001676F))

    miscVars.AddFormToArray("Locations[Haafingar]", Game.GetForm(0x00018A5A))
    miscVars.AddFormToArray("Locations[Haafingar]", Game.GetForm(0x00016770))

    miscVars.AddFormToArray("Locations[Hjaalmarch]", Game.GetForm(0x00018A53))
    miscVars.AddFormToArray("Locations[Hjaalmarch]", Game.GetForm(0x0001676E))

    miscVars.AddFormToArray("Locations[The Rift]", Game.GetForm(0x00018A58))
    miscVars.AddFormToArray("Locations[The Rift]", Game.GetForm(0x0001676C))

    miscVars.AddFormToArray("Locations[The Reach]", Game.GetForm(0x00018A59))
    miscVars.AddFormToArray("Locations[The Reach]", Game.GetForm(0x00016769))

    miscVars.AddFormToArray("Locations[The Pale]", Game.GetForm(0x00018A50))
    miscVars.AddFormToArray("Locations[The Pale]", Game.GetForm(0x0001676D))

    miscVars.CreateStringMap("Locations")
    int i = 0
    while (i < Holds.Length)
        string hold = Holds[i]
        if (miscVars.Exists("Locations["+ hold +"]"))
            miscVars.AddToContainer("Locations", "Locations["+ hold +"]")
        endif
        i += 1
    endWhile

    Debug("Config::SetHoldLocations", "Length: " + miscVars.GetLengthOf("Locations"))

    return true
endFunction

bool function IsInLocationFromHold(string hold)
; float x = StartBenchmark()

    if (!miscVars.Exists("Locations["+ hold +"]"))
        Error("Location does not exist for this hold.")
        return false
    endif

    int i = 0
    while (i < miscVars.GetLengthOf("Locations["+ hold +"]"))
        Location holdLocation = miscVars.GetFormFromArray("Locations["+ hold +"]", i) as Location
        ; As soon as the player is in any location for this hold, return.
        if (Player.IsInLocation(holdLocation))
            Debug("IsInLocationFromHold", "Player is in location: " + holdLocation.GetName() + " ("+ holdLocation.GetFormID() +")", MCM.IS_DEBUG)
        ;    EndBenchmark(x, i + " iterations (IsLocationFromHold): returned true")

            return true
        endif
        i += 1
    endWhile
; EndBenchmark(x, i + " iterations (IsInLocationFromHold): returned false")

    return false
endFunction

bool function IsLocationFromHold(string hold, Location akLocation)
; float x = StartBenchmark()

    int i = 0
    while (i < miscVars.Exists("Locations["+ hold +"]"))
        Location currentIteration = miscVars.GetFormFromArray("Locations["+ hold +"]", i) as Location
        if (currentIteration == akLocation)
; EndBenchmark(x, i + " iterations (IsLocationFromHold): returned true")

            return true
        endif
        i += 1
    endWhile
; EndBenchmark(x, i + " iterations (IsInLocationFromHold): returned false")

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

    int holdIndex = 0
    while (holdIndex < Holds.Length)
        string hold = Holds[holdIndex]
        int holdArrayLen = miscVars.GetLengthOf("Locations["+ hold +"]")
        int locationIndex = 0
        while (locationIndex < holdArrayLen)
            Location holdLocation = miscVars.GetFormFromArray("Locations["+ hold +"]", locationIndex) as Location
            if (Player.IsInLocation(holdLocation))
            ;    EndBenchmark(x, (locationIndex * holdIndex) + " iterations (GetCurrentPlayerHoldLocation): returned " + Holds[holdIndex])

                return hold
            endif
            locationIndex += 1
        endWhile
        holdIndex += 1
    endWhile
;    EndBenchmark(x, holdIndex + " iterations (GetCurrentPlayerHoldLocation): returned nothing")

    return ""
endFunction

string function GetHold(string city)
    return miscVars.GetString("Hold["+ city +"]")
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
    if (!miscVars.Exists("Jail::Release::Teleport["+ hold +"]"))
        MCM.Error("Config::GetJailTeleportReleaseMarker", "The marker does not exist!")
        return none
    endif

    return miscVars.GetForm("Jail::Release::Teleport["+ hold +"]")
endFunction

Form function GetJailPrisonerItemsContainer(string hold)
    if (!miscVars.Exists("Jail::Containers["+ hold +"]"))
        MCM.Error("Config::GetJailPrisonerItemsContainer", "The container does not exist!")
        return none
    endif
    
    return miscVars.GetForm("Jail::Containers["+ hold +"]")
endFunction

; To be refactored into the Jail or Imprisoned script
ObjectReference function GetRandomJailMarker(string hold)
    Form[] markers = RPB_Data.GetJailMarkers(hold) ; To be tested, probably not working now
    if (!markers)
        MCM.Error("Config::getJailMakers", "The markers do not exist!")
        return none
    endif

    int len = markers.length
    int markerIndex = Utility.RandomInt(0, len - 1)

    MCM.Debug("Config::GetRandomJailMarker", "Got Jail Cell " + (markerIndex + 1) + " (" + markers[markerIndex] + " [Index: "+ markerIndex +"]) marker for " + hold + "!")
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
        return miscVars.GetLengthOf("Factions")
    endFunction
endProperty

int property FreeTimescale
    int function get()
        return MCM.GetSliderOptionValue("General", "General::Timescale") as int
    endFunction
endProperty

int property JailedTimescale
    int function get()
        return MCM.GetSliderOptionValue("General", "General::TimescalePrison") as int
    endFunction
endProperty

float property BountyDecayUpdateInterval
    float function get()
        return MCM.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)")
    endFunction
endProperty

float property InfamyDecayUpdateInterval
    float function get()
        return MCM.GetSliderOptionValue("General", "General::Infamy Decay (Update Interval)")
    endFunction
endProperty

int property ArrestEludeWarningTime
    int function get()
        return MCM.GetSliderOptionValue("General", "General::Arrest Elude Warning Time") as int
    endFunction
endProperty

bool property ShouldDisplayArrestNotifications
    bool function get()
        return MCM.GetToggleOptionState("General", "General::ArrestNotifications")
    endFunction
endProperty

bool property ShouldDisplayJailNotifications
    bool function get()
        return MCM.GetToggleOptionState("General", "General::JailedNotifications")
    endFunction
endProperty

bool property ShouldDisplayBountyDecayNotifications
    bool function get()
        return MCM.GetToggleOptionState("General", "General::BountyDecayNotifications")
    endFunction
endProperty

bool property ShouldDisplayInfamyNotifications
    bool function get()
        return MCM.GetToggleOptionState("General", "General::InfamyNotifications")
    endFunction
endProperty

bool property HasNudeBodyModInstalled
    bool function get()
        return MCM.GetToggleOptionState("Clothing", "Configuration::NudeBodyModInstalled")
    endFunction
endProperty

bool property HasUnderwearBodyModInstalled
    bool function get()
        return MCM.GetToggleOptionState("Clothing", "Configuration::UnderwearModInstalled")
    endFunction
endProperty

int property UnderwearTopSlot
    int function get()
        return MCM.GetSliderOptionValue("Clothing", "Item Slots::Underwear (Top)") as int
    endFunction
endProperty

int property UnderwearBottomSlot
    int function get()
        return MCM.GetSliderOptionValue("Clothing", "Item Slots::Underwear (Bottom)") as int
    endFunction
endProperty

bool function ShouldDisplaySentencePage()
    RPB_Prison playerPrison = RPB_Prison.GetPrisonForHold("Haafingar")
    RPB_Prisoner playerPrisoner = playerPrison.GetPrisonerReference(self.Player)

    if (!playerPrisoner)
        return false
    endif

    return true
endFunction

; Temporary functions
function PrepareActorForJail(Actor akActor)
    ; Undress actor
    akActor.UnequipAll()

    AddOutfit("Outfit 1", none, Game.GetFormEx(0x3C9FE) as Armor, none, none)
    AddOutfit("Outfit 2", none, Game.GetFormEx(0x3C9FE) as Armor, none, Game.GetFormEx(0x3CA00) as Armor)
    WearOutfitOnActor(akActor, "Outfit 1")
endFunction

int function GetDelevelingSkillValue(string skillName)
    return MCM.GetSliderOptionValue("Skills", "Deleveling::" + skillName) as int
endFunction

int function GetSkillLevelCap(string skillName)
    return MCM.GetSliderOptionValue("Skills", "Level Caps::" + skillName) as int
endFunction

int function GetArrestRequiredBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Minimum Bounty to Arrest") as int
endFunction

int function GetArrestGuaranteedPayableBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Guaranteed Payable Bounty") as int
endFunction

int function GetArrestMaximumPayableBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Maximum Payable Bounty") as int
endFunction

int function GetArrestMaximumPayableChance(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Maximum Payable Bounty (Chance)") as int
endFunction

float function GetArrestAdditionalBountyEludingFromCurrentBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Eluding (%)")
endFunction

int function GetArrestAdditionalBountyEludingFlat(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Eluding") as int
endFunction

float function GetArrestAdditionalBountyResistingFromCurrentBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Resisting (%)")
endFunction

int function GetArrestAdditionalBountyResistingFlat(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Resisting") as int
endFunction

int function GetArrestAdditionalBountyResisting(string hold)
    float bountyPercentModifier = GetPercentAsDecimal(GetArrestAdditionalBountyResistingFromCurrentBounty(hold))
    int bountyFlat              = GetArrestAdditionalBountyResistingFlat(hold)
    Faction crimeFaction        = GetFaction(hold)
    int bounty                  = floor(crimeFaction.GetCrimeGold() * bountyPercentModifier) + bountyFlat

    return bounty
endFunction

float function GetArrestAdditionalBountyDefeatedFromCurrentBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Defeated (%)")
endFunction
 
int function GetArrestAdditionalBountyDefeatedFlat(string hold)
    return MCM.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Defeated") as int
endFunction

int function GetArrestAdditionalBountyDefeated(string hold)
    float bountyPercentModifier = GetPercentAsDecimal(getArrestAdditionalBountyDefeatedFromCurrentBounty(hold))
    int bountyFlat              = GetArrestAdditionalBountyDefeatedFlat(hold)
    Faction crimeFaction        = GetFaction(hold)
    int bounty                  = floor(crimeFaction.GetCrimeGold() * bountyPercentModifier) + bountyFlat
    
    return bounty
endFunction

bool function IsFriskingEnabled(string hold)
    return MCM.GetToggleOptionState(hold, "Frisking::Allow Frisking")
endFunction

bool function IsFriskingUnconditional(string hold)
    return MCM.GetToggleOptionState(hold, "Frisking::Unconditional Frisking")
endFunction

int function GetFriskingBountyRequired(string hold)
    return MCM.GetSliderOptionValue(hold, "Frisking::Minimum Bounty for Frisking") as int
endFunction

int function GetFriskingThoroughness(string hold)
    return MCM.GetSliderOptionValue(hold, "Frisking::Frisk Search Thoroughness") as int
endFunction

bool function IsFriskingStolenItemsConfiscated(string hold)
    return MCM.GetToggleOptionState(hold, "Frisking::Confiscate Stolen Items")
endFunction

bool function IsFriskingStripSearchWhenStolenItemsFound(string hold)
    return MCM.GetToggleOptionState(hold, "Frisking::Strip Search if Stolen Items Found")
endFunction

int function GetFriskingStolenItemsRequiredForStripping(string hold)
    return MCM.GetSliderOptionValue(hold, "Frisking::Minimum No. of Stolen Items Required") as int
endFunction

bool function IsStrippingEnabled(string hold)
    return MCM.GetToggleOptionState(hold, "Stripping::Allow Stripping")
endFunction

string function GetStrippingHandlingCondition(string hold)
    return MCM.GetMenuOptionValue(hold, "Stripping::Handle Stripping On")
endFunction

bool function IsStrippingUnconditional(string hold)
    return MCM.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Unconditionally"
endFunction

bool function IsStrippingBasedOnSentence(string hold)
    return MCM.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Minimum Sentence"
endFunction

bool function IsStrippingBasedOnBounty(string hold)
    return MCM.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Minimum Bounty"
endFunction

int function GetStrippingMinimumSentence(string hold)
    return MCM.GetSliderOptionValue(hold, "Stripping::Minimum Sentence to Strip") as int
endFunction

int function GetStrippingMinimumBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Stripping::Minimum Bounty to Strip") as int
endFunction

int function GetStrippingMinimumViolentBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Stripping::Minimum Violent Bounty to Strip") as int
endFunction

bool function IsStrippedOnDefeat(string hold)
    return MCM.GetToggleOptionState(hold, "Stripping::Strip when Defeated")
endFunction

int function GetStrippingThoroughness(string hold)
    return MCM.GetSliderOptionValue(hold, "Stripping::Strip Search Thoroughness") as int
endFunction

; TODO: Work needed, testing needed
int function GetStrippingThoroughnessBountyModifier(string hold)
    int bountyValue = MCM.GetSliderOptionValue(hold, "Stripping::Strip Search Thoroughness Modifier") as int

    if (bountyValue == 0)
        return 0
    endif

    return bountyValue
endFunction

bool function IsClothingEnabled(string hold)
    return MCM.GetToggleOptionState(hold, "Clothing::Allow Clothing")
endFunction

string function GetClothingHandlingCondition(string hold)
    return MCM.GetMenuOptionValue(hold, "Clothing::Handle Clothing On")
endFunction

bool function IsClothingUnconditional(string hold)
    return MCM.GetMenuOptionValue(hold, "Clothing::Handle Clothing On") == "Unconditionally"
endFunction

bool function IsClothingBasedOnSentence(string hold)
    return MCM.GetMenuOptionValue(hold, "Clothing::Handle Clothing On") == "Maximum Sentence"
endFunction

bool function IsClothingBasedOnBounty(string hold)
    return MCM.GetMenuOptionValue(hold, "Clothing::Handle Stripping On") == "Maximum Bounty"
endFunction

int function GetClothingMaximumSentence(string hold)
    return MCM.GetSliderOptionValue(hold, "Clothing::Maximum Sentence") as int
endFunction

int function GetClothingMaximumBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Clothing::Maximum Bounty") as int
endFunction

int function GetClothingMaximumViolentBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Clothing::Maximum Violent Bounty") as int
endFunction

bool function IsClothedOnDefeat(string hold)
    return MCM.GetToggleOptionState(hold, "Clothing::When Defeated")
endFunction

string function GetClothingOutfit(string hold)
    return MCM.GetOutfitIdentifier(MCM.GetMenuOptionValue(hold, "Clothing::Outfit")) ; Get mapped Outfit ID
endFunction

bool function IsClothingOutfitConditional(string hold)
    string holdOutfit = GetClothingOutfit(hold)
    return MCM.GetToggleOptionState("Clothing", holdOutfit + "::Conditional Outfit")
endFunction

bool function IsClothingOutfitConditionalFromID(string outfitId)
    return MCM.GetToggleOptionState("Clothing", outfitId + "::Conditional Outfit")
endFunction

int function GetClothingOutfitMinimumBountyFromID(string outfitId)
    return MCM.GetSliderOptionValue("Clothing", outfitId + "::Minimum Bounty") as int
endFunction

int function GetClothingOutfitMaximumBountyFromID(string outfitId)
    return MCM.GetSliderOptionValue("Clothing", outfitId + "::Maximum Bounty") as int
endFunction

int function GetClothingOutfitMinimumBounty(string hold)
    string holdOutfit = GetClothingOutfit(hold)
    return MCM.GetSliderOptionValue("Clothing", holdOutfit + "::Minimum Bounty") as int
endFunction

int function GetClothingOutfitMaximumBounty(string hold)
    string holdOutfit = GetClothingOutfit(hold)
    return MCM.GetSliderOptionValue("Clothing", holdOutfit + "::Maximum Bounty") as int
endFunction

bool function IsInfamyEnabled(string hold)
    return MCM.GetToggleOptionState(hold, "Infamy::Enable Infamy")
endFunction

float function GetInfamyGainedDailyFromArrestBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Infamy::Infamy Gained (%)")
endFunction

int function GetInfamyGainedDaily(string hold)
    return MCM.GetSliderOptionValue(hold, "Infamy::Infamy Gained") as int
endFunction

float function GetInfamyLostFromCurrentInfamy(string hold)
    return MCM.GetSliderOptionValue(hold, "Infamy::Infamy Lost (%)")
endFunction

int function GetInfamyLost(string hold)
    return MCM.GetSliderOptionValue(hold, "Infamy::Infamy Lost") as int
endFunction

int function GetInfamyRecognizedThreshold(string hold)
    return MCM.GetSliderOptionValue(hold, "Infamy::Infamy Recognized Threshold") as int
endFunction

int function GetInfamyKnownThreshold(string hold)
    return MCM.GetSliderOptionValue(hold, "Infamy::Infamy Known Threshold") as int
endFunction

int function GetInfamyGainModifier(string hold, string infamyLevel = "Recognized")
    return MCM.GetSliderOptionValue(hold, string_if (infamyLevel == "Recognized", "Infamy::Infamy Gain Modifier (Recognized)", "Infamy::Infamy Gain Modifier (Known)")) as int
endFunction

bool function IsBountyDecayEnabled(string hold)
    return MCM.GetToggleOptionState(hold, "Bounty Decaying::Enable Bounty Decaying")
endFunction

; TODO: Finish conditions for this function
bool function IsBountyDecayableAsCriminal(string hold)
    return isBountyDecayEnabled(hold) && isInfamyEnabled(hold) && MCM.GetToggleOptionState(hold, "Bounty Decaying::Decay if Known as Criminal")
endFunction

float function GetBountyDecayLostFromCurrentBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Bounty Decaying::Bounty Lost (%)")
endFunction

int function GetBountyDecayLostBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Bounty Decaying::Bounty Lost") as int
endFunction

float function GetAdditionalCharge(string hold, string charge)
    return MCM.GetSliderOptionValue(hold, "Additional Charges::" + charge)
endFunction

bool function IsJailUnconditional(string hold)
    return MCM.GetToggleOptionState(hold, "Jail::Unconditional Imprisonment")
endFunction

int function GetJailGuaranteedPayableBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Guaranteed Payable Bounty") as int
endFunction

int function GetJailMaximumPayableBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Maximum Payable Bounty") as int
endFunction

int function GetJailMaximumPayableChance(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Maximum Payable Bounty (Chance)") as int
endFunction

int function GetJailBountyExchange(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Bounty Exchange") as int
endFunction

int function GetJailBountyToSentence(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Bounty to Sentence") as int
endFunction

int function GetJailMinimumSentence(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Minimum Sentence") as int
endFunction

int function GetJailMaximumSentence(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Maximum Sentence") as int
endFunction

int function GetJailCellSearchThoroughness(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Cell Search Thoroughness") as int
endFunction

string function GetJailCellDoorLockLevel(string hold)
    return MCM.GetMenuOptionValue(hold, "Jail::Cell Lock Level")
endFunction

int function GetJailReleaseTimeMinimumHour(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Release Time (Minimum Hour)") as int
endFunction

int function GetJailReleaseTimeMaximumHour(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Release Time (Maximum Hour)") as int
endFunction

bool function IsReleaseAllowedOnWeekends(string hold)
    return MCM.GetToggleOptionState(hold, "Jail::Allow Release on Weekends")
endFunction

bool function IsJailFastForwardEnabled(string hold)
    return MCM.GetToggleOptionState(hold, "Jail::Fast Forward")
endFunction

int function GetJailFastForwardDay(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Day to fast forward from") as int
endFunction

string function GetJailHandleSkillLoss(string hold)
    return MCM.GetMenuOptionValue(hold, "Jail::Handle Skill Loss")
endFunction

int function GetJailDayToStartLosingSkills(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Day to Start Losing Skills") as int
endFunction

int function GetJailChanceToLoseSkillsDaily(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Chance to Lose Skills") as int
endFunction

float function GetJailRecognizedCriminalPenalty(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Recognized Criminal Penalty")
endFunction

float function GetJailKnownCriminalPenalty(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Known Criminal Penalty")
endFunction

int function GetJailBountyToTriggerCriminalPenalty(string hold)
    return MCM.GetSliderOptionValue(hold, "Jail::Minimum Bounty to Trigger") as int
endFunction

bool function IsJailReleaseFeesEnabled(string hold)
    return MCM.GetToggleOptionState(hold, "Release::Enable Release Fees")
endFunction

int function GetReleaseChanceForReleaseFeesEvent(string hold)
    return MCM.GetSliderOptionValue(hold, "Release::Chance for Event") as int
endFunction

int function GetReleaseBountyToOweFees(string hold)
    return MCM.GetSliderOptionValue(hold, "Release::Minimum Bounty to owe Fees") as int
endFunction

float function GetReleaseReleaseFeesFromBounty(string hold)
    return MCM.GetSliderOptionValue(hold, "Release::Release Fees (%)")
endFunction

int function GetReleaseReleaseFeesFlat(string hold)
    return MCM.GetSliderOptionValue(hold, "Release::Release Fees") as int
endFunction

int function GetReleaseDaysGivenToPayReleaseFees(string hold)
    return MCM.GetSliderOptionValue(hold, "Release::Days Given to Pay") as int
endFunction

bool function IsItemRetentionEnabledOnRelease(string hold)
    return MCM.GetToggleOptionState(hold, "Release::Enable Item Retention")
endFunction

int function GetReleaseBountyToRetainItems(string hold)
    return MCM.GetSliderOptionValue(hold, "Release::Minimum Bounty to Retain Items") as int
endFunction

bool function IsAutoDressingEnabledOnRelease(string hold)
    return MCM.GetToggleOptionState(hold, "Release::Auto Re-Dress on Release")
endFunction

float function GetEscapedBountyFromCurrentArrest(string hold)
    return MCM.GetSliderOptionValue(hold, "Escape::Escape Bounty (%)")
endFunction

int function GetEscapedBountyFlat(string hold)
    return MCM.GetSliderOptionValue(hold, "Escape::Escape Bounty") as int
endFunction

bool function IsTimeServedAccountedForOnEscape(string hold)
    return MCM.GetToggleOptionState(hold, "Escape::Account for Time Served")
endFunction

bool function IsSurrenderEnabledOnEscape(string hold)
    return MCM.GetToggleOptionState(hold, "Escape::Allow Surrendering")
endFunction

bool function ShouldFriskOnEscape(string hold)
    return MCM.GetToggleOptionState(hold, "Escape::Frisk Search upon Captured")
endFunction

bool function ShouldStripOnEscape(string hold)
    return MCM.GetToggleOptionState(hold, "Escape::Strip Search upon Captured")
endFunction

float function GetChargeBountyForImpersonation(string hold)
    return MCM.GetSliderOptionValue(hold, "Additional Charges::Bounty for Impersonation")
endFunction

float function GetChargeBountyForEnemyOfHold(string hold)
    return MCM.GetSliderOptionValue(hold, "Additional Charges::Bounty for Enemy of Hold")
endFunction

float function GetChargeBountyForStolenItems(string hold)
    return MCM.GetSliderOptionValue(hold, "Additional Charges::Bounty for Stolen Items")
endFunction

float function GetChargeBountyForStolenItemFromItemValue(string hold)
    return MCM.GetSliderOptionValue(hold, "Additional Charges::Bounty for Stolen Item")
endFunction

float function GetChargeBountyForContraband(string hold)
    return MCM.GetSliderOptionValue(hold, "Additional Charges::Bounty for Contraband")
endFunction

float function GetChargeBountyForCellKey(string hold)
    return MCM.GetSliderOptionValue(hold, "Additional Charges::Bounty for Cell Key")
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
    return actorVars.GetInfamy(self.GetFaction(hold), Player)
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

bool function CanBeArrested(string hold)
    Faction crimeFaction = getFaction(hold)
    int holdBounty = crimeFaction.GetCrimeGold()

    if (!crimeFaction)
        return false
    endif

    int minBountyRequired = getArrestRequiredBounty(hold)

    if (holdBounty <= minBountyRequired)
        return false
    endif

    return true
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

Armor function GetActorEquippedClothingForBodyPart(Actor actorTarget, string bodyPart)
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
        Armor armorPieceSingleSlot = actorTarget.GetWornForm(currentSlotMask) as Armor
        if (armorPieceSingleSlot)
            return armorPieceSingleSlot
        endif

        Armor armorPieceMultipleSlots = actorTarget.GetWornForm(combinedSlotMask) as Armor
        if (armorPieceMultipleSlots)
            return armorPieceMultipleSlots
        endif
        
        i += 1
    endWhile

    return none
endFunction

function WearOutfitOnActor(Actor actorTarget, string outfitId, bool unequipAllItems = true)
    Armor bodyPartHead = MCM.GetOutfitPart(outfitId, "Head")
    Armor bodyPartBody = MCM.GetOutfitPart(outfitId, "Body")
    Armor bodyPartHands = MCM.GetOutfitPart(outfitId, "Hands")
    Armor bodyPartFeet = MCM.GetOutfitPart(outfitId, "Feet")

    string actorName = actorTarget.GetActorBase().GetName()

    if (unequipAllItems)
        actorTarget.UnequipAll()
    endif

    MCM.Debug("WearOutfit", "Test call for this outfit for " + actorName + ", body parts: ["+ bodyPartHead + ", " + bodyPartBody + ", " + bodyPartHands + ", " + bodyPartFeet +"]")

    if (bodyPartHead != none)
        actorTarget.EquipItem(bodyPartHead, false, abSilent = true)
        MCM.Debug("WearOutfit", "Equipped " + bodyPartHead.GetName() + " from " + outfitId + "::Head" + " on " + actorName)
    endif

    if (bodyPartBody != none)
        actorTarget.EquipItem(bodyPartBody, false, abSilent = true)
        MCM.Debug("WearOutfit", "Equipped " + bodyPartBody.GetName() + " from " + outfitId + "::Body" + " on " + actorName)
    endif
    
    if (bodyPartHands != none)
        actorTarget.EquipItem(bodyPartHands, false, abSilent = true)
        MCM.Debug("WearOutfit", "Equipped " + bodyPartHands.GetName() + " from " + outfitId + "::Hands" + " on " + actorName)
    endif

    if (bodyPartFeet != none)
        actorTarget.EquipItem(bodyPartFeet, false, abSilent = true)
        MCM.Debug("WearOutfit", "Equipped " + bodyPartFeet.GetName() + " from " + outfitId + "::Feet" + " on " + actorName)
    endif

endFunction

function AddOutfit(string outfitId, Armor headClothing, Armor bodyClothing, Armor handsClothing, Armor feetClothing)
    ; if body overrides head (shares slots, remove head, since body will take up its slot)
    if (bodyClothing == headClothing)
        headClothing = none
    endif

    ; Set each outfit part's name in the input fields for the outfit
    MCM.SetOptionInputValue(outfitId + "::Head", headClothing.GetName())
    MCM.SetOptionInputValue(outfitId + "::Body", bodyClothing.GetName())
    MCM.SetOptionInputValue(outfitId + "::Hands", handsClothing.GetName())
    MCM.SetOptionInputValue(outfitId + "::Feet", feetClothing.GetName())

    ; Add each clothing piece to this outfit (store persistently into the outfit list)
    MCM.AddOutfitPiece(outfitId, "Head", headClothing)
    MCM.AddOutfitPiece(outfitId, "Body", bodyClothing)
    MCM.AddOutfitPiece(outfitId, "Hands", handsClothing)
    MCM.AddOutfitPiece(outfitId, "Feet", feetClothing)

    MCM.Trace("AddOutfit", "headClothing: " + headClothing + ", bodyClothing: " + bodyClothing + ", handsClothing: " + handsClothing + ", feetClothing: " + feetClothing)
    MCM.Trace("AddOutfit", "Slot Masks [headClothing: " + headClothing.GetSlotMask() + ", bodyClothing: " + bodyClothing.GetSlotMask() + ", handsClothing: " + handsClothing.GetSlotMask() + ", feetClothing: " + feetClothing.GetSlotMask() + "]")
endFunction

Armor function GetOutfitPart(string hold, string bodyPart)
    string holdOutfit = GetClothingOutfit(hold)
    return MCM.GetOutfitPart("Outfit 6", bodyPart)
endFunction

; Player function aliases for param Actor

Armor function GetEquippedClothingForBodyPart(string bodyPart)
    return GetActorEquippedClothingForBodyPart(Player, bodyPart)
endFunction

function WearOutfit(string outfitName, bool unequipAllItems = true)
    WearOutfitOnActor(Player, outfitName, unequipAllItems)
endFunction

bool function Debug_OutfitMeetsCondition(Faction crimeFaction, string outfitId)
    int bounty = crimeFaction.GetCrimeGold()
    int outfitMinimumBounty = MCM.GetSliderOptionValue("Clothing", outfitId + "::Minimum Bounty") as int
    int outfitMaximumBounty = MCM.GetSliderOptionValue("Clothing", outfitId + "::Maximum Bounty") as int

    bool onlyMinBountyRequired = outfitMinimumBounty == outfitMaximumBounty && bounty >= outfitMinimumBounty
    bool isBountyWithinRange = IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)
    bool hasCondition = MCM.GetToggleOptionState("Clothing", outfitId + "::Conditional Outfit") as bool
    bool meetsCondition = !hasCondition || isBountyWithinRange && !onlyMinBountyRequired || onlyMinBountyRequired

    MCM.Debug("Debug_OutfitMeetsCondition", "Bounty for " + crimeFaction.GetName() + ": " + bounty)
    MCM.Debug("Debug_OutfitMeetsCondition", outfitId + " [Minimum Bounty: " + outfitMinimumBounty + ", Maximum Bounty: " + outfitMaximumBounty + "] ("+ "isBountyWithinRange: " + isBountyWithinRange + ", hasCondition: "+ hasCondition +") (meets condition: " + meetsCondition + ")")

    return meetsCondition
endFunction

; bool function Debug_OutfitMeetsCondition(Faction crimeFaction, string outfitId)
;     int bounty = crimeFaction.GetCrimeGold()
;     int outfitMinimumBounty = GetOutfitMinimumBounty(outfitId)
;     int outfitMaximumBounty = GetOutfitMaximumBounty(outfitId)

;     bool hasMinBounty = outfitMinimumBounty > 0
;     bool hasMaxBounty = outfitMaximumBounty > 0

;     bool isBountyRange = hasMinBounty && hasMaxBounty
;     bool isSingleBounty = hasMinBounty && !hasMaxBounty

;     bool isBountyWithinRange = !isSingleBounty && isBountyRange && IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)

;     bool hasCondition = MCM.GetToggleOptionState("Clothing", outfitId + "::Conditional Outfit") as bool
;     bool meetsCondition = !hasCondition || (isSingleBounty && bounty >= outfitMinimumBounty) || isBountyWithinRange

;     MCM.Debug("Debug_OutfitMeetsCondition", "Bounty for " + crimeFaction.GetName() + ": " + bounty)
;     MCM.Debug("Debug_OutfitMeetsCondition", outfitId + " [Minimum Bounty: " + outfitMinimumBounty + ", Maximum Bounty: " + outfitMaximumBounty + "] ("+ "isBountyWithinRange: " + isBountyWithinRange + ", hasCondition: "+ hasCondition +") (meets condition: " + meetsCondition + ")")

;     return meetsCondition
; endFunction

bool function OutfitMeetsCondition(Faction crimeFaction, string outfitId)
    bool hasCondition = MCM.GetToggleOptionState("Clothing", outfitId + "::Conditional Outfit") as bool

    if (!hasCondition)
        return true
    endif

    int bounty = crimeFaction.GetCrimeGold()
    int outfitMinimumBounty = MCM.GetSliderOptionValue("Clothing", outfitId + "::Minimum Bounty") as int
    int outfitMaximumBounty = MCM.GetSliderOptionValue("Clothing", outfitId + "::Maximum Bounty") as int

    bool isBountyWithinRange = IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)
    bool meetsCondition = !hasCondition || isBountyWithinRange

    return meetsCondition
endFunction

