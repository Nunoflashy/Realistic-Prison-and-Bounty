scriptname RealisticPrisonAndBounty_PrisonerRef extends ReferenceAlias

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

Actor property this
    Actor function get()
        return self.GetActorReference()
    endFunction
endProperty

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_ActorVars property ActorVars
    RealisticPrisonAndBounty_ActorVars function get()
        return Config.ActorVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return Config.MiscVars
    endFunction
endProperty

RealisticPrisonAndBounty_BodySearcher property BodySearcher
    RealisticPrisonAndBounty_BodySearcher function get()
        return Config.mainAPI as RealisticPrisonAndBounty_BodySearcher
    endFunction
endProperty

RealisticPrisonAndBounty_Clothing property PrisonerDresser
    RealisticPrisonAndBounty_Clothing function get()
        return Config.mainAPI as RealisticPrisonAndBounty_Clothing
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property Jail
    RealisticPrisonAndBounty_Jail function get()
        return Config.Jail
    endFunction
endProperty

int property BountyNonViolent
    int function get()
        return arrestVars.GetInt("Arrest::Bounty Non-Violent")
    endFunction
endProperty

int property BountyViolent
    int function get()
        return arrestVars.GetInt("Arrest::Bounty Violent")
    endFunction
endProperty

int property Bounty
    int function get()
        return BountyNonViolent + BountyViolent
    endFunction
endProperty

bool property MeetsOutfitConditions
    bool function get()
        return Bounty >= arrestVars.OutfitMinBounty && Bounty <= arrestVars.OutfitMaxBounty
    endFunction
endProperty

Faction property JailFaction
    Faction function get()
        if (this == config.Player)
            return arrestVars.ArrestFaction
        else
            return arrestVars.GetForm("["+ this.GetFormID() +"]Arrest::Arrest Faction") as Faction
        endif
    endFunction
endProperty

Faction property ArrestFaction
    Faction function get()
        return JailFaction
    endFunction
endProperty

string property Hold
    string function get()
        return arrestVars.GetString("Arrest::Hold")
    endFunction
endProperty

float property CurrentTime
    float function get()
        return Utility.GetCurrentGameTime()
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
        return arrestVars.GetFloat("Arrest::Time of Arrest")
    endFunction
endProperty

float property TimeOfImprisonment
    float function get()
        return arrestVars.GetFloat("Jail::Time of Imprisonment")
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

; Maybe this should be reset upon escape/release,
; otherwise it will keep adding the remainder of the days of previous arrests to current one,
; which is accurate since it tracks ALL the time the actor was in jail, but maybe not what is ideal.
; Example: 2h served right before release which doesn't account to a full day will be taken into account
; on the next arrest, which means the actor only has to serve 22h of the following arrest for it to count as a day
; since they already had 2h clocked in from the previous imprisonment.
float accumulatedTimeServed

int property InfamyGainedDaily
    ;/
        arrestVars.InfamyGainedDaily: 40
        arrestVars.InfamyGainedDailyFromBountyPercentage: 1.44%
        Bounty: 3000
        <=> floor(3000 * (1.44/100) + 40)
        <=> floor(3000 * 0.0144) + 40
        <=> floor(43.2) + 40
        <=> 43 + 40 = 83
    /;
    int function get()
        if (IsInfamyKnown && arrestVars.InfamyGainModifierKnown != 0)
            return (round(Bounty * arrestVars.InfamyGainedDailyFromBountyPercentage) + arrestVars.InfamyGainedDaily) * \
                    int_if (arrestVars.InfamyGainModifierKnown < 0, (1 / abs(arrestVars.InfamyGainModifierKnown) as int), arrestVars.InfamyGainModifierKnown)
                    
        elseif (IsInfamyRecognized && arrestVars.InfamyGainModifierRecognized != 0)
            return (round(Bounty * arrestVars.InfamyGainedDailyFromBountyPercentage) + arrestVars.InfamyGainedDaily) * \
                    int_if (arrestVars.InfamyGainModifierRecognized < 0, (1 / abs(arrestVars.InfamyGainModifierRecognized) as int), arrestVars.InfamyGainModifierRecognized)
        endif

        return round(Bounty * arrestVars.InfamyGainedDailyFromBountyPercentage) + arrestVars.InfamyGainedDaily
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

bool property IsInfamyRecognized
    bool function get()
        return CurrentInfamy >= arrestVars.InfamyRecognizedThreshold
    endFunction
endProperty

bool property IsInfamyKnown
    bool function get()
        return CurrentInfamy >= arrestVars.InfamyKnownThreshold
    endFunction
endProperty

int property CurrentInfamy
    int function get()
        return self.QueryStat("Infamy Gained")
    endFunction
endProperty

int property InfamyBountyPenalty
    int function get()
        float infamyTypePenalty = float_if (IsInfamyKnown, arrestVars.InfamyKnownPenalty, float_if (IsInfamyRecognized, arrestVars.InfamyRecognizedPenalty))
        return round(CurrentInfamy * infamyTypePenalty)
    endFunction
endProperty

