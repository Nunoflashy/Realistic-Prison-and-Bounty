Scriptname RPB_Prisoner extends RPB_Actor

import RPB_Config
import RPB_Utility
import Math

; ==========================================================
;                          Constants
; ==========================================================

int property SKILL_LOSS_HANDLING_ALL_SKILLS             = 0 autoreadonly
int property SKILL_LOSS_HANDLING_ALL_STAT_SKILLS        = 1 autoreadonly
int property SKILL_LOSS_HANDLING_ALL_PERK_SKILLS        = 2 autoreadonly
int property SKILL_LOSS_HANDLING_RANDOM_STAT_SKILL      = 3 autoreadonly
int property SKILL_LOSS_HANDLING_RANDOM_PERK_SKILL      = 4 autoreadonly
int property SKILL_LOSS_HANDLING_RANDOM                 = 5 autoreadonly

; ==========================================================
;                      Script References
; ==========================================================

RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

; ==========================================================
;                   Management Properties
; ==========================================================

bool property HasStateRequiredForImprisonment
    bool function get()
        return Prison && JailCell && (Sentence || Bounty || IsUndeterminedSentence)
    endFunction
endProperty

bool property ShouldProcessImprisonmentEvents
    bool function get()
        return self.IsImprisoned
    endFunction
endProperty

bool property IsEnabledForBackgroundUpdates
    bool function get()
        return GetBool("IsEnabledForBackgroundUpdates")
    endFunction

    function set(bool value)
        SetBool("IsEnabledForBackgroundUpdates", value)
    endFunction
endProperty

bool property IsQueuedForImprisonment auto

; ==========================================================
;                 Arrest / Imprisonment Time
; ==========================================================

int property MinuteOfArrest
    int function get()
        return GetInt("Minute of Arrest")
    endFunction
endProperty

int property HourOfArrest
    int function get()
        return GetInt("Hour of Arrest")
    endFunction
endProperty

int property DayOfArrest
    int function get()
        return GetInt("Day of Arrest")
    endFunction
endProperty

int property MonthOfArrest
    int function get()
        return GetInt("Month of Arrest")
    endFunction
endProperty

int property YearOfArrest
    int function get()
        return GetInt("Year of Arrest")
    endFunction
endProperty

int property MinuteOfImprisonment
    int function get()
        return GetInt("Minute of Imprisonment")
    endFunction
endProperty

int property HourOfImprisonment
    int function get()
        return GetInt("Hour of Imprisonment")
    endFunction
endProperty

int property DayOfImprisonment
    int function get()
        return GetInt("Day of Imprisonment")
    endFunction
endProperty

int property MonthOfImprisonment
    int function get()
        return GetInt("Month of Imprisonment")
    endFunction
endProperty

int property YearOfImprisonment
    int function get()
        return GetInt("Year of Imprisonment")
    endFunction
endProperty

int property ReleaseHour
    int function get()
        float releaseTimeHour = ReleaseTime - math.floor(ReleaseTime)

        ; Get the release hour and minutes
        float releaseHourAndMinutes = releaseTimeHour / 0.0416

        return Round(releaseHourAndMinutes)
    endFunction
endProperty

int property ReleaseMinute
    int function get()
        float releaseTimeHour = ReleaseTime - math.floor(ReleaseTime)

        ; Get the release hour and minutes
        float releaseHourAndMinutes = releaseTimeHour / 0.0416
    
        int releaseMinutes = Round((releaseHourAndMinutes - math.floor(releaseHourAndMinutes)) * 60)
    
        return releaseMinutes
    endFunction
endProperty

; ==========================================================
;                    Prisoner Properties
; ==========================================================

; The number associated with this Prisoner
int property Number
    int function get()
        return GetInt("Prisoner Number")
    endFunction
endProperty

Actor property Captor
    Actor function get()
        return self.GetForm("Arrest Captor") as Actor
    endFunction
endProperty

RPB_Prison property Prison
    RPB_Prison function get()
        return self.GetPrison()
    endFunction
endProperty

RPB_JailCell property JailCell
    RPB_JailCell function get()
        return self.GetCell()
    endFunction
endProperty

float __currentTimeOverride
float property CurrentTime
    float function get()
        if (__currentTimeOverride > 0)
            return __currentTimeOverride
        endif

        return Utility.GetCurrentGameTime()
    endFunction
endProperty

int property BountyNonViolent
    int function get()
        return self.GetLatentBounty(abViolent = false)
    endFunction
endProperty

int property BountyViolent
    int function get()
        return self.GetLatentBounty(abNonViolent = false)
    endFunction
endProperty

int property Bounty
    int function get()
        return self.GetLatentBounty()
    endFunction
endProperty

bool property Defeated
    bool function get()
        return GetBool("Defeated", "Arrest")
    endFunction
endProperty

int property DefeatedBounty
    int function get()
        return GetInt("Bounty for Defeat", "Arrest")
    endFunction
endProperty

bool property ShouldBeFrisked
    bool function get()
        return self.ShouldFrisk()
    endFunction
endProperty

bool property ShouldBeStripped
    bool function get()
        return self.ShouldStrip()
    endFunction
endProperty

bool property ShouldBeStrippedSilently
    bool function get()
        return self.ShouldSilentlyStrip()
    endFunction
endProperty

int property StrippingThoroughness
    int function get()
        int modifier = Prison.StrippingThoroughnessModifier
        return GetInt("Stripping Thoroughness", "Stripping") + int_if (modifier > 0, Round(Bounty / modifier))
    endFunction
endProperty

bool property ShouldBeClothed
    bool function get()
        return self.ShouldClothe()
    endFunction
endProperty

bool property UseDefaultOutfitAsFallback
    bool function get()
        return self.Should("Use Default Outfit as Fallback")
    endFunction
endProperty

ObjectReference property PrisonerBelongingsContainer
    ObjectReference function get()
        return GetReference("Prisoner Belongings Container")
    endFunction
endProperty

ObjectReference property TeleportReleaseLocation
    ObjectReference function get()
        return GetReference("Teleport Release Location")
    endFunction
endProperty

bool property IsImprisoned
    bool function get()
        return GetBool("Imprisoned")
    endFunction
endProperty

;/
    Checks if this Prisoner is inside the cell.
    TODO: When cells with multiple doors are supported,
        this property should take into account the distance between the door and the exterior marker of that door,
        since each cell door should have at least one exterior marker.

        Needs to be refactored, because it doesn't exactly check if the prisoner is in the cell,
        it's only checking if the distance to the cell door is greater than the distance from the outside markers,
        and it fails on StripEnd because of that, since even when the Actor is outside the cell,
        the condition is being met because there's no rule checking if the Prisoner is inside the cell,
        need to think of a way to do that check
/;
bool property IsInCell
    bool function get()
        float distanceFromCellDoor      = self.GetDistance(JailCell.CellDoor)
        float distanceFromOutsideCell   = self.GetDistance(JailCell.ExteriorMarkers[0] as ObjectReference)
        bool isOutOfCell                = distanceFromCellDoor >= distanceFromOutsideCell

        return !isOutOfCell
    endFunction
endProperty

bool property ShouldBeInCell
    bool function get()
        return Has("Should Be In Cell")
    endFunction
endProperty

float __lastUpdate
float property LastUpdate
    float function get()
        return __lastUpdate
    endFunction
endProperty

;/
    Gets the time since the last update.
    1 Hour In-Game = 0.04166666666666666666666666666667
    Formula: Hours / 24
    f(h / 24) = hours in game
/;
float property TimeSinceLastUpdate
    float function get()
        return CurrentTime - LastUpdate
    endFunction
endProperty

float property TimeOfArrest
    float function get()
        return GetFloat("Time of Arrest")
    endFunction
endProperty

float property TimeOfImprisonment
    float function get()
        return GetFloat("Time of Imprisonment")
    endFunction
endProperty

float property TimeServed
    float function get()
        return CurrentTime - TimeOfImprisonment
    endFunction
endProperty

float property TimeArrested
    float function get()
        return CurrentTime - TimeOfArrest
    endFunction
endProperty

int property Sentence
    int function get()
        return GetInt("Sentence")
    endFunction
endProperty

bool property IsUndeterminedSentence
    bool function get()
        return GetBool("Sentence::IsUndetermined")
    endFunction

    function set(bool value)
        SetBool("Sentence::IsUndetermined", value)
    endFunction
endProperty

float __additionalReleaseHours
float property ReleaseTime
    float function get()
        ; if (self.IsReleaseOnWeekend())
        ;     return (self.GetReleaseTime(false) + self.GetReleaseTimeExtraHours()) + 2 ; Add 2 days, if on a Sundas, find a way to just add 1 day to round to Morndas
        ; endif

        ; if (self.IsReleaseOnLoredas())
        ;     return (self.GetReleaseTime(false) + self.GetReleaseTimeExtraHours()) + 2 ; Add 2 days, if on a Sundas, find a way to just add 1 day to round to Morndas
        ; elseif (self.IsReleaseOnSundas())
        ;     return (self.GetReleaseTime(false) + self.GetReleaseTimeExtraHours()) + 2 ; Add 2 days, if on a Sundas, find a way to just add 1 day to round to Morndas
        ; endif

        ; if (self.HasReleaseTimeExtraHours())
        ;     return self.GetReleaseTime(false) + self.GetReleaseTimeExtraHours()
        ; endif

        if (self.IsUndeterminedSentence)
            return self.GetIndefiniteReleaseTime()
        endif

        return self.GetReleaseTime()
    endFunction
endProperty

bool property ShowReleaseTime
    bool function get()
        return GetBool("ReleaseTime::Show")
    endFunction

    function set(bool value)
        SetBool("ReleaseTime::Show", value)
    endFunction
endProperty

bool property ShowSentence
    bool function get()
        return GetBool("Sentence::Show")
    endFunction

    function set(bool value)
        SetBool("Sentence::Show", value)
    endFunction
endProperty

bool property ShowTimeServed
    bool function get()
        return GetBool("TimeServed::Show")
    endFunction

    function set(bool value)
        SetBool("TimeServed::Show", value)
    endFunction
endProperty

bool property ShowTimeLeftInSentence
    bool function get()
        return GetBool("TimeLeftInSentence::Show")
    endFunction

    function set(bool value)
        SetBool("TimeLeftInSentence::Show", value)
    endFunction
endProperty

bool property ShowBounty
    bool function get()
        return GetBool("Bounty::Show")
    endFunction

    function set(bool value)
        SetBool("Bounty::Show", value)
    endFunction
endProperty
; float property ReleaseTime
;     float function get()
;         float gameHour = 0.04166666666666666666666666666667
;         if (self.HasAdditionalReleaseTimeHours())
;             return floor(TimeOfImprisonment) + (gameHour * 24 * Sentence) + __additionalReleaseHours
;         endif

;         return TimeOfImprisonment + (gameHour * 24 * Sentence)
;     endFunction
; endProperty

float property TimeLeftInSentence
    float function get()
        if (self.IsUndeterminedSentence)
            return 1 ; If there's always 1 day left, there's no release since the time never reaches 0
        endif

        return (ReleaseTime - TimeOfImprisonment) - TimeServed
    endFunction
endProperty

; Maybe this should be reset upon escape/release,
; otherwise it will keep adding the remainder of the days of previous arrests to current one,
; which is accurate since it tracks ALL the time the actor was in jail, but maybe not what is ideal.
; Example: 2h served right before release which doesn't account to a full day will be taken into account
; on the next arrest, which means the actor only has to serve 22h of the following arrest for it to count as a day
; since they already had 2h clocked in from the previous imprisonment.
float accumulatedTimeServed = 0.0

int property DaysSinceTimeOfImprisonment
    int function get()
        return floor(accumulatedTimeServed)
    endFunction
endProperty

bool property IsSentenceServed
    bool function get()
        return CurrentTime >= ReleaseTime
    endFunction
endProperty

bool property ShouldFastForwardToRelease
    bool function get()
        return Prison.FastForward && TimeServed >= Prison.DayToFastForwardFrom
    endFunction
endProperty

int property CurrentInfamy
    int function get()
        return self.QueryStat("Infamy Gained")
    endFunction
endProperty

bool property IsInfamyEnabled
    bool function get()
        return GetBool("Infamy Enabled")
    endFunction
endProperty

bool property IsInfamyRecognized
    bool function get()
        return CurrentInfamy >= Prison.InfamyRecognizedThreshold
    endFunction
endProperty

bool property IsInfamyKnown
    bool function get()
        return CurrentInfamy >= Prison.InfamyKnownThreshold
    endFunction
endProperty

int property InfamyGainedDaily
    ;/
        Prison.InfamyGainedDaily: 40
        Prison.InfamyGainedDailyFromBountyPercentage: 1.44%
        Bounty: 3000
        <=> floor(3000 * (1.44/100) + 40)
        <=> floor(3000 * 0.0144) + 40
        <=> floor(43.2) + 40
        <=> 43 + 40 = 83
    /;
    int function get()
        if (IsInfamyKnown && Prison.InfamyGainModifierKnown != 0)
            return ((Round(Bounty * Prison.InfamyGainedDailyOfCurrentBounty) + Prison.InfamyGainedDaily) * \
                    float_if (Prison.InfamyGainModifierKnown < 0, (1 / abs(Prison.InfamyGainModifierKnown) as int), Prison.InfamyGainModifierKnown)) as int
                    
        elseif (IsInfamyRecognized && Prison.InfamyGainModifierRecognized != 0)
            return ((Round(Bounty * Prison.InfamyGainedDailyOfCurrentBounty) + Prison.InfamyGainedDaily) * \
                    float_if (Prison.InfamyGainModifierRecognized < 0, (1 / abs(Prison.InfamyGainModifierRecognized) as int), Prison.InfamyGainModifierRecognized)) as int
        endif

        return round(Bounty * Prison.InfamyGainedDailyOfCurrentBounty) + Prison.InfamyGainedDaily
    endFunction
