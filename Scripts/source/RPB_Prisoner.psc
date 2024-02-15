Scriptname RPB_Prisoner extends RPB_Actor

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config
import Math

;/
    The Actor that has arrested this Arrestee.
    This may be null depending on whether the arrest was done through a captor or faction (if the latter, this is null).

    The reason this is not a property with the value of GetCasterActor() is the same as the one for the Arrestee.
    Once the MagicEffect is removed, this reference will be null and cannot be used in any function or event, this
    is using the same workaround.

    Additionally, the Caster may not be the Captor in the future, for instance if the Arrest is done through a Faction, there will
    be no Caster, or it will be the same as the Target, which would result in logic failure, this bypasses that problem too.

    The value is set through Initialize().
/;
; Actor captor ; To be changed, a prisoner shouldn't have a captor. The correct relation would be this prisoner to a prison, and multiple guards to a prison, not a prisoner
; Idea for the future: self.GetPrison().GetGuards() where the return type is RPB_Guard[], then each one could have prison cells assigned to them, or be selected at random to do some action
; Likewise, prisoners would be retrieved as such: self.GetPrison.GetPrisoners() where the return type is RPB_Prisoner[] and returns every prisoner in this particular prison by iterating through every prison cell.
; self.GetPrison() could return something like RPB_Prison or RPB_PrisonLocation, something akin to Faction
; This way, this prisoner script would no longer contain jailFaction or hold, since those would now be part of RPB_Prison

Actor property Captor
    Actor function get()
        return Prison_GetForm("Arrest Captor") as Actor
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
        return Prison_GetBool("Defeated", "Arrest")
    endFunction
endProperty

int property DefeatedBounty
    int function get()
        return Prison_GetInt("Bounty for Defeat", "Arrest")
    endFunction
endProperty

bool property ShouldBeFrisked
    bool function get()
        return true
    endFunction
endProperty

bool property ShouldBeStripped
    bool function get()
        return true
    endFunction
endProperty

int property StrippingThoroughness
    int function get()
        int modifier = Prison.StrippingThoroughnessModifier
        return Prison_GetInt("Stripping Thoroughness", "Stripping") + int_if (modifier > 0, Round(Bounty / modifier))
    endFunction
endProperty

ObjectReference property PrisonerBelongingsContainer
    ObjectReference function get()
        return Prison_GetReference("Prisoner Belongings Container")
    endFunction
endProperty

ObjectReference property TeleportReleaseLocation
    ObjectReference function get()
        return Prison_GetReference("Teleport Release Location")
    endFunction
endProperty

bool property IsImprisoned
    bool function get()
        return Prison_GetBool("Imprisoned")
    endFunction
endProperty

bool property IsInCell
    bool function get()
        return Prison_GetBool("In Cell")
    endFunction
endProperty

float property LastUpdate auto

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
        return Prison_GetFloat("Time of Arrest")
    endFunction
endProperty

float property TimeOfImprisonment
    float function get()
        return Prison_GetFloat("Time of Imprisonment")
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
        return Prison_GetInt("Sentence")
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

        return self.GetReleaseTime()
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

int property InfamyGainedPerUpdate
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
    int function get()
        return round(InfamyGainedDaily * TimeSinceLastUpdate)
    endFunction
endProperty

int property InfamyBountyPenalty
    int function get()
        float infamyTypePenalty = float_if (IsInfamyKnown, arrestVars.InfamyKnownPenalty, float_if (IsInfamyRecognized, arrestVars.InfamyRecognizedPenalty))
        return round(CurrentInfamy * infamyTypePenalty)
    endFunction
endProperty

bool property IsSentenceSet
    bool function get()
        return self.Sentence != 0
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

; Whether this prisoner should only be imprisoned in an empty cell
bool __onlyAllowImprisonmentInEmptyCell
bool property OnlyAllowImprisonmentInEmptyCell
    bool function get()
        return __onlyAllowImprisonmentInEmptyCell
    endFunction

    function set(bool value)
        if (value && (self.OnlyAllowImprisonmentInGenderCell || self.OnlyAllowImprisonmentInEmptyOrGenderCell))
            self.OnlyAllowImprisonmentInGenderCell          = false
            self.OnlyAllowImprisonmentInEmptyOrGenderCell   = false
        endif

        __onlyAllowImprisonmentInEmptyCell = value
    endFunction
endProperty

; Whether this prisoner should only be imprisoned in a gender exclusive cell
bool __onlyAllowImprisonmentInGenderCell
bool property OnlyAllowImprisonmentInGenderCell
    bool function get()
        return __onlyAllowImprisonmentInGenderCell
    endFunction

    function set(bool value)
        if (value && (self.OnlyAllowImprisonmentInEmptyCell || self.OnlyAllowImprisonmentInEmptyOrGenderCell))
            self.OnlyAllowImprisonmentInEmptyCell           = false
            self.OnlyAllowImprisonmentInEmptyOrGenderCell   = false
        endif

        __onlyAllowImprisonmentInGenderCell = value
    endFunction
endProperty

; Whether this prisoner should only be imprisoned in either an empty or gender exclusive cell
bool __onlyAllowImprisonmentInEmptyOrGenderCell
bool property OnlyAllowImprisonmentInEmptyOrGenderCell
    bool function get()
        return __onlyAllowImprisonmentInEmptyOrGenderCell
    endFunction

    function set(bool value)
        if (value && (self.OnlyAllowImprisonmentInEmptyCell || self.OnlyAllowImprisonmentInGenderCell))
            self.OnlyAllowImprisonmentInEmptyCell       = false
            self.OnlyAllowImprisonmentInGenderCell      = false
        endif

        __onlyAllowImprisonmentInEmptyOrGenderCell = value
    endFunction
endProperty

; Determines what type of jail cell should be assigned to this prisoner - called from RPB_Prison
function DetermineCellOptions()
    if (self.WillBeStrippedNaked || self.IsStrippedNaked)
        ; Only allow imprisonment in either empty cells or cells of the same gender where the prisoners are also stripped naked / possibly to underwear
        self.OnlyAllowImprisonmentInEmptyOrGenderCell = true

    elseif (self.WillBeStrippedToUnderwear || self.IsStrippedToUnderwear)
        ; Only allow imprisonment in either empty cells or cells of the same gender where the prisoners are also stripped to underwear / possibly naked
        self.OnlyAllowImprisonmentInEmptyOrGenderCell = true
    endif
endFunction

;/
    Assigns a jail cell to this prisoner
/;
bool function AssignCell()
    if (self.JailCell)
        Debug(this, "Prisoner::AssignCell", "A prison cell has already been assigned to prisoner " + this + ": [" +"Cell: " + self.JailCell + ", Door: " + self.JailCell.CellDoor + "]")
        return true
    endif

    ; Determine if prisoner will be stripped etc
    self.WillBeStrippedNaked = true

    RPB_JailCell assignedCell = Prison.RequestCellForPrisoner(self)

    if (assignedCell == none)
        ; Could not assign a cell to this prisoner, abort imprisonment?
        Debug(this, "Prisoner::AssignCell", "A jail cell could not be assigned to prisoner " + this + ", aborting imprisonment...!")
        self.Destroy() ; We might destroy this instance somewhere else, because in the case of failing to assign a cell, we may still want to try other imprisonment options (maybe transfer to another hold?)
        return false
    endif

    ; Actually bind this jail cell to the prisoner, it has been assigned.
    if (Prison.BindCellToPrisoner(assignedCell, self))
        Prison_SetReference("Cell", assignedCell)
    endif

    ; Debug(this, "Prisoner::AssignCell", this + " has been assigned a prison cell" + ": [\n" + \
    ;     "Cell: " + self.JailCell + "\n" + \
    ;     "Cell Door: " + self.JailCell.CellDoor + "\n" + \
    ; "]")

    return self.JailCell != none
