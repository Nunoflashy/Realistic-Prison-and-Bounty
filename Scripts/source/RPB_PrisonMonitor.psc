scriptname RPB_PrisonMonitor extends ReferenceAlias

;/
@references:
    RPB_API API
    RPB_Prison Prison
    RPB_PrisonerList Prisoners
@properties:
    bool IsMonitoring
    float NextWakeAt
    ObjectReference MonitorOn
    bool DebugDryRunReleases
    int ReleaseQueueLength
@functions:
    function SendRequest()
    function EnterForeground()
    function EnterBackground()
    function EnableMonitoring()
    function DisableMonitoring()
    float function ComputeNextWakeHours(float[] afDaysLeft, bool[] abExcluded, bool abHasUnknown = false, float afBufferHours = 0.1, float afMinHours = 1.0, float afUnknownPollHours = 24.0) global
    function Reschedule()
    function ArmHostilityRestore()
    function RequestRealTimeWake(string asQueue, float afSeconds)
    function RegisterPrisoner(RPB_Prisoner apPrisoner)
    function UpdatePrisonersStats()
    function PassDaysForPrisoner(RPB_Prisoner apPrisoner, int aiDays)
    bool function AwaitPrisonerImprisonment(RPB_Prisoner apPrisoner)
    bool function AwaitPrisonerForRelease(RPB_Prisoner apPrisoner)
    float function GetDryRunReleaseTime(Actor akActor)
    Form[] function GetDryRunReleaseOrder()
    function ClearDryRunReleaseOrder()
    function QueueRelease(RPB_Prisoner apPrisoner)
    function ReleaseQueued(RPB_Prisoner apPrisoner)
    function ReleaseNPC(RPB_Prisoner apPrisoner)
    function ProcessReleaseQueue()
    function AwaitPrisoners()
    function RegisterForMonitoring()
    function UpdateMonitorTime()
    function NPC_UpdateCellIntegrity(RPB_Prisoner apPrisoner)
    function UpdatePrisonersStrippingAndClothingStates()
    function UpdatePrisonerStrippingAndClothingStates(RPB_Prisoner apPrisoner)
@events:
    event OnUpdate()
    event OnUpdateGameTime()
    event OnCellAttach()
    event OnCellDetach()
/;

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

; Absolute game time (days) of the pending background wake, -1 when none is registered
float __nextWakeAt = -1.0

; Absolute game time (days) of whatever single game-time wake is registered right now (release, hostility restore or the
; foreground heartbeat), -1 when none: lets ArmHostilityRestore() move the wake earlier without a full Reschedule()
float __armedWakeAt = -1.0
float property NextWakeAt
    float function get()
        return __nextWakeAt
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

;/
    A foreground prisoner (or a newly registered one) asks for background monitoring. Ignored while the player is in the
    cell (state Inactive): the prisoners run in the foreground then, and EnterBackground() reschedules when the player leaves.
/;
function SendRequest()
    if (!self.IsMonitoring && self.GetState() != "Inactive")
        self.Reschedule()
    endif
endFunction

;/
    The player is in the prison's cell: prisoners are processed in the foreground, so the background wake is cancelled.
    A slow heartbeat only checks that the monitoring object is still attached, to recover from a missed detach event.
/;
function EnterForeground()
    UnregisterForUpdateGameTime()
    __armedWakeAt = -1.0
    __isMonitoring = false
    __nextWakeAt = -1.0
    self.GotoState("Inactive")
    self.Reschedule() ; Inactive's version: the 12h heartbeat, or sooner if a hostility restore is due first
endFunction

;/
    The player left (or was never in) the cell: prisoners without a running effect are processed in the background,
    with one wake scheduled at the earliest release.
/;
function EnterBackground()
    self.GotoState("")
    self.Reschedule()
endFunction

function EnableMonitoring()
    self.EnterBackground()
endFunction

function DisableMonitoring()
    self.EnterForeground()
endFunction

;/
    Computes when the next background wake is needed, in game HOURS from now.

    afDaysLeft[i]   Days left in prisoner i's sentence (may be <= 0: already served).
    abExcluded[i]   Prisoner i needs no background wake (the Player, an undetermined sentence, ...).
    abHasUnknown    At least one prisoner is away and its time left cannot be read (no effect script); re-check
                    at least every afUnknownPollHours until that state can be read without the effect.

    returns (float): the hours until the wake, or -1 when there is nothing to monitor. Never below afMinHours so a
    served-but-not-yet-released prisoner cannot make the monitor spin.