endProperty

float property InfamyGainedPerUpdate
    ;/
        InfamyGainedDaily: 83
        TimeSinceLastUpdate: 0.16666666666666666666666666666667 (4 / 24) [4 Hours passed since last update]
        <=> ceil(83 * 0.16666666666666666666666666666667)
        <=> ceil(13.833333333333333333333333333334)
        <=> 14

        if 1 hour passed then TimeSinceLastUpdate = 0.16666666666666666666666666666667 / 4
        <=> TimeSinceLastUpdate: 0.04166666666666666666666666666667
        <=> ceil (83 * 0.04166666666666666666666666666667)
        <=> ceil (3.4583333333333333333333333333334)
        <=> 4
    /;
    float function get()
        return InfamyGainedDaily * TimeSinceLastUpdate
    endFunction
endProperty

bool property IsSentenceSet
    bool function get()
        return self.Sentence != 0
    endFunction
endProperty

ReferenceAlias property CellPackage
    ReferenceAlias function get()
        string packageId = self.GetString("Cell Package ID")

        if (!packageId)
             self.SetString("Cell Package ID", JailCell.GetSuitableCellPackage().GetName())
        endif

        return Prison.PrisonManager.GetCellPackageByName(packageId)
    endFunction
endProperty

bool property HasCellPackage
    bool function get()
        return CellPackage.GetActorReference() == this
    endFunction
endProperty

bool property HasCriminalPenalty
    bool function get()
        return Was("Infamy Penalty Applied")
    endFunction
endProperty

int __criminalPenaltySentence
int property CriminalPenaltySentence
    int function get()
        return __criminalPenaltySentence
    endFunction
endProperty

; Whether this prisoner will be stripped naked (used for determing jail cell type before actually assigning a cell, or any other action in the future that makes use of such property.)
bool property WillBeStrippedNaked auto

; Whether this prisoner will be stripped to their underwear (used for determing jail cell type before actually assigning a cell, or any other action in the future that makes use of such property.)
bool property WillBeStrippedToUnderwear auto

; Whether this prisoner was stripped naked
bool property IsStrippedNaked auto

; Whether this prisoner was stripped to their underwear
bool property IsStrippedToUnderwear auto

bool property IsStripped
    bool function get()
        return IsStrippedNaked || IsStrippedToUnderwear
    endFunction
endProperty

bool property IsClothed
    bool function get()
        return self.Is("Clothed")
    endFunction
endProperty

Armor[] __prisonOutfit
Armor[] property PrisonOutfit
    Armor[] function get()
        return __prisonOutfit
    endFunction
endProperty

; ==========================================================
;                            States
; ==========================================================

state Processing
endState

state Awaiting
    event OnUpdateGameTime()
        EventManager.SendError("Updating in the Awaiting state, should not happen!", "{Awaiting} ["+ Name +"] Prisoner::OnUpdateGameTime")
    endEvent
endState

; While this Prisoner is being escorted
state Escorting
endState

state Releasing
    event OnBeginState()
    endEvent

    event OnUpdateGameTime()
    endEvent
endState

state Released
    event OnBeginState()
        ; Debug("{Released} ("+ Name +") Prisoner::OnBeginState", "this: " + this + ", HasCellPackage: " + self.HasCellPackage + ", Cell Package: " + self.CellPackage + ", Cell Package Actor Reference: " + CellPackage.GetActorReference())

        if (self.IsNPC())
            self.NPC_RestoreOriginalOutfit()
        endif

        if (self.IsNPC() && self.HasCellPackage)
            self.NPC_UnbindFromCell()
        endif

        self.UpdateTimeJailed()
        self.UpdateInfamy()    
    endEvent

    event OnUpdateGameTime()
        EventManager.SendError("Updating in the Released state, should not happen!", "{Released} ["+ Name +"] Prisoner::OnUpdateGameTime")
    endEvent
endState

; While this Prisoner is imprisoned in their cell
state Imprisoned
    event OnBeginState()
        ; Debug("[state: "+ self.GetState() +"] ["+ Name +"] Prisoner::OnBeginState", self.Name + "'s Bounty: " + Bounty)

        ; Captor should probably be destroyed in RPB_Captor, because more Prisoners/Arrestees may depend on it
        ; we could check if that Captor has any prisoners left to escort, if not, destroy the reference.
        ; Captor.Destroy()

        ; At this point, we can delete the prisoner's arrest state
        self.DestroyArrestState()

        self.RegisterLastUpdate()
        RegisterForUpdateGameTime(1.0)
        SetBool("Imprisoned", true)
    endEvent

    event OnUpdateGameTime()
        ; ; Test - Don't let NPC update
        ; if (self.IsNPC())
        ;     return
        ; endif
        ; Dont update if the player is not nearby, let Prison Monitor handle it
        if (!Prison.ShouldActivelyMonitorPrisoner(self))
            Prison.SendMonitoringRequest()
            return
        endif

        self.UpdateInfamy()
        self.UpdateTimeJailed() ; Must be updated in some other way, otherwise it will reset to 0 on next imprisonment
 
        if (self.IsSentenceServed)
            Prison.SendReleaseRequest(self)
            return
        endif

        ; Debug("("+ Name +") Prisoner::OnUpdateGameTime", "this: " + this)
        ; Debug("("+ Name +") Prisoner::OnUpdateGameTime", "ActorVars: " + GetContainerList(RPB_StorageVars.GetObjectHandleOnForm(this, "ActorVars")))
        Debug("("+ Name +") Prisoner::OnUpdateGameTime", "Time Jailed: " + RPB_StorageVars.GetFloatOnForm(Prison.Hold + "::Time Jailed", this, "ActorVars"))

        Prison.DEBUG_ShowPrisonerSentenceInfo(self, true)
        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "("+ self.GetActor() +") Cell Package: " + self.CellPackage)
        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "Outfit: " + self.PrisonOutfit)
        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "this: " + this)


        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "currentTimeServedStored: " + currentTimeServedStored)

        self.RegisterLastUpdate()
        RegisterForSingleUpdateGameTime(1.0)
        RegisterForSingleUpdate(10.0)
        ; Debug("[state: Imprisoned] ["+ Name +"] Prisoner::OnUpdateGameTime", self.Name + "'s Bounty: " + Bounty)
        ; self.DEBUG_ShowHoldStats()

    endEvent
endState

; When or while this Prisoner is escaping or has escaped
state Escape
    event OnBountyGained()
        Debug("[state: Escape] ["+ Name +"] Prisoner::OnBountyGained", "Currently escaping, not storing bounty!")
    endEvent

    function RestoreBounty()
        parent.RestoreBountyForFaction(Prison.PrisonFaction) ; Restore the Bounty
        
        if (Should("Account for Time Served"))
            ; Take away the bounty from the time already served
            int timeServedAsBounty = DaysSinceTimeOfImprisonment * GetInt("Bounty to Sentence")
            self.ModCrimeGold(-timeServedAsBounty)
        endif
    endFunction
endState

; When resting at a bed to serve the time
;/
    To avoid any problems with possible imprisoned NPC's,
    process all of the NPC's that are imprisoned with less
    time left on their sentence compared to the Player.

    This includes deleveling and any stat updates.
    After that, the Player can be released,
    this way we avoid invalid NPC stats.

    The NPC's that have more time on their sentence compared to the player should also be processed,
    but will not be released yet.
/;
state ServeOnRest
endState

; ==========================================================
;                           Scenes
; ==========================================================

function StartRestraining(Actor akRestrainer)
    Prison.StartRestrainingPrisoner(self, akRestrainer)
endFunction

function StartFrisking(Actor akSearcherGuard)
    Prison.StartFriskingPrisoner(self, akSearcherGuard)
endFunction

function StartStripping(Actor akStripperGuard)
    Prison.StartStrippingPrisoner(self, akStripperGuard)
endFunction

function StartGiveClothing(Actor akClothingGiver)
    Prison.StartGivingPrisonerClothing(self, akClothingGiver)
endFunction

function EscortToJail(Actor akEscort)
    Prison.EscortPrisonerToJail(self, akEscort)
endFunction

function EscortToCell(Actor akEscort)
    Prison.EscortPrisonerToCell(self, akEscort)
endFunction

; ==========================================================


; function DetermineReleaseTimeAdditionalHours()
;     Debug("["+ Name +"] Prisoner::DetermineReleaseTimeAdditionalHours", "ReleaseTime: " + ReleaseTime)
;     float currentGameHour = (Game.GetFormEx(0x38) as GlobalVariable).GetValue() ; 13.50 = 1:30 PM
;     float oneGameHour = 0.04166666666666666666666666666667


;     Debug("["+ Name +"] Prisoner::DetermineReleaseTimeAdditionalHours", "Prison.ReleaseTimeMinimumHour: " + Prison.ReleaseTimeMinimumHour + ", Prison.ReleaseTimeMaximumHour: " + Prison.ReleaseTimeMaximumHour)
;     ; If the release time window has already passed
;     if (currentGameHour > Prison.ReleaseTimeMaximumHour)
;         __additionalReleaseHours += 1 + (Prison.ReleaseTimeMinimumHour * oneGameHour) ; Add a day and the desired hour for release (taken from Minimum Hour)
;         Debug("["+ Name +"] Prisoner::DetermineReleaseTimeAdditionalHours", "(After Calculation) ReleaseTime: " + ReleaseTime)
;     endif
; endFunction

; ==========================================================
;                         Functions
; ==========================================================

;                Misc (TODO: Categorize these)
; ==========================================================

; Determines if at least a day has elapsed in prison
bool function HasDayElapsed()
    ; Add the time served from each update this runs
    accumulatedTimeServed += TimeSinceLastUpdate
    Debug("["+ Name +"] Prisoner::HasDayElapsed", "accumulatedTimeServed: " + accumulatedTimeServed + ", Has Day Elapsed: " + (accumulatedTimeServed >= 1))

    return accumulatedTimeServed >= 1
endFunction

function SetEscaped()
    SetBool("Escaped", true, "PrisonerEscape")
    self.IncrementStat("Times Escaped")
    
    if (self.IsPlayer())
        Game.IncrementStat("Jail Escapes")
    endif

    GotoState("Escape")
    Prison.OnPrisonerEscaped(self)
    self.Destroy()
endFunction

function SetEscapePenalty()
    string handleEscapeOn = GetString("Handle Escape On")

    int escapeBountyOfCurrentBounty     = (GetFloat("Escape Bounty of Current Bounty") * Bounty * 0.01) as int
    int escapeBountyFlat                = GetInt("Escape Bounty")
    int escapeBountySentenceMultiplier  = GetInt("Escape Bounty (Sentence)") * Sentence
    int escapeBountyCondition           = GetInt("Escape Bounty (Bounty Condition)")
    int escapeBountySentenceCondition   = GetInt("Escape Bounty (Sentence Condition)")

    ; Bounty penalty to apply
    int bountyPenalty = 0

    ; Whether the handling of the escape penalty is conditional
    bool isConditional = false

    if (handleEscapeOn == "Bounty")
        bountyPenalty += escapeBountyFlat + escapeBountyOfCurrentBounty

    elseif (handleEscapeOn == "Sentence")
        bountyPenalty += floor(escapeBountySentenceMultiplier * GetInt("Bounty to Sentence"))

    elseif (handleEscapeOn == "Bounty + Sentence")
        bountyPenalty += escapeBountyFlat + escapeBountyOfCurrentBounty
        bountyPenalty += floor(escapeBountySentenceMultiplier * GetInt("Bounty to Sentence"))

    elseif (handleEscapeOn == "Bounty (Conditionally)")
        bool meetsBountyCondition = Bounty >= escapeBountyCondition
        isConditional = true

        if (meetsBountyCondition)
            bountyPenalty += escapeBountyFlat + escapeBountyOfCurrentBounty
        endif

    elseif (handleEscapeOn == "Sentence (Conditionally)")
        bool meetsSentenceCondition = Sentence >= escapeBountySentenceCondition
        isConditional = true

        if (meetsSentenceCondition)
            bountyPenalty += floor(escapeBountySentenceMultiplier * GetInt("Bounty to Sentence"))    
        endif

    elseif (handleEscapeOn == "Bounty || Sentence (Conditionally OR)" || handleEscapeOn == "Bounty && Sentence (Conditionally AND)")
        bool meetsBountyCondition   = Bounty >= escapeBountyCondition
        bool meetsSentenceCondition = Sentence >= escapeBountySentenceCondition
        bool condition = bool_if (handleEscapeOn == "Bounty || Sentence (Conditionally OR)", meetsBountyCondition || meetsSentenceCondition, meetsBountyCondition && meetsSentenceCondition)
        isConditional = true

        if (condition)
            bountyPenalty += escapeBountyFlat + escapeBountyOfCurrentBounty
            bountyPenalty += floor(escapeBountySentenceMultiplier * GetInt("Bounty to Sentence"))    
        endif
    endif

    ; Handle fallback if conditions fail
    if (isConditional && !bountyPenalty && GetInt("Fallback Bounty") > 0)
        bountyPenalty = GetInt("Fallback Bounty")
    endif

    self.ModCrimeGold(bountyPenalty)
endFunction

; Moves this prisoner to Prison (To be processed)
function MoveToPrison(Actor akCaptor)
    ObjectReference escortLocation = Prison.GetRandomEscortLocation()

    ; Assign a container for this prisoner's belongings (if applicable)
    self.SetBelongingsContainer()
    self.MoveTo(escortLocation)

     ; Later maybe the captor shouldn't go, and instead there should be guards waiting in the prison
     ; They shouldn't go especially if they are not a guard (e.g: Bounty Hunter or other NPC)
    akCaptor.MoveTo(escortLocation)

    Prison.OnPrisonerTeleportedToPrison(self)

    SetBool("Go to Cell", true)
