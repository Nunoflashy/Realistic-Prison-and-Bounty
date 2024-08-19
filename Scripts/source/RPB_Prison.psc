Scriptname RPB_Prison extends ReferenceAlias  

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

int property DayToStartLosingSkills
    int function get()
        return Config.GetJailDayToStartLosingSkills(Hold)
    endFunction
endProperty

int property ChanceToLoseSkills
    int function get()
        return Config.GetJailChanceToLoseSkillsDaily(Hold)
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
;                       Prison Identity
; ==========================================================

bool property Initialized
    bool function get()
        return __isInitialized
        ; return ID && Name && PrisonFaction && PrisonLocation && Hold && City
    endFunction
endProperty

int property ID
    int function get()
        return self.GetID()
    endFunction
endProperty

Location __prisonLocation
Location property PrisonLocation
    Location function get()
        return __prisonLocation
    endFunction
endProperty

Faction __prisonFaction
Faction property PrisonFaction
    Faction function get()
        return __prisonFaction
    endFunction
endProperty

string __name
string __fallbackName
string property Name
    string function get()
        if (__name)
            return __name
        endif

        if (__fallbackName)
            return __fallbackName
        endif

        if (!__name)
            __name = self.GetRootPropertyOfTypeString("Name")
        endif

        if (!__name)
            __fallbackName = PrisonLocation.GetName()
        endif

        ; if (!__name)
        ;     return "Prison " + ID
        ; endif

        return __name
    endFunction
endProperty

string __hold
string property Hold
    string function get()
        return __hold
    endFunction
endProperty

string __city
string property City
    string function get()
        return __city
    endFunction
endProperty


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
        LogProperty("Prison::Prisoners", "Initialized with a value of: " + __prisoners)
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

function Uninitialize()
    __isInitialized = false

    __prisonLocation    = none
    __prisonFaction     = none
    __name              = none
    __hold              = none
    __city              = none
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

RPB_Prisoner function GetPrisoner(Actor akPrisonerActor)
    return self.Prisoners.AtKey(akPrisonerActor)
endFunction

; ==========================================================
;                         Prisoners
; ==========================================================

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
        return akPrisonCell.HasPrisoners()
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

bool function ProcessPrisoner(RPB_Prisoner apPrisoner)
    apPrisoner.SetReleaseLocation()
    apPrisoner.SetBelongingsContainer()

    if (!apPrisoner.AssignCell())
        return false
    endif

    if (apPrisoner.ShouldBeFrisked)
        ; Prison.EnqueueScene("RPB_Stripping02")
        ; SceneManager.EnqueueNextScene()
    endif

    if (apPrisoner.ShouldBeStripped)
        apPrisoner.StartStripping(apPrisoner.Captor)
    endif
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
    return RPB_Data.JailCell_GetParents(self.GetDataObject("Cells"))
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

;/
    Requests a jail cell for the given prisoner, based on this Prison's config.

    RPB_Prisoner    @akPrisoner: The prisoner that is requesting the jail cell.

    returns (RPB_JaiLCell): The jail cell that was requested for this prisoner, based on their criteria if it exists, otherwise returns none.
