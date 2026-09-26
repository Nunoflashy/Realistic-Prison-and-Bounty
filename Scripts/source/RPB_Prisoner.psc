Scriptname RPB_Prisoner extends RPB_ActorBase

;/
@constants:
    int SKILL_LOSS_HANDLING_ALL_SKILLS
    int SKILL_LOSS_HANDLING_ALL_STAT_SKILLS
    int SKILL_LOSS_HANDLING_ALL_PERK_SKILLS
    int SKILL_LOSS_HANDLING_RANDOM_STAT_SKILL
    int SKILL_LOSS_HANDLING_RANDOM_PERK_SKILL
    int SKILL_LOSS_HANDLING_RANDOM
    int BELONGINGS_MANIFEST_MAX
    int NPC_UNDERWEAR_TOP_INDEX
    int NPC_UNDERWEAR_BOTTOM_INDEX
@references:
    RPB_EventManager EventManager
    RPB_Prison Prison
    RPB_JailCell JailCell
@properties:
    Armor[] NPC_Underwear
    bool HasStateRequiredForImprisonment
    bool ShouldProcessImprisonmentEvents
    int MinuteOfArrest
    int HourOfArrest
    int DayOfArrest
    int MonthOfArrest
    int YearOfArrest
    int MinuteOfImprisonment
    int HourOfImprisonment
    int DayOfImprisonment
    int MonthOfImprisonment
    int YearOfImprisonment
    int ReleaseHour
    int ReleaseMinute
    Actor Captor
    float CurrentTime
    int BountyNonViolent
    int BountyViolent
    int Bounty
    int Infamy
    bool Defeated
    int DefeatedBounty
    bool ShouldBeFrisked
    bool ShouldBeStripped
    bool ShouldBeStrippedSilently
    int StrippingThoroughness
    bool ShouldBeClothed
    bool UseDefaultOutfitAsFallback
    ObjectReference PrisonerBelongingsContainer
    ObjectReference TeleportReleaseLocation
    bool IsImprisoned
    bool IsInCell
    bool ShouldBeInCell
    float LastUpdate
    float TimeSinceLastUpdate
    float TimeOfArrest
    float TimeOfImprisonment
    float TimeServed
    float TimeArrested
    int Sentence
    bool IsUndeterminedSentence
    float ReleaseTime
    bool ShowReleaseTime
    bool ShowSentence
    bool ShowTimeServed
    bool ShowTimeLeftInSentence
    bool ShowBounty
    float TimeLeftInSentence
    int DaysSinceTimeOfImprisonment
    bool IsSentenceServed
    bool ShouldFastForwardToRelease
    int CurrentInfamy
    bool IsInfamyEnabled
    bool IsInfamyRecognized
    bool IsInfamyKnown
    int InfamyGainedDaily
    float InfamyGainedPerUpdate
    bool IsSentenceSet
    ReferenceAlias CellPackage
    bool HasCellPackage
    bool HasCriminalPenalty
    int CriminalPenaltySentence
    bool WillBeStrippedNaked
    bool WillBeStrippedToUnderwear
    bool IsStrippedNaked
    bool IsStrippedToUnderwear
    bool IsStripped
    bool IsClothed
    Armor[] PrisonOutfit
    float PreviousUpdateTimeServed
    Outfit NPC_OriginalOutfit
@functions:
    function RestoreBounty()
    function StartRestraining(Actor akRestrainer)
    function StartFrisking(Actor akSearcherGuard)
    function StartStripping(Actor akStripperGuard)
    function StartGiveClothing(Actor akClothingGiver)
    function EscortToJail(Actor akEscort)
    function EscortToCell(Actor akEscort)
    bool function HasDayElapsed()
    function SetEscaped()
    function SetEscapePenalty()
    function MoveToPrison(Actor akCaptor)
    function MoveToCell(bool abBeginImprisonment = true)
    function TriggerInfamyPenalty()
    bool function IsRestrained()
    function Cuff(bool abCuffInFront = false)
    function Uncuff()
    function Restrain()
    bool function ShouldFrisk()
    function Frisk()
    bool function EvaluateStrippingCriteria()
    bool function ShouldStrip()
    bool function ShouldSilentlyStrip()
    int function ResolveStrippingType(bool abNudeBodyMod, bool abUnderwearBodyMod, bool abHasUnderwearWorn, int aiThoroughness) global
    function DetermineStrippingType()
    function Strip(bool abRemoveUnderwear = true)
    function StripSilently()
    function RemoveUnderwear()
    bool function ShouldClothe()
    bool function Outfit_MeetsConditions()
    bool function Outfit_IsValid(int aiPieceCountToCheck = 4, Armor[] akOutfit = none)
    Armor[] function GetConfiguredOutfit()
    Armor[] function GetOutfit()
    function DetermineClothingOutfit()
    function Clothe()
    int function GetTimeServed(string timeUnit)
    int function GetTimeLeftInSentence(string timeUnit)
    int function GetSentenceFromBounty()
    function RegisterTimeOfImprisonment()
    function UndetermineSentence()
    function SetSentenceFromTimeServed(int aiSentenceInDays, bool abShouldAffectBounty = false)
    function SetSentence(int aiSentenceInDays = 0, bool abShouldAffectBounty = true)
    function IncreaseSentence(int aiDaysToIncreaseBy, bool abShouldAffectBounty = true)
    function DecreaseSentence(int aiDaysToDecreaseBy, bool abShouldAffectBounty = true)
    bool function IsReleaseOnWeekend()
    bool function IsReleaseOnLoredas()
    bool function IsReleaseOnSundas()
    bool function HasReleaseTimeExtraHours()
    float function GetReleaseTime(bool abIncludeMinutes = true)
    int function GetReleaseTimeHour()
    float function GetIndefiniteReleaseTime()
    float function GetReleaseTimeExtraHours()
    function FastForwardToRelease()
    function DetermineReleaseTimeAdditionalHours()
    function SaveBelongingsManifest()
    function ModBelongingsManifest(Form akItem, int aiDelta)
    function ReturnBelongings()
    function NotifySentence()
    function NotifyReleaseDate()
    function Imprison()
    Form[] function GetCellMates()
    bool function HasActiveBounty()
    bool function HasLatentBounty()
    int function GetActiveBounty(bool abNonViolent = true, bool abViolent = true)
    int function GetLatentBounty(bool abNonViolent = true, bool abViolent = true)
    function SetCrimeGold(int aiGold)
    function SetCrimeGoldViolent(int aiGold)
    function ModCrimeGold(int aiAmount, bool abViolent = false)
    function HideBounty()
    function UpdateInfamyLost()
    bool function ShouldDelevelSkillOfType(string asSkillType)
    int function GetSkillLossHandlingType()
    int function GetMinimumSkillValue(string asSkill)
    bool function DelevelSkill(string asSkill)
    function PerformDeleveling()
    function UpdateInfamy()
    function UpdateTimeJailed()
    function UpdateDayEvents()
    function UpdateLongestSentence()
    function UpdateSentence()
    RPB_Prisoner function Initialize()
    function Destroy()
    function InitializeState()
    function RevertState()
    function DestroyArrestState()
    function RemoveFromCell()
    function SetBelongingsContainer()
    bool function AssignCell()
    function SetReleaseLocation(bool abIsTeleportLocation = true)
    function SetAsShowable(string asPropertyName, bool abValue = true)
    RPB_Arrestee function MakeArrestee()
    string function GetScriptVarCategory(string asVarCategory = "Actor")
    function RegisterLastUpdate()
    function LockPrisonerSettings()
    function NoteStateEntered()
    Actor function GetPrisoner()
    Actor function GetActor()
    Faction function GetFaction()
    Faction function GetPrisonFaction()
    string function GetHold()
    string function GetPrisonHold()
    RPB_Prison function GetPrison()
    RPB_JailCell function GetCell()
    bool function NPC_ShouldMonitorActively()
    function NPC_KeepMonitoring()
    function NPC_BindToCell()
    function NPC_UnbindFromCell()
    function NPC_ResumeImprisonment()
    Armor function NPC_GetUnderwearTop()
    Armor function NPC_GetUnderwearBottom()
    Armor[] function NPC_GetUnderwear()
    function NPC_SaveUnderwear(Armor akUnderwearTop, Armor akUnderwearBottom)
    function NPC_SaveOriginalOutfit()
    function NPC_RestoreOriginalOutfit()
    function NPC_ReequipAfterRelease()
    function NPC_EnsureDressed()
    function NPC_SaveWornArmor()
    int function NPC_ReequipSavedWornArmor()
    bool function IsHostilePrisoner()
    function NeutralizeWhileImprisoned()
    function NPC_SetPersistentOutfit(string asOutfit)
    function NPC_RemovePresetItems()
    function NPC_UpdateStripping()
    function NPC_UpdateUnderwear()
    function NPC_UpdateClothing()
    function DEBUG_ShowHoldStats()
