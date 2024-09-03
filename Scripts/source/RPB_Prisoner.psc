Scriptname RPB_Prisoner extends RPB_Actor

import RPB_Config
import RPB_Utility
import Math

; ==========================================================
;                      Script References
; ==========================================================

RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
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
        return true
    endFunction
endProperty

bool property ShouldBeStripped
    bool function get()
        return Bounty >= 1000
        return true && (!IsStrippedNaked && !IsStrippedToUnderwear)
    endFunction
endProperty

int property StrippingThoroughness
    int function get()
        int modifier = Prison.StrippingThoroughnessModifier
        return GetInt("Stripping Thoroughness", "Stripping") + int_if (modifier > 0, Round(Bounty / modifier))
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
        ; float infamyTypePenalty = float_if (IsInfamyKnown, arrestVars.InfamyKnownPenalty, float_if (IsInfamyRecognized, arrestVars.InfamyRecognizedPenalty))
        ; return round(CurrentInfamy * infamyTypePenalty)
    endFunction
endProperty

bool property IsSentenceSet
    bool function get()
        return self.Sentence != 0
    endFunction
endProperty

ReferenceAlias property CellPackage
    ReferenceAlias function get()
        return JailCell.GetPrisonerCellPackage(self)
    endFunction
endProperty

bool property HasCellPackage
    bool function get()
        return CellPackage.GetActorReference() == this
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
        Debug("["+ Name +"] Prisoner::AssignCell", "A prison cell has already been assigned to prisoner " + this + ": [" +"Cell: " + self.JailCell + ", Door: " + self.JailCell.CellDoor + "]")
        return true
    endif

    ; Needs to be refactored, shouldn't be here
    if (ShouldBeStripped)
        ; Determine if prisoner will be stripped etc (Set options that a cell depend on)
        self.WillBeStrippedNaked = true ; Makes the cell gender exclusive
    endif

    RPB_JailCell assignedCell = Prison.RequestCell(self)

    if (assignedCell == none)
        self.OnImprisonmentFail("Assign Cell")
        return false
    endif

    Prison.BindCellToPrisoner(assignedCell, self) ; Actually bind this jail cell to the prisoner, it has been assigned.
    return self.JailCell != none
endFunction

; Binds the NPC to their Cell, does not work on the Player.
function BindToCell()
    if (self.IsPlayer())
        return
    endif

    if (self.HasCellPackage)
        return
    endif

    self.BindAlias(CellPackage)
    MiscUtil.PrintConsole("["+ Name +"] Bound to Package " + CellPackage.GetName())
    Debug("[Prison: "+ self.Prison.Name +"] ["+ Name +"] Prisoner::BindToCell", "[Package: "+ CellPackage.GetName() +"] Bound " + Name + " to "+ self.GetPossessivePronoun() +" Cell.")
endFunction

function SetReleaseLocation(bool abIsTeleportLocation = true)
    if (abIsTeleportLocation)
        SetForm("Teleport Release Location", Prison.GetRandomReleaseMarker("Teleport"))
    else
        SetForm("Teleport Release Location", Prison.GetRandomReleaseMarker("Escort"))
    endif
endFunction

;/
    Sets the Prisoner's belongings container where their items will be stored
    while they are in prison.
/;
function SetBelongingsContainer()
    if (self.PrisonerBelongingsContainer)
        return
    endif

    SetForm("Prisoner Belongings Container", Prison.GetRandomPrisonerContainer("Belongings"))
    Debug("Prison::SetBelongingsContainer", "Prisoner Belongings Container:  " + PrisonerBelongingsContainer)
endFunction

;/
    Releases this prisoner from jail
/;
bool __isReleased
function Release()
    if (!__isReleased)
        GotoState("Released")
        self.UnbindAlias(CellPackage)
        Prison.ReleasePrisoner(self)
        Debug("["+ Name +"] Prisoner::Release", "Released " + self.Name + " from " + Prison.Name)
        __isReleased = true
    endif

endFunction

;/
    Removes this Prisoner reference from the assigned jail cell.
/;
function RemoveFromCell()
    if (!self.JailCell)
        DebugWarn("["+ Name +"] Prisoner::RemoveFromCell", "The prisoner " + self.Name + " is not bound to any jail cell!")
        return
    endif
    
    JailCell.RemovePrisoner(self)
endFunction

function Restrain()
    self.Cuff()
endFunction

function ReturnBelongings()
    PrisonerBelongingsContainer.RemoveAllItems(this, false, true)
endFunction

function TeleportToRelease()
    self.EnableAI(self.IsNPC())
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

bool function ShouldBeClothed()
    return false
endFunction