/;
RPB_JailCell function RequestCellForPrisoner(RPB_Prisoner akPrisoner)
    RPB_JailCell outputCell = none

    self.PrioritizeGenderCells = true

    ; Determine what type of cell this prisoner should go to
    akPrisoner.DetermineCellOptions()

    if (self.AllowOnlyEmptyCells && akPrisoner.OnlyAllowImprisonmentInGenderCell)
        ; Error, conflicting options
        Debug("Prison::RequestCellForPrisoner", "There are conflicting properties, cannot request a jail cell for this prisoner! [\n"+ \
            "\t Prison: " + self.Hold + "\n" + \
            "\t Prisoner: " + akPrisoner + ", identified by: " + akPrisoner.GetIdentifier() + \
            "\t Prison.AllowOnlyEmptyCells: " + self.AllowOnlyEmptyCells + "\n" + \
            "\t Prisoner.OnlyAllowImprisonmentInGenderCell: " + akPrisoner.OnlyAllowImprisonmentInGenderCell + "\n" + \
        "]")
        return none

    elseif (self.AllowOnlyGenderExclusiveCells && akPrisoner.OnlyAllowImprisonmentInEmptyCell)
        ; Error, conflicting options
        Debug("Prison::RequestCellForPrisoner", "There are conflicting properties, cannot request a jail cell for this prisoner! [\n"+ \
            "\t Prison: " + self.Hold + "\n" + \
            "\t Prisoner: " + akPrisoner + ", identified by: " + akPrisoner.GetIdentifier() + \
            "\t Prison.AllowOnlyGenderExclusiveCells: " + self.AllowOnlyGenderExclusiveCells + "\n" + \
            "\t Prisoner.OnlyAllowImprisonmentInEmptyCell: " + akPrisoner.OnlyAllowImprisonmentInEmptyCell + "\n" + \
        "]")
        return none
    endif

    ; Determine cell to request through Prisoner related config
    if (akPrisoner.OnlyAllowImprisonmentInEmptyCell)
        outputCell = self.GetEmptyJailCell()
        Debug("Prison::RequestCellForPrisoner", "Tried getting empty cell: " + outputCell, outputCell == none)
        Debug("Prison::RequestCellForPrisoner", "Got empty cell: " + outputCell, outputCell != none)
        return outputCell

    elseif (akPrisoner.OnlyAllowImprisonmentInGenderCell)
        outputCell = self.GetJailCellOfGender(akPrisoner.GetSex())
        Debug("Prison::RequestCellForPrisoner", "Tried getting gender exclusive cell: " + outputCell, outputCell == none)
        Debug("Prison::RequestCellForPrisoner", "Got gender exclusive cell: " + outputCell, outputCell != none)
        return outputCell

    elseif (akPrisoner.OnlyAllowImprisonmentInEmptyOrGenderCell)
        ; Get the cell based on prison's priorities, and do not allow random cells
        outputCell = self.GetJailCellBasedOnPriority(akPrisoner.GetSex())
        Debug("Prison::RequestCellForPrisoner", "Tried getting priority based cell (empty or gender exclusive): " + outputCell + ", Prisoner Gender: " + akPrisoner.GetSex(), outputCell == none)
        Debug("Prison::RequestCellForPrisoner", "Got priority based cell (empty or gender exclusive): " + outputCell + ", Prisoner Gender: " + akPrisoner.GetSex(), outputCell != none)
        return outputCell
    endif

    if (outputCell == none)
        ; Get a jail cell based on this prison's priorities, allow random cells
        outputCell = self.GetJailCellBasedOnPriority(akPrisoner.GetSex(), true)
        Debug("Prison::RequestCellForPrisoner", "Tried getting priority based or random cell: " + outputCell + ", Prisoner Gender: " + akPrisoner.GetSex(), outputCell == none)
        Debug("Prison::RequestCellForPrisoner", "Got priority based or random cell: " + outputCell + ", Prisoner Gender: " + akPrisoner.GetSex(), outputCell != none)
    endif

    ; Cells must either be empty or gender exclusive, and none was found for this prisoner
    if ((self.AllowOnlyEmptyCells || self.AllowOnlyGenderExclusiveCells) && outputCell == none)
        ; Could not assign a cell based on criteria.
    endif

    if (outputCell == none)
        ; If no criteria was passed and a cell was not retrieved yet, get a random cell
        outputCell = self.GetRandomJailCell() as RPB_JailCell
        Debug("Prison::RequestCellForPrisoner", "Tried getting random cell: " + outputCell, outputCell == none)
        Debug("Prison::RequestCellForPrisoner", "Got random cell: " + outputCell, outputCell != none)
    endif


    return outputCell
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
    string          @asFailReason: The reason for imprisonment failing.