endFunction

function MoveToCell(bool abBeginImprisonment = true)
    if (self.IsImprisoned)
        EventManager.SendError(self.GetName() + " is already imprisoned in "+ Prison.Name + "!", "["+ Name +"] Prisoner::MoveToCell")
        return
    endif

    if (self.ShouldBeInCell && self.IsInCell)
        EventManager.SendError(self.GetName() + " is already in "+ self.PronounPossessiveObject +" cell: " + JailCell + "!", "["+ Name +"] Prisoner::MoveToCell")
        return
    endif

    if (!self.JailCell)
        EventManager.SendError("The prisoner " + Name + " has not been assigned a jail cell!", "["+ Name +"] Prisoner::MoveToCell")
        Prison.OnPrisonerImprisonmentFail(self, "Assign Cell")
        return
    endif

    self.MoveTo(JailCell)
    Prison.OnPrisonerTeleportedToCell(self, abBeginImprisonment)
endFunction

function QueueForImprisonment()
    ; Prison.QueuePrisonerForImprisonment(self)
     FunctionNotImplemented("Prisoner::QueueForImprisonment")
endFunction

function TriggerInfamyPenalty()
    if (!IsInfamyEnabled || CurrentInfamy <= 0 || Was("Infamy Penalty Applied") || (Bounty <= self.GetInt("Bounty to Trigger Infamy")))
        return
    endif

    ;/ const /; int INFAMY_RECOGNIZED_THRESHOLD     = self.GetInt("Infamy Recognized Threshold")
    ;/ const /; int INFAMY_KNOWN_THRESHOLD          = self.GetInt("Infamy Known Threshold")
    ;/ const /; float INFAMY_RECOGNIZED_PENALTY     = self.GetFloat("Recognized Criminal Penalty")
    ;/ const /; float INFAMY_KNOWN_PENALTY          = self.GetFloat("Known Criminal Penalty")

    ;/ const /; int INFAMY_NEUTRAL      = 0
    ;/ const /; int INFAMY_RECOGNIZED   = 1
    ;/ const /; int INFAMY_KNOWN        = 2

    int currentInfamyType
    float penaltyAsBounty = 0

    if (Bounty >= INFAMY_KNOWN_THRESHOLD)
        penaltyAsBounty = CurrentInfamy * (INFAMY_KNOWN_PENALTY * 0.01)
        currentInfamyType = INFAMY_KNOWN

    elseif (Bounty >= INFAMY_RECOGNIZED_THRESHOLD)
        penaltyAsBounty = CurrentInfamy * (INFAMY_RECOGNIZED_PENALTY * 0.01)
        currentInfamyType = INFAMY_RECOGNIZED

    else
        currentInfamyType = INFAMY_NEUTRAL
    endif

    ; Infamy shouldn't touch the Bounty, add to the Sentence instead
    int penaltyAsSentence = Round(penaltyAsBounty / Prison.BountyToSentence)
    __criminalPenaltySentence = penaltyAsSentence

    Debug("("+ Name +") Prisoner::TriggerInfamyPenalty", "currentInfamyType: " + currentInfamyType + ", penaltyAsBounty: " + penaltyAsBounty + ", penaltyAsSentence: " + penaltyAsSentence)

    self.IncreaseSentence(penaltyAsSentence, abShouldAffectBounty = false)
    self.SetBool("Infamy Penalty Applied", true)
endFunction

bool function IsRestrained()
    return this.GetEquippedArmorInSlot(59) != none
endFunction

function Cuff(bool abCuffInFront = false)
    Form cuffs = Game.GetFormEx(0xA081D2F)

    if (abCuffInFront)
        cuffs = Game.GetFormEx(0xA081D33)
    endif

    this.SheatheWeapon()
    this.EquipItem(cuffs, true, true)
endFunction

function Uncuff()
    int cuffsItemSlot = 59
    Form cuffs = this.GetEquippedArmorInSlot(cuffsItemSlot)

    this.UnequipItemSlot(cuffsItemSlot)
    this.RemoveItem(cuffs)
    Debug("["+ Name +"] Prisoner::Uncuff", "Uncuffed " + this)
endFunction

function Restrain()
    self.Cuff()
endFunction

;                  Body Searching & Clothing
; ==========================================================

;                      Frisking - Checkers
; ==========================================================

bool function ShouldFrisk()
    return true
endFunction

;                      Frisking - Getters
; ==========================================================
;                      Frisking - Setters
; ==========================================================
;                  Frisking - Configurators
; ==========================================================
;                      Frisking - Mutators
; ==========================================================

function Frisk()

endFunction

;               Stripping / Undressing - Checkers
; ==========================================================

bool function EvaluateStrippingCriteria()
    string strippingHandler = self.GetString("Handle Stripping On")

    if (strippingHandler == "Minimum Sentence")
        return self.Sentence >= self.GetInt("Sentence to Strip")

    elseif (strippingHandler == "Minimum Bounty")
        return self.Bounty >= self.GetInt("Bounty to Strip") || \
               self.BountyViolent >= self.GetInt("Violent Bounty to Strip")

    elseif (strippingHandler == "Unconditionally")
        return true
    endif

    return false
endFunction

bool function ShouldStrip()
    if (!self.Has("Allow Stripping"))
        return false
    endif

    ; TODO: Need to do a silent strip in case the prisoner still has items (but no clothes on, this would be used as an exploit)
    if (self.IsNaked())
        return false
    endif

    return self.EvaluateStrippingCriteria()
endFunction

bool function ShouldSilentlyStrip()
    if (!self.Has("Allow Stripping"))
        return false
    endif

    if (!self.IsNaked() && !self.IsInUnderwear())
        return false
    endif

    ; Check for the items the Prisoner has
    ; Remove them according to the Stripping Thoroughness


    return self.EvaluateStrippingCriteria()
endFunction

;               Stripping / Undressing - Getters
; ==========================================================



;               Stripping / Undressing - Setters
; ==========================================================


;           Stripping / Undressing - Configurators
; ==========================================================

;/
    Determines whether this Prisoner will be stripped naked or to underwear
    based on several factors.

    If stripping naked is not possible, then it will fallback to stripping to underwear.
    Likewise, if stripping to underwear is not possible, it will default to stripping naked.
/;
function DetermineStrippingType()
    bool hasUnderwearWorn           = self.HasUnderwear()
    bool isAbleToStripNaked         = Config.HasNudeBodyModInstalled
    bool isAbleToStripToUnderwear   = (isAbleToStripNaked && Config.HasUnderwearBodyModInstalled && hasUnderwearWorn) || !isAbleToStripNaked

    self.WillBeStrippedNaked        = (isAbleToStripNaked       && (StrippingThoroughness >= 10 || !isAbleToStripToUnderwear))
    self.WillBeStrippedToUnderwear  = (isAbleToStripToUnderwear && (StrippingThoroughness < 10  || !isAbleToStripNaked))

    DebugParams( \ 
        hasUnderwearWorn + "," + isAbleToStripNaked + "," + isAbleToStripToUnderwear + "," + self.WillBeStrippedNaked + "," + self.WillBeStrippedToUnderwear, \
        "hasUnderwearWorn, isAbleToStripNaked, isAbleToStripToUnderwear, WillBeStrippedNaked, WillBeStrippedToUnderwear", \
        "("+ Name +") Prisoner::DetermineStrippingType" \ 
    )

    ; Assert (WIP)
    EventManager.SendError( \ 
        "An error has occurred, cannot strip prisoner both naked and to underwear, logic error!", \ 
        "("+ Name +") Prisoner::DetermineStrippingType", \ 
        self.WillBeStrippedNaked == self.WillBeStrippedToUnderwear \
    )
endFunction

;                      Stripping - Mutators
; ==========================================================

function Strip(bool abRemoveUnderwear = true)
    if (!self.PrisonerBelongingsContainer)
        EventManager.SendError("The prisoner hasn't had a belongings container assigned to them, cannot strip!", "["+ Name +"] Prisoner::Strip")
        return
    endif

    ; int itemCount = this.GetNumItems()
    ; Form[] items = this.GetContainerForms()

    ; int i = 0
    ; while (i < items.Length)
    ;     Form item = items[i]
    ;     int thisItemCount = this.GetItemCount(item)

    ;     ObjectReference droppedItem = this.DropObject(item, thisItemCount)
    ;     ; if (droppedItem.IsOffLimits())
    ;         ; Debug("["+ Name +"] Prisoner::OnUpdate", droppedItem + "("+ droppedItem.GetName() +") is stolen!")
    ;         ObjectReference evidenceChest = Prison.GetRandomPrisonerContainer("Evidence") as ObjectReference
    ;         evidenceChest.AddItem(droppedItem)
    ;     ; endif
    ;     i += 1
    ; endWhile

    Armor underwearTop      = none 
    Armor underwearBottom   = none 

    if (!abRemoveUnderwear)
        underwearTop    = self.GetUnderwear("Top")
        underwearBottom = self.GetUnderwear("Bottom")

        NPC_SaveUnderwear(underwearTop, underwearBottom)
    endif

    self.UnequipAll()
    self.RemoveAllItems(PrisonerBelongingsContainer, true, true) ; Remove and put all the items in the prisoner's possession in the assigned prisoner container
    self.UnequipHands()
    self.SheatheWeapon()

    self.OnStripped()

    ; ObjectReference evidenceChest = Game.GetForm(0x108D37) as ObjectReference ; temp
    ; evidenceChest.SetDisplayName("Vivienne Onis' Belongings") ; temp
    ; PrisonerBelongingsContainer.AddItem(evidenceChest) ; temp

    ; TODO: Find a way to keep the underwear without recovering NPC's body clothing (skyrim bug?), maybe filters? (FIXED: Change Actor Outfit)
    if (!abRemoveUnderwear)
        ; Equip Underwear
        PrisonerBelongingsContainer.RemoveItem(underwearTop, abSilent = true, akOtherContainer = this)
        PrisonerBelongingsContainer.RemoveItem(underwearBottom, abSilent = true, akOtherContainer = this)

        self.EquipItem(underwearTop)
        self.EquipItem(underwearBottom)
    endif

    ; DebugWithArgs("["+ Name +"] Prisoner::Strip", "abRemoveUnderwear: " + YesNo(abRemoveUnderwear), \ 
    ;     "\n\t Stripped " + Name + string_if (self.IsStrippedNaked, " naked.", " to underwear.") + \
    ;     "\n\t Prisoner Container: " + PrisonerBelongingsContainer \
    ; )
    ; Debug("["+ Name +"] Prisoner::Strip", "Stripped "+ Name + " naked.", self.IsStrippedNaked)
    ; Debug("["+ Name +"] Prisoner::Strip", "Stripped "+ Name + " to underwear.", self.IsStrippedToUnderwear)
endFunction

function StripSilently()
    if (!self.PrisonerBelongingsContainer)
        EventManager.SendError("The prisoner hasn't had a belongings container assigned to them, cannot strip silently!", "["+ Name +"] Prisoner::StripSilently")
        return
    endif

    Armor underwearTop      = self.GetUnderwear("Top")
    Armor underwearBottom   = self.GetUnderwear("Bottom")

    NPC_SaveUnderwear(underwearTop, underwearBottom)

    self.UnequipAll()
    self.RemoveAllItems(PrisonerBelongingsContainer, true, true) ; Remove and put all the items in the prisoner's possession in the assigned prisoner container
    self.UnequipHands()
    self.SheatheWeapon()
    self.OnStripped() ; Maybe use OnStrippedSilently?

    PrisonerBelongingsContainer.RemoveItem(underwearTop, abSilent = true, akOtherContainer = this)
    PrisonerBelongingsContainer.RemoveItem(underwearBottom, abSilent = true, akOtherContainer = this)

    self.EquipItem(underwearTop)
    self.EquipItem(underwearBottom)
endFunction

function RemoveUnderwear()
    if (!self.PrisonerBelongingsContainer)
        EventManager.SendError("The prisoner hasn't had a belongings container assigned to them, cannot remove underwear!", "["+ Name +"] Prisoner::RemoveUnderwear")
        return
    endif

    Armor underwearTop      = self.GetUnderwear("Top")
    Armor underwearBottom   = self.GetUnderwear("Bottom")

    if (underwearTop)
        this.RemoveItem(underwearTop, 1, true, PrisonerBelongingsContainer)
    endif

    if (underwearBottom)
        this.RemoveItem(underwearBottom, 1, true, PrisonerBelongingsContainer)
    endif

    self.OnUnderwearRemoved(underwearTop, underwearBottom)
endFunction

function UndressUpperBody()
    self.UnequipItemSlot(33)
    self.UnequipItemSlot(56)
    self.UnequipItemSlot(32)
endFunction

function UndressLowerBody()
    self.UnequipItemSlot(37)
    self.UnequipItemSlot(49)
    self.UnequipItemSlot(52)
endFunction

;                      Clothing - Checkers
; ==========================================================

bool function ShouldClothe()
    if (!self.GetBool("Allow Clothing"))
        return false
    endif

    ; If the prisoner is neither naked nor in underwear, do not clothe
    if ((!self.IsNaked() && !self.IsInUnderwear()))
        return false
    endif
    
    string clothingHandler  = self.GetString("Handle Clothing On")

    if (clothingHandler == "Maximum Sentence")
        int maxSentence = self.GetInt("Maximum Sentence to Clothe")
        if (self.Sentence > maxSentence)
            return false
        endif
        
    elseif (clothingHandler == "Maximum Bounty")
        int maxBounty           = self.GetInt("Maximum Bounty to Clothe")
        int maxViolentBounty    = self.GetInt("Maximum Violent Bounty to Clothe")
        if (self.BountyViolent > maxViolentBounty || self.Bounty > maxBounty)
            return false
        endif

    elseif (clothingHandler == "Unconditionally")
        return true
    endif

    return true
