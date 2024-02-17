Scriptname RPB_Prison extends ReferenceAlias  

import Math
import RealisticPrisonAndBounty_Config
import RPB_Utility

; ==========================================================
;                     Script References
; ==========================================================

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property Arrest
    RealisticPrisonAndBounty_Arrest function get()
        return Config.Arrest
    endFunction
endProperty


RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return Config.MiscVars
    endFunction
endProperty

RPB_PrisonManager property PrisonManager
    RPB_PrisonManager function get()
        return RPB_API.GetPrisonManager()
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

; ==========================================================
;                       Prison Identity
; ==========================================================

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
string property Name
    string function get()
        if (__name)
            return __name
        endif

        if (!__name)
            __name = self.GetRootPropertyOfTypeString("Name")
        endif

        if (!__name)
            __name = PrisonLocation.GetName()
        endif

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
        LogProperty(none, "Prison::Prisoners", "Initialized with a value of: " + __prisoners)
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

function Notify(string asMessage, bool abCondition = true)
    Config.NotifyJail(asMessage, abCondition)
endFunction

RPB_Prison function GetPrisonForHold(string asHold) global
    RPB_Prison prison = (RPB_API.GetPrisonManager()).GetPrison(asHold)
    return prison
endFunction

RPB_Prison function GetPrisonForImprisonedActor(Actor akImprisonedActor) global
    RPB_PrisonManager _prisonManager = GetFormFromMod(0x1B825) as RPB_PrisonManager
    RPB_Prison prisonForPrisoner    = _prisonManager.GetPrisonForBoundPrisoner(akImprisonedActor)

    return prisonForPrisoner
endFunction

function BindPrisonerToPrison(RPB_Prisoner akPrisoner, RPB_Prison akPrison) global
    JDB.solveIntSetter(".rpb_prison.prisoners." + akPrisoner.GetIdentifier(), akPrison.GetID(), true)
endFunction

RPB_Prison function GetPrisonForBoundPrisoner(Actor akPrisonerActor)
    int prisonAliasID = JDB.solveInt(".rpb_prison.prisoners." + akPrisonerActor.GetFormID()) ; returns the ID of the Prison alias
    return (self.GetOwningQuest()).GetAlias(prisonAliasID) as RPB_Prison
endFunction

Form[] function GetPrisonersInAllPrisons() global
    int prisonersObj = JDB.solveObj(".rpb_prison.prisoners") ; Should return a int[] with the Prisoners FormID
    return JArray.asFormArray(prisonersObj)
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

bool function HasPrisoners(RPB_JailCell akPrisonCell = none)

endFunction

bool function HasFemalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyFemales = false)

endFunction

bool function HasMalePrisoners(RPB_JailCell akPrisonCell = none, bool abOnlyMales = false)

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
    apPrisoner.JailCell.RemovePrisoner(apPrisoner)

    ; Unregister the prisoner from prison
    self.UnregisterPrisoner(apPrisoner)
endFunction

string function GetTimeOfArrestFormatted(RPB_Prisoner apPrisoner)
    int day      = apPrisoner.DayOfArrest
    int month    = apPrisoner.MonthOfArrest
    int year     = apPrisoner.YearOfArrest

    return RPB_Utility.GetFormattedDate(day, month, year, apPrisoner.HourOfArrest, apPrisoner.MinuteOfArrest)
endFunction

string function GetTimeOfImprisonmentFormatted(RPB_Prisoner apPrisoner)
    int day      = apPrisoner.DayOfImprisonment
    int month    = apPrisoner.MonthOfImprisonment
    int year     = apPrisoner.YearOfImprisonment

    return RPB_Utility.GetFormattedDate(day, month, year, apPrisoner.HourOfImprisonment, apPrisoner.MinuteOfImprisonment)
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
            Debug("Prison::GetEmptyJailCells", "Cell: " + jailCellRef + ", IsEmpty: " + jailCellRef.IsEmpty + ", Gender: " + jailCellRef.IsGenderExclusive)
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
            Debug("Prison::GetAvailableJailCells", "Cell: " + jailCellRef + ", IsAvailable: " + jailCellRef.IsAvailable + ", Gender: " + jailCellRef.IsGenderExclusive)
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