endFunction

RPB_JailCell function GetCell()
    return Prison_GetReference("Cell") as RPB_JailCell
endFunction

function SetReleaseLocation(bool abIsTeleportLocation = true)
    if (abIsTeleportLocation)
        Prison_SetForm("Teleport Release Location", Config.GetJailTeleportReleaseMarker(self.GetPrisonHold()))
    endif
endFunction

function SetBelongingsContainer()
    Prison_SetForm("Prisoner Belongings Container", Prison.GetRandomPrisonerContainer("Belongings"))
    Debug(none, "Prison::SetBelongingsContainer", "Prisoner Belongings Container:  " + PrisonerBelongingsContainer)
endFunction

;/
    Releases this prisoner from jail
/;
function Release()
    Prison.ReleasePrisoner(self)
endFunction

function Restrain()
    self.Cuff()
endFunction

function ReturnBelongings()
    PrisonerBelongingsContainer.RemoveAllItems(this, false, true)
endFunction

function TeleportToRelease()
    self.MoveTo(TeleportReleaseLocation)
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
    Debug(self.GetActor(), "Prisoner::Uncuff", "Uncuffed " + this)
endFunction

bool function ShouldBeClothed()
    return false
endFunction

;/
    Main function that handles the imprisonment of this Prisoner.
/;
function Imprison()
    float startBench = StartBenchmark()

    self.SetBelongingsContainer()
    self.SetReleaseLocation()

    ; Utility.Wait(0.4)

    self.RegisterLastUpdate()
    self.MarkAsJailed()
    self.SetSentence(abShouldAffectBounty = false)
    
    if (Prison_GetBool("Infamy Enabled"))
        self.TriggerInfamyPenalty()
    endif

    if (wasMoved)
        self.ProcessWhenMoved() ; Only use when moved, not when escorted (Handle all events at once)
    endif

    self.SetTimeOfImprisonment()
    self.DetermineReleaseTimeAdditionalHours() ; For Release Time (Minimum, Maximum) intervals

    Debug(this, "Prisoner::Imprison", this + " Sentence: " + Sentence + " Days")

    ; Prison.SetSentence(self, Utility.RandomInt(Prison.MinimumSentence, Prison.MaximumSentence))

    Config.NotifyJail("You have been sentenced to "+ Sentence +" days in prison for " + self.GetHold(), self.IsPlayer())
    Config.NotifyJail(self.GetName() + " has been sentenced to "+ Sentence +" days in prison for " + self.GetHold(), !self.IsPlayer())
    ; ArrestVars.List("Jail")

    GotoState("Imprisoned") ; State when the prisoner is in the cell, check for updates for sentence, etc...
    RegisterForUpdateGameTime(1.0)
    EndBenchmark(startBench, "Ended Prisoner::Imprison")
endFunction

; ==========================================================
;                       Body Searching
; ==========================================================

; ==========================================================
;                    Frisking / Pat Down

function Frisk()

endFunction

; ==========================================================
;                    Clothing / Undressing

function Clothe()

endFunction

function Strip(bool abRemoveUnderwear = true)
    ; return
    this.RemoveAllItems(PrisonerBelongingsContainer, false, true)
    self.IncrementStat("Times Stripped")
    self.IsStrippedNaked = true
    Prison_SetBool("Stripped", true) ; No use for now, might be changed
    return

    Config.NotifyJail("Stripping Thoroughness: " + StrippingThoroughness)

    bool _isStrippedNaked = StrippingThoroughness >= 10

    ; Get underwear
    int underwearTopSlotMask    = GetSlotMaskValue(config.UnderwearTopSlot)
    int underwearBottomSlotMask = GetSlotMaskValue(config.UnderwearBottomSlot)

    Armor underwearTop      = this.GetWornForm(underwearTopSlotMask) as Armor
    Armor underwearBottom   = this.GetWornForm(underwearBottomSlotMask) as Armor

    ; Remove and put all the items in the prisoner's posession in the assigned prisoner container
    this.RemoveAllItems(PrisonerBelongingsContainer, false, true)

    ; TODO: Determine what is required to happen to have the Prisoner be in underwear

    ; Unequip anything currently held in the hands of this Prisoner
    UnequipHandsForActor(this)
    this.SheatheWeapon()

    self.IncrementStat("Times Stripped")
    Prison_SetBool("Stripped", true) ; No use for now, might be changed
endFunction

function PutUnderwear()
    
endFunction

function RemoveUnderwear()
    ; Get underwear
    int underwearTopSlotMask    = GetSlotMaskValue(config.UnderwearTopSlot)
    int underwearBottomSlotMask = GetSlotMaskValue(config.UnderwearBottomSlot)

    Armor underwearTop      = this.GetWornForm(underwearTopSlotMask) as Armor
    Armor underwearBottom   = this.GetWornForm(underwearBottomSlotMask) as Armor

    if (underwearTop)
        this.RemoveItem(underwearTop, 1, true, PrisonerBelongingsContainer)
    endif

    if (underwearBottom)
        this.RemoveItem(underwearBottom, 1, true, PrisonerBelongingsContainer)
    endif
endFunction

; ==========================================================
;                           Scenes
; ==========================================================

function StartRestraining(Actor akRestrainer)
    Debug(self.GetActor(), "Prisoner::StartRestraining", "StartRestraining called")

    Jail.SceneManager.StartRestrainPrisoner_02( \
        akGuard     = akRestrainer, \
        akPrisoner  = this \
    )
endFunction

function StartStripping(Actor akStripperGuard)
    Debug(self.GetActor(), "Prisoner::StartStripping", "Stripping " + this)
    
    Jail.SceneManager.StartStripping_02( \
        akStripperGuard     = akStripperGuard, \
        akStrippedPrisoner  = this \
    )
endFunction

function StartGiveClothing(Actor akClothingGiver)
    Debug(self.GetActor(), "Prisoner::StartGiveClothing", "StartGiveClothing called")

    Jail.SceneManager.StartGiveClothing( \
        akGuard     = akClothingGiver, \
        akPrisoner  = this \
    )
endFunction

function EscortToCell(Actor akEscort)
    Debug(self.GetActor(), "Prisoner::EscortToCell", "EscortToCell called")
    
    Form outsideCellGuardWaitingMarker = JailCell.GetRandomMarker("Exterior")
    Config.SceneManager.StartEscortToCell( \
        akEscortLeader              = akEscort, \
        akEscortedPrisoner          = this, \
        akJailCellMarker            = self.JailCell, \
        akJailCellDoor              = self.JailCell.CellDoor, \
        akEscortWaitingMarker       = outsideCellGuardWaitingMarker as ObjectReference \ 
    )