/;
event OnPrisonerImprisonmentFail(RPB_Prisoner apPrisoner, string asFailReason)
    if (asFailReason == "Assign Cell")
        ; Could not assign a cell to this prisoner, abort imprisonment?
        DebugError("Prison::OnPrisonerImprisonmentFail", "A jail cell could not be assigned to prisoner " + apPrisoner.Name + ", aborting imprisonment and destroying reference...!")
        Error("A jail cell could not be assigned to " + apPrisoner.Name + ", aborting imprisonment...!")
        apPrisoner.Destroy()
    endif
endEvent

event OnPrisonerRegistered(RPB_Prisoner apPrisoner)
    self.RegisterPrisonerLastJailedStats(apPrisoner)
    PrisonManager.OnPrisonRegisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerUnregistered(RPB_Prisoner apPrisoner)
    PrisonManager.OnPrisonUnregisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerMovedToPrison(RPB_Prisoner apPrisoner, bool abWasMovedDirectlyToCell)
    if (abWasMovedDirectlyToCell)
        if (apPrisoner.IsRestrained())
            apPrisoner.Uncuff()
        endif

        return
    endif

    ; Moved to Prison
    self.ProcessPrisoner(apPrisoner)
    ; self.OnPrisonerProcessed(apPrisoner)
endEvent

event OnPrisonerProcessed(RPB_Prisoner apPrisoner)
    apPrisoner.SetReleaseLocation()
    apPrisoner.SetBelongingsContainer()
    if (!apPrisoner.AssignCell())
        return
    endif

    apPrisoner.StartStripping(apPrisoner.Captor)
endEvent

event OnPrisonerTimeElapsed(RPB_Prisoner apPrisoner)

endEvent

event OnPrisonerImprisoned(RPB_Prisoner apPrisoner)

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

event OnPrisonerDying(RPB_Prisoner apPrisoner, Actor akKiller)
    
endEvent

event OnPrisonerDeath(RPB_Prisoner apPrisoner, Actor akKiller)

endEvent

event OnEscortPrisonerToJailBegin(RPB_Actor apActor, Actor akEscort)
    (apActor as RPB_Arrestee).Cuff()

    ; ReferenceAlias arrestPackage = API.PrisonManager.GetCellPackageOfType("S")
    ; apActor.BindAlias(arrestPackage)
    Debug("Prison::OnEscortPrisonerToJailBegin", "Bound arrest package, arrestee should stay still.")
endEvent

event OnEscortPrisonerToJailEnd(RPB_Actor apActor, Actor akEscort)
    ; Retrieve or make the Actor a Prisoner
    RPB_Prisoner prisonerRef = RPB_Utility.ame_if (apActor as RPB_Prisoner, apActor, (apActor as RPB_Arrestee).MakePrisoner()) as RPB_Prisoner

    prisonerRef.SetReleaseLocation()    ; Set the release location for this prisoner
    prisonerRef.SetBelongingsContainer()     ; Set the container of where the prisoner's items will be confiscated to
    prisonerRef.AssignCell()            ; Assign a prison cell to this prisoner

    ; if should be stripped
    ; prisonerRef.StartStripping(akEscort)
    if (!prisonerRef.IsInCell)
        ; prisonerRef.StartRestraining(akStripper)
        prisonerRef.EscortToCell(akEscort)
    endif
    ; prisonerRef.EscortToCell(akEscort)
endEvent

event OnEscortPrisonerToCellBegin(RPB_Prisoner apPrisoner, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerToCellBegin", "Escape"))
        ; Process escort to cell after escape
    endif

    ; ; Since NPC's don't stay in the cell if the player is away with Scenes, we must force the move
    ; ; by checking if the player is far away, it will be seamless and it's as if they were escorted
    ; if (apPrisoner.IsNPC() && apPrisoner.IsFarFromPlayer())
    ;     apPrisoner.MoveToCellTemp()
    ;     apPrisoner.Strip()
    ; endif

    return
    Debug("Prison::OnEscortPrisonerToCellBegin", "Event fired but it has no implementation!")
endEvent

event OnEscortingPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)

endEvent

