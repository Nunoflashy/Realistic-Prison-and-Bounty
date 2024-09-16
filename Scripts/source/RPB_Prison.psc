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

import Math
import RPB_Config
import RPB_Utility

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
        return Config.GetClothingOutfit(Hold)
    endFunction
endProperty

;                          Outfit
; ==========================================================

string property OutfitName
    string function get()
        return Config.GetClothingOutfit(Hold)
    endFunction
endProperty

Form property OutfitPartHead
    Form function get()
        return Config.GetOutfitPart(Hold, "Head")
    endFunction
endProperty

Form property OutfitPartBody
    Form function get()
        return Config.GetOutfitPart(Hold, "Body")
    endFunction
endProperty

Form property OutfitPartHands
    Form function get()
        return Config.GetOutfitPart(Hold, "Hands")
    endFunction
endProperty

Form property OutfitPartFeet
    Form function get()
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
;                           Prison
; ==========================================================

Form[] function GetEscortLocations()
    return self.GetPropertyOfTypeFormArray("Markers//Jail//Escort")
endFunction

ObjectReference function GetRandomEscortLocation()
    Form[] escortLocations = self.GetEscortLocations()
    if (escortLocations == none)
        return none
    endif

    return escortLocations[Utility.RandomInt(0, escortLocations.Length - 1)] as ObjectReference
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
        prisoner.BindToCell()
        i += 1
    endWhile
endFunction

function Notify(string asMessage, bool abCondition = true)
    Config.NotifyJail(asMessage, abCondition)
endFunction

RPB_Prison function GetPrisonForHold(string asHold) global
    RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison(asHold)
    return prison
endFunction

; ==========================================================
;                         Prisoners
; ==========================================================

bool function ShouldStripPrisoner(RPB_Prisoner apPrisoner)
    DebugWithArgs("["+ Name +"] Prison::ShouldStripPrisoner", apPrisoner.Name, "Allow Stripping: " + apPrisoner.GetBool("Allow Stripping"))

    if (!apPrisoner.GetBool("Allow Stripping"))
        return false
    endif

    ; TODO: Need to do a silent strip in case the prisoner still has items (but no clothes on, this would be used as an exploit)
    if (apPrisoner.IsNaked())
        return false
    endif

    string strippingHandler = apPrisoner.GetString("Handle Stripping On")

    if (strippingHandler == "Minimum Sentence")
        int sentenceToStrip = apPrisoner.GetInt("Sentence to Strip")
        if (apPrisoner.Sentence >= sentenceToStrip)
            return true
        endif

    elseif (strippingHandler == "Minimum Bounty")
        int minBountyToStrip        = apPrisoner.GetInt("Bounty to Strip")
        int minViolentBountyToStrip = apPrisoner.GetInt("Violent Bounty to Strip")

        if (apPrisoner.Bounty >= minBountyToStrip || apPrisoner.BountyViolent >= minViolentBountyToStrip)
            return true
        endif

    elseif (strippingHandler == "Unconditionally")
        return true
    endif

    return false
endFunction

bool function ShouldClothePrisoner(RPB_Prisoner apPrisoner)
    if (!apPrisoner.GetBool("Allow Clothing"))
        return false
    endif

    ; If the prisoner is neither naked nor in underwear, do not clothe
    if ((!apPrisoner.IsNaked() && !apPrisoner.IsInUnderwear()))
        return false
    endif
    
    string clothingHandler  = apPrisoner.GetString("Handle Clothing On")

    if (clothingHandler == "Maximum Sentence")
        int maxSentence = apPrisoner.GetInt("Maximum Sentence to Clothe")
        if (apPrisoner.Sentence > maxSentence)
            return false
        endif
        
    elseif (clothingHandler == "Maximum Bounty")
        int maxBounty           = apPrisoner.GetInt("Maximum Bounty to Clothe")
        int maxViolentBounty    = apPrisoner.GetInt("Maximum Violent Bounty to Clothe")
        if (apPrisoner.BountyViolent > maxViolentBounty || apPrisoner.Bounty > maxBounty)
            return false
        endif

    elseif (clothingHandler == "Unconditionally")
        return true
    endif

    return true
endFunction

