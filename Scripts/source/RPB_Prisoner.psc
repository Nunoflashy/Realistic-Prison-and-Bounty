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
Actor captor ; To be changed, a prisoner shouldn't have a captor. The correct relation would be this prisoner to a prison, and multiple guards to a prison, not a prisoner
; Idea for the future: self.GetPrison().GetGuards() where the return type is RPB_Guard[], then each one could have prison cells assigned to them, or be selected at random to do some action
; Likewise, prisoners would be retrieved as such: self.GetPrison.GetPrisoners() where the return type is RPB_Prisoner[] and returns every prisoner in this particular prison by iterating through every prison cell.
; self.GetPrison() could return something like RPB_Prison or RPB_PrisonLocation, something akin to Faction
; This way, this prisoner script would no longer contain jailFaction or hold, since those would now be part of RPB_Prison

RPB_Prison property Prison
    RPB_Prison function get()
        return self.GetPrison() ; where it would search for an RPB_Prison where the location matches the prison location (current location for the prisoner since they are in prison)
    endFunction
endProperty

RPB_JailCell property JailCell
    RPB_JailCell function get()
        return none
    endFunction
endProperty


;/
    This Prison relation would also allow to retrieve the prison cells from it, like: Prison.GetPrisonCells(), return type: RPB_PrisonCell[]
    then this prisoner could have it retrieved as such:

    RPB_PrisonCell property PrisonCell
        RPB_PrisonCell function get()
            return Prison.GetPrisonCells().WherePrisonerIs(akPrisoner = this) ; something like this
        endFunction
    endProperty
/;

float property CurrentTime
    float function get()
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

ObjectReference property ItemsContainer
    ObjectReference function get()
        return Prison_GetReference("Prisoner Items Container")
    endFunction
endProperty

ObjectReference property TeleportReleaseLocation
    ObjectReference function get()
        return Prison_GetReference("Teleport Release Location")
    endFunction
endProperty

bool property IsImprisoned
    bool function get()
        return Prison_GetBool("Jailed")
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
        return Prison_GetFloat("Time of Arrest", "Arrest")
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

float property ReleaseTime
    float function get()
        float gameHour = 0.04166666666666666666666666666667
        return TimeOfImprisonment + (gameHour * 24 * Sentence)
    endFunction
endProperty

float property TimeLeftInSentence
    float function get()
        return (ReleaseTime - TimeOfImprisonment) - TimeServed
    endFunction
endProperty

bool property IsSentenceServed
    bool function get()
        return CurrentTime >= ReleaseTime
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

;/
    Assigns a jail cell to this prisoner
/;
bool function AssignCell()
    ; Get a random jail cell
    ObjectReference randomCell  = Prison.GetRandomPrisonCell()
    ObjectReference cellDoor    = Prison.GetCellDoor(randomCell)

    if (self.GetCell() && self.GetCellDoor())
        Debug(this, "Prisoner::AssignCell", "A prison cell has already been assigned to prisoner " + this + ": [" +"Cell: " + self.GetCell() + ", Door: " + self.GetCellDoor() + "]")
        ; Debug(this, "Prisoner::AssignCell", "A prison cell has already been assigned to prisoner " + this + ": [\n" + \
        ;     "Cell: " + self.GetCell() + "\n" + \
        ;     "Cell Door: " + self.GetCellDoor() + "\n" + \
        ; "]")

        return true
    endif

    Prison_SetReference("Cell", randomCell)
    Prison_SetReference("Cell Door", cellDoor)
    ; ArrestVars.SetReference("Jail::Cell", Game.GetFormEx(0x36897) as ObjectReference) ; Temp, later random or available one will be used
    ; ArrestVars.SetReference("Jail::Cell Door", Game.GetFormEx(0x5E921) as ObjectReference) ; Temp, later random or available one will be used

    Debug(this, "Prisoner::AssignCell", this + " has been assigned a prison cell" + ": [\n" + \
        "Cell: " + self.GetCell() + "\n" + \
        "Cell Door: " + self.GetCellDoor() + "\n" + \
    "]")

    return self.GetCell() != none
endFunction

; RPB_JailCell function GetCell()
;     ; RPB_JailCell jailCellRef = Jail.GetPrisonerCell(this) ; maybe?
; endFunction

; TODO: Change what this returns later to be dynamic
ObjectReference function GetCell()
    return Prison_GetReference("Cell")
endFunction

; TODO: Change what this returns later to be dynamic
ObjectReference function GetCellDoor()
    return Prison_GetReference("Cell Door")
endFunction

function SetReleaseLocation(bool abIsTeleportLocation = true)
    if (abIsTeleportLocation)
        Prison_SetForm("Teleport Release Location", Config.GetJailTeleportReleaseMarker(self.GetPrisonHold()))
    endif
