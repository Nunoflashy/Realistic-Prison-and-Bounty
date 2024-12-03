scriptname RPB_Prison extends RPB_Entity  
{
    @property int ID
    @property string UUID
    @property string Name
    @property bool Active

    @property Location PrisonLocation
    @property Faction PrisonFaction
    @property string Hold
    @property string City
    @property RPB_PrisonerList Prisoners
    @property Form[] JailCells
    @property Form[] EmptyJailCells
    @property Form[] AvailableJailCells
    @property Form[] FemaleJailCells
    @property Form[] MaleJailCells
}

;/
@functions:
    bool function HasFemaleOnlyCells()
    bool function HasMaleOnlyCells()
    int function GetRandomSentence(int aiMinSentence, int aiMaxSentence)
    int function GetCurrentLowestSentence()
    int function GetCurrentHighestSentence()
    Form[] function GetJailCells()
    Form[] function GetEmptyJailCells()
    Form[] function GetOccupiedJailCells()
    Form[] function GetAvailableJailCells()
    RPB_JailCell[] function GetCellsWithFemalePrisoners()
    RPB_JailCell[] function GetCellsWithMalePrisoners()
    RPB_JailCell[] function GetCellsWithMixedPrisoners()
    RPB_JailCell function GetCellByID(string asCellIdentifier)
    RPB_JailCell function GetGenderExclusiveCell(string asGender, bool abCanBeEmpty = true, bool abCanBeOvercrowded = false)
    RPB_JailCell function RequestCell(RPB_Prisoner apPrisoner)
    Form[] function GetEscortLocations()
    ObjectReference function GetRandomEscortLocation()
    bool function ShouldPrisonerBeInGenderExclusiveCell(RPB_Prisoner apPrisoner)
    bool function IsPrisoner(RPB_Prisoner apPrisoner)
    bool function HasPrisoners(RPB_JailCell akPrisonCell = none)
    bool function HasFemalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyFemales = false)
    bool function HasMalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyMales = false)
    bool function HasPrisonersOfGender(RPB_JailCell akPrisonCell = none, string asGender, bool abOnlySpecifiedGender = false)
    bool function HasCellMates(RPB_Prisoner apPrisoner)
    RPB_Prisoner[] function GetPrisoners(RPB_JailCell akPrisonCell = none)
    RPB_Prisoner[] function GetFemalePrisoners(RPB_JailCell akPrisonCell = none)
    RPB_Prisoner[] function GetMalePrisoners(RPB_JailCell akPrisonCell = none)
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
    function TeleportPrisonerToRelease(RPB_Prisoner apPrisoner)
    function EscortPrisonerToRelease(RPB_Prisoner apPrisoner)
    bool function SendReleaseRequest(RPB_Prisoner apPrisoner)
    function TriggerEscape(RPB_Prisoner apPrisoner)
    function SendEscortPrisonerToCellRequest(RPB_Prisoner apPrisoner)
    function SendEscortPrisonerFromCellRequest(RPB_Prisoner apPrisoner, ObjectReference akDestination)
    function AssignBelongingsContainer(RPB_Prisoner apPrisoner)
    function AssignReleaseLocation(RPB_Prisoner apPrisoner, bool abIsTeleportLocation = true)
    bool function AssignCell(RPB_Prisoner apPrisoner)
    function RemoveFromCell(RPB_Prisoner apPrisoner)
    function ClearPrisonerBounty(RPB_Actor apActor)
    bool function AssignPrisonerToCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    function EscortPrisonerToJail(RPB_Prisoner apPrisoner, Actor akEscort)
    function EscortPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
    function EscortPrisonerFromJail(RPB_Prisoner apPrisoner, Actor akEscort)
    function EscortPrisonerFromCell(RPB_Prisoner apPrisoner, Actor akEscort)
    function StartRestrainingPrisoner(RPB_Prisoner apPrisoner, Actor akRestrainer)
    function StartFriskingPrisoner(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    function StartStrippingPrisoner(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    function StartGivingPrisonerClothing(RPB_Prisoner apPrisoner, Actor akSearcherGuard)
    Form[] function GetReleaseMarkers(string asReleaseMarkerType = "Teleport")
    Form[] function GetSearchMarkers(string asSearchType = "Frisking")
    Form function GetRandomSearchMarker(string asSearchType = "Frisking")
    Form function GetRandomReleaseMarker(string asReleaseMarkerType = "Teleport")
    Form[] function GetPrisonerContainers(string asPrisonerContainerType = "Belongings")
    Form function GetRandomPrisonerContainer(string asPrisonerContainerType = "Belongings")
    Form function GetPrisonerContainerLinkedWithOppositeType(Form akOppositeTypePrisonerContainer, string asPrisonerContainerType)
    Form[] function GetGenderExclusiveCells(string asGender, bool abAvailable = true, bool abCanBeOvercrowded = false)
    RPB_JailCell function GetRandomJailCell(bool abPrioritizeEmptyCells = true)
    RPB_JailCell function GetRandomAvailableJailCell(bool abPrioritizeEmptyCells = true)
    RPB_JailCell function GetEmptyJailCell()
    RPB_JailCell function GetJailCellOfGender(string asSex, bool abAvailable = true, bool abCanBeOvercrowded = false)
    RPB_JailCell function GetFemaleJailCell()
    RPB_JailCell function GetMaleJailCell()
    bool function RegisterPrisoner(RPB_Prisoner apPrisoner)
    function AssignPrisonerNumber(RPB_Prisoner apPrisoner)
    function RegisterPrisonerLastJailedStats(RPB_Prisoner apPrisoner)
    function RegisterPrisonerReleaseTimeStats(RPB_Prisoner apPrisoner)
    function RegisterPrisonerEscapeTimeStats(RPB_Prisoner apPrisoner)
    function UnregisterPrisoner(RPB_Prisoner apPrisoner)
    RPB_Prisoner function GetPrisonerReference(Actor akPrisoner)

@events:
    event OnPrisonerImprisonmentFail(RPB_Prisoner apPrisoner, string reason)
    event OnPrisonerRegistered(RPB_Prisoner apPrisoner)
    event OnPrisonerUnregistered(RPB_Prisoner apPrisoner)
    event OnPrisonerReleased(RPB_Prisoner apPrisoner)
    event OnPrisonerEscaped(RPB_Prisoner apPrisoner)
    event OnPrisonerTeleportedToPrison(RPB_Prisoner apPrisoner)
    event OnPrisonerTeleportedToCell(RPB_Prisoner apPrisoner, bool abImprisonPrisoner)
    event OnPrisonerDying(RPB_Prisoner apPrisoner, Actor akKiller)
    event OnPrisonerDeath(RPB_Prisoner apPrisoner, Actor akKiller)
    event OnEscortPrisonerToJailBegin(RPB_Actor apActor, Actor akEscort)
    event OnEscortPrisonerToJailEnd(RPB_Actor apActor, Actor akEscort)
    event OnEscortPrisonerToCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnEscortingPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnEscortPrisonerToCellEnd(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell, Actor akEscort)
    event OnEscortPrisonerFromCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnEscortPrisonerFromCellEnd(RPB_Prisoner apPrisoner, Actor akEscort)
    event OnPrisonerStripBegin(RPB_Prisoner apPrisoner, Actor akStripper)
    event OnPrisonerStripping(RPB_Prisoner apPrisoner, Actor akStripper, string asSceneEvent)
    event OnPrisonerStripEnd(RPB_Prisoner apPrisoner, Actor akStripper)
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

RPB_Config property Config
    RPB_Config function get()
        return API.Config
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

Faction property PrisonFaction
    Faction function get()
        return self.GetLocalPropertyOfTypeForm("Crime Faction") as Faction
    endFunction
endProperty

string property Hold
    string function get()
        return self.GetLocalPropertyOfTypeString("Hold")
    endFunction
endProperty

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

RPB_PrisonerList __prisoners
RPB_PrisonerList property Prisoners
    RPB_PrisonerList function get()
        if (__prisoners)
            return __prisoners
        endif

        __prisoners = ((self as ReferenceAlias) as RPB_ActiveMagicEffectContainer) as RPB_PrisonerList
        ; __prisoners = PrisonManager.GetNthAlias(self.GetID()) as RPB_PrisonerList
        ; LogProperty("Prison::Prisoners", "Initialized with a value of: " + __prisoners)
        ; Debug("["+ Name +"] Prison::Prisoners", "Initialized with a value of: " + __prisoners)
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
    int prisonId = RPB_StorageVars.GetIntOnForm("Last Jailed - Prison", akCrimeFaction)
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
RPB_Prisoner function AwaitPrisonerReference(Actor akPrisoner, int aiMaxTries = 50, float afInitialTimeBetweenTries = 0.1, float afMaxTimeBetweenTries = 3.0)
    ; RPB_StorageVars.SetBoolOnForm("Is Initialized", akPrisoner, true, "Actor")
    return (RPB_Utility.AwaitEntityReference(akPrisoner, Prisoners, self, aiMaxTries, afInitialTimeBetweenTries, afMaxTimeBetweenTries) as RPB_Prisoner).Initialize()
endFunction

RPB_Prisoner function GetPrisoner(Actor akPrisoner, int aiMaxTries = 50, float afInitialTimeBetweenTries = 0.1, float afMaxTimeBetweenTries = 3.0)
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

int function GetCurrentLowestSentence()
    FunctionNotImplemented("Prison::GetCurrentLowestSentence")
endFunction

int function GetCurrentHighestSentence()
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
; Form[] function GetJailCells()
;     return RPB_Data.QueryFormArray(self.Children("Cells"), "*", "{ 'active': true }")
; endFunction

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

    returns (Form[]); The jail cells that are currently available to take more prisoners.
/;
Form[] function GetAvailableJailCells()
    Form[] cells = self.GetJailCells()
    int availableCellsArray = JArray.object()

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCellRef = cells[i] as RPB_JailCell

        if (jailCellRef && jailCellRef.IsAvailable)
            ; Debug("Prison::GetAvailableJailCells", "Cell: " + jailCellRef + ", IsAvailable: " + jailCellRef.IsAvailable + ", Gender: " + jailCellRef.IsGenderExclusive)
            JArray.addForm(availableCellsArray, jailCellRef)
        endif
        i += 1
    endWhile

    if (JValue.count(availableCellsArray) <= 0)
        return none
    endif

    return JArray.asFormArray(availableCellsArray)
endFunction

RPB_JailCell[] function GetCellsWithFemalePrisoners()
    ; Iterate through all the cells in the prison
    ; Get each prisoner from each cell
    ; Determine the sex of the prisoner
    ; Store the prisoner's gender, or just a bool determining if it's female or male and set to true
    ; If all the prisoners are the same sex, this cell only has female prisoners
endFunction

RPB_JailCell[] function GetCellsWithMalePrisoners()
    ; Iterate through all the cells in the prison
    ; Get each prisoner from each cell
    ; Determine the sex of the prisoner
    ; Store the prisoner's gender, or just a bool determining if it's female or male and set to true
    ; If all the prisoners are the same sex, this cell only has male prisoners
endFunction

RPB_JailCell[] function GetCellsWithMixedPrisoners()
    ; Iterate through all the cells in the prison
    ; Get each prisoner from each cell
    ; Determine the sex of the prisoner
    ; Store the prisoner's gender, or just a bool determining if it's female or male and set to true
    ; If all the prisoners are not the same sex, this cell has both male and female prisoners
endFunction

RPB_JailCell function GetCellByID(string asCellIdentifier)
    ; return self.FindPropertyOfTypeForm("Cells//*", 
    ;     "[active: true]," + \ 
    ;     "[id: "+ asCellIdentifier +"]" \ 
    ; )
    return RPB_Data.Jail_GetJailCellByID(self.GetDataObject(), asCellIdentifier)
endFunction

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

; Test function for requesting cell (WIP)
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

        if (returnedCell.IsGenderExclusive || (!returnedCell.IsGenderExclusive && prisonerMustBeInGenderExclusiveCell))
            returnedCell = none
        endif
    endif

    return returnedCell
endFunction

Form[] function GetEscortLocations()
    return self.GetPropertyOfTypeFormArray("Markers//Jail//Escort")
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

        if ((!abCanBeOvercrowded && !jailCellRef.IsFull) || abCanBeOvercrowded)
            if (jailCellRef && isGenderExclusive)
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
    if (escortLocations == none)
        return none
    endif

    return escortLocations[Utility.RandomInt(0, escortLocations.Length - 1)] as ObjectReference
endFunction

Form function GetRandomSearchMarker(string asSearchType = "Frisking")
    Form[] markers = self.GetSearchMarkers(asSearchType)
    return markers[Utility.RandomInt(0, markers.Length - 1)]
endFunction

Form function GetRandomReleaseMarker(string asReleaseMarkerType = "Teleport")
    Form[] allReleaseMarkersOfType = self.GetReleaseMarkers(asReleaseMarkerType)
    return allReleaseMarkersOfType[Utility.RandomInt(0, allReleaseMarkersOfType.Length - 1)]
endFunction

Form function GetRandomPrisonerContainer(string asPrisonerContainerType = "Belongings")
    Form[] allPrisonerContainers = self.GetPrisonerContainers(asPrisonerContainerType)
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

    int prisonerContainersObj = self.GetDataObject("Prisoner Containers") ; JMap&

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
    return emptyCells[Utility.RandomInt(0, emptyCells.Length - 1)] as RPB_JailCell
endFunction

;/
    bool    @abAvailable: Whether to only include available cells
    bool    @abCanBeOvercrowded: Whether to include cells that can be overcrowded
/;
RPB_JailCell function GetJailCellOfGender(string asSex, bool abAvailable = true, bool abCanBeOvercrowded = false)
    Form[] genderCells = self.GetGenderExclusiveCells(asSex, abAvailable, abCanBeOvercrowded)
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
bool function RegisterPrisoner(RPB_Prisoner apPrisoner)
    if (self.IsPrisoner(apPrisoner))
        return false
    endif
    
    Prisoners.Add(apPrisoner)
    self.OnPrisonerRegistered(apPrisoner)
    self.AssignPrisonerNumber(apPrisoner)
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


;/
    Binds this Prisoner to their cell (it must already be assigned),
    this is used to make NPC's "stick" to the cell, and not wander around
    or execute their usual AI packages.

    Several AI Packages are available to bind the prisoners, their use
    should depend on the size of the cell, as to not allow them to get out
    and not constrain them to a very small area either.

    Packages should be: XS, S, M, L, and XL.

    RPB_Prisoner    @apPrisoner: The prisoner to bind to the cell.
    string          @asPackageSize: The size of the AI cell package to apply.

    returns (ReferenceAlias): The reference alias that binds this AI Package.
/;
ReferenceAlias function BindPrisonerToCell(RPB_Prisoner apPrisoner, string asPackageSize)
    ; Make sure the prisoner is inside the cell before applying the AI Package (Wander in Cell),
    ; since the package's location is set to be the same point at the time of application 
    ; so the prisoner must be in the cell, in order to remain there.
    ReferenceAlias cellPackage = PrisonManager.GetCellPackageOfType(asPackageSize)

    apPrisoner.MoveTo(apPrisoner.JailCell)
    Debug("Prison::BindPrisonerToCell", "Cell [X,Y,Z]: " + "[" + apPrisoner.JailCell.X + "," + apPrisoner.JailCell.Y + "," + apPrisoner.JailCell.Z + "]")
    Debug("Prison::BindPrisonerToCell", "Prisoner [X,Y,Z]: " + "[" + apPrisoner.this.X + "," + apPrisoner.this.Y + "," + apPrisoner.this.Z + "]")
    apPrisoner.DisableAI()
    
    apPrisoner.BindAlias(cellPackage)
    apPrisoner.EnableAI()

    return cellPackage
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

bool function HasPrisoners(RPB_JailCell akPrisonCell = none)
    if (akPrisonCell)
        return akPrisonCell.HasPrisoners
    endif

    return Prisoners.Count > 0
endFunction

bool function HasFemalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyFemales = false)

endFunction

bool function HasMalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyMales = false)