; TODO: Remove RPB_JailCell from params. since a Prisoner already has a jail cell assigned to them
event OnEscortPrisonerToCellEnd(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell, Actor akEscort)
    if (apPrisoner.HasSceneState("OnEscortPrisonerToCellEnd", "Escape"))
        ; Process escort to cell after escape
    endif
    if (apPrisoner.IsStrippedNaked || apPrisoner.IsStrippedToUnderwear)
        ; return
    endif

    akJailCell.RegisterForSanityChecking(apPrisoner = apPrisoner)

    ; if (apPrisoner.IsNPC())
    ;     apPrisoner.BindToCell()

    ;     if (apPrisoner.IsFarFromPlayer())
    ;         apPrisoner.MoveTo(apPrisoner.JailCell)
    ;         self.RegisterForSingleUpdate(1.0) ; Poll request to ensure the prisoner stays in the jail cell, should be terminated right after that
    ;     endif
    ; endif

    ; akJailCell.Lock()

    ; Since NPC's don't stay in the cell if the player is away with Scenes, we must force the move
    ; by checking if the player is far away, it will be seamless and it's as if they were escorted
    ; if (apPrisoner.IsNPC() && apPrisoner.IsFarFromPlayer())
    ;     apPrisoner.MoveToCellTemp()
    ;     ; apPrisoner.Strip()
    ; endif

    ; if (apPrisoner.IsOutOfCell())
    ;     apPrisoner.MoveTo(apPrisoner.JailCell)
    ; endif

    ; apPrisoner.MoveTo(apPrisoner.JailCell)
    apPrisoner.Uncuff()
    apPrisoner.Imprison()
    ; if (apPrisoner.HasSceneState("OnEscortPrisonerToCellEnd", "Arrest"))
    ;     if (apPrisoner.ShouldBeStripped)
    ;         apPrisoner.Strip()
    ;     endif
    ; endif
    ; apPrisoner.StartStripping(akEscort)
    apPrisoner.OnEscortedToCell(akEscort)
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
        apPrisoner.EscortToCell(akStripper)
    endif

    Debug("Prison::OnPrisonerStripEnd", "event invoked")
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

function EscortPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
    ; The marker where the escort will stand, waiting for the prisoner to enter the cell.
    ObjectReference outsideJailCellEscortWaitingMarker = apPrisoner.JailCell.GetRandomMarker("Exterior") as ObjectReference

    SceneManager.StartEscortToCell( \
        akEscortLeader              = akEscort, \
        akEscortedPrisoner          = apPrisoner.GetActor(), \
        akJailCellMarker            = apPrisoner.JailCell, \
        akJailCellDoor              = apPrisoner.JailCell.CellDoor, \ 
        akEscortWaitingMarker       = outsideJailCellEscortWaitingMarker \ 
    )
endFunction

function BeginStrippingPrisoner(RPB_Prisoner apPrisoner, Actor akStripper)
    SceneManager.StartStripping_02( \
        akStripperGuard     = akStripper, \
        akStrippedPrisoner  = apPrisoner.GetActor() \
    )
endFunction

; ==========================================================
;                          Management
; ==========================================================

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
                RPB_Captor captor = API.Arrest.GetCaptorReference(prisonerEscort)
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
                RPB_Prisoner newPrisoner = self.GetPrisoner(akActor)
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

event OnInit()
    ; ; Temporary, to hold periodically updates prisoners for now
    ; checkedPrisoners        = new RPB_Prisoner[128]
    ; checkedPrisonersIndex   = 0

    ; ; __prisoners             = new RPB_Prisoner[128]
    ; __prisonersIndex        = 0


    Debug("Prison::OnInit", "OnInit PRISON")
endEvent

event OnUpdateGameTime()
    __isReceivingUpdates = true
    __isAwaitingUpdateForGameTime = false
    
    self.OnPrisonPeriodicUpdate()

    RegisterForSingleUpdateGameTime(5.0)
endEvent

int __holdObject