endFunction

function SetItemsContainer()
    Prison_SetForm("Prisoner Items Container", Config.GetJailPrisonerItemsContainer(self.GetPrisonHold()))
    Debug(none, "Prison::SetItemsContainer", "Prisoner Items Container:  " + ItemsContainer)
    ; ArrestVars.SetForm("Jail::Prisoner Items Container", Config.GetJailPrisonerItemsContainer(self.GetHold())) ; Where prisoners have their items confiscated to
endFunction

;/
    Releases this prisoner from jail
/;
function Release()
    ItemsContainer.RemoveAllItems(this, false, true)
    this.MoveTo(TeleportReleaseLocation)
    self.Dispel()
endFunction

function Restrain()
    self.Cuff()
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

    self.SetItemsContainer()
    self.SetReleaseLocation()

    ; Utility.Wait(0.4)

    self.RegisterLastUpdate()
    self.MarkAsJailed()
    self.SetSentence()
    
    if (Prison_GetBool("Infamy Enabled"))
        self.TriggerInfamyPenalty()
    endif

    if (wasMoved)
        self.ProcessWhenMoved() ; Only use when moved, not when escorted (Handle all events at once)
    endif

    self.SetTimeOfImprisonment()

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
    this.RemoveAllItems(ItemsContainer, false, true)
    self.IncrementStat("Times Stripped")
    Prison_SetBool("Stripped", true) ; No use for now, might be changed
    return
    Debug(self.GetActor(), "Prisoner::Strip", "Strip called")

    Config.NotifyJail("Stripping Thoroughness: " + StrippingThoroughness)

    bool isStrippedNaked = StrippingThoroughness >= 6

    ; Get underwear
    int underwearTopSlotMask    = GetSlotMaskValue(config.UnderwearTopSlot)
    int underwearBottomSlotMask = GetSlotMaskValue(config.UnderwearBottomSlot)

    Armor underwearTop      = this.GetWornForm(underwearTopSlotMask) as Armor
    Armor underwearBottom   = this.GetWornForm(underwearBottomSlotMask) as Armor

    ; Remove and put all the items in the prisoner's posession in the assigned prisoner container
    this.RemoveAllItems(ItemsContainer, false, true)

    ; TODO: Determine what is required to happen to have the Prisoner be in underwear

    ; Unequip anything currently held in the hands for this Prisoner
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
        this.RemoveItem(underwearTop, 1, true, ItemsContainer)
    endif

    if (underwearBottom)
        this.RemoveItem(underwearBottom, 1, true, ItemsContainer)
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
    
    ; Later ideally self.GetCell().GetDoor() where GetCell() is of type RPB_JailCell or RPB_Cell or RPB_PrisonCell
    Jail.SceneManager.StartEscortToCell( \
        akEscortLeader      = akEscort, \
        akEscortedPrisoner  = this, \
        akJailCellMarker    = self.GetCell(), \
        akJailCellDoor      = self.GetCellDoor() \ 
    )
endFunction

; ==========================================================

; ==========================================================
;                          Sentence
; ==========================================================

function SetTimeOfImprisonment()
    Prison_SetFloat("Time of Imprisonment", CurrentTime) ; Set the time of imprisonment
    Prison_SetBool("Jailed", true)
endFunction

function SetSentence(int aiSentence = 0, bool abShouldAffectBounty = true)
    if (Prison_GetBool("Sentence Set"))
        return
    endif

    Prison_SetBool("Sentence Set", true)

    if (aiSentence == 0)
        ; Set sentence based on bounty
        Prison_SetInt("Sentence", \ 
            aiValue     = self.GetSentenceFromBounty(), \
            aiMinValue  = Prison.MinimumSentence, \
            aiMaxValue  = Prison.MaximumSentence \
        )
        return
    endif

    ; Set a sentence based on params
    Prison_SetInt("Sentence", \ 
        aiValue     = aiSentence, \
        aiMinValue  = Prison.MinimumSentence, \
        aiMaxValue  = Prison.MaximumSentence \
    )

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = Sentence * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        Prison_SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence, "Arrest")
    endif

    ; Fire Events
    ; OnSentenceChanged()
endFunction

function IncreaseSentence(int aiDaysToIncreaseBy, bool abShouldAffectBounty = true)
    int previousSentence    = Sentence
    int newSentence         = previousSentence + Max(0, aiDaysToIncreaseBy) as int

    ; Set the sentence
    self.SetSentence(newSentence)

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = aiDaysToIncreaseBy * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        Prison_SetInt("Bounty Non-Violent", BountyNonViolent + bountyEquivalentOfSentence)
    endif

    ; TODO: Fire events
    ; OnSentenceChanged(previousSentence, newSentence, aiDaysToIncreaseBy > 0, abShouldAffectBounty)    