endFunction

bool function Outfit_MeetsConditions()
    if (!self.Is("Outfit::Conditional"))
        return true
    endif

    int outfitMinimumBounty = self.GetInt("Outfit::Minimum Bounty")
    int outfitMaximumBounty = self.GetInt("Outfit::Maximum Bounty")

    bool hasStrictlyMinimumBounty = (outfitMinimumBounty == outfitMaximumBounty)

    return  (hasStrictlyMinimumBounty   && Bounty >= outfitMinimumBounty) || \
            (!hasStrictlyMinimumBounty  && Bounty >= outfitMinimumBounty && Bounty <= outfitMaximumBounty)
endFunction

bool function Outfit_IsValid(int aiPieceCountToCheck = 4, Armor[] akOutfit = none)
    Armor[] outfitToVerify

    if (akOutfit != none)
        outfitToVerify = akOutfit
    else
        outfitToVerify = self.GetOutfit()
    endif

    int piecesVerified = 0
    int i = 0
    while (i < min(outfitToVerify.Length, aiPieceCountToCheck))
        if (outfitToVerify[i])
            piecesVerified += 1
        endif
        i += 1
    endWhile

    return piecesVerified >= 1
endFunction


;                      Clothing - Getters
; ==========================================================

Armor[] function GetConfiguredOutfit()
    Armor[] outfitPieces = new Armor[4]

    outfitPieces[0] = self.GetForm("Outfit::Head") as Armor
    outfitPieces[1] = self.GetForm("Outfit::Body") as Armor
    outfitPieces[2] = self.GetForm("Outfit::Hands") as Armor
    outfitPieces[3] = self.GetForm("Outfit::Feet") as Armor

    if (!Outfit_IsValid(akOutfit = outfitPieces))
        return none
    endif

    return outfitPieces
endFunction

Armor[] function GetOutfit()
    Armor[] outfitPieces = new Armor[4]

    outfitPieces[0] = self.GetForm("Outfit::Head") as Armor
    outfitPieces[1] = self.GetForm("Outfit::Body") as Armor
    outfitPieces[2] = self.GetForm("Outfit::Hands") as Armor
    outfitPieces[3] = self.GetForm("Outfit::Feet") as Armor

    ; Debug("["+ Name +"] Prisoner::GetOutfit", "Configured Outfit: " + outfitPieces)

    return outfitPieces
endFunction

;                      Clothing - Setters
; ==========================================================



;                      Clothing - Mutators
; ==========================================================

function DetermineClothingOutfit()
    bool prisonerMeetsOutfitCondition   = Outfit_MeetsConditions()
    Armor[] configuredOutfit            = self.GetConfiguredOutfit()

    ;/ const /; int OUTFIT_NONE         = 0
    ;/ const /; int OUTFIT_CONFIGURED   = 1
    ;/ const /; int OUTFIT_FALLBACK     = 2

    int outfitType = OUTFIT_NONE

    if (configuredOutfit && prisonerMeetsOutfitCondition)
        __prisonOutfit = configuredOutfit
        outfitType = OUTFIT_CONFIGURED

    elseif (UseDefaultOutfitAsFallback)
        __prisonOutfit = Prison.GetDefaultOutfit()
        outfitType = OUTFIT_FALLBACK
    endif

    ; Debug( \ 
    ;     "("+ Name +") Prisoner::DetermineClothingOutfit", \ 
    ;     "\n\tprisonerMeetsOutfitCondition: "+ prisonerMeetsOutfitCondition +" \n\tconfiguredOutfit: "+ configuredOutfit +" \n\toutfitType: "+ outfitType +" \n\tUseDefaultOutfitAsFallback: "+ UseDefaultOutfitAsFallback +" \n\tSentence: "+ Sentence + "\n" \
    ; )
 
    ; EventManager.SendInfo("Determined Configured Outfit: " + self.PrisonOutfit, "("+ Name +") Prisoner::DetermineClothingOutfit",  outfitType == OUTFIT_CONFIGURED)
    ; EventManager.SendInfo("Determined Fallback Outfit: " + self.PrisonOutfit, "("+ Name +") Prisoner::DetermineClothingOutfit",    outfitType == OUTFIT_FALLBACK)
    ; EventManager.SendInfo("No outfit is currently configured, and no fallback option!", "("+ Name +") Prisoner::DetermineClothingOutfit", outfitType == OUTFIT_NONE)
endFunction

function Clothe()
    if (!self.PrisonOutfit)
        EventManager.SendWarning("Tried to clothe prisoner " + Name + ", but there's no outfit configured!", "("+ Name +") Prisoner::Clothe")
        return
    endif

    EquipOutfit(self.PrisonOutfit)
    ; Debug("["+ Name +"] Prisoner::Clothe", "Applied Outfit: " + self.PrisonOutfit)

    self.OnClothed()
endFunction

;                      Sentence - Checkers
; ==========================================================

;                      Sentence - Getters
; ==========================================================

int function GetTimeServed(string timeUnit)
    int _timeServedDays = floor(TimeServed)

    if (timeUnit == "Days")
        return _timeServedDays
    endif

    float timeLeftOverOfDay     = (TimeServed - _timeServedDays) * 24 ; Hours and Minutes
    int _timeServedHoursOfDay   = floor(timeLeftOverOfDay)

    if (timeUnit == "Hours of Day")
        return _timeServedHoursOfDay
    endif

    float timeLeftOverOfHour        = (timeLeftOverOfDay - floor(timeLeftOverOfDay)) * 60 ; Minutes
    int _timeServedMinutesOfHour    = floor(timeLeftOverOfHour)

    if (timeUnit == "Minutes of Hour")
        return _timeServedMinutesOfHour
    endif

    float timeLeftOverOfMinute      = (timeLeftOverOfHour - floor(timeLeftOverOfHour)) * 60 ; Seconds
    int _timeServedSecondsOfMinute  = floor(timeLeftOverOfMinute)

    if (timeUnit == "Seconds of Minute")
        return _timeServedSecondsOfMinute
    endif
endFunction

int function GetTimeLeftInSentence(string timeUnit)
    int _timeLeftDays = floor(TimeLeftInSentence)

    if (timeUnit == "Days")
        return _timeLeftDays
    endif

    float _timeLeftOverOfDay    = (TimeLeftInSentence - _timeLeftDays) * 24 ; Hours and Minutes
    int _timeLeftHoursOfDay     = floor(_timeLeftOverOfDay)

    if (timeUnit == "Hours of Day")
        return _timeLeftHoursOfDay
    endif

    float _timeLeftOverOfHour   = (_timeLeftOverOfDay - floor(_timeLeftOverOfDay)) * 60 ; Minutes
    int _timeLeftMinutesOfHour  = floor(_timeLeftOverOfHour)

    if (timeUnit == "Minutes of Hour")
        return _timeLeftMinutesOfHour
    endif

    float _timeLeftOverOfMinute   =  (_timeLeftOverOfHour - floor(_timeLeftOverOfHour)) * 60 ; Seconds
    int _timeLeftSecondsOfMinute  =  floor(_timeLeftOverOfMinute)

    if (timeUnit == "Seconds of Minute")
        return _timeLeftSecondsOfMinute
    endif
endFunction

;/
    Retrieves the Sentence for this Prisoner based on their current bounty at the time of the call.
    The bounty that is taken into consideration is the latent bounty (Bounty upon being arrested).

    The sentence formula is as follows: (Bounty + (BountyViolent * BountyExchange)) / BountyToSentence
    Example: (2500 + (500 * 2)) / 170 = 20.5 <=> 21 Days Sentence
/;
int function GetSentenceFromBounty()
    int nonViolent  = self.GetLatentBounty(abViolent = false)
    int violent     = self.GetLatentBounty(abNonViolent = false)

    return (nonViolent + Round(violent * (100 / Prison.BountyExchange))) / Prison.BountyToSentence
endFunction


;                      Sentence - Mutators
; ==========================================================

function RegisterTimeOfImprisonment()
    SetFloat("Time of Imprisonment", CurrentTime)
    SetInt("Minute of Imprisonment", RPB_Utility.GetCurrentMinute())
    SetInt("Hour of Imprisonment", RPB_Utility.GetCurrentHour())
    SetInt("Day of Imprisonment", RPB_Utility.GetCurrentDay())
    SetInt("Month of Imprisonment", RPB_Utility.GetCurrentMonth())
    SetInt("Year of Imprisonment", RPB_Utility.GetCurrentYear())
endFunction

function UndetermineSentence()
    if (self.IsUndeterminedSentence)
        Warn("The prisoner " + self.Name + " already has an undetermined sentence.")
        return
    endif

    self.IsUndeterminedSentence = true
endFunction

;/
    Sets a new sentence from the point in time of the time already served in prison.
    If the time already served goes beyond the original sentence, this is essentially increasing the sentence beyond
    its initial purpose.

    This is most useful when the time served goes beyond the sentence, in all other cases, IncreaseSentence() should be used instead.

    int     @aiSentenceInDays: The days to set the new sentence from the time already served.
    bool?   @abShouldAffectBounty: Whether the sentence should affect the bounty.
/;
function SetSentenceFromTimeServed(int aiSentenceInDays, bool abShouldAffectBounty = false)
    ; Sets a new sentence from the time the prisoner has served at the point of calling this function, essentially increasing the already existing sentence

    ; Original Sentence: 30
    ; TimeServed: 40 (Exceeds sentence by 10d)
    ; aiSentenceInDays: 20
    ; New Sentence: 40 + 20 = 60 (20d left)
    SetInt("Sentence", (TimeServed as int) +  aiSentenceInDays)

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = aiSentenceInDays * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    endif

    self.OnSentenceSet(Sentence, CurrentTime)
endFunction

function SetSentence(int aiSentenceInDays = 0, bool abShouldAffectBounty = true)
    if (GetBool("Sentence Set"))
        Debug("["+ Name +"] Prisoner::SetSentence", "A sentence has already been set for this prisoner ("+ self.GetIdentifier() +"). \nConsider using IncreaseSentence() or DecreaseSentence() instead.")
        return
    endif

    if (self.IsUndeterminedSentence && aiSentenceInDays == 0)
        Debug("["+ Name +"] Prisoner::SetSentence", "Setting an undetermined sentence for prisoner " + self.GetActor())
        return
    endif

    ; Set a sentence based on params
    SetInt("Sentence", \ 
        aiValue     = int_if (aiSentenceInDays > 0, aiSentenceInDays, self.GetSentenceFromBounty()), \
        aiMinValue  = Prison.MinimumSentence, \
        aiMaxValue  = Prison.MaximumSentence \
    )

    ; if (abShouldAffectBounty)
    ;     int bountyEquivalentOfSentence = Sentence * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
    ;     SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    ; endif

    SetBool("Sentence Set", true)
    self.OnSentenceSet(Sentence, CurrentTime)
endFunction

function IncreaseSentence(int aiDaysToIncreaseBy, bool abShouldAffectBounty = true)
    int previousSentence    = Sentence
    int newSentence         = previousSentence + Max(0, aiDaysToIncreaseBy) as int

    ; Set the sentence
    SetInt("Sentence", \ 
        aiValue     = Sentence + aiDaysToIncreaseBy, \
        aiMinValue  = Prison.MinimumSentence, \
        aiMaxValue  = Prison.MaximumSentence \
    )

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = Sentence * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    endif

    self.OnSentenceChanged(previousSentence, newSentence, aiDaysToIncreaseBy > 0, abShouldAffectBounty)
endFunction

function DecreaseSentence(int aiDaysToDecreaseBy, bool abShouldAffectBounty = true)
    int previousSentence    = Sentence
    int newSentence         = previousSentence - Max(0, aiDaysToDecreaseBy) as int

    ; Set the sentence
    SetInt("Sentence", \ 
        aiValue     = Sentence - aiDaysToDecreaseBy, \
        aiMinValue  = Prison.MinimumSentence, \
        aiMaxValue  = Prison.MaximumSentence \
    )

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = Sentence * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    endif

    self.OnSentenceChanged(previousSentence, newSentence, newSentence > previousSentence, abShouldAffectBounty)
endFunction

;                      Release - Checkers
; ==========================================================

bool function IsReleaseOnWeekend()
    int releaseDate     = RPB_Utility.GetDateFromDaysPassed(DayOfImprisonment, MonthOfImprisonment, YearOfImprisonment, Sentence)
    int releaseDay      = RPB_Utility.GetStructMemberInt(releaseDate, "day")
    int releaseMonth    = RPB_Utility.GetStructMemberInt(releaseDate, "month")
    int releaseYear     = RPB_Utility.GetStructMemberInt(releaseDate, "year")

    int dayOfWeek = RPB_Utility.CalculateDayOfWeek(releaseDay, releaseMonth, releaseYear)
    Debug("["+ Name +"] Prisoner::IsReleaseOnWeekend", "releaseDate: " + releaseDay + "/" + releaseMonth + "/" + releaseYear + ", IsWeekend: " + RPB_Utility.IsWeekend(releaseDay, releaseMonth, releaseYear) + ", Day of Week: " + RPB_Utility.GetDayOfWeekName(dayOfWeek))
    return RPB_Utility.IsWeekend(releaseDay, releaseMonth, releaseYear)
endFunction

bool function IsReleaseOnLoredas()
    int releaseDate     = RPB_Utility.GetDateFromDaysPassed(DayOfImprisonment, MonthOfImprisonment, YearOfImprisonment, Sentence)
    int releaseDay      = RPB_Utility.GetStructMemberInt(releaseDate, "day")
    int releaseMonth    = RPB_Utility.GetStructMemberInt(releaseDate, "month")
    int releaseYear     = RPB_Utility.GetStructMemberInt(releaseDate, "year")

    return RPB_Utility.IsLoredas(releaseDay, releaseMonth, releaseYear)
endFunction