function ConfigurePrison( \
    Location akLocation, \
    Faction akFaction, \
    string asHold, \
    string asName = "" \
)

    __prisonLocation    = akLocation
    __prisonFaction     = akFaction
    __name              = asName
    __hold              = asHold

    int rootItem                = RPB_Data.GetRootObject(__hold)
    string configuredCity       = RPB_Data.Hold_GetCity(rootItem)

    __city              = configuredCity
    __holdObject        = rootItem

    ; RPB_Utility.Debug("Prison::ConfigurePrison", "Name: " + self.Name + ", Hold: " + self.Hold + ", Faction: " + self.PrisonFaction + ", City: " + self.City)

    ; if (PrisonLocation && PrisonFaction && Name && Hold)
        __isInitialized     = true
        ; RPB_StorageVars.SetBool("Prison::" + ID, true, "PrisonManager")
    ; endif
    ; Trace("Prison::ConfigurePrison", "["+ self.Name +"] Is Initialized: " + __isInitialized)

    ; Form randomPrisonerContainer = self.GetRandomPrisonerContainer()

    ; Form oppositeContainer = self.GetPrisonerContainerLinkedWithOppositeType(randomPrisonerContainer, "Evidence")
    ; Debug("Prison::ConfigurePrison", "Evidence Link Of Belongings Container " + randomPrisonerContainer + ": " + oppositeContainer)
    ; Debug("Prison::ConfigurePrison", "Prisoner Containers: " + self.GetPrisonerContainers())

    ; if (randomPrisonerContainer)
    ;     Config.Player.RemoveAllItems(randomPrisonerContainer as ObjectReference, true, true)
    ; endif

    ; Initialize all of the jail cells belonging to this prison
    self.SetupCells() ; To be changed, this will only work if the Player is present in the scene

    ; Debug(self.GetOwningQuest(), "Prison::ConfigurePrison", "Prison Location: " + PrisonLocation + ", Prison Faction: " + PrisonFaction + ", Prison Hold: " + Hold)
endFunction

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


function SetupCells()
    if (self.Hold != "Haafingar")
        return
    endif

    float startBench = StartBenchmark()

    int i = 0
    while (i < JailCells.Length)
        RPB_JailCell jailCell = JailCells[i] as RPB_JailCell

        ; if (jailCell == GetFormFromMod(0x3879) || jailCell == Game.GetFormEx(0x36897))
            if (!jailCell.IsInitialized())
                jailCell.Initialize(self)
    
                Debug("[Prison: "+ Name +"] Prison::SetupCells", "Jail Cell: " + jailCell + " - " + "HasOption(Maximum Prisoners):" + jailCell.HasOption("Maximum Prisoners") + ", HasObjects(Beds): " + jailCell.HasObjects("Beds"))
    
                if (jailCell.ShouldPerformScan("Beds"))
                    jailCell.ScanBeds()
                endif
                
                if (jailCell.ShouldPerformScan("Containers"))
                    jailCell.ScanContainers()
                endif
    
                if (jailCell.ShouldPerformScan("Props"))
                    jailCell.ScanMiscProps()
                endif
    
                Debug("[Prison: "+ Name +"] Prison::SetupCells", jailCell + " Maximum Prisoners: " + jailCell.MaxPrisoners)
            endif
        ; endif


        i += 1
    endWhile

    EndBenchmark(startBench, "Prison::SetupCells")
endFunction

Form[] function GetReleaseMarkers(string asReleaseMarkerType = "Teleport")
    if (asReleaseMarkerType != "Teleport" && asReleaseMarkerType != "Escort")
        Error("The release marker type specified ("+ asReleaseMarkerType +") is invalid!")
        DebugError("Prison::GetReleaseMarkers", "The release marker type specified ("+ asReleaseMarkerType +") is invalid!")
        return none
    endif

    return RPB_Data.Jail_GetReleaseMarkers(self.GetDataObject(), asReleaseMarkerType)
endFunction

