scriptname RPB_Prison extends RPB_Entity  

;/
@constants:
    int SERVE_TIME_YES
    float HOSTILITY_RESTORE_DELAY_HOURS
@references:
    RPB_PrisonManager PrisonManager
    RPB_API API
    RPB_Config Config
    RPB_SceneManager SceneManager
    RPB_EventManager EventManager
    RPB_PrisonMonitor Monitor
    RPB_PrisonerList Prisoners
@properties:
    int ID
    string UUID
    bool Active
    string Name
    Location PrisonLocation
    Faction PrisonFaction
    string Hold
    string City
    int GuaranteedPayableBounty
    int MaximumPayableBounty
    int MaximumPayableBountyChance
    int BountyExchange
    int BountyToSentence
    int MinimumSentence
    int MaximumSentence
    int CellSearchThoroughness
    string CellLockLevel
    int ReleaseTimeMinimumHour
    int ReleaseTimeMaximumHour
    bool AllowReleaseOnWeekends
    bool FastForward
    int DayToFastForwardFrom
    string HandleSkillLoss
    int DayToStartLosingSkillsStat
    int DayToStartLosingSkillsPerk
    int ChanceToLoseSkillsStat
    int ChanceToLoseSkillsPerk
    float RecognizedCriminalPenalty
    float KnownCriminalPenalty
    int MinimumBountyToTriggerCriminalPenalty
    bool EnableReleaseFees
    int ReleaseFeesChanceForEvent
    int MinimumBountyToOweReleaseFees
    float ReleaseFeesOfCurrentBounty
    int ReleaseFees
    int DaysGivenToPayReleaseFees
    bool EnableItemRetention
    int MinimumBountyToRetainItems
    bool AutoRedressOnRelease
    string HandleEscapeOn
    float EscapeBountyOfCurrentBounty
    int EscapeBounty
    float EscapeBountySentenceMultiplier
    int EscapeBountySentenceDays
    int EscapeBountyCondition
    int EscapeBountySentenceCondition
    int EscapeBountyFallbackBounty
    bool AccountForTimeServedOnEscape
    bool FriskUponCapturedOnEscape
    bool StripUponCapturedOnEscape
    bool EnableInfamy
    int InfamyRecognizedThreshold
    int InfamyKnownThreshold
    float InfamyGainedDailyOfCurrentBounty
    int InfamyGainedDaily
    float InfamyGainModifierRecognized
    float InfamyGainModifierKnown
    float InfamyLostDailyOfCurrentInfamy
    int InfamyLostDaily
    bool AllowFrisking
    int MinimumBountyForFrisking
    int FriskingThoroughness
    bool ConfiscateStolenItemsOnFrisk
    bool StripIfStolenItemsFoundOnFrisk
    int MinimumNumberOfStolenItemsRequiredToStripOnFrisk
    bool AllowStripping
    string HandleStrippingOn
    int MinimumBountyToStrip
    int MinimumViolentBountyToStrip
    int MinimumSentenceToStrip
    int StrippingThoroughness
    int StrippingThoroughnessModifier
    bool AllowClothing
    string HandleClothingOn
    int MaximumBountyClothing
    int MaximumViolentBountyClothing
    int MaximumSentenceClothing
    bool ClotheWhenDefeated
    string ClothingOutfit
    bool UseDefaultOutfitAsFallback
    string OutfitName
    Armor OutfitPartHead
    Armor OutfitPartBody
    Armor OutfitPartHands
    Armor OutfitPartFeet
    bool IsOutfitConditional
    int OutfitMinimumBounty
    int OutfitMaximumBounty
    Message ServeTimeMessage
    bool IsPlayerFastForwardingToRelease
    bool PrioritizeEmptyCells
    bool PrioritizeGenderCells
    bool AllowOnlyEmptyCells
    bool AllowOnlyGenderExclusiveCells
    bool AllowOnlyEmptyOrGenderCells
    Form[] JailCells
    Form[] EmptyJailCells
    Form[] OccupiedJailCells
    Form[] AvailableJailCells
    Form[] FemaleJailCells
    Form[] MaleJailCells
    bool HasInfamyRecognizedNotificationFired
    bool HasInfamyKnownNotificationFired
    string InfamyRecognizedSentenceAppliedNotification
    string InfamyKnownSentenceAppliedNotification
    int SettingsSnapshotBuilds
