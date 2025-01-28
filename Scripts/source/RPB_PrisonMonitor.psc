scriptname RPB_PrisonMonitor extends ReferenceAlias

import Math
import RPB_Config
import RPB_Utility
import RPB_Memory

; ==========================================================
;                     Script References
; ==========================================================

RPB_API property API
    RPB_API function get()
        return Prison.API
    endFunction
endProperty

RPB_Prison __prison
RPB_Prison property Prison
    RPB_Prison function get()
        if (__prison)
            return __prison
        endif

        __prison = self.GetOwningQuest().GetAliasByID(self.GetID()) as RPB_Prison        
        return __prison
    endFunction
endProperty

RPB_PrisonerList property Prisoners
    RPB_PrisonerList function get()
        return Prison.Prisoners
    endFunction
endProperty

bool __isMonitoring
bool property IsMonitoring
    bool function get()
        return __isMonitoring
    endFunction
endProperty


; ==========================================================
;                    Monitoring Properties
; ==========================================================

ObjectReference property MonitorOn
    ObjectReference function get()
        return Prison.GetPropertyOfTypeForm("Monitoring//On") as ObjectReference
    endFunction
endProperty

; ==========================================================
;                       Prison Monitoring
; ==========================================================

function SendRequest()
    if (!self.IsMonitoring)
        self.RegisterForMonitoring()
    endif
endFunction

function EnableMonitoring()
    self.GotoState("Active")
endFunction

function DisableMonitoring()
    self.GotoState("Inactive")
endFunction

; ==========================================================
;                          Prisoners
; ==========================================================

function RegisterPrisoner(RPB_Prisoner apPrisoner)
    if (!apPrisoner.IsNPC()) ; No need to monitor the Player, always in the current cell, RPB_Prisoner will handle it
        return
    endif

    if (!self.IsMonitoring)
        self.RegisterForMonitoring()
        Debug("PrisonMonitor::RegisterPrisoner", "Prisoner Sentence: " + apPrisoner.Sentence + " | Prisoner Sentence Left:  " + apPrisoner.TimeLeftInSentence)
    endif

    ; TODO: Get the prisoner's current time left (current sentence left), and add it to a queue,
    ; the prisoner with the lowest current sentence left will be the one to use for UpdateGameTime()
endFunction

function UpdatePrisonersStats()

endFunction

function PassDaysForPrisoner(RPB_Prisoner apPrisoner, int aiDays)
    int i = 0
    while (i < aiDays)
        apPrisoner.OnDayPassed()
        i += 1
    endWhile
endFunction

;/
    Updates any logic related to the Prisoner while they are imprisoned
    (e.g: Time Jailed, Infamy Gained)

    Any deleveling that should happen is also handled here.
/;
bool function AwaitPrisonerImprisonment(RPB_Prisoner apPrisoner)
    apPrisoner.UpdateTimeJailed()
    ; float currentTimeServed = (apPrisoner.TimeServed - apPrisoner.PreviousUpdateTimeServed) ; Subtract previous time served so we only add the new time after the last update
    ; apPrisoner.ModifyStat("Time Jailed", currentTimeServed)

    ; ; Get how many days have elapsed as told by currentTimeServed and loop through OnDayPassed() for that amount of times
    ; int daysElapsedSinceLastUpdate = math.floor(currentTimeServed)

    ; self.PassDaysForPrisoner(apPrisoner, daysElapsedSinceLastUpdate)

    ; Debug("PrisonMonitor::AwaitPrisonerImprisonment", "("+ apPrisoner.Name +") Time Jailed: " + RPB_StorageVars.GetFloatOnForm(Prison.Hold + "::Time Jailed", apPrisoner.GetActor(), "ActorVars") + " | Current Time Served: " + currentTimeServed + " | Previous Time Served: " + apPrisoner.PreviousUpdateTimeServed + " | Days Elapsed: " + daysElapsedSinceLastUpdate)
    ; apPrisoner.PreviousUpdateTimeServed = apPrisoner.TimeServed

    self.UpdatePrisonersStats()
endFunction

