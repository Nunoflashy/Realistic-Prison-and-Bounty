Scriptname RealisticPrisonAndBounty_BountyDecay extends ReferenceAlias  

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import Math

int factionMap
int holdsArray
int locationsToHoldMap
int holdDecayTimers

int internalScriptUpdateTimer = 1

Actor property Player
    Actor function get()
        return Game.GetForm(0x00014) as Actor
    endFunction
endProperty

RealisticPrisonAndBounty_MCM property mcm
    RealisticPrisonAndBounty_MCM function get()
        return Game.GetFormFromFile(0x0D61, GetPluginName()) as RealisticPrisonAndBounty_MCM
    endFunction
endProperty

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

float property UpdateInterval
    float function get()
        return config.BountyDecayUpdateInterval
    endFunction
endProperty

event OnInit()
    __initializeFactionMapping()
    __initializeLocationsMapping()
    __initializeTimers()

    ; Register bounty decaying
    ; RegisterForSingleUpdateGameTime(internalScriptUpdateTimer)
    RegisterForBountyDecayingUpdate()

endEvent

event OnPlayerLoadGame()
endEvent

event OnUpdateGameTime()
    int i = 0
    while (i < FactionCount)
        string hold = GetHoldAt(i)

        ; Infamy conditions
        bool isDecayable  = (config.isBountyDecayableAsCriminal(hold) && !config.isInfamyKnown(hold)) || config.isBountyDecayEnabled(hold)

        if (isDecayable)
            float holdTimer = __getHoldDecayTimer(hold)

            Debug(none, "OnUpdateGameTime", "holdTimer (" + hold + "): " + holdTimer, mcm.IS_DEBUG)

            if (holdTimer == 0.0)
                ; Decay Bounty depending on conditions
                ; if not in hold and has bounty
                if (HasBounty(hold) && !IsInLocationFromHold(hold))
                    Debug(none, "OnUpdateGameTime", "Bounty detected and currently not in any of the hold's locations, begin bounty decay. (Hold: " + hold + ")", mcm.IS_DEBUG)
                    DecayForHold(hold)
                    ; reset timer
                    holdTimer = __resetHoldDecayTimer(hold)
                    Debug(none, "OnUpdateGameTime", "Resetting timer for " + hold + " ... (next update in: " + holdTimer + " hours)", mcm.IS_DEBUG)

                endif
            endif

            decrementHoldDecayTimer(hold, UpdateInterval)
            ; Debug(none, "OnUpdateGameTime", "Decrementing " + hold + "'s timer by " + internalScriptUpdateTimer + "...", mcm.IS_DEBUG)

            if (IsInLocationFromHold(hold))
                ; if in hold
                ; reset hold decay timer
                holdTimer = __resetHoldDecayTimer(hold)
                Debug(none, "OnUpdateGameTime", "You are in one of the hold's locations, hold timer for " + hold + " reset. (next update in: " + holdTimer + " hours)", mcm.IS_DEBUG)
            endif
        endif

        i += 1
    endWhile
    
    RegisterForBountyDecayingUpdate()
    ; RegisterForSingleUpdateGameTime(internalScriptUpdateTimer)
endEvent

event OnLocationChange(Location oldLocation, Location newLocation)
    int i = 0
    while (i < FactionCount)
        string hold = GetHoldAt(i)
        if (HasDecayingEnabled(hold))
            if (IsLocationFromHold(hold, newLocation) || IsLocationFromHold(hold, oldLocation))
                float holdTimer = __resetHoldDecayTimer(hold)
                Debug(none, "OnLocationChange", "Resetting timer for " + hold + " ... (next update in: " + holdTimer + " hours)", mcm.IS_DEBUG)
            endif
        endif
        i += 1
    endWhile
endEvent