@events:
    event OnUpdateGameTime()
    event OnBeginState()
    event OnBountyGained()
    event OnTeleportedToPrison()
    event OnTeleportedToCell(bool abBeginImprisonment)
    event OnEscortToPrison(Actor akEscort)
    event OnEscortedToPrison(Actor akEscort)
    event OnEscortToCell(Actor akEscort)
    event OnEscortedToCell(Actor akEscort)
    event OnEscortFromJail(Actor akEscort)
    event OnEscortedFromJail(Actor akEscort)
    event OnEscortFromCell(Actor akEscort)
    event OnEscortedFromCell(Actor akEscort)
    event OnClothed()
    event OnStripped()
    event OnUnderwearRemoved(Armor akUnderwearTop, Armor akUnderwearBottom)
    event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    event OnDying(Actor akKiller)
    event OnDeath(Actor akKiller)
    event OnSentenceSet(int aiSentence, float afAtWhatTime)
    event OnSentenceChanged(int aiOldSentence, int aiNewSentence, bool abHasSentenceIncreased, bool abSentenceAffectsBounty)
    event OnStatChanged(string asStatName, float afValue)
    event OnDayPassed()
    event OnSleepStart(float afSleepStartTime, float afSleepEndTime)
    event OnImprisoned()
    event OnReleased()
    event OnEscaped()
    event OnInitialize()
    event OnRestore()
    event OnDestroy()
    event OnImprisonmentFail(string asReason)
    event NPC_OnResumeImprisonment()
/;

import RPB_Config
import RPB_Utility
import RPB_Memory
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
        ; Debug("("+ Name +") Prisoner::HasStateRequiredForImprisonment", \
        ;     "\nPrison: " + Prison.Name + "\n" + \
        ;     "JailCell: " + JailCell + "\n" + \
        ;     "Sentence: " + Sentence + "\n" + \
        ;     "Bounty: " + Bounty + "\n" + \
        ;     "IsUndeterminedSentence: " + IsUndeterminedSentence + "\n" + \
        ;     "All: " + (Prison && JailCell && (Sentence || Bounty || IsUndeterminedSentence)) \
        ; )
        return Prison && JailCell && (Sentence || Bounty || IsUndeterminedSentence)
    endFunction
endProperty

bool property ShouldProcessImprisonmentEvents
    bool function get()
        return self.IsImprisoned
    endFunction
endProperty

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

; TODO: Refactor into a Prison specific property when Hold to Prison is 1:N
int property Infamy
    int function get()
        string factionName = RPB_Utility.GetFormNameCached(Prison.PrisonFaction)
        return GetInt(factionName + "::Infamy Gained", "ActorVars")
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
        ; Both come from the settings locked into this prisoner (LockPrisonerSettings). The base used to be read from a
        ; category nothing writes ("Stripping"), so the MCM's thoroughness was ignored; the modifier from the live MCM.
        int thoroughness = GetInt("Stripping Thoroughness")
        int modifier = GetInt("Stripping Thoroughness Modifier")

        ; The bounty (~22ms to read) only matters when the modifier is enabled
        if (modifier > 0)
            thoroughness += Round(Bounty / modifier)
        endif

        return thoroughness
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

    The GetDistance() check above is fine-grained and correct while I'm loaded, but both distances collapse to the
    same sentinel when I'm not (confirmed: an off-screen prisoner who's genuinely, correctly placed in their cell
    still read IsInCell false, unlike a normal, non-stalled escort, which always read true). GetParentCell() is a
    persisted Cell-record comparison with no load-state dependency - coarser (it can't tell one cell from another if
    a prison's cells happen to share one interior Cell record), but only while unloaded, which is exactly where the
    distance check couldn't tell anything at all.
/;
bool property IsInCell
    bool function get()
        if (this.Is3DLoaded())
            float distanceFromCellDoor      = self.GetDistance(JailCell.CellDoor)
            float distanceFromOutsideCell   = self.GetDistance(JailCell.ExteriorMarkers[0] as ObjectReference)

            return distanceFromCellDoor < distanceFromOutsideCell
        endif

        return self.GetCurrentCell() == JailCell.GetParentCell()
    endFunction
endProperty

bool property ShouldBeInCell
    bool function get()
        return Has("Should Be In Cell")
    endFunction
endProperty

; Stored on the actor reference (not in a variable of this effect instance, which is replaced when the actor unloads and loads again)
float property LastUpdate
    float function get()
        return GetFloat("Last Update")
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

        return Round(Bounty * Prison.InfamyGainedDailyOfCurrentBounty) + Prison.InfamyGainedDaily
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
        string packageId    = self.GetString("Cell Package ID")
        Quest packageGroup  = self.GetForm("Cell Package Group") as Quest

        if (!packageId)
            ReferenceAlias cellPackageRef = JailCell.GetSuitableCellPackage()
            self.SetString("Cell Package ID", cellPackageRef.GetName())
            self.SetForm("Cell Package Group", cellPackageRef.GetOwningQuest())

            packageId    = self.GetString("Cell Package ID")
            packageGroup = self.GetForm("Cell Package Group") as Quest
        endif

        return Prison.PrisonManager.GetCellPackageByNameEx(packageGroup, packageId)
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

int property CriminalPenaltySentence
    int function get()
        return GetInt("Criminal Penalty Sentence")
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

        ; The hourly update registered while imprisoned would keep firing (an error every game hour during a time skip)
        if (self.IsEffectActive)
            self.UnregisterForUpdates()
        endif

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
        ; Already unregistered when entering the state; a tick that was already in flight is harmless
    endEvent
endState

; The Escort-to-Cell stall failsafe used to live here (state EscortToCellStallCheck, armed via ArmEscortToCellStallCheck())
; - moved to RPB_Prison.QueueEscortToCellStallCheck()/__ProcessEscortStallChecks() instead. This script is an
; ActiveMagicEffect: its RegisterForSingleUpdate doesn't survive the escorted actor's 3D unloading (OnEffectFinish tears
; the instance down, a reload starts a fresh one with no memory of the old timer) - confirmed against this codebase's own
; test-81 evidence, and exactly the condition ("player didn't follow") this failsafe needs to survive. RPB_Prison, a
; Quest-bound ReferenceAlias, has no such dependency.

; While this Prisoner is imprisoned in their cell
state Imprisoned
    event OnBeginState()
        ; Debug("[state: "+ self.GetState() +"] ["+ Name +"] Prisoner::OnBeginState", self.Name + "'s Bounty: " + Bounty)

        ; A Captor is meant to eventually support 1:N Arrestees (one guard escorting several) - that isn't built yet,
        ; Captor.Arrestee is still a single value, so "does this Captor still have anyone to escort" just means "is
        ; their one Arrestee still me". Only destroy when that holds, so a guard who's already been reassigned to a
        ; new arrest isn't torn down out from under it.
        ; GetCaptor(), not AwaitCaptorReference(): this only ever wants "tear down the existing Captor if there is
        ; one" - AwaitCaptorReference()'s create-if-missing semantics would force a fresh registration attempt if the
        ; guard's own 3D happened to be unloaded right now, which can never complete off-screen (a real test hit
        ; exactly this: "<Guard> is not loaded, cannot be registered right now!" right after an off-screen imprisonment).
        RPB_Captor captorRef = API.Arrest.GetCaptor(Captor)
        if (captorRef && captorRef.Arrestee == this)
            captorRef.Destroy()
        endif

        ; At this point, we can delete the prisoner's arrest state
        self.DestroyArrestState()
        RPB_Utility.FlowMark("Imprisoned: DestroyArrestState")
        RPB_Utility.Crumb(this, "Imprisoned: DestroyArrestState")

        self.RegisterLastUpdate()
        RPB_Utility.FlowMark("Imprisoned: RegisterLastUpdate")
        RegisterForUpdateGameTime(1.0)
        RPB_Utility.FlowMark("Imprisoned: RegisterForUpdateGameTime")
        RPB_Utility.Crumb(this, "Imprisoned: RegisterForUpdateGameTime")
        SetBool("Imprisoned", true)
    endEvent

    event OnUpdateGameTime()
        ; Dont update if the player is not nearby, let Prison Monitor handle it
        if (!Prison.ShouldActivelyMonitorPrisoner(self))
            Prison.SendMonitoringRequest()
            return
        endif

        self.UpdateInfamy()
        self.UpdateTimeJailed() ; Must be updated in some other way, otherwise it will reset to 0 on next imprisonment

        ; A prisoner is normally only neutralized once, at Imprison() time - but a disguise mod (Master of Disguise and
        ; similar) keeps re-evaluating the player's faction membership against currently worn gear, and if this prisoner
        ; isn't actually stripped (ShouldBeStripped off, a valid lighter-prison configuration), the disguise item never
        ; comes off, so such a mod could re-add the faction sometime during the sentence. Re-checking hourly bounds that
        ; window instead of leaving it neutral only until the first re-evaluation. IsHostilePrisoner() already makes this
        ; a near-free no-op for the common case (not currently in a listed hostile faction).
        self.NeutralizeWhileImprisoned()

        if (self.IsSentenceServed)
            Prison.SendReleaseRequest(self)
            return
        endif

        ; Debug("("+ Name +") Prisoner::OnUpdateGameTime", "this: " + this)
        ; Debug("("+ Name +") Prisoner::OnUpdateGameTime", "ActorVars: " + GetContainerList(RPB_StorageVars.GetObjectHandleOnReference(this, "ActorVars")))
        Debug("("+ Name +") Prisoner::OnUpdateGameTime", "Time Jailed: " + RPB_StorageVars.GetFloatOnReference(Prison.Hold + "::Time Jailed", this, "ActorVars"))

        Prison.DEBUG_ShowPrisonerSentenceInfo(self, true)
        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "("+ self.GetActor() +") Cell Package: " + self.CellPackage)
        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "Outfit: " + self.PrisonOutfit)
        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "this: " + this)


        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "currentTimeServedStored: " + currentTimeServedStored)

        self.RegisterLastUpdate()
        RegisterForSingleUpdateGameTime(1.0)
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
    SetBool("Escaped", true, "PrisonerEscape") ; refactor to EscapedAt perhaps, then calculate time since escaping, till re-caught
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
    RPB_Utility.FlowMark("Prisoner.MoveToCell: MoveTo(JailCell) done")
    RPB_Utility.Crumb(this, "Prisoner.MoveToCell: MoveTo(JailCell) done")
    Prison.OnPrisonerTeleportedToCell(self, abBeginImprisonment)
    RPB_Utility.FlowMark("Prisoner.MoveToCell: Prison.OnPrisonerTeleportedToCell returned")
    RPB_Utility.Crumb(this, "Prisoner.MoveToCell: Prison.OnPrisonerTeleportedToCell returned")