bool function AwaitPrisonerForRelease(RPB_Prisoner apPrisoner)
    if (apPrisoner.IsSentenceServed)
        Debug("PrisonMonitor::AwaitPrisonerForRelease", "Released Prisoner:  " + apPrisoner + apPrisoner.GetPrisoner())
        Prison.SendReleaseRequest(apPrisoner)
        Utility.Wait(0.2)
        return false
    endif

    string timeServed = RPB_Utility.GetTimeFormatted(apPrisoner.TimeServed, abIncludeMinutes = true, asNullValue = "seconds")
    string timeLeft   = RPB_Utility.GetTimeFormatted(apPrisoner.TimeLeftInSentence, abIncludeMinutes = true, asNullValue = "seconds")
    Debug("["+ Prison.Name +"] PrisonMonitor::AwaitPrisoners", apPrisoner.Name + " has not yet served "+ apPrisoner.PronounPossessiveObject +" sentence in " + Prison.Name + " (" + timeServed + " served, " +  timeLeft +" left).")

    return true
endFunction

function AwaitPrisoners()
    int prisonersAwaitingRelease = 0
    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner prisoner = Prisoners.AtIndex(i)

        self.AwaitPrisonerImprisonment(prisoner)

        bool isAwaitingRelease = self.AwaitPrisonerForRelease(prisoner)
        if (isAwaitingRelease)
            prisonersAwaitingRelease += 1

        else
            ; prisoner.UpdateTimeJailed()
            ; Debug("PrisonMonitor::AwaitPrisoners", "("+ prisoner.Name +") Time Jailed: " + prisoner.QueryStat("Time Jailed"))
            ; Debug("PrisonMonitor::AwaitPrisoners", "("+ prisoner.Name +") Time Jailed: " + RPB_StorageVars.GetFloatOnForm(Prison.Hold + "::Time Jailed", prisoner.GetActor(), "ActorVars"))
        endif

        ; Debug("PrisonMonitor::AwaitPrisoners", "("+ prisoner.Name +") [Before Update Time Jailed] Sentence - Time Left: " + (prisoner.Sentence - prisoner.TimeLeftInSentence))
        ; prisoner.UpdateTimeJailed()
        ; Debug("PrisonMonitor::AwaitPrisoners", "("+ prisoner.Name +") Time Jailed: " + RPB_StorageVars.GetFloatOnForm(Prison.Hold + "::Time Jailed", prisoner.GetActor(), "ActorVars"))
        ; Debug("PrisonMonitor::AwaitPrisoners", "("+ prisoner.Name +") Sentence - Time Left: " + (prisoner.Sentence - prisoner.TimeLeftInSentence))
        i += 1
    endWhile

    if (prisonersAwaitingRelease > 0)
        Debug("PrisonMonitor::AwaitPrisoners", "Awaiting release for " + prisonersAwaitingRelease + " prisoners in " + Prison.Name + " ("+ Prison.Hold +")")
    endif
endFunction

; ==========================================================
; TODO: Update Prisoner TimeJailed, Infamy Gained, Largest Sentence, Longest Sentence

state Active
    ; event OnUpdateGameTime()
    ; endEvent
endState

state Inactive
    event OnUpdateGameTime()
    endEvent
endState



function RegisterForMonitoring()
    float buffer        = 0.1 ; 6 minutes in game time
    float updateIn      = (Prison.GetCurrentLowestSentence() * 24) + buffer
    float timeInDays    = updateIn / 24

    Debug("["+ Prison.Name +"] PrisonMonitor::RegisterForMonitoring", "updateIn: "+ updateIn +", timeInDays: "+ timeInDays)

    ; if (updateIn < 0)
    if (Prisoners.Count == 0)
        Debug("["+ Prison.Name +"] PrisonMonitor::RegisterForMonitoring", "Prison Monitor - No prisoners to monitor (updateIn: "+ updateIn +")")
        __isMonitoring = false
        return
    endif

    RegisterForSingleUpdateGameTime(3.0)
    __isMonitoring = true
    Debug("["+ Prison.Name +"] PrisonMonitor::RegisterForMonitoring", "Prison Monitor - Updating in " + RPB_Utility.GetTimeFormatted(timeInDays, abIncludeMinutes = true) + " (" + timeInDays+ " days)")
endFunction

function UpdateMonitorTime()
    float updateIn      = Prison.GetCurrentLowestSentence() * 24
    float timeInDays    = updateIn / 24
    Debug("["+ Prison.Name +"] PrisonMonitor::UpdateMonitorTime", "Prison Monitor - Updating in " + RPB_Utility.GetTimeFormatted(timeInDays) + " (" + timeInDays+ " days)")
    RegisterForSingleUpdateGameTime(updateIn)
endFunction

