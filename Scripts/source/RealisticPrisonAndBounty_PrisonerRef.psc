scriptname RealisticPrisonAndBounty_PrisonerRef extends ReferenceAlias

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

Actor property this
    Actor function get()
        return self.GetActorReference()
    endFunction
endProperty

RealisticPrisonAndBounty_Config property config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property arrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return config.arrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_ActorVars property actorVars
    RealisticPrisonAndBounty_ActorVars function get()
        return config.actorVars
    endFunction
endProperty

RealisticPrisonAndBounty_BodySearcher property bodySearcher
    RealisticPrisonAndBounty_BodySearcher function get()
        return config.mainAPI as RealisticPrisonAndBounty_BodySearcher
    endFunction
endProperty

RealisticPrisonAndBounty_Clothing property prisonerDresser
    RealisticPrisonAndBounty_Clothing function get()
        return config.mainAPI as RealisticPrisonAndBounty_Clothing
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property jail
    RealisticPrisonAndBounty_Jail function get()
        return config.mainAPI as RealisticPrisonAndBounty_Jail
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

float property ReleaseTime
    float function get()
        float gameHour = 0.04166666666666666666666666666667
        return TimeOfImprisonment + (gameHour * 24 * arrestVars.Sentence)
    endFunction
endProperty

float property TimeLeftInSentence
    float function get()
        return (ReleaseTime - TimeOfImprisonment) - TimeServed
    endFunction
endProperty

bool property SentenceServed
    bool function get()
        return CurrentTime >= ReleaseTime
    endFunction
endProperty

int property InfamyGainedDaily
    ;/
        infamyGainedFlat: 40
        infamyGainedFromCurrentBounty: 1.44%
        Bounty: 3000
        <=> floor(3000 * (1.44/100) + 40)
        <=> floor(3000 * 0.0144) + 40
        <=> floor(43.2) + 40
        <=> 43 + 40 = 83
    /;
    int function get()
        int infamyGainedFlat                    = arrestVars.GetFloat("Jail::Infamy Gained Daily") as int
        float infamyGainedFromCurrentBounty     = arrestVars.GetFloat("Jail::Infamy Gained Daily from Current Bounty")
        return floor(arrestVars.Bounty * percent(infamyGainedFromCurrentBounty)) + infamyGainedFlat
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
        return ceiling(InfamyGainedDaily * TimeSinceLastUpdate)
    endFunction
endProperty

bool property Stripped
    bool function get()
        return arrestVars.IsStripped
    endFunction
endProperty

int property Sentence
    int function get()
        arrestVars.SetIntMin("Jail::Sentence", arrestVars.MinimumSentence)
        arrestVars.SetIntMax("Jail::Sentence", arrestVars.MaximumSentence)

        return arrestVars.GetInt("Jail::Sentence")
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

function SetupPrisonerVars()
    ; Dynamic Vars
    arrestVars.SetFloat("Jail::Sentence", (BountyNonViolent + (floor(BountyViolent * (100 / arrestVars.BountyExchange)))) / arrestVars.BountyToSentence)
    arrestVars.SetFloat("Jail::Time of Imprisonment", arrestVars.CurrentTime)
    arrestVars.SetForm("Jail::Cell Door", GetNearestJailDoorOfType(GetJailBaseDoorID(arrestVars.Hold), this, 10000))
    arrestVars.SetInt("Jail::Cell Door Old Lock Level", arrestVars.CellDoor.GetLockLevel())
    arrestVars.SetForm("Jail::Teleport Release Location", config.GetJailTeleportReleaseMarker(arrestVars.Hold))
    arrestVars.SetForm("Jail::Prisoner Items Container", config.GetJailPrisonerItemsContainer(arrestVars.Hold))
    arrestVars.SetBool("Jail::Jailed", true)

    ; ; inventation time (Later this container must be dynamic for each actor in prison)
    arrestVars.SetObject("Jail::Prisoner Equipped Items", JArray.object())