bool function HasStateRequiredForImprisonment()
    ; Debug("["+ Name +"] Prisoner::HasStateRequiredForImprisonment", "Status: [\n" + \
    ;     "\t Prison: " + Prison + "\n" + \
    ;     "\t JailCell: " + JailCell + "\n" + \
    ;     "\t Sentence: " + Sentence + "\n" + \
    ;     "\t Bounty: " + Bounty + "\n" + \
    ;     "\t IsUndeterminedSentence: " + IsUndeterminedSentence + "\n" + \
    ;     "\t Result: " + (Prison && JailCell && (Sentence || Bounty || IsUndeterminedSentence))+ "\n" + \
    ; "]")
    return Prison && JailCell && (Sentence || Bounty || IsUndeterminedSentence)
endFunction

;/
    Main function that handles the imprisonment of this Prisoner.
/;
function Imprison()
    if (!self.HasStateRequiredForImprisonment())
        Error(Name + " does not have the required state for "+ self.GetPossessivePronoun() +" imprisonment, cannot continue!")
        DebugError("["+ Name +"] Prisoner::Imprison", Name + " does not have the required state for "+ self.GetPossessivePronoun() +" imprisonment, cannot continue!")
        return
    endif

    if (self.IsImprisoned)
        Error(self.GetName() + " is already imprisoned in "+ Prison.Name + "!")
        DebugError("["+ Name +"] Prisoner::Imprison", self.GetName() + " is already imprisoned in "+ Prison.Name + "!")
        return
    endif

    float startBench = StartBenchmark()
    if (GetBool("Infamy Enabled"))
        self.TriggerInfamyPenalty()
    endif

    string sentenceFormatted    = RPB_Utility.GetTimeFormatted(Sentence, abIncludeHours = false)
    string releaseDateFormatted = Prison.GetTimeOfReleaseFormatted(self)

    if (self.ShowSentence && !self.IsUndeterminedSentence)
        Config.NotifyJail("Your sentence was set at "+ sentenceFormatted +" in " + Prison.Name, self.IsPlayer())
        Config.NotifyJail(self.GetName() + " has been sentenced to "+ sentenceFormatted +"  in prison for " + self.GetHold(), !self.IsPlayer())
    endif
    
    if (self.ShowReleaseTime && !self.IsUndeterminedSentence)
        Config.NotifyJail("Your release is due on " + releaseDateFormatted, self.IsPlayer())
        Config.NotifyJail(self.GetName() + "'s release is due on " + releaseDateFormatted, !self.IsPlayer())
    endif

    self.OnImprisoned()
    GotoState("Imprisoned") ; State when the prisoner is in the cell, check for updates for sentence, etc...
    EndBenchmark(startBench, "Ended ["+ Name +"] Prisoner::Imprison")
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
    if (!self.PrisonerBelongingsContainer)
        DebugError("["+ Name +"] Prisoner::Strip", "The prisoner hasn't had a belongings container assigned to them, cannot strip!")
        return
    endif

    RPB_Outfit prisonerOutfit = (self as ActiveMagicEffect) as RPB_Outfit ; Should be in Clothe()

    self.UnequipAll()
    self.RemoveAllItems(PrisonerBelongingsContainer, true, true) ; Remove and put all the items in the prisoner's posession in the assigned prisoner container

    ObjectReference evidenceChest = Game.GetForm(0x108D37) as ObjectReference ; temp
    evidenceChest.SetDisplayName("Vivienne Onis' Belongings") ; temp
    PrisonerBelongingsContainer.AddItem(evidenceChest) ; temp

    self.IsStrippedNaked       = StrippingThoroughness >= 10
    self.IsStrippedToUnderwear = !self.IsStrippedNaked

    DebugWithArgs("["+ Name +"] Prisoner::Strip", "abRemoveUnderwear: " + YesNo(abRemoveUnderwear), "Container: " + PrisonerBelongingsContainer)
    ; TODO: Determine what is required to happen to have the Prisoner be in underwear (e.g: Stripping Thoroughness)
    ; TODO: Find a way to keep the underwear without recovering NPC's body clothing (skyrim bug?), maybe filters?
    ; if (!abRemoveUnderwear)
    ;     Armor underwearTop      = self.GetUnderwear("Top")
    ;     Armor underwearBottom   = self.GetUnderwear("Bottom")

    ;     PrisonerBelongingsContainer.RemoveItem(underwearTop, abSilent = true, akOtherContainer = this)
    ;     PrisonerBelongingsContainer.RemoveItem(underwearBottom, abSilent = true, akOtherContainer = this)

    ;     self.EquipItem(underwearTop)
    ;     self.EquipItem(underwearBottom)
    ; endif
 
    ; Unequip anything currently held in the hands of this Prisoner
    self.UnequipHands()
    self.SheatheWeapon()

    ; this.EquipItem(Game.GetForm(0x13105) as Armor)

    self.IncrementStat("Times Stripped")
    SetBool("Stripped", true) ; No use for now, might be changed
    Debug("["+ Name +"] Prisoner::Strip", "Stripped "+ Name + " naked.", self.IsStrippedNaked)
    Debug("["+ Name +"] Prisoner::Strip", "Stripped "+ Name + " to underwear.", self.IsStrippedToUnderwear)