bool function HasFemaleOnlyCells()

endFunction

bool function HasMaleOnlyCells()

endFunction

bool function AssignPrisonerToCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    if (!akJailCell.IsAvailable)
        self.OnPrisonerCellAssignFail(apPrisoner, akJailCell)
        return false
    endif

    akJailCell.OnPrisonerEnter(apPrisoner)
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
    int prisonersAwaitingRelease = 0

    int i = 0
    while (i < Prisoners.Count)
        RPB_Prisoner currentPrisoner = Prisoners.AtIndex(i)

        if (currentPrisoner && !currentPrisoner.IsEffectActive)
            prisonersAwaitingRelease += 1
            ; Maybe take into account possible bounty gain and infamy updates

            if (currentPrisoner.IsSentenceServed)
                ; Release Prisoner
                Debug("Prison::AwaitPrisonersRelease", "Released Prisoner:  " + currentPrisoner + currentPrisoner.GetPrisoner())
                currentPrisoner.Release()
                ; checkedPrisoners[i] = none
            else
                int timeServedDays  = currentPrisoner.GetTimeServed("Days")
                int timeLeftDays    = currentPrisoner.GetTimeLeftInSentence("Days")
                ; Debug("Prison::AwaitPrisonersRelease", "Prisoner:  " + currentPrisoner.GetActor() + " has not served their sentence yet ("+ timeServedDays + " days served, " +  timeLeftDays +" days left).")
                ; Debug("Prison::AwaitPrisonersRelease", currentPrisoner + " " + currentPrisoner.GetActor() + " ("+ currentPrisoner.GetSex(true) +")" + " has not served their sentence yet in "+ Hold +".")
            endif
        endif
        i += 1
    endWhile
    
    if (prisonersAwaitingRelease > 0)
        Debug("Prison::AwaitPrisonersRelease", "Awaiting release for " + prisonersAwaitingRelease + " prisoners in " + Hold)
    endif
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
        Debug("Prison::OnPrisonPeriodicUpdate", "Cell " + theCell + ": " + debugInfo)
        i += 1
    endWhile

    Debug("Prison::OnPrisonPeriodicUpdate", "Prisoners in " + Hold + ": " + Prisoners.Count)

    ; ; TODO: If all the prisoners do not require processing anymore, unregister the update here

    ; Debug("Prison::OnPrisonPeriodicUpdate", "Prisoners in " + Hold + ": " + prisonerCount)
endEvent

event OnPrisonerRegistered(RPB_Prisoner apPrisoner)
    PrisonManager.OnPrisonRegisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerUnregistered(RPB_Prisoner apPrisoner)
    PrisonManager.OnPrisonUnregisteredPrisoner(self, apPrisoner)
endEvent

event OnPrisonerTimeElapsed(RPB_Prisoner apPrisoner)

endEvent

event OnPrisonerDying(RPB_Prisoner apPrisoner, Actor akKiller)
    
endEvent

event OnPrisonerDeath(RPB_Prisoner apPrisoner, Actor akKiller)

endEvent

event OnEscortPrisonerToJailEnd(RPB_Actor apActor, Actor akEscort)
    ; Retrieve or make the Actor a Prisoner
    RPB_Prisoner prisonerRef = RPB_Utility.ame_if (apActor as RPB_Prisoner, apActor, (apActor as RPB_Arrestee).MakePrisoner()) as RPB_Prisoner

    prisonerRef.SetReleaseLocation()    ; Set the release location for this prisoner
    prisonerRef.SetBelongingsContainer()     ; Set the container of where the prisoner's items will be confiscated to
    prisonerRef.AssignCell()            ; Assign a prison cell to this prisoner

    ; if should be stripped
    prisonerRef.StartStripping(akEscort)
endEvent

event OnEscortPrisonerToCellEnd(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell, Actor akEscort)
    if (apPrisoner.IsStrippedNaked || apPrisoner.IsStrippedToUnderwear)
        return
    endif
    
    apPrisoner.Imprison()
    ; apPrisoner.StartStripping(akEscort)