/;
float function ComputeNextWakeHours(float[] afDaysLeft, bool[] abExcluded, bool abHasUnknown = false, float afBufferHours = 0.1, float afMinHours = 1.0, float afUnknownPollHours = 24.0) global
    bool found = false
    float lowest = 0.0

    int i = 0
    while (i < afDaysLeft.Length)
        if (!abExcluded[i])
            if (!found || afDaysLeft[i] < lowest)
                lowest = afDaysLeft[i]
                found = true
            endif
        endif
        i += 1
    endWhile

    if (!found && !abHasUnknown)
        return -1.0
    endif

    float hours = 0.0
    bool hoursSet = false

    if (found)
        hours = (lowest * 24.0) + afBufferHours
        hoursSet = true
    endif

    if (abHasUnknown && (!hoursSet || hours > afUnknownPollHours))
        hours = afUnknownPollHours
    endif

    if (hours < afMinHours)
        hours = afMinHours
    endif

    return hours
endFunction

;/
    (Re)schedules the single background wake at the earliest release (+ buffer) of the prisoners that need it.
    Cancels any pending wake first; registers nothing (and logs no error) when there is nothing to monitor.
/;
function Reschedule()
    UnregisterForUpdateGameTime()
    __armedWakeAt = -1.0
    __nextWakeAt = -1.0
    __isMonitoring = false

    ; I'm the only script on this alias that registers game-time updates: RPB_Prison shares the alias, and two scripts
    ; registering on one object replaced or cancelled each other's wake (the hostility restore got lost, depending on the
    ; order of events). So this one registration covers both: the earliest release, and the earliest hostility restore.
    float releaseHours = self.__NextReleaseWakeHours()
    float restoreHours = Prison.NextHostilityRestoreHours()

    float hours = releaseHours
    if (restoreHours >= 0.0 && (hours < 0.0 || restoreHours < hours))
        hours = restoreHours
    endif
    if (hours < 0.0)
        return ; nothing to wake for
    endif

    RegisterForSingleUpdateGameTime(hours)
    __armedWakeAt = Utility.GetCurrentGameTime() + (hours / 24.0)

    ; IsMonitoring / NextWakeAt describe the release wake only, as before
    if (releaseHours >= 0.0)
        __nextWakeAt = Utility.GetCurrentGameTime() + (releaseHours / 24.0)
        __isMonitoring = true
        Debug("["+ Prison.Name +"] PrisonMonitor::Reschedule", "Prison Monitor - next wake in " + releaseHours + " game hours (" + RPB_Utility.GetTimeFormatted(releaseHours / 24.0, abIncludeMinutes = true) + ")")
    endif
endFunction

;/
    A hostility restore was queued: make sure the wake comes no later than it, WITHOUT a full Reschedule() - that one
    reads every prisoner's sentence (natives per prisoner), which made every hostile prisoner's release cost O(prisoners).
    Registering a single game-time update replaces the pending one, so the wake is only moved when the restore is due
    before whatever is armed now; otherwise the armed wake comes first, and every wake processes due restores and then
    re-arms fully. Works in both states (in Inactive the armed wake is the heartbeat).
/;
function ArmHostilityRestore()
    float restoreHours = Prison.NextHostilityRestoreHours()
    if (restoreHours < 0.0)
        return
    endif

    float restoreAt = Utility.GetCurrentGameTime() + (restoreHours / 24.0)
    if (__armedWakeAt < 0.0 || restoreAt < __armedWakeAt)
        RegisterForSingleUpdateGameTime(restoreHours)
        __armedWakeAt = restoreAt
    endif
endFunction