Form function GetRandomReleaseMarker(string asReleaseMarkerType = "Teleport")
    if (asReleaseMarkerType != "Teleport" && asReleaseMarkerType != "Escort")
        Error("The release marker type specified ("+ asReleaseMarkerType +") is invalid!")
        DebugError("Prison::GetRandomReleaseMarker", "The release marker type specified ("+ asReleaseMarkerType +") is invalid!")
        return none
    endif

    Form[] allReleaseMarkersOfType = self.GetReleaseMarkers(asReleaseMarkerType)
    return allReleaseMarkersOfType[Utility.RandomInt(0, allReleaseMarkersOfType.Length - 1)]
endFunction

Form[] function GetPrisonerContainers(string asPrisonerContainerType = "Belongings")
    return RPB_Data.Jail_GetPrisonerContainers(self.GetDataObject(), asPrisonerContainerType)
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

Form function GetJailCellExterior(RPB_JailCell akJailCell)

endFunction

;/
    Gets all the jail cells in this prison that match the sex passed in.

    string  @asSex: The desired sex for the exclusivity of the jail cell.

    For a jail cell to be of a specific sex, it must have at least one prisoner of that sex,
    which means these jail cells are never empty.
/;
Form[] function GetGenderExclusiveCells(string asSex)
    Form[] cells = self.JailCells
    int genderCellsArray = JArray.object()

    int i = 0
    while (i < cells.Length)
        RPB_JailCell jailCellRef = cells[i] as RPB_JailCell

        if (jailCellRef && (asSex == "Male" && jailCellRef.IsMaleOnly) || (asSex == "Female" && jailCellRef.IsFemaleOnly))
            ; Debug("Prison::GetGenderExclusiveCells", "Cell: " + jailCellRef + ", IsEmpty: " + jailCellRef.IsEmpty + ", Gender: " + jailCellRef.IsGenderExclusive)
            JArray.addForm(genderCellsArray, jailCellRef)
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

RPB_JailCell function GetJailCellOfGender(string asSex)
    Form[] genderCells = self.GetGenderExclusiveCells(asSex)
    RPB_JailCell genderCell = genderCells[Utility.RandomInt(0, genderCells.Length - 1)] as RPB_JailCell

    return genderCell
endFunction

RPB_JailCell function GetFemaleJailCell()
    return self.GetJailCellOfGender("Female")
endFunction

RPB_JailCell function GetMaleJailCell()
    return self.GetJailCellOfGender("Male")
endFunction

;/
    Retrieves a jail cell based on this prison's priorities.

    string  @asSex: The gender of the cell in case a gender exclusive cell is returned
    bool    @abAllowRandomCells: Whether to allow random jail cells as a fallback in case either empty or gender exclusive cells could not be returned

    returns: A jail cell based on the prison's priorities, random if the priorities could not be met, or none if no jail cells could be returned.

