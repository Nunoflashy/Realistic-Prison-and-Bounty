scriptname RPB_BountyDecayable extends RPB_ActorScript
{
    Bounty Decay script: An Actor that has this script attached to them
    has the bounty decay functionality enabled to them and is considered a BountyDecayable.

    Additionally, if the Actor is registered as a RPB_Actor, this script's state
    can be retrieved by calling GetScriptState(RPB_BountyDecayable.className()) on the Actor.
}

import Math
import RPB_Memory
import RPB_Utility

; ==========================================================
;                           Class
; ==========================================================

string function className() global
    return "RPB_BountyDecayable"
endFunction

string function typeName()
    return className()
endFunction

; ==========================================================
;                      Script Management
; ==========================================================

function Attach(Actor akActor) global
    RPB_ActorScript.AttachOfType(akActor, className())
endFunction

function Detach(Actor akActor) global
    RPB_ActorScript.DetachOfType(akActor, className())
endFunction

; ==========================================================
;                           Fields
; ==========================================================

;/ private /; int holdBountyDecayTimers ; FastMap<string, float>
;/ private /; int holdLastUpdates       ; FastMap<string, float>

; ==========================================================
;                          Properties
; ==========================================================

float property UpdateInterval
    float function get()
        return Config.BountyDecayUpdateInterval
    endFunction
endProperty

float property CurrentTime
    float function get()
        return Utility.GetCurrentGameTime()
    endFunction
endProperty

; ==========================================================

function __construct()
    holdLastUpdates         = self.CreateScriptProperty(holdLastUpdates, FastMap("<string>"))
    holdBountyDecayTimers   = self.CreateScriptProperty(holdBountyDecayTimers, FastMap("<string>"))
endFunction

; ==========================================================
;                        Event Handlers
; ==========================================================

event OnAttachScript()
    self.StartDecayUpdates()

    string[] holds = Config.Holds

    int i = 0
    while (i < holds.Length)
        string hold = holds[i]
        self.RegisterLastUpdateInHold(hold)
        i += 1
    endWhile
endEvent

event OnDetachScript()
endEvent

event OnBountyLost(Faction akFaction, int aiBountyLost)
endEvent

event OnUpdateGameTime()
    self.UpdateBountyDecaying()

    RPB_BountyDecayable actorBountyDecayEffectRef = ActorState.GetScriptState(className()) as RPB_BountyDecayable

    Debug("BountyDecayable::OnUpdateGameTime", "Updating bounty decay for Actor " + this + " (Actor Effect Ref: " + ActorState + ", Actor Bounty Decay Ref: " + actorBountyDecayEffectRef + ")")
endEvent

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    self.UpdateBountyDecayTimers(akOldLocation, akNewLocation)
endEvent

; ==========================================================

; ==========================================================
;                          Functions
; ==========================================================

function UpdateBountyLost(Faction akCrimeFaction)
    string hold = akCrimeFaction.GetName()

    int currentBountyNonViolent = parent.GetActiveBountyForFaction(akCrimeFaction, abViolent = false)
    int currentBountyViolent    = parent.GetActiveBountyForFaction(akCrimeFaction, abNonViolent = false)

    bool hasBounty = currentBountyNonViolent > 0 || currentBountyViolent > 0

    float bountyUpdatedAt = self.GetFloat("bounty::updated_at", hold + "::State")

    if (!bountyUpdatedAt && hasBounty)
        self.RegisterBountyLost(akCrimeFaction)
        return
    endif

    if (!hasBounty)
        return
    endif

    float bountyLost                    = Config.GetBountyDecayLostBounty(hold)
    float bountyLostFromCurrentBounty   = \
        Round((currentBountyNonViolent + currentBountyViolent) * \
        PercentToDecimal(Config.GetBountyDecayLostFromCurrentBounty(hold)))

    float timePassed    = now() - bountyUpdatedAt
    int reduceBy        = floor((timePassed * bountyLost) + (timePassed * bountyLostFromCurrentBounty))

    self.ModCrimeGoldForFaction(akCrimeFaction, -reduceBy)

    ; Update with new time for next bounty reduction
    self.RegisterBountyLost(akCrimeFaction)

    Debug("("+ hold +") ("+ Name +") BountyDecayable::UpdateBountyLost", "Bounty Lost Daily: " + bountyLost + ", Bounty Lost From Current Bounty: " + bountyLostFromCurrentBounty + ", TimePassed: " + timePassed + ", ReduceBy: " + reduceBy)
    Debug("("+ hold +") ("+ Name +") BountyDecayable::UpdateBountyLost", "Bounty Updated At: " + bountyUpdatedAt + ", Now: " + now())
endFunction

function RegisterBountyLost(Faction akCrimeFaction)
    string hold = akCrimeFaction.GetName()
    self.SetFloat("bounty::updated_at", now(), hold + "::State")
endFunction

function StartDecayUpdates()
    RegisterForSingleUpdateGameTime(UpdateInterval)
endFunction

int function GetBountyLostDaily(string asHold)
    Faction crimeFaction = Config.GetFaction(asHold)

    int currentBounty = parent.GetActiveBountyForFaction(crimeFaction)
    int bountyLostPercentOfCurrentBounty = Round(currentBounty * PercentToDecimal(Config.GetBountyDecayLostFromCurrentBounty(asHold)))
    int bountyLost = Config.GetBountyDecayLostBounty(asHold)
    int totalBountyLostDaily = bountyLostPercentOfCurrentBounty + bountyLost

    return totalBountyLostDaily
endFunction

int function GetBountyLostPerUpdate(string asHold)
    int bountyLostDaily = self.GetBountyLostDaily(asHold)
    float timeSinceLastUpdate = CurrentTime - self.GetLastBountyUpdateTime(asHold)
    
    return Round(bountyLostDaily * timeSinceLastUpdate)