bool function IsReleaseOnSundas()
    int releaseDate     = RPB_Utility.GetDateFromDaysPassed(DayOfImprisonment, MonthOfImprisonment, YearOfImprisonment, Sentence)
    int releaseDay      = RPB_Utility.GetStructMemberInt(releaseDate, "day")
    int releaseMonth    = RPB_Utility.GetStructMemberInt(releaseDate, "month")
    int releaseYear     = RPB_Utility.GetStructMemberInt(releaseDate, "year")

    return RPB_Utility.IsSundas(releaseDay, releaseMonth, releaseYear)
endFunction

bool __hasExtraReleaseTimeHours
bool function HasReleaseTimeExtraHours()
    return __hasExtraReleaseTimeHours
endFunction

;                      Release - Getters
; ==========================================================

float function GetReleaseTime(bool abIncludeMinutes = true)
    float oneGameHour = 0.04166666666666666666666666666667

    if (abIncludeMinutes)
        return TimeOfImprisonment + (oneGameHour * 24 * Sentence)
    endif

    return floor(TimeOfImprisonment) + (oneGameHour * 24 * Sentence)
endFunction

int function GetReleaseTimeHour()
    int releaseTimeHour = (ReleaseTime - math.floor(ReleaseTime)) as int

    ; Get the release hour and minutes
    float releaseHourAndMinutes = releaseTimeHour / 0.0416

    int releaseMinutes = Round((releaseHourAndMinutes - math.floor(releaseHourAndMinutes)) * 60)

    return releaseMinutes
endFunction

float function GetIndefiniteReleaseTime()
    return self.GetReleaseTime() + RPB_Utility.GetDaysPassed() + 1
endFunction

float function GetReleaseTimeExtraHours()
    float gameHour = 0.04166666666666666666666666666667
    return 1 + (Prison.ReleaseTimeMinimumHour * gameHour) ; Add 1 day and round to the time configured by Prison.ReleaseTimeMinimumHour
endFunction

;                      Release - Mutators
; ==========================================================

function FastForwardToRelease()
    Prison.SetPlayerFastForwardingToRelease(true)

    GotoState("ServeOnRest")
    self.UnregisterForUpdates()

    ; If the Release must fall in between Minimum and Maximum release hours, set the hour to the minimum before passing the days.
    if (self.HasReleaseTimeExtraHours())
        RPB_Utility.SetGameHour(Prison.ReleaseTimeMinimumHour)
        Debug("["+ Name +"] Prisoner::FastForwardToRelease", "Setting Game Hour to Release Time Minimum Hour: " + RPB_Utility.GetTimeAs12Hour(Prison.ReleaseTimeMinimumHour))
    endif

    ; Process all NPC Prisoners that have a Sentence less than the Player's
    ; This should probably be processed globally for all Prisons, but just for testing it's done with the same one the Player is in.
    Prison.ReleasePrisonersWithSentenceLessThan(TimeLeftInSentence)

    ; Pass the time
    int timeLeft = Math.Ceiling(TimeLeftInSentence)
    RPB_Utility.PassTimeInDays(timeLeft)

    self.UpdateTimeJailed()
    self.UpdateInfamy()

    ; float currentTimeBeforeChanges = CurrentTime
    ; __currentTimeOverride = CurrentTime + timeLeft

    ; Debug("["+ Name +"] Prisoner::FastForwardToRelease", "CurrentTime: " + currentTimeBeforeChanges + ", timeLeft: " + timeLeft + ", currentTimeOverride: " + __currentTimeOverride + ", TimeLeftInSentence: " + TimeLeftInSentence)

    GotoState("Awaiting")

    Prison.SendReleaseRequest(self)
    Prison.SetPlayerFastForwardingToRelease(false)

    ; Maybe process NPC states now, shouldn't be in this function though. (maybe OnDestroy()?)
endFunction

function DetermineReleaseTimeAdditionalHours()
    Debug("["+ Name +"] Prisoner::DetermineReleaseTimeAdditionalHours", "ReleaseTime: " + ReleaseTime)
    ; float currentGameHour = (Game.GetFormEx(0x38) as GlobalVariable).GetValue() ; 13.50 = 1:30 PM
    float currentGameHour = RPB_Utility.GetCurrentHourFloat() ; 13.50 = 1:30 PM

    Debug("["+ Name +"] Prisoner::DetermineReleaseTimeAdditionalHours", "Prison.ReleaseTimeMinimumHour: " + Prison.ReleaseTimeMinimumHour + ", Prison.ReleaseTimeMaximumHour: " + Prison.ReleaseTimeMaximumHour)
    ; If the release time window has already passed
    if (currentGameHour > Prison.ReleaseTimeMaximumHour)
        __hasExtraReleaseTimeHours = true
    endif
endFunction

function ReturnBelongings()
    PrisonerBelongingsContainer.RemoveAllItems(this, false, true)
endFunction

;                        Imprisonment
; ==========================================================

;/
    Main function that handles the imprisonment of this Prisoner.
/;
function Imprison()
    if (!self.HasStateRequiredForImprisonment)
        EventManager.SendError(Name + " does not have the required state for "+ self.PronounPossessiveObject +" imprisonment, cannot continue!", "["+ Name +"] Prisoner::Imprison")
        return
    endif

    if (self.IsImprisoned)
        EventManager.SendError(self.GetName() + " is already imprisoned in "+ Prison.Name + "!", "["+ Name +"] Prisoner::Imprison")
        return
    endif

    ; return

    float startBench = StartBenchmark()
    self.OnImprisoned()
    GotoState("Imprisoned") ; State when the prisoner is in the cell, check for updates for sentence, etc...

    string sentenceFormatted    = RPB_Utility.GetTimeFormatted(Sentence, abIncludeHours = false)
    string releaseDateFormatted = Prison.GetTimeOfReleaseFormatted(self)

    if (self.ShowSentence && !self.IsUndeterminedSentence)
        Config.NotifyJail("Your sentence was set at "+ sentenceFormatted +" in " + Prison.Name, self.IsPlayer())
        Config.NotifyJail(self.GetName() + " has been sentenced to "+ sentenceFormatted +" in " + Prison.Name, self.IsNPC())
    endif
    
    if (self.ShowReleaseTime && !self.IsUndeterminedSentence)
        Config.NotifyJail("Your release is due on " + releaseDateFormatted, self.IsPlayer())
        Config.NotifyJail(self.GetName() + "'s release is due on " + releaseDateFormatted, !self.IsPlayer())
    endif

    EndBenchmark(startBench, "Ended ["+ Name +"] Prisoner::Imprison")
endFunction


;                       Stats - Checkers
; ==========================================================

bool function HasActiveBounty()
    return parent.HasActiveBountyForFaction(Prison.PrisonFaction)
endFunction

bool function HasLatentBounty()
    return parent.HasLatentBountyForFaction(Prison.PrisonFaction)
endFunction

;/
    Gets the active bounty for this Actor, that is, the bounty that is currently set on a Faction when
    the Actor is wanted by that Faction.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.

    If no parameters are specified, both the non-violent and violent bounties are returned.
/;
int function GetActiveBounty(bool abNonViolent = true, bool abViolent = true)
    return parent.GetActiveBountyForFaction(Prison.PrisonFaction, abNonViolent, abViolent)
endFunction

;/
    Gets the latent bounty for this Actor, that is, the bounty that is stored when Arrested/Jailed.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.

    If no parameters are specified, both the non-violent and violent bounties are returned.
/;
int function GetLatentBounty(bool abNonViolent = true, bool abViolent = true)
    return parent.GetLatentBountyForFaction(Prison.PrisonFaction, abNonViolent, abViolent)
endFunction

;                Stats - Setters / Modifiers
; ==========================================================

function SetCrimeGold(int aiGold)
    parent.SetCrimeGoldForFaction(Prison.PrisonFaction, aiGold)
endFunction

function SetCrimeGoldViolent(int aiGold)
    parent.SetCrimeGoldViolentForFaction(Prison.PrisonFaction, aiGold)
endFunction

function ModCrimeGold(int aiAmount, bool abViolent = false)
    parent.ModCrimeGoldForFaction(Prison.PrisonFaction, aiAmount, abViolent)
endFunction

;                      Stats - Mutators
; ==========================================================

; Transfers the Active Bounty into the Latent Bounty.
function HideBounty()
    parent.HideBountyForFaction(Prison.PrisonFaction)
endFunction

; Restores the Active Bounty from the Latent Bounty.
function RestoreBounty()
    parent.RestoreBountyForFaction(Prison.PrisonFaction)
endFunction

;                    Deleveling - Checkers
; ==========================================================

bool function ShouldDelevelSkillOfType(string asSkillType)
    if (asSkillType != "Stat" && asSkillType != "Perk")
        DebugError("Prisoner::ShouldDelevelSkillOfType", "Invalid skill type, valid options are: Stat, Perk | Got: " + asSkillType)
        return false
    endif

    int dayToStartLosingSkills = GetInt("Day to Start Losing Skills ("+ asSkillType +")")

    ; DebugWithArgs("["+ Name +"] Prisoner::ShouldDelevelSkillOfType", asSkillType, "dayToStartLosingSkills != 1 && dayToStartLosingSkills >= TimeServed: " + (dayToStartLosingSkills != 1 && dayToStartLosingSkills >= self.TimeServed))
    ; DebugWithArgs("["+ Name +"] Prisoner::ShouldDelevelSkillOfType", asSkillType, "dayToStartLosingSkills: " + dayToStartLosingSkills)
    ; DebugWithArgs("["+ Name +"] Prisoner::ShouldDelevelSkillOfType", asSkillType, "TimeServed: " + self.TimeServed)

    if (dayToStartLosingSkills != 1 && dayToStartLosingSkills >= self.TimeServed)
        ; Don't delevel, property is set to a specific day to start and the prisoner hasn't been in prison for that long yet.
        return false
    endif

    int randomChance    = Utility.RandomInt(0, 100)
    int skillLossChance = GetInt("Chance to Lose Skills ("+ asSkillType +")")

    if (skillLossChance == 0)
        return false
    endif

    ; DebugWithArgs("["+ Name +"] Prisoner::ShouldDelevelSkillOfType", asSkillType, "randomChance: " + randomChance + ", skillLossChance: " + skillLossChance)

    return randomChance <= skillLossChance
endFunction


;                    Deleveling - Getters
; ==========================================================

int function GetSkillLossHandlingType()
    string handleSkillLossOn = GetString("Handle Skill Loss")

    if (handleSkillLossOn == "All Skills")
        return SKILL_LOSS_HANDLING_ALL_SKILLS

    elseif (handleSkillLossOn == "All Stat Skills (Health, Stamina, Magicka)")
        return SKILL_LOSS_HANDLING_ALL_STAT_SKILLS

    elseif (handleSkillLossOn == "All Perk Skills")
        return SKILL_LOSS_HANDLING_ALL_PERK_SKILLS

    elseif (handleSkillLossOn == "1x Random Stat Skill")
        return SKILL_LOSS_HANDLING_RANDOM_STAT_SKILL
        
    elseif (handleSkillLossOn == "1x Random Perk Skill")
        return SKILL_LOSS_HANDLING_RANDOM_PERK_SKILL

    elseif (handleSkillLossOn == "Random")
        return SKILL_LOSS_HANDLING_RANDOM
    endif

    return -1
endFunction

; Returns the minimum level this stat can be when deleveled
int function GetMinimumSkillValue(string asSkill)
    ; TODO: Add logic depending on which skill is passed in, maybe process it from JSON
    ; TODO: Possibly chain to other stats to delevel if this one has met the minimum value (e.g: Health reached minimum, delevel Stamina or Magicka)
    return Config.GetSkillLevelCap(asSkill)
    ; if (RPB_Utility.IsStatSkill(asSkill))
    ;     RPB_Utility.Trace("["+ Name +"] Prisoner::GetMinimumSkillValue", "It's a stat skill: " + asSkill)
    ;     return 50
    ; else
    ;     RPB_Utility.Trace("["+ Name +"] Prisoner::GetMinimumSkillValue", "It's a perk skill: " + asSkill)
    ;     return 10
    ; endif
endFunction


;              Deleveling - Setters / Modifiers
; ==========================================================



;                    Deleveling - Mutators
; ==========================================================

bool function DelevelSkill(string asSkill)
    int statValue               = this.GetBaseActorValue(asSkill) as int
    int configuredLossAmount    = Config.GetDelevelingSkillValue(asSkill)
    int newStatValue            = statValue - configuredLossAmount
    int minimumSkillValue       = self.GetMinimumSkillValue(asSkill)

    if (newStatValue < minimumSkillValue)
        ; Skill reached minimum level, don't delevel
        Debug("["+ Name +"] Prisoner::DelevelSkill", "Did not delevel Skill " + asSkill + " as it has reached the minimum level!")
        Info("["+ Name +"] Did not delevel Skill " + asSkill + " as it has reached the minimum level!")
        return false
    endif

    this.SetActorValue(asSkill, newStatValue)
    Debug("["+ Name +"] Prisoner::DelevelSkill", "Deleveling Skill " + asSkill + " ("+ "Was: " + statValue + ", Is: " + newStatValue + ")")
    return true
endFunction