bool property Stripped
    bool function get()
        return arrestVars.IsStripped
    endFunction
endProperty

int property Sentence
    int function get()
        return arrestVars.Sentence
    endFunction
endProperty

ObjectReference property JailCell
    ObjectReference function get()
        if (this == config.Player)
            ; Get the Jail Cell for Player (Always the same variable)
            return arrestVars.GetReference("Jail::Cell")
        else
            ; Get the Jail Cell for NPC's (Example)
            return arrestVars.GetReference("["+ this.GetFormID() +"]Jail::Cell")
        endif
    endFunction
endProperty

ObjectReference property CellDoor
    ObjectReference function get()
        return arrestVars.GetReference("Jail::Cell Door")
    endFunction
endProperty

Location property PrisonLocation
    Location function get()
        return arrestVars.GetForm("Jail::Prison Location") as Location
    endFunction
endProperty

bool property IsJailed
    bool function get()
        return arrestVars.GetBool("Jail::Jailed")
    endFunction
endProperty

bool alreadyLeftPrisonLocationOnce = false

; Increments the desired stat in this Arrest faction for this Prisoner.
function IncrementStat(string statName, int incrementBy = 1)
    actorVars.IncrementStat(statName, ArrestFaction, this, incrementBy)
endFunction

int function QueryStat(string statName)
    return actorVars.GetStat(statName, ArrestFaction, this)
endFunction

function SetStat(string statName, int value)
    actorVars.SetStat(statName, ArrestFaction, this, value)
endFunction

; To handle both Player and NPC's later
; function SetFloat(string arrestProperty, float value)
;     arrestVars.SetFloat(string_if (this == config.Player, arrestProperty, "["+ this.GetFormID() +"]" + arrestProperty), value)
; endFunction