endFunction

function RegisterLastUpdate()
    LastUpdate = Utility.GetCurrentGameTime()
endFunction

; Determines whether this prisoner should be stripped or not
bool function ShouldBeStripped()
    if (Stripped || !arrestVars.IsStrippingEnabled)
        return false
    endif

    if (self.IsEscapee() && arrestVars.ShouldStripOnEscape)
        return true
    endif

    bool meetsBountyRequirements    = (BountyNonViolent >= arrestVars.StrippingMinBounty) || (BountyViolent >= arrestVars.StrippingMinViolentBounty)
    bool meetsSentenceRequirements  = Sentence >= arrestVars.StrippingMinSentence
    return arrestVars.IsStrippingUnconditional || (arrestVars.StrippingHandling == "Minimum Bounty" && meetsBountyRequirements) || (arrestVars.StrippingHandling == "Minimum Sentence" && meetsSentenceRequirements)
endFunction

; Determines whether this prisoner should be clothed upon being stripped
bool function ShouldBeClothed()
    if (!arrestVars.IsClothingEnabled)
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
    return arrestVars.ArrestFaction.GetCrimeGold() > 0
endFunction

function Frisk()
    ObjectReference prisonerItemsContainer = arrestVars.PrisonerItemsContainer
    
    float friskingThoroughness = arrestVars.GetFloat("Frisking::Frisking Thoroughness")
    bodySearcher.FriskActor(this, friskingThoroughness, prisonerItemsContainer)
endFunction

function Strip()
    Debug(self.GetOwningQuest(), "Strip", "Prisoner Strip")

    ObjectReference prisonerItemsContainer = arrestVars.PrisonerItemsContainer

    float strippingThoroughness = arrestVars.GetFloat("Stripping::Stripping Thoroughness")
    bool isStrippedNaked = strippingThoroughness >= 6
    config.IncrementStat(arrestVars.Hold, "Times Stripped")
    actorVars.ModTimesStripped(arrestVars.ArrestFaction, this, 1)
    bodySearcher.StripActor(this, strippingThoroughness, prisonerItemsContainer)
    arrestVars.SetBool("Jail::Stripped", true)
    OnUndressed(isStrippedNaked)
endFunction

function Clothe()
    RealisticPrisonAndBounty_Outfit outfitToUse = prisonerDresser.GetOutfit(arrestVars.OutfitName)

    if (!outfitToUse.IsWearable(arrestVars.Bounty))
        ; Fallback to default outfit
        outfitToUse = prisonerDresser.GetDefaultOutfit(false)
        Debug(this, "Prisoner::Clothe", "Outfit condition not met, reverting to default outfit!")
    endif

    prisonerDresser.WearOutfit(this, outfitToUse)

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

function MoveToReleaseLocation()
    this.MoveTo(arrestVars.GetForm("Jail::Teleport Release Location") as ObjectReference)
endFunction

; Get the bounty from storage and add it into active bounty for this faction.
function RevertBounty()
    arrestVars.ArrestFaction.SetCrimeGold(arrestVars.BountyNonViolent)
    arrestVars.ArrestFaction.SetCrimeGoldViolent(arrestVars.BountyViolent)

    ; Should we clear it from storage vars?
    ; config.SetArrestVarInt("Arrest::Bounty Non-Violent", 0)
    ; config.SetArrestVarInt("Arrest::Bounty Violent", 0)
endFunction

function AddEscapeBounty()
    ; Player
    int escapeBountyGotten = floor((arrestVars.BountyNonViolent * percent(arrestVars.EscapeBountyFromCurrentArrest))) + arrestVars.EscapeBounty
    arrestVars.ArrestFaction.ModCrimeGold(escapeBountyGotten)
    config.NotifyJail("You have gained " + escapeBountyGotten + " Bounty in " + arrestVars.Hold + " for escaping") ; Hold must be dynamic to each prisoner later

    ; NPC (Later)