; Hours until the earliest release that needs a background wake (+ buffer, or the dev override), or -1.0 when none does
float function __NextReleaseWakeHours()
    int count = Prisoners.Count
    if (count == 0)
        return -1.0
    endif

    float[] daysLeft = Utility.CreateFloatArray(count)
    bool[] excluded = Utility.CreateBoolArray(count, false) ; the fill argument is NOT reliable here: every element is assigned below
    bool hasUnknown = false

    int i = 0
    while (i < count)
        RPB_Prisoner prisoner = Prisoners.AtIndex(i)

        if (!prisoner)
            ; Away: no effect script, its stored state cannot be read through RPB_Prisoner (see ROADMAP: persistent roster)
            excluded[i] = true
            hasUnknown = true
        elseif (prisoner.IsPlayer() || prisoner.IsUndeterminedSentence)
            excluded[i] = true
        else
            excluded[i] = false
            daysLeft[i] = prisoner.TimeLeftInSentence
        endif
        i += 1
    endWhile

    float hours = ComputeNextWakeHours(daysLeft, excluded, hasUnknown)
    if (hours < 0.0)
        return -1.0
    endif

    ; Dev override (F4 -> [Debug] Toggle Fast Monitor): a short fixed interval to test the monitor without waiting out a sentence
    float overrideHours = RPB_Utility.GetMonitorOverrideHours()
    if (overrideHours > 0.0)
        hours = overrideHours
    endif

    return hours
endFunction

; ==========================================================
;                          Prisoners
; ==========================================================

function RegisterPrisoner(RPB_Prisoner apPrisoner)
    if (!apPrisoner.IsNPC()) ; No need to monitor the Player, always in the current cell, RPB_Prisoner will handle it
        return
    endif

    ; A new prisoner may have the earliest release: always recompute (unless the player is in the cell)
    if (self.GetState() != "Inactive")
        self.Reschedule()
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

    ; Debug("PrisonMonitor::AwaitPrisonerImprisonment", "("+ apPrisoner.Name +") Time Jailed: " + RPB_StorageVars.GetFloatOnReference(Prison.Hold + "::Time Jailed", apPrisoner.GetActor(), "ActorVars") + " | Current Time Served: " + currentTimeServed + " | Previous Time Served: " + apPrisoner.PreviousUpdateTimeServed + " | Days Elapsed: " + daysElapsedSinceLastUpdate)
    ; apPrisoner.PreviousUpdateTimeServed = apPrisoner.TimeServed

    self.UpdatePrisonersStats()
endFunction

bool function AwaitPrisonerForRelease(RPB_Prisoner apPrisoner)
    if (apPrisoner.IsSentenceServed)
        Debug("PrisonMonitor::AwaitPrisonerForRelease", "Released Prisoner:  " + apPrisoner + apPrisoner.GetPrisoner())
        self.QueueRelease(apPrisoner) ; asynchronous, ordered: never blocks this pass on a release
        return false
    endif

    string timeServed = RPB_Utility.GetTimeFormatted(apPrisoner.TimeServed, abIncludeMinutes = true, asNullValue = "seconds")
    string timeLeft   = RPB_Utility.GetTimeFormatted(apPrisoner.TimeLeftInSentence, abIncludeMinutes = true, asNullValue = "seconds")
    Debug("["+ Prison.Name +"] PrisonMonitor::AwaitPrisoners", apPrisoner.Name + " has not yet served "+ apPrisoner.PronounPossessiveObject +" sentence in " + Prison.Name + " (" + timeServed + " served, " +  timeLeft +" left).")

    return true
endFunction

;/
    Ordered release queue. Due NPC prisoners are queued (ordered by their release time, no duplicates) and released ONE
    per wake on the monitor's own stack, so a slow or failing release only delays the queue, never the caller (the
    player's fast forward, the background wake). ReleaseQueued() is the plug-in point for the release strategy: today
    SendReleaseRequest (teleport / headless, what an away prisoner needs); later an escort scene when the prisoner is
    near the player (see ROADMAP: the SceneManager must play several scenes first).
/;
int __releaseQueue ; JArray of actor Forms, retained
int __releaseAt    ; JFormMap actor -> game time of release, retained
bool __releaseQueueRunning

; Test hook: when true ReleaseQueued() only records the order instead of releasing
bool property DebugDryRunReleases auto
int __releasedLog ; JArray of actor Forms in the order ReleaseQueued() saw them (dry run only)
int __releasedAt  ; JFormMap actor -> game time the release happened at (dry run only)