endFunction

;/
    Returns the last time the Bounty has decayed in this Hold in GameTime format.
/;
float function GetLastBountyUpdateTime(string asHold)
    return FastMap_GetFloat(holdLastUpdates, asHold)
endFunction

function RegisterLastUpdateInHold(string asHold)
    ; holdLastUpdates = Object_CreateIfNotExists(holdLastUpdates, FastMap("<string>", retain = true))
    ; holdLastUpdates = self.CreateScriptProperty(holdLastUpdates, FastMap("<string>"))

    FastMap_SetFloat(holdLastUpdates, asHold, CurrentTime)
endFunction

function UpdateBountyDecaying()
    string[] holds = Config.Holds

    int i = 0
    while (i < holds.Length)
        string hold = holds[i]
        self.UpdateBountyDecayForHold(hold)
        i += 1
    endWhile

    self.StartDecayUpdates()
endFunction

function UpdateBountyDecayForHold(string asHold)
    if (!Config.IsBountyDecayEnabled(asHold))
        return
    endif

    if (Config.IsInfamyKnown(asHold))
        return
    endif

    bool isActorInHold   = Config.IsActorInLocationFromHold(this, asHold)
    bool hasActiveBounty = parent.HasActiveBountyForFaction(Config.GetFaction(asHold))
    bool hasTimeElapsed  = self.HasTimerElapsed(asHold)
    bool shouldDecay     = hasTimeElapsed && hasActiveBounty && !isActorInHold
    Form[] holdLocations = RPB_Data.Hold_GetLocations(RPB_Data.GetRootObject(asHold))

    if (isActorInHold)
        Debug("BountyDecayable::UpdateBountyDecayForHold", "Actor " + this + " is in " + asHold + ", not decaying bounty...")
    else
        Debug("BountyDecayable::UpdateBountyDecayForHold", "Actor " + this + " is not in " + asHold + ", Current Location: " + this.GetCurrentLocation() + ", Hold Locations: " + holdLocations)
    endif

    if (shouldDecay)
        self.DecayBountyForHold(asHold)
        self.ResetHoldTimer(asHold)
        self.RegisterLastUpdateInHold(asHold)
    endif

    self.DecrementHoldTimer(asHold, UpdateInterval)

    if (isActorInHold)
        self.ResetHoldTimer(asHold)
    endif
endFunction

function DecayBountyForHold(string asHold)
    Faction crimeFaction = Config.GetFaction(asHold)
    int currentBounty = parent.GetActiveBountyForFaction(crimeFaction)
    int bountyDecayedPerUpdate = self.GetBountyLostPerUpdate(asHold)

    parent.ModCrimeGoldForFaction(crimeFaction, -bountyDecayedPerUpdate)
    self.OnBountyLost(crimeFaction, bountyDecayedPerUpdate)

    currentBounty = parent.GetActiveBountyForFaction(crimeFaction)
    Debug("BountyDecayable::DecayBountyForHold", "Decaying bounty for " + asHold + " on Actor " + this + " by " + bountyDecayedPerUpdate + " (Current Bounty: "+ currentBounty +")")
endFunction

function UpdateBountyDecayTimers(Location akOldLocation, Location akNewLocation)
    string[] holds = Config.Holds

    int i = 0
    while (i < holds.Length)
        string hold = holds[i]
        bool isDecayEnabled = Config.IsBountyDecayEnabled(hold)
        bool isInHold       = Config.IsLocationFromHold(akNewLocation, hold) || Config.IsLocationFromHold(akOldLocation, hold)

        if (isDecayEnabled && isInHold)
            self.ResetHoldTimer(hold)
        endif

        i += 1
    endWhile
endFunction

function InitializeTimers()
    ; holdBountyDecayTimers = Object_CreateIfNotExists(holdBountyDecayTimers, FastMap("<string>", retain = true))
    ; holdBountyDecayTimers = self.CreateScriptProperty(holdBountyDecayTimers, FastMap("<string>"))

    string[] holds = Config.Holds

    int i = 0
    while (i < holds.Length)
        string hold = holds[i]
        self.SetHoldTimer(hold, UpdateInterval)
        i += 1
    endWhile
endFunction

function SetHoldTimer(string asHold, float afValue)
    FastMap_SetFloat(holdBountyDecayTimers, asHold, afValue)
endFunction

function IncrementHoldTimer(string asHold, float afIncrementBy = 1.0)
    if (!FastMap_HasKey(holdBountyDecayTimers, asHold))
        return
    endif

    float timerValue = self.GetHoldTimer(asHold)
    FastMap_SetFloat(holdBountyDecayTimers, asHold, Max(0.0, timerValue + afIncrementBy))
endFunction

function DecrementHoldTimer(string asHold, float afDecrementBy = 1.0)
    if (!FastMap_HasKey(holdBountyDecayTimers, asHold))
        return
    endif

    float timerValue = self.GetHoldTimer(asHold)
    FastMap_SetFloat(holdBountyDecayTimers, asHold, Max(0.0, timerValue - afDecrementBy))
endFunction

function ResetHoldTimer(string asHold)
    if (!FastMap_HasKey(holdBountyDecayTimers, asHold))
        return
    endif

    self.SetHoldTimer(asHold, UpdateInterval)
endFunction

float function GetHoldTimer(string asHold)
    return FastMap_GetFloat(holdBountyDecayTimers, asHold)
endFunction

bool function HasTimerElapsed(string asHold)
    return self.GetHoldTimer(asHold) == 0
endFunction


Spell function ScriptSpell() global
    return RPB_Utility.GetFormFromMod(0x28525) as Spell
endFunction