endFunction

function TriggerCrimimalPenalty()
    if (arrestVars.InfamyEnabled)
        Debug(self.GetOwningQuest(), "TriggerCrimimalPenalty", "Triggered penalty?")
        bool hasBountyToTriggerPenalty = (arrestVars.Bounty >= arrestVars.GetInt("Jail::Bounty to Trigger Infamy"))

        if (arrestVars.IsInfamyRecognized || arrestVars.IsInfamyKnown)
            int currentInfamy  = 2000;config.GetInfamyGained(arrestVars.Hold)
            float criminalPenalty  = float_if (arrestVars.IsInfamyKnown, arrestVars.GetFloat("Jail::Known Criminal Penalty"), arrestVars.GetFloat("Jail::Recognized Criminal Penalty"))
            int infamyPenalty = (currentInfamy * floor(percent(criminalPenalty)))
            Debug(self.GetOwningQuest(), "TriggerCrimimalPenalty", "infamyPenalty: " + infamyPenalty)

            arrestVars.SetInt("Jail::Sentence", arrestVars.Sentence + infamyPenalty)
            config.NotifyJail(string_if (arrestVars.IsInfamyKnown, "Due to being a known criminal in the hold, your sentence has been extended", "Due to being a recognized criminal in the hold, your sentence has been extended"))
        endif
    endif
endFunction

function SetTimeOfImprisonment()
    int id = this.GetFormID()
    if (id == config.Player.GetFormID())
        arrestVars.SetFloat("Jail::Time of Imprisonment", arrestVars.CurrentTime)
    else
        arrestVars.SetFloat("["+ id +"]Jail::Time of Imprisonment", arrestVars.CurrentTime)
    endif
endFunction

; Should be called everytime the actor gets to jail (initial jailing and on escape fail)
function UpdateSentence()
    if (this == config.Player)
        int _bountyNonViolent    = arrestVars.ArrestFaction.GetCrimeGoldNonViolent()
        int _bountyViolent       = arrestVars.ArrestFaction.GetCrimeGoldViolent()
        int violentBountyConverted = floor(arrestVars.BountyViolent * (100 / arrestVars.BountyExchange))
    
        int oldSentence = arrestVars.GetInt("Jail::Sentence")
    
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", _bountyNonViolent)
        arrestVars.SetFloat("Arrest::Bounty Violent", _bountyViolent)
        arrestVars.SetFloat("Jail::Sentence", (_bountyNonViolent + violentBountyConverted) / arrestVars.BountyToSentence)
    
        int newSentence = arrestVars.GetInt("Jail::Sentence")
        ClearBounty(arrestVars.ArrestFaction)
    
        if (newSentence != oldSentence)
            OnSentenceChanged(oldSentence, newSentence, (newSentence > oldSentence), true)
        endif
    ; else
    ;     __updateSentenceForNPC()
    endif
endFunction

function UpdateSentenceFromCurrentBounty()
    if (this == config.Player)
        int _bountyNonViolent    = arrestVars.ArrestFaction.GetCrimeGoldNonViolent()
        int _bountyViolent       = arrestVars.ArrestFaction.GetCrimeGoldViolent()
        int violentBountyConverted = floor(arrestVars.BountyViolent * (100 / arrestVars.BountyExchange))
    
        int oldSentence = arrestVars.GetInt("Jail::Sentence")
    
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", arrestVars.BountyNonViolent + _bountyNonViolent)
        arrestVars.SetFloat("Arrest::Bounty Violent", arrestVars.BountyViolent + _bountyViolent)
        arrestVars.SetFloat("Jail::Sentence", (arrestVars.BountyNonViolent + violentBountyConverted) / arrestVars.BountyToSentence)
    
        int newSentence = arrestVars.GetInt("Jail::Sentence")
    
        if (newSentence != oldSentence)
            OnSentenceChanged(oldSentence, newSentence, (newSentence > oldSentence), true)
        endif
    
        ClearBounty(arrestVars.ArrestFaction)
    endif