; event OnLocationChange(Location oldLocation, Location newLocation)
;     ; Faction whiterunFaction     = GetFactionFromHold("Whiterun")
;     ; Faction winterholdFaction   = GetFactionFromHold("Winterhold")
;     ; Faction eastmarchFaction    = GetFactionFromHold("Eastmarch")
;     ; Faction falkreathFaction    = GetFactionFromHold("Falkreath")
;     ; Faction haafingarFaction    = GetFactionFromHold("Haafingar")
;     ; Faction hjaalmarchFaction   = GetFactionFromHold("Hjaalmarch")
;     ; Faction riftFaction         = GetFactionFromHold("The Rift")
;     ; Faction reachFaction        = GetFactionFromHold("The Reach")
;     ; Faction paleFaction         = GetFactionFromHold("The Pale")

;     int i = 0
;     while (i < FactionCount)
;         string hold = GetHoldAt(i)
;         if (HasBounty(hold))
;             Debug(none, "OnLocationChange", "Bounty detected for hold " + hold + ", should we reset decaying for this hold?", mcm.IS_DEBUG)
;             Location loc = JArray.getForm(GetHoldLocations(hold), i) as Location
;             if (newLocation == loc && !IsLocationFromHold(hold, oldLocation))
;                 ResetDecayForHold(hold)
;             else
;                 Debug(none, "OnLocationChange", "Bounty detected but we are not in any of the hold's locations, proceed normally with decay...", mcm.IS_DEBUG)
;             endif
;         endif
;         i += 1
;     endWhile
; endEvent

bool function IsLocationFromHold(string hold, Location loc)
    int holdLocations = GetHoldLocations(hold)
    int i = 0
    while (i < JArray.count(holdLocations))
        Location holdLocation = JArray.getForm(holdLocations, i) as Location
        if (holdLocation == loc)
            return true
        endif
        i += 1
    endWhile

    return false
endFunction


function RegisterForBountyDecayingUpdate()
    float bountyUpdateInterval = mcm.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)")
    RegisterForSingleUpdateGameTime(bountyUpdateInterval)
endFunction

; function RegisterForBountyDecayingUpdate()
;     int i = 0
;     while (i < FactionCount)
;         string hold = GetHoldAt(i)
;         if (HasDecayingEnabled(hold))
;             if (HasBounty(hold) && !IsInLocationFromHold(hold);/ && !IsNearGuards(hold)/;)
;                 DecayForHold(hold)
;             else
;                 ; Debug(none, "RegisterForBountyDecayingUpdate", "Player is in or near hold " + hold + " or has no bounty in said hold, no bounty decayed.", mcm.IS_DEBUG)
;             endif
;         endif
;         i += 1
;     endWhile

;     float bountyUpdateInterval = mcm.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)")
;     RegisterForSingleUpdateGameTime(bountyUpdateInterval)
;     Debug(none, "RegisterForBountyDecayingUpdate", "Bounty Update Interval: " + bountyUpdateInterval, mcm.IS_DEBUG)
; endFunction

bool function IsInLocationFromHold(string hold)
    if (!JMap.hasKey(locationsToHoldMap, hold))
        Warn(self.GetOwningQuest(), "IsInLocationFromHold", "Location does not exist for this hold.")
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

    Debug(self.GetOwningQuest(), "IsInLocationFromHold", "Player is not in any location related to " + hold, mcm.IS_DEBUG)
    return false
endFunction

int function GetHoldLocations(string hold)
    int locations = JMap.getObj(locationsToHoldMap, hold)
    return locations
endFunction

bool function HasDecayingEnabled(string hold)
    return mcm.GetToggleOptionValue(hold, "Bounty Decaying::Enable Bounty Decaying")
endFunction

bool function HasBounty(string hold)
    Faction crimeFaction = GetFactionFromHold(hold)
    return crimeFaction.GetCrimeGold() > 0
endFunction