endFunction

function RemoveUnderwear()
    Armor underwearTop      = self.GetUnderwear("Top")
    Armor underwearBottom   = self.GetUnderwear("Bottom")

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
    SceneManager.StartRestrainPrisoner_02( \
        akGuard     = akRestrainer, \
        akPrisoner  = this \
    )
endFunction

function StartFrisking(Actor akSearcherGuard)
    SceneManager.StartFrisking( \
        akFriskerGuard     = akSearcherGuard, \
        akFriskedPrisoner  = this \
    )
endFunction

function StartStripping(Actor akStripperGuard)
    SceneManager.StartStripping_02( \
        akStripperGuard     = akStripperGuard, \
        akStrippedPrisoner  = this \
    )
endFunction

function StartGiveClothing(Actor akClothingGiver)
    SceneManager.StartGiveClothing( \
        akGuard     = akClothingGiver, \
        akPrisoner  = this \
    )
endFunction

function EscortToJail(Actor akEscort)
    ObjectReference escortLocation = Prison.GetRandomEscortLocation()

    SceneManager.StartEscortToJail( \
        akEscortLeader      = akEscort, \
        akEscortedPrisoner  = this, \
        akPrisonerChest     = escortLocation \
    )
    SetBool("Go to Cell", true)
endFunction

function EscortToCell(Actor akEscort)
    ObjectReference outsideCellGuardWaitingMarker = JailCell.GetRandomMarker("Exterior")
    ; Debug("["+ Name +"] Prisoner::EscortToCell", "Called EscortToCell()")
    ; Debug("["+ Name +"] Prisoner::EscortToCell", "Started escort to cell with escort " + akEscort.GetBaseObject().GetName() + "\n" + \ 
    ;     "\t\t akEscortLeader: " + akEscort + \ 
    ;     "\t\t akEscortedPrisoner: " + this + \ 
    ;     "\t\t akJailCellMarker: " + self.JailCell + \ 
    ;     "\t\t akJailCellDoor: " + self.JailCell.CellDoor + \ 
    ;     "\t\t akEscortWaitingMarker: " + outsideCellGuardWaitingMarker \ 
    ; )
    SceneManager.StartEscortToCell( \
        akEscortLeader              = akEscort, \
        akEscortedPrisoner          = this, \
        akJailCellMarker            = self.JailCell, \
        akJailCellDoor              = self.JailCell.CellDoor, \
        akEscortWaitingMarker       = outsideCellGuardWaitingMarker \ 
    )
endFunction

; ==========================================================

; ==========================================================
;                          Sentence
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


function RegisterTimeOfImprisonment()
    SetFloat("Time of Imprisonment", CurrentTime)
    SetInt("Minute of Imprisonment", RPB_Utility.GetCurrentMinute())
    SetInt("Hour of Imprisonment", RPB_Utility.GetCurrentHour())
    SetInt("Day of Imprisonment", RPB_Utility.GetCurrentDay())
    SetInt("Month of Imprisonment", RPB_Utility.GetCurrentMonth())
    SetInt("Year of Imprisonment", RPB_Utility.GetCurrentYear())
endFunction

int function GetReleaseTimeHour()
    int releaseTimeHour = (ReleaseTime - math.floor(ReleaseTime)) as int

    ; Get the release hour and minutes
    float releaseHourAndMinutes = releaseTimeHour / 0.0416

    int releaseMinutes = Round((releaseHourAndMinutes - math.floor(releaseHourAndMinutes)) * 60)

    return releaseMinutes
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

state Released
    event OnBeginState()
        SetBool("Should Be In Cell", false)
        SetBool("Imprisoned", false)
    endEvent

    event OnUpdateGameTime()
    endEvent
endState