endFunction

function IncreaseSentence(int daysToIncreaseBy, bool shouldAffectBounty = true)
    int previousSentence = arrestVars.Sentence
    int newSentence = previousSentence + Max(0, daysToIncreaseBy) as int
    arrestVars.SetFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", arrestVars.BountyNonViolent + (daysToIncreaseBy * arrestVars.BountyToSentence))
    endif

    OnSentenceChanged(previousSentence, newSentence, daysToIncreaseBy > 0, shouldAffectBounty)
endFunction

function DecreaseSentence(int daysToDecreaseBy, bool shouldAffectBounty = true)
    int previousSentence = arrestVars.Sentence
    int newSentence = previousSentence + Max(0, daysToDecreaseBy) as int
    arrestVars.SetFloat("Jail::Sentence", newSentence)

    if (shouldAffectBounty)
        arrestVars.SetFloat("Arrest::Bounty Non-Violent", arrestVars.BountyNonViolent - (daysToDecreaseBy * arrestVars.BountyToSentence))
    endif

    OnSentenceChanged(previousSentence, newSentence, daysToDecreaseBy > 0, shouldAffectBounty)
endFunction

function UpdateInfamy()
    string city = config.GetCityNameFromHold(arrestVars.Hold)
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
    int _infamyGainedPerUpdate = ceiling(InfamyGainedDaily * TimeSinceLastUpdate)

    ; Update infamy
    ; config.IncrementStat(arrestVars.Hold, "Infamy Gained", _infamyGainedPerUpdate)
    actorVars.ModInfamy(arrestVars.ArrestFaction, this, _infamyGainedPerUpdate)
    config.NotifyInfamy(_infamyGainedPerUpdate + " Infamy gained in " + city, config.IS_DEBUG)

    ; Notify once when Recognized/Known Threshold is met
    if (arrestVars.IsInfamyKnown)
        config.NotifyInfamyKnownThresholdMet(arrestVars.Hold)

    elseif (arrestVars.IsInfamyRecognized)
        config.NotifyInfamyRecognizedThresholdMet(arrestVars.Hold)
    endif