endFunction

function DecreaseSentence(int aiDaysToDecreaseBy, bool abShouldAffectBounty = true)
    int previousSentence    = Sentence
    int newSentence         = previousSentence + Max(0, aiDaysToDecreaseBy) as int

    ; Set the sentence
    self.SetSentence(newSentence)

    if (abShouldAffectBounty)
        int bountyEquivalentOfSentence = aiDaysToDecreaseBy * Prison.BountyToSentence ; 2 Days = 200 Bounty if BountyToSentence = 100
        Prison_SetInt("Bounty Non-Violent", BountyNonViolent - bountyEquivalentOfSentence)
    endif

    ; TODO: Fire events
    ; OnSentenceChanged(previousSentence, newSentence, aiDaysToDecreaseBy > 0, abShouldAffectBounty)
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

; While this Prisoner is imprisoned in their cell
state Imprisoned
    event OnBeginState()
        ; if (!Prison.IsReceivingUpdates()) ; if we dont destroy the instance in time, this will get called from Prison after processing queued prisoners, and since we didnt register the prisoner, this is a bug since it will report 0 prisoners
            Prison.RegisterForPrisonPeriodicUpdate(self)
        ; endif
    endEvent

    event OnUpdateGameTime()
        ; Debug(this, "("+ self.CurrentState +") Prisoner::OnUpdateGameTime", "Began processing for prisoner " + this)
        ; Debug(this, "(state: "+ self.CurrentState +") Prisoner::OnUpdateGameTime", "Start Update for " + this)
        
        if (self.HasActiveBounty())
            ; self.UpdateSentenceFromCurrentBounty() ; temp, change function later
        endif

        if (Prison.EnableInfamy)
            self.UpdateInfamy()
        endif

        self.UpdateDaysImprisoned()

        if (self.IsSentenceServed) ; implementation is not finished
            self.Release()
            return
        endif

        ; DEBUG_ShowPrisonInfo()
        Prison.DEBUG_ShowPrisonerSentenceInfo(self, true)
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

bool __isEffectActive
bool property IsEffectActive
    bool function get()
        return __isEffectActive
    endFunction
endProperty

; Maybe this should be reset upon escape/release,
; otherwise it will keep adding the remainder of the days of previous arrests to current one,
; which is accurate since it tracks ALL the time the actor was in jail, but maybe not what is ideal.
; Example: 2h served right before release which doesn't account to a full day will be taken into account
; on the next arrest, which means the actor only has to serve 22h of the following arrest for it to count as a day
; since they already had 2h clocked in from the previous imprisonment.
float accumulatedTimeServed = 0.0

