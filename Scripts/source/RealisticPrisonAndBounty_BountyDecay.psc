Scriptname RealisticPrisonAndBounty_BountyDecay extends ReferenceAlias  

import RPB_Utility
import RPB_Config
import Math

int holdDecayTimers

RPB_Config property config
    RPB_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RPB_Config
    endFunction
endProperty

float property UpdateInterval
    float function get()
        return config.BountyDecayUpdateInterval
    endFunction
endProperty

event OnInit()
    initializeTimers()

    ; Register bounty decaying
    RegisterForBountyDecayingUpdate()
endEvent

event OnPlayerLoadGame()
endEvent

event OnUpdateGameTime()
    int i = 0
    while (i < config.FactionCount)
        string hold = config.Holds[i]

        ; Infamy conditions
        bool isDecayable  = (config.isBountyDecayableAsCriminal(hold) && !config.isInfamyKnown(hold)) || config.isBountyDecayEnabled(hold)

        if (isDecayable)
            float holdTimer = getHoldDecayTimer(hold)

            ; Debug(none, "OnUpdateGameTime", "holdTimer (" + hold + "): " + holdTimer)

            if (timeHasElapsed(hold))
                ; Decay Bounty depending on conditions
                ; if not in hold and has bounty
                if (config.hasBountyInHold(hold) && !config.IsInLocationFromHold(hold))
                    ; Debug(none, "OnUpdateGameTime", "Bounty detected and currently not in any of the hold's locations, begin bounty decay. (Hold: " + hold + ")")
                    DecayForHold(hold)
                    ; reset timer
                    holdTimer = resetHoldDecayTimer(hold)
                    ; Debug(none, "OnUpdateGameTime", "Resetting timer for " + hold + " ... (next update in: " + holdTimer + " hours)")

                endif
            endif

            decrementHoldDecayTimer(hold, UpdateInterval)

            if (config.isInLocationFromHold(hold))
                ; if in hold, reset hold decay timer
                holdTimer = resetHoldDecayTimer(hold)
                ; Debug(none, "OnUpdateGameTime", "You are in one of the hold's locations, hold timer for " + hold + " reset. (next update in: " + holdTimer + " hours)")
            endif
        endif

        i += 1
    endWhile
    
    RegisterForBountyDecayingUpdate()
endEvent

event OnLocationChange(Location oldLocation, Location newLocation)
    int i = 0
    while (i < config.FactionCount)
        string hold = config.Holds[i]
        if (config.isBountyDecayEnabled(hold))
            if (config.isLocationFromHold(hold, newLocation) || config.isLocationFromHold(hold, oldLocation))
                float holdTimer = resetHoldDecayTimer(hold)
                ; Debug(none, "OnLocationChange", "Resetting timer for " + hold + " ... (next update in: " + holdTimer + " hours)")
            endif
        endif
        i += 1
    endWhile
endEvent


function RegisterForBountyDecayingUpdate()
    ; Debug(self.GetOwningQuest(), "RegisterForBountyDecaying", "UpdateInterval: " + UpdateInterval)
    RegisterForSingleUpdateGameTime(UpdateInterval)
endFunction

function DecayForHold(string hold)
    Faction crimeFaction    = config.getFaction(hold)
    int currentBounty       = crimeFaction.GetCrimeGold()
    float bountyLostPercent = GetPercentAsDecimal(config.getBountyDecayLostFromCurrentBounty(hold))
    int bountyLost          = config.getBountyDecayLostBounty(hold)
    int decayTo = currentBounty - bountyLost - int_if(bountyLostPercent > 0, floor(currentBounty * bountyLostPercent))
    crimeFaction.SetCrimeGold(decayTo)
    ; Debug(none, "BountyDecay::DecayForHold", "Decaying Bounty for " + hold + ": Old Bounty = " + currentBounty + ", New Bounty: " + decayTo + ", Bounty Lost = " + floor((bountyLost + (currentBounty * bountyLostPercent))) + " (% = " + (bountyLostPercent * 100) + ", Flat = " + bountyLost + ")")
endFunction

function initializeTimers()
    holdDecayTimers = JMap.object()
    JValue.retain(holdDecayTimers)

    int i = 0
    while (i < config.FactionCount)
        string hold = config.Holds[i]
        setHoldDecayTimer(hold, UpdateInterval)
        ; Debug(none, "initializeTimers", "Initializing " + hold + " timer to " + getHoldDecayTimer(hold))
        i += 1
    endWhile

endFunction

function setHoldDecayTimer(string hold, float value)
    JMap.setFlt(holdDecayTimers, hold, value)
endFunction

float function decrementHoldDecayTimer(string hold, float decrementBy = 1.0)
    if (JMap.hasKey(holdDecayTimers, hold))
        float decayTimer = getHoldDecayTimer(hold)
        setHoldDecayTimer(hold, Max(0.0, decayTimer - decrementBy))
        ; JMap.setFlt(holdDecayTimers, hold, Max(0.0, decayTimer - decrementBy))
        return decayTimer - Max(0.0, decrementBy)
    endif
endFunction

float function incrementHoldDecayTimer(string hold, float incrementBy = 1.0)
    if (hasTimerForHold(hold))
        float decayTimer = getHoldDecayTimer(hold)
        float newValue = decayTimer + Max(0.0, incrementBy)
        setHoldDecayTimer(hold, newValue)

        return newValue
    endif
endFunction

float function getHoldDecayTimer(string hold)
    if (hasTimerForHold(hold))
        return JMap.getFlt(holdDecayTimers, hold)
    endif
endFunction

bool function hasTimerForHold(string hold)
    return JMap.hasKey(holdDecayTimers, hold)
endFunction

bool function timeHasElapsed(string hold)
    return getHoldDecayTimer(hold) == 0
endFunction

float function resetHoldDecayTimer(string hold)
    if (hasTimerForHold(hold))
        setHoldDecayTimer(hold, UpdateInterval)

        return UpdateInterval
    endif
endFunction