@functions:
    function ResetCachedHold()
    bool function ActiveByDefault()
    RPB_Prison function GetPrisonForHold(string asHold) global
    RPB_Prison function GetLastJailedPrison(Faction akCrimeFaction) global
    function SetupCells()
    function NotifyInfamyRecognizedThresholdMet(bool asNotification = false)
    function NotifyInfamyKnownThresholdMet(bool asNotification = false)
    bool function HasFemaleOnlyCells()
    bool function HasMaleOnlyCells()
    bool function ShouldActivelyMonitorPrisoner(RPB_Prisoner apPrisoner)
    RPB_Prisoner function AwaitPrisonerReference(Actor akPrisoner, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    RPB_Prisoner function GetPrisoner(Actor akPrisoner, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    RPB_Prisoner function GetPrisonerReference(Actor akPrisoner)
    RPB_Prisoner function MakePrisoner(Actor akActor, bool abDelayExecution = true)
    int function GetRandomSentence(int aiMinSentence, int aiMaxSentence)
    int function GetPrisonCapacity()
    float function GetCurrentLowestSentence()
    float function GetCurrentHighestSentence()
    Armor[] function GetDefaultOutfit()
    Form[] function GetJailCells()
    Form[] function GetEmptyJailCells()
    Form[] function GetOccupiedJailCells()
    Form[] function GetAvailableJailCells()
    Form[] function GetCellsWithFemalePrisoners(bool abOnlyFemales = false)
    Form[] function GetCellsWithMalePrisoners(bool abOnlyMales = false)
    Form[] function GetCellsWithMixedPrisoners()
    RPB_JailCell function GetCellByID(string asCellIdentifier)
    RPB_JailCell function GetGenderExclusiveCell(string asGender, bool abCanBeEmpty = true, bool abCanBeOvercrowded = false)
    RPB_JailCell function RequestCell(RPB_Prisoner apPrisoner)
    Form[] function GetEscortLocations()
    bool function IsInsideJail(Actor akActor)
    function PrepareArrival(RPB_Prisoner apPrisoner)
    Form[] function GetReleaseMarkers(string asReleaseMarkerType = "Teleport")
    Form[] function GetSearchMarkers(string asSearchType = "Frisking")
    Form[] function GetPrisonerContainers(string asPrisonerContainerType = "Belongings")
    Form[] function GetGenderExclusiveCells(string asGender, bool abAvailable = true, bool abCanBeOvercrowded = false)
    ObjectReference function GetRandomEscortLocation()
    Form function GetRandomSearchMarker(string asSearchType = "Frisking")
    Form function GetRandomReleaseMarker(string asReleaseMarkerType = "Teleport")
    Form function GetRandomPrisonerContainer(string asPrisonerContainerType = "Belongings")
    Form function GetPrisonerContainerLinkedWithOppositeType(Form akOppositeTypePrisonerContainer, string asPrisonerContainerType)
    RPB_JailCell function GetRandomJailCell(bool abPrioritizeEmptyCells = true)
    RPB_JailCell function GetRandomAvailableJailCell(bool abPrioritizeEmptyCells = true)
    RPB_JailCell function GetEmptyJailCell()
    RPB_JailCell function GetJailCellOfGender(string asSex, bool abAvailable = true, bool abCanBeOvercrowded = false)
    RPB_JailCell function GetFemaleJailCell()
    RPB_JailCell function GetMaleJailCell()
    function SetPlayerFastForwardingToRelease(bool abFastForward)
    function QueueRelease(RPB_Prisoner apPrisoner)
    function RebindPrisoner(RPB_Prisoner apPrisoner)
    bool function RegisterPrisoner(RPB_Prisoner apPrisoner)
    function UnregisterPrisoner(RPB_Prisoner apPrisoner)
    function BindAllPrisonersToCell()
    function Notify(string asMessage, bool abCondition = true)
    function SendMonitoringReschedule()
    bool function SendMonitoringRequest()
    bool function ShouldPrisonerBeInGenderExclusiveCell(RPB_Prisoner apPrisoner)
    bool function IsPrisoner(RPB_Prisoner apPrisoner)
    bool function IsActorPrisoner(Actor akActor)
    bool function HasPrisoners(RPB_JailCell akPrisonCell = none)
    bool function HasFemalePrisoners(RPB_JailCell akPrisonCell = none, bool abStrictlyFemales = false)
    bool function HasMalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyMales = false)
    bool function HasPrisonersOfGender(RPB_JailCell akPrisonCell = none, string asGender, bool abOnlySpecifiedGender = false)
    bool function HasCellMates(RPB_Prisoner apPrisoner)
    bool function HasCellMatesOfGender(RPB_Prisoner apPrisoner, string asGender)
    bool function HasFemaleCellMates(RPB_Prisoner apPrisoner)
    bool function HasMaleCellMates(RPB_Prisoner apPrisoner)
    Form[] function GetPrisonersWithSentenceLessThan(float afSentence, float afPadding = 0.0)
    Form[] function GetPrisonersReleasedNoLaterThan(float afTimeLeft)
    Form[] function GetPrisonersWithCurrentSentenceLessThan(float afSentence, float afPadding = 0.0)
    Form[] function GetPrisoners(RPB_JailCell akPrisonCell = none)
    Form[] function GetFemalePrisoners(RPB_JailCell akPrisonCell = none)
    Form[] function GetMalePrisoners(RPB_JailCell akPrisonCell = none)
    Form[] function GetCellMates(RPB_Prisoner apPrisoner)
    string function GetTimeOfArrestFormatted(RPB_Prisoner apPrisoner)
    string function GetTimeOfImprisonmentFormatted(RPB_Prisoner apPrisoner)
    string function GetTimeOfReleaseFormatted(RPB_Prisoner apPrisoner)
    string function GetTimeElapsedSinceArrest(RPB_Prisoner apPrisoner)
    string function GetTimeElapsedSinceImprisonment(RPB_Prisoner apPrisoner)
    string function GetTimeLeftOfSentenceFormatted(RPB_Prisoner apPrisoner)
    string function GetSentenceFormatted(RPB_Prisoner apPrisoner)
    string function GetCriminalPenaltySentenceFormatted(RPB_Prisoner apPrisoner)
    string function GetTimeServedFormatted(RPB_Prisoner apPrisoner)
    function SetSentence(RPB_Prisoner apPrisoner, int aiSentence = 0)
    function RestrainPrisoner(RPB_Prisoner apPrisoner, bool abRestrainInFront = false)
    function TeleportPrisonerToRelease(RPB_Prisoner apPrisoner, bool abMoveToReleaseLocation = true)
    function ReleaseInPlace(RPB_Prisoner apPrisoner)
    function CancelImprisonment(RPB_Prisoner apPrisoner, string asReason, bool abReturnBelongings = true)
    function ResumePrisonFlowWith(RPB_Prisoner apPrisoner, Actor akGuard)
    int function PendingDressCount()
    function QueueEscortToCellStallCheck(Actor akPrisoner, float afTimeoutSeconds = 8.0, bool abWatchAssist = false)
    function CancelEscortToCellStallCheck(Actor akPrisoner)
    function ResetDressCost()
    string function DressCostSummary()
    int function PendingHostilityRestoreCount()
    float function NextHostilityRestoreHours()
    bool function HasPendingHostilityRestore(Actor akActor)
    function ForgetPendingRestores(Actor akActor)
    function EscortPrisonerToRelease(RPB_Prisoner apPrisoner)
    bool function SendReleaseRequest(RPB_Prisoner apPrisoner)
    int function ReleaseDueNPCsInOrder(float afPlayerTimeLeft)
    function ReleasePrisonersWithSentenceLessThan(float afTimeLeftInSentence, bool abPassTime = true)
    function TriggerEscape(RPB_Prisoner apPrisoner)
    function SendEscortPrisonerToCellRequest(RPB_Prisoner apPrisoner)
    function SendEscortPrisonerFromCellRequest(RPB_Prisoner apPrisoner, ObjectReference akDestination)
    function AssignBelongingsContainer(RPB_Prisoner apPrisoner)
    function AssignReleaseLocation(RPB_Prisoner apPrisoner, bool abIsTeleportLocation = true)
    bool function AssignCell(RPB_Prisoner apPrisoner)
    function RemoveFromCell(RPB_Prisoner apPrisoner)
    function ClearPrisonerBounty(RPB_ActorBase apActor)
    bool function AssignPrisonerToCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    function RegisterPrisonerLastJailedStats(RPB_Prisoner apPrisoner)
    function RegisterPrisonerReleaseTimeStats(RPB_Prisoner apPrisoner)
    function RegisterPrisonerEscapeTimeStats(RPB_Prisoner apPrisoner)
    function EscortPrisonerToJail(RPB_Prisoner apPrisoner, Actor akEscort)
    function EscortPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
    function EscortPrisonerFromJail(RPB_Prisoner apPrisoner, Actor akEscort)
    function EscortPrisonerFromCell(RPB_Prisoner apPrisoner, Actor akEscort)
    function StartRestrainingPrisoner(RPB_Prisoner apPrisoner, Actor akRestrainer)
    function StartFriskingPrisoner(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    function StartStrippingPrisoner(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    function StartGivingPrisonerClothing(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    function RegisterInfamyLost(Actor akActor)
    function UpdateInfamyLost(Actor akActor)
    function ClearActorInfamyState(Actor akActor)
    bool function BindCellToPrisoner(ObjectReference akJailCell, RPB_Prisoner apPrisoner)
    bool function Global_GetPropertyOfTypeBool(int apRootObject, string asPropertyName) global
    int function Global_GetPropertyOfTypeInt(int apRootObject, string asPropertyName) global
    float function Global_GetPropertyOfTypeFloat(int apRootObject, string asPropertyName) global
    string function Global_GetPropertyOfTypeString(int apRootObject, string asPropertyName) global
    Form function Global_GetPropertyOfTypeForm(int apRootObject, string asPropertyName) global
    int[] function Global_GetPropertyOfTypeIntegerArray(int apRootObject, string asPropertyName) global
    float[] function Global_GetPropertyOfTypeFloatArray(int apRootObject, string asPropertyName) global
    string[] function Global_GetPropertyOfTypeStringArray(int apRootObject, string asPropertyName) global
    Form[] function Global_GetPropertyOfTypeFormArray(int apRootObject, string asPropertyName) global
    function ImprisonActorImmediately(Actor akActor)
    function DEBUG_ShowPrisonerSentenceInfo(RPB_Prisoner apPrisoner, bool abShort = false)
    int function GetSettingsSnapshot()
    function InvalidateSettingsSnapshot()
@events:
    event OnReferenceDeleted()
    event OnPrisonerImprisonmentFail(RPB_Prisoner apPrisoner, string reason)
    event OnPrisonerRegistered(RPB_Prisoner apPrisoner)
    event OnPrisonerUnregistered(RPB_Prisoner apPrisoner)
    event OnPrisonerReleased(RPB_Prisoner apPrisoner)
    event OnPrisonerLeave(RPB_Prisoner apPrisoner)
    event OnPrisonerEscaped(RPB_Prisoner apPrisoner)
    event OnPrisonerTeleportedToPrison(RPB_Prisoner apPrisoner)
    event OnPrisonerTeleportedToCell(RPB_Prisoner apPrisoner, bool abImprisonPrisoner)
    event OnPrisonerDying(RPB_Prisoner apPrisoner, Actor akKiller)
    event OnPrisonerDeath(RPB_Prisoner apPrisoner, Actor akKiller)
    event OnEscortPrisonerToJailBegin(RPB_ActorBase apActor, Actor akEscort)
    event OnEscortPrisonerToJailEnd(RPB_ActorBase apActor, Actor akEscort)
    event OnEscortPrisonerToCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnEscortingPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnEscortPrisonerToCellEnd(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell, Actor akEscort)
    event OnEscortPrisonerFromCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnEscortPrisonerFromCellEnd(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnPrisonerStripBegin(RPB_Prisoner apPrisoner, Actor akStripper)
    event OnPrisonerStripping(RPB_Prisoner apPrisoner, Actor akStripper, string asSceneEvent)
    event OnPrisonerStripEnd(RPB_Prisoner apPrisoner, Actor akStripper)
    event OnPrisonerClothingBegin(RPB_Prisoner apPrisoner, Actor akClothingGiver)
    event OnPrisonerClothingOngoing(RPB_Prisoner apPrisoner, Actor akClothingGiver)
    event OnPrisonerClothingStep(RPB_Prisoner apPrisoner, Actor akClothingGiver, int aiStep)
    event OnPrisonerClothingEnd(RPB_Prisoner apPrisoner, Actor akClothingGiver)
    event OnCellDoorOpen(RPB_JailCell akPrisonCell, Actor akOpener)
    event OnCellDoorClosed(RPB_JailCell akPrisonCell, Actor akCloser)
    event OnJailCellAssigned(RPB_JailCell akJailCell, RPB_Prisoner apPrisoner)
    event OnPrisonerCellAssigned(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    event OnPrisonerCellAssignFail(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    event OnPrisonerEnterCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    event OnPrisonerLeaveCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
/;

import Math
import RPB_Config
import RPB_Utility
import RPB_Memory

; ==========================================================
;                     Script References
; ==========================================================

RPB_PrisonManager __prisonManager
RPB_PrisonManager property PrisonManager
    RPB_PrisonManager function get()
        if (__prisonManager)
            return __prisonManager
        endif

        __prisonManager = RPB_API.GetPrisonManager()
        return __prisonManager
    endFunction
endProperty

RPB_API property API
    RPB_API function get()
        return PrisonManager.API
    endFunction
endProperty

RPB_Config __cachedConfig

RPB_Config property Config
    RPB_Config function get()
        if (!__cachedConfig)
            __cachedConfig = API.Config
        endif

        return __cachedConfig
    endFunction
endProperty

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
    endFunction
endProperty

RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

; ==========================================================
;                       Prison Identity
; ==========================================================

string property Name
    string function get()
        return self.TryGetString("Name")
    endFunction
endProperty

Location property PrisonLocation
    Location function get()
        return self.GetPropertyOfTypeForm("Location") as Location
    endFunction
endProperty


; Constant per Prison, and read by every Bounty/Infamy access: the StorageVars read (~4ms) is cached like Hold
Faction __cachedPrisonFaction

Faction property PrisonFaction
    Faction function get()
        if (!__cachedPrisonFaction)
            __cachedPrisonFaction = self.GetLocalPropertyOfTypeForm("Crime Faction") as Faction
        endif

        return __cachedPrisonFaction
    endFunction
endProperty

; Every Prison.X setting getter is Config.Is/Get...(Hold), so this getter runs on every MCM-backed read. Reading it
; from StorageVars builds a full path each time (~4ms), which was ~60% of a setting read; it never changes once set.
string __cachedHold

string property Hold
    string function get()
        if (__cachedHold == "")
            __cachedHold = self.GetLocalPropertyOfTypeString("Hold")
        endif

        return __cachedHold
    endFunction
endProperty

;/
    Forgets the cached Hold and Crime Faction, to be called after those local properties are (re)written.
/;
function ResetCachedHold()
    __cachedHold = ""
    __cachedPrisonFaction = none
endFunction

string property City
    string function get()
        return self.GetPropertyOfTypeString("City")
    endFunction
endProperty

; ==========================================================
;                       Prison Settings
; ==========================================================
;/
    These settings are retrieved directly through Config, which retrieves them
    from the MCM as soon as they are changed, so they are always up to date.
/;

;                           Jail
; ==========================================================

int property GuaranteedPayableBounty
    int function get()
        return Config.GetJailGuaranteedPayableBounty(Hold)
    endFunction
endProperty

int property MaximumPayableBounty
    int function get()
        return Config.GetJailMaximumPayableBounty(Hold)
    endFunction
endProperty

int property MaximumPayableBountyChance
    int function get()
        return Config.GetJailMaximumPayableChance(Hold)
    endFunction
endProperty

int property BountyExchange
    int function get()
        return Config.GetJailBountyExchange(Hold)
    endFunction
endProperty

int property BountyToSentence
    int function get()
        return Config.GetJailBountyToSentence(Hold)
    endFunction
endProperty

int property MinimumSentence
    int function get()
        return Config.GetJailMinimumSentence(Hold)
    endFunction
endProperty

int property MaximumSentence
    int function get()
        return Config.GetJailMaximumSentence(Hold)
    endFunction
endProperty

int property CellSearchThoroughness
    int function get()
        return Config.GetJailCellSearchThoroughness(Hold)
    endFunction
endProperty

string property CellLockLevel
    string function get()
        return Config.GetJailCellDoorLockLevel(Hold)
    endFunction
endProperty

int property ReleaseTimeMinimumHour
    int function get()
        return Config.GetJailReleaseTimeMinimumHour(Hold)
    endFunction
endProperty

int property ReleaseTimeMaximumHour
    int function get()
        return Config.GetJailReleaseTimeMaximumHour(Hold)
    endFunction
endProperty

bool property AllowReleaseOnWeekends
    bool function get()
        return Config.IsReleaseAllowedOnWeekends(Hold)
    endFunction
endProperty

bool property FastForward
    bool function get()
        return Config.IsJailFastForwardEnabled(Hold)
    endFunction
endProperty

int property DayToFastForwardFrom
    int function get()
        return Config.GetJailFastForwardDay(Hold)
    endFunction
endProperty

string property HandleSkillLoss
    string function get()
        return Config.GetJailHandleSkillLoss(Hold)
    endFunction
endProperty

int property DayToStartLosingSkillsStat
    int function get()
        return Config.GetJailDayToStartLosingSkillsOfType(Hold, "Stat")
    endFunction
endProperty

int property DayToStartLosingSkillsPerk
    int function get()
        return Config.GetJailDayToStartLosingSkillsOfType(Hold, "Perk")
    endFunction
endProperty

int property ChanceToLoseSkillsStat
    int function get()
        return Config.GetJailChanceToLoseSkillsDailyOfType(Hold, "Stat")
    endFunction
endProperty

int property ChanceToLoseSkillsPerk
    int function get()
        return Config.GetJailChanceToLoseSkillsDailyOfType(Hold, "Perk")
    endFunction
endProperty

float property RecognizedCriminalPenalty
    float function get()
        return Config.GetJailRecognizedCriminalPenalty(Hold)
    endFunction
endProperty

float property KnownCriminalPenalty
    float function get()
        return Config.GetJailKnownCriminalPenalty(Hold)
    endFunction
endProperty

int property MinimumBountyToTriggerCriminalPenalty
    int function get()
        return Config.GetJailBountyToTriggerCriminalPenalty(Hold)
    endFunction
endProperty

;                           Release
; ==========================================================

bool property EnableReleaseFees
    bool function get()
        return Config.IsJailReleaseFeesEnabled(Hold)
    endFunction
endProperty

int property ReleaseFeesChanceForEvent
    int function get()
        return Config.GetReleaseChanceForReleaseFeesEvent(Hold)
    endFunction
endProperty

int property MinimumBountyToOweReleaseFees
    int function get()
        return Config.GetReleaseBountyToOweFees(Hold)
    endFunction
endProperty

float property ReleaseFeesOfCurrentBounty
    float function get()
        return Config.GetReleaseReleaseFeesFromBounty(Hold)
    endFunction
endProperty

int property ReleaseFees
    int function get()
        return Config.GetReleaseReleaseFeesFlat(Hold)
    endFunction
endProperty

int property DaysGivenToPayReleaseFees
    int function get()
        return Config.GetReleaseDaysGivenToPayReleaseFees(Hold)
    endFunction
endProperty

bool property EnableItemRetention
    bool function get()
        return Config.IsItemRetentionEnabledOnRelease(Hold)
    endFunction
endProperty

int property MinimumBountyToRetainItems
    int function get()
        return Config.GetReleaseBountyToRetainItems(Hold)
    endFunction
endProperty

bool property AutoRedressOnRelease
    bool function get()
        return Config.IsAutoDressingEnabledOnRelease(Hold)
    endFunction
endProperty

;                           Escape
; ==========================================================

string property HandleEscapeOn
    string function get()
        return Config.GetEscapeHandlingCondition(Hold)
    endFunction
endProperty

float property EscapeBountyOfCurrentBounty
    float function get()
        return Config.GetEscapedBountyFromCurrentArrest(Hold)
    endFunction
endProperty

int property EscapeBounty
    int function get()
        return Config.GetEscapedBountyFlat(Hold)
    endFunction
endProperty

float property EscapeBountySentenceMultiplier
    float function get()
        return Config.GetEscapedBountySentenceMultiplier(Hold)
    endFunction
endProperty

int property EscapeBountySentenceDays
    int function get()
        return Config.GetEscapeBountySentenceDays(Hold)
    endFunction
endProperty

int property EscapeBountyCondition
    int function get()
        return Config.GetEscapeBountyCondition(Hold)
    endFunction
endProperty

int property EscapeBountySentenceCondition
    int function get()
        return Config.GetEscapeBountySentenceCondition(Hold)
    endFunction
endProperty

int property EscapeBountyFallbackBounty
    int function get()
        return Config.GetEscapeBountyFallbackBounty(Hold)
    endFunction
endProperty

bool property AccountForTimeServedOnEscape
    bool function get()
        return Config.IsTimeServedAccountedForOnEscape(Hold)
    endFunction
endProperty

bool property FriskUponCapturedOnEscape
    bool function get()
        return Config.ShouldFriskOnEscape(Hold)
    endFunction
endProperty

bool property StripUponCapturedOnEscape
    bool function get()
        return Config.ShouldStripOnEscape(Hold)
    endFunction
endProperty

;                           Infamy
; ==========================================================

bool property EnableInfamy
    bool function get()
        return Config.IsInfamyEnabled(Hold)
    endFunction
endProperty

int property InfamyRecognizedThreshold
    int function get()
        return Config.GetInfamyRecognizedThreshold(Hold)
    endFunction
endProperty

int property InfamyKnownThreshold
    int function get()
        return Config.GetInfamyKnownThreshold(Hold)
    endFunction
endProperty

float property InfamyGainedDailyOfCurrentBounty
    float function get()
        return Config.GetInfamyGainedDailyFromArrestBounty(Hold)
    endFunction
endProperty

int property InfamyGainedDaily
    int function get()
        return Config.GetInfamyGainedDaily(Hold)
    endFunction
endProperty

float property InfamyGainModifierRecognized
    float function get()
        return Config.GetInfamyGainModifier(Hold, "Recognized")
    endFunction
endProperty

float property InfamyGainModifierKnown
    float function get()
        return Config.GetInfamyGainModifier(Hold, "Known")
    endFunction
endProperty

float property InfamyLostDailyOfCurrentInfamy
    float function get()
        return Config.GetInfamyLostFromCurrentInfamy(Hold)
    endFunction
endProperty

int property InfamyLostDaily
    int function get()
        return Config.GetInfamyLost(Hold)
    endFunction
endProperty

;                          Frisking
; ==========================================================

bool property AllowFrisking
    bool function get()
        return Config.IsFriskingEnabled(Hold)
    endFunction
endProperty

int property MinimumBountyForFrisking
    int function get()
        return Config.GetFriskingBountyRequired(Hold)
    endFunction
endProperty

int property FriskingThoroughness
    int function get()
        return Config.GetFriskingThoroughness(Hold)
    endFunction
endProperty

bool property ConfiscateStolenItemsOnFrisk
    bool function get()
        return Config.IsFriskingStolenItemsConfiscated(Hold)
    endFunction
endProperty

bool property StripIfStolenItemsFoundOnFrisk
    bool function get()
        return Config.IsFriskingStripSearchWhenStolenItemsFound(Hold)
    endFunction
endProperty

int property MinimumNumberOfStolenItemsRequiredToStripOnFrisk
    int function get()
        return Config.GetFriskingStolenItemsRequiredForStripping(Hold)
    endFunction
endProperty

;                         Stripping
; ==========================================================

bool property AllowStripping
    bool function get()
        return Config.IsStrippingEnabled(Hold)
    endFunction
endProperty

string property HandleStrippingOn
    string function get()
        return Config.GetStrippingHandlingCondition(Hold)
    endFunction
endProperty

int property MinimumBountyToStrip
    int function get()
        return Config.GetStrippingMinimumBounty(Hold)
    endFunction
endProperty

int property MinimumViolentBountyToStrip
    int function get()
        return Config.GetStrippingMinimumViolentBounty(Hold)
    endFunction
endProperty

int property MinimumSentenceToStrip
    int function get()
        return Config.GetStrippingMinimumSentence(Hold)
    endFunction
endProperty

int property StrippingThoroughness
    int function get()
        return Config.GetStrippingThoroughness(Hold)
    endFunction
endProperty

int property StrippingThoroughnessModifier
    int function get()
        return Config.GetStrippingThoroughnessBountyModifier(Hold)
    endFunction
endProperty

;                        Clothing
; ==========================================================

bool property AllowClothing
    bool function get()
        return Config.IsClothingEnabled(Hold)
    endFunction
endProperty

string property HandleClothingOn
    string function get()
        return Config.GetClothingHandlingCondition(Hold)
    endFunction
endProperty

int property MaximumBountyClothing
    int function get()
        return Config.GetClothingMaximumBounty(Hold)
    endFunction
endProperty

int property MaximumViolentBountyClothing
    int function get()
        return Config.GetClothingMaximumViolentBounty(Hold)
    endFunction
endProperty

int property MaximumSentenceClothing
    int function get()
        return Config.GetClothingMaximumSentence(Hold)
    endFunction
endProperty

bool property ClotheWhenDefeated
    bool function get()
        return Config.IsClothedOnDefeat(Hold)
    endFunction
endProperty

string property ClothingOutfit
    string function get()
        return Config.GetClothingOutfitIdentifier(Hold)
    endFunction
endProperty

bool property UseDefaultOutfitAsFallback
    bool function get()
        return Config.UseDefaultOutfitAsFallback(Hold)
    endFunction
endProperty

;                          Outfit
; ==========================================================

string property OutfitName
    string function get()
        return Config.GetClothingOutfitName(Hold)
    endFunction
endProperty

Armor property OutfitPartHead
    Armor function get()
        return Config.GetOutfitPart(Hold, "Head")
    endFunction
endProperty

Armor property OutfitPartBody
    Armor function get()
        return Config.GetOutfitPart(Hold, "Body")
    endFunction
endProperty

Armor property OutfitPartHands
    Armor function get()
        return Config.GetOutfitPart(Hold, "Hands")
    endFunction
endProperty

Armor property OutfitPartFeet
    Armor function get()
        return Config.GetOutfitPart(Hold, "Feet")
    endFunction
endProperty

bool property IsOutfitConditional
    bool function get()
        return Config.IsClothingOutfitConditional(Hold)
    endFunction
endProperty

int property OutfitMinimumBounty
    int function get()
        return Config.GetClothingOutfitMinimumBounty(Hold)
    endFunction
endProperty

int property OutfitMaximumBounty
    int function get()
        return Config.GetClothingOutfitMaximumBounty(Hold)
    endFunction
endProperty

; ==========================================================

Message property ServeTimeMessage
    Message function get()
        return PrisonManager.ServeTimeMessage
    endFunction
endProperty

int property SERVE_TIME_YES = 0 autoreadonly


; ==========================================================
;                     Prison Properties
; ==========================================================

; This may have to be a property global to all Prisons in PrisonManager,
; because issues may arise if the player is fast forwarding days/months,
; and the normal update system is retained for the NPC's in the other Prisons.
bool __isPlayerFastForwardingToRelease
float __fastForwardSetAt
bool property IsPlayerFastForwardingToRelease
    bool function get()
        ; Self-healing: a fast-forward that never finished must not keep NPCs unmonitored forever
        if (__isPlayerFastForwardingToRelease && (Utility.GetCurrentRealTime() - __fastForwardSetAt) > 60.0)
            DebugError("["+ Name +"] Prison::IsPlayerFastForwardingToRelease", "The fast forward to release has been running for over a minute, treating it as stuck and clearing it.")
            __isPlayerFastForwardingToRelease = false
        endif
        return __isPlayerFastForwardingToRelease
    endFunction
endProperty

; Give priority to empty jail cells when placing a prisoner
bool property PrioritizeEmptyCells auto

; Give priority to gender exclusive cells when placing a prisoner
bool property PrioritizeGenderCells auto

; When assigning a cell to a prisoner, only allow empty ones
bool property AllowOnlyEmptyCells auto

; When assigning a cell to a prisoner, only allow gender exclusive ones
bool property AllowOnlyGenderExclusiveCells auto

; When assigning a cell to a prisoner, it must either be empty or a gender exclusive cell
bool property AllowOnlyEmptyOrGenderCells auto

RPB_PrisonMonitor property Monitor
    RPB_PrisonMonitor function get()
        return (self as ReferenceAlias) as RPB_PrisonMonitor
    endFunction
endProperty

RPB_PrisonerList __prisoners
RPB_PrisonerList property Prisoners
    RPB_PrisonerList function get()
        if (__prisoners)
            return __prisoners
        endif

        __prisoners = ((self as ReferenceAlias) as RPB_ActiveMagicEffectContainer) as RPB_PrisonerList
        return __prisoners
    endFunction
endProperty

Form[] property JailCells
    Form[] function get()
        return self.GetJailCells()
    endFunction
endProperty

Form[] property EmptyJailCells
    Form[] function get()
        return self.GetEmptyJailCells()
    endFunction
endProperty

Form[] property OccupiedJailCells
    Form[] function get()
        return self.GetOccupiedJailCells()
    endFunction
endProperty

Form[] property AvailableJailCells
    Form[] function get()
        return self.GetAvailableJailCells()
    endFunction
endProperty

Form[] property FemaleJailCells
    Form[] function get()
        return self.GetGenderExclusiveCells("Female")
    endFunction
endProperty

Form[] property MaleJailCells
    Form[] function get()
        return self.GetGenderExclusiveCells("Male")
    endFunction
endProperty

; ==========================================================

bool function ActiveByDefault() ; overrides
    return false
endFunction

event OnReferenceDeleted()
    ; Reset Prisoners list
    __prisoners = none
endEvent

; ==========================================================
;                       Infamy Messages
; ==========================================================

;/
    Properties used to determine if infamy messages have fired at least once,
    determines for both Recognized and Known thresholds
/;
bool property HasInfamyRecognizedNotificationFired
    bool function get()
        return PrisonManager.PrisonInfamyRecognizedThresholdNotification
    endFunction
endProperty

bool property HasInfamyKnownNotificationFired
    bool function get()
        return PrisonManager.PrisonInfamyKnownThresholdNotification
    endFunction
endProperty

string property InfamyRecognizedSentenceAppliedNotification
    string function get()
        return "Due to being a recognized criminal in the hold, your sentence was extended"
    endFunction
endProperty

string property InfamyKnownSentenceAppliedNotification
    string function get()
        return "Due to being a known criminal in the hold, your sentence was extended"
    endFunction
endProperty

; ==========================================================
;                      Static Functions
; ==========================================================

RPB_Prison function GetPrisonForHold(string asHold) global
    RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison(asHold)
    return prison
endFunction

;/
    Gets the prison where the player was last jailed for the specified crime faction.

    Faction @akCrimeFaction: The faction that arrested and imprisoned the player.
    
    returns: The prison where the player was last jailed as an instance of RPB_Prison.
/;
RPB_Prison function GetLastJailedPrison(Faction akCrimeFaction) global
    int prisonId = RPB_StorageVars.GetIntOnReference("Last Jailed - Prison", akCrimeFaction)
    if (prisonId)
        return RPB_API.GetPrisonManager().GetPrisonByID(prisonId)
    endif

    return none
endFunction


; ==========================================================
;                         Functions
; ==========================================================

;                  Prison - Initialization
; ==========================================================

function SetupCells()
    ; if (self.Hold != "Whiterun")
    ;     return
    ; endif

    float startBench = StartBenchmark()

    int i = 0
    while (i < JailCells.Length)
        RPB_JailCell jailCell = JailCells[i] as RPB_JailCell

        if (!jailCell.IsInitialized())
            jailCell.Initialize(self)

            ; if (jailCell.ShouldPerformScan("Beds"))
            ;     jailCell.ScanBeds()
            ; endif
            
            ; if (jailCell.ShouldPerformScan("Containers"))
            ;     jailCell.ScanContainers()
            ; endif

            ; if (jailCell.ShouldPerformScan("Props"))
            ;     jailCell.ScanMiscProps()
            ; endif
        endif

        i += 1
    endWhile

    EndBenchmark(startBench, "("+ Name +") Prison::SetupCells")
endFunction

;                   Prison - Notifications
; ==========================================================

function NotifyInfamyRecognizedThresholdMet(bool asNotification = false)
    if (__infamyRecognizedThresholdMsgSent)
        return
    endif

    __infamyRecognizedThresholdMsgSent = true

    PrisonManager.PrisonInfamyRecognizedThresholdNotification = true

    if (config.ShouldDisplayInfamyNotifications && asNotification)
        Debug.notification("You are now recognized as a criminal in " + Name)
        return
    endif

    Debug.MessageBox("You are now recognized as a criminal in " + Name)
endFunction

function NotifyInfamyKnownThresholdMet(bool asNotification = false)
    if (__infamyKnownThresholdMsgSent)
        return
    endif

    __infamyKnownThresholdMsgSent = true

    PrisonManager.PrisonInfamyKnownThresholdNotification = true

    if (config.ShouldDisplayInfamyNotifications && asNotification)
        Debug.notification("You are now a known criminal in " + Name)
        return
    endif

    Debug.MessageBox("You are now a known criminal in " + Name)
endFunction

;                      Prison - Checkers
; ==========================================================

bool function HasFemaleOnlyCells()

endFunction

bool function HasMaleOnlyCells()

endFunction

bool function ShouldActivelyMonitorPrisoner(RPB_Prisoner apPrisoner)
    ; Always actively monitor the Player, for now. (RPB_PrisonMonitor is only used for NPC's background monitoring)
    return apPrisoner.IsPlayer() || (apPrisoner.IsNPC() && !self.IsPlayerFastForwardingToRelease && !apPrisoner.IsFarFromPlayer())
endFunction

;                      Prison - Getters
; ==========================================================

;/
    Awaits a reference of RPB_Prisoner for the specified Actor.
    If the Actor is not a Prisoner yet, they will be made into one and bound to this Prison. 

    Actor   @akPrisoner: The actor to retrieve the Prisoner reference from.
    float?  @afInitialTimeBetweenTries: The delay on each try
    int?    @aiMaxTries: How many attempts retrieving the reference, in case it fails initially.
    float?  @afMaxTimeBetweenTries: The max delay on each try that is possible (Exponential Backoff).

    returns (RPB_Prisoner): The Prisoner reference for this Actor.
/;
RPB_Prisoner function AwaitPrisonerReference(Actor akPrisoner, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    ; RPB_StorageVars.SetBoolOnReference("Is Initialized", akPrisoner, true, "Actor")
    RPB_Prisoner prisonerRef = RPB_Utility.AwaitEntityReference(akPrisoner, Prisoners, self, aiMaxTries, afInitialTimeBetweenTries, afMaxTimeBetweenTries) as RPB_Prisoner
    RPB_Utility.FlowMark("AwaitPrisoner: registered")
    if (!prisonerRef)
        ; AwaitEntityReference has already logged why (not loaded / never registered); never call Initialize() on None
        return none
    endif

    return prisonerRef.Initialize()
endFunction

RPB_Prisoner function GetPrisoner(Actor akPrisoner, int aiMaxTries = 120, float afInitialTimeBetweenTries = 0.05, float afMaxTimeBetweenTries = 0.1)
    return RPB_Utility.AwaitExistingEntityReference(akPrisoner, Prisoners, self, aiMaxTries, afInitialTimeBetweenTries, afMaxTimeBetweenTries) as RPB_Prisoner
endFunction

; TODO: Delete this after replacing calls
RPB_Prisoner function GetPrisonerReference(Actor akPrisoner)
    return self.AwaitPrisonerReference(akPrisoner)
endFunction

;/
    Turns the Actor into an RPB_Prisoner and binds it to this Prison.

    Actor   @akActor: The actor to turn into a Prisoner
    bool?   @abDelayExecution: Whether to delay before obtaining a reference to the prisoner.
/;
; TODO: Delete this after replacing calls
RPB_Prisoner function MakePrisoner(Actor akActor, bool abDelayExecution = true)
    return self.AwaitPrisonerReference(akActor)
endFunction

int function GetRandomSentence(int aiMinSentence, int aiMaxSentence)
    return Utility.RandomInt( \
        Min(aiMinSentence, self.MinimumSentence) as int, \
        Min(aiMaxSentence, self.MaximumSentence) as int \
    )
endFunction

int function GetPrisonCapacity()
    FunctionNotImplemented("Prison::GetPrisonCapacity")
endFunction

float function GetCurrentLowestSentence()
    ; Days left of the NPC prisoner closest to release (running effects only), -1 when there is none.
    ; The Player, undetermined sentences and away prisoners (no effect) do not count, and none of that is an error.
    float currentLowestSentence = -1.0

    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner prisoner = Prisoners.AtIndex(i)
        if (prisoner && !prisoner.IsPlayer() && !prisoner.IsUndeterminedSentence)
            float prisonerCurrentTimeLeftInSentence = prisoner.TimeLeftInSentence
            if (currentLowestSentence == -1.0 || currentLowestSentence > prisonerCurrentTimeLeftInSentence)
                currentLowestSentence = prisonerCurrentTimeLeftInSentence
            endif
        endif
        i += 1
    endWhile

    return currentLowestSentence
endFunction

float function GetCurrentHighestSentence()
    FunctionNotImplemented("Prison::GetCurrentHighestSentence")
endFunction

Armor[] function GetDefaultOutfit()
    Armor[] outfitPieces = new Armor[4]
    Outfit[] prisonerDefaultOutfits = new Outfit[4]
    prisonerDefaultOutfits[0] = RPB_GetOutfit("Default")
    prisonerDefaultOutfits[1] = RPB_GetOutfit("Default 2")
    prisonerDefaultOutfits[2] = RPB_GetOutfit("Default no Shoes")
    prisonerDefaultOutfits[3] = RPB_GetOutfit("Default 2 no Shoes")

    Outfit randomPrisonerOutfit = prisonerDefaultOutfits[Utility.RandomInt(0, 3)]
    int outfitPartCount = randomPrisonerOutfit.GetNumParts()

    int i = 0
    while (i < outfitPieces.Length)
        Armor outfitPiece = randomPrisonerOutfit.GetNthPart(i) as Armor
        if (outfitPiece)
            outfitPieces[i] = outfitPiece
        endif
        i += 1
    endWhile

    return outfitPieces
endFunction

;/
    Retrieves the jail cells configured for this Prison.
    Each element is able to be cast to a RPB_JailCell.

    returns (Form[]): The jail cells for this Prison.
/;
Form[] __jailCells
Form[] function GetJailCells()
    if (__jailCells)
        ; Debug("("+ Name +") Prison::GetJailCells", __jailCells)
        return __jailCells
    endif

    Form[] objectData = RPB_Data.QueryFormArray(self.Children("Cells"), "*", "{ 'active': true }")
    __jailCells = objectData

    ; Debug("("+ Name +") Prison::GetJailCells", __jailCells)
    return __jailCells
endFunction

;/
    Retrieves the jail cells that are currently empty.
    Each element is able to be cast to a RPB_JailCell.

    returns (Form[]); The empty jail cells for this Prison.
/;
Form[] function GetEmptyJailCells()
    Form[] cells = self.GetJailCells()
    int emptyCellsArray = JArray.object()

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCellRef = cells[i] as RPB_JailCell

        if (jailCellRef && jailCellRef.IsEmpty)
            ; Debug("Prison::GetEmptyJailCells", "Cell: " + jailCellRef + ", IsEmpty: " + jailCellRef.IsEmpty + ", Gender: " + jailCellRef.IsGenderExclusive)
            JArray.addForm(emptyCellsArray, jailCellRef)
        endif
        i += 1
    endWhile

    if (JValue.count(emptyCellsArray) <= 0)
        return none
    endif

    return JArray.asFormArray(emptyCellsArray)
endFunction

Form[] function GetOccupiedJailCells()
    Form[] cells = self.GetJailCells()

    int cellsArray = FastArray("<Form>")
    
    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCellRef = cells[i] as RPB_JailCell

        if (jailCellRef && !jailCellRef.IsEmpty)
            FastArray_AddForm(cellsArray, jailCellRef)
        endif
        i += 1
    endWhile

    if (FastArray_Size(cellsArray) <= 0)
        return none
    endif

    return FastArray_ToFormArray(cellsArray)
endFunction

;/
    Retrieves the jail cells that are currently available (haven't reached the maximum amount of prisoners).
    Each element is able to be cast to a RPB_JailCell.

    returns (Form[]): The jail cells that are currently available to take more prisoners.
/;
Form[] function GetAvailableJailCells()
    Form[] cells = self.GetJailCells()
    int availableCellsArray = FastArray("<Form>")

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCellRef = cells[i] as RPB_JailCell

        if (jailCellRef && jailCellRef.IsAvailable)
            ; Debug("Prison::GetAvailableJailCells", "Cell: " + jailCellRef + ", IsAvailable: " + jailCellRef.IsAvailable + ", Gender: " + jailCellRef.IsGenderExclusive)
            FastArray_AddForm(availableCellsArray, jailCellRef)
        endif
        i += 1
    endWhile

    if (FastArray_Size(availableCellsArray) <= 0)
        return none
    endif

    return FastArray_ToFormArray(availableCellsArray)
endFunction

;/
    Retrieves the jail cells that have female prisoners.
    Each element is able to be cast to a RPB_JailCell.

    bool? @abOnlyFemales: Only return cells strictly with female prisoners.

    returns (Form[]): The jail cells that have female prisoners.
/;
Form[] function GetCellsWithFemalePrisoners(bool abOnlyFemales = false)
    Form[] cells = self.OccupiedJailCells

    if (!cells)
        return none
    endif

    int returnedCells = FastArray("<Form>")

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell

        if (jailCell.HasFemales(abOnlyFemales))
            FastArray_AddForm(returnedCells, jailCell)
        endif

        i += 1
    endWhile

    if (FastArray_Size(returnedCells) <= 0)
        return none
    endif

    return FastArray_ToFormArray(returnedCells)
endFunction

;/
    Retrieves the jail cells that have male prisoners.
    Each element is able to be cast to a RPB_JailCell.

    bool? @abOnlyMales: Only return cells strictly with male prisoners.

    returns (Form[]): The jail cells that have male prisoners.
/;
Form[] function GetCellsWithMalePrisoners(bool abOnlyMales = false)
    Form[] cells = self.OccupiedJailCells

    if (!cells)
        return none
    endif

    int returnedCells = FastArray("<Form>")

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell

        if (jailCell.HasMales(abOnlyMales))
            FastArray_AddForm(returnedCells, jailCell)
        endif

        i += 1
    endWhile

    if (FastArray_Size(returnedCells) <= 0)
        return none
    endif

    return FastArray_ToFormArray(returnedCells)
endFunction

;/
    Retrieves the jail cells that have both male and female prisoners.
    Each element is able to be cast to a RPB_JailCell.

    returns (Form[]): The jail cells that have both male and female prisoners.
/;
Form[] function GetCellsWithMixedPrisoners()
    Form[] cells = self.OccupiedJailCells

    if (!cells)
        return none
    endif

    int returnedCells = FastArray("<Form>")

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCell = cells[i] as RPB_JailCell

        if (jailCell.HasMales() && jailCell.HasFemales())
            FastArray_AddForm(returnedCells, jailCell)
        endif

        i += 1
    endWhile

    if (FastArray_Size(returnedCells) <= 0)
        return none
    endif

    return FastArray_ToFormArray(returnedCells)
endFunction

RPB_JailCell function GetCellByID(string asCellIdentifier)
    ; return self.FindPropertyOfTypeForm("Cells//*", 
    ;     "[active: true]," + \ 
    ;     "[id: "+ asCellIdentifier +"]" \ 
    ; )
    return RPB_Data.Jail_GetJailCellByID(self.Root, asCellIdentifier)
endFunction

;/
    Returns the gender exclusive cell for the specified gender.
    Optionally, if @abCanBeEmpty is true, returns an empty cell if there is no gender exclusive cell for the specified gender.
    Optionally, if @abCanBeOvercrowded is true, returns a cell that is overcrowdable if there is no available cell.

    string @asGender: The gender to get the gender exclusive cell for.
    bool? @abCanBeEmpty: If true, returns an empty cell if there is no gender exclusive cell for the specified gender.
    bool? @abCanBeOvercrowded: If true, returns a cell that is overcrowdable if there is no gender exclusive cell for the specified gender.

    returns (RPB_JailCell): The gender exclusive cell for the specified gender.
/;
RPB_JailCell function GetGenderExclusiveCell(string asGender, bool abCanBeEmpty = true, bool abCanBeOvercrowded = false)
    if (asGender != "Male" && asGender != "Female")
        return none
    endif

    RPB_JailCell returnedCell = self.GetJailCellOfGender(asGender, true, abCanBeOvercrowded)

    if (abCanBeEmpty && returnedCell == none)
        returnedCell = self.GetEmptyJailCell()
    endif

    return returnedCell
endFunction

;/
    Requests a cell for the specified prisoner.

    RPB_Prisoner @apPrisoner: The prisoner requesting a cell.

    returns (RPB_JailCell): The cell that the prisoner was assigned to.
/;
RPB_JailCell function RequestCell(RPB_Prisoner apPrisoner)
    ;/
        First, attempt to get empty cell for the prisoner, if that fails (there are no empty cells),
        get a gender exclusive one to the prisoner's gender (even if they are not stripped),
        if that fails, get a random cell with any gender (as long as the prisoner is not marked to be in a gender exclusive cell),
        otherwise get any cell that is overcrowdable (again, stripped prisoners cant be with the opposite gender)
    /;

    RPB_JailCell returnedCell = none
    bool prisonerMustBeInGenderExclusiveCell = self.ShouldPrisonerBeInGenderExclusiveCell(apPrisoner)
    
    if (self.PrioritizeEmptyCells)
        returnedCell = self.GetEmptyJailCell()
        DebugWithArgs("["+ Name +"] [Priority: Empty Cell] Prison::RequestCell", apPrisoner.Name, "prisonerMustBeInGenderExclusiveCell: " + prisonerMustBeInGenderExclusiveCell + ", returnedCell: " + returnedCell)

    elseif (self.PrioritizeGenderCells)
        if (prisonerMustBeInGenderExclusiveCell)
            returnedCell = self.GetGenderExclusiveCell(apPrisoner.Gender, true)

            if (returnedCell == none) ; could not find a gender exclusive cell that was not overcrowded or an empty one
                returnedCell = self.GetGenderExclusiveCell(apPrisoner.Gender, false, true) ; attempt to get one that is overcrowded
            endif
            DebugWithArgs("["+ Name +"] [Priority: Gender Exclusive Cell] Prison::RequestCell", apPrisoner.Name, "prisonerMustBeInGenderExclusiveCell: " + prisonerMustBeInGenderExclusiveCell + ", returnedCell: " + returnedCell)
        endif
    endif

    ; Priority failed, or no priority
    if (returnedCell == none)
        returnedCell = self.GetEmptyJailCell()
    endif

    if (returnedCell == none)
        DebugWithArgs("["+ Name +"] Prison::RequestCell", apPrisoner.Name, "prisonerMustBeInGenderExclusiveCell: " + prisonerMustBeInGenderExclusiveCell)

        if (prisonerMustBeInGenderExclusiveCell)
            returnedCell = self.GetGenderExclusiveCell(apPrisoner.Gender, abCanBeEmpty = true)

            if (returnedCell == none) ; could not find a gender exclusive cell that was not overcrowded or an empty one
                returnedCell = self.GetGenderExclusiveCell(apPrisoner.Gender, abCanBeEmpty = false, abCanBeOvercrowded = true) ; attempt to get one that is overcrowded
            endif
            DebugWithArgs("["+ Name +"] Prison::RequestCell", apPrisoner.Name, "prisonerMustBeInGenderExclusiveCell: " + prisonerMustBeInGenderExclusiveCell + ", returnedCell: " + returnedCell)
        endif
    endif

    if (returnedCell == none)
        returnedCell = self.GetRandomAvailableJailCell()

        ; A full prison has no available cell: returnedCell is none here (a None dereference raised script errors per overflow arrest)
        if (returnedCell && (returnedCell.IsGenderExclusive || prisonerMustBeInGenderExclusiveCell))
            returnedCell = none
        endif
    endif

    return returnedCell
endFunction


Form[] function GetEscortLocations()
    return self.GetPropertyOfTypeFormArray("Markers//Jail//Escort")
endFunction

; @akActor is inside this prison's jail: the cell its jail cells stand in
bool function IsInsideJail(Actor akActor)
    Cell here = akActor.GetParentCell()
    Form[] cellsOfJail = self.JailCells
    if (!here || !cellsOfJail || cellsOfJail.Length == 0)
        return false
    endif
    ObjectReference jailCell = cellsOfJail[0] as ObjectReference
    return jailCell && jailCell.GetParentCell() == here
endFunction

; The arrival's setup (where the prisoner is released to, their belongings chest, their cell): at the escort to jail's
; end, or when the guard dies inside the jail before it (RPB_Captor.OnDeath)
function PrepareArrival(RPB_Prisoner apPrisoner)
    self.AssignReleaseLocation(apPrisoner)    ; Set the teleport release location for this prisoner

    if (!apPrisoner.PrisonerBelongingsContainer)
        self.AssignBelongingsContainer(apPrisoner) ; Set the container of where the prisoner's items will be confiscated to
    endif

    if (!apPrisoner.JailCell)
        self.AssignCell(apPrisoner) ; Assign a prison cell to this prisoner
    endif
endFunction

Form[] function GetReleaseMarkers(string asReleaseMarkerType = "Teleport")
    if (asReleaseMarkerType != "Teleport" && asReleaseMarkerType != "Escort")
        Error("["+ Name +"] The release marker type specified ("+ asReleaseMarkerType +") is invalid!")
        DebugError("["+ Name +"] Prison::GetReleaseMarkers", "The release marker type specified ("+ asReleaseMarkerType +") is invalid!")
        return none
    endif

    return self.GetPropertyOfTypeFormArray("Markers//Release//" + asReleaseMarkerType)
endFunction

Form[] function GetSearchMarkers(string asSearchType = "Frisking")
    if (asSearchType != "Frisking" && asSearchType != "Stripping")
        Error("["+ Name +"] The search marker type specified ("+ asSearchType +") is invalid!")
        DebugError("["+ Name +"] Prison::GetSearchMarkers", "The search marker type specified ("+ asSearchType +") is invalid!")
        return none
    endif

    return self.GetPropertyOfTypeFormArray("Markers//Search//" + asSearchType)
endFunction

Form[] function GetPrisonerContainers(string asPrisonerContainerType = "Belongings")
    if (asPrisonerContainerType != "Belongings" && asPrisonerContainerType != "Evidence")
        Error("["+ Name +"] The prisoner container type specified ("+ asPrisonerContainerType +") is invalid!")
        DebugError("["+ Name +"] Prison::GetPrisonerContainers", "The prisoner container type specified ("+ asPrisonerContainerType +") is invalid!")
        return none
    endif

    return self.GetPropertyOfTypeFormArray("Prisoner Containers//" + asPrisonerContainerType)
endFunction

;/
    Gets all the jail cells in this prison that match the gender passed in.

    string  @asGender: The desired gender for the exclusivity of the jail cell.
    bool    @abAvailable: Whether to only include available cells.
    bool    @abCanBeOvercrowded: Whether to include cells that can be overcrowded.

    For a jail cell to be of a specific sex, it must have at least one prisoner of that sex,
    which means these jail cells are never empty.
/;
Form[] function GetGenderExclusiveCells(string asGender, bool abAvailable = true, bool abCanBeOvercrowded = false)
    Form[] cells
    
    if (abAvailable)
        cells = self.AvailableJailCells
    else
        cells = self.JailCells
    endif

    int genderCellsArray = JArray.object()

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCellRef = cells[i] as RPB_JailCell
        bool isGenderExclusive = (asGender == "Male" && jailCellRef.IsMaleOnly) || (asGender == "Female" && jailCellRef.IsFemaleOnly)
        ; Debug("["+ Name +"] ["+ jailCellRef.ID +"] Prison::GetGenderExclusiveCells", "isGenderExclusive: " + isGenderExclusive + ", abCanBeOvercrowded: " + abCanBeOvercrowded + ", jailCellRef.IsOvercrowded: " + jailCellRef.IsOvercrowded + ", (!abCanBeOvercrowded && !jailCellRef.IsOvercrowded) || abCanBeOvercrowded: " + ((!abCanBeOvercrowded && !jailCellRef.IsOvercrowded) || abCanBeOvercrowded))

        ; abCanBeOvercrowded includes the cells that ALLOW overcrowding, it used to include every cell (full ones too)
        if (jailCellRef && (!jailCellRef.IsFull || (abCanBeOvercrowded && jailCellRef.AllowOvercrowding)))
            if (isGenderExclusive)
                JArray.addForm(genderCellsArray, jailCellRef)
            endif
        endif
        i += 1
    endWhile

    if (JValue.count(genderCellsArray) <= 0)
        return none
    endif

    return JArray.asFormArray(genderCellsArray)
endFunction

ObjectReference function GetRandomEscortLocation()
    Form[] escortLocations = self.GetEscortLocations()
    if (!escortLocations)
        return none
    endif

    return escortLocations[Utility.RandomInt(0, escortLocations.Length - 1)] as ObjectReference
endFunction

Form function GetRandomSearchMarker(string asSearchType = "Frisking")
    Form[] markers = self.GetSearchMarkers(asSearchType)

    if (!markers)
        return none
    endif

    return markers[Utility.RandomInt(0, markers.Length - 1)]
endFunction

Form function GetRandomReleaseMarker(string asReleaseMarkerType = "Teleport")
    Form[] allReleaseMarkersOfType = self.GetReleaseMarkers(asReleaseMarkerType)

    if (!allReleaseMarkersOfType)
        return none
    endif

    return allReleaseMarkersOfType[Utility.RandomInt(0, allReleaseMarkersOfType.Length - 1)]
endFunction

Form function GetRandomPrisonerContainer(string asPrisonerContainerType = "Belongings")
    Form[] allPrisonerContainers = self.GetPrisonerContainers(asPrisonerContainerType)

    if (!allPrisonerContainers)
        return none
    endif

    return allPrisonerContainers[Utility.RandomInt(0, allPrisonerContainers.Length - 1)]
endFunction

;/
    Retrieves a prisoner container linked with its opposite type counterpart.
    (e.g: The first container of type Belongings will be linked to the first container of type Evidence,
    which means that this function will always return the same container index for the opposite type.)

    This function is useful if one wants to make a relationship between containers, for example make them close to eachother,
    and when getting a random container of type Belongings to store the prisoner's items, the linked Evidence container will be used to store
    their evidence/stolen items.

    Form    @akOppositeTypePrisonerContainer: The opposite type of prisoner container to obtain the link from.
    string  @asPrisonerContainerType: The type of prisoner container to obtain.

    returns (Form): The prisoner container of the specified type with the link to its opposite counterpart.
/;
Form function GetPrisonerContainerLinkedWithOppositeType(Form akOppositeTypePrisonerContainer, string asPrisonerContainerType)
    if (asPrisonerContainerType != "Belongings" && asPrisonerContainerType != "Evidence")
        return none
    endif

    ; int prisonerContainersObj = self.GetDataObject("Prisoner Containers") ; JMap&
    int prisonerContainersObj = self.Children("Prisoner Containers") ; JMap&

    ; Get the opposite type of prisoner container
    string oppositeContainerType = string_if (asPrisonerContainerType == "Belongings", "Evidence", "Belongings")

    if (asPrisonerContainerType == oppositeContainerType) ; Invalid, must not specify the same container type
        return none
    endif

    int oppositeContainersObj   = JMap.getObj(prisonerContainersObj, oppositeContainerType)     ; JArray& (Form[])
    int containersObj           = JMap.getObj(prisonerContainersObj, asPrisonerContainerType)   ; JArray& (Form[])

    int oppositeContainersSize  = JValue.count(oppositeContainersObj)
    int containersSize          = JValue.count(containersObj)

    ; Either one or both container types do not contain any containers, can't proceed
    if (oppositeContainersSize == 0 || containersSize == 0)
        return none
    endif

    int i = 0
    while (i < oppositeContainersSize)
        ; if (i > containersSize)
        ;     ; Opposite container is at an index greater than what their possible link counterpart could be. can't proceed
        ;     return none
        ; endif

        Form currentContainer = JArray.getForm(oppositeContainersObj, i)
        if (currentContainer == akOppositeTypePrisonerContainer)
            ; Found the linked counterpart container
            return JArray.getForm(containersObj, i)
        endif
        i += 1
    endWhile

    return none
endFunction

RPB_JailCell function GetRandomJailCell(bool abPrioritizeEmptyCells = true)
    Form[] interiorMarkers = self.JailCells

    if (!interiorMarkers)
        return none
    endif

    return interiorMarkers[Utility.RandomInt(0, interiorMarkers.Length - 1)] as RPB_JailCell
endFunction

RPB_JailCell function GetRandomAvailableJailCell(bool abPrioritizeEmptyCells = true)
    Form[] interiorMarkers = self.AvailableJailCells

    if (!interiorMarkers)
        return none
    endif

    return interiorMarkers[Utility.RandomInt(0, interiorMarkers.Length - 1)] as RPB_JailCell
endFunction

RPB_JailCell function GetEmptyJailCell()
    Form[] emptyCells = self.EmptyJailCells

    if (!emptyCells)
        return none
    endif

    return emptyCells[Utility.RandomInt(0, emptyCells.Length - 1)] as RPB_JailCell
endFunction

;/
    bool    @abAvailable: Whether to only include available cells
    bool    @abCanBeOvercrowded: Whether to include cells that can be overcrowded
/;
RPB_JailCell function GetJailCellOfGender(string asSex, bool abAvailable = true, bool abCanBeOvercrowded = false)
    Form[] genderCells = self.GetGenderExclusiveCells(asSex, abAvailable, abCanBeOvercrowded)

    if (!genderCells)
        return none
    endif

    RPB_JailCell genderCell = genderCells[Utility.RandomInt(0, genderCells.Length - 1)] as RPB_JailCell

    return genderCell
endFunction

RPB_JailCell function GetFemaleJailCell()
    return self.GetJailCellOfGender("Female")
endFunction

RPB_JailCell function GetMaleJailCell()
    return self.GetJailCellOfGender("Male")
endFunction

;                      Prison - Setters
; ==========================================================

function SetPlayerFastForwardingToRelease(bool abFastForward)
    __isPlayerFastForwardingToRelease = abFastForward
    __fastForwardSetAt = Utility.GetCurrentRealTime()
endFunction

; Hands a due NPC prisoner to the monitor's ordered release queue (asynchronous: never blocks the caller)
function QueueRelease(RPB_Prisoner apPrisoner)
    Monitor.QueueRelease(apPrisoner)
endFunction

;                      Prison - Mutators
; ==========================================================

;/
    Binds the actor to an instance of RPB_Prisoner,
    giving us the prisoner state of the Actor bound to this reference.

    Used when this Actor is a Prisoner, lasts until Release, Escape,
    or until Prisoner::Destroy() is called.

    This function is used inside RPB_Prisoner, since there is no other way to obtain
    a reference to the script as of now.

    RPB_Prisoner    @akPrisonerRef: The Prisoner reference to bind to the Actor.
/;
;/
    A prisoner that is already registered got a NEW effect instance (its actor unloaded and loaded again): make the list
    point at the live one, without firing the registration events again.
/;
function RebindPrisoner(RPB_Prisoner apPrisoner)
    Prisoners.Add(apPrisoner)
    ; Guarded: Crumb() returns early when crumbs are off, but its message (and the native inside it) is built before the call
    if (RPB_Utility.IsCrumbsEnabled())
        RPB_Utility.Crumb(apPrisoner.GetActor(), "Prison.RebindPrisoner: list holds this instance: " + (Prisoners.AtKey(apPrisoner.GetActor()) == apPrisoner))
    endif
endFunction

bool function RegisterPrisoner(RPB_Prisoner apPrisoner)
    if (self.IsPrisoner(apPrisoner))
        RPB_Utility.Crumb(apPrisoner.GetActor(), "Prison.RegisterPrisoner: already a prisoner, returned false")
        return false
    endif
    
    Prisoners.Add(apPrisoner)
    ; Guarded: Crumb() returns early when crumbs are off, but its message (and the native inside it) is built before the call
    if (RPB_Utility.IsCrumbsEnabled())
        RPB_Utility.Crumb(apPrisoner.GetActor(), "Prison.RegisterPrisoner: Prisoners.Add done (list holds this instance: " + (Prisoners.AtKey(apPrisoner.GetActor()) == apPrisoner) + ")")
    endif
    self.OnPrisonerRegistered(apPrisoner)
    RPB_Utility.FlowMark("RegisterPrisoner: OnPrisonerRegistered")
    return Prisoners.Exists(apPrisoner)
endFunction

;/
    Removes the Actor bound to @akPrisonerRef from its currently bound instance of RPB_Prisoner.

    Used when this Actor is a Prisoner.

    RPB_Prisoner   @apPrisoner: The prisoner to be removed from prison.
/;
function UnregisterPrisoner(RPB_Prisoner apPrisoner)
    if (apPrisoner)
        Prisoners.Remove(apPrisoner)
        self.OnPrisonerUnregistered(apPrisoner)
    endif
endFunction

function BindAllPrisonersToCell()
    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner prisoner = Prisoners.AtIndex(i)
        prisoner.NPC_BindToCell()
        i += 1
    endWhile
endFunction

function Notify(string asMessage, bool abCondition = true)
    Config.NotifyJail(asMessage, abCondition)
endFunction

function SendMonitoringReschedule()
    if (Monitor.GetState() != "Inactive")
        Monitor.Reschedule()
    endif
endFunction

bool function SendMonitoringRequest()
    Monitor.SendRequest()
endFunction


;                     Prisoner - Checkers
; ==========================================================

bool function ShouldPrisonerBeInGenderExclusiveCell(RPB_Prisoner apPrisoner)
    bool strippedNaked      = apPrisoner.WillBeStrippedNaked        || apPrisoner.IsStrippedNaked
    bool strippedUnderwear  = apPrisoner.WillBeStrippedToUnderwear  || apPrisoner.IsStrippedToUnderwear

    return strippedNaked || strippedUnderwear
endFunction

bool function IsPrisoner(RPB_Prisoner apPrisoner)
    return Prisoners.Exists(apPrisoner)
endFunction

bool function IsActorPrisoner(Actor akActor)
    return Prisoners.AtKey(akActor) != none
endFunction

;/
    Checks if there are any Prisoners in the Prison.
    If a jail cell is passed in, then only check that cell for Prisoners.
    
    RPB_JailCell?    @akPrisonCell: The Jail Cell to check for Prisoners.
    
    returns (bool): True if there are prisoners in the Prison, further checking from their cell if one is passed in.
/;
bool function HasPrisoners(RPB_JailCell akPrisonCell = none)
    if (akPrisonCell)
        return akPrisonCell.HasPrisoners
    endif

    return Prisoners.Count > 0
endFunction

;/
    Checks if there are any Prisoners in the Prison who are female.
    If a jail cell is passed in, then only check that cell for females.
    In case that @abStrictlyFemales is true, checks if all of the Prisoners are Females.

    RPB_JailCell?    @akPrisonCell: The Jail Cell to check for female prisoners.
    bool             @abStrictlyFemales: Checks if all of the Prisoners are Female.
    
    returns (bool): True if there are prisoners in the Prison who are female,
        further checking from their cell if one is passed in.
/;
bool function HasFemalePrisoners(RPB_JailCell akPrisonCell = none, bool abStrictlyFemales = false)
    if (akPrisonCell)
        return akPrisonCell.HasFemales(abStrictlyFemales)
    endif

    return RPB_Utility.HasFemalesInList(Prisoners.GetActors(), abStrictlyFemales)
endFunction

;/
    Checks if there are any Prisoners in the Prison who are male.
    If a jail cell is passed in, then only check that cell for Males.
    In case that @abStrictlyMales is true, checks if all of the Prisoners are Males.

    RPB_JailCell?    @akPrisonCell: The Jail Cell to check for male prisoners.
    bool             @abStrictlyMales: Checks if all of the Prisoners are Male.
    
    returns (bool): True if there are prisoners in the Prison who are male,
        further checking from their cell if one is passed in.
/;
bool function HasMalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyMales = false)
    if (akPrisonCell)
        return akPrisonCell.HasMales(abOnlyMales)
    endif

    return RPB_Utility.HasMalesInList(Prisoners.GetActors(), abOnlyMales)
endFunction

;/
    Checks if there are any Prisoners in the Prison who are of the specified gender.
    If a jail cell is passed in, then only check that cell for Prisoners.
    In case that @abOnlySpecifiedGender is true, checks if all of the Prisoners are of the specified gender.

    RPB_JailCell?    @akPrisonCell: The Jail Cell to check for Prisoners.
    string           @asGender: The gender to check for.
    bool?            @abOnlySpecifiedGender: Checks if all of the Prisoners are of the specified gender.
    
    returns (bool): True if there are prisoners in the Prison who are of the specified gender,
        further checking from their cell if one is passed in.
/;
bool function HasPrisonersOfGender(RPB_JailCell akPrisonCell = none, string asGender, bool abOnlySpecifiedGender = false)
    if (akPrisonCell)
        return akPrisonCell.HasPrisonersOfGender(asGender, abOnlySpecifiedGender)
    endif

    return RPB_Utility.HasActorsOfGenderInList(Prisoners.GetActors(), asGender, abOnlySpecifiedGender)
endFunction

; Should probably be in RPB_Prisoner
bool function HasCellMates(RPB_Prisoner apPrisoner)
    RPB_JailCell jailCell = apPrisoner.JailCell

    if (jailCell == none)
        return false
    endif

    return jailCell.PrisonerCount > 1
endFunction

; Should probably be in RPB_Prisoner
bool function HasCellMatesOfGender(RPB_Prisoner apPrisoner, string asGender)
    RPB_JailCell jailCell = apPrisoner.JailCell

    if (jailCell == none)
        return false
    endif

    ; TODO: Implementation
endFunction

; Should probably be in RPB_Prisoner
bool function HasFemaleCellMates(RPB_Prisoner apPrisoner)
    return HasCellMatesOfGender(apPrisoner, "Female")
endFunction

; Should probably be in RPB_Prisoner
bool function HasMaleCellMates(RPB_Prisoner apPrisoner)
    return HasCellMatesOfGender(apPrisoner, "Male")
endFunction


;                     Prisoner - Getters
; ==========================================================

;/
    Returns a list of all prisoners with a base Sentence less than @afSentence, with a padding of @afPadding.

    float  @afSentence: The sentence to compare against.
    float  @afPadding: The padding to remove from the sentence.

    returns (Form[]): A list of all prisoners with a base Sentence less than the specified sentence.
        Each element is able to be cast to a RPB_Prisoner.
/;
Form[] function GetPrisonersWithSentenceLessThan(float afSentence, float afPadding = 0.0)
    int prisonersArray = FastArray("<Form>")

    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner prisoner = Prisoners.AtIndex(i)

        if (prisoner.Sentence < (afSentence - afPadding))
            FastArray_AddForm(prisonersArray, prisoner.GetActor())
        endif

        i += 1
    endWhile

    return FastArray_ToFormArray(prisonersArray)
endFunction

;/
    Returns a list of all prisoners with the same or less time left in their sentence than @afTimeLeft (no padding),
    i.e. everyone that is released no later than that. The player's own entry is included when it matches.

    returns (Form[]): The prisoners' actors.
/;
Form[] function GetPrisonersReleasedNoLaterThan(float afTimeLeft)
    int prisonersArray = FastArray("<Form>")

    ; The actors from the list's index (no call into anyone), a prisoner RPB found frozen left out before any call into
    ; him: the time skip hung on one, and no one after him was released (test 179). He's released after the next load
    Form[] actors = Prisoners.GetActorsNoCall()
    int frozenMap = RPB_Utility.FrozenGuardsForScan()
    int i = 0
    while (i < actors.Length)
        Actor candidate = actors[i] as Actor
        if (frozenMap && RPB_Utility.IsListedFrozen(frozenMap, candidate))
            RPB_Utility.LogWarn(candidate + " is frozen: left out of the time skip's releases until the next load", "["+ Name +"] Prison::GetPrisonersReleasedNoLaterThan")
            RPB_Utility.NoteFrozenAction(candidate, "Left out of the time skip's releases: released after the next load")
        else
            RPB_Prisoner prisoner = Prisoners.AtKey(candidate)
            if (prisoner && prisoner.TimeLeftInSentence <= afTimeLeft)
                FastArray_AddForm(prisonersArray, candidate)
            endif
        endif

        i += 1
    endWhile

    return FastArray_ToFormArray(prisonersArray)
endFunction

;/
    Returns a list of all prisoners with a Current Sentence less than @afSentence, with a padding of @afPadding.

    float  @afSentence: The sentence to compare against.
    float  @afPadding: The padding to remove from the sentence.

    returns (Form[]): A list of all prisoners with a Current Sentence less than the specified sentence.
/;
Form[] function GetPrisonersWithCurrentSentenceLessThan(float afSentence, float afPadding = 0.0)
    int prisonersArray = FastArray("<Form>")

    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner prisoner = Prisoners.AtIndex(i)

        if (prisoner.TimeLeftInSentence < (afSentence - afPadding))
            FastArray_AddForm(prisonersArray, prisoner.GetActor())
        endif

        i += 1
    endWhile

    return FastArray_ToFormArray(prisonersArray)
endFunction

;/
    Returns a list of all prisoners.
    If a jail cell is passed in, then only return the prisoners from that cell.

    RPB_JailCell?    @akPrisonCell: The Jail Cell to check for Prisoners.

    returns (Form[]): A list of all prisoners in the Prison.
/;
Form[] function GetPrisoners(RPB_JailCell akPrisonCell = none)
    if (akPrisonCell)
        return akPrisonCell.Prisoners
    endif

    return Prisoners.GetActors()
endFunction

;/
    Returns a list of all female prisoners.
    If a jail cell is passed in, then only return the female prisoners from that cell.

    RPB_JailCell?    @akPrisonCell: The Jail Cell to check for Prisoners.

    returns (Form[]): A list of all female prisoners in the Prison.
/;
Form[] function GetFemalePrisoners(RPB_JailCell akPrisonCell = none)
    if (akPrisonCell)
        return akPrisonCell.GetFemalePrisoners()
    endif

    return RPB_Utility.GetFemalesInList(Prisoners.GetActors())
endFunction

;/
    Returns a list of all male prisoners.
    If a jail cell is passed in, then only return the male prisoners from that cell.

    RPB_JailCell?    @akPrisonCell: The Jail Cell to check for Prisoners.

    returns (Form[]): A list of all male prisoners in the Prison.
/;
Form[] function GetMalePrisoners(RPB_JailCell akPrisonCell = none)
    if (akPrisonCell)
        return akPrisonCell.GetMalePrisoners()
    endif

    return RPB_Utility.GetMalesInList(Prisoners.GetActors())
endFunction

;/
    Returns a list of all cell mates of the specified prisoner.

    RPB_Prisoner @apPrisoner: The prisoner to check for cell mates.

    returns (Form[]): A list of all cell mates of the specified prisoner.
/;
Form[] function GetCellMates(RPB_Prisoner apPrisoner)
    RPB_JailCell jailCell   = apPrisoner.JailCell
    Form[] prisonersInCell  = jailCell.Prisoners
    int cellMates           = FastArray("<Form>")

    int i = 0
    while (i < prisonersInCell.Length)
        if (prisonersInCell[i] != apPrisoner.GetActor())
            FastArray_AddForm(cellMates, prisonersInCell[i])
        endif
        i += 1
    endWhile

    return FastArray_ToFormArray(cellMates)
endFunction

string function GetTimeOfArrestFormatted(RPB_Prisoner apPrisoner)
    int day      = apPrisoner.DayOfArrest
    int month    = apPrisoner.MonthOfArrest
    int year     = apPrisoner.YearOfArrest
    int hour     = apPrisoner.HourOfArrest
    int minute   = apPrisoner.MinuteOfArrest

    return RPB_Utility.GetFormattedDate(day, month, year, hour, minute)
endFunction

string function GetTimeOfImprisonmentFormatted(RPB_Prisoner apPrisoner)
    int day      = apPrisoner.DayOfImprisonment
    int month    = apPrisoner.MonthOfImprisonment
    int year     = apPrisoner.YearOfImprisonment
    int hour     = apPrisoner.HourOfImprisonment
    int minute   = apPrisoner.MinuteOfImprisonment

    return RPB_Utility.GetFormattedDate(day, month, year, hour, minute)
endFunction

string function GetTimeOfReleaseFormatted(RPB_Prisoner apPrisoner)
    int playerSentence = apPrisoner.Sentence

    ; if (apPrisoner.HasReleaseTimeExtraHours())
    ;     playerSentence += 1
    ; endif

    ; if (apPrisoner.IsReleaseOnLoredas())
    ;     playerSentence += 2
    ; elseif (apPrisoner.IsReleaseOnSundas())
    ;     playerSentence += 1
    ; endif


    int releaseDateStruct = RPB_Utility.GetDateFromDaysPassed(apPrisoner.DayOfImprisonment, apPrisoner.MonthOfImprisonment, apPrisoner.YearOfImprisonment, int_if (!apPrisoner.IsUndeterminedSentence, playerSentence))

    int release_day      = RPB_Utility.GetStructMemberInt(releaseDateStruct, "day")
    int release_month    = RPB_Utility.GetStructMemberInt(releaseDateStruct, "month")
    int release_year     = RPB_Utility.GetStructMemberInt(releaseDateStruct, "year")

    ; return RPB_Utility.GetFormattedDate(release_day, release_month, release_year, apPrisoner.ReleaseHour, apPrisoner.ReleaseMinute)

    string release_dayOfWeek   = RPB_Utility.GetDayOfWeekName(RPB_Utility.CalculateDayOfWeek(release_day, release_month, release_year))
    ; string release_hour        = RPB_Utility.GetTimeAs12Hour(apPrisoner.ReleaseHour, apPrisoner.ReleaseMinute)
    ; string release_maxHour     = RPB_Utility.GetTimeAs12Hour(self.ReleaseTimeMaximumHour)
    string release_hour        = RPB_Utility.GetClockFormat(apPrisoner.ReleaseHour, apPrisoner.ReleaseMinute)
    string release_maxHour     = RPB_Utility.GetClockFormat(self.ReleaseTimeMaximumHour)

    float release_midpointHourAndMins = (apPrisoner.ReleaseHour + self.ReleaseTimeMaximumHour) / 2
    int release_midpointHour = math.floor(release_midpointHourAndMins)
    int release_midpointMinutes = Round((release_midpointHourAndMins - math.floor(release_midpointHourAndMins)) * 60)
    string release_midpointHourFormatted = RPB_Utility.GetClockFormat(release_midpointHour, release_midpointMinutes)

    string release_hourShown = string_if (release_day > 9, "~" + release_midpointHourFormatted, release_hour + " - " + release_maxHour)
    string release_dayOrdinal  = RPB_Utility.ToOrdinalNthDay(release_day)
    string release_monthName   = RPB_Utility.GetMonthName(release_month)
    string release_yearString  = "4E " + release_year

    ; Fredas, 7:00 AM - 10:00 AM, 21st of Sun's Dusk, 4E 201 || Fredas, ~8:00 AM, 21st of Sun's Dusk, 4E 201
    return release_dayOfWeek + ", " + release_hourShown + ", " + release_dayOrdinal + " of " + release_monthName + ", " + release_yearString
endFunction

string function GetTimeElapsedSinceArrest(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.CurrentTime - apPrisoner.TimeOfArrest)
endFunction

string function GetTimeElapsedSinceImprisonment(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.CurrentTime - apPrisoner.TimeOfImprisonment)
endFunction

string function GetTimeLeftOfSentenceFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.TimeLeftInSentence)
endFunction

string function GetSentenceFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.Sentence)
endFunction

string function GetCriminalPenaltySentenceFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.CriminalPenaltySentence)
endFunction

string function GetTimeServedFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.TimeServed)
endFunction


;                     Prisoner - Setters
; ==========================================================

function SetSentence(RPB_Prisoner apPrisoner, int aiSentence = 0)
    apPrisoner.SetSentence(aiSentence)
endFunction


;                     Prisoner - Mutators
; ==========================================================

function RestrainPrisoner(RPB_Prisoner apPrisoner, bool abRestrainInFront = false)
    ; Temporary cuffs using ZaZ
    ; Hand Cuffs Backside Rusty - 0xA081D2F
    ; Hand Cuffs Front Rusty - 0xA081D33
    ; Hand Cuffs Front Shiny - 0xA081D34
    ; Hand Cuffs Crossed Front 01 - 0xA033D9D
    ; Hands Crossed Front in Scarfs - 0xA073A14
    ; Hands in Irons Front Black - 0xA033D9E

    ; A different pair already on comes off first (front over back locked the animation); weapons sheathed, not taken
    RPB_Utility.EquipCuffs(apPrisoner.GetActor(), abRestrainInFront)
endFunction

;/
    Releases @apPrisoner where they stand: the whole release (belongings, outfit, cell, hostility restore, leftover arrest
    state), without the move to the release location. For RPB_Recovery.ResetActor.
/;function ReleaseInPlace(RPB_Prisoner apPrisoner)
    apPrisoner.StopEscortAssist() ; a raised walking speed must not outlive the escort
    self.CancelEscortToCellStallCheck(apPrisoner.GetActor())
    self.TeleportPrisonerToRelease(apPrisoner, abMoveToReleaseLocation = false)
endFunction

;/
    Undoes a prisoner an arrest registered but never got to prison (the captor died, a fight broke out, a reset) - without
    a release: a release counts all game time since the start as time jailed (a reset outside prison once took the Time
    Jailed stat from 19 to 88 days, with a sentence of 12, and added infamy). The same teardown as a failed cell assignment
    (OnPrisonerImprisonmentFail): out of the cell, the latent bounty back to active, the state destroyed (which also
    removes the spell). An imprisoned prisoner is never cancelled: that's a release.
/;
function CancelImprisonment(RPB_Prisoner apPrisoner, string asReason, bool abReturnBelongings = true)
    if (!apPrisoner || apPrisoner.IsImprisoned)
        return
    endif

    Actor prisonerActor = apPrisoner.GetActor()
    apPrisoner.StopEscortAssist() ; a raised walking speed must not outlive the escort
    ; Left queued, it fired long after (126's teardown, then an hour waited) on someone no longer a prisoner
    self.CancelEscortToCellStallCheck(prisonerActor)
    Info("["+ Name +"] Imprisonment of " + apPrisoner.Name + " " + prisonerActor + " cancelled (" + asReason + "), not released: no time jailed, no infamy")

    ; Not when nobody is left to hand them over (the guard died inside the prison, no other guard to take over): the
    ; prisoner is free inside, stripped, and gets their things back from the belongings chest themselves
    if (apPrisoner.IsStripped && abReturnBelongings)
        apPrisoner.ReturnBelongings()
        if (apPrisoner.IsNPC())
            apPrisoner.NPC_RestoreOriginalOutfit()
        else
            apPrisoner.Player_ReequipAfterRelease() ; as if it never happened: dressed again, not just given their things back
        endif
    endif
    if (apPrisoner.HasCellPackage)
        apPrisoner.NPC_UnbindFromCell()
    endif
    if (apPrisoner.JailCell)
        apPrisoner.RemoveFromCell()
    endif

    apPrisoner.RestoreBountyForFaction(PrisonFaction) ; no-op when the arrest already gave it back

    RPB_Arrestee arrestState = RPB_Arrestee.GetStateForPrisoner(apPrisoner)
    if (arrestState != none)
        arrestState.Destroy()
    endif
    apPrisoner.Destroy()
endFunction

function TeleportPrisonerToRelease(RPB_Prisoner apPrisoner, bool abMoveToReleaseLocation = true)
    ; Crumbs (only recorded while the dev flag is on): a release that stalls shows the last step it completed
    Actor releasedActor = apPrisoner.GetActor()
    ObjectReference releaseLocation = none
    if (abMoveToReleaseLocation)
        releaseLocation = apPrisoner.TeleportReleaseLocation
    endif
    bool releasedIsNPC = apPrisoner.IsNPC()
    Outfit dressOutfit = none
    if (releasedIsNPC && RPB_Utility.IsCrumbsEnabled())
        dressOutfit = RPB_StorageVars.GetFormOnReference("NPC Original Outfit", releasedActor, "Jail") as Outfit
    endif
    RPB_Utility.Crumb(releasedActor, "Release: start, " + self.__PartsTrace(releasedActor, dressOutfit))
    if (RPB_Utility.IsCrumbsEnabled())
        ; The JContainers handles this release reads, so a console "access to non-existing object with id N" during a test
        ; can be matched to what it was (a cell package once stayed bound after such warnings)
        RPB_Utility.Crumb(releasedActor, "Release: handles jail " + RPB_StorageVars.GetObjectHandleOnReference(releasedActor, "Jail") + ", actor " + RPB_StorageVars.GetObjectHandleOnReference(releasedActor, "Actor") + ", pending dress " + __pendingDress + ", pending hostility " + __pendingHostility + ", has cell package " + apPrisoner.HasCellPackage + " (" + apPrisoner.CellPackage + ")")
    endif
    RPB_Utility.FlowMark("Release: start")

    ; A prisoner effect instance that starts while the release runs (the actor's 3D loads when it is moved) must not register
    ; it again: see Prisoner.OnInitialize. Destroy() wipes this flag together with the rest of the state.
    apPrisoner.SetBool("Releasing", true)

    apPrisoner.GotoState("Released")
    RPB_Utility.Crumb(releasedActor, "Release: Released state entered, " + self.__PartsTrace(releasedActor, dressOutfit))
    RPB_Utility.FlowMark("Release: Released state entered")
    Debug("["+ Name +"] Prison::TeleportPrisonerToRelease", "Released " + apPrisoner.Name + ".")

    apPrisoner.Remove("Imprisoned")

    apPrisoner.ReturnBelongings()
    ; Cuffs stripped into the container before strips deleted them come back with the belongings, and a reset prisoner
    ; can still wear them
    RPB_Utility.RemoveCuffs(releasedActor)
    RPB_Utility.Crumb(releasedActor, "Release: belongings returned, " + self.__PartsTrace(releasedActor, dressOutfit))
    RPB_Utility.FlowMark("Release: belongings returned")
    apPrisoner.NPC_ReequipAfterRelease()
    apPrisoner.Player_ReequipAfterRelease() ; the player too, on a teleport release (an escort release is meant to get a clothing Scene)
    RPB_Utility.Crumb(releasedActor, "Release: outfit re-equipped, " + self.__PartsTrace(releasedActor, dressOutfit))
    RPB_Utility.FlowMark("Release: outfit re-equipped")
    apPrisoner.RemoveFromCell()
    RPB_Utility.Crumb(releasedActor, "Release: removed from cell")
    RPB_Utility.FlowMark("Release: removed from cell")

    if (!releasedIsNPC && releaseLocation)
        apPrisoner.MoveTo(releaseLocation)
    endif

    ; An NPC is moved only AFTER its prisoner state is destroyed and its spell removed: moving it loads its 3D, which starts a new
    ; prisoner effect instance while the spell is still on it, and that instance registered the released NPC in the prison
    ; again (a "ghost" prisoner the monitor then stripped and clothed as if it were still imprisoned).
    ; What the NPC is dressed with again is queued before the release destroys the storage it comes from (see __QueueDress).
    if (releasedIsNPC)
        self.__QueueDress(releasedActor)
    endif
    RPB_Utility.FlowMark("Release: dress queued")
    ; Hostility restore (unlike dressing) applies to the player too: a disguise mod can neutralize the same way an NPC does.
    ; No-ops cheaply when nothing was saved (the common case).
    self.__QueueHostilityRestore(releasedActor)
    RPB_Utility.FlowMark("Release: hostility queued")

    self.OnPrisonerReleased(apPrisoner)
    RPB_Utility.Crumb(releasedActor, "Release: OnPrisonerReleased done, " + self.__PartsTrace(releasedActor, dressOutfit))
    RPB_Utility.FlowMark("Release: OnPrisonerReleased done")

    if (releasedIsNPC)
        if (releaseLocation)
            releasedActor.MoveTo(releaseLocation)
        endif
        RPB_Utility.Crumb(releasedActor, "Release: moved, " + self.__PartsTrace(releasedActor, dressOutfit))
        RPB_Utility.FlowMark("Release: moved")
        releasedActor.EnableAI(true)
        RPB_Utility.Crumb(releasedActor, "Release: AI enabled")
        RPB_Utility.FlowMark("Release: AI enabled")

        ; An equip on an actor whose 3D is not loaded yet can be dropped: give it a moment (bounded)
        float loadWaited = 0.0
        while (!releasedActor.Is3DLoaded() && loadWaited < 1.5)
            Utility.Wait(0.1)
            loadWaited += 0.1
        endWhile
        RPB_Utility.FlowMark("Release: 3D wait")

        ; This is the equip of the release (NPC_ReequipAfterRelease only restores the outfit and issues missing parts): it
        ; happens here, at the release location with the 3D loaded, because an equip done in the cell didn't survive the move.
        ; An escorted release must do the same at its dressing spot - see NPC_ReequipAfterRelease for the order.
        ; The equipment of an NPC released while its cell was unloaded can be right and still not be drawn: refresh the 3D
        float dressStart = Utility.GetCurrentRealTime()
        releasedActor.QueueNiNodeUpdate()
        int equippedNow = self.__DressActor(releasedActor)
        __dressCostMs += (Utility.GetCurrentRealTime() - dressStart) * 1000.0
        __dressCostCount += 1
        RPB_Utility.FlowMark("Release: dress-up")
        if (RPB_Utility.IsCrumbsEnabled()) ; its message calls Is3DLoaded(), built before Crumb() could return early
            RPB_Utility.Crumb(releasedActor, "Release: after the dress-up (equipped " + equippedNow + "), 3D loaded " + releasedActor.Is3DLoaded() + ", " + self.__PartsTrace(releasedActor, dressOutfit))
        endif

        ; Diagnostic (one line per NPC release). Only built when it can print: its message calls GetDisplayName() and
        ; Is3DLoaded(), a frame each, and was built on every NPC release before DebugInfo()/Info() could skip it.
        if (IsDebuggingEnabled() || IsLoggingEnabled())
            string checkMsg = "Dress check on " + releasedActor.GetDisplayName() + " " + releasedActor + ": equipped now " + equippedNow + ", 3D loaded " + releasedActor.Is3DLoaded()
            DebugInfo("["+ Name +"] Prison::TeleportPrisonerToRelease", checkMsg)
            Info(checkMsg)
        endif
    endif
    RPB_Utility.ProbeNPC(releasedActor, "prisoner released")
    RPB_Utility.FlowEnd("Release: done")
endFunction

; ==========================================================
;                  Dressing released NPCs
; ==========================================================
; What a released NPC is dressed with again, and nothing else it carries (it may carry several armors): the plain armor parts of its
; saved original outfit and the armor it wore before it was stripped. The list is read from the storage BEFORE the release destroys
; it and kept in JContainers (actor -> { items, since, tries }), because the engine handles the outfit of a released NPC on its own
; schedule (a tunic equipped in the cell was found unequipped after the move): a delayed pass looks again once things settled.
; No Papyrus array is passed around here: the one built for this used to arrive as None.

int __pendingDress ; JFormMap actor -> JMap { items: JArray of forms, tries: int }, retained
int __pendingPasses ; consecutive OnUpdate calls that found the queue not empty (safety net: a queue that never empties is cleared)
float __dressCostMs ; diagnostics: time spent in the immediate dress-up of released NPCs, and how many
int __dressCostCount

function __EnsurePendingDress()
    if (!__pendingDress || !JValue.isExists(__pendingDress))
        __pendingDress = JValue.retain(JFormMap.object())
    endif
endFunction

int function PendingDressCount()
    if (!__pendingDress || !JValue.isExists(__pendingDress))
        return 0
    endif

    return JFormMap.count(__pendingDress)
endFunction

function __QueueDress(Actor akActor)
    self.__EnsurePendingDress()

    int items = JArray.object()
    Outfit original = RPB_StorageVars.GetFormOnReference("NPC Original Outfit", akActor, "Jail") as Outfit
    if (original)
        int parts = original.GetNumParts()
        int i = 0
        while (i < parts)
            Armor part = original.GetNthPart(i) as Armor
            if (part && JArray.findForm(items, part) < 0)
                JArray.addForm(items, part)
            endif
            i += 1
        endWhile
    endif

    int slot = 30
    while (slot <= 61)
        Armor wornBefore = RPB_StorageVars.GetFormOnReference("NPC Worn Armor " + slot, akActor, "Jail") as Armor
        if (wornBefore && JArray.findForm(items, wornBefore) < 0)
            JArray.addForm(items, wornBefore)
        endif
        slot += 1
    endWhile

    int entry = JMap.object()
    JMap.setObj(entry, "items", items)
    JMap.setInt(entry, "tries", 0)
    JFormMap.setObj(__pendingDress, akActor, entry)
    RPB_Utility.Crumb(akActor, "Dress queued: outfit " + original + ", " + JArray.count(items) + " items")

    Monitor.RequestRealTimeWake("Dress", 3.0)
endFunction

; Equips what the actor carries and does not wear from its queued list. returns (int): how many items it equipped.
int function __DressActor(Actor akActor)
    if (!__pendingDress || !JValue.isExists(__pendingDress))
        return 0
    endif

    int entry = JFormMap.getObj(__pendingDress, akActor)
    if (!entry)
        return 0
    endif

    int items = JMap.getObj(entry, "items")
    int equipped = 0
    int k = 0
    int n = JArray.count(items)
    while (k < n)
        Form item = JArray.getForm(items, k)
        if (item && akActor.GetItemCount(item) > 0 && !akActor.IsEquipped(item))
            akActor.EquipItem(item)
            equipped += 1
        endif
        k += 1
    endWhile
    return equipped
endFunction

; No OnUpdate here: RPB_PrisonMonitor shares this alias and owns its one real-time update. The re-dress pass and the
; Escort-to-Cell stall checks ask it for a wake (Monitor.RequestRealTimeWake), and it calls __ProcessPendingDress() and
; __ProcessEscortStallChecks() when each one is due.

; The delayed pass: every queued NPC is looked at again 3 s (or more) after its release; it stays queued until two passes in a row
; found nothing left to equip, or after 5 passes.
function __ProcessPendingDress()
    if (!__pendingDress || !JValue.isExists(__pendingDress))
        return
    endif

    int keys = JFormMap.allKeys(__pendingDress)
    int n = JArray.count(keys)

    ; A key of a form that no longer exists reads as None and cannot be removed by a None form: rebuild the map from the live entries
    bool dead = false
    int i = 0
    while (i < n)
        if (!(JArray.getForm(keys, i) as Actor))
            dead = true
        endif
        i += 1
    endWhile

    if (dead)
        int fresh = JValue.retain(JFormMap.object())
        int kept = 0
        i = 0
        while (i < n)
            Actor liveActor = JArray.getForm(keys, i) as Actor
            if (liveActor)
                int liveEntry = JFormMap.getObj(__pendingDress, liveActor)
                if (liveEntry)
                    JFormMap.setObj(fresh, liveActor, liveEntry)
                    kept += 1
                endif
            endif
            i += 1
        endWhile
        JValue.release(__pendingDress)
        __pendingDress = fresh
        RPB_Utility.LogWarn("Dropped " + (n - kept) + " re-dress entries of NPCs that no longer exist", "["+ Name +"] Prison::__ProcessPendingDress")
        keys = JFormMap.allKeys(__pendingDress)
        n = JArray.count(keys)
    endif

    ; Every queued NPC is looked at on each update (it fires 3 s after the last release was queued, so each entry is at least that old):
    ; it leaves the queue after two clean passes in a row or after 5 passes. Nothing depends on a clock (real time restarts every session).
    ; A frozen one is passed over (each call below would hang the monitor's update); his tries still count
    int frozenMap = RPB_Utility.FrozenGuardsForScan()
    i = 0
    while (i < n)
        Actor passActor = JArray.getForm(keys, i) as Actor
        int entry = JFormMap.getObj(__pendingDress, passActor)
        if (entry)
            int tries = JMap.getInt(entry, "tries") + 1
            JMap.setInt(entry, "tries", tries)

            bool finished = false
            if (!(frozenMap && RPB_Utility.IsListedFrozen(frozenMap, passActor)) && passActor.Is3DLoaded())
                passActor.QueueNiNodeUpdate()
                int equippedNow = self.__DressActor(passActor)
                RPB_Utility.ProbeNPC(passActor, "released NPC re-dressed")
                string passMsg = "Re-dress pass on " + passActor.GetDisplayName() + " " + passActor + ": equipped " + equippedNow + " (pass " + tries + ")"
                DebugInfo("["+ Name +"] Prison::__ProcessPendingDress", passMsg)
                Info(passMsg)
                RPB_Utility.Crumb(passActor, "Release: pass " + tries + ", equipped " + equippedNow)
                finished = (equippedNow == 0 && tries >= 2)
            endif

            if (finished || tries >= 5)
                JFormMap.removeKey(__pendingDress, passActor)
            endif
        endif
        i += 1
    endWhile

    if (JFormMap.count(__pendingDress) > 0)
        __pendingPasses += 1
        if (__pendingPasses > 40)
            ; more than two minutes of updates and the queue is still not empty: something is wrong, do not loop for ever
            RPB_Utility.LogWarn("The re-dress queue did not empty after " + __pendingPasses + " updates, clearing it", "["+ Name +"] Prison::__ProcessPendingDress")
            JFormMap.clear(__pendingDress)
            __pendingPasses = 0
        else
            Monitor.RequestRealTimeWake("Dress", 3.0)
        endif
    else
        __pendingPasses = 0
    endif
endFunction

; JFormMap actor -> JMap { dueAt: float (real time) }, retained. Owns the Escort-to-Cell stall failsafe (see
; QueueEscortToCellStallCheck/__ProcessEscortStallChecks below) - deliberately NOT on RPB_Prisoner (an ActiveMagicEffect):
; its RegisterForSingleUpdate doesn't survive the escorted actor's 3D unloading (OnEffectFinish tears the instance down,
; and a reload starts a fresh one with no memory of the old timer) - confirmed against this exact codebase's own test-81
; evidence and the PrisonMonitor redesign note, and exactly the condition ("player didn't follow") this bug needs to
; survive. RPB_Prison is a Quest-bound ReferenceAlias, so its own timer has no such dependency.
int __pendingEscortStallChecks

function __EnsurePendingEscortStallChecks()
    if (!__pendingEscortStallChecks || !JValue.isExists(__pendingEscortStallChecks))
        __pendingEscortStallChecks = JValue.retain(JFormMap.object())
    endif
endFunction

;/
    Arms a failsafe for one prisoner's Escort-to-Cell Scene: if it hasn't confirmed (become Imprisoned) within
    afTimeoutSeconds, __ProcessEscortStallChecks() runs the same completion the Scene's own End would have, directly.
    Shares RPB_Prison's existing 3s real-time heartbeat (the same one __ProcessPendingDress already uses) rather than
    computing an exact wake time - Papyrus only gives one pending RegisterForSingleUpdate per event per object, and a
    ~3s granularity is more than precise enough for an 8s-scale timeout.

    The real caller (RPB_EventManager's "Lock Cell" handler) arms this from a confirmed, evidence-backed last
    checkpoint - a real debug-level log showed the Scene reliably reaches this exact phase cue every time, and in a
    stalled run, nothing after it ever arrives - rather than from the Scene's own start (an earlier, less precise
    design that needed a much longer, player-distance-dependent guess to avoid cutting a still-progressing Scene
    short). Arming this close to the real failure point means a short, universal timeout is safe regardless of
    whether the player is nearby.

    Actor   @akPrisoner: the prisoner whose Escort-to-Cell Scene to watch.
    float   @afTimeoutSeconds: how long to wait for the Scene to confirm before treating it as stalled.
/;
function QueueEscortToCellStallCheck(Actor akPrisoner, float afTimeoutSeconds = 8.0, bool abWatchAssist = false)
    self.__EnsurePendingEscortStallChecks()

    int entry = JMap.object()
    JMap.setFlt(entry, "dueAt", Utility.GetCurrentRealTime() + afTimeoutSeconds)
    ; The player's escort from its start: due early when the escort assist's ticks stop (a tick stuck on a frozen guard)
    ; or the guard is known frozen; otherwise only at the timeout
    JMap.setInt(entry, "watchAssist", abWatchAssist as int)
    JMap.setInt(entry, "ticks", -1)
    JFormMap.setObj(__pendingEscortStallChecks, akPrisoner, entry)
    RPB_Utility.Crumb(akPrisoner, "Escort-to-Cell stall check queued, due in " + afTimeoutSeconds + "s")

    Monitor.RequestRealTimeWake("EscortStall", 3.0)
endFunction

; The escort to the cell is over some other way (cancelled, released): nothing left to watch
function CancelEscortToCellStallCheck(Actor akPrisoner)
    if (!akPrisoner || !__pendingEscortStallChecks || !JValue.isExists(__pendingEscortStallChecks))
        return
    endif
    if (JFormMap.hasKey(__pendingEscortStallChecks, akPrisoner))
        JFormMap.removeKey(__pendingEscortStallChecks, akPrisoner)
        RPB_Utility.Crumb(akPrisoner, "Escort-to-Cell stall check cancelled")
    endif
endFunction

;/
    The player's escort to the cell, watched from its start: every heartbeat pass (3s) compares the escort assist's tick
    count. Five passes (~15s) without a new tick make the check due now, and the recovery below moves them into the cell
    without calling him. A frozen guard alone no longer does: his AI walks the escort on, and the assist reads him through
    a marker (RPB_Prisoner.__AssistGuardRef); its own moves take over if he stops (2026-10-04: recovered 10s after he was
    found frozen, the player teleported into the cell for nothing). Imprisoned or gone: the watch ends. Heartbeat passes don't run
    while the game is paused, so a menu never counts as a stuck tick.
/;
function __WatchEscortAssist(Actor akPrisoner, int aiEntry, float afNow)
    RPB_Prisoner watched = Prisoners.AtKey(akPrisoner)
    if (!watched || watched.IsImprisoned)
        JFormMap.removeKey(__pendingEscortStallChecks, akPrisoner)
        return
    endif
    if (!watched.EscortAssistActive)
        JMap.setInt(aiEntry, "still", 0) ; paused (a fight) or between escorts: nothing to judge
        return
    endif
    int ticks = watched.EscortAssistTicks
    int still = 0
    if (ticks == JMap.getInt(aiEntry, "ticks"))
        still = JMap.getInt(aiEntry, "still") + 1
    else
        ; Still ticking: the escort is going on, so the deadline moves with it. A long escort (Castle Dour's, 2026-10-02)
        ; reached the 90s from its start while walking in and was finished by hand; only a stop in the ticks (or a frozen
        ; guard) ends it early now
        JMap.setFlt(aiEntry, "dueAt", RPB_Utility.Max(JMap.getFlt(aiEntry, "dueAt"), afNow + 60.0))
    endif
    JMap.setInt(aiEntry, "ticks", ticks)
    JMap.setInt(aiEntry, "still", still)
    if (still >= 5)
        bool frozen = RPB_Utility.IsFrozenGuard(watched.Captor)
        JMap.setInt(aiEntry, "watchAssist", 0)
        JMap.setFlt(aiEntry, "dueAt", afNow)
        Warn("["+ Name +"] Prison::__WatchEscortAssist: " + akPrisoner + "'s escort to the cell is stuck (the escort assist hasn't ticked for ~" + (still * 3) + "s, guard frozen " + frozen + "): recovering")
    endif
endFunction

; Recovers every entry whose due time has passed and is still not Imprisoned, then re-arms if anything's left pending.
function __ProcessEscortStallChecks()
    if (!__pendingEscortStallChecks || !JValue.isExists(__pendingEscortStallChecks))
        return
    endif

    int keys = JFormMap.allKeys(__pendingEscortStallChecks)
    int n = JArray.count(keys)

    ; Same dead-key rebuild as __ProcessPendingDress/__ProcessHostilityRestore: a key of a form that no longer exists
    ; reads as None and cannot be removed by a None form.
    bool dead = false
    int i = 0
    while (i < n)
        if (!(JArray.getForm(keys, i) as Actor))
            dead = true
        endif
        i += 1
    endWhile

    if (dead)
        int fresh = JValue.retain(JFormMap.object())
        int kept = 0
        i = 0
        while (i < n)
            Actor liveActor = JArray.getForm(keys, i) as Actor
            if (liveActor)
                int liveEntry = JFormMap.getObj(__pendingEscortStallChecks, liveActor)
                if (liveEntry)
                    JFormMap.setObj(fresh, liveActor, liveEntry)
                    kept += 1
                endif
            endif
            i += 1
        endWhile
        JValue.release(__pendingEscortStallChecks)
        __pendingEscortStallChecks = fresh
        RPB_Utility.LogWarn("Dropped " + (n - kept) + " Escort-to-Cell stall checks of NPCs that no longer exist", "["+ Name +"] Prison::__ProcessEscortStallChecks")
        keys = JFormMap.allKeys(__pendingEscortStallChecks)
        n = JArray.count(keys)
    endif

    float now = Utility.GetCurrentRealTime()
    i = 0
    while (i < n)
        Actor checkActor = JArray.getForm(keys, i) as Actor
        int entry = JFormMap.getObj(__pendingEscortStallChecks, checkActor)
        if (entry && JMap.getInt(entry, "watchAssist") == 1)
            self.__WatchEscortAssist(checkActor, entry, now)
        endif
        if (entry && JMap.getFlt(entry, "dueAt") <= now)
            ; Dequeued immediately, before anything below can yield (AwaitPrisonerReference/Scene.Stop()/Wait) - a real
            ; test showed the WARN just below logging twice for one recovery: this shares its 3s heartbeat with other
            ; queues on this same object, so a second OnUpdate() dispatch could land while this one was still suspended
            ; mid-Wait, find this same still-present due entry, and log its own copy of the same WARN before either
            ; pass had removed it (only one ever got far enough to still see !IsImprisoned and actually recover). Once
            ; the key's gone, a second dispatch's own lookup simply won't find it - the same protection
            ; RPB_JailCell.__onCellAttachAndDetachEvent() already gives itself (via __attachEventLockedUntil) against
            ; the equivalent risk for its own event.
            JFormMap.removeKey(__pendingEscortStallChecks, checkActor)

            ; Only a prisoner still registered here, with a cell: awaiting one that's gone (a cancelled imprisonment) found a
            ; blank Prisoner with no cell and "recovered" it
            RPB_Prisoner prisoner = Prisoners.AtKey(checkActor)
            if (prisoner && !prisoner.JailCell)
                Warn("["+ Name +"] Prison::__ProcessEscortStallChecks: dropped the stall check of " + checkActor + ": no cell assigned (the imprisonment is gone)")
                prisoner = none
            endif
            if (prisoner && !prisoner.IsImprisoned)
                ; The Scene's own End never confirmed within the timeout - a Package-driven phase (the guard's approach,
                ; or its final phase after locking the door) can silently never resolve. Run the exact same completion
                ; the Scene would have, directly: OnEscortPrisonerToCellEnd()'s own steps are already idempotent, so
                ; this is safe even if the Scene does eventually still finish on its own afterward.
                Actor guard = prisoner.Captor
                ; Warn() only takes one message string plus a bool condition - passing a second string here silently
                ; got cast to that bool, discarding this whole detail message (confirmed by decompiling the actual
                ; running bytecode). Both this and the escalation warning below printed the same bare fallback text,
                ; which is why what were really two different, legitimate warnings looked like one line logged twice.
                Warn("["+ Name +"] Prison::__ProcessEscortStallChecks: Escort-to-Cell stalled for " + checkActor.GetDisplayName() + " " + checkActor + " (the Scene never confirmed) - recovering directly")

                ; The Scene itself is still technically "playing" from the engine's perspective - a first attempt at
                ; this recovery skipped this step and left both Actors still bound to the Scene's own Reference Aliases
                ; (confirmed in a real test: the guard AND the prisoner were both still stuck on RPB_StayInPlace
                ; afterward, the prisoner should have had RPB_Wander_S). Stopping it explicitly, the same way
                ; AwaitConfrontationScene already does for a stalled confrontation Scene, is what actually releases
                ; whatever Forced Package the Scene's own aliases still hold on both of them.
                Scene stalledScene = self.SceneManager.GetScene(self.SceneManager.EscortToCellSceneName())
                if (stalledScene && stalledScene.IsPlaying())
                    stalledScene.Stop()
                    Utility.Wait(0.5) ; let OnSceneEnd land and clear the SceneManager's own "is playing" flag
                endif

                ; Stop() fires the Scene's own End Fragment - the exact same signal a natural completion sends - which
                ; drives UnsetPackageLockOnActor/OnEscortPrisonerToCellEnd through the real native path on its own. A
                ; first attempt at this recovery called both manually right here regardless, which double-dispatched
                ; the completion (harmless by itself, both are idempotent) but also freed the guard early via a
                ; redundant UnsetPackageLockOnActor, widening the real window before Captor.Destroy()'s own cleanup
                ; actually finishes - a guard reused for a new arrest in that window could race the still-in-flight
                ; teardown of the old one. Re-checking here means the common case goes through Stop()'s own real
                ; cascade alone, with the manual completion only as a genuine last resort if that didn't happen.
                prisoner = self.AwaitPrisonerReference(checkActor)
                if (prisoner && !prisoner.IsImprisoned)
                    Warn("["+ Name +"] Prison::__ProcessEscortStallChecks: Stop() didn't drive " + checkActor.GetDisplayName() + " " + checkActor + " through its own completion either - falling back to a manual finish")
                    ; A frozen guard is left alone: any call on him never returns (FROZEN GUARD)
                    if (RPB_Utility.IsFrozenGuard(guard))
                        guard = none
                    else
                        self.SceneManager.UnsetPackageLockOnActor(guard)
                    endif
                    prisoner.StopEscortAssist()
                    if (!prisoner.IsInCell)
                        ; Not in the cell (the player stuck on the stairs): imprisoned where they stood before. Moved in,
                        ; which begins the imprisonment itself.
                        prisoner.MoveToCell()
                    else
                        ; Already in the cell: locked behind them, as the Scene's "Lock Cell" step and MoveToCell do (this
                        ; finish left the door open, 2026-10-02)
                        RPB_CellDoor stalledDoor = prisoner.JailCell.CellDoor
                        if (stalledDoor)
                            stalledDoor.Close()
                            stalledDoor.Lock()
                        endif
                        self.OnEscortPrisonerToCellEnd(prisoner, prisoner.JailCell, guard)
                    endif
                endif
            endif
        endif
        i += 1
    endWhile

    if (JFormMap.count(__pendingEscortStallChecks) > 0)
        Monitor.RequestRealTimeWake("EscortStall", 3.0)
    endif
endFunction

; Diagnostics for the stress tests: what the immediate dress-up of released NPCs cost
function ResetDressCost()
    __dressCostMs = 0.0
    __dressCostCount = 0
endFunction

string function DressCostSummary()
    float average = 0.0
    if (__dressCostCount > 0)
        average = __dressCostMs / __dressCostCount
    endif
    return (__dressCostMs as int) + " ms over " + __dressCostCount + " NPCs (" + (average as int) + " ms each)"
endFunction

; ==========================================================
;                    Hostile prisoners
; ==========================================================
; A hostile prisoner (a bandit/Civil-War-soldier/Forsworn NPC, or the player disguised via a mod like Master of Disguise) is made
; neutral while imprisoned (Prisoner.NeutralizeWhileImprisoned, called from Imprison): its hostile faction memberships are
; stripped, so guards no longer see it as a target in the cell. What was stripped is read from the storage BEFORE the release
; destroys it (same reasoning as __QueueDress) and queued here, keyed by an absolute game-time due date rather than a real-time
; poll: the delay is measured in hours, and real time restarts every session and must not be persisted (see the re-dress pass
; above). Restoring several prisoners released around the same time is supported (one JFormMap entry per actor); the wake is a
; single game-time timer for whichever entry is due soonest. Unlike the re-dress pass, this queues for the player too (see
; TeleportPrisonerToRelease) since the player can be neutralized the same way an NPC can.

int __pendingHostility ; JFormMap actor -> JMap { factions: JArray of Faction, ranks: JArray of int (parallel), aggression: float, dueAt: float (game time) }, retained
float property HOSTILITY_RESTORE_DELAY_HOURS = 24.0 autoreadonly ; "a good while" after release before a neutralized prisoner turns hostile again

function __EnsurePendingHostility()
    if (!__pendingHostility || !JValue.isExists(__pendingHostility))
        __pendingHostility = JValue.retain(JFormMap.object())
    endif
endFunction

int function PendingHostilityRestoreCount()
    if (!__pendingHostility || !JValue.isExists(__pendingHostility))
        return 0
    endif

    return JFormMap.count(__pendingHostility)
endFunction

bool function HasPendingHostilityRestore(Actor akActor)
    return __pendingHostility && JValue.isExists(__pendingHostility) && JFormMap.hasKey(__pendingHostility, akActor)
endFunction

;/
    Drops @akActor from the queued hostility restores and re-dress passes. For test teardown: a temp actor is deleted
    right after, and its entries would otherwise linger until due (a hostility restore waits a full day).
/;
function ForgetPendingRestores(Actor akActor)
    if (__pendingHostility && JValue.isExists(__pendingHostility))
        JFormMap.removeKey(__pendingHostility, akActor)
    endif
    if (__pendingDress && JValue.isExists(__pendingDress))
        JFormMap.removeKey(__pendingDress, akActor)
    endif
endFunction

; Reads what Prisoner.NeutralizeWhileImprisoned saved (nothing, for the common non-hostile prisoner) and queues it to be
; restored HOSTILITY_RESTORE_DELAY_HOURS after release.
function __QueueHostilityRestore(Actor akActor)
    Form[] savedFactions = RPB_StorageVars.GetFormsOnReference("Hostile Factions", akActor, "Jail")
    if (!savedFactions || savedFactions.Length == 0)
        return ; the common case: this prisoner was never hostile, nothing to restore
    endif

    self.__EnsurePendingHostility()

    int[] savedRanks = RPB_StorageVars.GetIntsOnReference("Hostile Ranks", akActor, "Jail")
    int factions = JArray.object()
    int ranks = JArray.object()
    int i = 0
    while (i < savedFactions.Length)
        JArray.addForm(factions, savedFactions[i])
        JArray.addInt(ranks, savedRanks[i])
        i += 1
    endWhile

    int entry = JMap.object()
    JMap.setObj(entry, "factions", factions)
    JMap.setObj(entry, "ranks", ranks)
    JMap.setFlt(entry, "aggression", RPB_StorageVars.GetFloatOnReference("Original Aggression", akActor, "Jail"))
    float delayHours = RPB_Utility.GetHostilityRestoreOverrideHours()
    if (delayHours <= 0.0)
        delayHours = HOSTILITY_RESTORE_DELAY_HOURS
    endif
    float dueAt = Utility.GetCurrentGameTime() + (delayHours / 24.0)
    JMap.setFlt(entry, "dueAt", dueAt)
    JFormMap.setObj(__pendingHostility, akActor, entry)
    RPB_Utility.Crumb(akActor, "Hostility restore queued: " + savedFactions.Length + " factions, due at game time " + dueAt)

    self.__RescheduleHostilityRestore()
endFunction

; I don't register the restore's game-time wake here: this script shares its alias with RPB_PrisonMonitor, and the two used
; to register on the same object - a monitor reschedule (a release, the player entering or leaving the prison cell) could
; cancel or replace the pending restore wake, so tests 99/100 passed or failed depending on the order of events. The
; monitor is now the only one registering game-time updates on this alias: it takes the earliest of its own release wake
; and NextHostilityRestoreHours(), and runs __ProcessHostilityRestore() whenever it wakes.
function __RescheduleHostilityRestore()
    Monitor.ArmHostilityRestore() ; not a full Reschedule(): that reads every prisoner's sentence, on every release
endFunction

;/
    Hours until the earliest pending hostility restore is due (at least 0.01, so an overdue one wakes almost immediately
    instead of being scheduled into the past), or -1.0 when nothing is pending. Read by RPB_PrisonMonitor.Reschedule().
/;
float function NextHostilityRestoreHours()
    if (!__pendingHostility || !JValue.isExists(__pendingHostility) || JFormMap.count(__pendingHostility) == 0)
        return -1.0
    endif

    int keys = JFormMap.allKeys(__pendingHostility)
    int n = JArray.count(keys)
    float earliest = 0.0
    bool found = false
    int i = 0
    while (i < n)
        Form entryActor = JArray.getForm(keys, i)
        int entry = JFormMap.getObj(__pendingHostility, entryActor)
        ; A frozen one isn't counted: overdue, he'd wake the monitor every few seconds until the next load
        if (entry && !RPB_Utility.IsFrozenGuard(entryActor as Actor))
            float dueAt = JMap.getFlt(entry, "dueAt")
            if (!found || dueAt < earliest)
                earliest = dueAt
                found = true
            endif
        endif
        i += 1
    endWhile

    if (!found)
        return -1.0
    endif

    float hours = (earliest - Utility.GetCurrentGameTime()) * 24.0
    if (hours < 0.01)
        hours = 0.01 ; already due (e.g. after a long time skip): wake almost immediately, not schedule into the past
    endif
    return hours
endFunction

; Restores every entry whose due date has passed. Called from RPB_PrisonMonitor's game-time wake, which re-arms itself
; afterwards (see __RescheduleHostilityRestore for why this script no longer registers its own wake).
function __ProcessHostilityRestore()
    if (!__pendingHostility || !JValue.isExists(__pendingHostility))
        return
    endif

    int keys = JFormMap.allKeys(__pendingHostility)
    int n = JArray.count(keys)

    ; Same dead-key rebuild as __ProcessPendingDress: a key of a form that no longer exists reads as None and cannot be removed
    ; by a None form.
    bool dead = false
    int i = 0
    while (i < n)
        if (!(JArray.getForm(keys, i) as Actor))
            dead = true
        endif
        i += 1
    endWhile

    if (dead)
        int fresh = JValue.retain(JFormMap.object())
        int kept = 0
        i = 0
        while (i < n)
            Actor liveActor = JArray.getForm(keys, i) as Actor
            if (liveActor)
                int liveEntry = JFormMap.getObj(__pendingHostility, liveActor)
                if (liveEntry)
                    JFormMap.setObj(fresh, liveActor, liveEntry)
                    kept += 1
                endif
            endif
            i += 1
        endWhile
        JValue.release(__pendingHostility)
        __pendingHostility = fresh
        RPB_Utility.LogWarn("Dropped " + (n - kept) + " hostility-restore entries of NPCs that no longer exist", "["+ Name +"] Prison::__ProcessHostilityRestore")
        keys = JFormMap.allKeys(__pendingHostility)
        n = JArray.count(keys)
    endif

    float now = Utility.GetCurrentGameTime()
    int frozenMap = RPB_Utility.FrozenGuardsForScan()
    i = 0
    while (i < n)
        Actor restoreActor = JArray.getForm(keys, i) as Actor
        int entry = JFormMap.getObj(__pendingHostility, restoreActor)
        ; A frozen one keeps his entry (every call below would hang the monitor's whole wake): restored after the next load
        if (entry && JMap.getFlt(entry, "dueAt") <= now && !(frozenMap && RPB_Utility.IsListedFrozen(frozenMap, restoreActor)))
            int factions = JMap.getObj(entry, "factions")
            int ranks = JMap.getObj(entry, "ranks")
            int k = 0
            int factionCount = JArray.count(factions)
            string ranksLogged = ""
            while (k < factionCount)
                Faction restoreFaction = JArray.getForm(factions, k) as Faction
                if (restoreFaction)
                    int savedRank = JArray.getInt(ranks, k)
                    restoreActor.AddToFaction(restoreFaction)
                    ; SetFactionRank(faction, -1) REMOVES the actor from the faction (that is the documented behavior, not a
                    ; quirk): most combat factions (BanditFaction included) store their members at rank -1 since rank is
                    ; meaningless for them, so calling it unconditionally undid the AddToFaction() right above it (test 99:
                    ; the restore ran, the queue emptied, but the faction never came back). AddToFaction() alone already
                    ; restores plain membership; only set a rank when one was actually meaningful.
                    if (savedRank >= 0)
                        restoreActor.SetFactionRank(restoreFaction, savedRank)
                    endif
                    ranksLogged += " " + restoreFaction + "=r" + savedRank
                endif
                k += 1
            endWhile
            restoreActor.SetActorValue("Aggression", JMap.getFlt(entry, "aggression"))

            string restoreMsg = "Hostility restored on " + restoreActor.GetDisplayName() + " " + restoreActor + ": " + factionCount + " factions:" + ranksLogged
            DebugInfo("["+ Name +"] Prison::__ProcessHostilityRestore", restoreMsg)
            Info(restoreMsg)
            RPB_Utility.Crumb(restoreActor, "Hostility restored: " + factionCount + " factions")
            JFormMap.removeKey(__pendingHostility, restoreActor)
        endif
        i += 1
    endWhile
endFunction

; The NPC's outfit parts: how many it carries and whether each is worn, to see where a part is doubled or lost during the release.
string function __PartsTrace(Actor akActor, Outfit akOutfit)
    if (!akOutfit || !RPB_Utility.IsCrumbsEnabled())
        return ""
    endif

    string trace = "parts:"
    int n = akOutfit.GetNumParts()
    int i = 0
    while (i < n)
        Armor part = akOutfit.GetNthPart(i) as Armor
        if (part)
            trace += " [" + part.GetName() + " c" + akActor.GetItemCount(part) + " w" + akActor.IsEquipped(part) + "]"
        endif
        i += 1
    endWhile
    return trace
endFunction

function EscortPrisonerToRelease(RPB_Prisoner apPrisoner)
    apPrisoner.GotoState("Releasing")
    apPrisoner.NoteStateEntered()

    ObjectReference releaseLocation = self.GetRandomReleaseMarker("Escort") as ObjectReference
    self.SendEscortPrisonerFromCellRequest(apPrisoner, releaseLocation)
endFunction

bool function SendReleaseRequest(RPB_Prisoner apPrisoner)
    RPB_Utility.FlowBegin("Release")
    if (apPrisoner.IsNPC() && apPrisoner.IsFarFromPlayer())
        apPrisoner.SetBool("Teleport to Release", true)

    else
        apPrisoner.SetBool("Teleport to Release", true)
        ; apPrisoner.SetBool("Escort to Release", true)
    endif

    ; TODO: Maybe add some conditions for instances where the Release request should be denied.
    RPB_Utility.FlowMark("Release: request routed")

    if (apPrisoner.Should("Teleport to Release"))
        self.TeleportPrisonerToRelease(apPrisoner)

    elseif (apPrisoner.Should("Escort to Release"))
        self.EscortPrisonerToRelease(apPrisoner)
    endif
endFunction

;/
    The NPC side of the player's time skip, as a chronological timeline: every NPC prisoner with less time left than
    @afPlayerTimeLeft is released in order of release time, and game time is passed only by the DIFFERENCE since the
    previous event before each release, so an NPC is released at its own release time (its Time Jailed and infamy are its
    sentence, not the moment a background stack happened to run) and the player is released after them. Each release is
    waited for, bounded (Monitor.ReleaseNPC); only the release by event (RPB_Utility.IsNpcReleaseByEvent) keeps a release
    that hangs from hanging the skip too: on this stack, the release itself isn't bounded. A prisoner RPB found frozen
    isn't in the list at all (GetPrisonersReleasedNoLaterThan).

    returns (int): the days passed here (the caller passes the rest for the player).
/;
int function ReleaseDueNPCsInOrder(float afPlayerTimeLeft)
    ; Equal or less time left: an NPC with the same sentence that was imprisoned earlier is released before the player
    Form[] due = self.GetPrisonersReleasedNoLaterThan(afPlayerTimeLeft)
    int count = due.Length
    if (count == 0)
        return 0
    endif

    float[] left = Utility.CreateFloatArray(count)
    bool[] done = Utility.CreateBoolArray(count, false) ; the fill argument is unreliable: every element is assigned below

    int pending = 0
    int i = 0
    while (i < count)
        RPB_Prisoner prisoner = Prisoners.AtKey(due[i] as Actor)
        if (prisoner && !prisoner.IsPlayer())
            left[i] = prisoner.TimeLeftInSentence
            done[i] = false
            pending += 1
        else
            left[i] = 0.0
            done[i] = true
        endif
        i += 1
    endWhile

    int passed = 0
    while (pending > 0)
        int pick = -1
        int j = 0
        while (j < count)
            if (!done[j] && (pick == -1 || left[j] < left[pick]))
                pick = j
            endif
            j += 1
        endWhile

        if (pick == -1)
            pending = 0
        else
            float delta = left[pick] - passed
            if (delta > 0.0)
                int daysToPass = Ceiling(delta)
                RPB_Utility.PassTimeInDays(daysToPass)
                passed += daysToPass
            endif

            RPB_Prisoner releasing = Prisoners.AtKey(due[pick] as Actor)
            if (releasing)
                Monitor.ReleaseNPC(releasing, due[pick] as Actor)
            endif

            done[pick] = true
            pending -= 1
        endif
    endWhile

    return passed
endFunction

;/
    Queues the release of every NPC prisoner with less time left than @afTimeLeftInSentence (+ one day of padding) in the
    monitor's ordered release queue and returns immediately. It used to release each one inline (passing game time between
    them and calling into every prisoner), so a slow release delayed the player's own fast-forward. @abPassTime is kept
    for existing callers and ignored: the caller (the player's fast forward) passes the time itself.
/;
function ReleasePrisonersWithSentenceLessThan(float afTimeLeftInSentence, bool abPassTime = true)
    ;/ const /; int PADDING_ONE_DAY = 1

    Form[] due = self.GetPrisonersWithCurrentSentenceLessThan(afTimeLeftInSentence, PADDING_ONE_DAY)

    int i = 0
    while (i < due.Length)
        RPB_Prisoner prisoner = Prisoners.AtKey(due[i] as Actor)
        if (prisoner && !prisoner.IsPlayer())
            self.QueueRelease(prisoner)
        endif
        i += 1
    endWhile
endFunction

function TriggerEscape(RPB_Prisoner apPrisoner)
endFunction

function SendEscortPrisonerToCellRequest(RPB_Prisoner apPrisoner)
    ;/
        TODO: Implementation.

        This function will send a request to the Prison letting it know that a prisoner
        is awaiting escort to their cell.

        This would be most useful when there are multiple prisoners escorted to the prison,
        awaiting to be frisked/stripped or just processed.

        It would then add the prisoner to a queue in the prison, and they would be led 1 by 1
        to their cell as the queue empties.
    /;
    FunctionNotImplemented("Prison::SendEscortPrisonerToCellRequest")
endFunction

function SendEscortPrisonerFromCellRequest(RPB_Prisoner apPrisoner, ObjectReference akDestination)
    ;/
        TODO: Implementation.

        This function will send a request to the Prison letting it know that a prisoner
        is awaiting escort from their cell.

        The main scenario of this is when multiple prisoners are to be released,
        usually they are released 1 by 1, so we would need to implement a queue system.

        It would then add the prisoner to a queue in the prison, and they would be led 1 by 1
        from their cell to the destination as the queue empties.
    /;
    FunctionNotImplemented("Prison::SendEscortPrisonerFromCellRequest")
endFunction

;/
    Sets the Prisoner's belongings container where their items will be stored
    while they are in prison.

    RPB_Prisoner    @apPrisoner: The prisoner to set the belongings container for.
/;
function AssignBelongingsContainer(RPB_Prisoner apPrisoner)
    if (apPrisoner.PrisonerBelongingsContainer)
        return
    endif

    apPrisoner.SetForm("Prisoner Belongings Container", self.GetRandomPrisonerContainer("Belongings"))
    ; Debug("Prison::SetBelongingsContainer", "Prisoner Belongings Container:  " + apPrisoner.PrisonerBelongingsContainer)
endFunction

function AssignReleaseLocation(RPB_Prisoner apPrisoner, bool abIsTeleportLocation = true)
    if (abIsTeleportLocation)
        apPrisoner.SetForm("Teleport Release Location", self.GetRandomReleaseMarker("Teleport"))
    else
        apPrisoner.SetForm("Teleport Release Location", self.GetRandomReleaseMarker("Escort")) ; Change Form Map ID to Escort
    endif
endFunction

bool function AssignCell(RPB_Prisoner apPrisoner)
    if (apPrisoner.JailCell)
        Debug("["+ Name +"] Prison::AssignCell", "A prison cell has already been assigned to prisoner " + apPrisoner.Name + ": [" +"Cell: " + apPrisoner.JailCell + ", Door: " + apPrisoner.JailCell.CellDoor + "]")
        return true
    endif

    RPB_Utility.FlowMark("AssignCell: start")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "AssignCell: start")

    ; Picking a cell and registering the prisoner in it must be one step: arrests that start together used to all see the same
    ; cell as free (nobody was registered in it yet) and filled cells past their maximum. The lock is per prison and short.
    int cellLock = RPB_ThreadLock.Get("AssignCell_" + Name)
    ; Arrests that start together queue here one after another, each holding the lock through the cell's binding (up to
    ; ~0.5s), so a waiter can wait well over 5s. Acquire() only force-takes a lock nobody has acquired for ~5s, so a moving
    ; queue never does: a force-take would put two arrests in here at once, both seeing the same cell as not full (test
    ; 92 once imprisoned 10 NPCs in 9 places, a cell at 3 of 2, while the bound still counted each waiter's own wait).
    RPB_ThreadLock.Acquire(cellLock)

    RPB_JailCell assignedCell = self.RequestCell(apPrisoner)
    RPB_Utility.FlowMark("AssignCell: RequestCell")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "AssignCell: RequestCell")
    ; RPB_JailCell assignedCell = GetFormFromMod(0x388D) as RPB_JaiLCell

    if (assignedCell == none)
        RPB_ThreadLock.Release(cellLock)
        RPB_Utility.LogError("Could not assign a cell for prisoner " + apPrisoner.Name, "("+ Name +") Prison::AssignCell")
        return false
    endif

    ; An NPC needs a cell AI package to stay in its cell, and the package aliases are finite: when they are all in use the prison is
    ; full for NPCs whatever the cells allow. (Counted by prisoner: the alias is only occupied at bind time, later than this.)
    if (apPrisoner.IsNPC())
        int packageCapacity = PrisonManager.GetCellPackageCapacity(assignedCell.PackageSize)
        if (packageCapacity > 0 && self.__CountNPCPrisonersInCells(apPrisoner) >= packageCapacity)
            RPB_ThreadLock.Release(cellLock)
            RPB_Utility.LogWarn("No cell package left for " + apPrisoner.Name + " (" + packageCapacity + " in use), the prison cannot hold more NPCs", "("+ Name +") Prison::AssignCell")
            return false
        endif
    endif

    self.BindCellToPrisoner(assignedCell, apPrisoner) ; Actually bind this jail cell to the prisoner, it has been assigned.
    RPB_ThreadLock.Release(cellLock)
    return apPrisoner.JailCell != none
endFunction

; NPC prisoners (other than @apExcept) that hold a cell: each one holds or is about to hold a cell package
int function __CountNPCPrisonersInCells(RPB_Prisoner apExcept)
    int count = 0
    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner other = Prisoners.AtIndex(i)
        if (other && other != apExcept && other.IsNPC() && other.JailCell != none)
            count += 1
        endif
        i += 1
    endWhile
    return count
endFunction

function RemoveFromCell(RPB_Prisoner apPrisoner)
    RPB_JailCell jailCell = apPrisoner.JailCell

    if (!jailCell)
        RPB_Utility.LogWarn("The prisoner " + apPrisoner.Name + " is not bound to any jail cell!", "["+ Name +"] Prisoner::RemoveFromCell")
        return
    endif
    
    jailCell.RemovePrisoner(apPrisoner)
endFunction

function ClearPrisonerBounty(RPB_ActorBase apActor)
    apActor.ClearLatentBountyForFaction(PrisonFaction)
endFunction

bool function AssignPrisonerToCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    if (!akJailCell.IsAvailable)
        self.OnPrisonerCellAssignFail(apPrisoner, akJailCell)
        return false
    endif

    akJailCell.RegisterPrisoner(apPrisoner)
    return true
endFunction



function RegisterPrisonerLastJailedStats(RPB_Prisoner apPrisoner)
    ; Only register for the player, for now
    if (apPrisoner.IsPlayer())
        ; Reset Last Released/Escaped vars
        RPB_StorageVars.DeleteCategoryOnReference(self.PrisonFaction, "PrisonLastReleased")
        RPB_StorageVars.DeleteCategoryOnReference(self.PrisonFaction, "PrisonLastEscaped")

        RPB_StorageVars.SetStringOnReference("Last Jailed - Prison", self.PrisonFaction, self.UUID, "PrisonLastJailed")
        RPB_StorageVars.SetIntOnReference("Last Jailed - Day", self.PrisonFaction, RPB_Utility.GetCurrentDay(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnReference("Last Jailed - Month", self.PrisonFaction, RPB_Utility.GetCurrentMonth(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnReference("Last Jailed - Year", self.PrisonFaction, RPB_Utility.GetCurrentYear(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnReference("Last Jailed - Hour", self.PrisonFaction, RPB_Utility.GetCurrentHour(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnReference("Last Jailed - Minute", self.PrisonFaction, RPB_Utility.GetCurrentMinute(), "PrisonLastJailed")
        RPB_StorageVars.SetStringOnReference("Last Jailed - Cell", self.PrisonFaction, apPrisoner.JailCell.ID, "PrisonLastJailed")
    endif
endFunction

function RegisterPrisonerReleaseTimeStats(RPB_Prisoner apPrisoner)
    ; Only register for the player, for now
    if (apPrisoner.IsPlayer())
        RPB_StorageVars.SetIntOnReference("Last Released - Prison", self.PrisonFaction, self.ID, "PrisonLastReleased")
        RPB_StorageVars.SetIntOnReference("Last Released - Day", self.PrisonFaction, RPB_Utility.GetCurrentDay(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnReference("Last Released - Month", self.PrisonFaction, RPB_Utility.GetCurrentMonth(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnReference("Last Released - Year", self.PrisonFaction, RPB_Utility.GetCurrentYear(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnReference("Last Released - Hour", self.PrisonFaction, RPB_Utility.GetCurrentHour(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnReference("Last Released - Minute", self.PrisonFaction, RPB_Utility.GetCurrentMinute(), "PrisonLastReleased")
        RPB_StorageVars.SetStringOnReference("Last Released - Cell", self.PrisonFaction, apPrisoner.JailCell.ID, "PrisonLastReleased")
    endif
endFunction

function RegisterPrisonerEscapeTimeStats(RPB_Prisoner apPrisoner)
    ; Only register for the player, for now
    if (apPrisoner.IsPlayer())
        RPB_StorageVars.SetIntOnReference("Last Escaped - Prison", self.PrisonFaction, self.ID, "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnReference("Last Escaped - Day", self.PrisonFaction, RPB_Utility.GetCurrentDay(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnReference("Last Escaped - Month", self.PrisonFaction, RPB_Utility.GetCurrentMonth(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnReference("Last Escaped - Year", self.PrisonFaction, RPB_Utility.GetCurrentYear(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnReference("Last Escaped - Hour", self.PrisonFaction, RPB_Utility.GetCurrentHour(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnReference("Last Escaped - Minute", self.PrisonFaction, RPB_Utility.GetCurrentMinute(), "PrisonLastEscaped")
        RPB_StorageVars.SetStringOnReference("Last Escaped - Cell", self.PrisonFaction, apPrisoner.JailCell.ID, "PrisonLastEscaped")
    endif
endFunction

; ==========================================================
;                           Scenes
; ==========================================================

;                       Escort Actions
; ==========================================================

function EscortPrisonerToJail(RPB_Prisoner apPrisoner, Actor akEscort)
    ObjectReference escortLocation = self.GetRandomEscortLocation()
    apPrisoner.NPC_BindToCell()

    SceneManager.StartEscortToJail( \
        akEscortLeader      = akEscort, \
        akEscortedPrisoner  = apPrisoner.GetActor(), \
        akPrisonerChest     = escortLocation \
    )

    ; Set state
    apPrisoner.SetBool("Go to Cell", true)
endFunction

function EscortPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
    RPB_JailCell jailCell = apPrisoner.JailCell

    ObjectReference outsideCellGuardWaitingMarker = jailCell.GetRandomMarker("Exterior")
    apPrisoner.NPC_BindToCell()

    SceneManager.StartEscortToCell( \
        akEscortLeader              = akEscort, \
        akEscortedPrisoner          = apPrisoner.GetActor(), \
        akJailCellMarker            = jailCell, \
        akJailCellDoor              = jailCell.CellDoor, \
        akEscortWaitingMarker       = outsideCellGuardWaitingMarker \ 
    )
endFunction

function EscortPrisonerFromJail(RPB_Prisoner apPrisoner, Actor akEscort)
    FunctionNotImplemented("Prison::EscortPrisonerFromJail")
endFunction

function EscortPrisonerFromCell(RPB_Prisoner apPrisoner, Actor akEscort)
    FunctionNotImplemented("Prison::EscortPrisonerFromCell")
endFunction

;                        Misc Actions
; ==========================================================

function StartRestrainingPrisoner(RPB_Prisoner apPrisoner, Actor akRestrainer)
    SceneManager.StartRestrainPrisoner_02( \
        akGuard       = akRestrainer, \
        akPrisoner    = apPrisoner.GetActor() \
    )
endFunction

function StartFriskingPrisoner(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    SceneManager.StartFrisking( \
        akFriskerGuard     = akSearcherGuard, \
        akFriskedPrisoner  = apPrisoner.GetActor() \
    )
endFunction

function StartStrippingPrisoner(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    ObjectReference stripMarker = self.GetRandomSearchMarker("Stripping") as ObjectReference

    SceneManager.StartStripping_02( \
        akStripperGuard     = akSearcherGuard, \
        akStrippedPrisoner  = apPrisoner.GetActor(), \
        akStripMarker       = none \
    )
endFunction

function StartGivingPrisonerClothing(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    SceneManager.StartGiveClothing( \
        akGuard     = akSearcherGuard, \
        akPrisoner  = apPrisoner.GetActor() \
    )
endFunction

; What's left of the prison flow (strip, clothing, escort to the cell), from where it stands, with @akGuard: another guard
; took over after the first one died inside the prison (RPB_Arrestee.HandOverInPrison). The cell and the belongings
; container were already assigned at the arrival. The queue plays them in order.
function ResumePrisonFlowWith(RPB_Prisoner apPrisoner, Actor akGuard)
    ; He comes to the prisoner first and cuffs them (RPB_RestrainPrisoner02: a Travel to the prisoner, then the restrain):
    ; the strip Scene has no approach and strips at its start, since its guard normally escorted the prisoner there. A
    ; take-over guard from across the prison stripped them with nobody there, then had them walk over to him.
    ; Not when already cuffed (the guard died after the strip): its hands-behind-back pose over the cuffs broke the animation
    ; Nothing worn to strip (the player took it all off), but their things still on them: taken silently, as at the
    ; arrival. Without it they went to the cell with everything they had (2026-10-04). The cuffs stay on (as in every
    ; strip), so the restrain below doesn't play over them
    bool strippedSilently = false
    if (!apPrisoner.IsStripped && !apPrisoner.ShouldBeStripped && apPrisoner.ShouldBeStrippedSilently)
        apPrisoner.StripSilently()
        strippedSilently = true
    endif
    if (!RPB_Utility.IsCuffed(apPrisoner.GetActor()))
        self.StartRestrainingPrisoner(apPrisoner, akGuard)
    endif
    if (!strippedSilently && !apPrisoner.IsStripped && apPrisoner.ShouldBeStripped)
        self.StartStrippingPrisoner(apPrisoner, akGuard)
    endif
    if (apPrisoner.ShouldBeClothed && !apPrisoner.IsClothed)
        self.StartGivingPrisonerClothing(apPrisoner, akGuard)
    endif
    if (apPrisoner.Should("Go to Cell"))
        self.EscortPrisonerToCell(apPrisoner, akGuard)
    endif
endFunction

; ==========================================================
;                          Events
; ==========================================================

;/
    Handles imprisonment failures of any kind.
    
    RPB_Prisoner    @apPrisoner: The prisoner that has failed to be imprisoned.
    string          @reason: The reason for imprisonment failing.
/;
event OnPrisonerImprisonmentFail(RPB_Prisoner apPrisoner, string reason)
    if (reason == "Assign Cell")
        ; Could not assign a cell to this prisoner, abort imprisonment?
        DebugError("["+ Name +"] Prison::OnPrisonerImprisonmentFail", "A jail cell could not be assigned to prisoner " + apPrisoner.Name + ", aborting imprisonment and destroying reference...!")
        Error("["+ Name +"] A jail cell could not be assigned to " + apPrisoner.Name + ", aborting imprisonment...!")

        RPB_Arrestee prisonerArresteeState = RPB_Arrestee.GetStateForPrisoner(apPrisoner)
        if (prisonerArresteeState != none)
            prisonerArresteeState.Destroy()
        endif

        ; Destroy() (not just UnregisterPrisoner()) so the prisoner's state is wiped too: its "Initialized"
        ; flag survived an unregister-only, and a later re-arrest of this same NPC then skipped registering
        ; (RPB_Prisoner.OnInitialize returns early when "Initialized" is already true) or would have kept
        ; the previous sentence and release location. Destroy() clears the state, then unregisters (which
        ; also removes the spell), exactly like the release path.
        apPrisoner.Destroy()
    endif
endEvent

event OnPrisonerRegistered(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerLastJailedStats(apPrisoner)

    Monitor.RegisterPrisoner(apPrisoner)
    PrisonManager.OnPrisonRegisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerUnregistered(RPB_Prisoner apPrisoner)
    PrisonManager.OnPrisonUnregisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerReleased(RPB_Prisoner apPrisoner)
    ; INFO level (visible with debug logging off): the MCM cannot show a released NPC's Time Jailed, the log can
    ; Info() is silent while debug logging is on (only the Debug* variants print then): call both, exactly one prints.
    ; Only built when one of them can print: the message reads stats and the game time (natives) on every release.
    if (IsDebuggingEnabled() || IsLoggingEnabled())
        string releasedMsg = "["+ Name +"] Released " + apPrisoner.Name + ": sentence " + apPrisoner.Sentence + " days, time jailed " + apPrisoner.QueryStat("Time Jailed") + " days, time served " + apPrisoner.TimeServed + " days, released at game time " + Utility.GetCurrentGameTime()
        DebugInfo("["+ Name +"] Prison::OnPrisonerReleased", releasedMsg)
        Info(releasedMsg)
    endif
    RPB_Utility.FlowMark("OnPrisonerReleased: message")

    self.RegisterPrisonerReleaseTimeStats(apPrisoner)
    RPB_Utility.FlowMark("OnPrisonerReleased: release time stats")
    self.ClearPrisonerBounty(apPrisoner)
    RPB_Utility.FlowMark("OnPrisonerReleased: ClearPrisonerBounty")

    self.OnPrisonerLeave(apPrisoner)
    RPB_Utility.FlowMark("OnPrisonerReleased: OnPrisonerLeave")
    ; Normally already gone (imprisonment tears it down); only a prisoner released before reaching the cell still has one
    apPrisoner.ClearArrest()
    RPB_Utility.FlowMark("OnPrisonerReleased: ClearArrest")
    apPrisoner.Destroy()
    RPB_Utility.FlowMark("OnPrisonerReleased: Destroy")
endEvent

event OnPrisonerLeave(RPB_Prisoner apPrisoner)
    self.RegisterInfamyLost(apPrisoner.GetActor())
    Debug("("+ Name +") Prison::OnPrisonerLeave", apPrisoner.Name + " has left the prison! (registering infamy time for state)")
endEvent

event OnPrisonerEscaped(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerEscapeTimeStats(apPrisoner)
    apPrisoner.SetAttackActorOnSight()
    apPrisoner.SetEscapePenalty()
    apPrisoner.RestoreBounty()
    ; apPrisoner.DEBUG_ShowHoldStats()
    apPrisoner.OnEscaped()
    self.OnPrisonerLeave(apPrisoner)
endEvent

event OnPrisonerTeleportedToPrison(RPB_Prisoner apPrisoner)
    apPrisoner.SetBelongingsContainer()

    if (apPrisoner.ShouldBeFrisked)
        self.StartFriskingPrisoner(apPrisoner, apPrisoner.Captor)
        ; apPrisoner.Frisk()
    endif

    if (apPrisoner.ShouldBeStripped)
        self.StartStrippingPrisoner(apPrisoner, apPrisoner.Captor) ; Maybe there's some instances where a Captor is not available? TODO: Refactor and take this into account
    endif

    ; Same thing here regarding the Captor, and maybe there should be instances where the prisoner is not taken to the cell.
    self.StartRestrainingPrisoner(apPrisoner, apPrisoner.Captor)
    self.EscortPrisonerToCell(apPrisoner, apPrisoner.Captor)

    apPrisoner.OnTeleportedToPrison()
endEvent

event OnPrisonerTeleportedToCell(RPB_Prisoner apPrisoner, bool abImprisonPrisoner)
    if (apPrisoner.IsNPC())
        apPrisoner.EnableAI(!apPrisoner.IsFarFromPlayer()) ; Disable AI if not near Player
        apPrisoner.NPC_BindToCell()
    endif

    RPB_Utility.FlowMark("Teleported: AI + NPC_BindToCell")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Teleported: AI + NPC_BindToCell")
    if (!apPrisoner.PrisonerBelongingsContainer)
        self.AssignBelongingsContainer(apPrisoner)
    endif

    RPB_Utility.FlowMark("Teleported: belongings container")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Teleported: belongings container")
    if (apPrisoner.ShouldBeFrisked)
        apPrisoner.Frisk()
    endif

    RPB_Utility.FlowMark("Teleported: frisk")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Teleported: frisk")
    if (apPrisoner.ShouldBeStripped)
        apPrisoner.Strip(abRemoveUnderwear = apPrisoner.WillBeStrippedNaked)

    elseif (apPrisoner.ShouldBeStrippedSilently)
        apPrisoner.StripSilently()
    endif

    RPB_Utility.FlowMark("Teleported: strip")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Teleported: strip")
    if (apPrisoner.ShouldBeClothed)
        apPrisoner.DetermineClothingOutfit()
        apPrisoner.Clothe()
    endif

    RPB_Utility.FlowMark("Teleported: clothe")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Teleported: clothe")
    if (abImprisonPrisoner)
        apPrisoner.Imprison()
    endif

    apPrisoner.SetBool("Should Be In Cell", true)
    apPrisoner.OnTeleportedToCell(abImprisonPrisoner)
endEvent

event OnPrisonerDying(RPB_Prisoner apPrisoner, Actor akKiller)
    
endEvent

event OnPrisonerDeath(RPB_Prisoner apPrisoner, Actor akKiller)

endEvent
event OnEscortPrisonerToJailBegin(RPB_ActorBase apActor, Actor akEscort)
    ; Watched as the walk starts: a guard found frozen now hands the escort to a guard who sees it (RPB_Arrest.__HandOverEscort)
    RPB_Utility.ProbeGuardAfterBurst(akEscort, "escort to jail began")
    RPB_Utility.ProbeNPC(apActor.GetActor(), "escort to jail began") ; an NPC prisoner through the same burst (the player isn't probed)
    ; The player's stairs assist for the walk (RPB_Prisoner's Escorting state)
    RPB_Prisoner prisonerRef = self.Prisoners.AtKey(apActor.GetActor())
    if (prisonerRef)
        prisonerRef.StartEscortAssist(akEscort, abToCell = false)
    endif
endEvent

; TODO: Possibly rename this to OnEscortedPrisonerToPrison
event OnEscortPrisonerToJailEnd(RPB_ActorBase apActor, Actor akEscort)
    ; Retrieve or make the Actor a Prisoner
    ; An if, not ame_if: its arguments are all evaluated, so MakePrisoner() ran on a None Arrestee for a prisoner already
    RPB_Prisoner prisonerRef = apActor as RPB_Prisoner
    if (!prisonerRef)
        prisonerRef = (apActor as RPB_Arrestee).MakePrisoner()
    endif
    prisonerRef.StopEscortAssist()
    prisonerRef.EndArrestEscortWatch() ; the arrest's own escort watch sent me back here mid escort to the cell

    self.PrepareArrival(prisonerRef)

    ; TODO: Review if a prisoner should be both frisked and stripped, or only stripped if they were going to be stripped
    ; This used to skip straight from ShouldBeStripped to ShouldBeFrisked, missing the ShouldBeStrippedSilently tier
    ; OnPrisonerTeleportedToCell already checks correctly - ShouldStrip() deliberately returns false once the
    ; prisoner already reads as naked (e.g. the shared ActorBase was already left "Naked" by an earlier prisoner of
    ; the same base), but ShouldSilentlyStrip() has the opposite guard specifically to still catch anything left
    ; equipped (a weapon, say) in that case. Since Frisking has no real effect (ShouldFrisk() is hardcoded true and
    ; the Frisking Scene has no code hookup to actually remove anything), a prisoner who fell through both of the
    ; first two checks was silently keeping whatever she still had equipped.
    ; He died as the escort ended: his death's handover (RPB_Arrestee.HandOverInPrison) gives the prison flow to another
    ; guard. Queued with him, its Scenes never started, and one teleported the player into the cell (2026-10-04)
    if (RPB_Utility.IsDeadNoCall(akEscort))
        GuardMark(akEscort, "escort to jail ended with him dead: no prison flow queued with him")
        return
    endif
    GuardMark(akEscort, "escort to jail ended, the prison flow starts with him")
    RPB_Utility.ProbeGuardAfterBurst(akEscort, "escort to jail ended")
    RPB_Utility.ProbeNPC(prisonerRef.GetActor(), "escort to jail ended")
    if (prisonerRef.ShouldBeStripped)
        self.StartStrippingPrisoner(prisonerRef, akEscort)

    elseif (prisonerRef.ShouldBeStrippedSilently)
        prisonerRef.StripSilently()

    elseif (prisonerRef.ShouldBeFrisked)
        self.StartFriskingPrisoner(prisonerRef, akEscort)
    endif

    
    if (prisonerRef.ShouldBeClothed)
        self.StartGivingPrisonerClothing(prisonerRef, akEscort)
    endif

    if (prisonerRef.Should("Go to Cell"))
        ; Need to check if the prisoner is not in the cell later, IsInCell doesn't work as it should
        self.EscortPrisonerToCell(prisonerRef, akEscort)
    endif
    GuardMark(akEscort, "prison flow queued (strip, clothing, escort to the cell)")

    prisonerRef.OnEscortedToPrison(akEscort)
endEvent

; TODO: Possibly rename this to OnEscortPrisonerToPrison
event OnEscortPrisonerToCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerToCellBegin", "Escape"))
        ; Process escort to cell after escape
    endif

    ; Only when nothing is on: the arrest's cuffs are still on unless a strip took them, and the strip Scenes cuff again
    ; themselves (my own re-cuff at the strip's end added back cuffs under their front ones and locked the prisoner at the
    ; belongings chest). The cell end uncuffs.
    if (!RPB_Utility.IsCuffed(apPrisoner.GetActor()))
        apPrisoner.Restrain()
    endif
    apPrisoner.StartEscortAssist(akEscort, abToCell = true) ; the player's stairs assist (Castle Dour's stairs)
    apPrisoner.OnEscortToCell(akEscort)
endEvent

event OnEscortingPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
endEvent

; TODO: Remove RPB_JailCell from params. since a Prisoner already has a jail cell assigned to them
event OnEscortPrisonerToCellEnd(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell, Actor akEscort)
    RPB_Utility.ProbeGuardAfterBurst(akEscort, "escort to the cell ended")
    RPB_Utility.ProbeNPC(apPrisoner.GetActor(), "escort to the cell ended")
    apPrisoner.StopEscortAssist()
    ; TODO: Fix NPC not staying in cell if they are stripped OnEscortToCellEnd
    if (!apPrisoner.IsStripped && apPrisoner.ShouldBeStripped)
        ; abRemoveUnderwear defaults to true - unlike OnPrisonerTeleportedToCell's own Strip() call, this one was
        ; leaving it at that default instead of passing WillBeStrippedNaked, so a prisoner configured to keep their
        ; underwear never got it saved/re-equipped by Strip() itself on this path - NPC_UpdateUnderwear()'s retry loop
        ; was left as the only chance, and a real regression there (now fixed) meant it sometimes never happened at all.
        apPrisoner.Strip(abRemoveUnderwear = apPrisoner.WillBeStrippedNaked)
        ; apPrisoner.StartStripping(akEscort)
        ; SceneManager.ResumeSceneBlocked()
    endif

    if (!apPrisoner.PrisonerBelongingsContainer)
        self.AssignBelongingsContainer(apPrisoner)     ; Set the container of where the prisoner's items will be confiscated to
    endif

    apPrisoner.Uncuff()

    if (!apPrisoner.IsImprisoned)
        apPrisoner.Imprison()
    endif

    if (apPrisoner.IsNPC())
        if (apPrisoner.IsFarFromPlayer())
            ; The player isn't here to see whether the Scene's own native package actually finished walking this NPC
            ; in and locking the door - exactly the class of thing that can stall the Scene in the first place. I
            ; react now, since the Scene already had its full chance to play, instead of only reacting once the
            ; player eventually visits this cell: PerformPrisonerSanityCheck() runs the same EnableAI/MoveTo
            ; correction __onCellAttachAndDetachEvent() uses, but as a plain function call it has no load-state
            ; requirement (only native event dispatch - RegisterForSingleUpdate's OnUpdate, OnCellAttach - does),
            ; so it isn't left waiting on this JailCell reference's own cell being loaded to ever run.
            apPrisoner.JailCell.PerformPrisonerSanityCheck(apPrisoner)

            ; Ensures the Prisoner stays in the cell since we update it 10s later after the initial check, delaying
            ; it enough for all actions to finish before the check - kept as a backup for whenever the player visits.
            apPrisoner.JailCell.RegisterForSanityChecking(10.0, apPrisoner = apPrisoner)
        endif
    endif

    apPrisoner.SetBool("Should Be In Cell", true)
    apPrisoner.OnEscortedToCell(akEscort)
endEvent

event OnEscortPrisonerFromCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerFromCellBegin", "Release"))
        ; Process Release
    endif

    EventNotImplemented("Prison::OnEscortPrisonerFromCellBegin")
    apPrisoner.OnEscortFromCell(akEscort)
endEvent

event OnEscortPrisonerFromCellEnd(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerFromCellEnd", "Release"))
        ; Process Release
    endif

    EventNotImplemented("Prison::OnEscortPrisonerFromCellEnd")

    apPrisoner.SetBool("Should Be In Cell", false)
    apPrisoner.OnEscortedFromCell(akEscort)
endEvent

; Happens when a Prisoner is about to be stripped
event OnPrisonerStripBegin(RPB_Prisoner apPrisoner, Actor akStripper)
    ; TODO: Maybe check whether this Prisoner should be stripped
    ; apPrisoner.Strip()
endEvent

; Happens when a Prisoner is being stripped
event OnPrisonerStripping(RPB_Prisoner apPrisoner, Actor akStripper, string asSceneEvent)
    if (asSceneEvent == "Lie Down")
        OrientRelative(apPrisoner.GetActor(), akStripper, afRotZ = 180)
        apPrisoner.PlayAnimation("ZazAPC011")

    elseif (asSceneEvent == "Sit Down")
        ; OrientRelative(apPrisoner.GetActor(), stripperGuard, afRotZ = 180)
        apPrisoner.PlayAnimation("ZazAPC006")

    elseif (asSceneEvent == "Undress Lower Body")
        apPrisoner.UndressLowerBody()
    elseif (asSceneEvent == "Undress Upper Body")
        apPrisoner.UndressUpperBody()

    elseif (asSceneEvent == "Undress to Underwear")
        ; Remove all clothing except Underwear
        apPrisoner.Strip(false)

    elseif (asSceneEvent == "Remove Underwear")
        ; Remove Underwear, prisoner must be unclothed already.
        ; The stripping Scenes send this step whatever the stripping type is, so I filter it here: only a prisoner being
        ; stripped naked loses the underwear (the same rule every direct Strip() call follows). WillBeStrippedNaked also
        ; requires a nude body mod, so removing it otherwise is never right.
        if (apPrisoner.WillBeStrippedNaked)
            apPrisoner.RemoveUnderwear()
        else
            Debug("Prison::OnPrisonerStripping", "Keeping " + apPrisoner.Name + "'s underwear: not being stripped naked")
        endif
    endif
endEvent

; Happens when a Prisoner has been stripped
event OnPrisonerStripEnd(RPB_Prisoner apPrisoner, Actor akStripper)
    if (apPrisoner.HasSceneState("OnPrisonerStripEnd", "Escort to Cell"))
        ; Process Escorting to Cell
    endif
    ; No re-cuffing here: the strip Scenes put the cuffs back on themselves ("Restrain Prisoner", "Stand Up (Kneel)"), and
    ; a second pair from here locked the prisoner's animation (see OnEscortPrisonerToCellBegin)
    if (!apPrisoner.IsInCell)
        ; apPrisoner.StartRestraining(akStripper)
    endif
    ; apPrisoner.EscortToCell(akStripper)
endEvent

event OnPrisonerClothingBegin(RPB_Prisoner apPrisoner, Actor akClothingGiver)
    if (apPrisoner.ShouldBeClothed)
        apPrisoner.DetermineClothingOutfit()
    endif
endEvent

event OnPrisonerClothingOngoing(RPB_Prisoner apPrisoner, Actor akClothingGiver)
endEvent

event OnPrisonerClothingStep(RPB_Prisoner apPrisoner, Actor akClothingGiver, int aiStep)
endEvent

event OnPrisonerClothingEnd(RPB_Prisoner apPrisoner, Actor akClothingGiver)
    if (apPrisoner.ShouldBeClothed)
        apPrisoner.Clothe()
    endif
endEvent

event OnCellDoorOpen(RPB_JailCell akPrisonCell, Actor akOpener)

endEvent

event OnCellDoorClosed(RPB_JailCell akPrisonCell, Actor akCloser)
    
endEvent

event OnJailCellAssigned(RPB_JailCell akJailCell, RPB_Prisoner apPrisoner)
    ; if (akJailCell.IsEmpty)
    ;     akJailCell.SetExclusiveToPrisonerSex(apPrisoner)
    ; endif
endEvent

event OnPrisonerCellAssigned(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    ; akJailCell.OnPrisonerEnter(apPrisoner)
endEvent

event OnPrisonerCellAssignFail(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    RPB_JailCell availableCell = self.GetRandomAvailableJailCell()

    if (availableCell)
        self.AssignPrisonerToCell(apPrisoner, availableCell)
        return
    endif

    ; Destroy() clears the prisoner's state as well as unregistering it (see OnPrisonerImprisonmentFail)
    apPrisoner.Destroy()
endEvent

; Refactor to use CK Triggers, this should be fired on enter/leave trigger
event OnPrisonerEnterCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    ; akJailCell.OnPrisonerEnter(apPrisoner)
endEvent

; Refactor to use CK Triggers, this should be fired on enter/leave trigger
event OnPrisonerLeaveCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    ; akJailCell.OnPrisonerLeave(apPrisoner)
endEvent

; ==========================================================
;                        Actor Specific
; ==========================================================

;/
    Registers the infamy lost at this time for the specified Actor in the Prison.

    Actor   @akActor: The Actor to register the lost infamy for.
/;
function RegisterInfamyLost(Actor akActor)
    self.SetReferenceStateFloat(akActor, "infamy::lost_at", now())
endFunction

;/
    Updates the infamy lost for the specified Actor in the Prison.

    Actor   @akActor: The Actor to update the lost infamy for.
/;
function UpdateInfamyLost(Actor akActor)
    float infamyLostAt = self.GetReferenceStateFloat(akActor, "infamy::lost_at")
    
    if (!infamyLostAt)
        return
    endif

    int currentInfamy = RPB_ActorVars.GetCurrentInfamy(self.PrisonFaction, akActor)
    float infamyLostFromCurrentInfamy = PercentToDecimal(self.InfamyLostDailyOfCurrentInfamy)
    float timePassed = (now() - infamyLostAt)
    float reduceBy = (timePassed * self.InfamyLostDaily) + (timePassed * infamyLostFromCurrentInfamy)
    RPB_ActorVars.ModifyStat("Infamy Gained", self.PrisonFaction, akActor, -reduceBy)

    ; Update with new time for next infamy reduction
    self.RegisterInfamyLost(akActor)

    Debug("("+ Name +") Prison::UpdateInfamyLost", "InfamyLostDaily: " + self.InfamyLostDaily + ", InfamyLostFromCurrentInfamy: " + infamyLostFromCurrentInfamy + ", TimePassed: " + timePassed + ", ReduceBy: " + reduceBy)
    Debug("("+ Name +") Prison::UpdateInfamyLost", "InfamyLostAt: " + infamyLostAt + ", Now: " + now())
endFunction

function ClearActorInfamyState(Actor akActor)
    self.RemoveReferenceState(akActor, "infamy::lost_at")
endFunction

; ==========================================================
;                          Management
; ==========================================================

bool function BindCellToPrisoner(ObjectReference akJailCell, RPB_Prisoner apPrisoner)
    RPB_JailCell jailCell = (akJailCell as RPB_JailCell)

    ; The bind process with this prison has already happened
    if (!jailCell.IsInitialized())
        ; Binds the jail cell to this Prison
        jailCell.BindPrison(self)
        jailCell.ScanCellDoor()
    endif

    ; Register the prisoner into the cell
    RPB_Utility.FlowMark("Bind: init/ScanCellDoor")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Bind: init/ScanCellDoor")
    jailCell.RegisterPrisoner(apPrisoner)
    RPB_Utility.FlowMark("Bind: RegisterPrisoner")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Bind: RegisterPrisoner")
    jailCell.DetermineGoodies()
    RPB_Utility.FlowMark("Bind: DetermineGoodies")
    RPB_Utility.Crumb(apPrisoner.GetActor(), "Bind: DetermineGoodies")

    return true
endFunction

;                       Global Root Properties                    
; =========================================================
bool function Global_GetPropertyOfTypeBool(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeInteger(apRootObject, asPropertyName) as bool
endFunction

int function Global_GetPropertyOfTypeInt(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeInteger(apRootObject, asPropertyName)
endFunction

float function Global_GetPropertyOfTypeFloat(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeFloat(apRootObject, asPropertyName)
endFunction

string function Global_GetPropertyOfTypeString(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeString(apRootObject, asPropertyName)
endFunction

Form function Global_GetPropertyOfTypeForm(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeForm(apRootObject, asPropertyName)
endFunction

int[] function Global_GetPropertyOfTypeIntegerArray(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeIntegerArray(apRootObject, asPropertyName)
endFunction

float[] function Global_GetPropertyOfTypeFloatArray(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeFloatArray(apRootObject, asPropertyName)
endFunction

string[] function Global_GetPropertyOfTypeStringArray(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeStringArray(apRootObject, asPropertyName)
endFunction

Form[] function Global_GetPropertyOfTypeFormArray(int apRootObject, string asPropertyName) global
    return RPB_Data.GetPropertyOfTypeFormArray(apRootObject, asPropertyName)
endFunction

; ==========================================================

function ImprisonActorImmediately(Actor akActor)
    FunctionNotImplemented("Prisoner::ImprisonActorImmediately")
endFunction

; ==========================================================
;                          private
; ==========================================================

; State for Infamy Messages
bool __infamyRecognizedThresholdMsgSent
bool __infamyKnownThresholdMsgSent

; ==========================================================
;                            Debug
; ==========================================================

function DEBUG_ShowPrisonerSentenceInfo(RPB_Prisoner apPrisoner, bool abShort = false)
    string sentenceFormatted    = self.GetSentenceFormatted(apPrisoner)
    string timeServedFormatted  = self.GetTimeServedFormatted(apPrisoner)
    string timeLeftFormatted    = self.GetTimeLeftOfSentenceFormatted(apPrisoner)

    if (abShort)
        LogNoType(apPrisoner.GetName() + " in " + self.Name + " ("+ apPrisoner.JailCell.ID +"): { "+ "Sentence: " + string_if (!apPrisoner.IsUndeterminedSentence, sentenceFormatted, "Not Available") + " | Time Served: " + timeServedFormatted + string_if (!apPrisoner.IsUndeterminedSentence, " | Time Left: " + timeLeftFormatted) +" }")
    else
        string minSentence = RPB_Utility.GetTimeFormatted(MinimumSentence)
        string maxSentence = RPB_Utility.GetTimeFormatted(MaximumSentence)

        LogNoType("\n" + "Prisoner in "+ self.Name + " ("+ apPrisoner.JailCell.ID +")" +": { \n\t" + \
            "Prisoner: "            + "(Name: " + apPrisoner.GetName() + ", Prisoner Reference: " + apPrisoner +  ", Actor Reference: " + apPrisoner.GetActor() + ")" + ", \n\t" + \
            "Minimum Sentence: "    + MinimumSentence + " Days" + " ("+ minSentence +"), \n\t" + \
            "Maximum Sentence: "    + MaximumSentence + " Days" + " ("+ maxSentence +"), \n\t" + \
            "Sentence: "            + string_if (!apPrisoner.IsUndeterminedSentence, apPrisoner.Sentence + " Days" + " ("+ sentenceFormatted +")", "Not Available") + ", \n\t" + \
            "Time of Arrest: "      + string_if (apPrisoner.TimeOfArrest, apPrisoner.TimeOfArrest, "None") + ", \n\t" + \
            "Time of Imprisonment: "+ string_if (apPrisoner.TimeOfImprisonment, apPrisoner.TimeOfImprisonment, "None") + ", \n\t" + \
            "Time Served: "         + apPrisoner.TimeServed + " ("+ timeServedFormatted +"), \n\t" + \
            "Time Left: "           + string_if (!apPrisoner.IsUndeterminedSentence, apPrisoner.TimeLeftInSentence + " ("+ timeLeftFormatted + ")", "Not Available") + ", \n\t" + \
            "Release Time: "        + string_if (!apPrisoner.IsUndeterminedSentence, apPrisoner.ReleaseTime + " ("+ timeLeftFormatted +" from now)", "Never") + "\n\t" + \
        " }")
    endif
endFunction

;/
    Settings snapshot: this Prison's MCM settings as they are right now, read once and reused for every prisoner
    (each prisoner gets a COPY, so already-imprisoned actors keep the values they were locked with). Stale when the
    MCM's settings version changed since it was built (see RPB_MCM.GetSettingsVersion()).
/;
int __settingsSnapshot
int __settingsSnapshotVersion = -1
int __settingsSnapshotBuilds

; How many times the snapshot was (re)built, for tests and diagnostics
int property SettingsSnapshotBuilds
    int function get()
        return __settingsSnapshotBuilds
    endFunction
endProperty

;/
    returns (int): A FastMap with the Prison's current settings, built or rebuilt when stale.
                   Read only for callers: copy it (ActorBase.SetPairs), never edit it.
/;
int function GetSettingsSnapshot()
    int version = Config.MCM.GetSettingsVersion(Hold)

    if (__settingsSnapshot && __settingsSnapshotVersion == version)
        return __settingsSnapshot
    endif

    if (!__settingsSnapshot)
        __settingsSnapshot = FastMap("<string>", retain = true)
    else
        FastMap_Clear(__settingsSnapshot)
    endif

    self.__BuildSettingsSnapshot(__settingsSnapshot)
    __settingsSnapshotVersion = version
    __settingsSnapshotBuilds += 1

    ; Provenance, copied into every prisoner locked from this snapshot (not settings; tests and debugging read them)
    FastMap_SetInt(__settingsSnapshot, "Settings Snapshot Build", __settingsSnapshotBuilds)
    FastMap_SetInt(__settingsSnapshot, "Settings Snapshot Version", version)

    return __settingsSnapshot
endFunction

;/
    Marks the settings snapshot stale, so the next GetSettingsSnapshot() rebuilds it.
/;
function InvalidateSettingsSnapshot()
    __settingsSnapshotVersion = -1
endFunction

;/
    Writes every setting a prisoner locks into @apMap (same keys and value types RPB_Prisoner writes).
/;
function __BuildSettingsSnapshot(int apMap)
    ; Infamy
    FastMap_SetInt(apMap, "Infamy Enabled", EnableInfamy as int)
    FastMap_SetFloat(apMap, "Infamy Recognized Threshold", InfamyRecognizedThreshold)
    FastMap_SetFloat(apMap, "Infamy Known Threshold", InfamyKnownThreshold)
    FastMap_SetFloat(apMap, "Infamy Gained Daily from Current Bounty", InfamyGainedDailyOfCurrentBounty)
    FastMap_SetFloat(apMap, "Infamy Gained Daily", InfamyGainedDaily)
    FastMap_SetFloat(apMap, "Infamy Gain Modifier (Recognized)", InfamyGainModifierRecognized)
    FastMap_SetFloat(apMap, "Infamy Gain Modifier (Known)", InfamyGainModifierKnown)
    ; Frisking
    FastMap_SetInt(apMap, "Allow Frisking", AllowFrisking as int)
    FastMap_SetInt(apMap, "Bounty for Frisking", MinimumBountyForFrisking)
    FastMap_SetInt(apMap, "Frisking Thoroughness", FriskingThoroughness)
    FastMap_SetInt(apMap, "Confiscate Stolen Items", ConfiscateStolenItemsOnFrisk as int)
    FastMap_SetInt(apMap, "Strip if Stolen Items Found", StripIfStolenItemsFoundOnFrisk as int)
    FastMap_SetInt(apMap, "Minimum Number of Stolen Items Required", MinimumNumberOfStolenItemsRequiredToStripOnFrisk)
    ; Stripping
    FastMap_SetInt(apMap, "Allow Stripping", AllowStripping as int)
    FastMap_SetString(apMap, "Handle Stripping On", HandleStrippingOn)
    FastMap_SetInt(apMap, "Bounty to Strip", MinimumBountyToStrip)
    FastMap_SetInt(apMap, "Violent Bounty to Strip", MinimumViolentBountyToStrip)
    FastMap_SetInt(apMap, "Sentence to Strip", MinimumSentenceToStrip)
    FastMap_SetInt(apMap, "Stripping Thoroughness", StrippingThoroughness)
    FastMap_SetInt(apMap, "Stripping Thoroughness Modifier", StrippingThoroughnessModifier)
    ; Clothing
    FastMap_SetInt(apMap, "Allow Clothing", AllowClothing as int)
    FastMap_SetString(apMap, "Handle Clothing On", HandleClothingOn)
    FastMap_SetInt(apMap, "Maximum Bounty to Clothe", MaximumBountyClothing)
    FastMap_SetInt(apMap, "Maximum Violent Bounty to Clothe", MaximumViolentBountyClothing)
    FastMap_SetInt(apMap, "Maximum Sentence to Clothe", MaximumSentenceClothing)
    FastMap_SetInt(apMap, "Clothe when Defeated", ClotheWhenDefeated as int)
    FastMap_SetString(apMap, "Outfit", ClothingOutfit)
    FastMap_SetInt(apMap, "Use Default Outfit as Fallback", UseDefaultOutfitAsFallback as int)
    ; Prison
    FastMap_SetInt(apMap, "Bounty Exchange", BountyExchange)
    FastMap_SetInt(apMap, "Bounty to Sentence", BountyToSentence)
    FastMap_SetInt(apMap, "Minimum Sentence", MinimumSentence)
    FastMap_SetInt(apMap, "Maximum Sentence", MaximumSentence)
    FastMap_SetFloat(apMap, "Cell Search Thoroughness", CellSearchThoroughness)
    FastMap_SetString(apMap, "Cell Lock Level", CellLockLevel)
    FastMap_SetInt(apMap, "Fast Forward", FastForward as int)
    FastMap_SetFloat(apMap, "Day to Fast Forward From", DayToFastForwardFrom)
    FastMap_SetString(apMap, "Handle Skill Loss", HandleSkillLoss)
    FastMap_SetInt(apMap, "Day to Start Losing Skills (Stat)", DayToStartLosingSkillsStat)
    FastMap_SetInt(apMap, "Day to Start Losing Skills (Perk)", DayToStartLosingSkillsPerk)
    FastMap_SetInt(apMap, "Chance to Lose Skills (Stat)", ChanceToLoseSkillsStat)
    FastMap_SetInt(apMap, "Chance to Lose Skills (Perk)", ChanceToLoseSkillsPerk)
    FastMap_SetFloat(apMap, "Recognized Criminal Penalty", RecognizedCriminalPenalty)
    FastMap_SetFloat(apMap, "Known Criminal Penalty", KnownCriminalPenalty)
    FastMap_SetFloat(apMap, "Bounty to Trigger Infamy", MinimumBountyToTriggerCriminalPenalty)
    ; Release
    FastMap_SetInt(apMap, "Release Fees Enabled", EnableReleaseFees as int)
    FastMap_SetFloat(apMap, "Chance for Release Fees Event", ReleaseFeesChanceForEvent)
    FastMap_SetFloat(apMap, "Bounty to Owe Fees", MinimumBountyToOweReleaseFees)
    FastMap_SetFloat(apMap, "Release Fees from Arrest Bounty", ReleaseFeesOfCurrentBounty)
    FastMap_SetFloat(apMap, "Release Fees Flat", ReleaseFees)
    FastMap_SetFloat(apMap, "Days Given to Pay Release Fees", DaysGivenToPayReleaseFees)
    FastMap_SetInt(apMap, "Enable Item Retention", EnableItemRetention as int)
    FastMap_SetInt(apMap, "Minimum Bounty to Retain Items", MinimumBountyToRetainItems)
    FastMap_SetInt(apMap, "Auto Redress on Release", AutoRedressOnRelease as int)
    ; Escape
    FastMap_SetString(apMap, "Handle Escape On", HandleEscapeOn)
    FastMap_SetInt(apMap, "Escape Bounty", EscapeBounty)
    FastMap_SetFloat(apMap, "Escape Bounty of Current Bounty", EscapeBountyOfCurrentBounty)
    FastMap_SetFloat(apMap, "Escape Bounty (Sentence)", EscapeBountySentenceMultiplier)
    FastMap_SetFloat(apMap, "Escape Bounty (Sentence Days)", EscapeBountySentenceDays)
    FastMap_SetInt(apMap, "Escape Bounty (Bounty Condition)", EscapeBountyCondition)
    FastMap_SetInt(apMap, "Escape Bounty (Sentence Condition)", EscapeBountySentenceCondition)
    FastMap_SetInt(apMap, "Fallback Bounty", EscapeBountyFallbackBounty)
    FastMap_SetInt(apMap, "Account for Time Served", AccountForTimeServedOnEscape as int)
    FastMap_SetInt(apMap, "Frisk upon Captured", FriskUponCapturedOnEscape as int)
    FastMap_SetInt(apMap, "Strip upon Captured", StripUponCapturedOnEscape as int)
    ; Outfit
    FastMap_SetString(apMap, "Outfit::Name", OutfitName)
    FastMap_SetForm(apMap, "Outfit::Head", OutfitPartHead)
    FastMap_SetForm(apMap, "Outfit::Body", OutfitPartBody)
    FastMap_SetForm(apMap, "Outfit::Hands", OutfitPartHands)
    FastMap_SetForm(apMap, "Outfit::Feet", OutfitPartFeet)
    FastMap_SetInt(apMap, "Outfit::Conditional", IsOutfitConditional as int)
    FastMap_SetInt(apMap, "Outfit::Minimum Bounty", OutfitMinimumBounty)
    FastMap_SetInt(apMap, "Outfit::Maximum Bounty", OutfitMaximumBounty)
endFunction