bool function IsPrisoner(RPB_Prisoner apPrisoner)
    return Prisoners.Exists(apPrisoner)
endFunction

function SetSentence(RPB_Prisoner apPrisoner, int aiSentence = 0)
    apPrisoner.SetSentence(aiSentence)
endFunction

int function GetRandomSentence(int aiMinSentence, int aiMaxSentence)
    return Utility.RandomInt( \
        Min(aiMinSentence, self.MinimumSentence) as int, \
        Min(aiMaxSentence, self.MaximumSentence) as int \
    )
endFunction

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

RPB_Prisoner[] function GetPrisoners(RPB_JailCell akPrisonCell = none)

endFunction

RPB_Prisoner[] function GetFemalePrisoners(RPB_JailCell akPrisonCell = none)

endFunction

RPB_Prisoner[] function GetMalePrisoners(RPB_JailCell akPrisonCell = none)
    
endFunction

bool function ReleasePrisoner(RPB_Prisoner apPrisoner)
    ; Temporarily give the prisoner their items back
    apPrisoner.ReturnBelongings()

    ; Teleport to release
    apPrisoner.TeleportToRelease()

    ; Let the cell know the prisoner is leaving
    apPrisoner.RemoveFromCell()
    ; apPrisoner.JailCell.RemovePrisoner(apPrisoner)

    ; Unregister the prisoner from prison
    self.UnregisterPrisoner(apPrisoner)
    
    self.OnPrisonerReleased(apPrisoner)
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

string function GetTimeServedFormatted(RPB_Prisoner apPrisoner)
    return RPB_Utility.GetTimeFormatted(apPrisoner.TimeServed, asNullValue = "None")
endFunction

; ==========================================================
;                         Escape
; ==========================================================

function TriggerEscape(RPB_Prisoner akPrisoner)

endFunction

; ==========================================================
;                          Cell
; ==========================================================

;/
    Retrieves the jail cells configured for this Prison.
    Each element is able to be cast to a RPB_JailCell.

    returns (Form[]); The jail cells for this Prison.
/;

Form[] function GetJailCells()
    return RPB_Data.QueryFormArray(self.Children("Cells"), "*", "{ 'active': true }")
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

bool function HasFemaleOnlyCells()

endFunction

bool function HasMaleOnlyCells()

endFunction

bool function AssignPrisonerToCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    if (!akJailCell.IsAvailable)
        self.OnPrisonerCellAssignFail(apPrisoner, akJailCell)
        return false
    endif

    akJailCell.RegisterPrisoner(apPrisoner)
    return true
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

bool function ShouldPrisonerBeInGenderExclusiveCell(RPB_Prisoner apPrisoner)
    bool strippedNaked      = apPrisoner.WillBeStrippedNaked || apPrisoner.IsStrippedNaked
    bool strippedUnderwear  = apPrisoner.WillBeStrippedToUnderwear || apPrisoner.IsStrippedToUnderwear

    return strippedNaked || strippedUnderwear
endFunction

; ==========================================================

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

event OnPrisonerProcessed(RPB_Prisoner apPrisoner)
    apPrisoner.SetReleaseLocation()
    apPrisoner.SetBelongingsContainer()
    if (!apPrisoner.AssignCell())
        return
    endif

    apPrisoner.StartStripping(apPrisoner.Captor)
endEvent

event OnPrisonerImprisoned(RPB_Prisoner apPrisoner)
    apPrisoner.RegisterTimeOfImprisonment()
    apPrisoner.DetermineReleaseTimeAdditionalHours() ; For Release Time (Minimum, Maximum) intervals
    ; apPrisoner.SetReleaseLocation() ; to be refactored (needs to take into account whether to use Escort or Teleport markers)

    ; if (!apPrisoner.Sentence)
    ;     apPrisoner.SetSentence(abShouldAffectBounty = false)
    ; endif

    apPrisoner.IncrementStat("Times Jailed")
    if (apPrisoner.IsPlayer())
        Game.IncrementStat("Times Jailed") ; Increment the "Times Jailed" in the regular vanilla stat menu.
    endif
endEvent