endEvent

event OnPrisonerStripBegin(RPB_Prisoner apPrisoner, Actor akStripper)
    apPrisoner.Strip()
endEvent

event OnPrisonerStripEnd(RPB_Prisoner apPrisoner, Actor akStripper)
    if (!apPrisoner.IsInCell)
        apPrisoner.StartRestraining(akStripper)
        apPrisoner.EscortToCell(akStripper)
    endif

    Debug("Prison::OnPrisonerStripEnd", "event invoked")
endEvent

event OnPrisonerReleased(RPB_Prisoner apPrisoner)

endEvent

event OnGuardDeath(RPB_Guard akGuard, Actor akKiller)

endEvent

event OnCellDoorOpen(RPB_JailCell akPrisonCell, Actor akOpener)

endEvent

event OnCellDoorClosed(RPB_JailCell akPrisonCell, Actor akCloser)
    
endEvent

event OnJailCellAssigned(RPB_JailCell akJailCell, RPB_Prisoner akPrisoner)
    ; if (akJailCell.IsEmpty)
    ;     akJailCell.SetExclusiveToPrisonerSex(akPrisoner)
    ; endif
endEvent

event OnPrisonerCellAssigned(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)
    akJailCell.OnPrisonerEnter(apPrisoner)
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

endEvent

event OnPrisonerLeaveCell(RPB_Prisoner apPrisoner, RPB_JailCell akJailCell)

endEvent

; ==========================================================
;                           Scenes
; ==========================================================

function EscortPrisonerToCell(RPB_Prisoner apPrisoner, Actor akEscort)
    ; The marker where the escort will stand, waiting for the prisoner to enter the cell.
    ObjectReference outsideJailCellEscortWaitingMarker = apPrisoner.JailCell.GetRandomMarker("Exterior") as ObjectReference

    Config.SceneManager.StartEscortToCell( \
        akEscortLeader              = akEscort, \
        akEscortedPrisoner          = apPrisoner.GetActor(), \
        akJailCellMarker            = apPrisoner.JailCell, \
        akJailCellDoor              = apPrisoner.JailCell.CellDoor, \ 
        akEscortWaitingMarker       = outsideJailCellEscortWaitingMarker \ 
    )
endFunction