endFunction

; ==========================================================

; ==========================================================
;                          Sentence
; ==========================================================

int property MinuteOfArrest
    int function get()
        return Prison_GetInt("Minute of Arrest")
    endFunction
endProperty

int property HourOfArrest
    int function get()
        return Prison_GetInt("Hour of Arrest")
    endFunction
endProperty

int property DayOfArrest
    int function get()
        return Prison_GetInt("Day of Arrest")
    endFunction
endProperty

int property MonthOfArrest
    int function get()
        return Prison_GetInt("Month of Arrest")
    endFunction
endProperty

int property YearOfArrest
    int function get()
        return Prison_GetInt("Year of Arrest")
    endFunction
endProperty

int property MinuteOfImprisonment
    int function get()
        return Prison_GetInt("Minute of Imprisonment")
    endFunction
endProperty

int property HourOfImprisonment
    int function get()
        return Prison_GetInt("Hour of Imprisonment")
    endFunction
endProperty

int property DayOfImprisonment
    int function get()
        return Prison_GetInt("Day of Imprisonment")
    endFunction
endProperty

int property MonthOfImprisonment
    int function get()
        return Prison_GetInt("Month of Imprisonment")
    endFunction
endProperty

int property YearOfImprisonment
    int function get()
        return Prison_GetInt("Year of Imprisonment")
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


function SetTimeOfImprisonment()
    Prison_SetFloat("Time of Imprisonment", CurrentTime) ; Set the time of imprisonment
    Prison_SetInt("Minute of Imprisonment", RPB_Utility.GetCurrentMinute())
    Prison_SetInt("Hour of Imprisonment", RPB_Utility.GetCurrentHour())
    Prison_SetInt("Day of Imprisonment", RPB_Utility.GetCurrentDay())
    Prison_SetInt("Month of Imprisonment", RPB_Utility.GetCurrentMonth())
    Prison_SetInt("Year of Imprisonment", RPB_Utility.GetCurrentYear())
    Prison_SetBool("Imprisoned", true)
endFunction

int function GetReleaseTimeHour()
    int releaseTimeHour = (ReleaseTime - math.floor(ReleaseTime)) as int

    ; Get the release hour and minutes
    float releaseHourAndMinutes = releaseTimeHour / 0.0416

    int releaseMinutes = Round((releaseHourAndMinutes - math.floor(releaseHourAndMinutes)) * 60)

    return releaseMinutes
endFunction

function SetSentence(int aiSentence = 0, bool abShouldAffectBounty = true)
    if (Prison_GetBool("Sentence Set"))
        RPB_Utility.Debug("Prisoner::SetSentence", "A sentence has already been set for this prisoner ("+ self.GetIdentifier() +"). \nConsider using IncreaseSentence() or DecreaseSentence() instead.")
        return
    endif

    ; Set a sentence based on params
    Prison_SetInt("Sentence", \ 
        aiValue     = int_if (aiSentence > 0, aiSentence, self.GetSentenceFromBounty()), \
        aiMinValue  = Prison.MinimumSentence, \
        aiMaxValue  = Prison.MaximumSentence \
    )

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = Sentence * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        Prison_SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    endif

    Prison_SetBool("Sentence Set", true)
    
    self.OnSentenceSet(Sentence, CurrentTime)
endFunction

function IncreaseSentence(int aiDaysToIncreaseBy, bool abShouldAffectBounty = true)
    int previousSentence    = Sentence
    int newSentence         = previousSentence + Max(0, aiDaysToIncreaseBy) as int

    ; Set the sentence
    Prison_SetInt("Sentence", \ 
        aiValue     = Sentence + aiDaysToIncreaseBy, \
        aiMinValue  = Prison.MinimumSentence, \
        aiMaxValue  = Prison.MaximumSentence \
    )

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = Sentence * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        Prison_SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    endif

    self.OnSentenceChanged(previousSentence, newSentence, aiDaysToIncreaseBy > 0, abShouldAffectBounty)
endFunction

function DecreaseSentence(int aiDaysToDecreaseBy, bool abShouldAffectBounty = true)
    int previousSentence    = Sentence
    int newSentence         = previousSentence + Max(0, aiDaysToDecreaseBy) as int

    ; Set the sentence
    Prison_SetInt("Sentence", \ 
        aiValue     = Sentence - aiDaysToDecreaseBy, \
        aiMinValue  = Prison.MinimumSentence, \
        aiMaxValue  = Prison.MaximumSentence \
    )

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = Sentence * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        Prison_SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    endif

    self.OnSentenceChanged(previousSentence, newSentence, newSentence > previousSentence, abShouldAffectBounty)
endFunction

; int function GetTimeOfImprisonmentDay()

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

; ==========================================================
;                            States
; ==========================================================

; While this Prisoner is being escorted
state Escorting
endState

; While this Prisoner is imprisoned in their cell
state Imprisoned
    event OnBeginState()
        ; if (!Prison.IsReceivingUpdates()) ; if we dont destroy the instance in time, this will get called from Prison after processing queued prisoners, and since we didnt register the prisoner, this is a bug since it will report 0 prisoners
            Prison.RegisterForPrisonPeriodicUpdate(self)
        ; endif

        RPB_Utility.Debug("Prisoner::Imprisoned::OnBeginState", "Prison Faction: " + self.GetFaction())

        ; At this point, we can delete the prisoner's arrest state
        self.DestroyArrestState()
    endEvent

    event OnUpdateGameTime()
        if (Prison.EnableInfamy)
            self.UpdateInfamy()
        endif

        self.UpdateDaysImprisoned()

        if (self.IsSentenceServed) ; implementation is not finished
            ; Prison.SendReleaseRequest(self)
            self.Release()
            return
        endif

        ; DEBUG_ShowPrisonInfo()
        Prison.DEBUG_ShowPrisonerSentenceInfo(self)
        ; DEBUG_ShowSentenceInfo()

        self.RegisterLastUpdate()
        RegisterForSingleUpdateGameTime(1.0)
    endEvent
endState

; When this Prisoner gets released
state Released
endState

; When or while this Prisoner is escaping or has escaped
state Escape
endState

; ==========================================================
;                     Stats / Deleveling
; ==========================================================

int property SKILL_LOSS_HANDLING_ALL_SKILLS             = 0 autoreadonly
int property SKILL_LOSS_HANDLING_ALL_STAT_SKILLS        = 1 autoreadonly
int property SKILL_LOSS_HANDLING_ALL_PERK_SKILLS        = 2 autoreadonly
int property SKILL_LOSS_HANDLING_RANDOM_STAT_SKILL      = 3 autoreadonly
int property SKILL_LOSS_HANDLING_RANDOM_PERK_SKILL      = 4 autoreadonly
int property SKILL_LOSS_HANDLING_RANDOM                 = 5 autoreadonly

int function GetSkillLossHandlingType()
    string handleSkillLossOn = Prison_GetString("Handle Skill Loss")

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
    ; return Config.GetSkillLevelCap(asSkill)
    if (RPB_Utility.IsStatSkill(asSkill))
        RPB_Utility.Trace("Prisoner::GetMinimumSkillValue", "It's a stat skill: " + asSkill)
        return 50
    else
        RPB_Utility.Trace("Prisoner::GetMinimumSkillValue", "It's a perk skill: " + asSkill)
        return 10
    endif