event OnPrisonerReleased(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerReleaseTimeStats(apPrisoner)
    apPrisoner.Destroy()
endEvent

event OnPrisonerEscaped(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerEscapeTimeStats(apPrisoner)
    apPrisoner.SetAttackActorOnSight()
    apPrisoner.SetEscapePenalty()
    apPrisoner.RestoreBounty()
    apPrisoner.DEBUG_ShowHoldStats()
endEvent

event OnPrisonerTeleportedToPrison(RPB_Prisoner apPrisoner)
    if (!apPrisoner.PrisonerBelongingsContainer)
        apPrisoner.SetBelongingsContainer()
    endif

    if (apPrisoner.ShouldBeFrisked)
        apPrisoner.Frisk()
    endif

    if (apPrisoner.ShouldBeStripped)
        apPrisoner.StartStripping(apPrisoner.Captor)
    endif

    apPrisoner.StartRestraining(apPrisoner.Captor)
    apPrisoner.EscortToCell(apPrisoner.Captor)
endEvent

event OnPrisonerTeleportedToCell(RPB_Prisoner apPrisoner, bool abImprisonPrisoner)
    if (apPrisoner.IsNPC())
        apPrisoner.EnableAI(!apPrisoner.IsFarFromPlayer()) ; Disable AI if not near Player
        apPrisoner.BindToCell()
    endif

    if (!apPrisoner.PrisonerBelongingsContainer)
        apPrisoner.SetBelongingsContainer()
    endif

    if (apPrisoner.ShouldBeFrisked)
        apPrisoner.Frisk()
    endif

    if (apPrisoner.ShouldBeStripped)
        apPrisoner.Strip()
    endif

    if (abImprisonPrisoner)
        if (self.IsPrisonerQueuedForImprisonment(apPrisoner))
            self.RegisterForQueuedImprisonment()
        else
            apPrisoner.Imprison()
        endif
    endif
endEvent

event OnPrisonerDying(RPB_Prisoner apPrisoner, Actor akKiller)
    
endEvent

event OnPrisonerDeath(RPB_Prisoner apPrisoner, Actor akKiller)

endEvent

event OnEscortPrisonerToJailBegin(RPB_Actor apActor, Actor akEscort)
    (apActor as RPB_Arrestee).Cuff()
endEvent

event OnEscortPrisonerToJailEnd(RPB_Actor apActor, Actor akEscort)
    ; Retrieve or make the Actor a Prisoner
    RPB_Prisoner prisonerRef = RPB_Utility.ame_if (apActor as RPB_Prisoner, apActor, (apActor as RPB_Arrestee).MakePrisoner()) as RPB_Prisoner

    prisonerRef.SetReleaseLocation()    ; Set the teleport release location for this prisoner

    if (!prisonerRef.PrisonerBelongingsContainer)
        prisonerRef.SetBelongingsContainer() ; Set the container of where the prisoner's items will be confiscated to
    endif

    if (!prisonerRef.JailCell)
        prisonerRef.AssignCell() ; Assign a prison cell to this prisoner
    endif

    ; TODO: Review if a prisoner should be both frisked and stripped, or only stripped if they were going to be stripped
    if (prisonerRef.ShouldBeStripped)
        prisonerRef.StartStripping(akEscort)

    elseif (prisonerRef.ShouldBeFrisked)
        prisonerRef.StartFrisking(akEscort)
    endif

    if (prisonerRef.Should("Go to Cell"))
        ; Need to check if the prisoner is not in the cell later, IsInCell doesn't work as it should
        prisonerRef.EscortToCell(akEscort)
    endif
endEvent

event OnEscortPrisonerToCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerToCellBegin", "Escape"))
        ; Process escort to cell after escape
    endif

    Debug("Prison::OnEscortPrisonerToCellBegin", "Event fired but it has no implementation!")
endEvent

event OnEscortingPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)

endEvent

; TODO: Remove RPB_JailCell from params. since a Prisoner already has a jail cell assigned to them
event OnEscortPrisonerToCellEnd(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerToCellEnd", "Escape"))
        ; Process escort to cell after escape
    endif

    ; TODO: Fix NPC not staying in cell if they are stripped OnEscortToCellEnd
    if (!apPrisoner.IsStripped && apPrisoner.ShouldBeStripped)
        apPrisoner.Strip()
        ; apPrisoner.StartStripping(akEscort)
        ; SceneManager.ResumeSceneBlocked()
    endif

    if (!apPrisoner.PrisonerBelongingsContainer)
        apPrisoner.SetBelongingsContainer()     ; Set the container of where the prisoner's items will be confiscated to
    endif

    apPrisoner.Uncuff()

    if (!apPrisoner.IsImprisoned)
        apPrisoner.Imprison()
    endif

    apPrisoner.SetBool("Should Be In Cell", true)

    if (apPrisoner.IsNPC())
        ; Ensures the Prisoner stays in the cell since we update it 10s later after the initial check,
        ; delaying it enough for all actions to finish before the check.
        apPrisoner.JailCell.RegisterForSanityChecking(10.0, apPrisoner = apPrisoner)
   endif

endEvent

event OnEscortPrisonerFromCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerFromCellBegin", "Release"))
        ; Process Release
    endif

    Debug("Prison::OnEscortPrisonerFromCellBegin", "Event fired but it has no implementation!")
endEvent

event OnEscortPrisonerFromCellEnd(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerFromCellEnd", "Release"))
        ; Process Release
    endif

    Debug("Prison::OnEscortPrisonerFromCellEnd", "Event fired but it has no implementation!")
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
        apPrisoner.UnequipItemSlot(37)
        apPrisoner.UnequipItemSlot(49)
        apPrisoner.UnequipItemSlot(52)
    elseif (asSceneEvent == "Undress Upper Body")
        apPrisoner.UnequipItemSlot(33)
        apPrisoner.UnequipItemSlot(56)
        apPrisoner.UnequipItemSlot(32)

    elseif (asSceneEvent == "Undress to Underwear")
        ; Remove all clothing except Underwear
        apPrisoner.Strip(false)

    elseif (asSceneEvent == "Remove Underwear")
        ; Remove Underwear, prisoner must be unclothed already
        ; apPrisoner.RemoveUnderwear()
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

event OnGuardDeath(RPB_Guard akGuard, Actor akKiller)

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

event OnPrisonerEnterCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    ; akJailCell.OnPrisonerEnter(apPrisoner)
endEvent

event OnPrisonerLeaveCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    ; akJailCell.OnPrisonerLeave(apPrisoner)
endEvent

; ==========================================================
;                           Scenes
; ==========================================================

; ==========================================================
;                          Management
; ==========================================================

;/
    Fires a Prisoner based Event on a Scene condition and phase.
    It also handles sub-events within that Scene that should not fire an Event by themselves.

    string          @asScene: The name of the Scene.
    string          @asSceneEvent: The event that takes place within the Scene.
    RPB_Prisoner    @apPrisoner: The prisoner that is taking part in the Scene.
    string?         @asSceneSubEvent: The event that takes place within the Scene at a certain phase.

    returns: Return value is not used, instead, the sole purpose is to block the execution and prevent further calls that depend on these Events.
/;
int function FirePrisonerEventOnScene(string asScene, string asSceneEvent, RPB_Prisoner apPrisoner, string asSceneSubEvent = "null")
    if (asScene == SceneManager.SCENE_STRIPPING_02 || asScene == SceneManager.SCENE_STRIPPING_01 || asScene == SceneManager.SCENE_FORCED_STRIPPING_02)
        Actor stripperGuard = apPrisoner.GetForm("StripperGuard", "Temporary::Imprisoned") as Actor
        Debug("Prison::FirePrisonerEventOnScene", "Stripper Guard: " + stripperGuard)

        if (asSceneEvent == "StripBegin")
            if (asSceneSubEvent == "Undress to Underwear")
                apPrisoner.Strip(abRemoveUnderwear = false)

            elseif (asSceneSubEvent == "Lie Down")
                apPrisoner.PlayAnimation("IdleLayDownEnter")

            elseif (asSceneSubEvent == "")
            endif
            self.OnPrisonerStripBegin(apPrisoner, stripperGuard)
            
        elseif (asSceneEvent == "StripMiddle")
            self.OnPrisonerStripping(apPrisoner, stripperGuard, asSceneSubEvent)

        elseif (asSceneEvent == "StripEnd")
            if (asSceneSubEvent == "Restrain Prisoner")
                Form cuffs = Game.GetFormEx(0xA081D33)
                apPrisoner.SheatheWeapon()
                apPrisoner.EquipItem(cuffs, true, true)
                return 1

            elseif (asSceneSubEvent == "Stand Up (Lie Down)")
                apPrisoner.PlayAnimation("IdleLayDownExit")
                ; Remove Underwear
                self.OnPrisonerStripEnd(apPrisoner, stripperGuard)

            elseif (asSceneSubEvent == "Stand Up (Kneel)")
                apPrisoner.PlayAnimation("IdleKneelExit") ; TODO: Not working
                self.OnPrisonerStripEnd(apPrisoner, stripperGuard)
                API.Arrest.RestrainArrestee(apPrisoner.GetActor())
                return 1
            endif

            self.OnPrisonerStripEnd(apPrisoner, stripperGuard)
        endif

    elseif (asScene == SceneManager.SCENE_ESCORT_TO_JAIL_01 || asScene == SceneManager.SCENE_ESCORT_TO_JAIL_02)
        Actor prisonerEscort = apPrisoner.GetForm("EscortGuard", apPrisoner.TEMPORARY_DESTROY_ON_IMPRISONED) as Actor

        if (asSceneEvent == "EscortBegin")
            self.OnEscortPrisonerToJailBegin(apPrisoner, prisonerEscort)

        elseif (asSceneEvent == "EscortEnd")
            self.OnEscortPrisonerToJailEnd(apPrisoner, prisonerEscort)

        endif

        Debug("Prison::FirePrisonerEventOnScene", "Prison -> " + asScene + ": " + asSceneEvent)

    elseif (asScene == SceneManager.SCENE_ESCORT_TO_CELL_01 || asScene == SceneManager.SCENE_ESCORT_TO_CELL_02)
        Actor prisonerEscort        = apPrisoner.GetForm("EscortGuard", apPrisoner.TEMPORARY_DESTROY_ON_IMPRISONED) as Actor
        RPB_CellDoor cellDoor       = apPrisoner.GetForm("CellDoor", apPrisoner.TEMPORARY_DESTROY_ON_IMPRISONED) as RPB_CellDoor 

        if (asSceneEvent == "EscortBegin")
            self.OnEscortPrisonerToCellBegin(apPrisoner, prisonerEscort)

        elseif (asSceneEvent == "Escorting")
            if (asSceneSubEvent == "Release from Captor")
                RPB_Captor captor = API.Arrest.AwaitCaptorReference(prisonerEscort)
                captor.StopEscorting()
            endif

            self.OnEscortingPrisonerToCell(apPrisoner, prisonerEscort)

        elseif (asSceneEvent == "EscortEnd")
            if (asSceneSubEvent == "Lock Cell Door")
                cellDoor.Close()
                cellDoor.Lock()
                Debug.SendAnimationEvent(prisonerEscort, "IdleLockpick") ; Lock animation

            elseif (asSceneSubEvent == "Unlock Cell Door")
                Debug.SendAnimationEvent(prisonerEscort, "IdleLockpick")
                cellDoor.Unlock()
                cellDoor.Open()
                return 1
            endif
            
            self.OnEscortPrisonerToCellEnd(apPrisoner, apPrisoner.JailCell, prisonerEscort)
        endif

    elseif (asScene == SceneManager.SCENE_ESCORT_FROM_CELL)
        Actor prisonerEscort = apPrisoner.GetForm("EscortGuard", apPrisoner.TEMPORARY_DESTROY_ON_IMPRISONED) as Actor

        if (asSceneEvent == "EscortBegin")
            self.OnEscortPrisonerFromCellBegin(apPrisoner, prisonerEscort)

        elseif (asSceneEvent == "EscortEnd")
            self.OnEscortPrisonerFromCellEnd(apPrisoner, prisonerEscort)
            
        endif
    endif
endFunction

int function FireFallbackActorEventOnScene(string asScene, string asSceneEvent, Actor akActor, string asSceneSubEvent = "null")
    if (asScene == SceneManager.SCENE_ESCORT_TO_JAIL_01)
        if (asSceneEvent == "EscortBegin")
            if (asSceneSubEvent == "Make Prisoner") ; Make the Actor a Prisoner
                RPB_Prisoner prisoner = self.MakePrisoner(akActor)
                prisoner.SetSentence()
                self.RegisterPrisoner(prisoner)
                return 1
            endif
        endif

    elseif (asScene == SceneManager.SCENE_STRIPPING_02)
        if (asSceneEvent == "StripBegin")
            if (asSceneSubEvent == "Make Prisoner")
                self.MakePrisoner(akActor)
                RPB_Prisoner newPrisoner = self.AwaitPrisonerReference(akActor)
                int copiedSentence       = newPrisoner.GetInt("Sentence", newPrisoner.TEMPORARY_DESTROY_ON_IMPRISONED)
                newPrisoner.SetSentence(copiedSentence)  ; Copy the sentence
                return 1
            endif
        endif
    endif

    return 0
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

event OnCellAttach()
    self.SetupCells()
    Debug("["+ Name +"] Prison::OnCellAttach", "On Cell Attach Prison")
endEvent

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

    EndBenchmark(startBench, "Prison::SetupCells")
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

Form function GetRandomSearchMarker(string asSearchType = "Frisking")
    Form[] markers = self.GetSearchMarkers(asSearchType)
    return markers[Utility.RandomInt(0, markers.Length - 1)]
endFunction

Form function GetRandomReleaseMarker(string asReleaseMarkerType = "Teleport")
    Form[] allReleaseMarkersOfType = self.GetReleaseMarkers(asReleaseMarkerType)
    return allReleaseMarkersOfType[Utility.RandomInt(0, allReleaseMarkersOfType.Length - 1)]
endFunction

Form[] function GetPrisonerContainers(string asPrisonerContainerType = "Belongings")
    if (asPrisonerContainerType != "Belongings" && asPrisonerContainerType != "Evidence")
        Error("["+ Name +"] The prisoner container type specified ("+ asPrisonerContainerType +") is invalid!")
        DebugError("["+ Name +"] Prison::GetPrisonerContainers", "The prisoner container type specified ("+ asPrisonerContainerType +") is invalid!")
        return none
    endif

    return self.GetPropertyOfTypeFormArray("Prisoner Containers//" + asPrisonerContainerType)
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

function RegisterForPrisonPeriodicUpdate(RPB_Prisoner akPrisoner)
    Debug("Prison::RegisterForPrisonPeriodicUpdate", "Called RegisterForPrisonPeriodicUpdate()")
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
    Binds the actor to an instance of RPB_Prisoner,
    giving us the prisoner state of the Actor bound to this reference.

    Used when this Actor is a Prisoner, lasts until Release or Escape.

    This function is used inside RPB_Prisoner, since there is no other way to obtain
    a reference to the script as of now.

    RPB_Prisoner    @akPrisonerRef: The Prisoner reference to bind to the Actor.
/;
bool function RegisterPrisoner(RPB_Prisoner apPrisoner)
    Prisoners.Add(apPrisoner)
    self.OnPrisonerRegistered(apPrisoner)
    self.AssignPrisonerNumber(apPrisoner)
    return Prisoners.Exists(apPrisoner)
endFunction

;/
    Assigns a number to this Prisoner for this Prison.
/;
function AssignPrisonerNumber(RPB_Prisoner apPrisoner)
    int prisonerCount   = Prisoners.Count
    int assignedNumber  = prisonerCount + 1
    apPrisoner.SetInt("Prisoner Number", assignedNumber)
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
        RPB_StorageVars.SetBoolOnForm("Imprisoned", apPrisoner.GetActor(), false)
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
        RPB_StorageVars.SetBoolOnForm("Imprisoned", apPrisoner.GetActor(), false)
    endif
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

; TODO: Delete this after replacing calls
RPB_Prisoner function GetPrisonerReference(Actor akPrisoner)
    return self.AwaitPrisonerReference(akPrisoner)
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


; ; ==========================================================

; ==========================================================
;                      Global Functions
; ==========================================================

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
    return RPB_Utility.AwaitEntityReference(akPrisoner, Prisoners, self, aiMaxTries, afInitialTimeBetweenTries, afMaxTimeBetweenTries) as RPB_Prisoner
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

; State for Infamy Messages
bool __infamyRecognizedThresholdMsgSent
bool __infamyKnownThresholdMsgSent

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

; ==========================================================

; ==========================================================
;                           States
; ==========================================================

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