function UpdateDaysImprisoned()
    ; Add the time served from each update this runs
    accumulatedTimeServed += TimeSinceLastUpdate

    if (accumulatedTimeServed >= 1)
        ; A day or more has passed
        int fullDaysPassed = floor(accumulatedTimeServed) ; Get the full days
        Game.IncrementStat("Days Jailed", fullDaysPassed)
        self.IncrementStat("Days Jailed", fullDaysPassed)

        accumulatedTimeServed -= fullDaysPassed ; Remove the counted days from accumulated time served (Get the fractional part if there's any - i.e: hours)
        float accumulatedTimeRemaining = accumulatedTimeServed - fullDaysPassed
        Debug(none, "Prisoner::UpdateDaysImprisoned", "accumulatedTimeServed remaining: " + accumulatedTimeRemaining)
    endif

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

    this.MoveTo(self.GetCell())

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

function MarkAsJailed()
    Prison_SetBool("Jailed", true)
    self.IncrementStat("Times Jailed") ; Increment the "Times Jailed" stat for this Hold

    if (self.IsPlayer())
        Game.IncrementStat("Times Jailed") ; Increment the "Times Jailed" in the regular vanilla stat menu.
    endif
endFunction

function UpdateSentence()
    Debug(this, "Prisoner::UpdateSentence", "Prison.Hold: " + Prison.Hold)

    int nonViolent  = self.GetActiveBounty(abViolent = false)
    int violent     = self.GetActiveBounty(abNonViolent = false)

    if (nonViolent + violent > 0)
        self.HideBounty()
    endif

    Prison_SetBool("Sentence Set", false) ; To be able to re-set the sentence
    self.SetSentence()
    self.UpdateLongestSentence()
endFunction

function TriggerInfamyPenalty()

endFunction

; ==========================================================

function MoveToCaptor()
    this.MoveTo(captor)
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
    RPB_Arrestee arresteeRef = Arrest.MarkActorAsArrestee(this)
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
    __isEffectActive = true

    ; Prison.RegisterForPrisonPeriodicUpdate(self)

    if (NPC_RestorePrisonerState())
        ; Actor was already a prisoner, do not initialize normally and instead proceed to restoring their previous state
        Prison.RegisterPrisoner(self, this) ; Registers this prisoner into the prisoner list since they were unregistered OnDestroy()
        self.RegisterForTrackedStats()
        return
    endif

    Prison.RegisterPrisoner(self, this) ; Registers this prisoner into the prisoner list

    ; Debug(this, "Prisoner::OnInitialize", "Initialized Prisoner, this: " + this)
    self.RegisterForTrackedStats()
    self.LockPrisonerSettings()
endEvent

bool property IsEnabledForBackgroundUpdates auto

event OnDestroy()
    __isEffectActive = false

    if (!self.IsPlayer())
        self.NPC_SavePrisonerState()

        if (!Prison.IsReceivingUpdates()) ; if we dont destroy the instance in time, this will get called from Prison after processing queued prisoners, and since we didnt register the prisoner, this is a bug since it will report 0 prisoners
            Prison.RegisterForPrisonPeriodicUpdate(self)
        endif
    endif

    Prison.UnregisterPrisoner(self) ; Remove this Actor from the AME list since they are no longer a prisoner
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

event OnStatChanged(string asStatName, int aiValue)
    if (asStatName == self.GetHold() + " Bounty") ; If there's bounty gained in the current prison hold
        self.OnBountyGained()
        ; Maybe inform the prisoner of their new sentence and have them escorted out of the cell to be frisked/stripped if they are not
    endif

    ; Debug(this, "Prisoner::OnStatChanged", "Stat " + asStatName + " has been changed to " + aiValue)
endEvent

; ==========================================================
;                          Management
; ==========================================================

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

    hasSettingsLocked = true
endFunction

; function SetupPrisonVars()
;     float x = StartBenchmark()
;     JailVars.SetBool("Jail::Infamy Enabled", config.IsInfamyEnabled(hold))
;     JailVars.SetFloat("Jail::Infamy Recognized Threshold", config.GetInfamyRecognizedThreshold(hold))
;     JailVars.SetFloat("Jail::Infamy Known Threshold", config.GetInfamyKnownThreshold(hold))
;     JailVars.SetFloat("Jail::Infamy Gained Daily from Current Bounty", config.GetInfamyGainedDailyFromArrestBounty(hold))
;     JailVars.SetFloat("Jail::Infamy Gained Daily", config.GetInfamyGainedDaily(hold))
;     JailVars.SetInt("Jail::Infamy Gain Modifier (Recognized)", config.GetInfamyGainModifier(Hold, "Recognized"))
;     JailVars.SetInt("Jail::Infamy Gain Modifier (Known)", config.GetInfamyGainModifier(Hold, "Known"))
;     JailVars.SetFloat("Jail::Bounty Exchange", config.GetJailBountyExchange(hold))
;     JailVars.SetFloat("Jail::Bounty to Sentence", config.GetJailBountyToSentence(hold))
;     JailVars.SetFloat("Jail::Minimum Sentence", config.GetJailMinimumSentence(hold))
;     JailVars.SetFloat("Jail::Maximum Sentence", config.GetJailMaximumSentence(hold))
;     JailVars.SetFloat("Jail::Cell Search Thoroughness", config.GetJailCellSearchThoroughness(hold))
;     JailVars.SetString("Jail::Cell Lock Level", config.GetJailCellDoorLockLevel(hold))
;     ; Prisoner_SetString("Cell Lock Level", Prison.CellLockLevel)
;     JailVars.SetBool("Jail::Fast Forward", config.IsJailFastForwardEnabled(hold))
;     JailVars.SetFloat("Jail::Day to Fast Forward From", config.GetJailFastForwardDay(hold))
;     JailVars.SetString("Jail::Handle Skill Loss", config.GetJailHandleSkillLoss(hold))
;     JailVars.SetFloat("Jail::Day to Start Losing Skills", config.GetJailDayToStartLosingSkills(hold))
;     JailVars.SetFloat("Jail::Chance to Lose Skills", config.GetJailChanceToLoseSkillsDaily(hold))
;     JailVars.SetFloat("Jail::Recognized Criminal Penalty", config.GetJailRecognizedCriminalPenalty(hold))
;     JailVars.SetFloat("Jail::Known Criminal Penalty", config.GetJailKnownCriminalPenalty(hold))
;     JailVars.SetFloat("Jail::Bounty to Trigger Infamy", config.GetJailBountyToTriggerCriminalPenalty(hold))
;     JailVars.SetBool("Release::Release Fees Enabled", config.IsJailReleaseFeesEnabled(hold))
;     JailVars.SetFloat("Release::Chance for Release Fees Event", config.GetReleaseChanceForReleaseFeesEvent(hold))
;     JailVars.SetFloat("Release::Bounty to Owe Fees", config.GetReleaseBountyToOweFees(hold))
;     JailVars.SetFloat("Release::Release Fees from Arrest Bounty", config.GetReleaseReleaseFeesFromBounty(hold))
;     JailVars.SetFloat("Release::Release Fees Flat", config.GetReleaseReleaseFeesFlat(hold))
;     JailVars.SetFloat("Release::Days Given to Pay Release Fees", config.GetReleaseDaysGivenToPayReleaseFees(hold))
;     JailVars.SetBool("Release::Item Retention Enabled", config.IsItemRetentionEnabledOnRelease(hold))
;     JailVars.SetFloat("Release::Bounty to Retain Items", config.GetReleaseBountyToRetainItems(hold))
;     JailVars.SetBool("Release::Redress on Release", config.IsAutoDressingEnabledOnRelease(hold))
;     JailVars.SetFloat("Escape::Escape Bounty from Current Arrest", config.GetEscapedBountyFromCurrentArrest(hold))
;     JailVars.SetFloat("Escape::Escape Bounty Flat", config.GetEscapedBountyFlat(hold))
;     JailVars.SetBool("Escape::Allow Surrendering", config.IsSurrenderEnabledOnEscape(hold))
;     JailVars.SetBool("Escape::Account for Time Served", config.IsTimeServedAccountedForOnEscape(hold))
;     JailVars.SetBool("Escape::Should Frisk Search", config.ShouldFriskOnEscape(hold))
;     JailVars.SetBool("Escape::Should Strip Search", config.ShouldStripOnEscape(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Impersonation", config.GetChargeBountyForImpersonation(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Enemy of Hold", config.GetChargeBountyForEnemyOfHold(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Stolen Items", config.GetChargeBountyForStolenItems(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Stolen Item", config.GetChargeBountyForStolenItemFromItemValue(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Contraband", config.GetChargeBountyForContraband(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Cell Key", config.GetChargeBountyForCellKey(hold))
;     JailVars.SetBool("Frisking::Allow Frisking", config.IsFriskingEnabled(hold))
;     JailVars.SetBool("Frisking::Unconditional Frisking", config.IsFriskingUnconditional(hold))
;     JailVars.SetFloat("Frisking::Bounty for Frisking", config.GetFriskingBountyRequired(hold))
;     JailVars.SetFloat("Frisking::Frisking Thoroughness", config.GetFriskingThoroughness(hold))
;     JailVars.SetBool("Frisking::Confiscate Stolen Items", config.IsFriskingStolenItemsConfiscated(hold))
;     JailVars.SetBool("Frisking::Strip if Stolen Items Found", config.IsFriskingStripSearchWhenStolenItemsFound(hold))
;     JailVars.SetFloat("Frisking::Stolen Items Required for Stripping", config.GetFriskingStolenItemsRequiredForStripping(hold))
;     JailVars.SetBool("Stripping::Allow Stripping", config.IsStrippingEnabled(hold))
;     JailVars.SetString("Stripping::Handle Stripping On", config.GetStrippingHandlingCondition(hold))
;     JailVars.SetInt("Stripping::Bounty to Strip", config.GetStrippingMinimumBounty(hold))
;     JailVars.SetInt("Stripping::Violent Bounty to Strip", config.GetStrippingMinimumViolentBounty(hold))
;     JailVars.SetInt("Stripping::Sentence to Strip", config.GetStrippingMinimumSentence(hold))
;     JailVars.SetBool("Stripping::Strip when Defeated", config.IsStrippedOnDefeat(hold))
;     JailVars.SetFloat("Stripping::Stripping Thoroughness", config.GetStrippingThoroughness(hold))
;     JailVars.SetInt("Stripping::Stripping Thoroughness Modifier", config.GetStrippingThoroughnessBountyModifier(hold))
;     JailVars.SetBool("Clothing::Allow Clothing", config.IsClothingEnabled(hold))
;     JailVars.SetString("Clothing::Handle Clothing On", config.GetClothingHandlingCondition(hold))
;     JailVars.SetFloat("Clothing::Maximum Bounty to Clothe", config.GetClothingMaximumBounty(hold))
;     JailVars.SetFloat("Clothing::Maximum Violent Bounty to Clothe", config.GetClothingMaximumViolentBounty(hold))
;     JailVars.SetFloat("Clothing::Maximum Sentence to Clothe", config.GetClothingMaximumSentence(hold))
;     JailVars.SetBool("Clothing::Clothe when Defeated", config.IsClothedOnDefeat(hold))
;     JailVars.SetString("Clothing::Outfit", config.GetClothingOutfit(hold))

;     ; Outfit
;     JailVars.SetString("Clothing::Outfit::Name", config.GetClothingOutfit(hold))
;     JailVars.SetForm("Clothing::Outfit::Head", config.GetOutfitPart(Hold, "Head"))
;     JailVars.SetForm("Clothing::Outfit::Body", config.GetOutfitPart(Hold, "Body"))
;     JailVars.SetForm("Clothing::Outfit::Hands", config.GetOutfitPart(Hold, "Hands"))
;     JailVars.SetForm("Clothing::Outfit::Feet", config.GetOutfitPart(Hold, "Feet"))
;     JailVars.SetBool("Clothing::Outfit::Conditional", config.IsClothingOutfitConditional(hold))
;     JailVars.SetFloat("Clothing::Outfit::Minimum Bounty", config.GetClothingOutfitMinimumBounty(hold))
;     JailVars.SetFloat("Clothing::Outfit::Maximum Bounty", config.GetClothingOutfitMaximumBounty(hold))

;     JailVars.SetBool("Override::Release::Item Retention Enabled", false)
;     ; arrestVars.SetInt("Override::Jail::Minimum Sentence", 1)
;     ; arrestVars.SetString("Override::Stripping::Handle Stripping On", "Unconditionally")
;     ; arrestVars.SetString("Override::Clothing::Handle Clothing On", "Unconditionally")
;     EndBenchmark(x, "SetupJailVars")
; endFunction

; function SetupPrisonVars()
;     float x = StartBenchmark()
;     JailVars.SetBool("Jail::Infamy Enabled", config.IsInfamyEnabled(hold))
;     JailVars.SetFloat("Jail::Infamy Recognized Threshold", config.GetInfamyRecognizedThreshold(hold))
;     JailVars.SetFloat("Jail::Infamy Known Threshold", config.GetInfamyKnownThreshold(hold))
;     JailVars.SetFloat("Jail::Infamy Gained Daily from Current Bounty", config.GetInfamyGainedDailyFromArrestBounty(hold))
;     JailVars.SetFloat("Jail::Infamy Gained Daily", config.GetInfamyGainedDaily(hold))
;     JailVars.SetInt("Jail::Infamy Gain Modifier (Recognized)", config.GetInfamyGainModifier(Hold, "Recognized"))
;     JailVars.SetInt("Jail::Infamy Gain Modifier (Known)", config.GetInfamyGainModifier(Hold, "Known"))
;     JailVars.SetFloat("Jail::Bounty Exchange", config.GetJailBountyExchange(hold))
;     JailVars.SetFloat("Jail::Bounty to Sentence", config.GetJailBountyToSentence(hold))
;     JailVars.SetFloat("Jail::Minimum Sentence", config.GetJailMinimumSentence(hold))
;     JailVars.SetFloat("Jail::Maximum Sentence", config.GetJailMaximumSentence(hold))
;     JailVars.SetFloat("Jail::Cell Search Thoroughness", config.GetJailCellSearchThoroughness(hold))
;     JailVars.SetString("Jail::Cell Lock Level", config.GetJailCellDoorLockLevel(hold))
;     ; Prisoner_SetString("Cell Lock Level", Prison.CellLockLevel)
;     JailVars.SetBool("Jail::Fast Forward", config.IsJailFastForwardEnabled(hold))
;     JailVars.SetFloat("Jail::Day to Fast Forward From", config.GetJailFastForwardDay(hold))
;     JailVars.SetString("Jail::Handle Skill Loss", config.GetJailHandleSkillLoss(hold))
;     JailVars.SetFloat("Jail::Day to Start Losing Skills", config.GetJailDayToStartLosingSkills(hold))
;     JailVars.SetFloat("Jail::Chance to Lose Skills", config.GetJailChanceToLoseSkillsDaily(hold))
;     JailVars.SetFloat("Jail::Recognized Criminal Penalty", config.GetJailRecognizedCriminalPenalty(hold))
;     JailVars.SetFloat("Jail::Known Criminal Penalty", config.GetJailKnownCriminalPenalty(hold))
;     JailVars.SetFloat("Jail::Bounty to Trigger Infamy", config.GetJailBountyToTriggerCriminalPenalty(hold))
;     JailVars.SetBool("Release::Release Fees Enabled", config.IsJailReleaseFeesEnabled(hold))
;     JailVars.SetFloat("Release::Chance for Release Fees Event", config.GetReleaseChanceForReleaseFeesEvent(hold))
;     JailVars.SetFloat("Release::Bounty to Owe Fees", config.GetReleaseBountyToOweFees(hold))
;     JailVars.SetFloat("Release::Release Fees from Arrest Bounty", config.GetReleaseReleaseFeesFromBounty(hold))
;     JailVars.SetFloat("Release::Release Fees Flat", config.GetReleaseReleaseFeesFlat(hold))
;     JailVars.SetFloat("Release::Days Given to Pay Release Fees", config.GetReleaseDaysGivenToPayReleaseFees(hold))
;     JailVars.SetBool("Release::Item Retention Enabled", config.IsItemRetentionEnabledOnRelease(hold))
;     JailVars.SetFloat("Release::Bounty to Retain Items", config.GetReleaseBountyToRetainItems(hold))
;     JailVars.SetBool("Release::Redress on Release", config.IsAutoDressingEnabledOnRelease(hold))
;     JailVars.SetFloat("Escape::Escape Bounty from Current Arrest", config.GetEscapedBountyFromCurrentArrest(hold))
;     JailVars.SetFloat("Escape::Escape Bounty Flat", config.GetEscapedBountyFlat(hold))
;     JailVars.SetBool("Escape::Allow Surrendering", config.IsSurrenderEnabledOnEscape(hold))
;     JailVars.SetBool("Escape::Account for Time Served", config.IsTimeServedAccountedForOnEscape(hold))
;     JailVars.SetBool("Escape::Should Frisk Search", config.ShouldFriskOnEscape(hold))
;     JailVars.SetBool("Escape::Should Strip Search", config.ShouldStripOnEscape(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Impersonation", config.GetChargeBountyForImpersonation(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Enemy of Hold", config.GetChargeBountyForEnemyOfHold(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Stolen Items", config.GetChargeBountyForStolenItems(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Stolen Item", config.GetChargeBountyForStolenItemFromItemValue(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Contraband", config.GetChargeBountyForContraband(hold))
;     JailVars.SetFloat("Additional Charges::Bounty for Cell Key", config.GetChargeBountyForCellKey(hold))
;     JailVars.SetBool("Frisking::Allow Frisking", config.IsFriskingEnabled(hold))
;     JailVars.SetBool("Frisking::Unconditional Frisking", config.IsFriskingUnconditional(hold))
;     JailVars.SetFloat("Frisking::Bounty for Frisking", config.GetFriskingBountyRequired(hold))
;     JailVars.SetFloat("Frisking::Frisking Thoroughness", config.GetFriskingThoroughness(hold))
;     JailVars.SetBool("Frisking::Confiscate Stolen Items", config.IsFriskingStolenItemsConfiscated(hold))
;     JailVars.SetBool("Frisking::Strip if Stolen Items Found", config.IsFriskingStripSearchWhenStolenItemsFound(hold))
;     JailVars.SetFloat("Frisking::Stolen Items Required for Stripping", config.GetFriskingStolenItemsRequiredForStripping(hold))
;     JailVars.SetBool("Stripping::Allow Stripping", config.IsStrippingEnabled(hold))
;     JailVars.SetString("Stripping::Handle Stripping On", config.GetStrippingHandlingCondition(hold))
;     JailVars.SetInt("Stripping::Bounty to Strip", config.GetStrippingMinimumBounty(hold))
;     JailVars.SetInt("Stripping::Violent Bounty to Strip", config.GetStrippingMinimumViolentBounty(hold))
;     JailVars.SetInt("Stripping::Sentence to Strip", config.GetStrippingMinimumSentence(hold))
;     JailVars.SetBool("Stripping::Strip when Defeated", config.IsStrippedOnDefeat(hold))
;     JailVars.SetFloat("Stripping::Stripping Thoroughness", config.GetStrippingThoroughness(hold))
;     JailVars.SetInt("Stripping::Stripping Thoroughness Modifier", config.GetStrippingThoroughnessBountyModifier(hold))
;     JailVars.SetBool("Clothing::Allow Clothing", config.IsClothingEnabled(hold))
;     JailVars.SetString("Clothing::Handle Clothing On", config.GetClothingHandlingCondition(hold))
;     JailVars.SetFloat("Clothing::Maximum Bounty to Clothe", config.GetClothingMaximumBounty(hold))
;     JailVars.SetFloat("Clothing::Maximum Violent Bounty to Clothe", config.GetClothingMaximumViolentBounty(hold))
;     JailVars.SetFloat("Clothing::Maximum Sentence to Clothe", config.GetClothingMaximumSentence(hold))
;     JailVars.SetBool("Clothing::Clothe when Defeated", config.IsClothedOnDefeat(hold))
;     JailVars.SetString("Clothing::Outfit", config.GetClothingOutfit(hold))

;     ; Outfit
;     JailVars.SetString("Clothing::Outfit::Name", config.GetClothingOutfit(hold))
;     JailVars.SetForm("Clothing::Outfit::Head", config.GetOutfitPart(Hold, "Head"))
;     JailVars.SetForm("Clothing::Outfit::Body", config.GetOutfitPart(Hold, "Body"))
;     JailVars.SetForm("Clothing::Outfit::Hands", config.GetOutfitPart(Hold, "Hands"))
;     JailVars.SetForm("Clothing::Outfit::Feet", config.GetOutfitPart(Hold, "Feet"))
;     JailVars.SetBool("Clothing::Outfit::Conditional", config.IsClothingOutfitConditional(hold))
;     JailVars.SetFloat("Clothing::Outfit::Minimum Bounty", config.GetClothingOutfitMinimumBounty(hold))
;     JailVars.SetFloat("Clothing::Outfit::Maximum Bounty", config.GetClothingOutfitMaximumBounty(hold))

;     JailVars.SetBool("Override::Release::Item Retention Enabled", false)
;     ; arrestVars.SetInt("Override::Jail::Minimum Sentence", 1)
;     ; arrestVars.SetString("Override::Stripping::Handle Stripping On", "Unconditionally")
;     ; arrestVars.SetString("Override::Clothing::Handle Clothing On", "Unconditionally")
;     EndBenchmark(x, "SetupJailVars")
; endFunction

; ==========================================================
;                      -- Arrest Vars --
;                           Getters
bool function Prison_GetBool(string asVarName, string asVarCategory = "Jail")
    return parent.Vars_GetBool(asVarName, asVarCategory)
endFunction

int function Prison_GetInt(string asVarName, string asVarCategory = "Jail")
    return parent.Vars_GetInt(asVarName, asVarCategory)
endFunction

float function Prison_GetFloat(string asVarName, string asVarCategory = "Jail")
    return parent.Vars_GetFloat(asVarName, asVarCategory)
endFunction

string function Prison_GetString(string asVarName, string asVarCategory = "Jail")
    return parent.Vars_GetString(asVarName, asVarCategory)
endFunction

Form function Prison_GetForm(string asVarName, string asVarCategory = "Jail")
    return parent.Vars_GetForm(asVarName, asVarCategory)
endFunction

ObjectReference function Prison_GetReference(string asVarName, string asVarCategory = "Jail")
    return parent.Vars_GetReference(asVarName, asVarCategory)
endFunction

Actor function Prison_GetActor(string asVarName, string asVarCategory = "Jail")
    return parent.Vars_GetActor(asVarName, asVarCategory)
endFunction
;                          Setters
function Prison_SetBool(string asVarName, bool abValue, string asVarCategory = "Jail")
    parent.Vars_SetBool(asVarName, abValue, asVarCategory)
endFunction

function Prison_SetInt(string asVarName, int aiValue, string asVarCategory = "Jail", int aiMinValue = 0, int aiMaxValue = 0)
    parent.Vars_SetInt(asVarName, aiValue, asVarCategory, aiMinValue, aiMaxValue)
endFunction

function Prison_ModInt(string asVarName, int aiValue, string asVarCategory = "Jail")
    parent.Vars_ModInt(asVarName, aiValue, asVarCategory)
endFunction

function Prison_SetFloat(string asVarName, float afValue, string asVarCategory = "Jail")
    parent.Vars_SetFloat(asVarName, afValue, asVarCategory)
endFunction

function Prison_ModFloat(string asVarName, float afValue, string asVarCategory = "Jail")
    parent.Vars_ModFloat(asVarName, afValue, asVarCategory)
endFunction

function Prison_SetString(string asVarName, string asValue, string asVarCategory = "Jail")
    parent.Vars_SetString(asVarName, asValue, asVarCategory)
endFunction

function Prison_SetForm(string asVarName, Form akValue, string asVarCategory = "Jail")
    parent.Vars_SetForm(asVarName, akValue, asVarCategory)
endFunction

function Prison_SetReference(string asVarName, ObjectReference akValue, string asVarCategory = "Jail")
    parent.Vars_SetReference(asVarName, akValue, asVarCategory)
endFunction

function Prison_SetActor(string asVarName, Actor akValue, string asVarCategory = "Jail")
    parent.Vars_SetActor(asVarName, akValue, asVarCategory)
endFunction

function Prison_Remove(string asVarName, string asVarCategory = "Jail")
    parent.Vars_Remove(asVarName, asVarCategory)
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
    string prisonHold               = Vars_GetString("Hold", "Arrest") 
    RPB_PrisonManager prisonManager = GetFormFromMod(0x1B825) as RPB_PrisonManager
    RPB_Prison returnedPrison       = prisonManager.GetPrison(prisonHold)
    
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
        "Arrested: "            + Vars_GetBool("Arrested") + ", \n\t" + \
        "Jailed: "              + self.IsImprisoned + ", \n\t" + \
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