endFunction

function TriggerInfamyPenalty()
    if (!IsInfamyEnabled || CurrentInfamy <= 0 || Was("Infamy Penalty Applied") || (Bounty <= self.GetInt("Bounty to Trigger Infamy")))
        return
    endif

    ;/ constexpr /; int INFAMY_RECOGNIZED_THRESHOLD     = self.GetInt("Infamy Recognized Threshold")
    ;/ constexpr /; int INFAMY_KNOWN_THRESHOLD          = self.GetInt("Infamy Known Threshold")
    ;/ constexpr /; float INFAMY_RECOGNIZED_PENALTY     = self.GetFloat("Recognized Criminal Penalty")
    ;/ constexpr /; float INFAMY_KNOWN_PENALTY          = self.GetFloat("Known Criminal Penalty")

    ;/ const /; int INFAMY_NEUTRAL      = 0
    ;/ const /; int INFAMY_RECOGNIZED   = 1
    ;/ const /; int INFAMY_KNOWN        = 2

    int currentInfamyType
    float penaltyAsBounty = 0

    if (Infamy >= INFAMY_KNOWN_THRESHOLD)
        penaltyAsBounty = CurrentInfamy * (INFAMY_KNOWN_PENALTY * 0.01)
        currentInfamyType = INFAMY_KNOWN

    elseif (Infamy >= INFAMY_RECOGNIZED_THRESHOLD)
        penaltyAsBounty = CurrentInfamy * (INFAMY_RECOGNIZED_PENALTY * 0.01)
        currentInfamyType = INFAMY_RECOGNIZED

    else
        currentInfamyType = INFAMY_NEUTRAL
    endif

    ; Infamy shouldn't touch the Bounty, add to the Sentence instead
    int penaltyAsSentence = Round(penaltyAsBounty / Prison.BountyToSentence)
    SetInt("Criminal Penalty Sentence", penaltyAsSentence)

    Debug("("+ Name +") Prisoner::TriggerInfamyPenalty", "currentInfamyType: " + currentInfamyType + ", penaltyAsBounty: " + penaltyAsBounty + ", penaltyAsSentence: " + penaltyAsSentence)

    self.IncreaseSentence(penaltyAsSentence, abShouldAffectBounty = false)
    self.SetBool("Infamy Penalty Applied", true)
endFunction

bool function IsRestrained()
    return this.GetEquippedArmorInSlot(59) != none
endFunction

function Cuff(bool abCuffInFront = false)
    ; Form cuffs = Game.GetFormEx(0xA081D2F)
    Form cuffs = Game.GetFormFromFile(0x81D2F, "ZaZAnimationPack.esm")

    if (abCuffInFront)
        ; cuffs = Game.GetFormEx(0xA081D33)
        cuffs = Game.GetFormFromFile(0x81D33, "ZaZAnimationPack.esm")
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
int function ResolveStrippingType(bool abNudeBodyMod, bool abUnderwearBodyMod, bool abHasUnderwearWorn, int aiThoroughness) global
    ; Pure decision, no game state. Returns flags: 1 = stripped naked, 2 = stripped to underwear (exactly one of them).
    bool isAbleToStripNaked         = abNudeBodyMod
    bool isAbleToStripToUnderwear   = (isAbleToStripNaked && abUnderwearBodyMod && abHasUnderwearWorn) || !isAbleToStripNaked

    int result = 0

    if (isAbleToStripNaked && (aiThoroughness >= 10 || !isAbleToStripToUnderwear))
        result += 1
    endif

    if (isAbleToStripToUnderwear && (aiThoroughness < 10 || !isAbleToStripNaked))
        result += 2
    endif

    return result
endFunction

function DetermineStrippingType()
    ; Papyrus && / || do not short-circuit, so gather the inputs lazily: without a nude body mod the result is "to
    ; underwear" whatever the underwear or the thoroughness are (both cost tens of ms), and the thoroughness is read once.
    bool nudeBodyMod        = Config.HasNudeBodyModInstalled
    bool underwearBodyMod   = false
    bool hasUnderwearWorn   = false
    int thoroughness        = 0

    if (nudeBodyMod)
        underwearBodyMod = Config.HasUnderwearBodyModInstalled

        if (underwearBodyMod)
            hasUnderwearWorn = self.HasUnderwear()
        endif

        thoroughness = self.StrippingThoroughness
    endif

    int strippingType = RPB_Prisoner.ResolveStrippingType(nudeBodyMod, underwearBodyMod, hasUnderwearWorn, thoroughness)

    self.WillBeStrippedNaked        = Math.LogicalAnd(strippingType, 1) == 1
    self.WillBeStrippedToUnderwear  = Math.LogicalAnd(strippingType, 2) == 2

    ; Assert (WIP): the message is only built when something is wrong
    if (self.WillBeStrippedNaked == self.WillBeStrippedToUnderwear)
        EventManager.SendError("An error has occurred, cannot strip prisoner both naked and to underwear, logic error!", "("+ Name +") Prisoner::DetermineStrippingType")
    endif
endFunction

;/
    The original implementation, kept as the reference the new one is tested against (test 64).