function PerformDeleveling()
    int handlingType = self.GetSkillLossHandlingType()

    Debug("["+ Name +"] Prisoner::PerformDeleveling", "Handling Type: " + handlingType)

    if  (handlingType == SKILL_LOSS_HANDLING_RANDOM_STAT_SKILL || \
         handlingType == SKILL_LOSS_HANDLING_RANDOM_PERK_SKILL || \
         handlingType == SKILL_LOSS_HANDLING_RANDOM)

        string skillType = none
        if (handlingType == SKILL_LOSS_HANDLING_RANDOM_STAT_SKILL)
            skillType = "Stat"
        elseif (handlingType == SKILL_LOSS_HANDLING_RANDOM_PERK_SKILL)
            skillType = "Perk"
        else
            int randomChance = Utility.RandomInt(0, 1)
            skillType = string_if (randomChance == 0, "Stat", "Perk")
        endif

        if (self.ShouldDelevelSkillOfType(skillType))
            string randomStat = RPB_Utility.GetRandomSkill(skillType)
            self.DelevelSkill(randomStat)
        endif
    
    elseif (handlingType == SKILL_LOSS_HANDLING_ALL_STAT_SKILLS || \
            handlingType == SKILL_LOSS_HANDLING_ALL_PERK_SKILLS || \
            handlingType == SKILL_LOSS_HANDLING_ALL_SKILLS)

        bool shouldDelevelStatSkills = handlingType == SKILL_LOSS_HANDLING_ALL_STAT_SKILLS || handlingType == SKILL_LOSS_HANDLING_ALL_SKILLS
        bool shouldDelevelPerkSkills = handlingType == SKILL_LOSS_HANDLING_ALL_PERK_SKILLS || handlingType == SKILL_LOSS_HANDLING_ALL_SKILLS

        if (shouldDelevelStatSkills)
            string[] statSkills = RPB_Utility.GetStatSkills()

            int statSkillCount = 0
            while (statSkillCount < statSkills.Length)
                if (self.ShouldDelevelSkillOfType("Stat"))
                    self.DelevelSkill(statSkills[statSkillCount])
                endif
                statSkillCount += 1
            endWhile
        endif

        if (shouldDelevelPerkSkills)
            string[] perkSkills = RPB_Utility.GetPerkSkills()

            int perkSkillCount = 0
            while (perkSkillCount < perkSkills.Length)
                if (self.ShouldDelevelSkillOfType("Perk"))
                    self.DelevelSkill(perkSkills[perkSkillCount])
                endif
                perkSkillCount += 1
            endWhile
        endif

    endif
endFunction

;                       Update Stats
; ==========================================================

function UpdateInfamy()
    if (!Prison.EnableInfamy)
        return
    endif

    float infamyGained = InfamyGainedPerUpdate
    self.ModifyStat("Infamy Gained", infamyGained)

    Config.NotifyInfamy(infamyGained + " infamy gained in " + Prison.Name, self.IsPlayer())
    Info(self.GetName() + " has gained " + infamyGained + " infamy in " + Prison.Name, self.IsNPC())
    Debug("("+ Name +") Prisoner::UpdateInfamy", self.GetName() + " has gained " + infamyGained + " infamy in " + Prison.Name)

    if (IsInfamyKnown && self.IsPlayer())
        Prison.NotifyInfamyKnownThresholdMet(Prison.HasInfamyKnownNotificationFired)

    elseif (IsInfamyRecognized && self.IsPlayer())
        Prison.NotifyInfamyRecognizedThresholdMet(Prison.HasInfamyRecognizedNotificationFired)
    endif
    
    self.RegisterLastUpdate()
endFunction

float property PreviousUpdateTimeServed
    float function get()
        return RPB_StorageVars.GetFloatOnForm("Previous Update Time Served", this, "Temporary")
    endFunction

    function set(float value)
        RPB_StorageVars.SetFloatOnForm("Previous Update Time Served", this, value, "Temporary")
    endFunction
endProperty

function UpdateTimeJailed()
    float timeJailedSinceLastUpdate = TimeServed - PreviousUpdateTimeServed
    int daysElapsed = floor(TimeServed) - floor(PreviousUpdateTimeServed)

    Debug("["+ Name +"] Prisoner::UpdateTimeJailed", "TimeServed: " + TimeServed + ", PreviousUpdateTimeServed: " + PreviousUpdateTimeServed + ", timeJailedSinceLastUpdate: " + timeJailedSinceLastUpdate)
    Debug("["+ Name +"] Prisoner::UpdateTimeJailed()", "Before UpdateDayEvents: PreviousUpdateTimeServed = " + PreviousUpdateTimeServed)

    self.UpdateDayEvents()
    
    Debug("["+ Name +"] Prisoner::UpdateTimeJailed()", "After UpdateDayEvents: PreviousUpdateTimeServed = " + PreviousUpdateTimeServed)

    self.ModifyStat("Time Jailed", timeJailedSinceLastUpdate)

    if (self.IsPlayer() && daysElapsed > 0)
        Game.IncrementStat("Days Jailed", daysElapsed)
    endif

    PreviousUpdateTimeServed = TimeServed
    Debug("["+ Name +"] Prisoner::UpdateTimeJailed()", "(Function End) PreviousUpdateTimeServed = " + PreviousUpdateTimeServed + ", TimeServed = " + TimeServed + ", LastUpdate: " + LastUpdate)

endFunction

function UpdateDayEvents()
    int daysElapsed = floor(TimeServed) - floor(PreviousUpdateTimeServed)
    Debug("["+ Name +"] Prisoner::UpdateDayEvents", "PreviousUpdateTimeServed: " + PreviousUpdateTimeServed + ", TimeServed: " + TimeServed + ", daysElapsed: " + daysElapsed)

    while (daysElapsed > 0)
        self.OnDayPassed()
        daysElapsed -= 1
    endwhile

    PreviousUpdateTimeServed = TimeServed
endFunction


function UpdateLongestSentence()
    int currentLongestSentence = self.QueryStat("Longest Sentence")
    int newLongestSentence = int_if (currentLongestSentence < Sentence, Sentence, currentLongestSentence)
    self.SetStat("Longest Sentence", newLongestSentence)
    self.SetStat("Last Sentence", Sentence)
    ; RPB_ActorVars.SetLastSentence(Prison.PrisonFaction, this, Sentence)

    Debug("["+ Name +"] Prisoner::UpdateLongestSentence", "[\n" + \ 
        "\t Current Longest Sentence: " + currentLongestSentence + "\n" + \
        "\t New Longest Sentence: " + newLongestSentence + "\n" + \
        "\t Sentence: " + Sentence + "\n" + \
    "]")
endFunction

function UpdateSentence()
    int nonViolent      = self.GetActiveBounty(abViolent = false)
    int violent         = self.GetActiveBounty(abNonViolent = false)
    int activeBounty    = nonViolent + violent

    if (activeBounty > 0)
        self.HideBounty()
    endif

    self.IncreaseSentence(activeBounty / Prison.BountyToSentence, false)
endFunction

;                     De/(Initialization)
; ==========================================================

RPB_Prisoner function Initialize()
    if (self.Was("Initialized"))
        return self
    endif

    DebugInfo("("+ Name +") Prisoner::Initialize", "Was Initialized: " + self.Was("Initialized"))

    if (!Prison.IsPrisoner(self))
        Prison.RegisterPrisoner(self)
    endif

    if (!self.Sentence)
        self.SetSentence()
    endif

    self.RegisterSleepEvents = true
    self.RegisterForTrackedStats()
    self.LockPrisonerSettings()

    self.InitializeState()

    return self
endFunction

function Destroy()
    self.RemoveAll()
    parent.Destroy()
    ; self.Remove("Is Initialized", "Actor")
    ; RPB_StorageVars.SetBoolOnForm("Is Initialized", this, false, "Actor")

    ; Debug("("+ Name +") Prisoner::Destroy", "Object: " + GetContainerList(RPB_StorageVars.GetObjectHandleOnForm(this)))
    ; TODO: Unset all properties related to this Prisoner
    ; Prison.UnregisterPrisoner(self)
endFunction

;/
    Handles the Prisoner's initialization state,
    ensuring the logic goes through before actually making the arrest.

    If anything should fail here that is crucial, 
    the arrest should be terminated and everything reverted.
/;
function InitializeState()
    if (self.Was("Initialized"))
        return
    endif

    ShowSentence = true
    ShowReleaseTime = true
    ShowTimeLeftInSentence = true
    ShowTimeServed = true
    ShowBounty = true

    self.DetermineStrippingType()
    self.DetermineClothingOutfit()
    self.SetReleaseLocation() ; to be refactored (needs to take into account whether to use Escort or Teleport markers)
    self.TriggerInfamyPenalty()

    int errors = RPB_Memory.FastArray("<string>")

    errors = EnsureTrue((WillBeStrippedNaked || WillBeStrippedToUnderwear), "Could not determine the stripping type for Prisoner " + Name, errors)
    errors = EnsureTrue(TeleportReleaseLocation, "Could not determine the release location for Prisoner " + Name, errors)

    bool hasErrors = RPB_Memory.FastArray_Size(errors) > 0

    if (hasErrors)
        ; Log error, revert state, etc... like a transaction in a database
        self.RevertState()
    endif

    self.SetBool("Initialized", true) ; Prevent further initializations
endFunction

; NOT WORKING: We shouldn't process anything if this fails, the execution should stop here for this script
function RevertState()
    RPB_Arrestee arresteeRef = RPB_Arrestee.GetStateForPrisoner(self)

    if (arresteeRef)
        arresteeRef.RevertState()
    endif

    ; Refactor into Destroy()
    self.RemoveFromCell()
    Prison.UnregisterPrisoner(self)
endFunction

;/
    Destroys the prisoner's arrest state, as they are now a prisoner and the arrest state is not required anymore.
/;
function DestroyArrestState()
    if (!RPB_Utility.IsActorArrested(this))
        return
    endif

    RPB_Arrestee arrestState = RPB_Arrestee.GetStateForPrisoner(self)
    arrestState.Destroy()
endFunction

;                         Management
; ==========================================================

;/
    Removes this Prisoner reference from the assigned jail cell.
/;
function RemoveFromCell()
    Prison.RemoveFromCell(self)
endFunction

;/
    Sets the Prisoner's belongings container where their items will be stored
    while they are in prison.
/;
function SetBelongingsContainer()
    Prison.AssignBelongingsContainer(self)
endFunction

;/
    Assigns a jail cell to this prisoner
/;
bool function AssignCell()
    return Prison.AssignCell(self)
endFunction

function SetReleaseLocation(bool abIsTeleportLocation = true)
    if (abIsTeleportLocation)
        SetForm("Teleport Release Location", Prison.GetRandomReleaseMarker("Teleport"))
    else
        SetForm("Teleport Release Location", Prison.GetRandomReleaseMarker("Escort"))
    endif
endFunction

function SetAsShowable(string asPropertyName, bool abValue = true)
    SetBool(asPropertyName + "::Show", abValue)
endFunction

;/
    Reverts this Prisoner to an Arrestee.

    This function should be used whenever this Prisoner must be escorted out of the prison and possibly into another prison location,
    for example, escorting from Solitude prison to Whiterun prison with their bounties.

    This can be useful if we imagine the Holds helping each other catching crime, and while one of the holds is holding the criminal,
    they can easily transfer them into another prison.

    This means that the Prisoner can potentially hop into several prisons before all their sentences are served.
    To avoid infinite sentencing, a variable should be put in place to limit how many prisons they can be transfered to.

    This could also be an event that happens by chance (configured in the MCM, to make it more dynamic and random)
/;
RPB_Arrestee function MakeArrestee()
    RPB_Arrestee arresteeRef = API.Arrest.AwaitArresteeReference(this)
    ;/ arresteeRef.SetArrestParameters( \
        asArrestHold        = newArrestHold, \
        akArrestCaptor      = newArrestCaptor \
        akArrestFaction     = newArrestFaction, \
    )/;

    return arresteeRef
endFunction


string function GetScriptVarCategory(string asVarCategory = "Actor")
    if (asVarCategory == "Actor")
        return "Jail"
    endif

    return asVarCategory
endFunction

;/
    Registers the last update for the prisoner, 
    this is a crucial variable used to determine updated sentences, infamy gained, and so on...
/;
function RegisterLastUpdate()
    __lastUpdate = Utility.GetCurrentGameTime()
endFunction


;/
    Locks the prisoner's settings configured in the MCM for the Prison they are housed in.

    This makes it possible to change the MCM options while imprisoned, and they will have no change
    because they were already set for this Prisoner, guaranteeing that this Prisoner's state will not change while they are in prison.