float _previousUpdateTimeServed
; While this Prisoner is imprisoned in their cell
state Imprisoned
    event OnBeginState()
        Debug("[state: "+ self.GetState() +"] ["+ Name +"] Prisoner::OnBeginState", self.Name + "'s Bounty: " + Bounty)
        ; if (!Prison.IsReceivingUpdates()) ; if we dont destroy the instance in time, this will get called from Prison after processing queued prisoners, and since we didnt register the prisoner, this is a bug since it will report 0 prisoners
            Prison.RegisterForPrisonPeriodicUpdate(self)
        ; endif

        ; Captor should probably be destroyed in RPB_Captor, because more Prisoners/Arrestees may depend on it
        ; we could check if that Captor has any prisoners left to escort, if not, destroy the reference.
        ; Captor.Destroy()

        ; At this point, we can delete the prisoner's arrest state
        self.DestroyArrestState()
        self.RemoveAll(TEMPORARY_DESTROY_ON_IMPRISONED) ; Destroy all Temporary vars on Imprisoned state

        self.RegisterLastUpdate()
        RegisterForUpdateGameTime(1.0)
        SetBool("Imprisoned", true)
    endEvent

    event OnUpdateGameTime()
        self.UpdateInfamy()
        self.UpdateTimeJailed() ; Must be updated in some other way, otherwise it will reset to 0 on next imprisonment
 
        if (self.IsSentenceServed) ; implementation is not finished
            ; Prison.SendReleaseRequest(self)
            self.Release()
            return
        endif

        Prison.DEBUG_ShowPrisonerSentenceInfo(self, true)

        ; Debug("["+ Name +"] Prisoner::OnUpdateGameTime", "currentTimeServedStored: " + currentTimeServedStored)

        self.RegisterLastUpdate()
        RegisterForSingleUpdateGameTime(1.0)
        RegisterForSingleUpdate(10.0)
        ; Debug("[state: Imprisoned] ["+ Name +"] Prisoner::OnUpdateGameTime", self.Name + "'s Bounty: " + Bounty)
        ; self.DEBUG_ShowHoldStats()

    endEvent
endState

state Awaiting
    event OnUpdateGameTime()
        DebugError("[state: Awaiting] ["+ Name +"] Prisoner::OnUpdateGameTime", "Updating in the Awaiting state, should not happen!")
    endEvent
endState

; When this Prisoner gets released
state Released
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
state ServeOnRest
    function UpdateTimeJailed()
        int timeLeft = Math.Ceiling(TimeLeftInSentence)
        self.ModifyStat("Time Jailed", timeLeft)
        self.IncrementStat("Days Jailed", timeLeft)

        if (self.IsPlayer())
            Game.IncrementStat("Days Jailed", timeLeft)
        endif

        Debug("[state: ServeOnRest] ["+ Name +"] Prisoner::UpdateTimeJailed", "Updating " + self.Name + "'s time jailed: " + timeLeft + ", TimeLeftInSentence: " + TimeLeftInSentence)
    endFunction

    function UpdateInfamy()
        if (!Prison.EnableInfamy)
            return
        endif

        int timeLeft = Math.Ceiling(TimeLeftInSentence)
        int infamyGained = (InfamyGainedDaily * timeLeft) as int

        self.IncrementStat("Infamy Gained", infamyGained)

        Config.NotifyInfamy(infamyGained + " infamy gained in " + Prison.Name, self.IsPlayer())
        Config.NotifyInfamy(self.GetName() + " has gained " + infamyGained + " infamy in " + Prison.Name, !self.IsPlayer())
    
        if (IsInfamyKnown)
            Prison.NotifyInfamyKnownThresholdMet(Prison.HasInfamyKnownNotificationFired)
    
        elseif (IsInfamyRecognized)
            Prison.NotifyInfamyRecognizedThresholdMet(Prison.HasInfamyRecognizedNotificationFired)
        endif

        Debug("[state: ServeOnRest] ["+ Name +"] Prisoner::UpdateInfamy", "Updating " + self.Name + "'s infamy in jail: " + infamyGained)
    endFunction
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

; ==========================================================
;                            Utility
; ==========================================================

function UpdateInfamy()
    if (!Prison.EnableInfamy)
        return
    endif

    self.IncrementStat("Infamy Gained", InfamyGainedPerUpdate)

    Config.NotifyInfamy(InfamyGainedPerUpdate + " infamy gained in " + Prison.Name, self.IsPlayer())
    Info(self.GetName() + " has gained " + InfamyGainedPerUpdate + " infamy in " + Prison.Name, self.IsNPC())

    if (IsInfamyKnown && self.IsPlayer())
        Prison.NotifyInfamyKnownThresholdMet(Prison.HasInfamyKnownNotificationFired)

    elseif (IsInfamyRecognized && self.IsPlayer())
        Prison.NotifyInfamyRecognizedThresholdMet(Prison.HasInfamyRecognizedNotificationFired)
    endif
endFunction