function DecayForHold(string hold)
    Faction crimeFaction = GetFactionFromHold(hold)
    int currentBounty = crimeFaction.GetCrimeGold()
    float bountyLostPercent = mcm.GetSliderOptionValue(hold, "Bounty Decaying::Bounty Lost (%)") / 100
    int bountyLost = mcm.GetSliderOptionValue(hold, "Bounty Decaying::Bounty Lost") as int
    int decayTo = currentBounty - bountyLost - int_if(bountyLostPercent > 0, floor(currentBounty * bountyLostPercent))
    crimeFaction.SetCrimeGold(decayTo)
    Debug(none, "BountyDecay::DecayForHold", "Decaying Bounty for " + hold + ": Old Bounty = " + currentBounty + ", New Bounty: " + decayTo + ", Bounty Lost = " + floor((bountyLost + (currentBounty * bountyLostPercent))) + " (% = " + (bountyLostPercent * 100) + ", Flat = " + bountyLost + ")")
endFunction

function __initializeFactionMapping()
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

    holdsArray = JArray.object()
    JValue.retain(holdsArray)

    JArray.addStr(holdsArray, "Whiterun")
    JArray.addStr(holdsArray, "Winterhold")
    JArray.addStr(holdsArray, "Eastmarch")
    JArray.addStr(holdsArray, "Falkreath")
    JArray.addStr(holdsArray, "Haafingar")
    JArray.addStr(holdsArray, "Hjaalmarch")
    JArray.addStr(holdsArray, "The Rift")
    JArray.addStr(holdsArray, "The Reach")
    JArray.addStr(holdsArray, "The Pale")
endFunction

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

function __initializeTimers()
    holdDecayTimers = JMap.object()
    JValue.retain(holdDecayTimers)

    float bountyUpdateInterval = mcm.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)")

    int i = 0
    while (i < FactionCount)
        string hold = GetHoldAt(i)
        JMap.setFlt(holdDecayTimers, hold, bountyUpdateInterval)
        Debug(none, "__initializeTimers", "Initializing " + hold + " timer to " + bountyUpdateInterval, mcm.IS_DEBUG)
        Debug(none, "__initializeTimers", "__getHoldDecayTimer(" + hold + ") =  " + __getHoldDecayTimer(hold), mcm.IS_DEBUG)
        i += 1
    endWhile

endFunction

function __setHoldDecayTimer(string hold, float value)
    if (JMap.hasKey(holdDecayTimers, hold))
        JMap.setFlt(holdDecayTimers, hold, value)
    endif
    ; warn no timer set
endFunction

float function decrementHoldDecayTimer(string hold, float decrementBy = 1.0)
    if (JMap.hasKey(holdDecayTimers, hold))
        float decayTimer = __getHoldDecayTimer(hold)
        JMap.setFlt(holdDecayTimers, hold, Max(0.0, decayTimer - decrementBy))
        ; JMap.setFlt(holdDecayTimers, hold, decayTimer - Max(0.0, decrementBy))

        return decayTimer - Max(0.0, decrementBy)
    endif
endFunction

float function incrementHoldDecayTimer(string hold, float incrementBy = 1.0)
    if (JMap.hasKey(holdDecayTimers, hold))
        float decayTimer = __getHoldDecayTimer(hold)
        JMap.setFlt(holdDecayTimers, hold, decayTimer + Max(0.0, incrementBy))

        return decayTimer + Max(0.0, incrementBy)
    endif
endFunction

float function __getHoldDecayTimer(string hold)
    if (JMap.hasKey(holdDecayTimers, hold))
        return JMap.getFlt(holdDecayTimers, hold)
    endif
endFunction

float function __resetHoldDecayTimer(string hold)
    if (JMap.hasKey(holdDecayTimers, hold))
        float bountyUpdateInterval = mcm.GetSliderOptionValue("General", "General::Bounty Decay (Update Interval)")
        JMap.setFlt(holdDecayTimers, hold, bountyUpdateInterval)

        return bountyUpdateInterval
    endif
endFunction

int property FactionCount
    int function get()
        return JMap.count(factionMap)
    endFunction
endProperty

string function GetHoldAt(int index)
    return JArray.getStr(holdsArray, index)
endFunction

Faction function GetFactionFromHold(string hold)
    if (JMap.hasKey(factionMap, hold))
        return JMap.getForm(factionMap, hold) as Faction
    endif

    return none
endFunction