endFunction

bool function HasPrisonersOfGender(RPB_JailCell akPrisonCell = none, string asGender, bool abOnlySpecifiedGender = false)

endFunction

bool function HasCellMates(RPB_Prisoner apPrisoner)
    RPB_JailCell jailCell = apPrisoner.JailCell

    if (jailCell == none)
        return false
    endif

    return jailCell.PrisonerCount > 1
endFunction


;                     Prisoner - Getters
; ==========================================================

RPB_Prisoner[] function GetPrisoners(RPB_JailCell akPrisonCell = none)

endFunction

RPB_Prisoner[] function GetFemalePrisoners(RPB_JailCell akPrisonCell = none)

endFunction

RPB_Prisoner[] function GetMalePrisoners(RPB_JailCell akPrisonCell = none)
    
endFunction

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
    return RPB_Utility.GetTimeFormatted(apPrisoner.TimeLeftInSentence, asNullValue = "None")
endFunction

string function GetSentenceFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.Sentence, asNullValue = "None")
endFunction

string function GetCriminalPenaltySentenceFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.CriminalPenaltySentence, asNullValue = "None")
endFunction

string function GetTimeServedFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.TimeServed, asNullValue = "None")
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
    Form cuffs = Game.GetFormEx(0xA081D2F)
    if (abRestrainInFront)
        cuffs = Game.GetFormEx(0xA081D33)
    endif

    apPrisoner.GetActor().SheatheWeapon()
    UnequipHandsForActor(apPrisoner.GetActor())
    apPrisoner.GetActor().EquipItem(cuffs, true, true)