endFunction

bool function ShouldDelevelSkills()
    int dayToStartLosingSkills  = Prison_GetInt("Day to Start Losing Skills")

    if (dayToStartLosingSkills != 1 && dayToStartLosingSkills >= self.TimeServed)
        ; Don't delevel, property is set to a specific day to start and the prisoner hasn't been in prison for that long yet.
        return false
    endif

    int randomChance    = Utility.RandomInt(0, 100)
    int skillLossChance = Prison_GetInt("Chance to Lose Skills")

    if (skillLossChance == 0)
        return false
    endif

    RPB_Utility.Debug("Prisoner::ShouldDelevelSkills", "randomChance: " + randomChance + ", skillLossChance: " + skillLossChance)

    return randomChance <= skillLossChance
endFunction

bool function DelevelSkill(string asSkill)
    if (RPB_Utility.IsPerkSkill(asSkill))
        asSkill = "Conjuration"
    endif

    int statValue               = this.GetBaseActorValue(asSkill) as int
    int configuredLossAmount    = Config.GetDelevelingSkillValue(asSkill)
    int newStatValue            = statValue - configuredLossAmount
    int minimumSkillValue       = self.GetMinimumSkillValue(asSkill)

    if (RPB_Utility.IsPerkSkill(asSkill))
        configuredLossAmount = 3 ; temporary
        newStatValue = statValue - configuredLossAmount
    endif

    if (newStatValue <= minimumSkillValue)
        ; Skill reached minimum level, don't delevel
        RPB_Utility.Debug("Prisoner::PerformDeleveling", "Did not delevel Skill " + asSkill + " as it has reached the minimum level!")
        return false
    endif

    this.SetActorValue(asSkill, newStatValue)
    RPB_Utility.Debug("Prisoner::PerformDeleveling", "Deleveling Skill " + asSkill + " ("+ "Was: " + statValue + ", Is: " + newStatValue + ")")
endFunction

function PerformDeleveling()
    int handlingType = self.GetSkillLossHandlingType()

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

        string randomStat = RPB_Utility.GetRandomSkill(skillType)

        if (self.ShouldDelevelSkills())
            self.DelevelSkill(randomStat)
        endif
    
    elseif (handlingType == SKILL_LOSS_HANDLING_ALL_STAT_SKILLS || \
            handlingType == SKILL_LOSS_HANDLING_ALL_PERK_SKILLS || \
            handlingType == SKILL_LOSS_HANDLING_ALL_SKILLS)

        string[] skills = RPB_Utility.GetAllSkills( \
            abIncludeStatSkills = (handlingType == SKILL_LOSS_HANDLING_ALL_STAT_SKILLS) || (handlingType == SKILL_LOSS_HANDLING_ALL_SKILLS), \
            abIncludePerkSkills = (handlingType == SKILL_LOSS_HANDLING_ALL_PERK_SKILLS) || (handlingType == SKILL_LOSS_HANDLING_ALL_SKILLS) \
        )

        int i = 0
        while (i < skills.Length)
            if (self.ShouldDelevelSkills())
                self.DelevelSkill(skills[i])
            endif
            i += 1
        endWhile
    endif
endFunction

; ==========================================================
;                            Utility
; ==========================================================

function UpdateInfamy()
    string city = Config.GetCityNameFromHold(self.GetHold())

    self.IncrementStat("Infamy Gained", InfamyGainedPerUpdate)

    Config.NotifyInfamy(InfamyGainedPerUpdate + " infamy gained in " + city + "'s prison", self.IsPlayer())
    Config.NotifyInfamy(self.GetName() + " has gained " + InfamyGainedPerUpdate + " infamy in " + city + "'s prison", !self.IsPlayer())

    if (IsInfamyKnown)
        Jail.NotifyInfamyKnownThresholdMet(self.GetHold(), Jail.HasInfamyKnownNotificationFired)

    elseif (IsInfamyRecognized)
        Jail.NotifyInfamyRecognizedThresholdMet(self.GetHold(), Jail.HasInfamyRecognizedNotificationFired)
    endif
endFunction

function UpdateLongestSentence()
    int currentLongestSentence = self.QueryStat("Longest Sentence")
    int newLongestSentence = int_if (currentLongestSentence < Sentence, Sentence, currentLongestSentence)
    self.SetStat("Longest Sentence", newLongestSentence)

    Debug(this, "Prisoner::UpdateLongestSentence", "[\n" + \ 
        "\t Current Longest Sentence: " + currentLongestSentence + "\n" + \
        "\t New Longest Sentence: " + newLongestSentence + "\n" + \
        "\t Sentence: " + Sentence + "\n" + \
    "]")
endFunction

function UpdateLargestBounty()
    int currentLargestBounty = self.QueryStat("Largest Bounty")
    int newLargestBounty = int_if (currentLargestBounty < Bounty, Bounty, currentLargestBounty)
    self.SetStat("Largest Bounty", newLargestBounty)

    Debug(this, "Prisoner::UpdateLargestBounty", "[\n" + \ 
        "\t Current Longest Bounty: " + currentLargestBounty + "\n" + \
        "\t New Longest Bounty: " + newLargestBounty + "\n" + \
        "\t Bounty: " + Bounty + "\n" + \
    "]")    
endFunction

function UpdateCurrentBounty()
    self.SetStat("Current Bounty", Bounty)

    Debug(this, "Prisoner::UpdateCurrentBounty", "[\n" + \ 
        "\t Current Bounty: " + self.QueryStat("Current Bounty") + "\n" + \
        "\t Bounty: " + Bounty + "\n" + \
    "]")        
endFunction

function UpdateTotalBounty()
    ; self.IncrementStat("Total Bounty", Bounty) ; wrong, giving wrong values
    self.SetStat("Total Bounty", Bounty)
    ; self.IncrementStat("Total Bounty", self.GetActiveBounty())

    Debug(this, "Prisoner::UpdateTotalBounty", "[\n" + \ 
        "\t Total Bounty: " + self.QueryStat("Total Bounty") + "\n" + \
        "\t Bounty: " + Bounty + "\n" + \
    "]")            
endFunction

; ==========================================================
;                       Temporary - Maybe
; ==========================================================

bool property IsQueuedForImprisonment auto

; Determines if at least a day has elapsed in prison
bool function HasDayElapsed()
    ; Add the time served from each update this runs
    accumulatedTimeServed += TimeSinceLastUpdate

    if (accumulatedTimeServed >= 1)
        return true
    endif

    return false
endFunction