/;
function __DetermineStrippingTypeReference()
    bool hasUnderwearWorn           = self.HasUnderwear()
    bool isAbleToStripNaked         = Config.HasNudeBodyModInstalled
    bool isAbleToStripToUnderwear   = (isAbleToStripNaked && Config.HasUnderwearBodyModInstalled && hasUnderwearWorn) || !isAbleToStripNaked

    self.WillBeStrippedNaked        = (isAbleToStripNaked       && (StrippingThoroughness >= 10 || !isAbleToStripToUnderwear))
    self.WillBeStrippedToUnderwear  = (isAbleToStripToUnderwear && (StrippingThoroughness < 10  || !isAbleToStripNaked))

    ; DebugParams( \ 
    ;     hasUnderwearWorn + "," + isAbleToStripNaked + "," + isAbleToStripToUnderwear + "," + self.WillBeStrippedNaked + "," + self.WillBeStrippedToUnderwear, \
    ;     "hasUnderwearWorn, isAbleToStripNaked, isAbleToStripToUnderwear, WillBeStrippedNaked, WillBeStrippedToUnderwear", \
    ;     "("+ Name +") Prisoner::DetermineStrippingType" \ 
    ; )

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
        EventManager.SendError("The prisoner " + Name + " hasn't had a belongings container assigned to "+ PronounObject +", therefore cannot strip!", "["+ Name +"] Prisoner::Strip")
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

    self.NPC_SaveWornArmor()
    self.SaveBelongingsManifest()
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
        self.ModBelongingsManifest(underwearTop, -1)
        self.ModBelongingsManifest(underwearBottom, -1)

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
        EventManager.SendError("The prisoner " + Name + " hasn't had a belongings container assigned to "+ PronounObject +", therefore cannot strip silently!", "["+ Name +"] Prisoner::StripSilently")
        return
    endif

    Armor underwearTop      = self.GetUnderwear("Top")
    Armor underwearBottom   = self.GetUnderwear("Bottom")

    NPC_SaveUnderwear(underwearTop, underwearBottom)

    self.NPC_SaveWornArmor()
    self.SaveBelongingsManifest()
    self.UnequipAll()
    self.RemoveAllItems(PrisonerBelongingsContainer, true, true) ; Remove and put all the items in the prisoner's possession in the assigned prisoner container
    self.UnequipHands()
    self.SheatheWeapon()
    self.OnStripped() ; Maybe use OnStrippedSilently?

    PrisonerBelongingsContainer.RemoveItem(underwearTop, abSilent = true, akOtherContainer = this)
    PrisonerBelongingsContainer.RemoveItem(underwearBottom, abSilent = true, akOtherContainer = this)
    self.ModBelongingsManifest(underwearTop, -1)
    self.ModBelongingsManifest(underwearBottom, -1)

    self.EquipItem(underwearTop)
    self.EquipItem(underwearBottom)
endFunction