function UpdateTimeJailed()
    float currentTimeJailed = (TimeServed - _previousUpdateTimeServed) ; Subtract previous time served so we only add the new time after the last update
    Debug("["+ Name +"] Prisoner::UpdateTimeJailed", "currentTimeJailed: " + currentTimeJailed + ", TimeServed: " + TimeServed + ", _previousUpdateTimeServed: " + _previousUpdateTimeServed)

    self.ModifyStat("Time Jailed", currentTimeJailed)

    if (self.HasDayElapsed())
        if (self.IsPlayer())
            Game.IncrementStat("Days Jailed", DaysSinceTimeOfImprisonment)
        endif

        accumulatedTimeServed -= DaysSinceTimeOfImprisonment ; Remove the counted days from accumulated time served (Get the fractional part if there's any - i.e: hours)
        Debug("["+ Name +"] Prisoner::UpdateTimeJailed", "DaysSinceTimeOfImprisonment: " + DaysSinceTimeOfImprisonment + ", accumulatedTimeServed: " + accumulatedTimeServed)
        Debug("["+ Name +"] Prisoner::UpdateTimeJailed", "Days Jailed: " + self.QueryStat("Days Jailed"))
        self.OnDayPassed()
    endif

    ; Debug("["+ Name +"] Prisoner::UpdateTimeJailed", "Updating " + self.Name + "'s time jailed by: " + currentTimeJailed)
    ; Debug("["+ Name +"] Prisoner::UpdateTimeJailed", "TimeServed: " + TimeServed + ", _previousUpdateTimeServed: " + _previousUpdateTimeServed)

    ; Update the previous time served, to take into account for the next calculation
    _previousUpdateTimeServed = TimeServed
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

function UpdateLargestBounty()
    parent.SyncLargestBountyForFaction(Prison.PrisonFaction)
endFunction

function UpdateTotalBounty()
    parent.SyncTotalBountyForFaction(Prison.PrisonFaction)
endFunction

bool function HasActiveBounty()
    return parent.HasActiveBountyForFaction(Prison.PrisonFaction)
endFunction

bool function HasLatentBounty()
    return parent.HasLatentBountyForFaction(Prison.PrisonFaction)
endFunction

function SetCrimeGold(int aiGold)
    parent.SetCrimeGoldForFaction(Prison.PrisonFaction, aiGold)
endFunction

function SetCrimeGoldViolent(int aiGold)
    parent.SetCrimeGoldViolentForFaction(Prison.PrisonFaction, aiGold)
endFunction

function ModCrimeGold(int aiAmount, bool abViolent = false)
    parent.ModCrimeGoldForFaction(Prison.PrisonFaction, aiAmount, abViolent)
endFunction

;/
    Gets the active bounty for this Actor, that is, the bounty that is currently set on a Faction when
    the Actor is wanted by that Faction.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetActiveBounty(bool abNonViolent = true, bool abViolent = true)
    return parent.GetActiveBountyForFaction(Prison.PrisonFaction, abNonViolent, abViolent)
endFunction

;/
    Gets the latent bounty for this Actor, that is, the bounty that is stored when Arrested/Jailed.

    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetLatentBounty(bool abNonViolent = true, bool abViolent = true)
    return parent.GetLatentBountyForFaction(Prison.PrisonFaction, abNonViolent, abViolent)
endFunction

; Transfers the Active Bounty into the Latent Bounty.
function HideBounty()
    parent.HideBountyForFaction(Prison.PrisonFaction)
endFunction

; Restores the Active Bounty from the Latent Bounty.
function RestoreBounty()
    parent.RestoreBountyForFaction(Prison.PrisonFaction)
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
    ; Assign a container for this prisoner's belongings (if applicable)
    self.SetBelongingsContainer()

    self.MoveTo(PrisonerBelongingsContainer)

     ; Later maybe the captor shouldn't go, and instead there should be guards waiting in the prison
     ; They shouldn't go especially if they are not a guard (e.g: Bounty Hunter or other NPC)
    akCaptor.MoveTo(PrisonerBelongingsContainer)
endFunction

function MoveToCellTemp()
    ; Release from Scenes
    int escorteeId = self.GetInt("Escortee")
    ReferenceAlias escorteeAlias = SceneManager.GetEscortee(escorteeId)
    self.UnbindAlias(escorteeAlias)
    Utility.Wait(0.2)
    self.MoveToCell()
    Prison.OnPrisonerMovedToPrison(self, true)
endFunction

function MoveToCell(bool abBeginImprisonment = true)
    if (self.IsImprisoned)
        Error(self.GetName() + " is already imprisoned in "+ Prison.Name + "!")
        DebugError("["+ Name +"] Prisoner::MoveToCell", self.GetName() + " is already imprisoned in "+ Prison.Name + "!")
        return
    endif

    if (self.ShouldBeInCell && self.IsInCell)
        Error(self.GetName() + " is already in "+ self.GetPossessivePronoun() +" cell: " + JailCell + "!")
        DebugError("["+ Name +"] Prisoner::MoveToCell", self.GetName() + " is already in "+ self.GetPossessivePronoun() +" cell: " + JailCell + "!")
        return
    endif

    if (!self.JailCell)
        Error("The prisoner " + Name + " has not been assigned a jail cell!")
        DebugError("["+ Name +"] Prisoner::MoveToCell", "The prisoner " + Name + " has not been assigned a jail cell!")
        Prison.OnPrisonerImprisonmentFail(self, "Assign Cell")
        return
    endif

    self.MoveTo(JailCell)
    self.OnTeleportedToCell(abBeginImprisonment)
endFunction

function QueueForImprisonment()
    Prison.QueuePrisonerForImprisonment(self)
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

function FastForwardToRelease()
    GotoState("ServeOnRest")
    self.UnregisterForUpdates()

    ; If the Release must fall in between Minimum and Maximum release hours, set the hour to the minimum before passing the days.
    if (self.HasReleaseTimeExtraHours())
        RPB_Utility.SetGameHour(Prison.ReleaseTimeMinimumHour)
        Debug("["+ Name +"] Prisoner::FastForwardToRelease", "Setting Game Hour to Release Time Minimum Hour: " + RPB_Utility.GetTimeAs12Hour(Prison.ReleaseTimeMinimumHour))
    endif

    self.UpdateTimeJailed()
    self.UpdateInfamy()

    ; Pass the time
    int timeLeft = Math.Ceiling(TimeLeftInSentence)
    RPB_Utility.PassTimeInDays(timeLeft)

    ; float currentTimeBeforeChanges = CurrentTime
    ; __currentTimeOverride = CurrentTime + timeLeft

    ; Debug("["+ Name +"] Prisoner::FastForwardToRelease", "CurrentTime: " + currentTimeBeforeChanges + ", timeLeft: " + timeLeft + ", currentTimeOverride: " + __currentTimeOverride + ", TimeLeftInSentence: " + TimeLeftInSentence)

    GotoState("Awaiting")

    self.Release()
endFunction

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

float function GetReleaseTime(bool abIncludeMinutes = true)
    float oneGameHour = 0.04166666666666666666666666666667

    if (abIncludeMinutes)
        return TimeOfImprisonment + (oneGameHour * 24 * Sentence)
    endif

    return floor(TimeOfImprisonment) + (oneGameHour * 24 * Sentence)
endFunction

float function GetIndefiniteReleaseTime()
    return self.GetReleaseTime() + RPB_Utility.GetDaysPassed() + 1
endFunction

float function GetReleaseTimeExtraHours()
    float gameHour = 0.04166666666666666666666666666667
    return 1 + (Prison.ReleaseTimeMinimumHour * gameHour) ; Add 1 day and round to the time configured by Prison.ReleaseTimeMinimumHour
endFunction

bool __hasExtraReleaseTimeHours
bool function HasReleaseTimeExtraHours()
    return __hasExtraReleaseTimeHours
endFunction

function DetermineReleaseTime(bool abNotify = false)
    SetBool("ReleaseTime::Show", true)

    if (abNotify)
        string releaseDateFormatted = Prison.GetTimeOfReleaseFormatted(self)
        Config.NotifyJail("Your release is due on " + releaseDateFormatted, self.IsPlayer())
    endif
endFunction

function SetAsShowable(string asPropertyName, bool abValue = true)
    SetBool(asPropertyName + "::Show", abValue)
endFunction

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
    RPB_Arrestee arresteeRef = API.Arrest.MakeArrestee(this)
    ;/ arresteeRef.SetArrestParameters( \
        asArrestHold        = newArrestHold, \
        akArrestCaptor      = newArrestCaptor \
        akArrestFaction     = newArrestFaction, \
    )/;

    return arresteeRef
endFunction

bool function ShouldProcessImprisonmentEvents()
    return self.IsImprisoned
endFunction

; ==========================================================
;                           Events
; ==========================================================

event OnTeleportedToCell(bool abBeginImprisonment)
    SetBool("Should Be In Cell", true)
    Prison.OnPrisonerTeleportedToCell(self, abBeginImprisonment)
endEvent

event OnEscortedToCell(Actor akEscort)
    SetBool("Should Be In Cell", true)
    Prison.OnEscortPrisonerToCellEnd(self, JailCell, akEscort)
endEvent

event OnEscortedFromCell(Actor akEscort)
    SetBool("Should Be In Cell", false)
endEvent

event OnInitialize()
    ; if (self.Is("Inactive"))
    ;     return
    ; endif

    ; Prison.RegisterForPrisonPeriodicUpdate(self)
    Prison.RegisterPrisoner(self) ; Registers this prisoner into the prisoner list
    Trace("["+ Name +"] Prisoner::OnInitialize", "self: " + self)
    if (self.IsNPC() && !self.IsInCell)
        ; self.PerformSanityChecks()
        JailCell.RegisterForSanityChecking(1.0, apPrisoner = self)
        ; JailCell.PerformPrisonerSanityCheck(self)
    endif
    if (NPC_RestorePrisonerState())
        ; Actor was already a prisoner, do not initialize normally and instead proceed to restoring their previous state
        ; Prison.RegisterPrisoner(self) ; Registers this prisoner into the prisoner list since they were unregistered OnDestroy()
        self.RegisterForTrackedStats()
        return
    endif

    self.RegisterSleepEvents = true
    self.RegisterForTrackedStats()
    self.LockPrisonerSettings()
endEvent

bool property IsEnabledForBackgroundUpdates
    bool function get()
        return GetBool("IsEnabledForBackgroundUpdates")
    endFunction

    function set(bool value)
        SetBool("IsEnabledForBackgroundUpdates", value)
    endFunction
endProperty

event OnDestroy()
    if (self.IsNPC())
        self.NPC_SavePrisonerState() ; temporarily disabled

        if (!Prison.IsReceivingUpdates()) ; if we dont destroy the instance in time, this will get called from Prison after processing queued prisoners, and since we didnt register the prisoner, this is a bug since it will report 0 prisoners
            Prison.RegisterForPrisonPeriodicUpdate(self)
        endif

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
    if (!self.ShouldProcessImprisonmentEvents())
        return
    endif

    self.UpdateSentence()
    self.UpdateLargestBounty()
    self.UpdateTotalBounty()
endEvent

event OnSentenceSet(int aiSentence, float afAtWhatTime)
    if (!self.ShouldProcessImprisonmentEvents())
        return
    endif

    self.UpdateLongestSentence()
endEvent

event OnSentenceChanged(int aiOldSentence, int aiNewSentence, bool abHasSentenceIncreased, bool abSentenceAffectsBounty)
    if (!self.ShouldProcessImprisonmentEvents())
        return
    endif

    if (abHasSentenceIncreased)
        int daysIncreasedBy = aiNewSentence - aiOldSentence
        Config.NotifyJail("Your sentence was increased by " + daysIncreasedBy + " days.")
        self.UpdateLongestSentence()
    endif
endEvent

; Triggered whenever a full day has passed
event OnDayPassed()
    if (!self.ShouldProcessImprisonmentEvents())
        return
    endif

    self.PerformDeleveling()
endEvent

event OnStatChanged(string asStatName, float afValue)
    if (asStatName == Prison.Hold + " Bounty") ; If there's bounty gained in the current prison hold
        self.OnBountyGained()
        ; Maybe inform the prisoner of their new sentence and have them escorted out of the cell to be frisked/stripped if they are not
    endif

    ; Debug(this, "["+ Name +"] Prisoner::OnStatChanged", "Stat " + asStatName + " has been changed to " + afValue)
endEvent

int __serveTimeLastDayRegistered
event OnSleepStart(float afSleepStartTime, float afSleepEndTime)
    if (!self.ShouldProcessImprisonmentEvents())
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
    Prison.OnPrisonerImprisoned(self)
endEvent

event OnImprisonmentFail(string asReason)
    Prison.OnPrisonerImprisonmentFail(self, asReason)
endEvent

; ==========================================================
;                          Management
; ==========================================================

string property TEMPORARY_DESTROY_ON_IMPRISONED = "Temporary::Imprisoned" autoreadonly

function Destroy()
    ; TODO: Unset all properties related to this Prisoner
    ; Prison.UnregisterPrisoner(self)
endFunction

;/
    Destroys the prisoner's arrest state, as they are now a prisoner and the arrest state is not required anymore.
/;
function DestroyArrestState()
    if (!API.Arrest.IsActorArrested(this))
        return
    endif

    RPB_Arrestee arrestState = RPB_Arrestee.GetStateForPrisoner(self)

    if (arrestState)
        ; Save the bounty from the Arrest state
        int _bounty          = self.GetInt("Bounty Non-Violent", "Arrest")
        int _bountyViolent   = self.GetInt("Bounty Violent", "Arrest")
        
        arrestState.Destroy()
        Utility.Wait(0.2)
        
        ; Save the bounty from the Arrest state
        self.SetInt("Bounty Non-Violent", _bounty, "Arrest")
        self.SetInt("Bounty Violent", _bountyViolent, "Arrest")
    endif
endFunction

;/
    Performs sanity checks for prisoners that should be stripped (NPC's only)

    When the player is far away from the prisoner at the time of imprisonment,
    despite the prisoner being stripped, they will still be wearing their normal clothes,
    leaving copies of it in the prisoner chest on strip.

    This function aims to fix that by performing a sanity check to ensure they are stripped when the player
    is in the same location.

    It can and should only run once, after that, their clothes will not reappear on them.
    called from JailCell::PerformPrisonersSanityCheck() and JailCell::PerformPrisonerSanityCheck()

    May be renamed to PerformClothingSanityChecks
/;
bool function PerformStrippingSanityChecks()
    if (!self.IsNPC())
        return false
    endif

    ; TODO: Check if the prisoner was stripped to underwear, and give them the underwear back,
    ; also take into account possible lockpicks or keys the prisoner might have, we don't want to include those, the prisoner should remain with them
    bool shouldStrip = !self.IsNaked() && self.IsInCell && self.Is("Stripped") ;/&& !self.IsWearingPrisonerOutfit/;

    if (shouldStrip)
        if (self.IsStrippedToUnderwear)
            Armor underwearTop      = self.GetUnderwear("Top")
            Armor underwearBottom   = self.GetUnderwear("Bottom")

            self.UnequipAll()
            self.RemoveAllItems()
  
            self.EquipItem(underwearTop, abCondition = underwearTop != none)        
            self.EquipItem(underwearBottom, abCondition = underwearBottom != none)

            Debug("["+ Name +"] Prisoner::PerformStrippingSanityChecks", "Stripped " + self.Name + " to underwear - performed sanity check", underwearTop != none || underwearBottom != none)
            Debug("["+ Name +"] Prisoner::PerformStrippingSanityChecks", "Stripped " + self.Name + " naked - performed sanity check", underwearTop == none && underwearBottom == none)

        elseif (self.IsStrippedNaked)
            self.RemoveAllItems()
            Debug("["+ Name +"] Prisoner::PerformStrippingSanityChecks", "Stripped " + self.Name + " naked - performed sanity check")
        endif
    endif

    return (self.IsStrippedNaked && self.IsNaked()) || (self.IsStrippedToUnderwear && self.IsInUnderwear()) ; TODO: Add outfit clothing condition
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
    LastUpdate = Utility.GetCurrentGameTime()
endFunction

function NPC_RestoreImprisonment()
    if (!self.IsImprisoned)
        return
    endif
    
    Debug("["+ Name +"] Prisoner::NPC_RestoreImprisonment", "Restoring NPC Imprisonment...")

    if (GetBool("Infamy Enabled"))
        self.TriggerInfamyPenalty()
    endif

    ; self.ProcessWhenMoved() ; Only use when moved, not when escorted (Handle all events at once)
    Config.NotifyJail(self.GetName() + " still has "+ self.GetTimeLeftInSentence("Days") +" days left in prison for " + self.GetHold())

    ; ArrestVars.List("Jail")
    GotoState("Imprisoned") ; State when the prisoner is in the cell, check for updates for sentence, etc...
    RegisterForUpdateGameTime(1.0)
endFunction

;/
    Restores this ActiveMagicEffect on the imprisoned NPC, if they exist and are imprisoned.

    Since ActiveMagicEffects dispel after the Player is far away enough from the target Actor, we
    must re-apply the effect and restore the state previous to reference destruction for NPC's.
/;
bool function NPC_RestorePrisonerState()
    return false
    if (GetBool("ShouldRestorePrisonerState"))
        Debug("["+ Name +"] Prisoner::NPC_RestorePrisonerState", "Restoring NPC state...")
        self.NPC_RestoreImprisonment()

        ; Unset the flag so the state can be restored again at re-initialization upon being destroyed
        SetBool("ShouldRestorePrisonerState", false)
    endif
endFunction

function NPC_SavePrisonerState()
    return
    SetBool("ShouldRestorePrisonerState", true)
    Debug("["+ Name +"] Prisoner::NPC_SavePrisonerState", "Saving NPC state...")
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
    SetInt("Maximum Sentence to Clothe",                     Prison.MaximumSentence)
    SetBool("Clothe when Defeated",                          Prison.ClotheWhenDefeated)
    SetString("Outfit",                                      Prison.ClothingOutfit)
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
    SetFloat("Outfit::Minimum Bounty",                       Prison.OutfitMinimumBounty)
    SetFloat("Outfit::Maximum Bounty",                       Prison.OutfitMaximumBounty)

    ; ArrestVars.Serialize("Prisoner#" + self.GetIdentifier())
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
    int prisonID = GetInt("Prison ID")

    if (!prisonID)
        Fatal("There was an error retrieving the Prison belonging to Prisoner: " + self.Name)
        DebugError("["+ Name +"] Prisoner::GetPrison", "There was an error retrieving the Prison belonging to Prisoner: " + self.Name)
        __prisonFailedInitialization = true
        return none
    endif

    __cachedPrison = API.PrisonManager.GetPrisonByID(prisonID)
    return __cachedPrison
endFunction

RPB_JailCell function GetCell()
    return GetReference("Cell") as RPB_JailCell
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