function BeginStrippingPrisoner(RPB_Prisoner apPrisoner, Actor akStripper)
    Config.SceneManager.StartStripping_02( \
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

    RPB_Utility.Debug("Prison::ConfigurePrison", "Name: " + self.Name + ", Hold: " + self.Hold + ", Faction: " + self.PrisonFaction + ", City: " + self.City)

    __isInitialized     = true

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

function AddPrisonCell(RPB_JailCell akPrisonCell)

endFunction

bool function BindCellToPrisoner(ObjectReference akJailCell, RPB_Prisoner akPrisoner)
    ; Add this jail cell to the prisoner for ease of access
    ; akPrisoner.BindCell(akJailCell) ; Bind the Prisoner to the Cell
    ; MiscVars.SetReference("["+ akPrisoner.GetIdentifier() +"]Cell", akJailCell) ; Bind the Prisoner to the Cell
    ; Debug(self.GetOwningQuest(), "Prison::BindCellToPrisoner", akJailCell + " jail cell bound to " + akPrisoner.GetActor())

    ; Get the door of the jail cell (the marker)
    ; ObjectReference cellDoor = GetNearestJailDoorOfType(GetJailBaseDoorID(Hold), akJailCell, 4000) ; this should return RPB_CellDoor (TODO: new save)

    RPB_JailCell jailCell = (akJailCell as RPB_JailCell)

    ; Registers the prisoner into this cell, to let the prison system know how many prisoners and of what gender are in a given cell
    ; jailCell.RegisterPrisoner(akPrisoner)

    ; Debug("Prison::BindCellToPrisoner", "CellDoor: " + cellDoor + ", JailCell: " + jailCell + ", WasInitialized: " + jailCell.WasInitialized())

    ; The bind process with this prison has already happened
    if (!jailCell.IsInitialized())
        ; Binds the jail cell to this Prison
        jailCell.BindPrison(self)
        jailCell.ScanCellDoor()
    endif

    ; ; Binds the jail cell to this Prison
    ; jailCell.BindPrison(self)

    ; Handle the events related to the prisoner entering the cell
    jailCell.OnPrisonerEnter(akPrisoner)

    if (jailCell.HasContainers)
        ; Get a random container, and add a lockpick to it
        Form lockpick = Game.GetForm(0xA)
        ObjectReference chosenContainer = jailCell.Containers[Utility.RandomInt(0, jailCell.Containers.Length - 1)] as ObjectReference
        chosenContainer.AddItem(lockpick, 1, true)
        Debug("Prison::BindCellToPrisoner", "Added 1 Lockpick to container " + chosenContainer + " ("+ chosenContainer.GetBaseObject().GetName() +")")
    endif

    if (jailCell.HasOtherProps)
        Form lockpick = Game.GetForm(0xA)
        ObjectReference chosenProp = jailCell.OtherProps[Utility.RandomInt(0, jailCell.OtherProps.Length - 1)] as ObjectReference
        chosenProp.PlaceAtMe(lockpick, 1)
        Debug("Prison::BindCellToPrisoner", "Placed 1 Lockpick near misc prop " + chosenProp + " ("+ chosenProp.GetBaseObject().GetName() +")")
    endif

    return true
    ; Now possible to get this prisoner's jail cell through: MiscVars.GetReference("["+ akPrisoner.GetIdentifier() +"]Cell")
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
    
                Debug("Prison::SetupCells", "Jail Cell: " + jailCell + " - " + "HasOption(Maximum Prisoners):" + jailCell.HasOption("Maximum Prisoners") + ", HasObjects(Beds): " + jailCell.HasObjects("Beds"))
    
                if (jailCell.ShouldPerformScan("Beds"))
                    jailCell.ScanBeds()
                endif
                
                if (jailCell.ShouldPerformScan("Containers"))
                    jailCell.ScanContainers()
                endif
    
                if (jailCell.ShouldPerformScan("Props"))
                    jailCell.ScanMiscProps()
                endif
    
                Debug("Prison::SetupCells", jailCell + " Maximum Prisoners: " + jailCell.MaxPrisoners)
            endif
        ; endif


        i += 1
    endWhile

    EndBenchmark(startBench, "Prison::SetupCells")
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
        Debug("Prison::GetJailCellBasedOnPriority", "Got empty cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)

    elseif (self.PrioritizeGenderCells)
        returnedCell = self.GetJailCellOfGender(asSex)
        Debug("Prison::GetJailCellBasedOnPriority", "Got gender exclusive cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)
    endif

        
    ; No priority
    ; Get empty cell first, if that fails, get a gender exclusive one, else get a random cell if @abAllowRandomCells is true
    if (returnedCell == none)
        returnedCell = self.GetEmptyJailCell()
        Debug("Prison::GetJailCellBasedOnPriority", "Got empty cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)
    endif

    if (returnedCell == none)
        returnedCell = self.GetJailCellOfGender(asSex)
        Debug("Prison::GetJailCellBasedOnPriority", "Got gender exclusive cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)

    endif

    if (returnedCell == none && abAllowRandomCells)
        returnedCell = self.GetRandomJailCell()
        Debug("Prison::GetJailCellBasedOnPriority", "Got random cell: " + returnedCell + ", Prisoner Gender: " + asSex, returnedCell != none)

    endif

    ; Could not return any cell, error here
    Debug("Prison::GetJailCellBasedOnPriority", "Could not retrieve any cell!  Prisoner Gender: " + asSex, returnedCell == none)

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

    Debug("Prison::RegisterPrisoner", "PrisonerList: " + Prisoners.GetKeys())

    return Prisoners.Exists(apPrisoner)
endFunction

function RegisterPrisonerTimeOfImprisonment(RPB_Prisoner apPrisoner)
    apPrisoner.SetFloat("Time of Imprisonment", RPB_Utility.GetCurrentTime(), "Jail")
    apPrisoner.SetFloat("Minute of Imprisonment", RPB_Utility.GetCurrentMinute(), "Jail")
    apPrisoner.SetFloat("Hour of Imprisonment", RPB_Utility.GetCurrentHour(), "Jail")
    apPrisoner.SetFloat("Day of Imprisonment", RPB_Utility.GetCurrentDay(), "Jail")
    apPrisoner.SetFloat("Month of Imprisonment", RPB_Utility.GetCurrentMonth(), "Jail")
    apPrisoner.SetFloat("Year of Imprisonment", RPB_Utility.GetCurrentYear(), "Jail")
    apPrisoner.SetBool("Imprisoned", true, "Jail")
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

    Debug("Prison::GetPrisonerReference", "Prisoner Reference: " + prisonerRef + ", akPrisoner: " + akPrisoner)
    Debug("Prison::GetPrisonerReference", "Prisoner Reference FormID: " + prisonerRef.GetActor().GetFormID() + ", Base ID: " + prisonerRef.GetActor().GetBaseObject().GetFormID())

    if (!prisonerRef)
        Error("Prison::GetPrisonerReference", "The Actor " + akPrisoner + " is not a prisoner or there was a state mismatch!")
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
;                            Test
; ==========================================================

Form[] function GetBedBaseObjects()
    Form bedRollHay01 = Game.GetFormEx(0x1899D)

endFunction

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

RPB_Prisoner function MakePrisoner(Actor akActor, bool abDelayExecution = true)
    ; Cast the Prisoner spell (to bind the RPB_Prisoner instance script)
    Spell prisonerSpell = GetFormFromMod(0x197D7) as Spell
    akActor.AddSpell(prisonerSpell, false)
    Debug("Prison::MakePrisoner", "MakePrisoner for " + akActor)

    ; Delay execution before returning an instance of the prisoner, since we need to let the RPB_Prisoner script register this Prisoner
    if (abDelayExecution)
        Utility.Wait(0.2)
    endif

    RPB_Prisoner prisonerReference = self.GetPrisonerReference(akActor)

    ; The instance should be available by now, since after the spell is added, the script will register this actor as a Prisoner OnInitialize() through self.RegisterPrisoner()
    return prisonerReference
endFunction

function ImprisonActorImmediately(Actor akActor)
    RPB_StorageVars.SetFormOnForm("Faction", akActor, self.PrisonFaction, "Arrest")
    RPB_StorageVars.SetFormOnForm("Arrestee", akActor, akActor, "Arrest")
    RPB_StorageVars.SetStringOnForm("Arrest Type", akActor, Arrest.ARREST_TYPE_TELEPORT_TO_CELL, "Arrest")
    RPB_StorageVars.SetStringOnForm("Hold", akActor, self.Hold, "Arrest")
    RPB_StorageVars.SetFloatOnForm("Time of Arrest", akActor, RPB_Utility.GetCurrentTime(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Minute of Arrest", akActor, RPB_Utility.GetCurrentMinute(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Hour of Arrest", akActor, RPB_Utility.GetCurrentHour(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Day of Arrest", akActor, RPB_Utility.GetCurrentDay(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Month of Arrest", akActor, RPB_Utility.GetCurrentMonth(), "Jail")
    RPB_StorageVars.SetFloatOnForm("Year of Arrest", akActor, RPB_Utility.GetCurrentYear(), "Jail")

    RPB_Prisoner prisonerRef = self.MakePrisoner(akActor)

    if (!prisonerRef.AssignCell())
        Debug(akActor, "Prison::ImprisonActorImmediately", "Could not assign a cell to actor " + akActor)
        akActor.Disable()
        return
    endif

    prisonerRef.QueueForImprisonment()
    prisonerRef.MoveToCell()
    prisonerRef.ProcessWhenMoved()
    prisonerRef.SetSentence(self.GetRandomSentence(0, 75))

    RPB_Utility.Debug("Prison::ImprisonActorImmediately", "TimeOfArrest: " + prisonerRef.TimeOfArrest)
endFunction

; ==========================================================
;                           States
; ==========================================================

; ==========================================================
;                            Debug
; ==========================================================

string function DEBUG_GetPrisonerSentenceInfo(RPB_Prisoner akPrisoner, bool abShort = false, bool abIncludeCellInfo = false)
    if (abShort)
        ; Time Served
        int timeServedDays           = akPrisoner.GetTimeServed("Days")
        int timeServedHours          = akPrisoner.GetTimeServed("Hours of Day")

        ; Time Left
        int timeLeftToServeDays      = akPrisoner.GetTimeLeftInSentence("Days")
        int timeLeftToServeHours     = akPrisoner.GetTimeLeftInSentence("Hours of Day")

        string sentenceString   = "Sentence: " + akPrisoner.Sentence + " Days"
        string timeServedString = timeServedDays + " Days, " + timeServedHours + " Hours"
        string timeLeftString   = timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours"
        
        return "{"+ sentenceString +", (Served: "+ timeServedString +"), (Left: "+ timeLeftString +")}" + string_if (abIncludeCellInfo, " (Cell: " + akPrisoner.Prison_GetReference("Cell") + ", Door: " + akPrisoner.Prison_GetReference("Cell Door") + ")")
    else
        ; Time Served
        int timeServedDays           = akPrisoner.GetTimeServed("Days")
        int timeServedHours          = akPrisoner.GetTimeServed("Hours of Day")
        int timeServedMinutes        = akPrisoner.GetTimeServed("Minutes of Hour")
        int timeServedSeconds        = akPrisoner.GetTimeServed("Seconds of Minute")

        ; Time Left
        int timeLeftToServeDays      = akPrisoner.GetTimeLeftInSentence("Days")
        int timeLeftToServeHours     = akPrisoner.GetTimeLeftInSentence("Hours of Day")
        int timeLeftToServeMinutes   = akPrisoner.GetTimeLeftInSentence("Minutes of Hour")
        int timeLeftToServeSeconds   = akPrisoner.GetTimeLeftInSentence("Seconds of Minute")

        return Hold + " Sentence: { \n\t" + \
            "Prisoner: "            + "(Name: " + akPrisoner.GetName() + ", Prisoner Reference: " + akPrisoner +  ", Actor Reference: " + akPrisoner.GetActor() + ")" + "\n\t" + \
            "Minimum Sentence: "    + MinimumSentence + " Days, \n\t" + \
            "Maximum Sentence: "    + MaximumSentence + " Days, \n\t" + \
            "Sentence: "            + akPrisoner.Sentence + " Days, \n\t" + \
            "Time of Arrest: "      + akPrisoner.TimeOfArrest + ", \n\t" + \
            "Time of Imprisonment: "+ akPrisoner.TimeOfImprisonment + ", \n\t" + \
            "Time Served: "         + akPrisoner.TimeServed + " ("+ (akPrisoner.TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"], \n\t" + \
            "Time Left: "           + akPrisoner.TimeLeftInSentence + " ("+ (akPrisoner.TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"], \n\t" + \
            "Release Time: "        + akPrisoner.ReleaseTime + "\n" + \
        " }"
    endif
endFunction

function DEBUG_ShowPrisonerSentenceInfo(RPB_Prisoner apPrisoner, bool abShort = false)
    string sentenceFormatted    = self.GetSentenceFormatted(apPrisoner)
    string timeServedFormatted  = self.GetTimeServedFormatted(apPrisoner)
    string timeLeftFormatted    = self.GetTimeLeftOfSentenceFormatted(apPrisoner)

    if (abShort)
        LogNoType(apPrisoner.GetName() + " in " + self.Name + " ("+ apPrisoner.JailCell.Identifier +"): { "+ "Sentence: " + sentenceFormatted + " | Time Served: " + timeServedFormatted + string_if (!apPrisoner.IsUndeterminedSentence, " | Time Left: " + timeLeftFormatted) +" }")
    else
        string minSentence = RPB_Utility.GetTimeFormatted(MinimumSentence)
        string maxSentence = RPB_Utility.GetTimeFormatted(MaximumSentence)

        LogNoType("\n" + "Prisoner in "+ self.Name + " ("+ apPrisoner.JailCell.Identifier +")" +": { \n\t" + \
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