function UpdateDaysImprisoned()
    ; if (self.HasDayElapsed())
    ;     Game.IncrementStat("Days Jailed", DaysSinceTimeOfImprisonment) ; Pause Stat Menu
    ;     self.IncrementStat("Days Jailed", DaysSinceTimeOfImprisonment) ; Hold Stat
        
    ;     accumulatedTimeServed -= DaysSinceTimeOfImprisonment ; Remove the counted days from accumulated time served (Get the fractional part if there's any - i.e: hours)
        
    ;     float accumulatedTimeRemaining = accumulatedTimeServed - DaysSinceTimeOfImprisonment
    ;     ; RPB_Utility.Debug("Prisoner::UpdateDaysImprisoned", "accumulatedTimeServed remaining: " + accumulatedTimeServed)
    ;     ; RPB_Utility.Debug("Prisoner::UpdateDaysImprisoned", "TimeOfImprisonment: " + TimeOfImprisonment)
    ;     RPB_Utility.Debug("Prisoner::UpdateDaysImprisoned", "Days Jailed: " + self.QueryStat("Days Jailed"))
    ;     self.OnDayPassed()
    ; endif

    ; Debug(none, "Prisoner::UpdateDaysImprisoned", "TimeServed: " + TimeServed + ", floor(TimeServed): " + floor(TimeServed))
    ; Debug(none, "Prisoner::UpdateDaysImprisoned", "Updating Days Jailed: " + floor(accumulatedTimeServed))
    ; Debug(none, "Prisoner::UpdateDaysImprisoned", "LastUpdate: " + LastUpdate)
    ; Debug(none, "Prisoner::UpdateDaysImprisoned", "TimeSinceLastUpdate: " + TimeSinceLastUpdate)
endFunction

function SetEscaped()
    Prison_SetBool("Escaped", true)
    self.IncrementStat("Times Escaped")
    
    if (self.IsPlayer())
        Game.IncrementStat("Jail Escapes")
    endif

    this.SetAttackActorOnSight()
endFunction

bool wasMoved
function ProcessWhenMoved()
    if (self.ShouldBeFrisked)
        self.Frisk()
    endif

    if (self.ShouldBeStripped)
        self.Strip()
    endif
endFunction

function MoveToCell(bool abBeginImprisonment = true)
    wasMoved = true

    this.MoveTo(self.JailCell)

    if (abBeginImprisonment)
        if (Prison.IsPrisonerQueuedForImprisonment(self))
            Prison.RegisterForQueuedImprisonment()
        else
            self.Imprison()
        endif
    endif

endFunction

function QueueForImprisonment()
    Prison.QueuePrisonerForImprisonment(self)
endFunction

function QueueForScene() ; TODO: Implementation, should be used for Scenes where every prisoner may take part of, so a queue system must be created in order for the same Scene to be executed for each prisoner.
    ; Implementation can be Release scene, Stripping / Frisking scene, etc... Any scene that a prisoner can be a part of when they are inside the cell.
endFunction

function MarkAsJailed()
    Prison_SetBool("Imprisoned", true)
    self.IncrementStat("Times Jailed") ; Increment the "Times Jailed" stat for this Hold

    if (self.IsPlayer())
        Game.IncrementStat("Times Jailed") ; Increment the "Times Jailed" in the regular vanilla stat menu.
    endif
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

function TriggerInfamyPenalty()

endFunction

; ==========================================================

function MoveToCaptor()
    this.MoveTo(captor)
endFunction

bool __fastForwardedToRelease
function FastForwardToRelease()
    ; if (__fastForwardedToRelease)
    ;     return false
    ; endif

    ; If the Release must fall in between Minimum and Maximum release hours, set the hour to the minimum before passing the days.
    if (self.HasReleaseTimeExtraHours())
        RPB_Utility.SetGameHour(Prison.ReleaseTimeMinimumHour)
        RPB_Utility.Debug("Prisoner::FastForwardToRelease", "Setting Game Hour to Release Time Minimum Hour: " + RPB_Utility.GetTimeAs12Hour(Prison.ReleaseTimeMinimumHour))
    endif

    int timeLeft = Math.Ceiling(TimeLeftInSentence)
    RPB_Utility.PassTimeInDays(timeLeft)
    Game.IncrementStat("Days Jailed", timeLeft)
    self.IncrementStat("Days Jailed", timeLeft) ; Hold Stat

    float currentTimeBeforeChanges = CurrentTime
    __currentTimeOverride = CurrentTime + timeLeft

    RPB_Utility.Debug("Prisoner::FastForwardToRelease", "CurrentTime: " + currentTimeBeforeChanges + ", timeLeft: " + timeLeft + ", currentTimeOverride: " + __currentTimeOverride + ", TimeLeftInSentence: " + TimeLeftInSentence)

    __fastForwardedToRelease = true
endFunction

; function DetermineReleaseTimeAdditionalHours()
;     RPB_Utility.Debug("Prisoner::DetermineReleaseTimeAdditionalHours", "ReleaseTime: " + ReleaseTime)
;     float currentGameHour = (Game.GetFormEx(0x38) as GlobalVariable).GetValue() ; 13.50 = 1:30 PM
;     float oneGameHour = 0.04166666666666666666666666666667


;     RPB_Utility.Debug("Prisoner::DetermineReleaseTimeAdditionalHours", "Prison.ReleaseTimeMinimumHour: " + Prison.ReleaseTimeMinimumHour + ", Prison.ReleaseTimeMaximumHour: " + Prison.ReleaseTimeMaximumHour)
;     ; If the release time window has already passed
;     if (currentGameHour > Prison.ReleaseTimeMaximumHour)
;         __additionalReleaseHours += 1 + (Prison.ReleaseTimeMinimumHour * oneGameHour) ; Add a day and the desired hour for release (taken from Minimum Hour)
;         RPB_Utility.Debug("Prisoner::DetermineReleaseTimeAdditionalHours", "(After Calculation) ReleaseTime: " + ReleaseTime)
;     endif
; endFunction

function DetermineReleaseTimeAdditionalHours()
    RPB_Utility.Debug("Prisoner::DetermineReleaseTimeAdditionalHours", "ReleaseTime: " + ReleaseTime)
    float currentGameHour = (Game.GetFormEx(0x38) as GlobalVariable).GetValue() ; 13.50 = 1:30 PM

    RPB_Utility.Debug("Prisoner::DetermineReleaseTimeAdditionalHours", "Prison.ReleaseTimeMinimumHour: " + Prison.ReleaseTimeMinimumHour + ", Prison.ReleaseTimeMaximumHour: " + Prison.ReleaseTimeMaximumHour)
    ; If the release time window has already passed
    if (currentGameHour > Prison.ReleaseTimeMaximumHour)
        __hasExtraReleaseTimeHours = true
    endif
endFunction

float function GetReleaseTime(bool abIncludeMinutes = true)
    float oneGameHour = 0.04166666666666666666666666666667

    if (abIncludeMinutes)
        return TimeOfImprisonment + (oneGameHour * 24 * Sentence)
    endif

    return floor(TimeOfImprisonment) + (oneGameHour * 24 * Sentence)
endFunction

float function GetReleaseTimeExtraHours()
    float gameHour = 0.04166666666666666666666666666667
    return 1 + (Prison.ReleaseTimeMinimumHour * gameHour) ; Add 1 day and round to the time configured by Prison.ReleaseTimeMinimumHour
endFunction

bool __hasExtraReleaseTimeHours
bool function HasReleaseTimeExtraHours()
    return __hasExtraReleaseTimeHours
endFunction

bool function IsReleaseOnWeekend()
    int releaseDate     = RPB_Utility.GetDateFromDaysPassed(DayOfImprisonment, MonthOfImprisonment, YearOfImprisonment, Sentence)
    int releaseDay      = RPB_Utility.GetStructMemberInt(releaseDate, "day")
    int releaseMonth    = RPB_Utility.GetStructMemberInt(releaseDate, "month")
    int releaseYear     = RPB_Utility.GetStructMemberInt(releaseDate, "year")

    int dayOfWeek = RPB_Utility.CalculateDayOfWeek(releaseDay, releaseMonth, releaseYear)
    RPB_Utility.Debug("Prisoner::IsReleaseOnWeekend", "releaseDate: " + releaseDay + "/" + releaseMonth + "/" + releaseYear + ", IsWeekend: " + RPB_Utility.IsWeekend(releaseDay, releaseMonth, releaseYear) + ", Day of Week: " + RPB_Utility.GetDayOfWeekName(dayOfWeek))
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

; bool function HasAdditionalReleaseTimeHours()
;     return __additionalReleaseHours > 0
; endFunction

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
    RPB_Arrestee arresteeRef = Arrest.MakeArrestee(this)
    ;/ arresteeRef.SetArrestParameters( \
        asArrestHold        = newArrestHold, \
        akArrestCaptor      = newArrestCaptor \
        akArrestFaction     = newArrestFaction, \
    )/;

    return arresteeRef
endFunction

; ==========================================================
;                           Events
; ==========================================================

event OnInitialize()
    ; Prison.RegisterForPrisonPeriodicUpdate(self)

    if (NPC_RestorePrisonerState())
        ; Actor was already a prisoner, do not initialize normally and instead proceed to restoring their previous state
        ; Prison.RegisterPrisoner(self) ; Registers this prisoner into the prisoner list since they were unregistered OnDestroy()
        self.RegisterForTrackedStats()
        return
    endif

    if (!self.IsEnabledForBackgroundUpdates)
        Prison.RegisterPrisoner(self) ; Registers this prisoner into the prisoner list
    endif

    self.RegisterSleepEvents = true
    ; Debug(this, "Prisoner::OnInitialize", "Initialized Prisoner, this: " + this)
    self.RegisterForTrackedStats()
    self.LockPrisonerSettings()
endEvent

bool property IsEnabledForBackgroundUpdates
    bool function get()
        return Prison_GetBool("IsEnabledForBackgroundUpdates")
    endFunction

    function set(bool value)
        Prison_SetBool("IsEnabledForBackgroundUpdates", value)
    endFunction
endProperty

event OnDestroy()
    if (!self.IsPlayer())
        self.NPC_SavePrisonerState()

        if (!Prison.IsReceivingUpdates()) ; if we dont destroy the instance in time, this will get called from Prison after processing queued prisoners, and since we didnt register the prisoner, this is a bug since it will report 0 prisoners
            Prison.RegisterForPrisonPeriodicUpdate(self)
        endif
    endif

    ; We don't unregister the prisoner (remove from the AME list) because OnDestroy will get called as soon as the Player is out of range, meaning it's not a proper way to handle the destruction of the object
    ; Prison.UnregisterPrisoner(self) ; Remove this Actor from the AME list since they are no longer a prisoner
    self.UnregisterForTrackedStats()
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    
endEvent

event OnDying(Actor akKiller)
    Prison.OnPrisonerDying(self, akKiller)
endEvent

event OnDeath(Actor akKiller)
    Prison.OnPrisonerDeath(self, akKiller)
endEvent

;/
    Handles what happens when this Prisoner receives additional active bounty.
/;
event OnBountyGained()
    self.UpdateSentence()
    self.UpdateCurrentBounty()
    self.UpdateLargestBounty()
    self.UpdateTotalBounty()
endEvent

event OnSentenceSet(int aiSentence, float afAtWhatTime)
    self.UpdateLongestSentence()
endEvent

event OnSentenceChanged(int aiOldSentence, int aiNewSentence, bool abHasSentenceIncreased, bool abSentenceAffectsBounty)
    if (abHasSentenceIncreased)
        int daysIncreasedBy = aiNewSentence - aiOldSentence
        Config.NotifyJail("Your sentence was increased by " + daysIncreasedBy + " days.")
        self.UpdateLongestSentence()
    endif
endEvent

; Triggered whenever a full day has passed
event OnDayPassed()
    self.PerformDeleveling()
endEvent

event OnStatChanged(string asStatName, int aiValue)
    if (asStatName == Prison.Hold + " Bounty") ; If there's bounty gained in the current prison hold
        self.OnBountyGained()
        ; Maybe inform the prisoner of their new sentence and have them escorted out of the cell to be frisked/stripped if they are not
    endif

    ; Debug(this, "Prisoner::OnStatChanged", "Stat " + asStatName + " has been changed to " + aiValue)
endEvent

event OnSleepStart(float afSleepStartTime, float afSleepEndTime)
    ; if (self.ShouldFastForwardToRelease)
        self.FastForwardToRelease()
        Prison.Notify("Fast forwarded to Release")
        Prison.Notify("Sleep Start is: " + afSleepStartTime + ", Sleep End is: " + afSleepEndTime)
    ; endif
endEvent

; ==========================================================
;                          Management
; ==========================================================

function Destroy()
    ; TODO: Unset all properties related to this Prisoner
    Prison.UnregisterPrisoner(self)
endFunction

;/
    Destroys the prisoner's arrest state, as they are now a prisoner and the arrest state is not required anymore.
/;
function DestroyArrestState()
    RPB_Arrestee arrestState = RPB_Arrestee.GetStateForPrisoner(self)

    Debug(none, "Prisoner::DestroyArrestState", "Prison Hold from Arrest Vars: " + Prison_GetString("Hold", "Arrest"))

    if (arrestState)
        arrestState.Destroy()
    endif
endFunction

;/
    Registers the last update for the prisoner, 
    this is a crucial variable used to determine updated sentences, infamy gained, and so on...
/;
function RegisterLastUpdate()
    LastUpdate = Utility.GetCurrentGameTime()
endFunction


function NPC_RestoreImprisonment()
    if (Prison_GetBool("Infamy Enabled"))
        self.TriggerInfamyPenalty()
    endif

    self.ProcessWhenMoved() ; Only use when moved, not when escorted (Handle all events at once)

    Config.NotifyJail(self.GetName() + " still has "+ self.GetTimeLeftInSentence("Days") +" days left in prison for " + self.GetHold())

    ; ArrestVars.List("Jail")
    GotoState("Imprisoned") ; State when the prisoner is in the cell, check for updates for sentence, etc...
    RegisterForUpdateGameTime(1.0)
endFunction

;/
    Restores this ActiveMagicEffect on the imprisoned NPC, if they exist and are imprisoned.

    Since ActiveMagicEffects dispel after the Player is far away enough to the target Actor, we
    must re-apply the effect and restore the state previous to reference destruction for NPC's.
/;
bool function NPC_RestorePrisonerState()
    if (Prison_GetBool("ShouldRestorePrisonerState"))
        self.NPC_RestoreImprisonment()

        ; Unset the flag so the state can be restored again at re-initialization upon being destroyed
        Prison_SetBool("ShouldRestorePrisonerState", false)
    endif
endFunction

function NPC_SavePrisonerState()
    Prison_SetBool("ShouldRestorePrisonerState", true)
    return
    ; Prison_SetInt("Sentence",               self.Sentence)
    ; Prison_SetFloat("Time of Arrest",       self.TimeOfArrest)
    ; Prison_SetFloat("Time of Imprisonment", self.TimeOfImprisonment)

    ; ; Set flag to know whether to restore the state or not
    ; Prison_SetBool("ShouldRestorePrisonerState", true)

    ; Debug(this, "Prisoner::NPC_SavePrisonerState", "Saving NPC Prisoner state..." + "\n" + \
    ;     "\t Sentence: " + self.Sentence + "\n" + \
    ;     "\t Time of Arrest: " + self.TimeOfArrest + "\n" + \
    ;     "\t Time Of Imprisonment: " + self.TimeOfImprisonment + "\n" + \
    ;     "\t Release Time: " + self.ReleaseTime + "\n" \
    ; )

endFunction

bool hasSettingsLocked
;/
    Locks the prisoner's settings configured in the MCM for the Prison they are housed in.

    This makes it possible to change the MCM options while imprisoned, and they will have no change
    because they were already set for this Prisoner, guaranteeing that this Prisoner's state will not change while they are in prison.
/;
function LockPrisonerSettings()
    ; Infamy
    Prison_SetBool("Infamy Enabled",                                Prison.EnableInfamy)
    Prison_SetFloat("Infamy Recognized Threshold",                  Prison.InfamyRecognizedThreshold)
    Prison_SetFloat("Infamy Known Threshold",                       Prison.InfamyKnownThreshold)
    Prison_SetFloat("Infamy Gained Daily from Current Bounty",      Prison.InfamyGainedDailyOfCurrentBounty)
    Prison_SetFloat("Infamy Gained Daily",                          Prison.InfamyGainedDaily)
    Prison_SetFloat("Infamy Gain Modifier (Recognized)",            Prison.InfamyGainModifierRecognized)
    Prison_SetFloat("Infamy Gain Modifier (Known)",                 Prison.InfamyGainModifierKnown)
    ; Frisking
    Prison_SetBool("Allow Frisking",                                Prison.AllowFrisking, "Frisking") ; Change all to Prison or Jail prefix later
    Prison_SetInt("Bounty for Frisking",                            Prison.MinimumBountyForFrisking, "Frisking")
    Prison_SetInt("Frisking Thoroughness",                          Prison.FriskingThoroughness, "Frisking")
    Prison_SetBool("Confiscate Stolen Items",                       Prison.ConfiscateStolenItemsOnFrisk, "Frisking")
    Prison_SetBool("Strip if Stolen Items Found",                   Prison.StripIfStolenItemsFoundOnFrisk, "Frisking")
    Prison_SetInt("Minimum No. of Stolen Items Required",           Prison.MinimumNumberOfStolenItemsRequiredToStripOnFrisk, "Frisking")
    ; Stripping
    Prison_SetBool("Allow Stripping",                               Prison.AllowStripping, "Stripping") ; Change all to Prison or Jail prefix later
    Prison_SetString("Handle Stripping On",                         Prison.HandleStrippingOn, "Stripping")
    Prison_SetInt("Bounty to Strip",                                Prison.MinimumBountyToStrip, "Stripping")
    Prison_SetInt("Violent Bounty to Strip",                        Prison.MinimumViolentBountyToStrip, "Stripping")
    Prison_SetInt("Sentence to Strip",                              Prison.MinimumSentenceToStrip, "Stripping")
    Prison_SetInt("Stripping Thoroughness",                         Prison.StrippingThoroughness, "Stripping")
    Prison_SetInt("Stripping Thoroughness Modifier",                Prison.StrippingThoroughnessModifier, "Stripping")
    ; Clothing
    Prison_SetBool("Allow Clothing",                                Prison.AllowClothing, "Clothing") ; Change all to Prison or Jail prefix later
    Prison_SetString("Handle Clothing On",                          Prison.HandleClothingOn, "Clothing")
    Prison_SetInt("Maximum Bounty to Clothe",                       Prison.MaximumBountyClothing, "Clothing")
    Prison_SetInt("Maximum Violent Bounty to Clothe",               Prison.MaximumViolentBountyClothing, "Clothing")
    Prison_SetInt("Maximum Sentence to Clothe",                     Prison.MaximumSentence, "Clothing")
    Prison_SetBool("Clothe when Defeated",                          Prison.ClotheWhenDefeated, "Clothing")
    Prison_SetString("Outfit",                                      Prison.ClothingOutfit, "Clothing")
    ; Prison
    Prison_SetInt("Bounty Exchange",                                Prison.BountyExchange)
    Prison_SetInt("Bounty to Sentence",                             Prison.BountyToSentence)
    Prison_SetInt("Minimum Sentence",                               Prison.MinimumSentence)
    Prison_SetInt("Maximum Sentence",                               Prison.MaximumSentence)
    Prison_SetFloat("Cell Search Thoroughness",                     Prison.CellSearchThoroughness)
    Prison_SetString("Cell Lock Level",                             Prison.CellLockLevel)
    Prison_SetBool("Fast Forward",                                  Prison.FastForward)
    Prison_SetFloat("Day to Fast Forward From",                     Prison.DayToFastForwardFrom)
    Prison_SetString("Handle Skill Loss",                           Prison.HandleSkillLoss)
    Prison_SetFloat("Day to Start Losing Skills",                   Prison.DayToStartLosingSkills)
    Prison_SetFloat("Chance to Lose Skills",                        Prison.ChanceToLoseSkills)
    Prison_SetFloat("Recognized Criminal Penalty",                  Prison.RecognizedCriminalPenalty)
    Prison_SetFloat("Known Criminal Penalty",                       Prison.KnownCriminalPenalty)
    Prison_SetFloat("Bounty to Trigger Infamy",                     Prison.MinimumBountyToTriggerCriminalPenalty)
    ; Release
    Prison_SetBool("Release Fees Enabled",                          Prison.EnableReleaseFees, "Release")
    Prison_SetFloat("Chance for Release Fees Event",                Prison.ReleaseFeesChanceForEvent, "Release")
    Prison_SetFloat("Bounty to Owe Fees",                           Prison.MinimumBountyToOweReleaseFees, "Release")
    Prison_SetFloat("Release Fees from Arrest Bounty",              Prison.ReleaseFeesOfCurrentBounty, "Release")
    Prison_SetFloat("Release Fees Flat",                            Prison.ReleaseFees, "Release")
    Prison_SetFloat("Days Given to Pay Release Fees",               Prison.DaysGivenToPayReleaseFees, "Release")
    Prison_SetBool("Enable Item Retention",                         Prison.EnableItemRetention, "Release")
    Prison_SetInt("Minimum Bounty to Retain Items",                 Prison.MinimumBountyToRetainItems, "Release")
    Prison_SetBool("Auto Redress on Release",                       Prison.AutoRedressOnRelease, "Release")
    ; Escape
    Prison_SetFloat("Escape Bounty of Current Bounty",              Prison.EscapeBountyOfCurrentBounty, "Escape")
    Prison_SetInt("Escape Bounty",                                  Prison.EscapeBounty, "Escape")
    Prison_SetBool("Account for Time Served",                       Prison.AccountForTimeServedOnEscape, "Escape")
    Prison_SetBool("Frisk upon Captured",                           Prison.FriskUponCapturedOnEscape, "Escape")
    Prison_SetBool("Strip upon Captured",                           Prison.StripUponCapturedOnEscape, "Escape")
    ; Outfit
    Prison_SetString("Outfit::Name",                                Prison.OutfitName, "Clothing")
    Prison_SetForm("Outfit::Head",                                  Prison.OutfitPartHead, "Clothing")
    Prison_SetForm("Outfit::Body",                                  Prison.OutfitPartBody, "Clothing")
    Prison_SetForm("Outfit::Hands",                                 Prison.OutfitPartHands, "Clothing")
    Prison_SetForm("Outfit::Feet",                                  Prison.OutfitPartFeet, "Clothing")
    Prison_SetBool("Outfit::Conditional",                           Prison.IsOutfitConditional, "Clothing")
    Prison_SetFloat("Outfit::Minimum Bounty",                       Prison.OutfitMinimumBounty, "Clothing")
    Prison_SetFloat("Outfit::Maximum Bounty",                       Prison.OutfitMaximumBounty, "Clothing")

    ; ArrestVars.Serialize("Prisoner#" + self.GetIdentifier())
    hasSettingsLocked = true
endFunction

; ==========================================================
;                      -- Arrest Vars --
;                           Getters
bool function Prison_GetBool(string asVarName, string asVarCategory = "Jail")
    return parent.GetBool(asVarName, asVarCategory)
endFunction

int function Prison_GetInt(string asVarName, string asVarCategory = "Jail")
    return parent.GetInt(asVarName, asVarCategory)
endFunction

float function Prison_GetFloat(string asVarName, string asVarCategory = "Jail")
    return parent.GetFloat(asVarName, asVarCategory)
endFunction

string function Prison_GetString(string asVarName, string asVarCategory = "Jail")
    return parent.GetString(asVarName, asVarCategory)
endFunction

Form function Prison_GetForm(string asVarName, string asVarCategory = "Jail")
    return parent.GetForm(asVarName, asVarCategory)
endFunction

ObjectReference function Prison_GetReference(string asVarName, string asVarCategory = "Jail")
    return parent.GetReference(asVarName, asVarCategory)
endFunction

;                          Setters
function Prison_SetBool(string asVarName, bool abValue, string asVarCategory = "Jail")
    parent.SetBool(asVarName, abValue, asVarCategory)
endFunction

function Prison_SetInt(string asVarName, int aiValue, string asVarCategory = "Jail", int aiMinValue = 0, int aiMaxValue = 0)
    parent.SetInt(asVarName, aiValue, asVarCategory)
endFunction

function Prison_ModInt(string asVarName, int aiValue, string asVarCategory = "Jail")
    parent.ModInt(asVarName, aiValue, asVarCategory)
endFunction

function Prison_SetFloat(string asVarName, float afValue, string asVarCategory = "Jail")
    parent.SetFloat(asVarName, afValue, asVarCategory)
endFunction

function Prison_ModFloat(string asVarName, float afValue, string asVarCategory = "Jail")
    parent.ModFloat(asVarName, afValue, asVarCategory)
endFunction

function Prison_SetString(string asVarName, string asValue, string asVarCategory = "Jail")
    parent.SetString(asVarName, asValue, asVarCategory)
endFunction

function Prison_SetForm(string asVarName, Form akValue, string asVarCategory = "Jail")
    parent.SetForm(asVarName, akValue, asVarCategory)
endFunction

function Prison_SetReference(string asVarName, ObjectReference akValue, string asVarCategory = "Jail")
    parent.SetReference(asVarName, akValue, asVarCategory)
endFunction

function Prison_Remove(string asVarName, string asVarCategory = "Jail")
    parent.Remove(asVarName, asVarCategory)
endFunction

function Prison_RemoveAll(string asVarCategory = "Jail")
    parent.RemoveAll(asVarCategory)
endFunction

; ==========================================================

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

RPB_Prison __cachedPrison
RPB_Prison function GetPrison()
    if (__cachedPrison)
        return __cachedPrison
    endif

    ; Temporarily retrieve the hold to obtain the Prison (necessary as key to get the Prison, later retrieved through Prison.Hold)
    string prisonHold               = RPB_StorageVars.GetStringOnForm("Hold", this, "Arrest")
    RPB_Prison returnedPrison       = (RPB_API.GetPrisonManager()).GetPrison(prisonHold)

    __cachedPrison = returnedPrison
    return returnedPrison
endFunction

; ==========================================================
;                          Debug
; ==========================================================

function DEBUG_ShowPrisonInfo()
    Debug(this, "DEBUG_ShowPrisonInfo", "\n" + Prison.Hold + " Prison: { \n\t" + \
        "Hold: "                + Prison.Hold + ", \n\t" + \
        "Bounty Non-Violent: "  + BountyNonViolent + ", \n\t" + \
        "Bounty Violent: "      + BountyViolent + ", \n\t" + \
        "Imprisoned: "          + self.IsImprisoned + ", \n\t" + \
        "Jail Cell: "           + Prison_GetReference("Cell") + ", \n" + \
    " }")
endFunction

function DEBUG_ShowSentenceInfo(bool abShort = false)
    int timeServedDays      = GetTimeServed("Days")
    int timeServedHours     = GetTimeServed("Hours of Day")
    int timeServedMinutes   = GetTimeServed("Minutes of Hour")
    int timeServedSeconds   = GetTimeServed("Seconds of Minute")

    int timeLeftToServeDays      = GetTimeLeftInSentence("Days")
    int timeLeftToServeHours     = GetTimeLeftInSentence("Hours of Day")
    int timeLeftToServeMinutes   = GetTimeLeftInSentence("Minutes of Hour")
    int timeLeftToServeSeconds   = GetTimeLeftInSentence("Seconds of Minute")

    string sentenceString   = "Sentence: " + Sentence + " Days"
    string timeServedString = TimeServed + " ("+ (TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"]"
    string timeLeftString   = TimeLeftInSentence + " ("+ (TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"]"

    if (abShort)
        Info(this, "ShowSentenceInfo", Prison.Hold + " Sentence for " + this +": {"+ sentenceString +", Served: "+ timeServedString +", Left: "+ timeLeftString +"}")
    else
        Info(this, "ShowSentenceInfo", "\n" + Prison.Hold + " Sentence: { \n\t" + \
        "Minimum Sentence: "    + Prison.MinimumSentence + " Days, \n\t" + \
        "Maximum Sentence: "    + Prison.MaximumSentence + " Days, \n\t" + \
        "Sentence: "            + Sentence + " Days, \n\t" + \
        "Time of Arrest: "      + TimeOfArrest + ", \n\t" + \
        "Time of Imprisonment: "+ TimeOfImprisonment + ", \n\t" + \
        "Time Served: "         + TimeServed + " ("+ (TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"], \n\t" + \
        "Time Left: "           + TimeLeftInSentence + " ("+ (TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"], \n\t" + \
        "Release Time: "        + ReleaseTime + "\n" + \
    " }")
    endif
endFunction

function DEBUG_ShowHoldStats()
    Info(this, "ShowHoldStats", "\n" + Prison.Hold + " Stats: { \n\t" + \
        "Current Bounty: "      + self.QueryStat("Current Bounty")      + ", \n\t" + \
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