/;
function LockPrisonerSettings()
    ; Infamy
    SetBool("Infamy Enabled",                                Prison.EnableInfamy)
    SetFloat("Infamy Recognized Threshold",                  Prison.InfamyRecognizedThreshold)
    SetFloat("Infamy Known Threshold",                       Prison.InfamyKnownThreshold)
    SetFloat("Infamy Gained Daily from Current Bounty",      Prison.InfamyGainedDailyOfCurrentBounty)
    SetFloat("Infamy Gained Daily",                          Prison.InfamyGainedDaily)
    SetFloat("Infamy Gain Modifier (Recognized)",            Prison.InfamyGainModifierRecognized)
    SetFloat("Infamy Gain Modifier (Known)",                 Prison.InfamyGainModifierKnown)
    ; Frisking
    SetBool("Allow Frisking",                                Prison.AllowFrisking)
    SetInt("Bounty for Frisking",                            Prison.MinimumBountyForFrisking)
    SetInt("Frisking Thoroughness",                          Prison.FriskingThoroughness)
    SetBool("Confiscate Stolen Items",                       Prison.ConfiscateStolenItemsOnFrisk)
    SetBool("Strip if Stolen Items Found",                   Prison.StripIfStolenItemsFoundOnFrisk)
    SetInt("Minimum No. of Stolen Items Required",           Prison.MinimumNumberOfStolenItemsRequiredToStripOnFrisk)
    ; Stripping
    SetBool("Allow Stripping",                               Prison.AllowStripping)
    SetString("Handle Stripping On",                         Prison.HandleStrippingOn)
    SetInt("Bounty to Strip",                                Prison.MinimumBountyToStrip)
    SetInt("Violent Bounty to Strip",                        Prison.MinimumViolentBountyToStrip)
    SetInt("Sentence to Strip",                              Prison.MinimumSentenceToStrip)
    SetInt("Stripping Thoroughness",                         Prison.StrippingThoroughness)
    SetInt("Stripping Thoroughness Modifier",                Prison.StrippingThoroughnessModifier)
    ; Clothing
    SetBool("Allow Clothing",                                Prison.AllowClothing)
    SetString("Handle Clothing On",                          Prison.HandleClothingOn)
    SetInt("Maximum Bounty to Clothe",                       Prison.MaximumBountyClothing)
    SetInt("Maximum Violent Bounty to Clothe",               Prison.MaximumViolentBountyClothing)
    SetInt("Maximum Sentence to Clothe",                     Prison.MaximumSentenceClothing)
    SetBool("Clothe when Defeated",                          Prison.ClotheWhenDefeated)
    SetString("Outfit",                                      Prison.ClothingOutfit)
    SetBool("Use Default Outfit as Fallback",                Prison.UseDefaultOutfitAsFallback)
    ; Prison
    SetInt("Bounty Exchange",                                Prison.BountyExchange)
    SetInt("Bounty to Sentence",                             Prison.BountyToSentence)
    SetInt("Minimum Sentence",                               Prison.MinimumSentence)
    SetInt("Maximum Sentence",                               Prison.MaximumSentence)
    SetFloat("Cell Search Thoroughness",                     Prison.CellSearchThoroughness)
    SetString("Cell Lock Level",                             Prison.CellLockLevel)
    SetBool("Fast Forward",                                  Prison.FastForward)
    SetFloat("Day to Fast Forward From",                     Prison.DayToFastForwardFrom)
    SetString("Handle Skill Loss",                           Prison.HandleSkillLoss)
    SetInt("Day to Start Losing Skills (Stat)",              Prison.DayToStartLosingSkillsStat)
    SetInt("Day to Start Losing Skills (Perk)",              Prison.DayToStartLosingSkillsPerk)
    SetInt("Chance to Lose Skills (Stat)",                   Prison.ChanceToLoseSkillsStat)
    SetInt("Chance to Lose Skills (Perk)",                   Prison.ChanceToLoseSkillsPerk)
    SetFloat("Recognized Criminal Penalty",                  Prison.RecognizedCriminalPenalty)
    SetFloat("Known Criminal Penalty",                       Prison.KnownCriminalPenalty)
    SetFloat("Bounty to Trigger Infamy",                     Prison.MinimumBountyToTriggerCriminalPenalty)
    ; Release
    SetBool("Release Fees Enabled",                          Prison.EnableReleaseFees)
    SetFloat("Chance for Release Fees Event",                Prison.ReleaseFeesChanceForEvent)
    SetFloat("Bounty to Owe Fees",                           Prison.MinimumBountyToOweReleaseFees)
    SetFloat("Release Fees from Arrest Bounty",              Prison.ReleaseFeesOfCurrentBounty)
    SetFloat("Release Fees Flat",                            Prison.ReleaseFees)
    SetFloat("Days Given to Pay Release Fees",               Prison.DaysGivenToPayReleaseFees)
    SetBool("Enable Item Retention",                         Prison.EnableItemRetention)
    SetInt("Minimum Bounty to Retain Items",                 Prison.MinimumBountyToRetainItems)
    SetBool("Auto Redress on Release",                       Prison.AutoRedressOnRelease)
    ; Escape
    SetString("Handle Escape On",                            Prison.HandleEscapeOn)
    SetInt("Escape Bounty",                                  Prison.EscapeBounty)
    SetFloat("Escape Bounty of Current Bounty",              Prison.EscapeBountyOfCurrentBounty)
    SetFloat("Escape Bounty (Sentence)",                     Prison.EscapeBountySentenceMultiplier)
    SetFloat("Escape Bounty (Sentence Days)",                Prison.EscapeBountySentenceDays)
    SetInt("Escape Bounty (Bounty Condition)",               Prison.EscapeBountyCondition)
    SetInt("Escape Bounty (Sentence Condition)",             Prison.EscapeBountySentenceCondition)
    SetInt("Fallback Bounty",                                Prison.EscapeBountyFallbackBounty)
    SetBool("Account for Time Served",                       Prison.AccountForTimeServedOnEscape)
    SetBool("Frisk upon Captured",                           Prison.FriskUponCapturedOnEscape)
    SetBool("Strip upon Captured",                           Prison.StripUponCapturedOnEscape)
    ; Outfit
    SetString("Outfit::Name",                                Prison.OutfitName)
    SetForm("Outfit::Head",                                  Prison.OutfitPartHead)
    SetForm("Outfit::Body",                                  Prison.OutfitPartBody)
    SetForm("Outfit::Hands",                                 Prison.OutfitPartHands)
    SetForm("Outfit::Feet",                                  Prison.OutfitPartFeet)
    SetBool("Outfit::Conditional",                           Prison.IsOutfitConditional)
    SetInt("Outfit::Minimum Bounty",                         Prison.OutfitMinimumBounty)
    SetInt("Outfit::Maximum Bounty",                         Prison.OutfitMaximumBounty)
endFunction


; ==========================================================
;                           Events
; ==========================================================

;             Escort / Teleport -> Prison / Cell
; ==========================================================

event OnTeleportedToPrison()
endEvent

event OnTeleportedToCell(bool abBeginImprisonment)
endEvent

event OnEscortToPrison(Actor akEscort)
endEvent

event OnEscortedToPrison(Actor akEscort)
endEvent

event OnEscortToCell(Actor akEscort)
endEvent

event OnEscortedToCell(Actor akEscort)
endEvent

; When should this happen?
event OnEscortFromJail(Actor akEscort)
endEvent

; When should this happen?
event OnEscortedFromJail(Actor akEscort)
endEvent

event OnEscortFromCell(Actor akEscort)
endEvent

event OnEscortedFromCell(Actor akEscort)
endEvent

;               Stripping / Clothing / Removal
; ==========================================================

event OnClothed()
    SetBool("Clothed", true)
endEvent

event OnStripped()
    ;/
        Saves the NPC's original Outfit (inherited from ActorBase), and sets them
        to be naked before possibly equipping a Prison issued outfit (or no clothing).

        This doesn't mean they will be naked if an outfit should be equipped, it simply means
        that their base outfit is now naked, their state handles the outfitting afterwards.

        This is due to a FormList limitation, since we cannot have dynamic FormLists, they must be set
        statically in the CK, so the outfitting must happen on an Armor[].
    /;
    NPC_SaveOriginalOutfit()
    NPC_SetPersistentOutfit("Naked")

    ; Determine what items the prisoner will retain, if any.
    ; This should depend on stripping throughness and whether they will be stripped naked or to underwear.


    self.IsStrippedNaked        = self.WillBeStrippedNaked
    self.IsStrippedToUnderwear  = self.WillBeStrippedToUnderwear

    IncrementStat("Times Stripped")
    SetBool("Stripped", true)
endEvent

event OnUnderwearRemoved(Armor akUnderwearTop, Armor akUnderwearBottom)
    DebugParams( \ 
        akUnderwearTop + "," + akUnderwearBottom, \
        "akUnderwearTop, akUnderwearBottom", \
        "("+ Name +") Prisoner::OnUnderwearRemoved" \ 
    )
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    
endEvent

;                            Death
; ==========================================================

event OnDying(Actor akKiller)
    Prison.OnPrisonerDying(self, akKiller)
endEvent

event OnDeath(Actor akKiller)
    Prison.OnPrisonerDeath(self, akKiller)
endEvent

;                  Bounty / Sentence / Stats
; ==========================================================
 
;/
    Handles what happens when this Prisoner receives additional active bounty.
/;
event OnBountyGained()
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    self.UpdateSentence()
endEvent

event OnSentenceSet(int aiSentence, float afAtWhatTime)
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    self.UpdateLongestSentence()
endEvent

event OnSentenceChanged(int aiOldSentence, int aiNewSentence, bool abHasSentenceIncreased, bool abSentenceAffectsBounty)
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    if (abHasSentenceIncreased)
        int daysIncreasedBy = aiNewSentence - aiOldSentence
        Config.NotifyJail("Your sentence was increased by " + daysIncreasedBy + " days.", self.IsPlayer())
        self.UpdateLongestSentence()
    endif
endEvent

event OnStatChanged(string asStatName, float afValue)
    ;/ const /; string HOLD_BOUNTY                  = Prison.Hold + " Bounty"
    ;/ const /; string HOLD_LATENT_BOUNTY           = "Bounty Non-Violent"
    ;/ const /; string HOLD_LATENT_VIOLENT_BOUNTY   = "Bounty Violent"

    if (asStatName == HOLD_BOUNTY) ; If there's bounty gained in the current prison hold
        self.OnBountyGained()
        ; Maybe inform the prisoner of their new sentence and have them escorted out of the cell to be frisked/stripped if they are not

    elseif (asStatName == HOLD_LATENT_BOUNTY || asStatName == HOLD_LATENT_VIOLENT_BOUNTY)
        self.OnBountyGained()
    endif

    Debug("["+ Name +"] Prisoner::OnStatChanged", "Stat " + asStatName + " has been changed to " + afValue)
endEvent

;                Imprisonment / Sleep / Time
; ==========================================================

; Triggered whenever a full day has passed
event OnDayPassed()
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    Debug("["+ Name +"] Prisoner::OnDayPassed", "A day has passed.")
    self.PerformDeleveling()
endEvent

int __serveTimeLastDayRegistered
event OnSleepStart(float afSleepStartTime, float afSleepEndTime)
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    if (self.IsUndeterminedSentence)
        Debug("["+ Name +"] Prisoner::OnSleepStart", self.Name + " currently has an undetermined sentence, cannot serve time.")
        return
    endif

    if (__serveTimeLastDayRegistered != RPB_Utility.GetCurrentDay() || !__serveTimeLastDayRegistered)
        int msgResult = Prison.ServeTimeMessage.Show()
        if (msgResult == Prison.SERVE_TIME_YES)
            ; if (self.ShouldFastForwardToRelease)
                self.FastForwardToRelease()
                Prison.Notify("Sleep Start is: " + afSleepStartTime + ", Sleep End is: " + afSleepEndTime)
            ; endif
            return
        endif
        __serveTimeLastDayRegistered = RPB_Utility.GetCurrentDay()
    endif
endEvent

event OnImprisoned()
    self.RegisterTimeOfImprisonment()
    self.DetermineReleaseTimeAdditionalHours() ; For Release Time (Minimum, Maximum) intervals
    ; self.SetReleaseLocation() ; to be refactored (needs to take into account whether to use Escort or Teleport markers)

    ; if (!self.Sentence)
    ;     self.SetSentence(abShouldAffectBounty = false)
    ; endif

    self.IncrementStat("Times Jailed")
    if (self.IsPlayer())
        Game.IncrementStat("Times Jailed") ; Increment the "Times Jailed" in the regular vanilla stat menu.
    endif
endEvent

;                      Release / Escape
; ==========================================================

event OnReleased()
    self.Destroy()
endEvent

event OnEscaped()

endEvent

;                         Management
; ==========================================================

event OnInitialize()
    ; DebugInfo("("+ Name +") Prisoner::OnInitialize", "State: " + self.GetState())
    ; DebugInfo("("+ Name +") Prisoner::OnInitialize", "IsInitialized: " + self.IsInitialized)

    if (self.IsNPC() && self.IsImprisoned)
        self.NPC_ResumeImprisonment()
    endif

    if (self.Was("Initialized"))
        return
    endif

    Prison.RegisterPrisoner(self)
    ; DebugInfo("("+ Name +") Prisoner::OnInitialize", "Initialized: " + self.Was("Initialized"))
endEvent

event OnRestore()
    ; if (self.IsNPC() && self.IsImprisoned)
    ;     self.NPC_ResumeImprisonment()
    ; endif

    DebugInfo("("+ Name +") Prisoner::OnRestore", "Restoring Prisoner: " + Name)
endEvent

event OnDestroy()
    if (self.IsNPC())
        if (this.GetParentCell() != Config.Player.GetParentCell())
            Debug("["+ Name +"] Prisoner::OnDestroy", Name + "'s Cell: " + this.GetParentCell() + ", Player's Cell: " + Config.Player.GetParentCell())
        endif
    endif

    ; We don't unregister the prisoner (remove from the AME list) because OnDestroy will get called as soon as the Player is out of range, meaning it's not a proper way to handle the destruction of the object
    self.UnregisterForTrackedStats()

    if (self.IsPlayer())
        ; If for some reason AI is disabled, re-enable it
        ReleaseAI()
    endif
endEvent

event OnImprisonmentFail(string asReason)
    Prison.OnPrisonerImprisonmentFail(self, asReason)
endEvent

; ==========================================================
;                            Getters
; ==========================================================

;/
    Returns the same as GetActor(), used for convenience.
/;
Actor function GetPrisoner()
    return self.GetActor()
endFunction

Actor function GetActor()
    return this
endFunction

Faction function GetFaction()
    return Prison.PrisonFaction
endFunction

Faction function GetPrisonFaction()
    return self.GetFaction()
endFunction

string function GetHold()
    return Prison.Hold
endFunction

string function GetPrisonHold()
    return Prison.Hold
endFunction

bool       __prisonFailedInitialization
RPB_Prison __cachedPrison
RPB_Prison function GetPrison()
    if (__cachedPrison)
        return __cachedPrison
    endif

    if (__prisonFailedInitialization)
        return none
    endif

    ; Used to obtain a reference to the Prison for the first time, not required after caching.
    string prisonUUID = self.GetString("Prison UUID")

    if (!prisonUUID)
        EventManager.SendError("There was an error retrieving the Prison belonging to Prisoner: " + self.Name, "["+ Name +"] Prisoner::GetPrison")
        __prisonFailedInitialization = true
        return none
    endif

    __cachedPrison = API.PrisonManager.GetPrisonByUUID(prisonUUID)
    return __cachedPrison
endFunction