function __EnsureReleaseQueue()
    if (!__releaseQueue || !JValue.isExists(__releaseQueue))
        __releaseQueue = JValue.retain(JArray.object())
    endif
    if (!__releaseAt || !JValue.isExists(__releaseAt))
        __releaseAt = JValue.retain(JFormMap.object())
    endif
    if (!__releasedLog || !JValue.isExists(__releasedLog))
        __releasedLog = JValue.retain(JArray.object())
    endif
    if (!__releasedAt || !JValue.isExists(__releasedAt))
        __releasedAt = JValue.retain(JFormMap.object())
    endif
endFunction

float function GetDryRunReleaseTime(Actor akActor)
    self.__EnsureReleaseQueue()
    return JFormMap.getFlt(__releasedAt, akActor, -1.0)
endFunction

int property ReleaseQueueLength
    int function get()
        if (!__releaseQueue || !JValue.isExists(__releaseQueue))
            return 0
        endif
        return JArray.count(__releaseQueue)
    endFunction
endProperty

Form[] function GetDryRunReleaseOrder()
    self.__EnsureReleaseQueue()
    int count = JArray.count(__releasedLog)
    Form[] order = Utility.CreateFormArray(count)
    int i = 0
    while (i < count)
        order[i] = JArray.getForm(__releasedLog, i)
        i += 1
    endWhile
    return order
endFunction

function ClearDryRunReleaseOrder()
    self.__EnsureReleaseQueue()
    JArray.clear(__releasedLog)
    JFormMap.clear(__releasedAt)
endFunction

function QueueRelease(RPB_Prisoner apPrisoner)
    Actor queued = apPrisoner.GetActor()
    if (!queued)
        return
    endif

    self.__EnsureReleaseQueue()
    if (JFormMap.hasKey(__releaseAt, queued))
        return
    endif

    float releaseAt = Utility.GetCurrentGameTime() + apPrisoner.TimeLeftInSentence
    JFormMap.setFlt(__releaseAt, queued, releaseAt)

    int position = 0
    int count = JArray.count(__releaseQueue)
    while (position < count && JFormMap.getFlt(__releaseAt, JArray.getForm(__releaseQueue, position)) <= releaseAt)
        position += 1
    endWhile
    JArray.addForm(__releaseQueue, queued, position)

    if (!__releaseQueueRunning)
        __releaseQueueRunning = true
        self.RequestRealTimeWake("Release", 0.1)
    endif
endFunction

; The release strategy for one queued prisoner (see the comment on the queue)
function ReleaseQueued(RPB_Prisoner apPrisoner)
    if (self.DebugDryRunReleases)
        self.__RecordDryRun(apPrisoner)
        return
    endif

    Prison.SendReleaseRequest(apPrisoner)
endFunction

function __RecordDryRun(RPB_Prisoner apPrisoner)
    self.__EnsureReleaseQueue()
    JArray.addForm(__releasedLog, apPrisoner.GetActor())
    JFormMap.setFlt(__releasedAt, apPrisoner.GetActor(), Utility.GetCurrentGameTime())
endFunction

;/
    Releases one NPC prisoner NOW and waits (bounded, ~20 s real time) until it has left the prison's list. Used by the
    player's time skip, where every NPC must be released at its own release time, in order, before time moves on. The
    bounded wait means a slow NPC release can delay the time skip but never freeze it. This is the seam for the release
    mode (instant teleport today, an escort scene the player can watch later: see ROADMAP).
/;
function ReleaseNPC(RPB_Prisoner apPrisoner)
    if (self.DebugDryRunReleases)
        self.__RecordDryRun(apPrisoner)
        return
    endif

    Actor releasing = apPrisoner.GetActor()
    Prison.SendReleaseRequest(apPrisoner)

    float t0 = Utility.GetCurrentRealTime()
    while (Prisoners.AtKey(releasing) != none && (Utility.GetCurrentRealTime() - t0) < 20.0)
        Utility.Wait(0.2)
    endWhile
endFunction