function SetupPrisonerVars()
    ; Dynamic Vars
    arrestVars.SetFloat("Jail::Sentence", (BountyNonViolent + (floor(BountyViolent * (100 / arrestVars.BountyExchange)))) / arrestVars.BountyToSentence)
    arrestVars.SetFloat("Jail::Time of Imprisonment", CurrentTime)
    arrestVars.SetForm("Jail::Prison Location", this.GetCurrentLocation()) ; Since we are in the prison, this is the prison location
    ; arrestVars.SetForm("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(Hold), JailCell, 10000))
    arrestVars.SetReference("Jail::Cell Door", Game.GetFormEx(0x5E921) as ObjectReference)
    arrestVars.SetInt("Jail::Cell Door Old Lock Level", CellDoor.GetLockLevel())
    arrestVars.SetForm("Jail::Teleport Release Location", config.GetJailTeleportReleaseMarker(Hold))
    arrestVars.SetForm("Jail::Prisoner Items Container", config.GetJailPrisonerItemsContainer(Hold))
    arrestVars.SetBool("Jail::Jailed", true)

    Debug(none, "PrisonerRef::SetupPrisonerVars", "Vars: [ \n" + \
        "Captor: " + arrestVars.Captor + "\n" + \
        "Arrestee: " + arrestVars.Arrestee + "\n" + \
        "Cell Door: " + arrestVars.GetReference("Jail::Cell Door") + "\n" + \
        "Cell: " + arrestVars.JailCell + "\n" + \
    "]")

    ; ; inventation time (Later this container must be dynamic for each actor in prison)
    arrestVars.SetObject("Jail::Prisoner Equipped Items", JArray.object())
endFunction

function ResetArrestVars()
    if (this == config.Player)
        ; Restore jail objects original state
        CellDoor.SetLockLevel(arrestVars.GetInt("Jail::Cell Door Old Lock Level"))

        ; Arrest Vars
        arrestVars.Remove("Arrest::Arrested")
        arrestVars.Remove("Arrest::Arrestee")
        arrestVars.Remove("Arrest::Hold")
        arrestVars.Remove("Arrest::Bounty Non-Violent")
        arrestVars.Remove("Arrest::Bounty Violent")
        arrestVars.Remove("Arrest::Arrest Faction")
        arrestVars.Remove("Arrest::Arresting Guard")
        arrestVars.Remove("Arrest::Time of Arrest")
        arrestVars.Remove("Arrest::Defeated")
        arrestVars.Remove("Arrest::Bounty for Defeat")

        ; Jail Vars
        arrestVars.Remove("Jail::Jailed")
        arrestVars.Remove("Jail::Stripped")
        arrestVars.Remove("Jail::Clothed")
        arrestVars.Remove("Jail::Sentence")
        arrestVars.Remove("Jail::Time of Imprisonment")
        arrestVars.Remove("Jail::Cell")
        arrestVars.Remove("Jail::Cell Door")

        accumulatedTimeServed = 0.0
    endif
endFunction

;/
    Registers the last update for the prisoner, 
    this is a crucial variable used to determine updated sentences, infamy gained, and so on...
/;
function RegisterLastUpdate()
    LastUpdate = Utility.GetCurrentGameTime()
endFunction

; Determines whether this prisoner should be stripped or not
bool function ShouldBeStripped()
    if (Stripped || !arrestVars.IsStrippingEnabled)
        return false
    endif

    if (self.HasEscaped() && arrestVars.ShouldStripOnEscape)
        return true
    endif

    bool meetsBountyRequirements    = (BountyNonViolent >= arrestVars.StrippingMinBounty) || (BountyViolent >= arrestVars.StrippingMinViolentBounty)
    bool meetsSentenceRequirements  = TimeLeftInSentence >= arrestVars.StrippingMinSentence
    return arrestVars.IsStrippingUnconditional || (arrestVars.StrippingHandling == "Minimum Bounty" && meetsBountyRequirements) || (arrestVars.StrippingHandling == "Minimum Sentence" && meetsSentenceRequirements)
endFunction

; Determines whether this prisoner should be clothed upon being stripped
bool function ShouldBeClothed()
    if (!arrestVars.IsClothingEnabled)
        return false
    endif

    ; Don't clothe if the player was defeated and it's configured to be disabled in the MCM
    if (!arrestVars.ClotheWhenDefeated && arrestVars.WasDefeated)
        return false
    endif

    bool meetsBountyRequirements    = (BountyNonViolent <= arrestVars.ClothingMaxBounty) && (BountyViolent <= arrestVars.ClothingMaxBountyViolent)
    bool meetsSentenceRequirements  = Sentence <= arrestVars.ClothingMaxSentence
    return arrestVars.ClothingHandling || (arrestVars.ClothingHandling == "Maximum Bounty" && meetsBountyRequirements) || (arrestVars.ClothingHandling == "Maximum Sentence" && meetsSentenceRequirements)
endFunction

bool function ShouldBeFrisked()
    if (!arrestVars.IsFriskingEnabled)
        return false
    endif

    return arrestVars.IsFriskingUnconditional || Bounty >= arrestVars.FriskingMinBounty
endFunction

bool function ShouldItemsBeRetained()
    bool itemRetentionEnabled = arrestVars.GetBool("Release::Item Retention Enabled")
    if (!itemRetentionEnabled)
        return false
    endif

    int minBountyToRetainItems = arrestVars.GetInt("Release::Bounty to Retain Items")
    return Bounty >= minBountyToRetainItems
endFunction

bool function IsNaked()
    ; return bodySearcher.IsActorNaked(this)
    return !ActorHasClothing(this)
endFunction

bool function HasActiveBounty()
    return ArrestFaction.GetCrimeGold() > 0 || (arrestVars.GetInt("Jail::Bounty Non-Violent") + arrestVars.GetInt("Jail::Bounty Violent")) > 0
endFunction

bool function HasEscaped()
    return arrestVars.GetBool("Jail::Escaped")
endFunction

function Frisk()
    ObjectReference prisonerItemsContainer = arrestVars.PrisonerItemsContainer
    
    float friskingThoroughness = arrestVars.GetFloat("Frisking::Frisking Thoroughness")
    bodySearcher.FriskActor(this, friskingThoroughness, prisonerItemsContainer)
    self.OnFriskSearched(prisonerItemsContainer)
endFunction

function Strip()
    Debug(self.GetOwningQuest(), "Strip", "Prisoner Strip")
    ObjectReference prisonerItemsContainer = arrestVars.PrisonerItemsContainer

    ; Bounty modifier for stripping thoroughness
    int strippingThoroughnessModifier = int_if (arrestVars.StrippingThoroughnessModifier > 0, Round(Bounty / arrestVars.StrippingThoroughnessModifier))

    ; Total stripping thoroughness after modifier is applied if there's any
    float strippingThoroughness = arrestVars.StrippingThoroughness + strippingThoroughnessModifier
    "Stripping::Stripping Thoroughness"
    debug.notification("Stripping Thoroughness: " + strippingThoroughness + ", modifier: " + strippingThoroughnessModifier)
    Debug(none, "Prisoner::Strip", "Stripping Thoroughness: " + strippingThoroughness + ", modifier: " + strippingThoroughnessModifier)
    bool isStrippedNaked = strippingThoroughness >= 6
    bodySearcher.StripActor(this, strippingThoroughness, prisonerItemsContainer)
    
    self.IncrementStat("Times Stripped")
    arrestVars.SetBool("Jail::Stripped", true)
    
    ; Fire Events
    self.OnUndressed(isStrippedNaked)
    self.OnStripSearched(prisonerItemsContainer)
endFunction

function RemoveUnderwear()
    bodySearcher.RemoveUnderwearFromActor(this, arrestVars.PrisonerItemsContainer)
endFunction

function Clothe()
    RealisticPrisonAndBounty_Outfit outfitToUse = prisonerDresser.GetOutfit(arrestVars.OutfitName)

    if (!outfitToUse.IsWearable(arrestVars.Bounty))
        ; Fallback to default outfit
        outfitToUse = prisonerDresser.GetDefaultOutfit(false)
        Debug(this, "Prisoner::Clothe", "Outfit condition not met, reverting to default outfit!")
    endif

    prisonerDresser.WearOutfit(this, outfitToUse, undressActor = false)

    OnClothed(outfitToUse)
endFunction

function GiveItemsBack()
    ObjectReference prisonerItemsContainer = arrestVars.PrisonerItemsContainer
    bool redressOnRelease = arrestVars.RedressOnRelease

    prisonerItemsContainer.RemoveAllItems(this, abRemoveQuestItems = true)
    if (redressOnRelease)
        int itemsArray = arrestVars.GetObject("Jail::Prisoner Equipped Items")
        int i = 0
        while (i < JArray.count(itemsArray))
            Form currentItem = JArray.getForm(itemsArray, i)
            this.EquipItem(currentItem)
            i += 1
        endWhile
    endif

endFunction

function Restrain(bool inFront = false)
    ; Hand Cuffs Backside Rusty - 0xA081D2F
    ; Hand Cuffs Front Rusty - 0xA081D33
    ; Hand Cuffs Front Shiny - 0xA081D34
    ; Hand Cuffs Crossed Front 01 - 0xA033D9D
    ; Hands Crossed Front in Scarfs - 0xA073A14
    ; Hands in Irons Front Black - 0xA033D9E
    Form cuffs = Game.GetFormEx(0xA081D2F)
    if (inFront)
        cuffs = Game.GetFormEx(0xA081D33)
    endif

    this.SheatheWeapon()
    this.EquipItem(cuffs, true, true)
endFunction

function MoveToReleaseLocation()
    this.MoveTo(arrestVars.GetForm("Jail::Teleport Release Location") as ObjectReference)
endFunction

function MarkAsJailed()
    if (this == config.Player)
        arrestVars.SetBool("Jail::Jailed", true)

        ; Increment the "Times Jailed" stat for this Hold
        self.IncrementStat("Times Jailed")

        ; Increment the "Times Jailed" in the regular vanilla stat menu.
        Game.IncrementStat("Times Jailed")
    endif
endFunction

function CloseCellDoor(bool locked = true)
    CellDoor.SetOpen(false)
    if (locked)
        CellDoor.SetLockLevel(jail.GetCellDoorLockLevel())
        CellDoor.Lock()
    endif
endFunction

function OpenCellDoor()
    CellDoor.SetOpen(true)
endFunction

function SetEscaped(bool escaped = true)
    if (this == config.Player)
        arrestVars.SetBool("Arrest::Arrested",  bool_if(escaped, false, true))
        arrestVars.SetBool("Jail::Jailed",      bool_if(escaped, false, true))
        arrestVars.SetBool("Jail::Escaped",     bool_if(escaped, true, false))

        if (escaped)
            ; Increment the "Times Escaped" stat for this Hold
            self.IncrementStat("Times Escaped")

            ; Increment the "Jail Escapes" in the regular vanilla stat menu.
            Game.IncrementStat("Jail Escapes")

            this.SetAttackActorOnSight()
        endif
    endif
endFunction

; Get the bounty from storage and add it into active bounty for this faction.
function RevertBounty()
    ArrestFaction.SetCrimeGold(BountyNonViolent)
    ArrestFaction.SetCrimeGoldViolent(BountyViolent)
endFunction

function AddEscapeBounty()
    ; ==========================================================
    ;                           PLAYER
    ; ==========================================================
    int escapeBountyGotten = floor(Bounty * arrestVars.EscapeBountyFromCurrentArrest) + arrestVars.EscapeBounty

    ; Account for Infamy arrests where Bounty is less than the sentence gotten from infamy alone

    if (Bounty < InfamyBountyPenalty)
        ; This is an infamy arrest, bounty decreased should be different to avoid decreasing more than the actual bounty
        if (arrestVars.AccountForTimeServed && TimeServed >= 1)
            ArrestFaction.SetCrimeGold(escapeBountyGotten)
            config.NotifyJail("Due to time served in jail, your bounty was decreased by " + Max(0, (Bounty - escapeBountyGotten)), (Bounty - escapeBountyGotten) > 0)
            config.NotifyJail("You have gained " + escapeBountyGotten + " Bounty in " + Hold + " for escaping") ; Hold must be dynamic to each prisoner later

            ; Should we clear it from storage vars?
            arrestVars.SetInt("Arrest::Bounty Non-Violent", 0)
            arrestVars.SetInt("Arrest::Bounty Violent", 0)

            arrestVars.SetInt("Escape::Bounty Non-Violent", ArrestFaction.GetCrimeGoldNonViolent())
            arrestVars.SetInt("Escape::Bounty Violent", ArrestFaction.GetCrimeGoldViolent())
            return
        endif
    endif

    if (arrestVars.AccountForTimeServed && TimeServed >= 1)
        int bountyDecreased = floor(TimeServed * arrestVars.BountyToSentence)
        escapeBountyGotten -= bountyDecreased ; 2 * 100 = 200 Bounty (2 days served decreases 200 Bounty)
        config.NotifyJail("Due to time served in jail, your bounty was decreased by " + bountyDecreased)
    endif

    ArrestFaction.ModCrimeGold(escapeBountyGotten)
    config.NotifyJail("You have gained " + escapeBountyGotten + " Bounty in " + Hold + " for escaping", escapeBountyGotten > 0) ; Hold must be dynamic to each prisoner later
    
    ; Should we clear it from storage vars?
    arrestVars.SetInt("Arrest::Bounty Non-Violent", 0)
    arrestVars.SetInt("Arrest::Bounty Violent", 0)

    arrestVars.SetInt("Escape::Bounty Non-Violent", ArrestFaction.GetCrimeGoldNonViolent())
    arrestVars.SetInt("Escape::Bounty Violent", ArrestFaction.GetCrimeGoldViolent())

    ; ==========================================================
    ;                         NPC (Later)
    ; ==========================================================

endFunction

function TriggerCrimimalPenalty()
    Debug(self.GetOwningQuest(), "TriggerCrimimalPenalty", "Triggered penalty?")
    bool hasBountyToTriggerPenalty = (Bounty >= arrestVars.InfamyBountyTrigger)

    if (hasBountyToTriggerPenalty && (IsInfamyRecognized || IsInfamyKnown))
        Debug(none, "TriggerCriminalPenalty", "Infamy Extra Sentence: " + InfamyBountyPenalty / arrestVars.BountyToSentence)
        arrestVars.ModInt("Jail::Sentence", InfamyBountyPenalty / arrestVars.BountyToSentence)

        self.UpdateLongestSentence()
        config.NotifyJail(string_if (IsInfamyKnown, jail.InfamyKnownSentenceAppliedNotification, jail.InfamyRecognizedSentenceAppliedNotification))
    endif
endFunction

function SetTimeOfImprisonment()
    int id = this.GetFormID()
    if (id == config.Player.GetFormID())
        arrestVars.SetFloat("Jail::Time of Imprisonment", CurrentTime)
    else
        arrestVars.SetFloat("["+ id +"]Jail::Time of Imprisonment", CurrentTime)
    endif
endFunction

; Should be called everytime the actor gets to jail (initial jailing and on escape fail)
function UpdateSentence()
    ; Temporary, to be refactored into something more elegant and dynamic
    ; if (arrestVars.GetBool("Jail::Escaped"))
    ;     config.NotifyJail("Due to a failed escape attempt, your Bounty was restored to its original state")

    ;     int escapeBountyNonViolent = arrestVars.GetInt("Escape::Bounty Non-Violent")
    ;     int escapeBountyViolent = arrestVars.GetInt("Escape::Bounty Violent")

    ;     int bountyGainedSinceEscape = (escapeBountyNonViolent + escapeBountyViolent) - (Bounty - (escapeBountyNonViolent + escapeBountyViolent))
    ;     config.NotifyJail("Additionally, you have gained " + bountyGainedSinceEscape + " Bounty since then", bountyGainedSinceEscape > 0)

    ;     Debug(none, "UpdateSentence", "bountyGainedSinceEscape: " + bountyGainedSinceEscape)
    ; endif

    if (this == config.Player)
        int _bountyNonViolent    = ArrestFaction.GetCrimeGoldNonViolent()
        int _bountyViolent       = ArrestFaction.GetCrimeGoldViolent()
        int violentBountyConverted = floor(BountyViolent * (100 / arrestVars.BountyExchange))
    
        int oldSentence = Sentence
        
        if (_bountyNonViolent + _bountyViolent != 0)
            arrestVars.SetFloat("Arrest::Bounty Non-Violent", _bountyNonViolent)
            arrestVars.SetFloat("Arrest::Bounty Violent", _bountyViolent)
        endif

        ; arrestVars.SetFloat("Jail::Sentence", (_bountyNonViolent + violentBountyConverted) / arrestVars.BountyToSentence)
        arrestVars.SetFloat("Jail::Sentence", (BountyNonViolent + violentBountyConverted) / arrestVars.BountyToSentence) ; round() maybe?
    
        int newSentence = Sentence
        ClearBounty(ArrestFaction)
        
        self.UpdateLongestSentence()

        if (newSentence != oldSentence)
            OnSentenceChanged(oldSentence, newSentence, (newSentence > oldSentence), true)
        endif
    endif
endFunction

function UpdateSentenceFromCurrentBounty()
    if (this == config.Player)
        int _bountyNonViolent    = ArrestFaction.GetCrimeGoldNonViolent()
        int _bountyViolent       = ArrestFaction.GetCrimeGoldViolent()
        int violentBountyConverted = floor(BountyViolent * (100 / arrestVars.BountyExchange))
    
        int oldSentence = Sentence
        
        int bountyNonViolentGainedInJail    = arrestVars.GetInt("Jail::Bounty Non-Violent")
        int bountyViolentGainedInJail       = arrestVars.GetInt("Jail::Bounty Violent")

        arrestVars.SetFloat("Arrest::Bounty Non-Violent", BountyNonViolent + _bountyNonViolent + bountyNonViolentGainedInJail)
        arrestVars.SetFloat("Arrest::Bounty Violent", BountyViolent + _bountyViolent + bountyViolentGainedInJail)
        arrestVars.SetFloat("Jail::Sentence", (BountyNonViolent + violentBountyConverted) / arrestVars.BountyToSentence)
    
        int newSentence = Sentence
        
        self.UpdateCurrentBounty()
        self.UpdateLargestBounty()
        self.UpdateTotalBounty()
        self.UpdateLongestSentence()

        ; Clear bounty gained in jail
        arrestVars.Remove("Jail::Bounty Non-Violent")
        arrestVars.Remove("Jail::Bounty Violent")

        if (newSentence != oldSentence)
            OnSentenceChanged(oldSentence, newSentence, (newSentence > oldSentence), true)
        endif
    
        ClearBounty(ArrestFaction)
    endif
endFunction

function IncreaseSentence(int daysToIncreaseBy, bool shouldAffectBounty = true)
    int previousSentence = Sentence
    int newSentence = previousSentence + Max(0, daysToIncreaseBy) as int
    arrestVars.SetFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", BountyNonViolent + (daysToIncreaseBy * arrestVars.BountyToSentence))
    endif

    OnSentenceChanged(previousSentence, newSentence, daysToIncreaseBy > 0, shouldAffectBounty)
endFunction

function DecreaseSentence(int daysToDecreaseBy, bool shouldAffectBounty = true)
    int previousSentence = Sentence
    int newSentence = previousSentence + Max(0, daysToDecreaseBy) as int
    arrestVars.SetFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", BountyNonViolent - (daysToDecreaseBy * arrestVars.BountyToSentence))
    endif

    ; daysToDecreaseBy > 0 is possibly a bug, since they should always be more than 0, and that doesn't imply that the sentence was increased as per the param name
    OnSentenceChanged(previousSentence, newSentence, daysToDecreaseBy > 0, shouldAffectBounty)
endFunction

; ==========================================================
;                       Stats Updates
; ==========================================================
function UpdateInfamy()
    string city = config.GetCityNameFromHold(arrestVars.Hold)

    ; Update infamy
    self.IncrementStat("Infamy Gained", InfamyGainedPerUpdate)
    config.NotifyInfamy(InfamyGainedPerUpdate + " Infamy gained in " + city, config.IS_DEBUG)

    ; Notify once when Recognized/Known Threshold is met
    if (IsInfamyKnown)
        jail.NotifyInfamyKnownThresholdMet(Hold, jail.HasInfamyKnownNotificationFired)

    elseif (IsInfamyRecognized)
        jail.NotifyInfamyRecognizedThresholdMet(Hold, jail.HasInfamyRecognizedNotificationFired)
    endif
endFunction

function UpdateDaysJailed()
    ; Add the time served from each update this runs
    accumulatedTimeServed += TimeSinceLastUpdate

    if (accumulatedTimeServed >= 1)
        ; A day or more has passed
        int fullDaysPassed = floor(accumulatedTimeServed) ; Get the full days
        Game.IncrementStat("Days Jailed", fullDaysPassed)
        self.IncrementStat("Days Jailed", fullDaysPassed)

        accumulatedTimeServed -= fullDaysPassed ; Remove the counted days from accumulated time served (Get the fractional part if there's any - i.e: hours)
        float accumulatedTimeRemaining = accumulatedTimeServed - fullDaysPassed
        Debug(none, "Prisoner::UpdateDaysJailed", "accumulatedTimeServed remaining: " + accumulatedTimeRemaining)
    endif

    Debug(none, "Prisoner::UpdateDaysJailed", "TimeServed: " + TimeServed + ", floor(TimeServed): " + floor(TimeServed))
    Debug(none, "Prisoner::UpdateDaysJailed", "Updating Days Jailed: " + floor(accumulatedTimeServed))
    Debug(none, "Prisoner::UpdateDaysJailed", "LastUpdate: " + LastUpdate)
    Debug(none, "Prisoner::UpdateDaysJailed", "TimeSinceLastUpdate: " + TimeSinceLastUpdate)
endFunction

function UpdateLongestSentence()
    int currentLongestSentence = self.QueryStat("Longest Sentence")
    actorVars.SetLongestSentence(ArrestFaction, this, int_if (currentLongestSentence < Sentence, Sentence, currentLongestSentence))
endFunction

function UpdateLargestBounty()
    int currentLargestBounty = self.QueryStat("Largest Bounty")
    self.SetStat("Largest Bounty", int_if (currentLargestBounty < Bounty, Bounty, currentLargestBounty))
endFunction

function UpdateCurrentBounty()
    int currentBounty = self.QueryStat("Current Bounty")
    self.SetStat("Current Bounty", int_if (currentBounty < Bounty, Bounty, currentBounty))
endFunction

function UpdateTotalBounty()
    int currentTotalBounty = self.QueryStat("Total Bounty")
    self.SetStat("Total Bounty", int_if (currentTotalBounty < Bounty, Bounty, currentTotalBounty))
endFunction

; ==========================================================

function ShowJailInfo()
    Debug(self.GetOwningQuest(), "ShowJailInfo", "\n" + arrestVars.Hold + " Arrest Vars: { \n\t" + \
        "Hold: " + arrestVars.Hold + ", \n\t" + \
        "Bounty Non-Violent: " + arrestVars.BountyNonViolent + ", \n\t" + \
        "Bounty Violent: " + arrestVars.BountyViolent + ", \n\t" + \
        "Arrested: " + arrestVars.IsArrested + ", \n\t" + \
        "Jailed: " + arrestVars.IsJailed + ", \n\t" + \
        "Jail Cell: " + arrestVars.JailCell + ", \n\t" + \
        "Minimum Sentence: " + arrestVars.MinimumSentence + " Days, \n\t" + \
        "Maximum Sentence: " + arrestVars.MaximumSentence + " Days, \n\t" + \
        "Sentence: " + arrestVars.Sentence + " Days, \n\t" + \
        "Time of Arrest: " + arrestVars.TimeOfArrest + ", \n\t" + \
        "Time of Imprisonment: " + arrestVars.TimeOfImprisonment + ", \n\t" + \
        "Release Time: " + ReleaseTime + "\n" + \
    " }")
endFunction

function ShowSentenceInfo()
    int timeServedDays      = GetTimeServed("Days")
    int timeServedHours     = GetTimeServed("Hours of Day")
    int timeServedMinutes   = GetTimeServed("Minutes of Hour")
    int timeServedSeconds   = GetTimeServed("Seconds of Minute")

    int timeLeftToServeDays      = GetTimeLeftInSentence("Days")
    int timeLeftToServeHours     = GetTimeLeftInSentence("Hours of Day")
    int timeLeftToServeMinutes   = GetTimeLeftInSentence("Minutes of Hour")
    int timeLeftToServeSeconds   = GetTimeLeftInSentence("Seconds of Minute")

    Info(self.GetOwningQuest(), "ShowSentenceInfo", "\n" + arrestVars.Hold + " Sentence: { \n\t" + \
        "Minimum Sentence: "    + arrestVars.MinimumSentence + " Days, \n\t" + \
        "Maximum Sentence: "    + arrestVars.MaximumSentence + " Days, \n\t" + \
        "Sentence: "            + Sentence + " Days, \n\t" + \
        "Time of Arrest: "      + TimeOfArrest + ", \n\t" + \
        "Time of Imprisonment: "+ TimeOfImprisonment + ", \n\t" + \
        "Time Served: "         + TimeServed + " ("+ (TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"], \n\t" + \
        "Time Left: "           + TimeLeftInSentence + " ("+ (TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"], \n\t" + \
        "Release Time: "        + ReleaseTime + "\n" + \
    " }")
endFunction

function ShowHoldStats()
    Info(self.GetOwningQuest(), "ShowHoldStats", "\n" + Hold + " Stats: { \n\t" + \
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

function ShowOutfitInfo()
    Info(self.GetOwningQuest(), "ShowOutfitInfo", "\n" + config.GetCityNameFromHold(arrestVars.Hold) + " Outfit: { \n\t" + \
        "Name: "            + arrestVars.OutfitName + ", \n\t" + \
        "Head: "            + arrestVars.OutfitHead + " ("+ arrestVars.OutfitHead.GetName() +")" + ", \n\t" + \
        "Body: "            + arrestVars.OutfitBody + " ("+ arrestVars.OutfitBody.GetName() +")" + ", \n\t" + \
        "Hands: "           + arrestVars.OutfitHands + " ("+ arrestVars.OutfitHands.GetName() +")" + ", \n\t" + \
        "Feet: "            + arrestVars.OutfitFeet + " ("+ arrestVars.OutfitFeet.GetName() +")" + ", \n\t" + \
        "Conditional: "     + arrestVars.IsOutfitConditional + ", \n\t" + \
        "Minimum Bounty: "  + arrestVars.OutfitMinBounty + ", \n\t" + \
        "Maximum Bounty: "  + arrestVars.OutfitMaxBounty + ", \n" + \
    " }")
endFunction

function ShowActorVars()
    Debug(self.GetOwningQuest(), "ShowActorVars", "\n" + \
        GetContainerList(actorVars.GetContainer()) \
    )
endFunction

function MoveToCell()
    this.MoveTo(JailCell)
    self.CloseCellDoor()
endFunction

event OnSearched(ObjectReference prisonerHeldItemsContainer)
    ; Determine how many stolen items were found upon being searched
    ; add bounty accordingly from Additional Charges
    int bountyForStolenItems    = arrestVars.GetInt("Additional Charges::Bounty for Stolen Items")
    float bountyPerStolenItem   = GetPercentAsDecimal(arrestVars.GetFloat("Additional Charges::Bounty for Stolen Item"))

    Debug(self.GetOwningQuest(), "Prisoner::OnSearched", "BountyForStolenItems: " + bountyForStolenItems + ", Bounty per Stolen Item: " + bountyPerStolenItem)

    if ((bountyForStolenItems + bountyPerStolenItem) <= 0)
        return
    endif

    int totalBountyAdded = 0
    int stolenItems = 0
    int i = 0
    while (i < prisonerHeldItemsContainer.GetNumItems())
        Form currentItem = prisonerHeldItemsContainer.GetNthForm(i)

        ; if (IsStolenItem(currentItem))
            stolenItems += 1
            Debug(self.GetOwningQuest(), "Prisoner::OnSearched", "Found stolen item: " + currentItem)
            ; int bountyAdded = floor(bountyPerStolenItem * stolenItems) + bountyForStolenItems
            int bountyAdded = floor(currentItem.GetGoldValue() * bountyPerStolenItem)
            arrestVars.ModInt("Arrest::Bounty Non-Violent", bountyAdded)
            totalBountyAdded += bountyAdded
        ; endif

        i += 1
    endWhile

    if (stolenItems > 0)
        totalBountyAdded += bountyForStolenItems
        arrestVars.ModInt("Arrest::Bounty Non-Violent", bountyForStolenItems)
        config.NotifyJail("You have been charged with item theft and received an additional " + totalBountyAdded + " Bounty")
        Debug(self.GetOwningQuest(), "Prisoner::OnSearched", "Added bounty for stolen items: " + totalBountyAdded)
    endif
endEvent

event OnFriskSearched(ObjectReference prisonerHeldItemsContainer)
    ; self.OnSearched(prisonerHeldItemsContainer)
endEvent

event OnStripSearched(ObjectReference prisonerHeldItemsContainer)
    ; self.OnSearched(prisonerHeldItemsContainer)
endEvent

event OnUndressed(bool isNaked)
    jail.OnUndressed(this)
endEvent

event OnClothed(RealisticPrisonAndBounty_Outfit prisonerOutfit)
    jail.OnClothed(this, prisonerOutfit)
endEvent

event OnSentenceChanged(int oldSentence, int newSentence, bool hasSentenceIncreased, bool bountyAffected)
    jail.OnSentenceChanged(this, oldSentence, newSentence, hasSentenceIncreased, bountyAffected)
endEvent

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    jail.OnPrisonerLocationChanged(self, akOldLocation, akNewLocation)
endEvent

; event OnLocationChange(Location akOldLocation, Location akNewLocation)
;     if (self.HasEscaped() && !alreadyLeftPrisonLocationOnce && !this.IsInCombat())
;         if (akNewLocation != arrestVars.GetForm("Jail::Prison Location") as Location)
;             ; if we are not in the Prison location anymore (to be tested)
;             JailFaction.SetCrimeGold(1000)
;             config.NotifyJail("You have escaped from the prison location undetected, Bounty set to 1000")
;             arrestVars.Remove("Arrest::Arrested") ; temporary for OnUpdate to succeed
;             alreadyLeftPrisonLocationOnce = true
;         endif

;         Debug(none, "OnLocationChange", "Prison Location: " + arrestVars.GetForm("Jail::Prison Location") as Location)
;     endif
; endEvent

event OnItemRemoved(Form baseItem, int itemCount, ObjectReference itemReference, ObjectReference destContainer)
    ; Process all stolen items that were taken away from the prisoner
    Faction factionOwner = itemReference.GetFactionOwner()
    ActorBase actorOwner = itemReference.GetActorOwner()

    Debug(none, "Prisoner::OnItemRemoved", ", " + \
        "Base Item: " + baseItem + ", " + \
        "Item Reference: " + itemReference + ", " + \
        "Faction Owner: " + factionOwner + ", " + \
        "Actor Owner: " + actorOwner + ", " + \
        "Item Count: " + itemCount + ", " + \
        "Destination Container: " + destContainer \
    )
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    if (akBaseObject as Armor) ; Only store equipped Clothing/Armor
        int prisonerEquippedItemsContainer = arrestVars.GetObject("Jail::Prisoner Equipped Items")
        JArray.addForm(prisonerEquippedItemsContainer, akBaseObject)
        int wasItemAdded = JArray.findForm(prisonerEquippedItemsContainer, akBaseObject)
    endif
endEvent

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

; function __updateSentenceFromCurrentBountyForNPC()
;     int _bountyNonViolent   = actorVars.GetCrimeGoldNonViolent(ArrestFaction, this)
;     int _bountyViolent      = actorVars.GetCrimeGoldViolent(ArrestFaction, this)

;     int arrestBountyViolent = arrestVars.GetInt("["+ this.GetFormID() +"]Arrest::Bounty Violent")
;     int violentBountyConverted = floor(arrestBountyViolent * (100 / arrestVars.BountyExchange))

;     arrestVars.SetFloat("["+ this.GetFormID() +"]Arrest::Bounty Non-Violent", arrestVars.BountyNonViolent + _bountyNonViolent)
;     arrestVars.SetFloat("["+ this.GetFormID() +"]Arrest::Bounty Violent", arrestVars.BountyViolent + _bountyViolent)
;     arrestVars.SetFloat("["+ this.GetFormID() +"]Jail::Sentence", (arrestVars.BountyNonViolent + violentBountyConverted) / arrestVars.BountyToSentence)
; endFunction