endFunction

function TeleportPrisonerToRelease(RPB_Prisoner apPrisoner)
    apPrisoner.GotoState("Released")
    Debug("["+ Name +"] Prison::TeleportPrisonerToRelease", "Released " + apPrisoner.Name + ".")

    apPrisoner.Remove("Imprisoned")

    apPrisoner.ReturnBelongings()
    apPrisoner.RemoveFromCell()

    if (apPrisoner.TeleportReleaseLocation)
        apPrisoner.EnableAI(apPrisoner.IsNPC())
        apPrisoner.MoveTo(apPrisoner.TeleportReleaseLocation)
    endif

    self.UnregisterPrisoner(apPrisoner)
    self.OnPrisonerReleased(apPrisoner)
endFunction

function EscortPrisonerToRelease(RPB_Prisoner apPrisoner)
    apPrisoner.GotoState("Releasing")

    ObjectReference releaseLocation = self.GetRandomReleaseMarker("Escort") as ObjectReference
    self.SendEscortPrisonerFromCellRequest(apPrisoner, releaseLocation)
endFunction

bool function SendReleaseRequest(RPB_Prisoner apPrisoner)
    Debug("["+ Name +"] Prison::SendReleaseRequest", "Cell Package Applied: " + apPrisoner.CellPackage)

    ; Determine type of release
    if (apPrisoner.IsNPC() && apPrisoner.IsFarFromPlayer())
        apPrisoner.SetBool("Teleport to Release", true)

    else
        apPrisoner.SetBool("Teleport to Release", true)
        ; apPrisoner.SetBool("Escort to Release", true)
    endif

    ; TODO: Maybe add some conditions for instances where the Release request should be denied.

    if (apPrisoner.Should("Teleport to Release"))
        self.TeleportPrisonerToRelease(apPrisoner)

    elseif (apPrisoner.Should("Escort to Release"))
        self.EscortPrisonerToRelease(apPrisoner)
    endif
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
    Debug("Prison::SetBelongingsContainer", "Prisoner Belongings Container:  " + apPrisoner.PrisonerBelongingsContainer)
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

    ; Needs to be refactored, shouldn't be here
    if (apPrisoner.ShouldBeStripped)
        ; Determine if prisoner will be stripped etc (Set options that a cell depend on)
        apPrisoner.WillBeStrippedNaked = true ; Makes the cell gender exclusive
    endif

    RPB_JailCell assignedCell = self.RequestCell(apPrisoner)

    if (assignedCell == none)
        EventManager.SendError("("+ Name +") Prison::AssignCell", "Could not assign a cell for prisoner " + apPrisoner.Name)
        return false
    endif

    self.BindCellToPrisoner(assignedCell, apPrisoner) ; Actually bind this jail cell to the prisoner, it has been assigned.
    return apPrisoner.JailCell != none
