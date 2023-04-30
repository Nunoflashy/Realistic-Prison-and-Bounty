Scriptname RealisticPrisonAndBounty_Config extends Quest

import RealisticPrisonAndBounty_Util
import PO3_SKSEFunctions
import Math

float function GetVersion() global
    return 1.00
endFunction

string function GetPluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

Form function GetFormFromMod(int formId) global
    return Game.GetFormFromFile(formId, GetPluginName())
endFunction

RealisticPrisonAndBounty_MCM property mcm
    RealisticPrisonAndBounty_MCM function get()
        return Game.GetFormFromFile(0x0D61, GetPluginName()) as RealisticPrisonAndBounty_MCM
    endFunction
endProperty

string[] property Holds
    string[] function get()
        int _holds = JArray.object()

        if (JArray.count(_holds) == 0)
            JArray.addStr(_holds, "Whiterun")
            JArray.addStr(_holds, "Winterhold")
            JArray.addStr(_holds, "Eastmarch")
            JArray.addStr(_holds, "Falkreath")
            JArray.addStr(_holds, "Haafingar")
            JArray.addStr(_holds, "Hjaalmarch")
            JArray.addStr(_holds, "The Rift")
            JArray.addStr(_holds, "The Reach")
            JArray.addStr(_holds, "The Pale")
        endif

        return JArray.asStringArray(_holds)
    endFunction
endProperty

Actor property Player
    Actor function get()
        return Game.GetForm(0x00014) as Actor
    endFunction
endProperty

int _arrestVars
function SetArrestVarBool(string varName, bool value)
    JMap.setInt(_arrestVars, varName, value as int)
endFunction

function SetArrestVarFloat(string varName, float value)
    JMap.setFlt(_arrestVars, varName, value)
endFunction

function SetArrestVarString(string varName, string value)
    JMap.setStr(_arrestVars, varName, value)
endFunction

function SetArrestVarForm(string varName, Form value)
    JMap.setForm(_arrestVars, varName, value)
endFunction

bool function GetArrestVarBool(string varName)
    return JMap.getInt(_arrestVars, varName) as bool
endFunction

float function GetArrestVarFloat(string varName)
    return JMap.getFlt(_arrestVars, varName)
endFunction

string function GetArrestVarString(string varName)
    return JMap.getStr(_arrestVars, varName)
endFunction

Form function GetArrestVarForm(string varName)
    return JMap.getForm(_arrestVars, varName)
endFunction

function ResetArrestVars()
    JMap.clear(_arrestVars)
endFunction

bool property IsArrested
    bool function get()
        return JMap.hasKey(_arrestVars, "Arrest::Arrested") && JMap.getInt(_arrestVars, "Arrest::Arrested") == 1
    endFunction
endProperty

bool property IsJailed
    bool function get()
        return JMap.hasKey(_arrestVars, "Jail::Jailed") && JMap.getInt(_arrestVars, "Jail::Jailed") == 1
    endFunction
endProperty

ObjectReference property JailCell
    ObjectReference function get()
        return form_if (IsArrested && JMap.hasKey(_arrestVars, "Jail::Cell"), JMap.getForm(_arrestVars, "Jail::Cell"), none) as ObjectReference
    endFunction
endProperty

int property MinimumSentence
    int function get()
        return int_if (JMap.hasKey(_arrestVars, "Jail::Minimum Sentence"), JMap.getInt(_arrestVars, "Jail::Minimum Sentence"), -1)
    endFunction
endProperty

int property MaximumSentence
    int function get()
        return int_if (JMap.hasKey(_arrestVars, "Jail::Maximum Sentence"), JMap.getInt(_arrestVars, "Jail::Maximum Sentence"), -1)
    endFunction
endProperty

int property Sentence
    int function get()
        return int_if (JMap.hasKey(_arrestVars, "Jail::Sentence"), JMap.getInt(_arrestVars, "Jail::Sentence"), -1)
    endFunction
endProperty

bool property InfamyEnabled
    bool function get()
        return bool_if (JMap.hasKey(_arrestVars, "Jail::Infamy Enabled"), JMap.getInt(_arrestVars, "Jail::Infamy Enabled")) as bool
    endFunction
endProperty

; Map with all variables needed to process the player when in jail
int jailVars
; __setJailVar("hold", "Haafingar")
; __setJailVar("", 1)
; __setJailVar("jailCellIndex", 1)
; __setJailVar("minSentence", 40)
; __setJailVar("maxSentence", 200)
; __setJailVar("arrestBounty", 6000)
; __setJailVar("sentence", 40)

int factionMap
function __initializeFactionsMapping()
    factionMap = JMap.object()
    JValue.retain(factionMap)

    JMap.setForm(factionMap, "Whiterun",    Game.GetForm(0x000267EA))
    JMap.setForm(factionMap, "Winterhold",  Game.GetForm(0x0002816F))
    JMap.setForm(factionMap, "Eastmarch",   Game.GetForm(0x000267E3))
    JMap.setForm(factionMap, "Falkreath",   Game.GetForm(0x00028170))
    JMap.setForm(factionMap, "Haafingar",   Game.GetForm(0x00029DB0))
    JMap.setForm(factionMap, "Hjaalmarch",  Game.GetForm(0x0002816D))
    JMap.setForm(factionMap, "The Rift",    Game.GetForm(0x0002816B))
    JMap.setForm(factionMap, "The Reach",   Game.GetForm(0x0002816C))
    JMap.setForm(factionMap, "The Pale",    Game.GetForm(0x0002816E))

    ; TODO: Possibly load more factions from a file (custom factions and holds?)

    mcm.Debug("InitializeFactions", "Factions were initialized.")