function RemoveUnderwear()
    if (!self.PrisonerBelongingsContainer)
        EventManager.SendError("The prisoner " + Name + " hasn't had a belongings container assigned to "+ PronounObject +", therefore cannot remove underwear!", "["+ Name +"] Prisoner::RemoveUnderwear")
        return
    endif

    Armor underwearTop      = self.GetUnderwear("Top")
    Armor underwearBottom   = self.GetUnderwear("Bottom")

    if (underwearTop)
        this.RemoveItem(underwearTop, 1, true, PrisonerBelongingsContainer)
        self.ModBelongingsManifest(underwearTop, 1)
    endif

    if (underwearBottom)
        this.RemoveItem(underwearBottom, 1, true, PrisonerBelongingsContainer)
        self.ModBelongingsManifest(underwearBottom, 1)
    endif

    self.OnUnderwearRemoved(underwearTop, underwearBottom)
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

    if (akOutfit)
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

    ; EventManager.SendInfo("Determining Clothing Outfit" "("+ Name +") Prisoner::DetermineClothingOutfit")
    Config.NotifyJail("Determining Clothing Outfit")


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
    RPB_Utility.FlowMark("RTI: start")
    float rtiNow = CurrentTime
    RPB_Utility.FlowMark("RTI: CurrentTime read")
    SetFloat("Time of Imprisonment", rtiNow)
    RPB_Utility.FlowMark("RTI: SetFloat")
    int rtiMinute = RPB_Utility.GetCurrentMinute()
    RPB_Utility.FlowMark("RTI: GetCurrentMinute")
    SetInt("Minute of Imprisonment", rtiMinute)
    RPB_Utility.FlowMark("RTI: SetInt minute")
    SetInt("Hour of Imprisonment", RPB_Utility.GetCurrentHour())
    SetInt("Day of Imprisonment", RPB_Utility.GetCurrentDay())
    SetInt("Month of Imprisonment", RPB_Utility.GetCurrentMonth())
    SetInt("Year of Imprisonment", RPB_Utility.GetCurrentYear())
    RPB_Utility.FlowMark("RTI: hour+day+month+year done")
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
    if (Has("Sentence Set"))
        EventManager.SendWarning("A sentence has already been set for this prisoner ("+ self.GetIdentifier() +"). \nConsider using IncreaseSentence() or DecreaseSentence() instead.", "["+ Name +"] Prisoner::SetSentence")
        return
    endif

    if (self.IsUndeterminedSentence && aiSentenceInDays == 0)
        EventManager.SendInfo("Setting an undetermined sentence for prisoner " + self.GetActor(), "["+ Name +"] Prisoner::SetSentence")
        return
    endif

    if (aiSentenceInDays <= 0 && !self.Bounty)
        EventManager.SendWarning("Sentence must be greater than 0 days. (Sentence not set)", "["+ Name +"] Prisoner::SetSentence")
        return
    endif

    self.SetInt("Sentence", \ 
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

bool function HasReleaseTimeExtraHours()
    return GetBool("Has Extra Release Hours")
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
    self.NoteStateEntered()
    self.UnregisterForUpdates()

    ; If the Release must fall in between Minimum and Maximum release hours, set the hour to the minimum before passing the days.
    if (self.HasReleaseTimeExtraHours())
        RPB_Utility.SetGameHour(Prison.ReleaseTimeMinimumHour)
        Debug("["+ Name +"] Prisoner::FastForwardToRelease", "Setting Game Hour to Release Time Minimum Hour: " + RPB_Utility.GetTimeAs12Hour(Prison.ReleaseTimeMinimumHour))
    endif

    ; Process all NPC Prisoners that have a Sentence less than the Player's, chronologically: each one is released at its own
    ; release time (time is passed by the difference between them), the player's own time is passed after that.
    ; This should probably be processed globally for all Prisons, but just for testing it's done with the same one the Player is in.
    Prison.ReleaseDueNPCsInOrder(TimeLeftInSentence)

    ; Pass the time
    int timeLeft = Math.Ceiling(TimeLeftInSentence)
    RPB_Utility.PassTimeInDays(timeLeft)

    self.UpdateTimeJailed()
    self.UpdateInfamy()

    ; float currentTimeBeforeChanges = CurrentTime
    ; __currentTimeOverride = CurrentTime + timeLeft

    ; Debug("["+ Name +"] Prisoner::FastForwardToRelease", "CurrentTime: " + currentTimeBeforeChanges + ", timeLeft: " + timeLeft + ", currentTimeOverride: " + __currentTimeOverride + ", TimeLeftInSentence: " + TimeLeftInSentence)

    GotoState("Awaiting")
    self.NoteStateEntered()

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
        SetBool("Has Extra Release Hours", true)
    endif
endFunction

;/
    The belongings containers are shared between prisoners (one is picked at random for each), so what this prisoner put
    there is recorded when it is stripped (item forms and counts, in the storage on the actor) and exactly that is
    returned on release: RemoveAllItems() would hand another prisoner's things over to whoever is released first.
    Kept up to BELONGINGS_MANIFEST_MAX entries (Papyrus array limit); a longer inventory marks the manifest incomplete and
    the release falls back to returning the whole container.
/;
int property BELONGINGS_MANIFEST_MAX = 120 autoreadonly

function SaveBelongingsManifest()
    int total = this.GetNumItems()
    int count = total
    int manifestState = 1 ; 1 = complete, 2 = incomplete
    if (count > BELONGINGS_MANIFEST_MAX)
        count = BELONGINGS_MANIFEST_MAX
        manifestState = 2
    endif

    Form[] forms = new Form[120]
    int[] counts = new int[120]
    int i = 0
    while (i < count)
        Form item = this.GetNthForm(i)
        forms[i] = item
        counts[i] = this.GetItemCount(item)
        i += 1
    endWhile

    string refKey = self.__GetRefKey()
    string category = self.GetScriptVarCategory("Actor")
    RPB_StorageVars.SetFormsOnReference("Belongings Forms", refKey, self.__TrimForms(forms, count), category)
    RPB_StorageVars.SetIntsOnReference("Belongings Counts", refKey, self.__TrimInts(counts, count), category)
    SetInt("Belongings Manifest", manifestState)
    EventManager.SendInfo("Recorded " + count + " of " + total + " belongings of " + self.Name + " (manifest " + string_if (manifestState == 1, "complete", "incomplete") + ")", "["+ Name +"] Prisoner::SaveBelongingsManifest")
endFunction

Form[] function __TrimForms(Form[] akForms, int aiCount)
    if (aiCount <= 0)
        return Utility.CreateFormArray(0)
    endif

    Form[] trimmed = Utility.CreateFormArray(aiCount)
    int i = 0
    while (i < aiCount)
        trimmed[i] = akForms[i]
        i += 1
    endWhile
    return trimmed
endFunction

int[] function __TrimInts(int[] aiInts, int aiCount)
    if (aiCount <= 0)
        return Utility.CreateIntArray(0)
    endif

    int[] trimmed = Utility.CreateIntArray(aiCount)
    int i = 0
    while (i < aiCount)
        trimmed[i] = aiInts[i]
        i += 1
    endWhile
    return trimmed
endFunction

;/
    Adjusts one item of the manifest by @aiDelta (underwear moved between the container and the actor after the strip).
/;
function ModBelongingsManifest(Form akItem, int aiDelta)
    if (!akItem || GetInt("Belongings Manifest") != 1)
        return
    endif

    string refKey = self.__GetRefKey()
    string category = self.GetScriptVarCategory("Actor")
    Form[] forms = RPB_StorageVars.GetFormsOnReference("Belongings Forms", refKey, category)
    int[] counts = RPB_StorageVars.GetIntsOnReference("Belongings Counts", refKey, category)

    int index = -1
    if (forms)
        index = forms.Find(akItem)
    endif

    if (index >= 0)
        counts[index] = counts[index] + aiDelta
    elseIf (aiDelta > 0 && (!forms || forms.Length < BELONGINGS_MANIFEST_MAX))
        int oldLength = 0
        if (forms)
            oldLength = forms.Length
        endif
        Form[] grownForms = Utility.CreateFormArray(oldLength + 1)
        int[] grownCounts = Utility.CreateIntArray(oldLength + 1)
        int i = 0
        while (i < oldLength)
            grownForms[i] = forms[i]
            grownCounts[i] = counts[i]
            i += 1
        endWhile
        grownForms[oldLength] = akItem
        grownCounts[oldLength] = aiDelta
        forms = grownForms
        counts = grownCounts
    else
        return
    endif

    RPB_StorageVars.SetFormsOnReference("Belongings Forms", refKey, forms, category)
    RPB_StorageVars.SetIntsOnReference("Belongings Counts", refKey, counts, category)
endFunction

function ReturnBelongings()
    if (!PrisonerBelongingsContainer)
        return
    endif

    if (GetInt("Belongings Manifest") != 1)
        if (self.IsNPC())
            ; The container is shared: RemoveAllItems() here handed one NPC the belongings of everybody else (55 tunics for one NPC in the
            ; mass test) and left the next ones with nothing. An NPC without a manifest gets nothing back, its outfit is issued again.
            EventManager.SendInfo("No belongings manifest for " + self.Name + ", nothing is returned from the shared container (the outfit is issued again)", "["+ Name +"] Prisoner::ReturnBelongings")
            return
        endif

        ; The player: no better source for irreplaceable items, everything in the container, as before
        PrisonerBelongingsContainer.RemoveAllItems(this, false, true)
        return
    endif

    string refKey = self.__GetRefKey()
    string category = self.GetScriptVarCategory("Actor")
    Form[] forms = RPB_StorageVars.GetFormsOnReference("Belongings Forms", refKey, category)
    int[] counts = RPB_StorageVars.GetIntsOnReference("Belongings Counts", refKey, category)

    int returned = 0
    int i = 0
    while (forms && i < forms.Length)
        int inContainer = PrisonerBelongingsContainer.GetItemCount(forms[i])
        int amount = counts[i]
        if (inContainer < amount)
            amount = inContainer
        endif
        if (amount > 0)
            PrisonerBelongingsContainer.RemoveItem(forms[i], amount, true, this)
            returned += 1
        endif
        i += 1
    endWhile

    Remove("Belongings Manifest")
    Remove("Belongings Forms")
    Remove("Belongings Counts")
    EventManager.SendInfo("Returned " + returned + " kinds of belongings to " + self.Name, "["+ Name +"] Prisoner::ReturnBelongings")
endFunction

;                        Imprisonment
; ==========================================================

function NotifySentence()
    if (self.ShowSentence && !self.IsUndeterminedSentence)
        string sentenceFormatted = RPB_Utility.GetTimeFormatted(Sentence, abIncludeHours = false)
        Config.NotifyJail("Your sentence was set at "+ sentenceFormatted +" in " + Prison.Name, self.IsPlayer())
        Config.NotifyJail(Name + " has been sentenced to "+ sentenceFormatted +" in " + Prison.Name, self.IsNPC())
    endif
endFunction

function NotifyReleaseDate()
    if (self.ShowReleaseTime && !self.IsUndeterminedSentence)
        string releaseDateFormatted = Prison.GetTimeOfReleaseFormatted(self)
        Config.NotifyJail("Your release is due on " + releaseDateFormatted, self.IsPlayer())
        Config.NotifyJail(Name + "'s release is due on " + releaseDateFormatted, self.IsNPC())
    endif
endFunction

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

    float startBench = StartBenchmark()
    self.OnImprisoned()
    RPB_Utility.FlowMark("Imprison: OnImprisoned done")
    RPB_Utility.Crumb(this, "Imprison: OnImprisoned done")
    self.NeutralizeWhileImprisoned() ; no-op for the common (non-hostile) prisoner; see IsHostilePrisoner. Player or NPC alike.
    GotoState("Imprisoned") ; State when the prisoner is in the cell, check for updates for sentence, etc...
    RPB_Utility.FlowEnd("Imprison: GotoState(Imprisoned) done")
    EndBenchmark(startBench, "Ended ["+ Name +"] Prisoner::Imprison")
endFunction

Form[] function GetCellMates()
    Form[] prisonersInCell  = self.JailCell.Prisoners
    int cellMates           = FastArray("<Form>")

    int i = 0
    while (i < prisonersInCell.Length)
        if (prisonersInCell[i] != self.GetActor())
            FastArray_AddForm(cellMates, prisonersInCell[i])
        endif
        i += 1
    endWhile

    return FastArray_ToFormArray(cellMates)
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

function UpdateInfamyLost()
    Prison.UpdateInfamyLost(this)
    Prison.ClearActorInfamyState(this)
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

    ; Debug("["+ Name +"] Prisoner::PerformDeleveling", "Handling Type: " + handlingType)

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
        return RPB_StorageVars.GetFloatOnReference("Previous Update Time Served", this, "Temporary")
    endFunction

    function set(float value)
        RPB_StorageVars.SetFloatOnReference("Previous Update Time Served", this, value, "Temporary")
    endFunction
endProperty

function UpdateTimeJailed()
    float timeJailedSinceLastUpdate = GetElapsedTimeBetweenTimes(PreviousUpdateTimeServed, TimeServed)

    int maxDays = RPB_Utility.GetMaxDayEventsPerUpdate()
    if (timeJailedSinceLastUpdate > maxDays)
        DebugError("["+ Name +"] Prisoner::UpdateTimeJailed", "Elapsed time of " + timeJailedSinceLastUpdate + " days is over the " + maxDays + " day bound, clamping it.")
        timeJailedSinceLastUpdate = maxDays
    endif

    int daysElapsed = timeJailedSinceLastUpdate as int

    ; Debug("["+ Name +"] Prisoner::UpdateTimeJailed", "TimeServed: " + TimeServed + ", PreviousUpdateTimeServed: " + PreviousUpdateTimeServed + ", timeJailedSinceLastUpdate: " + timeJailedSinceLastUpdate)
    ; Debug("["+ Name +"] Prisoner::UpdateTimeJailed()", "Before UpdateDayEvents: PreviousUpdateTimeServed = " + PreviousUpdateTimeServed)

    self.UpdateDayEvents()
    
    ; Debug("["+ Name +"] Prisoner::UpdateTimeJailed()", "After UpdateDayEvents: PreviousUpdateTimeServed = " + PreviousUpdateTimeServed)

    self.ModifyStat("Time Jailed", timeJailedSinceLastUpdate)

    if (self.IsPlayer() && daysElapsed > 0)
        Game.IncrementStat("Days Jailed", daysElapsed)
    endif

    PreviousUpdateTimeServed = TimeServed
    ; Debug("["+ Name +"] Prisoner::UpdateTimeJailed()", "(Function End) PreviousUpdateTimeServed = " + PreviousUpdateTimeServed + ", TimeServed = " + TimeServed + ", LastUpdate: " + LastUpdate)
endFunction

function UpdateDayEvents()
    int daysElapsed = GetElapsedTimeBetweenTimes(PreviousUpdateTimeServed, TimeServed) as int
    ; Debug("["+ Name +"] Prisoner::UpdateDayEvents", "PreviousUpdateTimeServed: " + PreviousUpdateTimeServed + ", TimeServed: " + TimeServed + ", daysElapsed: " + daysElapsed)

    ; One day event per elapsed day with no bound made a 100000 day gap run for 7 minutes in a single stack (~4 ms each)
    int maxDays = RPB_Utility.GetMaxDayEventsPerUpdate()
    if (daysElapsed > maxDays)
        DebugError("["+ Name +"] Prisoner::UpdateDayEvents", daysElapsed + " day events are pending, more than the " + maxDays + " day bound: running " + maxDays + ".")
        daysElapsed = maxDays
    endif

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

    ; Debug("["+ Name +"] Prisoner::UpdateLongestSentence", "[\n" + \ 
    ;     "\t Current Longest Sentence: " + currentLongestSentence + "\n" + \
    ;     "\t New Longest Sentence: " + newLongestSentence + "\n" + \
    ;     "\t Sentence: " + Sentence + "\n" + \
    ; "]")
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
    ; RPB_StorageVars.SetBoolOnReference("Is Initialized", this, false, "Actor")

    ; Debug("("+ Name +") Prisoner::Destroy", "Object: " + GetContainerList(RPB_StorageVars.GetObjectHandleOnReference(this)))
    ; TODO: Unset all properties related to this Prisoner
    Prison.UnregisterPrisoner(self)
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
    self.UpdateInfamyLost()
    self.TriggerInfamyPenalty()

    int errors = RPB_Memory.FastArray("<string>")

    ; The messages contain the prisoner's name (an engine native), so they are only built when a condition fails
    if (!(WillBeStrippedNaked || WillBeStrippedToUnderwear))
        errors = EnsureTrue(false, "Could not determine the stripping type for Prisoner " + Name, errors)
    endif

    if (!TeleportReleaseLocation)
        errors = EnsureTrue(false, "Could not determine the release location for Prisoner " + Name, errors)
    endif

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

    RPB_Utility.FlowMark("DestroyArrestState: IsActorArrested")
    RPB_Arrestee arrestState = RPB_Arrestee.GetStateForPrisoner(self)
    RPB_Utility.FlowMark("DestroyArrestState: GetStateForPrisoner")
    arrestState.Destroy()
    RPB_Utility.FlowMark("DestroyArrestState: Arrestee.Destroy")
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
    SetFloat("Last Update", Utility.GetCurrentGameTime())
endFunction


;/
    Locks the prisoner's settings configured in the MCM for the Prison they are housed in.

    This makes it possible to change the MCM options while imprisoned, and they will have no change
    because they were already set for this Prisoner, guaranteeing that this Prisoner's state will not change while they are in prison.
/;
function LockPrisonerSettings()
    ; The MCM settings of this Prison are the same for every prisoner until an option changes, so they are read once
    ; into a per-Prison snapshot (rebuilt only when stale) and COPIED into this prisoner: it keeps the values it was
    ; jailed under even when the MCM (and the snapshot) change later.
    self.SetPairs(Prison.GetSettingsSnapshot())
endFunction

;/
    The original way of locking the settings: one Prison property read and one write per setting (~68 of each).
    Kept as the reference the snapshot is tested against.
/;
function __LockPrisonerSettingsDirect()
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
    SetInt("Minimum Number of Stolen Items Required",           Prison.MinimumNumberOfStolenItemsRequiredToStripOnFrisk)
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

;/
    The earliest release may have moved: let the prison's background monitor recompute its single wake.
/;
function __RescheduleMonitor()
    if (self.IsNPC())
        Prison.SendMonitoringReschedule()
    endif
endFunction

event OnSentenceSet(int aiSentence, float afAtWhatTime)
    self.__RescheduleMonitor()
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    self.UpdateLongestSentence()
endEvent

event OnSentenceChanged(int aiOldSentence, int aiNewSentence, bool abHasSentenceIncreased, bool abSentenceAffectsBounty)
    self.__RescheduleMonitor()
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

    ; Debug("["+ Name +"] Prisoner::OnStatChanged", "Stat " + asStatName + " has been changed to " + afValue)
endEvent

;                Imprisonment / Sleep / Time
; ==========================================================

; Triggered whenever a full day has passed
event OnDayPassed()
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    ; Debug("["+ Name +"] Prisoner::OnDayPassed", "A day has passed.")
    self.PerformDeleveling()
endEvent

int __serveTimeLastDayRegistered
; Real time (seconds) at which this prisoner entered a transient serve/release state (ServeOnRest, Awaiting, Releasing)
float __serveStateEnteredAt

function NoteStateEntered()
    __serveStateEnteredAt = Utility.GetCurrentRealTime()
endFunction

;/
    Self-healing: a prisoner that has been in a transient serve/release state for over a minute got stuck there (the flow
    that should have moved it on never finished), which used to leave "serve your sentence" doing nothing. Back to Imprisoned.
/;
function __RecoverStuckServeState()
    string currentState = self.GetState()
    if (currentState != "ServeOnRest" && currentState != "Awaiting" && currentState != "Releasing")
        return
    endif

    if (!self.IsImprisoned || __serveStateEnteredAt <= 0.0 || (Utility.GetCurrentRealTime() - __serveStateEnteredAt) < 60.0)
        return
    endif

    DebugError("["+ Name +"] Prisoner::__RecoverStuckServeState", "Stuck in the '" + currentState + "' state for over a minute, back to Imprisoned.")
    Prison.SetPlayerFastForwardingToRelease(false)
    self.GotoState("Imprisoned")
endFunction

event OnSleepStart(float afSleepStartTime, float afSleepEndTime)
    self.__RecoverStuckServeState()
    if (!self.ShouldProcessImprisonmentEvents)
        return
    endif

    if (self.IsUndeterminedSentence)
        EventManager.SendInfo(Name + " currently has an undetermined sentence, cannot serve time.", "["+ Name +"] Prisoner::OnSleepStart")
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
    RPB_Utility.FlowMark("OnImprisoned: RegisterTimeOfImprisonment")
    self.DetermineReleaseTimeAdditionalHours() ; For Release Time (Minimum, Maximum) intervals
    RPB_Utility.FlowMark("OnImprisoned: DetermineReleaseTimeAdditionalHours")
    self.NotifySentence()
    RPB_Utility.FlowMark("OnImprisoned: NotifySentence")
    self.NotifyReleaseDate()
    RPB_Utility.FlowMark("OnImprisoned: NotifyReleaseDate")

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
endEvent

event OnEscaped()
endEvent

;                         Management
; ==========================================================

event OnInitialize()
    ; An instance that starts while this actor is being released (its 3D loads when it is moved out) must do nothing: it used to
    ; rebind/register the released actor in the prison again.
    if (self.GetBool("Releasing"))
        RPB_Utility.Crumb(this, "Prisoner.OnInitialize: the actor is being released, nothing to initialize")
        return
    endif

    ; DebugInfo("("+ Name +") Prisoner::OnInitialize", "State: " + self.GetState())
    ; DebugInfo("("+ Name +") Prisoner::OnInitialize", "IsInitialized: " + self.IsInitialized)

    ; The Prison UUID is written before the spell is added, but keep a bounded wait as a safety net (the effect starts on
    ; another thread): without a Prison this prisoner can never register.
    int bindingTries = 0
    while (self.GetString("Prison UUID") == "" && bindingTries < 20)
        Utility.Wait(0.1)
        bindingTries += 1
    endWhile

    if (RPB_Utility.IsCrumbsEnabled())
        RPB_Utility.Crumb(this, "Prisoner.OnInitialize: enter (Was Initialized: " + self.Was("Initialized") + ", IsImprisoned: " + self.IsImprisoned + ", binding waits: " + bindingTries + ", Prison: " + Prison + ")")
    endif

    if (self.IsNPC() && self.IsImprisoned)
        self.NPC_ResumeImprisonment()
    endif

    if (self.Was("Initialized"))
        RPB_Utility.Crumb(this, "Prisoner.OnInitialize: already initialized, rebinding the prison list to this instance")
        Prison.RebindPrisoner(self)
        return
    endif

    Prison.RegisterPrisoner(self)
    RPB_Utility.Crumb(this, "Prisoner.OnInitialize: RegisterPrisoner returned")
    ; DebugInfo("("+ Name +") Prisoner::OnInitialize", "Initialized: " + self.Was("Initialized"))
endEvent

event OnRestore()
    ; if (self.IsNPC() && self.IsImprisoned)
    ;     self.NPC_ResumeImprisonment()
    ; endif

    DebugInfo("("+ Name +") Prisoner::OnRestore", "Restoring Prisoner: " + Name)

    ; The effect starts again when the actor's 3D loads (after being away): IsInitialized is persistent, so OnInitialize does
    ; not run and nothing resumed the imprisonment (Imprisoned state, hourly update, cell sanity check). Do it here.
    if (self.IsNPC() && self.IsImprisoned)
        self.NPC_ResumeImprisonment()
    endif
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
        ; Not sticky anymore: a read that happens before the binding is written used to fail the prisoner for good.
        ; Only an error while the effect is running: a finishing effect (state already cleaned up) asks for its Prison too.
        if (self.IsEffectActive)
            EventManager.SendError("There was an error retrieving the Prison belonging to Prisoner: " + self.Name, "["+ Name +"] Prisoner::GetPrison")
        endif
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

    ; Choosing a free package alias and binding to it must be one step for the whole game: an alias only holds one actor, and two
    ; prisoners choosing the same free one meant the second bind took the package away from the first.
    int packageLock = RPB_ThreadLock.Get("CellPackages")
    RPB_ThreadLock.Acquire(packageLock)

    if (self.HasCellPackage)
        RPB_ThreadLock.Release(packageLock)
        return
    endif

    ReferenceAlias cellPackageAlias = self.CellPackage
    if (cellPackageAlias && cellPackageAlias.GetReference() != none && cellPackageAlias.GetActorReference() != this)
        ; the alias chosen earlier (and remembered) has been taken by someone else since: choose again
        Remove("Cell Package ID")
        Remove("Cell Package Group")
        cellPackageAlias = self.CellPackage
    endif

    if (!cellPackageAlias)
        RPB_ThreadLock.Release(packageLock)
        EventManager.SendError("There was an error retrieving the Cell Package belonging to Prisoner: " + self.Name, "["+ Name +"] Prisoner::NPC_BindToCell")
        return
    endif

    self.BindAlias(cellPackageAlias)
    RPB_ThreadLock.Release(packageLock)
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

    if (!self.CellPackage)
        EventManager.SendError("There was an error retrieving the Cell Package belonging to Prisoner: " + self.Name, "["+ Name +"] Prisoner::NPC_UnbindFromCell")
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

; The original outfit and the underwear live in the storage on the actor reference (not in script variables of this effect
; instance): an unload ends the effect and a reload starts a NEW instance, whose variables are empty, so the NPC could never
; get his outfit back.
Outfit property NPC_OriginalOutfit
    Outfit function get()
        return GetForm("NPC Original Outfit") as Outfit
    endFunction
endProperty

; Not every NPC has underwear: the entries may be none
Armor function NPC_GetUnderwearTop()
    return GetForm("NPC Underwear Top") as Armor
endFunction

Armor function NPC_GetUnderwearBottom()
    return GetForm("NPC Underwear Bottom") as Armor
endFunction

; Always a two element array (entries may be none); prefer the two functions above
Armor[] function NPC_GetUnderwear()
    Armor[] underwear = new Armor[2]
    underwear[0] = self.NPC_GetUnderwearTop()
    underwear[1] = self.NPC_GetUnderwearBottom()
    return underwear
endFunction

int property NPC_UNDERWEAR_TOP_INDEX    = 0 autoreadonly
int property NPC_UNDERWEAR_BOTTOM_INDEX = 1 autoreadonly

function NPC_SaveUnderwear(Armor akUnderwearTop, Armor akUnderwearBottom)
    if (self.IsNPC())
        ; SetForm(key, none) is unreliable with the storage: a none part deletes the variable instead
        if (akUnderwearTop)
            SetForm("NPC Underwear Top", akUnderwearTop)
        else
            Remove("NPC Underwear Top")
        endif
        if (akUnderwearBottom)
            SetForm("NPC Underwear Bottom", akUnderwearBottom)
        else
            Remove("NPC Underwear Bottom")
        endif
    endif
endFunction

function NPC_SaveOriginalOutfit()
    if (self.IsNPC())
        Outfit npcBaseOutfit = this.GetActorBase().GetOutfit()

        ; The outfit belongs to the ActorBase, shared by every NPC of that base: once the first of them is stripped the base outfit is
        ; "Naked" and the others would find nothing to save. So the real outfit is also remembered per base, and an NPC stripped
        ; while the base is "Naked" takes the remembered one.
        string baseOutfitKey = "Original Outfit " + this.GetActorBase().GetFormID()
        if (npcBaseOutfit != RPB_GetOutfit("Naked"))
            ; Ensure we don't save a 'naked' outfit.
            SetForm("NPC Original Outfit", npcBaseOutfit)
            RPB_StorageVars.SetForm(baseOutfitKey, npcBaseOutfit, "BaseOutfits")
        else
            Form rememberedOutfit = RPB_StorageVars.GetForm(baseOutfitKey, "BaseOutfits")
            if (rememberedOutfit)
                SetForm("NPC Original Outfit", rememberedOutfit)
            endif
        endif
    endif
endFunction

function NPC_RestoreOriginalOutfit()
    if (!self.IsNPC())
        return
    endif

    Outfit original = NPC_OriginalOutfit
    EventManager.SendInfo("Restoring outfit of " + self.Name + ": saved " + original + ", base outfit now " + this.GetActorBase().GetOutfit(), "["+ Name +"] Prisoner::NPC_RestoreOriginalOutfit")
    if (original)
        this.SetOutfit(original)
    endif
endFunction

;/
    SetOutfit() only changes the default outfit, it does not equip what the actor already carries, and the belongings are
    returned after the Released state starts. Called once they are back: sets the outfit again if needed and equips every
    armor part of the original outfit the actor carries (leveled list parts cannot be resolved here and are skipped).
/;
function NPC_ReequipAfterRelease()
    if (!self.IsNPC())
        return
    endif

    ; Guards and other template based NPCs have no Outfit of their own (nothing saved): the worn armor snapshot covers them.
    ; Deliberately never call SetOutfit("Naked")'s inverse here for a none original - a none Outfit means this NPC's real
    ; appearance was never Outfit-driven to begin with (it's inventory/template driven), so there is nothing meaningful to
    ; "restore" via SetOutfit, and NPC_SetPersistentOutfit("Naked") staying on this ActorBase's own default outfit forever
    ; is the accepted, already-tracked cost (ROADMAP.md: "Stripping via Outfit = Naked affects the whole Base Object") -
    ; not something to work around here by clearing the override, since that would also remove the one thing
    ; NPC_SetPersistentOutfit exists for: stopping the engine from re-equipping this NPC from its own template if its 3D
    ; reloads while still imprisoned. Real, directly-equipped worn armor (below) is what actually determines how the NPC
    ; looks - it takes priority over whatever the "default outfit" says regardless of that record's own stuck value.
    Outfit original = NPC_OriginalOutfit
    int parts = 0
    int equipped = 0
    int skipped = 0
    int reissued = 0
    if (original)
        if (this.GetActorBase().GetOutfit() != original)
            this.SetOutfit(original)
        endif

        parts = original.GetNumParts()
        int i = 0
        while (i < parts)
            Armor part = original.GetNthPart(i) as Armor
            if (!part)
                skipped += 1
            else
                if (this.GetItemCount(part) == 0)
                    ; The belongings did not bring this part back: outfit items are generic, issue it again instead of leaving the NPC bare
                    this.AddItem(part, 1, true)
                    reissued += 1
                endif
                this.EquipItem(part)
                equipped += 1
            endif
            i += 1
        endWhile
    endif

    int wornEquipped = self.NPC_ReequipSavedWornArmor()
    EventManager.SendInfo("Re-equipped " + equipped + " of " + parts + " outfit parts (" + skipped + " not plain armors, " + reissued + " issued again because the belongings did not have them, saved outfit " + original + ") and " + wornEquipped + " saved worn armors on " + self.Name + ", worn body: " + this.GetWornForm(0x4), "["+ Name +"] Prisoner::NPC_ReequipAfterRelease")
endFunction

;/
    The armor the NPC wears when it is stripped, per slot, in the storage on the actor. Needed for NPCs whose gear does not
    come from their own default Outfit (guards use templates: GetOutfit() is none), so the outfit alone cannot dress them again.
    Must be called BEFORE the NPC is unequipped and emptied.
/;
;/
    Called once the NPC has been moved to its release location and has its AI back: one release in the mass test (1 of 9) left
    the NPC with all its clothes in the inventory and nothing on (the first equip runs while the NPC is still in its cell).
    Equips what is carried but not worn, of the original outfit and the saved worn armor. Silent when nothing was off.
/;
function NPC_EnsureDressed()
    if (!self.IsNPC())
        return
    endif

    int fixed = 0
    Outfit original = NPC_OriginalOutfit
    if (original)
        int parts = original.GetNumParts()
        int i = 0
        while (i < parts)
            Armor part = original.GetNthPart(i) as Armor
            if (part && this.GetItemCount(part) > 0 && !this.IsEquipped(part))
                this.EquipItem(part)
                fixed += 1
            endif
            i += 1
        endWhile
    endif
    fixed += self.NPC_ReequipSavedWornArmor()

    if (fixed > 0)
        EventManager.SendInfo("Equipped " + fixed + " items that were still off after the release on " + self.Name, "["+ Name +"] Prisoner::NPC_EnsureDressed")
    endif
endFunction

int[] function __NPC_WornArmorSlots()
    ; Every armor occupies at least one of the 32 body slots (30..61), so scanning all of them is complete for any NPC or mod list
    int[] slots = new int[32]
    int i = 0
    while (i < 32)
        slots[i] = 30 + i
        i += 1
    endWhile
    return slots
endFunction

function NPC_SaveWornArmor()
    if (!self.IsNPC())
        return
    endif

    ; Called right after OnPrisonerTeleportedToCell's own MoveTo(JailCell), with no wait of its own - GetWornForm() read
    ; immediately after a teleport can come back empty even when the actor genuinely has gear equipped (confirmed real
    ; log: 0 saved worn armor slots for an arrested bandit that should have had gear). The release side already learned
    ; this exact lesson for equipping (RPB_Prison.psc's own "equip on an actor whose 3D is not loaded yet can be
    ; dropped" wait) - apply the same bounded wait here, on the read side, before trusting GetWornForm().
    float loadWaited = 0.0
    while (!this.Is3DLoaded() && loadWaited < 1.5)
        Utility.Wait(0.1)
        loadWaited += 0.1
    endWhile

    int[] slots = self.__NPC_WornArmorSlots()
    Form[] seen = new Form[32] ; an armor covering several slots is stored once
    int saved = 0
    int i = 0
    while (i < slots.Length)
        string wornKey = "NPC Worn Armor " + slots[i]
        Armor worn = this.GetWornForm(Math.LeftShift(1, slots[i] - 30)) as Armor
        if (worn && seen.Find(worn) < 0)
            seen[saved] = worn
            SetForm(wornKey, worn)
            saved += 1
        elseIf (GetForm(wornKey))
            Remove(wornKey)
        endif
        i += 1
    endWhile
    EventManager.SendInfo("Saved " + saved + " worn armor slots of " + self.Name + " before stripping", "["+ Name +"] Prisoner::NPC_SaveWornArmor")
endFunction

int function NPC_ReequipSavedWornArmor()
    int[] slots = self.__NPC_WornArmorSlots()
    int equipped = 0
    int i = 0
    while (i < slots.Length)
        Armor saved = GetForm("NPC Worn Armor " + slots[i]) as Armor
        if (saved && this.GetItemCount(saved) > 0 && !this.IsEquipped(saved))
            this.EquipItem(saved)
            equipped += 1
        endif
        i += 1
    endWhile
    return equipped
endFunction

;/
    Delegates to RPB_Utility.IsHostileActor(this) - see there for why this is Actor-based (not just this instance's storage):
    the same check also has to run from RPB_Arrest.BeginArrest, before an RPB_Prisoner instance exists at all.
/;
bool function IsHostilePrisoner()
    return RPB_Utility.IsHostileActor(this)
endFunction

;/
    Delegates to RPB_Utility.NeutralizeHostileActor(this) - kept as a same-named instance method so Imprison() and the hourly
    Imprisoned-state tick don't need to change; see RPB_Utility.NeutralizeHostileActor's doc comment for why the real logic
    (and its storage) lives there instead of here, and for the other two places this same actor gets neutralized (arrest time,
    hourly while imprisoned).
/;
function NeutralizeWhileImprisoned()
    RPB_Utility.NeutralizeHostileActor(this)
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

    Armor underwearTop      = self.NPC_GetUnderwearTop()
    Armor underwearBottom   = self.NPC_GetUnderwearBottom()

    bool hasUnderwearInInventory    = this.GetItemCount(underwearTop) >= 1 || this.GetItemCount(underwearBottom) >= 1
    bool wasStrippedToUnderwear     = self.Was("Stripped") && self.IsStrippedToUnderwear
    ; IsNaked() only ever checks body slot 32 - equipping underwear (a different, configurable slot) never changes what
    ; it sees, so shouldBeInUnderwear never turns false on its own once true. Without an already-equipped check, every
    ; call re-"equips" (a harmless no-op once already worn) and re-logs "Equipped underwear" regardless of whether
    ; anything actually needed doing - confirmed in a real test, where a repeated sanity-check retry logged this line
    ; 10 times in a row for an already-correctly-dressed prisoner. I first tried self.HasUnderwear() here, but that
    ; only checks whether the configured slot is occupied by ANYTHING, not specifically by this prisoner's own
    ; designated underwear - a real regression followed: with something else able to occupy that slot, this read false
    ; from the very first check and the prisoner never got dressed at all. Checking the specific items directly (the
    ; same "carried but not worn" idiom already used elsewhere in this file, e.g. NPC_EnsureDressed) avoids that.
    bool isUnderwearAlreadyWorn     = (underwearTop == none || this.IsEquipped(underwearTop)) && (underwearBottom == none || this.IsEquipped(underwearBottom))
    bool shouldBeInUnderwear        = self.IsNaked() && wasStrippedToUnderwear && hasUnderwearInInventory && !isUnderwearAlreadyWorn

    if (shouldBeInUnderwear)
        self.EquipItem(underwearTop,    abCondition = underwearTop != none)
        self.EquipItem(underwearBottom, abCondition = underwearBottom != none)
    endif

    ; Unlike shouldBeInUnderwear above, "genuinely has none" has no already-worn term to turn it false on its own -
    ; it's a stable fact about this prisoner, so without a latch it logged on every single sanity-check pass forever
    ; (confirmed in a real test: 10 repeats in one capture for a prisoner with no underwear at all). Was("Warned No
    ; Underwear") gates it to once, the same shape as the Was("Stripped") flag already read above.
    bool hasNoUnderwearAtAll = wasStrippedToUnderwear && !hasUnderwearInInventory && !self.Was("Warned No Underwear")
    if (hasNoUnderwearAtAll)
        self.SetBool("Warned No Underwear", true)
    endif

    EventManager.SendInfo("Equipped underwear on " + self.Name, "["+ Name +"] Prisoner::NPC_UpdateUnderwear", shouldBeInUnderwear)
    EventManager.SendInfo("Tried to equip underwear on " + self.Name + ", but " + self.Pronoun + " does not have any!", "["+ Name +"] Prisoner::NPC_UpdateUnderwear", hasNoUnderwearAtAll)
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