endFunction

function RemoveFromCell(RPB_Prisoner apPrisoner)
    RPB_JailCell jailCell = apPrisoner.JailCell

    if (!jailCell)
        EventManager.SendWarning("The prisoner " + apPrisoner.Name + " is not bound to any jail cell!", "["+ Name +"] Prisoner::RemoveFromCell")
        return
    endif
    
    jailCell.RemovePrisoner(apPrisoner)
endFunction

function ClearPrisonerBounty(RPB_Actor apActor)
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
        RPB_StorageVars.DeleteCategoryOnForm(self.PrisonFaction, "PrisonLastReleased")
        RPB_StorageVars.DeleteCategoryOnForm(self.PrisonFaction, "PrisonLastEscaped")

        RPB_StorageVars.SetStringOnForm("Last Jailed - Prison", self.PrisonFaction, self.UUID, "PrisonLastJailed")
        RPB_StorageVars.SetIntOnForm("Last Jailed - Day", self.PrisonFaction, RPB_Utility.GetCurrentDay(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnForm("Last Jailed - Month", self.PrisonFaction, RPB_Utility.GetCurrentMonth(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnForm("Last Jailed - Year", self.PrisonFaction, RPB_Utility.GetCurrentYear(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnForm("Last Jailed - Hour", self.PrisonFaction, RPB_Utility.GetCurrentHour(), "PrisonLastJailed")
        RPB_StorageVars.SetIntOnForm("Last Jailed - Minute", self.PrisonFaction, RPB_Utility.GetCurrentMinute(), "PrisonLastJailed")
        RPB_StorageVars.SetStringOnForm("Last Jailed - Cell", self.PrisonFaction, apPrisoner.JailCell.ID, "PrisonLastJailed")
    endif
endFunction

function RegisterPrisonerReleaseTimeStats(RPB_Prisoner apPrisoner)
    ; Only register for the player, for now
    if (apPrisoner.IsPlayer())
        RPB_StorageVars.SetIntOnForm("Last Released - Prison", self.PrisonFaction, self.ID, "PrisonLastReleased")
        RPB_StorageVars.SetIntOnForm("Last Released - Day", self.PrisonFaction, RPB_Utility.GetCurrentDay(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnForm("Last Released - Month", self.PrisonFaction, RPB_Utility.GetCurrentMonth(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnForm("Last Released - Year", self.PrisonFaction, RPB_Utility.GetCurrentYear(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnForm("Last Released - Hour", self.PrisonFaction, RPB_Utility.GetCurrentHour(), "PrisonLastReleased")
        RPB_StorageVars.SetIntOnForm("Last Released - Minute", self.PrisonFaction, RPB_Utility.GetCurrentMinute(), "PrisonLastReleased")
        RPB_StorageVars.SetStringOnForm("Last Released - Cell", self.PrisonFaction, apPrisoner.JailCell.ID, "PrisonLastReleased")
    endif
endFunction

function RegisterPrisonerEscapeTimeStats(RPB_Prisoner apPrisoner)
    ; Only register for the player, for now
    if (apPrisoner.IsPlayer())
        RPB_StorageVars.SetIntOnForm("Last Escaped - Prison", self.PrisonFaction, self.ID, "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnForm("Last Escaped - Day", self.PrisonFaction, RPB_Utility.GetCurrentDay(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnForm("Last Escaped - Month", self.PrisonFaction, RPB_Utility.GetCurrentMonth(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnForm("Last Escaped - Year", self.PrisonFaction, RPB_Utility.GetCurrentYear(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnForm("Last Escaped - Hour", self.PrisonFaction, RPB_Utility.GetCurrentHour(), "PrisonLastEscaped")
        RPB_StorageVars.SetIntOnForm("Last Escaped - Minute", self.PrisonFaction, RPB_Utility.GetCurrentMinute(), "PrisonLastEscaped")
        RPB_StorageVars.SetStringOnForm("Last Escaped - Cell", self.PrisonFaction, apPrisoner.JailCell.ID, "PrisonLastEscaped")
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

; ==========================================================
; Temp
function AwaitPrisonersRelease()
    ; int prisonersAwaitingRelease = 0

    ; int i = 0
    ; while (i < Prisoners.Count)
    ;     RPB_Prisoner currentPrisoner = Prisoners.AtIndex(i)

    ;     if (currentPrisoner && !currentPrisoner.IsEffectActive)
    ;         prisonersAwaitingRelease += 1
    ;         ; Maybe take into account possible bounty gain and infamy updates

    ;         if (currentPrisoner.IsSentenceServed)
    ;             ; Release Prisoner
    ;             Debug("Prison::AwaitPrisonersRelease", "Released Prisoner:  " + currentPrisoner + currentPrisoner.GetPrisoner())
    ;             currentPrisoner.Release()
    ;             ; checkedPrisoners[i] = none
    ;         else
    ;             int timeServedDays  = currentPrisoner.GetTimeServed("Days")
    ;             int timeLeftDays    = currentPrisoner.GetTimeLeftInSentence("Days")
    ;             ; Debug("Prison::AwaitPrisonersRelease", "Prisoner:  " + currentPrisoner.GetActor() + " has not served their sentence yet ("+ timeServedDays + " days served, " +  timeLeftDays +" days left).")
    ;             ; Debug("Prison::AwaitPrisonersRelease", currentPrisoner + " " + currentPrisoner.GetActor() + " ("+ currentPrisoner.GetSex(true) +")" + " has not served their sentence yet in "+ Hold +".")
    ;         endif
    ;     endif

    ;     currentPrisoner.PerformSanityChecks()

    ;     i += 1
    ; endWhile
    
    ; if (prisonersAwaitingRelease > 0)
    ;     Debug("Prison::AwaitPrisonersRelease", "Awaiting release for " + prisonersAwaitingRelease + " prisoners in " + Hold)
    ; endif
endFunction

function AwaitPrisonersQueuedImprisonment()
    if (isProcessingQueuedPrisonersForImprisonment)
        return
    endif

    int i = 0
    while (i < queuedPrisonersForImprisonment.Length)
        if (queuedPrisonersForImprisonment[i] != none)
            queuedPrisonersForImprisonment[i].Imprison()    ; Imprison this Prisoner
            queuedPrisonersForImprisonment[i] = none        ; Remove from Queue
        endif
        Utility.Wait(0.2)
        i += 1
    endWhile
endFunction

; ==========================================================

; ==========================================================
;                          Events
; ==========================================================

event OnPrisonPeriodicUpdate()
    self.AwaitPrisonersQueuedImprisonment() ; Delayed Imprisonment for registered Prisoners
    self.AwaitPrisonersRelease()            ; Keep checking for Prisoners to Release

    ; Get all jail cells
    ; Show relevant info from each
    int i = 0
    Form[] cells = self.GetJailCells()
    while (i < cells.Length)
        RPB_JailCell theCell = cells[i] as RPB_JailCell
        string debugInfo = theCell.DEBUG_GetCellProperties()
        ; Debug("Prison::OnPrisonPeriodicUpdate", "Cell " + theCell + ": " + debugInfo)
        i += 1
    endWhile

    Debug("Prison::OnPrisonPeriodicUpdate", "Prisoners in " + Hold + ": " + Prisoners.Count)

    ; ; TODO: If all the prisoners do not require processing anymore, unregister the update here

    ; Debug("Prison::OnPrisonPeriodicUpdate", "Prisoners in " + Hold + ": " + prisonerCount)
endEvent

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

        self.UnregisterPrisoner(apPrisoner)
    endif
endEvent

event OnPrisonerRegistered(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerLastJailedStats(apPrisoner)
    PrisonManager.OnPrisonRegisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerUnregistered(RPB_Prisoner apPrisoner)
    PrisonManager.OnPrisonUnregisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerReleased(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerReleaseTimeStats(apPrisoner)
    self.ClearPrisonerBounty(apPrisoner)

    apPrisoner.Destroy()
endEvent

event OnPrisonerEscaped(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerEscapeTimeStats(apPrisoner)
    apPrisoner.SetAttackActorOnSight()
    apPrisoner.SetEscapePenalty()
    apPrisoner.RestoreBounty()
    apPrisoner.DEBUG_ShowHoldStats()

    apPrisoner.OnEscaped()
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

    if (!apPrisoner.PrisonerBelongingsContainer)
        self.AssignBelongingsContainer(apPrisoner)
    endif

    if (apPrisoner.ShouldBeFrisked)
        apPrisoner.Frisk()
    endif

    if (apPrisoner.ShouldBeStripped)
        apPrisoner.Strip(abRemoveUnderwear = apPrisoner.WillBeStrippedNaked)

    elseif (apPrisoner.ShouldBeStrippedSilently)
        apPrisoner.StripSilently()
    endif


    ; Debug("("+ Name +") Prisoner::OnTeleportedToCell", "ShouldBeStripped: " + ShouldBeStripped)
    ; Debug("("+ Name +") Prisoner::OnTeleportedToCell", "ShouldBeClothed: " + ShouldBeClothed)

    if (apPrisoner.ShouldBeClothed)
        apPrisoner.DetermineClothingOutfit()
        apPrisoner.Clothe()
    endif

    if (abImprisonPrisoner)
        ; To be removed, this monitoring should be done automatically by Prison (maybe PrisonMonitor which has the Prison as a member)
        if (self.IsPrisonerQueuedForImprisonment(apPrisoner))
            self.RegisterForQueuedImprisonment()
        else
            apPrisoner.Imprison()
        endif
    endif

    apPrisoner.SetBool("Should Be In Cell", true)
    apPrisoner.OnTeleportedToCell(abImprisonPrisoner)
endEvent

event OnPrisonerDying(RPB_Prisoner apPrisoner, Actor akKiller)
    
endEvent

event OnPrisonerDeath(RPB_Prisoner apPrisoner, Actor akKiller)

endEvent

event OnEscortPrisonerToJailBegin(RPB_Actor apActor, Actor akEscort)
    RPB_Prisoner prisonerRef = RPB_Utility.ame_if (apActor as RPB_Prisoner, apActor, (apActor as RPB_Arrestee).MakePrisoner()) as RPB_Prisoner

    EventNotImplemented("Prison::OnEscortPrisonerToJailBegin")
    prisonerRef.OnEscortToPrison(akEscort)
endEvent

; TODO: Possibly rename this to OnEscortedPrisonerToPrison
event OnEscortPrisonerToJailEnd(RPB_Actor apActor, Actor akEscort)
    ; Retrieve or make the Actor a Prisoner
    RPB_Prisoner prisonerRef = RPB_Utility.ame_if (apActor as RPB_Prisoner, apActor, (apActor as RPB_Arrestee).MakePrisoner()) as RPB_Prisoner

    self.AssignReleaseLocation(prisonerRef)    ; Set the teleport release location for this prisoner

    if (!prisonerRef.PrisonerBelongingsContainer)
        self.AssignBelongingsContainer(prisonerRef) ; Set the container of where the prisoner's items will be confiscated to
    endif

    if (!prisonerRef.JailCell)
        self.AssignCell(prisonerRef) ; Assign a prison cell to this prisoner
    endif

    ; TODO: Review if a prisoner should be both frisked and stripped, or only stripped if they were going to be stripped
    if (prisonerRef.ShouldBeStripped)
        self.StartStrippingPrisoner(prisonerRef, akEscort)

    elseif (prisonerRef.ShouldBeFrisked)
        self.StartFriskingPrisoner(prisonerRef, akEscort)
    endif

    if (prisonerRef.Should("Go to Cell"))
        ; Need to check if the prisoner is not in the cell later, IsInCell doesn't work as it should
        self.EscortPrisonerToCell(prisonerRef, akEscort)
    endif

    prisonerRef.OnEscortedToPrison(akEscort)
endEvent

; TODO: Possibly rename this to OnEscortPrisonerToPrison
event OnEscortPrisonerToCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerToCellBegin", "Escape"))
        ; Process escort to cell after escape
    endif

    EventNotImplemented("Prison::OnEscortPrisonerToCellBegin")
    apPrisoner.OnEscortToCell(akEscort)
endEvent

event OnEscortingPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
endEvent

; TODO: Remove RPB_JailCell from params. since a Prisoner already has a jail cell assigned to them
event OnEscortPrisonerToCellEnd(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell, Actor akEscort)
    ; TODO: Fix NPC not staying in cell if they are stripped OnEscortToCellEnd
    if (!apPrisoner.IsStripped && apPrisoner.ShouldBeStripped)
        apPrisoner.Strip()
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
        ; Ensures the Prisoner stays in the cell since we update it 10s later after the initial check,
        ; delaying it enough for all actions to finish before the check.
        if (apPrisoner.IsFarFromPlayer())
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
        ; Remove Underwear, prisoner must be unclothed already
        apPrisoner.RemoveUnderwear()
    endif
endEvent

; Happens when a Prisoner has been stripped
event OnPrisonerStripEnd(RPB_Prisoner apPrisoner, Actor akStripper)
    if (apPrisoner.HasSceneState("OnPrisonerStripEnd", "Escort to Cell"))
        ; Process Escorting to Cell
    endif
    if (!apPrisoner.IsInCell)
        ; apPrisoner.StartRestraining(akStripper)
    endif
    ; apPrisoner.EscortToCell(akStripper)
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

    self.UnregisterPrisoner(apPrisoner)
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
;                          Management
; ==========================================================

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


; Temporary, to hold periodically updates prisoners for now
RPB_Prisoner[] checkedPrisoners
int checkedPrisonersIndex

RPB_Prisoner[] property CheckedPrisonersList
    RPB_Prisoner[] function get()
        return checkedPrisoners
    endFunction
endProperty

event OnUpdateGameTime()
    __isReceivingUpdates = true
    __isAwaitingUpdateForGameTime = false
    
    self.OnPrisonPeriodicUpdate()

    RegisterForSingleUpdateGameTime(5.0)
endEvent

bool function BindCellToPrisoner(ObjectReference akJailCell, RPB_Prisoner apPrisoner)
    RPB_JailCell jailCell = (akJailCell as RPB_JailCell)

    ; The bind process with this prison has already happened
    if (!jailCell.IsInitialized())
        ; Binds the jail cell to this Prison
        jailCell.BindPrison(self)
        jailCell.ScanCellDoor()
    endif

    ; Register the prisoner into the cell
    jailCell.RegisterPrisoner(apPrisoner)
    jailCell.DetermineGoodies()

    return true
endFunction

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

; To be refactored into RPB_PrisonMonitor perhaps, along with OnUpdateGameTime() to check for Prisoner releases/escapes
event OnCellAttach()
    self.SetupCells()
    Debug("["+ Name +"] Prison::OnCellAttach", "On Cell Attach Prison")

    float startBench = StartBenchmark()
    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner prisoner = Prisoners.AtIndex(i)
        
        if (prisoner && prisoner.IsNPC())
            self.NPC_UpdateCellIntegrity(prisoner)
            ; self.UpdatePrisonerStrippingAndClothingStates(prisoner) ; temporary
        endif

        ; Debug("["+ Name +"] Prison::OnCellAttach", prisoner.Name + "'s Cell: " + prisoner.JailCell.ID)
        ; Debug("["+ Name +"] Prison::OnCellAttach", prisoner.JailCell.ID + " Prisoners: " + prisoner.JailCell.Prisoners)

        i += 1
    endWhile

    EndBenchmark(startBench, "NPC Cell Integrity Checks")
endEvent


function RegisterForPrisonPeriodicUpdate(RPB_Prisoner akPrisoner)
    ; Debug("Prison::RegisterForPrisonPeriodicUpdate", "Called RegisterForPrisonPeriodicUpdate()")
    ; Add this prisoner to the list of prisoners to check periodically
    if (!akPrisoner.IsEnabledForBackgroundUpdates)
        checkedPrisoners[checkedPrisonersIndex] = akPrisoner
        Debug("Prison::RegisterForPrisonPeriodicUpdate", "Added Prisoner to check for updates: " + checkedPrisoners[checkedPrisonersIndex] + ", index: " + checkedPrisonersIndex)
        checkedPrisonersIndex += 1
        akPrisoner.IsEnabledForBackgroundUpdates = true
    endif

    __isReceivingUpdates = true
    self.RegisterForSingleUpdateGameTime(5.0)
endFunction

;/
    Assigns a number to this Prisoner for this Prison.
/;
function AssignPrisonerNumber(RPB_Prisoner apPrisoner)
    int prisonerCount   = Prisoners.Count
    int assignedNumber  = prisonerCount + 1
    apPrisoner.SetInt("Prisoner Number", assignedNumber)
endFunction


bool __isReceivingUpdates
bool function IsReceivingUpdates()
    return __isReceivingUpdates
endFunction

; =========================================================
;                         Data Config                      
; =========================================================

;/
    Retrieves the Prison's data object.

    string? @asPrisonObjectCategory: The category of object to get from the Prison object (e.g: Cells).

    returns (any& <JContainer>): The reference to the Prison data object, or an object inside the Prison object if a category is specified.
/;
int function GetDataObject(string asPrisonObjectCategory = "null")
    int rootObject      = RPB_Data.GetRootObject(self.Hold)             ; JMap&
    int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject)       ; JMap&
    int returnedObject  = prisonObject

    if (asPrisonObjectCategory != "null")
        returnedObject = JMap.getObj(prisonObject, asPrisonObjectCategory) ; any& <JContainer>
    endif
    
    return returnedObject
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

; ==========================================================
;                            Test
; ==========================================================

bool __isAwaitingUpdateForGameTime
bool property IsAwaitingUpdateForGameTime
    bool function get()
        return __isAwaitingUpdateForGameTime
    endFunction
endProperty


function RegisterForSingleUpdateGameTime(float afInterval)
    parent.RegisterForSingleUpdateGameTime(afInterval)
    __isAwaitingUpdateForGameTime = true
endFunction

RPB_Prisoner[] queuedPrisonersForImprisonment
bool isProcessingQueuedPrisonersForImprisonment
int queuedPrisonerAvailableIndex

bool function IsPrisonerQueuedForImprisonment(RPB_Prisoner akPrisoner)
    ; float startBench = StartBenchmark()
    int i = 0
    while (i < queuedPrisonersForImprisonment.Length)
        if (queuedPrisonersForImprisonment[i] == akPrisoner)
            ; EndBenchmark(startBench, "IsPrisonerQueuedForImprisonment -> returned true")
            return true
        endif
        i += 1
    endWhile
    
    ; EndBenchmark(startBench, "IsPrisonerQueuedForImprisonment -> returned false")
    return false
endFunction

function RegisterForQueuedImprisonment()
    ; Don't process, we are already processing
    if (isProcessingQueuedPrisonersForImprisonment)
        return
    endif

    ; GotoState("ProcessQueuedPrisonersForImprisonment")
    RegisterForSingleUpdateGameTime(0.1)
endFunction

function QueuePrisonerForImprisonment(RPB_Prisoner akPrisoner)
    if (self.IsPrisonerQueuedForImprisonment(akPrisoner))
        return
    endif

    if (!queuedPrisonersForImprisonment)
        queuedPrisonersForImprisonment = new RPB_Prisoner[128]
        queuedPrisonerAvailableIndex = 0
    endif
    ; Debug("Prison::QueuePrisonerForImprisonment", "queuedPrisonersForImprisonment.Length: " + queuedPrisonersForImprisonment.Length)

    queuedPrisonersForImprisonment[queuedPrisonerAvailableIndex] = akPrisoner
    Debug("Prison::QueuePrisonerForImprisonment", "Queued " + queuedPrisonersForImprisonment[queuedPrisonerAvailableIndex] + " for imprisonment.")
    queuedPrisonerAvailableIndex += 1
endFunction

function ProcessImprisonmentForQueuedPrisoners()
    int i = 0
    while (i < queuedPrisonersForImprisonment.Length)
        if (queuedPrisonersForImprisonment[i] != none)
            queuedPrisonersForImprisonment[i].Imprison()    ; Imprison this Prisoner
            queuedPrisonersForImprisonment[i] = none        ; Remove from Queue
        endif
        Utility.Wait(0.2)
        i += 1
    endWhile

    ; Finished processing prisoners
    isProcessingQueuedPrisonersForImprisonment = false
endFunction

function ImprisonActorImmediately(Actor akActor)
    RPB_Prisoner prisonerRef = self.MakePrisoner(akActor)

    if (!prisonerRef.AssignCell())
        Debug(akActor, "Prison::ImprisonActorImmediately", "Could not assign a cell to actor " + akActor)
        return
    endif

    prisonerRef.QueueForImprisonment()
    prisonerRef.MoveToCell()
    prisonerRef.SetSentence(self.GetRandomSentence(0, 75))
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