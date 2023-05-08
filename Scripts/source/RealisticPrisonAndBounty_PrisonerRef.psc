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

bool function IsNaked()
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
    bodySearcher.StripActor(this, strippingThoroughness, prisonerItemsContainer)
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

    Debug(this, "Prisoner::Clothe", "\n" + \
        "Head: " + outfitToUse.Head + "\n" + \
        "Body: " + outfitToUse.Body + "\n" + \
        "Hands: " + outfitToUse.Hands + "\n" + \
        "Feet: " + outfitToUse.Feet + "\n" + \
        "arrestVars.Bounty: " + arrestVars.Bounty + "\n" + \
        "outfitToUse.IsWearable(arrestVars.Bounty): " + outfitToUse.IsWearable(arrestVars.Bounty) + "\n" + \
        "self.GetOwningQuest().GetName(): " + self.GetOwningQuest().GetID() + "\n" \
    )

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
    arrestVars.ArrestFaction.ModCrimeGold(floor((arrestVars.BountyNonViolent * percent(arrestVars.EscapeBountyFromCurrentArrest))) + arrestVars.EscapeBounty)
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
        __updateSentenceForPlayer()
    ; else
    ;     __updateSentenceForNPC()
    endif
endFunction

function UpdateSentenceFromCurrentBounty()
    if (this == config.Player)
        __updateSentenceFromCurrentBountyForPlayer()
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
    int infamyGainedPerUpdate = ceiling(InfamyGainedDaily * jail.TimeSinceLastUpdate)

    ; Update infamy
    config.IncrementStat(arrestVars.Hold, "Infamy Gained", infamyGainedPerUpdate)
    config.NotifyInfamy(infamyGainedPerUpdate + " Infamy gained in " + city, config.IS_DEBUG)

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
        "Release Time: " + jail.ReleaseTime + "\n" + \
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
        "Time Served: " + jail.TimeServed + " ("+ (jail.TimeServed * 24) + " Hours" +") ["+ timeServedDays + " Days, " + timeServedHours + " Hours, " +  timeServedMinutes + " Minutes, " + timeServedSeconds + " Seconds" +"], \n\t" + \
        "Time Left: " + jail.TimeLeftInSentence + " ("+ (jail.TimeLeftInSentence * 24) + " Hours" +") ["+ timeLeftToServeDays + " Days, " + timeLeftToServeHours + " Hours, " +  timeLeftToServeMinutes + " Minutes, " + timeLeftToServeSeconds + " Seconds" +"], \n\t" + \
        "Release Time: " + jail.ReleaseTime + "\n" + \
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

event OnSentenceChanged(int oldSentence, int newSentence, bool hasSentenceIncreased, bool bountyAffected)
    jail.OnSentenceChanged(this, oldSentence, newSentence, hasSentenceIncreased, bountyAffected)
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    JArray.addForm(arrestVars.GetObject("Jail::Prisoner Equipped Items"), akBaseObject)
    int wasItemAdded = JArray.findForm(arrestVars.GetObject("Jail::Prisoner Equipped Items"), akBaseObject)
    Debug(self.GetOwningQuest(), "PrisonerRef::OnObjectUnequipped", "\n" + \
        "Unequipped: " + akBaseObject + \
        "Was it added: " + wasItemAdded \
    )
endEvent

int function GetTimeServed(string timeUnit)
    int _timeServedDays = floor(jail.TimeServed)

    if (timeUnit == "Days")
        return _timeServedDays
    endif

    float timeLeftOverOfDay     = (jail.TimeServed - _timeServedDays) * 24 ; Hours and Minutes
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
    int _timeLeftDays = floor(jail.TimeLeftInSentence)

    if (timeUnit == "Days")
        return _timeLeftDays
    endif

    float _timeLeftOverOfDay    = (jail.TimeLeftInSentence - _timeLeftDays) * 24 ; Hours and Minutes
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

function __updateSentenceForPlayer()
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
endFunction

function __updateSentenceFromCurrentBountyForPlayer()
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