event OnUpdateGameTime()
    ; return
    Debug("["+ Prison.Name +"] PrisonMonitor::OnUpdateGameTime", "Prison Monitor - Updating")
    RegisterForMonitoring()
    self.AwaitPrisoners()
endEvent

; event OnCellAttach()
;     Debug("["+ Prison.Name +"] PrisonMonitor::OnCellAttach", "Prison Monitor - On Cell Attach")
;     Prison.SetupCells()

;     float startBench = StartBenchmark()
;     int i = 0
;     while (i < Prisoners.Count)
;         RPB_Prisoner prisoner = Prisoners.AtIndex(i)
        
;         if (prisoner && prisoner.IsNPC())
;             self.NPC_UpdateCellIntegrity(prisoner)
;         endif

;         ; prisoner.UpdateTimeJailed()

;         i += 1
;     endWhile

;     RegisterForMonitoring()

;     EndBenchmark(startBench, "NPC Cell Integrity Checks")
; endEvent

event OnCellAttach()
    Debug("["+ Prison.Name +"] PrisonMonitor::OnCellAttach", "Prison Monitor - On Cell Attach")
    self.DisableMonitoring()

    int i = 0
    while (i < Prison.JailCells.Length)
        RPB_JailCell jailCell = Prison.JailCells[i] as RPB_JailCell
        if (jailCell && !jailCell.IsInitialized())
            jailCell.Initialize(Prison)
        endif
        i += 1
    endWhile
endEvent

event OnCellDetach()
    Debug("["+ Prison.Name +"] PrisonMonitor::OnCellDetach", "Prison Monitor - On Cell Detach")
    self.GotoState("")
    RegisterForSingleUpdateGameTime(3.0)
    ; self.GotoState("Active")
endEvent

; ==========================================================
;                       NPC Monitoring
; ==========================================================

;/
    Workaround for references getting deleted in Skyrim after a certain
    amount of time (10 days tested).

    The reference (JailCell) will reset all its member properties, so they
    will become null, this includes the Prisoners residing in the cell.
    
    So every time a jail cell does not contain prisoners, and considering its reference
    is stored in RPB_Prisoner, that implies that the Jail Cell was reset but the Prisoner
    should still be there, in which case we re-bind the Prisoner to the Jail Cell.

    This is a workaround for that issue.

    TODO: Test if this works when many prisoners are in the same cell,
    because !JailCell.Prisoners will only be true when there are no prisoners,
    which means that after one of these updates, it may not happen to the other ones
    from the other RPB_Prisoner instances, since this will be false by then.
/;
function NPC_UpdateCellIntegrity(RPB_Prisoner apPrisoner)
    if (!apPrisoner || !apPrisoner.IsNPC())
        return
    endif

    ; The reference to the prisoner's jail cell, it was reset, but the Prisoner retains its reference
    RPB_JailCell jailCell = apPrisoner.JailCell
    
    ; If the prisoner holds the jail cell reference, but is not registered, the integrity was broken
    bool isCellIntegrityBroken = !jailCell.HasPrisoner(apPrisoner)

    if (!isCellIntegrityBroken)
        return
    endif

    ; Since the jail cell's properties were reset, re-register this prisoner
    jailCell.RegisterPrisoner(apPrisoner)
    jailCell.PerformPrisonerSanityCheck(apPrisoner)
endFunction

;/
    Updates the prisoners stripping and clothing states after they have been imprisoned,
    used in case the initial check fails and the prisoners are not stripped and/or clothed if applicable.
/;
function UpdatePrisonersStrippingAndClothingStates()
    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner apPrisoner = Prisoners.AtIndex(i)
        self.UpdatePrisonerStrippingAndClothingStates(apPrisoner)
        i += 1
    endWhile
endFunction

;/
    Updates a prisoner's stripping and clothing states after they have been imprisoned,
    used in case the initial check fails and the prisoner is not stripped and/or clothed if applicable.
/;
function UpdatePrisonerStrippingAndClothingStates(RPB_Prisoner apPrisoner)
    if (apPrisoner.ShouldBeStripped)
        apPrisoner.Strip(abRemoveUnderwear = apPrisoner.WillBeStrippedNaked)

    elseif (apPrisoner.ShouldBeStrippedSilently)
        apPrisoner.StripSilently()
    endif

    if (apPrisoner.ShouldBeClothed)
        apPrisoner.DetermineClothingOutfit()
        apPrisoner.Clothe()
    endif
endFunction