function ProcessReleaseQueue()
    self.__EnsureReleaseQueue()

    if (JArray.count(__releaseQueue) == 0)
        __releaseQueueRunning = false
        return
    endif

    Form next = JArray.getForm(__releaseQueue, 0)
    JArray.eraseIndex(__releaseQueue, 0)
    JFormMap.removeKey(__releaseAt, next)

    RPB_Prisoner prisoner = Prisoners.AtKey(next as Actor)
    if (prisoner)
        self.ReleaseQueued(prisoner)
    else
        Debug("["+ Prison.Name +"] PrisonMonitor::ProcessReleaseQueue", "Queued prisoner " + next + " is not in the prison anymore, skipping.")
    endif

    if (JArray.count(__releaseQueue) > 0)
        self.RequestRealTimeWake("Release", 0.5)
    else
        __releaseQueueRunning = false
    endif
endFunction

; ==========================================================
;           The alias's one real-time update (OnUpdate)
; ==========================================================
; RPB_Prison shares this alias, and two scripts registering single updates on one object replaced each other's: the
; release queue's 0.5s wakes ran the prison's re-dress pass early (it counts a pass per call and drops an NPC after two
; empty ones, so NPCs could leave the queue ~1s after their release, before the engine settled their outfit), and the
; prison's 3s wakes slowed the release queue. So I'm the only one registering it here, and every queue has its own due
; time: a wake runs only the queues that are due, each at its own pace. Same one-owner rule as the game-time wake.
; Real-time seconds (Utility.GetCurrentRealTime), -1 = nothing pending.
float __dressDueAt = -1.0
float __stallDueAt = -1.0
float __releaseDueAt = -1.0
float __armedRealTimeAt = -1.0

;/
    Asks for @asQueue ("Dress", "EscortStall" or "Release") to be processed in @afSeconds. Keeps the sooner of that and
    what the queue already had pending, and only re-registers the single update when this comes before the armed one.
/;
function RequestRealTimeWake(string asQueue, float afSeconds)
    float at = Utility.GetCurrentRealTime() + afSeconds

    if (asQueue == "Dress")
        if (__dressDueAt < 0.0 || at < __dressDueAt)
            __dressDueAt = at
        endif
    elseIf (asQueue == "EscortStall")
        if (__stallDueAt < 0.0 || at < __stallDueAt)
            __stallDueAt = at
        endif
    elseIf (asQueue == "Release")
        if (__releaseDueAt < 0.0 || at < __releaseDueAt)
            __releaseDueAt = at
        endif
    else
        RPB_Utility.Warn("PrisonMonitor::RequestRealTimeWake: unknown queue '" + asQueue + "'")
        return
    endif

    if (__armedRealTimeAt < 0.0 || at < __armedRealTimeAt)
        RegisterForSingleUpdate(afSeconds)
        __armedRealTimeAt = at
    endif
endFunction

; Due now, or saved in an earlier session: GetCurrentRealTime() restarts every session, so a stored time far in the future
; is stale, not a real wait
bool function __IsRealTimeDue(float afDueAt, float afNow)
    return afDueAt >= 0.0 && (afDueAt <= afNow + 0.05 || afDueAt - afNow > 60.0)
endFunction

event OnUpdate()
    __armedRealTimeAt = -1.0 ; a single update is used up once it fires
    float now = Utility.GetCurrentRealTime()

    if (self.__IsRealTimeDue(__dressDueAt, now))
        __dressDueAt = -1.0
        Prison.__ProcessPendingDress()
    endif
    if (self.__IsRealTimeDue(__stallDueAt, now))
        __stallDueAt = -1.0
        Prison.__ProcessEscortStallChecks()
    endif
    if (self.__IsRealTimeDue(__releaseDueAt, now))
        __releaseDueAt = -1.0
        self.ProcessReleaseQueue()
    endif

    ; Re-arm for whatever is still pending (the processors above re-request what they need, which may already have armed)
    float nextAt = -1.0
    if (__dressDueAt >= 0.0 && (nextAt < 0.0 || __dressDueAt < nextAt))
        nextAt = __dressDueAt
    endif
    if (__stallDueAt >= 0.0 && (nextAt < 0.0 || __stallDueAt < nextAt))
        nextAt = __stallDueAt
    endif
    if (__releaseDueAt >= 0.0 && (nextAt < 0.0 || __releaseDueAt < nextAt))
        nextAt = __releaseDueAt
    endif
    if (nextAt >= 0.0 && (__armedRealTimeAt < 0.0 || nextAt < __armedRealTimeAt))
        float seconds = nextAt - Utility.GetCurrentRealTime()
        if (seconds < 0.05)
            seconds = 0.05
        endif
        RegisterForSingleUpdate(seconds)
        __armedRealTimeAt = nextAt
    endif