/;
RPB_JailCell function GetJailCellBasedOnPriority(string asSex, bool abAllowRandomCells = false)
    RPB_JailCell returnedCell = none

    if (self.PrioritizeEmptyCells)
        returnedCell = self.GetEmptyJailCell()
        Trace("Prison::GetJailCellBasedOnPriority", "Got empty cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)

    elseif (self.PrioritizeGenderCells)
        returnedCell = self.GetJailCellOfGender(asSex)
        Trace("Prison::GetJailCellBasedOnPriority", "Got gender exclusive cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)
    endif

        
    ; No priority
    ; Get empty cell first, if that fails, get a gender exclusive one, else get a random cell if @abAllowRandomCells is true
    if (returnedCell == none)
        returnedCell = self.GetEmptyJailCell()
        Trace("Prison::GetJailCellBasedOnPriority", "Got empty cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)
    endif

    if (returnedCell == none)
        returnedCell = self.GetJailCellOfGender(asSex)
        Trace("Prison::GetJailCellBasedOnPriority", "Got gender exclusive cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)

    endif

    if (returnedCell == none && abAllowRandomCells)
        returnedCell = self.GetRandomJailCell()
        Trace("Prison::GetJailCellBasedOnPriority", "Got random cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)

    endif

    ; Could not return any cell, error here
    Trace("Prison::GetJailCellBasedOnPriority", "Could not retrieve any cell!  Prisoner Gender: " + asSex, returnedCell == none)

    return returnedCell
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

    ; Assign a Prisoner number based on the current number of prisoners in the prison
    self.AssignPrisonerNumber(apPrisoner)

    Trace("Prison::RegisterPrisoner", "PrisonerList: " + Prisoners.GetKeys())

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

        RPB_StorageVars.SetIntOnForm("Last Jailed - Prison", self.PrisonFaction, self.ID, "PrisonLastJailed")
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

RPB_Prisoner function GetPrisonerReference(Actor akPrisoner)
    RPB_Prisoner prisonerRef = Prisoners.AtKey(akPrisoner)

    if (!prisonerRef)
        DebugError("Prison::GetPrisonerReference", "The Actor " + akPrisoner + " is not a prisoner or there was a state mismatch!")
        Error(akPrisoner.GetBaseObject().GetName() + " is not a prisoner or there was a state mismatch!")
        return none
    endif

    return prisonerRef
endFunction


bool __isReceivingUpdates
bool function IsReceivingUpdates()
    return __isReceivingUpdates
endFunction

bool function WasInitialized()
    return __isInitialized
    ; return RPB_StorageVars.GetBool("Prison::" + ID, "PrisonManager")
    ; return __isInitialized && (PrisonManager.GetNthAlias(ID) as RPB_Prison == self)
endFunction

bool function IsValid()
    return self.GetReference() != none
endFunction

bool function WasConfigChanged()
    int holdRootObject = RPB_Data.GetRootObject(self.Hold)
    RPB_Utility.Debug("Prison::WasConfigChanged", "Prison: " + self.City + ", " + "holdRootObject: " + holdRootObject + ", holdObject: " + __holdObject)
    RPB_Utility.Debug("Prison::WasConfigChanged", "Hold: " + self.Hold + ", Faction: " + self.PrisonFaction + ", City: " + self.City)
    return __holdObject != holdRootObject
endFunction

; TODO: Store the prisoners for each prison here, making the AME list futile since we can always retrieve them through here,
; maybe map the index to a key for easier access like it's done in the AME list.

int __prisonersIndex


RPB_JailCell[] __prisonCells

bool __isInitialized

; =========================================================
;                         Data Config                      
; =========================================================

;                       Root Properties                    
; =========================================================
bool function GetRootPropertyOfTypeBool(string asPropertyName)
    return RPB_Data.Jail_GetRootPropertyOfTypeBool(self.GetDataObject(), asPropertyName)
endFunction

int function GetRootPropertyOfTypeInt(string asPropertyName)
    return RPB_Data.Jail_GetRootPropertyOfTypeInt(self.GetDataObject(), asPropertyName)
endFunction

float function GetRootPropertyOfTypeFloat(string asPropertyName)
    return RPB_Data.Jail_GetRootPropertyOfTypeFloat(self.GetDataObject(), asPropertyName)
endFunction

string function GetRootPropertyOfTypeString(string asPropertyName)
    return RPB_Data.Jail_GetRootPropertyOfTypeString(self.GetDataObject(), asPropertyName)
endFunction

Form function GetRootPropertyOfTypeForm(string asPropertyName)
    return RPB_Data.Jail_GetRootPropertyOfTypeForm(self.GetDataObject(), asPropertyName)
endFunction

;                       Global Root Properties                    
; =========================================================
bool function Global_GetRootPropertyOfTypeBool(int apPrisonDataObject, string asPropertyName) global
    return RPB_Data.Jail_GetRootPropertyOfTypeBool(apPrisonDataObject, asPropertyName)
endFunction

int function Global_GetRootPropertyOfTypeInt(int apPrisonDataObject, string asPropertyName) global
    return RPB_Data.Jail_GetRootPropertyOfTypeInt(apPrisonDataObject, asPropertyName)
endFunction

float function Global_GetRootPropertyOfTypeFloat(int apPrisonDataObject, string asPropertyName) global
    return RPB_Data.Jail_GetRootPropertyOfTypeFloat(apPrisonDataObject, asPropertyName)
endFunction

string function Global_GetRootPropertyOfTypeString(int apPrisonDataObject, string asPropertyName) global
    return RPB_Data.Jail_GetRootPropertyOfTypeString(apPrisonDataObject, asPropertyName)
endFunction

Form function Global_GetRootPropertyOfTypeForm(int apPrisonDataObject, string asPropertyName) global
    return RPB_Data.Jail_GetRootPropertyOfTypeForm(apPrisonDataObject, asPropertyName)
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
    Turns the Actor into an RPB_Prisoner and binds it to this Prison.

    Actor   @akActor: The actor to turn into a Prisoner
    bool?   @abDelayExecution: Whether to delay before obtaining a reference to the prisoner.
/;
RPB_Prisoner function MakePrisoner(Actor akActor, bool abDelayExecution = true)
    ; Cast the Prisoner spell (to bind the RPB_Prisoner instance script)
    Spell prisonerSpell = RPB_Utility.RPB_PrisonerSpell()
    akActor.AddSpell(prisonerSpell, false)

    ; Bind this Prison to the Prisoner (to retrieve it from RPB_Prisoner)
    RPB_StorageVars.SetIntOnForm("Prison ID", akActor, self.ID, "Jail")

    ; Delay execution before returning an instance of the prisoner, since we need to let the RPB_Prisoner script register this Prisoner
    if (abDelayExecution)
        Utility.Wait(0.2)
    endif

    RPB_Prisoner prisonerReference = self.GetPrisonerReference(akActor)

    ; The instance should be available by now, since after the spell is added, the script will register this actor as a Prisoner OnInitialize() through self.RegisterPrisoner()
    return prisonerReference
endFunction

function ImprisonActorImmediately(Actor akActor)
    RPB_Prisoner prisonerRef = self.MakePrisoner(akActor)

    if (!prisonerRef.AssignCell())
        Debug(akActor, "Prison::ImprisonActorImmediately", "Could not assign a cell to actor " + akActor)
        return
    endif

    prisonerRef.QueueForImprisonment()
    prisonerRef.MoveToCell()
    prisonerRef.ProcessWhenMoved()
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
    ; if (RPB_StorageVars.GetBool("["+ Hold +"]Jail::Infamy Recognized Threshold Message Sent"))
    ;     return
    ; endif

    if (__infamyRecognizedThresholdMsgSent)
        return
    endif

    __infamyRecognizedThresholdMsgSent = true

    PrisonManager.PrisonInfamyRecognizedThresholdNotification = true

    ; RPB_StorageVars.SetBool("["+ Hold +"]Jail::Infamy Recognized Threshold Message Sent", true)
    ; RPB_StorageVars.SetBool("Jail::Infamy Recognized Threshold Notification", true)

    if (config.ShouldDisplayInfamyNotifications && asNotification)
        debug.notification("You are now recognized as a criminal in " + Name)
        return
    endif

    debug.MessageBox("You are now recognized as a criminal in " + Name)
endFunction

function NotifyInfamyKnownThresholdMet(bool asNotification = false)
    ; if (RPB_StorageVars.GetBool("["+ Hold +"]Jail::Infamy Known Threshold Message Sent"))
    ;     return
    ; endif

    if (__infamyKnownThresholdMsgSent)
        return
    endif

    __infamyKnownThresholdMsgSent = true

    PrisonManager.PrisonInfamyKnownThresholdNotification = true


    ; RPB_StorageVars.SetBool("["+ Hold +"]Jail::Infamy Known Threshold Message Sent", true)
    RPB_StorageVars.SetBool("Jail::Infamy Known Threshold Notification", true)

    if (config.ShouldDisplayInfamyNotifications && asNotification)
        debug.notification("You are now a known criminal in " + Name)
        return
    endif

    debug.MessageBox("You are now a known criminal in " + Name)
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