endFunction

function __initializeArrestVars()
    _arrestVars = JMap.object()
    JValue.retain(_arrestVars)
endFunction

int jailMarkersMap
function __initializeJailMarkersMapping()
    jailMarkersMap = JMap.object()
    JValue.retain(jailMarkersMap)

    int whiterunMarkers = JArray.object()
    JArray.addForm(whiterunMarkers, GetFormFromMod(0x3885)) ; Jail Cell 01
    JArray.addForm(whiterunMarkers, GetFormFromMod(0x3886)) ; Jail Cell 02
    JArray.addForm(whiterunMarkers, GetFormFromMod(0x3887)) ; Jail Cell 03
    JArray.addForm(whiterunMarkers, GetFormFromMod(0x3888)) ; Jail Cell 04 (Alik'r Cell)

    ; missing Winterhold markers

    int windhelmMarkers = JArray.object()
    JArray.addForm(windhelmMarkers, Game.GetForm(0x58CF8)) ; Jail Cell 01
    JArray.addForm(windhelmMarkers, GetFormFromMod(0x388A)) ; Jail Cell 02
    JArray.addForm(windhelmMarkers, GetFormFromMod(0x388B)) ; Jail Cell 03
    JArray.addForm(windhelmMarkers, GetFormFromMod(0x388C)) ; Jail Cell 04

    int falkreathMarkers = JArray.object()
    JArray.addForm(falkreathMarkers, Game.GetForm(0x3EF07)) ; Jail Cell 01

    int solitudeMarkers = JArray.object()
    JArray.addForm(solitudeMarkers, Game.GetForm(0x36897)) ; Jail Cell 01 (Original)
    JArray.addForm(solitudeMarkers, GetFormFromMod(0x3880)) ; Jail Cell 02
    JArray.addForm(solitudeMarkers, GetFormFromMod(0x3879)) ; Jail Cell 03
    JArray.addForm(solitudeMarkers, GetFormFromMod(0x3881)) ; Jail Cell 04
    JArray.addForm(solitudeMarkers, GetFormFromMod(0x3882)) ; Jail Cell 05
    JArray.addForm(solitudeMarkers, GetFormFromMod(0x3883)) ; Jail Cell 06
    JArray.addForm(solitudeMarkers, GetFormFromMod(0x3884)) ; Jail Cell 07 (Bjartur Cell)

    int morthalMarkers = JArray.object()
    JArray.addForm(morthalMarkers, Game.GetForm(0x3EF08)) ; Jail Cell 01

    ; missing The Reach markers (Markarth)

    int riftenMarkers = JArray.object()
    JArray.addForm(riftenMarkers, Game.GetForm(0x6128D)) ; Jail Cell 01 (Original)
    JArray.addForm(riftenMarkers, GetFormFromMod(0x388D)) ; Jail Cell 02
    JArray.addForm(riftenMarkers, GetFormFromMod(0x388E)) ; Jail Cell 03
    ; JArray.addForm(riftenMarkers, GetFormFromMod(0x388F)) ; Jail Cell 04 (Sibbi's Cell [RESERVED])
    JArray.addForm(riftenMarkers, GetFormFromMod(0x3890)) ; Jail Cell 05
    JArray.addForm(riftenMarkers, GetFormFromMod(0x3893)) ; Jail Cell 06
    JArray.addForm(riftenMarkers, GetFormFromMod(0x3894)) ; Jail Cell 07
    JArray.addForm(riftenMarkers, GetFormFromMod(0x3895)) ; Jail Cell 08

    int dawnstarMarkers = JArray.object()
    JArray.addForm(dawnstarMarkers, GetFormFromMod(0x3896)) ; Jail Cell 01

    JMap.setObj(jailMarkersMap, "Whiterun", whiterunMarkers)
    ; JMap.setObj(jailMarkersMap, "Winterhold", solitudeMarkers)
    JMap.setObj(jailMarkersMap, "Eastmarch", windhelmMarkers)
    JMap.setObj(jailMarkersMap, "Falkreath", falkreathMarkers)
    JMap.setObj(jailMarkersMap, "Haafingar", solitudeMarkers)
    JMap.setObj(jailMarkersMap, "Hjaalmarch", morthalMarkers)
    JMap.setObj(jailMarkersMap, "The Rift", riftenMarkers)
    ; JMap.setObj(jailMarkersMap, "The Reach", solitudeMarkers)
    JMap.setObj(jailMarkersMap, "The Pale", dawnstarMarkers)
endFunction

int locationsToHoldMap
function __initializeLocationsMapping()
    locationsToHoldMap = JMap.object()
    JValue.retain(locationsToHoldMap)

    int whiterunLocations = JArray.object() ; Whiterun
    JArray.addForm(whiterunLocations, Game.GetForm(0x00018A56)) ; WhiterunLocation
    JArray.addForm(whiterunLocations, Game.GetForm(0x00016772)) ; WhiterunHoldLocation

    int winterholdLocations = JArray.object() ; Winterhold
    JArray.addForm(winterholdLocations, Game.GetForm(0x00018A51)) ; WinterholdLocation
    JArray.addForm(winterholdLocations, Game.GetForm(0x0001676B)) ; WinterholdHoldLocation

    int eastmarchLocations = JArray.object() ; Windhelm
    JArray.addForm(eastmarchLocations, Game.GetForm(0x00018A57)) ; WindhelmLocation
    JArray.addForm(eastmarchLocations, Game.GetForm(0x0001676A)) ; EastmarchHoldLocation

    int falkreathLocations = JArray.object() ; Falkreath
    JArray.addForm(falkreathLocations, Game.GetForm(0x00018A49)) ; FalkreathLocation
    JArray.addForm(falkreathLocations, Game.GetForm(0x0001676F)) ; FalkreathHoldLocation

    int haafingarLocations = JArray.object() ; Solitude
    JArray.addForm(haafingarLocations, Game.GetForm(0x00018A5A)) ; SolitudeLocation
    JArray.addForm(haafingarLocations, Game.GetForm(0x00016770)) ; HaafingarHoldLocation

    int hjaalmarchLocations = JArray.object() ; Morthal
    JArray.addForm(hjaalmarchLocations, Game.GetForm(0x00018A53)) ; MorthalLocation
    JArray.addForm(hjaalmarchLocations, Game.GetForm(0x0001676E)) ; HjaalmarchHoldLocation

    int riftLocations = JArray.object() ; Riften
    JArray.addForm(riftLocations, Game.GetForm(0x00018A58)) ; RiftenLocation
    JArray.addForm(riftLocations, Game.GetForm(0x0001676C)) ; RiftHoldLocation 

    int reachLocations = JArray.object() ; Markarth
    JArray.addForm(reachLocations, Game.GetForm(0x00018A59)) ; MarkarthLocation 
    JArray.addForm(reachLocations, Game.GetForm(0x00016769)) ; ReachHoldLocation 

    int paleLocations = JArray.object() ; Dawnstar
    JArray.addForm(paleLocations, Game.GetForm(0x00018A50)) ; DawnstarLocation 
    JArray.addForm(paleLocations, Game.GetForm(0x0001676D)) ; PaleHoldLocation

    JMap.setObj(locationsToHoldMap, "Whiterun", whiterunLocations)
    JMap.setObj(locationsToHoldMap, "Winterhold", winterholdLocations)
    JMap.setObj(locationsToHoldMap, "Eastmarch", eastmarchLocations)
    JMap.setObj(locationsToHoldMap, "Falkreath", falkreathLocations)
    JMap.setObj(locationsToHoldMap, "Haafingar", haafingarLocations)
    JMap.setObj(locationsToHoldMap, "Hjaalmarch", hjaalmarchLocations)
    JMap.setObj(locationsToHoldMap, "The Rift", riftLocations)
    JMap.setObj(locationsToHoldMap, "The Reach", reachLocations)
    JMap.setObj(locationsToHoldMap, "The Pale", paleLocations)
endFunction

bool function IsInLocationFromHold(string hold)
    if (!JMap.hasKey(locationsToHoldMap, hold))
        Warn(none, "IsInLocationFromHold", "Location does not exist for this hold.")
        return false
    endif

    int holdArray = JMap.getObj(locationsToHoldMap, hold) ; Form[]

    int i = 0
    while (i < JArray.count(holdArray))
        Location holdLocation = JArray.getForm(holdArray, i) as Location
        ; As soon as the player is in any location for this hold, return.
        if (Player.IsInLocation(holdLocation))
            Debug(none, "IsInLocationFromHold", "Player is in location: " + holdLocation.GetName() + " ("+ holdLocation.GetFormID() +")", mcm.IS_DEBUG)
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

int function GetHoldLocations(string hold)
    return JMap.getObj(locationsToHoldMap, hold) 
endFunction

bool function IsLocationFromHold(string hold, Location loc)
    int holdLocations = getHoldLocations(hold)
    
    int i = 0
    while (i < JArray.count(holdLocations))
        Location iterLoc = JArray.getForm(holdLocations, i) as Location
        if (iterLoc == loc)
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

string function GetCurrentPlayerHoldLocation()
    int holdIndex = 0
    while (holdIndex < Holds.Length)
        int holdArray = JMap.getObj(locationsToHoldMap, Holds[holdIndex]) ; Form[]

        int locationIndex = 0
        while (locationIndex < JArray.count(holdArray))
            Location holdLocation = JArray.getForm(holdArray, locationIndex) as Location
            if (Player.IsInLocation(holdLocation))
                Debug(none, "IsInLocationFromHold", "Player is currently in hold: " + Holds[holdIndex])
                return Holds[holdIndex]
            endif
            locationIndex += 1
        endWhile

        holdIndex += 1
    endWhile

    return ""
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

Form[] function GetJailMarkers(string hold)
    if (!JMap.hasKey(jailMarkersMap, hold))
        mcm.Error("Config::getJailMakers", "The marker does not exist!")
        return none
    endif

    int holdJailMarkerArray = JMap.getObj(jailMarkersMap, hold)
    return JArray.asFormArray(holdJailMarkerArray)
endFunction

; To be refactored into the Jail or Imprisoned script
ObjectReference function GetRandomJailMarker(string hold)
    Form[] markers = GetJailMarkers(hold)
    if (!markers)
        mcm.Error("Config::getJailMakers", "The markers do not exist!")
        return none
    endif

    int len = markers.length
    int markerIndex = Utility.RandomInt(0, len - 1)

    ; mcm.Debug("Config::getRandomJailMarker", "Got the " + markerIndex + " marker for " + hold + "!")
    mcm.Debug("Config::GetRandomJailMarker", "Got Jail Cell " + (markerIndex + 1) + " (" + markers[markerIndex] + " [Index: "+ markerIndex +"]) marker for " + hold + "!")
    return markers[markerIndex] as ObjectReference
endFunction

Faction function GetFaction(string hold)
    if (JMap.hasKey(factionMap, hold))
        return JMap.getForm(factionMap, hold) as Faction
    endif

    return none
endFunction

event OnInit()
    __initializeFactionsMapping()
    __initializeJailMarkersMapping()
    __initializeLocationsMapping()
    __initializeArrestVars()

    RegisterForKey(0x58) ; F12

    RegisterForModEvent("PlayerArrestBegin", "OnPlayerBeginArrest")
    mcm.Debug("OnInit", "Config::Init Script")
endEvent

event OnKeyDown(int keyCode)
    if (keyCode == 0x58)
        SendModEvent("PlayerArrestBegin")
        IncrementInfamy("The Rift", 3000)
        ; int playerItemsValue = 0
        ; int i = 0
        ; while (i < Player.GetNumItems())
        ;     Form item = Player.GetNthForm(i)
        ;     int itemCount = Player.GetItemCount(item)
        ;     playerItemsValue += item.GetGoldValue() * itemCount
        ;     Debug(self, "OnKeyDown", "Item: " + item.GetName() + ", Value: " + item.GetGoldValue() + ", Count: " + itemCount)
        ;     i += 1
        ; endWhile
        ; int bountyChargeStolenItems = getAdditionalCharge("The Rift", "Bounty for Stolen Items") as int
        ; float bountyChargePerItem = ToPercent(getAdditionalCharge("The Rift", "Bounty for Stolen Item"))
        ; int bountyToAdd = floor((playerItemsValue * bountyChargePerItem) + bountyChargeStolenItems)
        ; Debug(self, "OnKeyDown", "playerItemsValue * bountyChargePerItem: " + playerItemsValue * bountyChargePerItem + ", Player Items: " + Player.GetNumItems())
        ; Debug(self, "OnKeyDown", "Bounty Charge Stolen Items: " + bountyChargeStolenItems + ", Bounty Charge Per Item: " + bountyChargePerItem + ", Total Charge: " + bountyToAdd)

        ; notifyBounty("The Rift", bountyToAdd)
    endif

    Debug(self, "OnKeyDown", "Key Pressed: " + keyCode)
endEvent

string function GetGlobalEquivalentOfLocalStat(string localStat)
    int localToGlobalMap = JMap.object()

    JMap.setStr(localToGlobalMap, "Largest Bounty", "Largest Bounty")
    ; JMap.setStr(localToGlobalMap, "Total Bounty", "Total Lifetime Bounty")
    JMap.setStr(localToGlobalMap, "Days in Jail", "Days Jailed")
    JMap.setStr(localToGlobalMap, "Times Jailed", "Times Jailed")
    JMap.setStr(localToGlobalMap, "Times Escaped", "Jail Escapes")

    if (!JMap.hasKey(localToGlobalMap, localStat))
        Error(self, "GetGlobalEquivalentOfLocalStat", "Call failed because the stat: " + localStat + " does not exist globally!")
        return none
    endif

    return JMap.getStr(localToGlobalMap, localStat)
endFunction

function SetStat(string hold, string stat, int value)
    string _key = hold + "::" + stat ; e.g: The Rift::Current Bounty
    mcm.SetOptionStatValue(_key, value)

    ; if (includeGlobalStat)
    ;     string globalEquivalent = GetGlobalEquivalentOfLocalStat(stat)
    ;     if (globalEquivalent)
    ;         int globalStatValue = Game.QueryStat(globalEquivalent)
    ;         Game.IncrementStat(globalEquivalent, -globalStatValue) ; Set the stat to 0
    ;         Game.IncrementStat(globalEquivalent, value) ; Change to new value
    ;     endif
    ; endif
endFunction

function IncrementStat(string hold, string stat, int incrementBy = 1)
    string _key = hold + "::" + stat ; e.g: The Rift::Infamy Gained
    int currentValue    = mcm.GetStatOptionValue("Stats", _key)
    int newValue        = Max(0, currentValue + incrementBy) as int
    
    mcm.SetOptionStatValue(_key, newValue)

    ; if (includeGlobalStat)
    ;     string globalEquivalent = GetGlobalEquivalentOfLocalStat(stat)
    ;     if (globalEquivalent)
    ;         Game.IncrementStat(globalEquivalent, incrementBy)
    ;     endif
    ; endif
endFunction

function DecrementStat(string hold, string stat, int decrementBy = 1)
    IncrementStat(hold, stat, -decrementBy)
endFunction

int property FactionCount
    int function get()
        return JMap.count(factionMap)
    endFunction
endProperty

int property FreeTimescale
    int function get()
        return mcm.GetSliderOptionValue("General", "General::Timescale") as int
    endFunction
endProperty

int property JailedTimescale
    int function get()
        return mcm.GetSliderOptionValue("General", "General::TimescalePrison") as int
    endFunction
endProperty

float property BountyDecayUpdateInterval
    float function get()
        return mcm.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)")
    endFunction
endProperty

float property InfamyDecayUpdateInterval
    float function get()
        return mcm.GetSliderOptionValue("General", "General::Infamy Decay (Update Interval)")
    endFunction
endProperty

bool property ShouldDisplayArrestNotifications
    bool function get()
        return mcm.GetToggleOptionState("General", "General::ArrestNotifications")
    endFunction
endProperty

bool property ShouldDisplayJailNotifications
    bool function get()
        return mcm.GetToggleOptionState("General", "General::JailedNotifications")
    endFunction
endProperty

bool property ShouldDisplayBountyDecayNotifications
    bool function get()
        return mcm.GetToggleOptionState("General", "General::BountyDecayNotifications")
    endFunction
endProperty

bool property ShouldDisplayInfamyNotifications
    bool function get()
        return mcm.GetToggleOptionState("General", "General::InfamyNotifications")
    endFunction
endProperty

bool property HasNudeBodyModInstalled
    bool function get()
        return mcm.GetToggleOptionState("Clothing", "Configuration::NudeBodyModInstalled")
    endFunction
endProperty

bool property HasUnderwearBodyModInstalled
    bool function get()
        return mcm.GetToggleOptionState("Clothing", "Configuration::UnderwearModInstalled")
    endFunction
endProperty

; Temporary functions
function PrepareActorForJail(Actor akActor)
    ; Undress actor
    akActor.UnequipAll()

    AddOutfit("Outfit 1", none, Game.GetFormEx(0x3C9FE) as Armor, none, none)
    AddOutfit("Outfit 2", none, Game.GetFormEx(0x3C9FE) as Armor, none, Game.GetFormEx(0x3CA00) as Armor)
    WearOutfitOnActor(akActor, "Outfit 1")
endFunction

int function GetDelevelingStatValue(string statName)
    return mcm.GetSliderOptionValue("General", "Deleveling::" + statName) as int
endFunction

int function GetArrestRequiredBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Minimum Bounty to Arrest") as int
endFunction

int function GetArrestGuaranteedPayableBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Guaranteed Payable Bounty") as int
endFunction

int function GetArrestMaximumPayableBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Maximum Payable Bounty") as int
endFunction

int function GetArrestMaximumPayableChance(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Maximum Payable Bounty (Chance)") as int
endFunction

float function GetArrestAdditionalBountyResistingFromCurrentBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Resisting (%)")
endFunction

int function GetArrestAdditionalBountyResistingFlat(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Resisting") as int
endFunction

int function GetArrestAdditionalBountyResisting(string hold)
    float bountyPercentModifier = ToPercent(GetArrestAdditionalBountyResistingFromCurrentBounty(hold))
    int bountyFlat              = GetArrestAdditionalBountyResistingFlat(hold)
    Faction crimeFaction        = GetFaction(hold)
    int bounty                  = floor(crimeFaction.GetCrimeGold() * bountyPercentModifier) + bountyFlat

    return bounty
endFunction

float function GetArrestAdditionalBountyDefeatedFromCurrentBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Defeated (%)")
endFunction
 
int function GetArrestAdditionalBountyDefeatedFlat(string hold)
    return mcm.GetSliderOptionValue(hold, "Arrest::Additional Bounty when Defeated") as int
endFunction

int function GetArrestAdditionalBountyDefeated(string hold)
    float bountyPercentModifier = ToPercent(getArrestAdditionalBountyDefeatedFromCurrentBounty(hold))
    int bountyFlat              = GetArrestAdditionalBountyDefeatedFlat(hold)
    Faction crimeFaction        = GetFaction(hold)
    int bounty                  = floor(crimeFaction.GetCrimeGold() * bountyPercentModifier) + bountyFlat
    
    return bounty
endFunction

bool function IsFriskingEnabled(string hold)
    return mcm.GetToggleOptionState(hold, "Frisking::Allow Frisking")
endFunction

bool function IsFriskingUnconditional(string hold)
    return mcm.GetToggleOptionState(hold, "Frisking::Unconditional Frisking")
endFunction

int function GetFriskingBountyRequired(string hold)
    return mcm.GetSliderOptionValue(hold, "Frisking::Frisk Search Thoroughness") as int
endFunction

int function GetFriskingThoroughness(string hold)
    return mcm.GetSliderOptionValue(hold, "Frisking::Minimum Bounty for Frisking") as int
endFunction

bool function IsFriskingStolenItemsConfiscated(string hold)
    return mcm.GetToggleOptionState(hold, "Frisking::Confiscate Stolen Items")
endFunction

bool function IsFriskingStripSearchWhenStolenItemsFound(string hold)
    return mcm.GetToggleOptionState(hold, "Frisking::Strip Search if Stolen Items Found")
endFunction

int function GetFriskingStolenItemsRequiredForStripping(string hold)
    return mcm.GetSliderOptionValue(hold, "Frisking::Minimum No. of Stolen Items Required") as int
endFunction

bool function IsStrippingEnabled(string hold)
    return mcm.GetToggleOptionState(hold, "Stripping::Allow Stripping")
endFunction

string function GetStrippingHandlingCondition(string hold)
    return mcm.GetMenuOptionValue(hold, "Stripping::Handle Stripping On")
endFunction

bool function IsStrippingUnconditional(string hold)
    return mcm.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Unconditionally"
endFunction

bool function IsStrippingBasedOnSentence(string hold)
    return mcm.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Minimum Sentence"
endFunction

bool function IsStrippingBasedOnBounty(string hold)
    return mcm.GetMenuOptionValue(hold, "Stripping::Handle Stripping On") == "Minimum Bounty"
endFunction

int function GetStrippingMinimumSentence(string hold)
    return mcm.GetSliderOptionValue(hold, "Stripping::Minimum Sentence") as int
endFunction

int function GetStrippingMinimumBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Stripping::Minimum Bounty") as int
endFunction

int function GetStrippingMinimumViolentBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Stripping::Minimum Violent Bounty") as int
endFunction

bool function IsStrippedOnDefeat(string hold)
    return mcm.GetToggleOptionState(hold, "Stripping::Strip when Defeated")
endFunction

int function GetStrippingThoroughness(string hold)
    return mcm.GetSliderOptionValue(hold, "Stripping::Strip Search Thoroughness") as int
endFunction

bool function IsClothingEnabled(string hold)
    return mcm.GetToggleOptionState(hold, "Clothing::Allow Clothing")
endFunction

string function GetClothingHandlingCondition(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Handle Clothing On")
endFunction

bool function IsClothingUnconditional(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Handle Clothing On") == "Unconditionally"
endFunction

bool function IsClothingBasedOnSentence(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Handle Clothing On") == "Maximum Sentence"
endFunction

bool function IsClothingBasedOnBounty(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Handle Stripping On") == "Maximum Bounty"
endFunction

int function GetClothingMaximumSentence(string hold)
    return mcm.GetSliderOptionValue(hold, "Clothing::Maximum Sentence") as int
endFunction

int function GetClothingMaximumBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Clothing::Maximum Bounty") as int
endFunction

int function GetClothingMaximumViolentBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Clothing::Maximum Violent Bounty") as int
endFunction

bool function IsClothedOnDefeat(string hold)
    return mcm.GetToggleOptionState(hold, "Clothing::Clothe when Defeated")
endFunction

string function GetClothingOutfit(string hold)
    return mcm.GetMenuOptionValue(hold, "Clothing::Outfit")
endFunction

bool function IsClothingOutfitConditional(string hold)
    string holdOutfit = GetClothingOutfit(hold)
    return mcm.GetToggleOptionState("Clothing", holdOutfit + "::Conditional Outfit")
endFunction

int function GetClothingOutfitMinimumBounty(string hold)
    string holdOutfit = GetClothingOutfit(hold)
    return mcm.GetSliderOptionValue("Clothing", holdOutfit + "::Minimum Bounty") as int
endFunction

int function GetClothingOutfitMaximumBounty(string hold)
    string holdOutfit = GetClothingOutfit(hold)
    return mcm.GetSliderOptionValue("Clothing", holdOutfit + "::Maximum Bounty") as int
endFunction

bool function IsInfamyEnabled(string hold)
    return mcm.GetToggleOptionState(hold, "Infamy::Enable Infamy")
endFunction

float function GetInfamyGainedDailyFromArrestBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Infamy::Infamy Gained (%)")
endFunction

int function GetInfamyGainedDaily(string hold)
    return mcm.GetSliderOptionValue(hold, "Infamy::Infamy Gained") as int
endFunction

float function GetInfamyLostFromCurrentInfamy(string hold)
    return mcm.GetSliderOptionValue(hold, "Infamy::Infamy Lost (%)")
endFunction

int function GetInfamyLost(string hold)
    return mcm.GetSliderOptionValue(hold, "Infamy::Infamy Lost)") as int
endFunction

function IncrementInfamy(string hold, int incrementBy)
    int currentInfamy = GetInfamyGained(hold)
    string option = hold + "::Infamy Gained"
    mcm.SetOptionStatValue(option, currentInfamy + incrementBy)
    NotifyInfamy("You have gained " + incrementBy + " Infamy in " + hold)
endFunction

function DecrementInfamy(string hold, int decrementBy)
    int currentInfamy = GetInfamyGained(hold)
    string option = hold + "::Infamy Gained"
    mcm.SetOptionStatValue(option, currentInfamy - decrementBy)
endFunction

; TODO: Change how the stat is parsed
int function GetInfamyGained(string hold)
    return mcm.GetStatOptionValue("Stats", hold + "::Infamy Gained")
endFunction

int function GetStat(string hold, string stat)
    return mcm.GetStatOptionValue("Stats", hold + "::" + stat)
endFunction

int function QueryStat(string hold, string stat)
    return GetStat(hold, stat)
endFunction

bool function IsInfamyRecognized(string hold)
    return isInfamyEnabled(hold) && getInfamyGained(hold) >= getInfamyRecognizedThreshold(hold)
endFunction

bool function IsInfamyKnown(string hold)
    return isInfamyEnabled(hold) && getInfamyGained(hold) >= getInfamyKnownThreshold(hold)
endFunction

int function GetInfamyRecognizedThreshold(string hold)
    return mcm.GetSliderOptionValue(hold, "Infamy::Infamy Recognized Threshold") as int
endFunction

int function GetInfamyKnownThreshold(string hold)
    return mcm.GetSliderOptionValue(hold, "Infamy::Infamy Known Threshold") as int
endFunction

bool function IsBountyDecayEnabled(string hold)
    return mcm.GetToggleOptionState(hold, "Bounty Decaying::Enable Bounty Decaying")
endFunction

bool function IsBountyDecayableAsCriminal(string hold)
    return isBountyDecayEnabled(hold) && isInfamyEnabled(hold) && mcm.GetToggleOptionState(hold, "Bounty Decaying::Decay if Known as Criminal")
endFunction

float function GetBountyDecayLostFromCurrentBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Bounty Decaying::Bounty Lost (%)")
endFunction

int function GetBountyDecayLostBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Bounty Decaying::Bounty Lost") as int
endFunction

float function GetAdditionalCharge(string hold, string charge)
    return mcm.GetSliderOptionValue(hold, "Additional Charges::" + charge)
endFunction

bool function IsJailUnconditional(string hold)
    return mcm.GetToggleOptionState(hold, "Jail::Unconditional Imprisonment")
endFunction

int function GetJailGuaranteedPayableBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Guaranteed Payable Bounty") as int
endFunction

int function GetJailMaximumPayableBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Maximum Payable Bounty") as int
endFunction

int function GetJailMaximumPayableChance(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Maximum Payable Bounty (Chance)") as int
endFunction

int function GetJailBountyToSentence(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Bounty to Sentence") as int
endFunction

int function GetJailMinimumSentence(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Minimum Sentence") as int
endFunction

int function GetJailMaximumSentence(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Maximum Sentence") as int
endFunction

int function GetJailCellSearchThoroughness(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Cell Search Thoroughness") as int
endFunction

string function GetJailCellDoorLockLevel(string hold)
    return mcm.GetMenuOptionValue(hold, "Jail::Cell Lock Level")
endFunction

bool function IsJailFastForwardEnabled(string hold)
    return mcm.GetToggleOptionState(hold, "Jail::Fast Forward")
endFunction

int function GetJailFastForwardDay(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Day to fast forward from") as int
endFunction

string function GetJailHandleSkillLoss(string hold)
    return mcm.GetMenuOptionValue(hold, "Jail::Handle Skill Loss")
endFunction

int function GetJailDayToStartLosingSkills(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Day to Start Losing Skills") as int
endFunction

int function GetJailChanceToLoseSkillsDaily(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Chance to Lose Skills") as int
endFunction

float function GetJailRecognizedCriminalPenalty(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Recognized Criminal Penalty")
endFunction

float function GetJailKnownCriminalPenalty(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Known Criminal Penalty")
endFunction

int function GetJailBountyToTriggerCriminalPenalty(string hold)
    return mcm.GetSliderOptionValue(hold, "Jail::Minimum Bounty to Trigger") as int
endFunction

bool function IsJailReleaseFeesEnabled(string hold)
    return mcm.GetToggleOptionState(hold, "Release::Enable Release Fees")
endFunction

int function GetReleaseChanceForReleaseFeesEvent(string hold)
    return mcm.GetSliderOptionValue(hold, "Release::Chance for Event") as int
endFunction

int function GetReleaseBountyToOweFees(string hold)
    return mcm.GetSliderOptionValue(hold, "Release::Minimum Bounty to owe Fees") as int
endFunction

float function GetReleaseReleaseFeesFromBounty(string hold)
    return mcm.GetSliderOptionValue(hold, "Release::Release Fees (%)")
endFunction

int function GetReleaseReleaseFeesFlat(string hold)
    return mcm.GetSliderOptionValue(hold, "Release::Release Fees") as int
endFunction

int function GetReleaseDaysGivenToPayReleaseFees(string hold)
    return mcm.GetSliderOptionValue(hold, "Release::Days Given to Pay") as int
endFunction

bool function IsItemRetentionEnabledOnRelease(string hold)
    return mcm.GetToggleOptionState(hold, "Release::Enable Item Retention")
endFunction

int function GetReleaseBountyToRetainItems(string hold)
    return mcm.GetSliderOptionValue(hold, "Release::Minimum Bounty to Retain Items") as int
endFunction

bool function IsAutoDressingEnabledOnRelease(string hold)
    return mcm.GetToggleOptionState(hold, "Release::Auto Re-Dress on Release")
endFunction

float function GetEscapedBountyFromCurrentArrest(string hold)
    return mcm.GetSliderOptionValue(hold, "Escape::Escape Bounty (%)")
endFunction

int function GetEscapedBountyFlat(string hold)
    return mcm.GetSliderOptionValue(hold, "Escape::Escape Bounty") as int
endFunction

bool function IsSurrenderEnabledOnEscape(string hold)
    return mcm.GetToggleOptionState(hold, "Escape::Allow Surrendering")
endFunction

bool function ShouldFriskOnEscape(string hold)
    return mcm.GetToggleOptionState(hold, "Escape::Frisk Search upon Captured")
endFunction

bool function ShouldStripOnEscape(string hold)
    return mcm.GetToggleOptionState(hold, "Escape::Strip Search upon Captured")
endFunction

float function GetChargeBountyForImpersonation(string hold)
    return mcm.GetSliderOptionValue(hold, "Additional Charges::Bounty for Impersonation")
endFunction

float function GetChargeBountyForEnemyOfHold(string hold)
    return mcm.GetSliderOptionValue(hold, "Additional Charges::Bounty for Enemy of Hold")
endFunction

float function GetChargeBountyForStolenItems(string hold)
    return mcm.GetSliderOptionValue(hold, "Additional Charges::Bounty for Stolen Items")
endFunction

float function GetChargeBountyForStolenItemFromItemValue(string hold)
    return mcm.GetSliderOptionValue(hold, "Additional Charges::Bounty for Stolen Item")
endFunction

float function GetChargeBountyForContraband(string hold)
    return mcm.GetSliderOptionValue(hold, "Additional Charges::Bounty for Contraband")
endFunction

float function GetChargeBountyForCellKey(string hold)
    return mcm.GetSliderOptionValue(hold, "Additional Charges::Bounty for Cell Key")
endFunction

function RemoveKeys(ObjectReference akContainer = none)
    RemoveKeysFromActor(Player, akContainer)
endFunction

function RemoveWeapons(ObjectReference akContainer = none)
    RemoveWeaponsFromActor(Player, akContainer)
endFunction

bool function HasBountyInHold(string hold)
    Faction crimeFaction = GetFaction(hold)
    if (!crimeFaction)
        Error(self, "Config", "The faction does not exist. " + "(Hold: " + hold + ")")
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

function NotifyInfamyRecognizedThresholdMet(string hold, bool asNotification = false)
    if (ShouldDisplayInfamyNotifications && asNotification)
        debug.notification("You are now recognized as a criminal in " + hold)
        return
    endif

    debug.MessageBox("You are now recognized as a criminal in " + hold)
endFunction

function NotifyInfamyKnownThresholdMet(string hold, bool asNotification = false)
    if (ShouldDisplayInfamyNotifications && asNotification)
        debug.notification("You are now a known criminal in " + hold)
        return
    endif

    debug.MessageBox("You are now a known criminal in " + hold)
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

event OnPlayerBeginArrest(string eventName, string strArg, float numArg, Form sender)
    mcm.Debug("OnPlayerBeginArrest", "Begin Arrest Event")
endEvent

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
    Armor bodyPartHead = mcm.GetOutfitPart(outfitId, "Head")
    Armor bodyPartBody = mcm.GetOutfitPart(outfitId, "Body")
    Armor bodyPartHands = mcm.GetOutfitPart(outfitId, "Hands")
    Armor bodyPartFeet = mcm.GetOutfitPart(outfitId, "Feet")

    string actorName = actorTarget.GetActorBase().GetName()

    if (unequipAllItems)
        actorTarget.UnequipAll()
    endif

    mcm.Debug("WearOutfit", "Test call for this outfit for " + actorName + ", body parts: ["+ bodyPartHead + ", " + bodyPartBody + ", " + bodyPartHands + ", " + bodyPartFeet +"]")

    if (bodyPartHead != none)
        actorTarget.EquipItem(bodyPartHead, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartHead.GetName() + " from " + outfitId + "::Head" + " on " + actorName)
    endif

    if (bodyPartBody != none)
        actorTarget.EquipItem(bodyPartBody, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartBody.GetName() + " from " + outfitId + "::Body" + " on " + actorName)
    endif
    
    if (bodyPartHands != none)
        actorTarget.EquipItem(bodyPartHands, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartHands.GetName() + " from " + outfitId + "::Hands" + " on " + actorName)
    endif

    if (bodyPartFeet != none)
        actorTarget.EquipItem(bodyPartFeet, false, abSilent = true)
        mcm.Debug("WearOutfit", "Equipped " + bodyPartFeet.GetName() + " from " + outfitId + "::Feet" + " on " + actorName)
    endif

endFunction

function AddOutfit(string outfitId, Armor headClothing, Armor bodyClothing, Armor handsClothing, Armor feetClothing)
    ; if body overrides head (shares slots, remove head, since body will take up its slot)
    if (bodyClothing == headClothing)
        headClothing = none
    endif

    ; Set each outfit part's name in the input fields for the outfit
    mcm.SetOptionInputValue(outfitId + "::Head", headClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Body", bodyClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Hands", handsClothing.GetName())
    mcm.SetOptionInputValue(outfitId + "::Feet", feetClothing.GetName())

    ; Add each clothing piece to this outfit (store persistently into the outfit list)
    mcm.AddOutfitPiece(outfitId, "Head", headClothing)
    mcm.AddOutfitPiece(outfitId, "Body", bodyClothing)
    mcm.AddOutfitPiece(outfitId, "Hands", handsClothing)
    mcm.AddOutfitPiece(outfitId, "Feet", feetClothing)

    mcm.Trace("AddOutfit", "headClothing: " + headClothing + ", bodyClothing: " + bodyClothing + ", handsClothing: " + handsClothing + ", feetClothing: " + feetClothing)
    mcm.Trace("AddOutfit", "Slot Masks [headClothing: " + headClothing.GetSlotMask() + ", bodyClothing: " + bodyClothing.GetSlotMask() + ", handsClothing: " + handsClothing.GetSlotMask() + ", feetClothing: " + feetClothing.GetSlotMask() + "]")
endFunction

Armor function GetOutfitPart(string hold, string bodyPart)
    string holdOutfit = GetClothingOutfit(hold)
    return mcm.GetOutfitPart("Outfit 6", bodyPart)
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
    int outfitMinimumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Minimum Bounty") as int
    int outfitMaximumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Maximum Bounty") as int

    bool onlyMinBountyRequired = outfitMinimumBounty == outfitMaximumBounty && bounty >= outfitMinimumBounty
    bool isBountyWithinRange = IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)
    bool hasCondition = mcm.GetToggleOptionState("Clothing", outfitId + "::Conditional Outfit") as bool
    bool meetsCondition = !hasCondition || isBountyWithinRange && !onlyMinBountyRequired || onlyMinBountyRequired

    mcm.Debug("Debug_OutfitMeetsCondition", "Bounty for " + crimeFaction.GetName() + ": " + bounty)
    mcm.Debug("Debug_OutfitMeetsCondition", outfitId + " [Minimum Bounty: " + outfitMinimumBounty + ", Maximum Bounty: " + outfitMaximumBounty + "] ("+ "isBountyWithinRange: " + isBountyWithinRange + ", hasCondition: "+ hasCondition +") (meets condition: " + meetsCondition + ")")

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

;     bool hasCondition = mcm.GetToggleOptionState("Clothing", outfitId + "::Conditional Outfit") as bool
;     bool meetsCondition = !hasCondition || (isSingleBounty && bounty >= outfitMinimumBounty) || isBountyWithinRange

;     mcm.Debug("Debug_OutfitMeetsCondition", "Bounty for " + crimeFaction.GetName() + ": " + bounty)
;     mcm.Debug("Debug_OutfitMeetsCondition", outfitId + " [Minimum Bounty: " + outfitMinimumBounty + ", Maximum Bounty: " + outfitMaximumBounty + "] ("+ "isBountyWithinRange: " + isBountyWithinRange + ", hasCondition: "+ hasCondition +") (meets condition: " + meetsCondition + ")")

;     return meetsCondition
; endFunction

bool function OutfitMeetsCondition(Faction crimeFaction, string outfitId)
    bool hasCondition = mcm.GetToggleOptionState("Clothing", outfitId + "::Conditional Outfit") as bool

    if (!hasCondition)
        return true
    endif

    int bounty = crimeFaction.GetCrimeGold()
    int outfitMinimumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Minimum Bounty") as int
    int outfitMaximumBounty = mcm.GetSliderOptionValue("Clothing", outfitId + "::Maximum Bounty") as int

    bool isBountyWithinRange = IsWithin(bounty, outfitMinimumBounty, outfitMaximumBounty)
    bool meetsCondition = !hasCondition || isBountyWithinRange

    return meetsCondition
endFunction