endEvent

function AwaitPrisoners()
    int prisonersAwaitingRelease = 0
    int prisonersAway = 0

    ; Snapshot of the actors first: a release removes the prisoner from the list, which used to shift the indexes under this loop
    Form[] actors = Prisoners.GetActors()
    prisonersAway = Prisoners.Count - actors.Length ; entries whose effect is not running (away)

    int i = 0
    while (i < actors.Length)
        RPB_Prisoner prisoner = Prisoners.AtKey(actors[i] as Actor)

        ; Foreground prisoners and the Player run themselves; only NPCs that are not actively monitored are processed here
        if (prisoner && prisoner.IsNPC() && !Prison.ShouldActivelyMonitorPrisoner(prisoner))
            self.AwaitPrisonerImprisonment(prisoner)

            if (self.AwaitPrisonerForRelease(prisoner))
                prisonersAwaitingRelease += 1
            endif
        endif

        i += 1
    endWhile

    if (prisonersAway > 0)
        Debug("PrisonMonitor::AwaitPrisoners", prisonersAway + " prisoner(s) in " + Prison.Name + " are away (no effect running): their release cannot be evaluated in the background yet")
    endif

    if (prisonersAwaitingRelease > 0)
        Debug("PrisonMonitor::AwaitPrisoners", "Awaiting release for " + prisonersAwaitingRelease + " prisoners in " + Prison.Name + " ("+ Prison.Hold +")")
    endif
endFunction

; ==========================================================
; TODO: Update Prisoner TimeJailed, Infamy Gained, Largest Sentence, Longest Sentence

state Active
endState

;/
    The player is (was last seen) in the prison's cell. Nothing is scheduled here except a slow heartbeat that recovers from
    a missed OnCellDetach: if the monitoring object's cell is no longer attached, the player is gone and we go back to the
    background.
/;
state Inactive
    ; The heartbeat, or sooner if a hostility restore is due first - this is the alias's only game-time registration (see
    ; the default Reschedule), so a restore due while the player is in the prison would otherwise wait up to 12h
    function Reschedule()
        UnregisterForUpdateGameTime()
        __armedWakeAt = -1.0
        float hours = 12.0
        float restoreHours = Prison.NextHostilityRestoreHours()
        if (restoreHours >= 0.0 && restoreHours < hours)
            hours = restoreHours
        endif
        RegisterForSingleUpdateGameTime(hours)
        __armedWakeAt = Utility.GetCurrentGameTime() + (hours / 24.0)
    endFunction

    event OnUpdateGameTime()
        __armedWakeAt = -1.0 ; a single update is used up once it fires
        Prison.__ProcessHostilityRestore()

        ObjectReference monitored = self.GetReference()
        Cell monitoredCell = none
        if (monitored)
            monitoredCell = monitored.GetParentCell()
        endif

        if (!monitoredCell || !monitoredCell.IsAttached())
            Debug("["+ Prison.Name +"] PrisonMonitor::Inactive.OnUpdateGameTime", "The monitoring object is not attached anymore (missed detach), going back to the background")
            self.EnterBackground()
        else
            self.Reschedule()
        endif
    endEvent
endState

; Kept for existing callers: asks for a background schedule (see SendRequest / Reschedule)
function RegisterForMonitoring()
    self.SendRequest()
endFunction

; Kept for existing callers
function UpdateMonitorTime()
    self.Reschedule()
endFunction

; The single background wake: the earliest release has (probably) arrived
event OnUpdateGameTime()
    Debug("["+ Prison.Name +"] PrisonMonitor::OnUpdateGameTime", "Prison Monitor - Updating")
    __armedWakeAt = -1.0 ; a single update is used up once it fires
    Prison.__ProcessHostilityRestore() ; only acts on restores that are due (this wake may be for a release)
    __isMonitoring = false
    __nextWakeAt = -1.0
    self.AwaitPrisoners()
    self.Reschedule()
endEvent

event OnCellAttach()
    Debug("["+ Prison.Name +"] PrisonMonitor::OnCellAttach", "Prison Monitor - On Cell Attach")
    self.EnterForeground()

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
    self.EnterBackground()
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