endFunction

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

    Debug(self.GetOwningQuest(), "ShowSentenceInfo", "\n" + arrestVars.Hold + " Sentence: { \n\t" + \
        "Minimum Sentence: " + arrestVars.MinimumSentence + " Days, \n\t" + \
        "Maximum Sentence: " + arrestVars.MaximumSentence + " Days, \n\t" + \
        "Sentence: " + arrestVars.Sentence + " Days, \n\t" + \
        "Time of Arrest: " + arrestVars.TimeOfArrest+ ", \n\t" + \
        "Time of Imprisonment: " + arrestVars.TimeOfImprisonment + ", \n\t" + \
        "Time Served: " + TimeServed + " ("+ (TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"], \n\t" + \
        "Time Left: " + TimeLeftInSentence + " ("+ (TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"], \n\t" + \
        "Release Time: " + ReleaseTime + "\n" + \
    " }")
endFunction

function ShowHoldStats()
    int currentBounty = config.QueryStat(arrestVars.Hold, "Current Bounty")
    int largestBounty = config.QueryStat(arrestVars.Hold, "Largest Bounty")
    int totalBounty = config.QueryStat(arrestVars.Hold, "Total Bounty")
    int timesArrested = config.QueryStat(arrestVars.Hold, "Times Arrested")
    int timesFrisked = config.QueryStat(arrestVars.Hold, "Times Frisked")
    int feesOwed = config.QueryStat(arrestVars.Hold, "Fees Owed")
    int daysInJail = config.QueryStat(arrestVars.Hold, "Days in Jail")
    int longestSentence = config.QueryStat(arrestVars.Hold, "Longest Sentence")
    int timesJailed = config.QueryStat(arrestVars.Hold, "Times Jailed")
    int timesEscaped = config.QueryStat(arrestVars.Hold, "Times Escaped")
    int timesStripped = config.QueryStat(arrestVars.Hold, "Times Stripped")
    int infamyGained = config.QueryStat(arrestVars.Hold, "Infamy Gained")

    Debug(self.GetOwningQuest(), "ShowHoldStats", "\n" + arrestVars.Hold + " Stats: { \n\t" + \
        "Current Bounty: " + currentBounty + ", \n\t" + \
        "Largest Bounty: " + largestBounty + ", \n\t" + \
        "Total Bounty: " + totalBounty + ", \n\t" + \
        "Times Arrested: " + timesArrested + ", \n\t" + \
        "Times Frisked: " + timesFrisked + ", \n\t" + \
        "Fees Owed: " + feesOwed + ", \n\t" + \
        "Days in Jail: " + daysInJail + ", \n\t" + \
        "Longest Sentence: " + longestSentence + ", \n\t" + \
        "Times Jailed: " + timesJailed + ", \n\t" + \
        "Times Escaped: " + timesEscaped + ", \n\t" + \
        "Times Stripped: " + timesStripped + ", \n\t" + \
        "Infamy Gained: " + infamyGained + "\n" + \
    " }")
endFunction

function ShowOutfitInfo()
    Debug(self.GetOwningQuest(), "ShowOutfitInfo", "\n" + config.GetCityNameFromHold(arrestVars.Hold) + " Outfit: { \n\t" + \
        "Name: " + arrestVars.OutfitName + ", \n\t" + \
        "Head: " + arrestVars.OutfitHead + " ("+ arrestVars.OutfitHead.GetName() +")" + ", \n\t" + \
        "Body: " + arrestVars.OutfitBody + " ("+ arrestVars.OutfitBody.GetName() +")" + ", \n\t" + \
        "Hands: " + arrestVars.OutfitHands + " ("+ arrestVars.OutfitHands.GetName() +")" + ", \n\t" + \
        "Feet: " + arrestVars.OutfitFeet + " ("+ arrestVars.OutfitFeet.GetName() +")" + ", \n\t" + \
        "Conditional: " + arrestVars.IsOutfitConditional + ", \n\t" + \
        "Minimum Bounty: " + arrestVars.OutfitMinBounty + ", \n\t" + \
        "Maximum Bounty: " + arrestVars.OutfitMaxBounty + ", \n" + \
    " }")
endFunction

function ShowActorVars()
    Debug(self.GetOwningQuest(), "ShowActorVars", "\n" + \
        GetContainerList(actorVars.GetContainer()) \
    )
endFunction

function MoveToCell()
    ObjectReference prisonerJailCell  = arrestVars.GetReference("Jail::Cell")
    ObjectReference jailCellDoor      = arrestVars.GetReference("Jail::Cell Door") 

    this.MoveTo(prisonerJailCell)
    jailCellDoor.SetOpen(false)
    jailCellDoor.Lock()
endFunction

function FlagAsEscapee()
    arrestVars.SetBool("Jail::Escaped", true)
endFunction

bool function IsEscapee()
    return arrestVars.GetBool("Jail::Escaped")
endFunction

event OnUndressed(bool isNaked)
    jail.OnUndressed(this)
endEvent

event OnClothed(RealisticPrisonAndBounty_Outfit prisonerOutfit)
    jail.OnClothed(this, prisonerOutfit)
endEvent
; akSpeaker.SetPlayerResistingArrest()
event OnSentenceChanged(int oldSentence, int newSentence, bool hasSentenceIncreased, bool bountyAffected)
    jail.OnSentenceChanged(this, oldSentence, newSentence, hasSentenceIncreased, bountyAffected)
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