RPB_JailCell function GetCell()
    return GetReference("Cell") as RPB_JailCell
endFunction


; ==========================================================
;                          NPC Only
; ==========================================================

; ==========================================================
;                          Management

bool function NPC_ShouldMonitorActively()
    return self.IsNPC() && !self.IsFarFromPlayer()
endFunction

function NPC_KeepMonitoring()
    Prison.SendMonitoringRequest()
endFunction

function NPC_BindToCell()
    if (!self.IsNPC())
        return
    endif

    if (self.HasCellPackage)
        return
    endif

    self.BindAlias(CellPackage)
    MiscUtil.PrintConsole("["+ Name +"] Bound to Package " + CellPackage.GetName())
    Debug("[Prison: "+ self.Prison.Name +"] ["+ Name +"] Prisoner::NPC_BindToCell", "[Package: "+ CellPackage.GetName() +"] Bound " + Name + " to "+ self.PronounPossessiveObject +" Cell.")
endFunction

function NPC_UnbindFromCell()
    if (!self.IsNPC())
        return
    endif

    if (!self.HasCellPackage)
        return
    endif

    self.UnbindAlias(CellPackage)
    MiscUtil.PrintConsole("["+ Name +"] Unbound from Package " + CellPackage.GetName())
    Debug("[Prison: "+ self.Prison.Name +"] ["+ Name +"] Prisoner::NPC_UnbindFromCell", "[Package: "+ CellPackage.GetName() +"] Unbound " + Name + " from "+ self.PronounPossessiveObject +" Cell.")
endFunction

;/
    Handles actions when an NPC's imprisonment state is resumed (usually when the player is in the same location as the NPC).
/;
event NPC_OnResumeImprisonment()
    JailCell.RegisterForSanityChecking(1.0, apPrisoner = self)
endEvent

function NPC_ResumeImprisonment()
    if (!self.IsNPC())
        return
    endif

    if (!self.IsImprisoned)
        DebugError("["+ Name +"] Prisoner::NPC_ResumeImprisonment", "Prisoner " + Name + " is not imprisoned, cannot resume imprisonment!")
        Error("Prisoner " + Name + " is not imprisoned, cannot resume imprisonment!")
        return
    endif

    GotoState("Imprisoned")
    RegisterForSingleUpdateGameTime(0.1)

    NPC_OnResumeImprisonment()
endFunction

; ==========================================================
;                    Clothing / Undressing

Outfit __npcOriginalOutfit
Outfit property NPC_OriginalOutfit
    Outfit function get()
        return __npcOriginalOutfit
    endFunction
endProperty

Armor[] __npcUnderwear
Armor[] property NPC_Underwear
    Armor[] function get()
        return __npcUnderwear
    endFunction
endProperty

int property NPC_UNDERWEAR_TOP_INDEX    = 0 autoreadonly
int property NPC_UNDERWEAR_BOTTOM_INDEX = 1 autoreadonly

function NPC_SaveUnderwear(Armor akUnderwearTop, Armor akUnderwearBottom)
    if (self.IsNPC())
        __npcUnderwear = new Armor[2]
        __npcUnderwear[NPC_UNDERWEAR_TOP_INDEX]     = akUnderwearTop
        __npcUnderwear[NPC_UNDERWEAR_BOTTOM_INDEX]  = akUnderwearBottom
    endif
endFunction

function NPC_SaveOriginalOutfit()
    if (self.IsNPC())
        Outfit npcBaseOutfit = this.GetActorBase().GetOutfit()

        ; Ensure we don't save a 'naked' outfit.
        if (npcBaseOutfit != RPB_GetOutfit("Naked"))
            __npcOriginalOutfit = npcBaseOutfit
        endif
    endif
endFunction

function NPC_RestoreOriginalOutfit()
    if (self.IsNPC() && NPC_OriginalOutfit)
        this.SetOutfit(NPC_OriginalOutfit)
    endif
endFunction

function NPC_SetPersistentOutfit(string asOutfit)
    if (self.IsNPC())
        Outfit persistentOutfit = RPB_GetOutfit(asOutfit)
        this.SetOutfit(persistentOutfit)

        ; NPCs will recover their ActorBase inventory when the Outfit is changed, remove them.
        NPC_RemovePresetItems()
    endif
endFunction

function NPC_RemovePresetItems()
    if (self.IsNPC())
        self.RemoveAllItems()
    endif
endFunction

; function NPC_UpdateStripping()
;     if (!self.IsNPC())
;         return
;     endif

;     ; TODO: Check if the prisoner was stripped to underwear, and give them the underwear back,
;     ; also take into account possible lockpicks or keys the prisoner might have, we don't want to include those, the prisoner should remain with them
;     ; bool shouldStrip = !self.IsNaked() && self.IsInCell && self.Is("Stripped") ;/&& !self.IsWearingPrisonerOutfit/;

;     ; Needs to take into account default outfit as well, we should store it in the prisoner state
;     Armor[] pOutfit = self.GetOutfit()

;     bool shouldStrip = \
;         self.Was("Stripped") && \ 
;         ( \
;             (!self.HasUnderwear()   && self.IsStrippedToUnderwear) || \ 
;             (!self.IsNaked()        && self.IsStrippedNaked) \
;         ) && \
;         ( \
;             (self.ShouldBeClothed && !self.IsWearingOutfit(pOutfit)) || \
;             !self.ShouldBeClothed \
;         )

;     if (!shouldStrip)
;         DebugParams( \ 
;             shouldStrip + "," + self.Was("Stripped") + "," + self.IsNaked() + "," + self.HasUnderwear() + "," + self.IsStrippedNaked + "," + self.IsStrippedToUnderwear, \
;             "shouldStrip, WasStripped, IsNaked,  HasUnderwear, IsStrippedNaked, IsStrippedToUnderwear", \
;             "("+ Name +") Prisoner::NPC_UpdateStripping" \
;         )
;         return
;     endif

;     if (IsStrippedToUnderwear)
;         ; Armor underwearTop    = self.GetUnderwear("Top") ; TODO: Get the underwear from the prison container perhaps, since it is impossible for the prisoner to be wearing it at this stage
;         ; Armor underwearBottom = self.GetUnderwear("Bottom") ; TODO: Get the underwear from the prison container perhaps, since it is impossible for the prisoner to be wearing it at this stage

;         Armor underwearTop      = NPC_Underwear[NPC_UNDERWEAR_TOP_INDEX]
;         Armor underwearBottom   = NPC_Underwear[NPC_UNDERWEAR_BOTTOM_INDEX]

;         self.UnequipAll() ; Probably not needed, since their base state will be naked (although we can check for items, but it probably shouldn't be done at this point)
;         self.RemoveAllItems() ; Probably not needed, since their base state will be naked (although we can check for items, but it probably shouldn't be done at this point)

;         self.EquipItem(underwearTop,    abCondition = underwearTop != none)
;         self.EquipItem(underwearBottom, abCondition = underwearBottom != none)
        
;         Debug("["+ Name +"] Prisoner::NPC_UpdateStripping", "Stripped " + self.Name + " to underwear - performed sanity check", underwearTop != none || underwearBottom != none)
;         Debug("["+ Name +"] Prisoner::NPC_UpdateStripping", "Stripped " + self.Name + " naked - performed sanity check", underwearTop == none && underwearBottom == none)

;     elseif (IsStrippedNaked)
;         self.RemoveAllItems()
;         Debug("["+ Name +"] Prisoner::PerformStrippingSanityChecks", "Stripped " + self.Name + " naked - performed sanity check")
;     endif

;     DebugParams( \ 
;         shouldStrip + "," + self.Was("Stripped") + "," + self.IsNaked() + "," + self.HasUnderwear() + "," + self.IsStrippedNaked + "," + self.IsStrippedToUnderwear, \
;         "shouldStrip, WasStripped, IsNaked,  HasUnderwear, IsStrippedNaked, IsStrippedToUnderwear", \
;         "("+ Name +") (END) Prisoner::NPC_UpdateStripping" \
;     )

; endFunction

function NPC_UpdateStripping()
    if (!self.IsNPC())
        return
    endif

    return ; Unused for now

    bool shouldStrip = \
        self.Was("Stripped") && \ 
        ( \
            (!self.HasUnderwear()   && self.IsStrippedToUnderwear) || \ 
            (!self.IsNaked()        && self.IsStrippedNaked) \
        ) && \
        ( \
            (self.ShouldBeClothed && !self.IsWearingOutfit(PrisonOutfit)) || \
            !self.ShouldBeClothed \
        )

    if (!shouldStrip)
        DebugParams( \ 
            shouldStrip + "," + self.Was("Stripped") + "," + self.IsNaked() + "," + self.HasUnderwear() + "," + self.IsStrippedNaked + "," + self.IsStrippedToUnderwear, \
            "shouldStrip, WasStripped, IsNaked,  HasUnderwear, IsStrippedNaked, IsStrippedToUnderwear", \
            "("+ Name +") (Should not Strip) Prisoner::NPC_UpdateStripping" \
        )
        return
    endif

    self.UnequipAll() ; Probably not needed, since their base state will be naked (although we can check for items, but it probably shouldn't be done at this point)
    self.RemoveAllItems() ; Probably not needed, since their base state will be naked (although we can check for items, but it probably shouldn't be done at this point)

    DebugParams( \ 
        shouldStrip + "," + self.Was("Stripped") + "," + self.IsNaked() + "," + self.HasUnderwear() + "," + self.IsStrippedNaked + "," + self.IsStrippedToUnderwear, \
        "shouldStrip, WasStripped, IsNaked,  HasUnderwear, IsStrippedNaked, IsStrippedToUnderwear", \
        "("+ Name +") (END) Prisoner::NPC_UpdateStripping" \
    )
endFunction

function NPC_UpdateUnderwear()
    if (!self.IsNPC())
        return
    endif

    Armor underwearTop      = NPC_Underwear[NPC_UNDERWEAR_TOP_INDEX]
    Armor underwearBottom   = NPC_Underwear[NPC_UNDERWEAR_BOTTOM_INDEX]

    bool hasUnderwearInInventory    = this.GetItemCount(underwearTop) >= 1 || this.GetItemCount(underwearBottom) >= 1
    bool wasStrippedToUnderwear     = self.Was("Stripped") && self.IsStrippedToUnderwear
    bool shouldBeInUnderwear        = self.IsNaked() && wasStrippedToUnderwear && hasUnderwearInInventory

    if (shouldBeInUnderwear)
        self.EquipItem(underwearTop,    abCondition = underwearTop != none)
        self.EquipItem(underwearBottom, abCondition = underwearBottom != none)
    endif

    EventManager.SendInfo("Equipped underwear on " + self.Name, "["+ Name +"] Prisoner::NPC_UpdateUnderwear", shouldBeInUnderwear)
    EventManager.SendInfo("Tried to equip underwear on " + self.Name + ", but " + self.Pronoun + " does not have any!", "["+ Name +"] Prisoner::NPC_UpdateUnderwear", wasStrippedToUnderwear && !hasUnderwearInInventory)
endFunction

function NPC_UpdateClothing()
    if (!self.IsNPC())
        return
    endif

    ; TODO: Fix this condition, keeps being true when NPC is not stripped (when NPC_UpdateStripping does nothing)
    bool isWearingOutfit        = self.IsWearingOutfit(PrisonOutfit)
    bool isNakedOrInUnderwear   = self.IsNaked() || self.HasUnderwear()

    bool shouldClothe = self.Was("Stripped") && self.ShouldBeClothed \ 
        && isNakedOrInUnderwear && !isWearingOutfit

        ; DebugParams( \ 
        ;     shouldClothe + "," + ShouldBeClothed + "," + self.IsNaked() + "," + self.HasUnderwear() + "," + self.IsStrippedNaked + "," + self.IsStrippedToUnderwear, \
        ;     "shouldClothe, ShouldBeClothed, IsNaked,  HasUnderwear, IsStrippedNaked, IsStrippedToUnderwear", \
        ;     "("+ Name +") Prisoner::NPC_UpdateClothing" \
        ; )

    if (shouldClothe)
        self.Clothe()
    endif
endFunction


; ==========================================================
;                          Debug
; ==========================================================

function DEBUG_ShowHoldStats()
    int nonViolent  = self.GetLatentBounty(abViolent = false)
    int violent     = self.GetLatentBounty(abNonViolent = false)

    LogNoType("\n" + Prison.Hold + " Stats: { \n\t" + \
        "Bounty: "              + nonViolent  + ", \n\t" + \
        "Bounty Violent: "      + violent  + ", \n\t" + \
        "Bounty: "              + self.QueryStat("Bounty Non-Violent")  + ", \n\t" + \
        "Bounty Violent: "      + self.QueryStat("Bounty Violent")      + ", \n\t" + \
        "Largest Bounty: "      + self.QueryStat("Largest Bounty")      + ", \n\t" + \
        "Total Bounty: "        + self.QueryStat("Total Bounty")        + ", \n\t" + \
        "Times Arrested: "      + self.QueryStat("Times Arrested")      + ", \n\t" + \
        "Arrests Resisted: "    + self.QueryStat("Arrests Resisted")    + ", \n\t" + \
        "Times Frisked: "       + self.QueryStat("Times Frisked")       + ", \n\t" + \
        "Days Jailed: "         + self.QueryStat("Days Jailed")         + ", \n\t" + \
        "Longest Sentence: "    + self.QueryStat("Longest Sentence")    + ", \n\t" + \
        "Times Jailed: "        + self.QueryStat("Times Jailed")        + ", \n\t" + \
        "Times Escaped: "       + self.QueryStat("Times Escaped")       + ", \n\t" + \
        "Times Stripped: "      + self.QueryStat("Times Stripped")      + ", \n\t" + \
        "Infamy Gained: "       + self.QueryStat("Infamy Gained")       + "\n" + \
    " }")
endFunction