scriptname RPB_ActorBase extends ActiveMagicEffect
{Base Actor script for RPB_ActorBase, must be inherited from to be used}

import RPB_Utility

; ==========================================================
;                      Script References
; ==========================================================

RPB_API __api
RPB_API property API
    RPB_API function get()
        if (!__api)
            __api = RPB_API.GetSelf()
        endif

        return __api
    endFunction
endProperty

RPB_Config property Config
    RPB_Config function get()
        return API.Config
    endFunction
endProperty

; ==========================================================
;                       Actor Related
; ==========================================================

string property Name
    string function get()
        return self.GetName()
    endFunction
endProperty

string property Sex
    string function get()
        return self.GetSex()
    endFunction
endProperty

bool property IsFemale
    bool function get()
        return this.GetActorBase().GetSex() == 1
    endFunction
endProperty

bool property IsMale
    bool function get()
        return this.GetActorBase().GetSex() == 0
    endFunction
endProperty

string property Gender
    string function get()
        if (self.IsFemale)
            return "Female"

        elseif (self.IsMale)
            return "Male"
        endif
    endFunction
endProperty


; Returns 'she' for Females, 'he' for Males
string property Pronoun
    string function get()
        if (self.IsFemale)
            return "she"
        elseif (self.IsMale)
            return "he"
        else
            return "they" ; Let's hope we never get here
        endif
    endFunction
endProperty

; Returns 'her' for Females, 'him' for Males
string property PronounObject
    string function get()
        if (self.IsFemale)
            return "her"
        elseif (self.IsMale)
            return "him"
        else
            return "they" ; Let's hope we never get here
        endif
    endFunction
endProperty

; Returns 'hers' for Females, 'his' for Males
string property PronounPossessive
    string function get()
        if (self.IsFemale)
            return "hers"
        elseif (self.IsMale)
            return "his"
        else
            return "theirs" ; Let's hope we never get here
        endif
    endFunction
endProperty

; Returns 'her' for Females, 'his' for Males
string property PronounPossessiveObject
    string function get()
        if (self.IsFemale)
            return "her"
        elseif (self.IsMale)
            return "his"
        else
            return "their" ; Let's hope we never get here
        endif
    endFunction
endProperty

; Returns 'herself' for Females, 'himself' for Males
string property PronounReflexive
    string function get()
        if (self.IsFemale)
            return "herself"
        elseif (self.IsMale)
            return "himself"
        else
            return "themself" ; Let's hope we never get here
        endif
    endFunction
endProperty

; Returns 'herself' for Females, 'himself' for Males
string property PronounIntensive
    string function get()
        return self.PronounReflexive
    endFunction
endProperty


; ==========================================================

; ==========================================================
;                      Static Functions
; ==========================================================

int function GetCurrentActiveAndLatentBountyForFaction(Actor akActor, Faction akFaction, bool abNonViolent = true, bool abViolent = true) global
    int totalBounty = 0
    bool isPlayer = akActor.GetFormID() == 0x14

    if (abNonViolent)
        int activeNonViolentBounty = int_if (isPlayer, akFaction.GetCrimeGoldNonViolent(), RPB_ActorVars.GetCrimeGoldNonViolent(akFaction, akActor))
        int latentNonViolentBounty = RPB_ActorVars.GetLatentCrimeGoldNonViolent(akFaction, akActor)
        totalBounty += activeNonViolentBounty + latentNonViolentBounty
    endif

    if (abViolent)
        int activeViolentBounty = int_if (isPlayer, akFaction.GetCrimeGoldViolent(), RPB_ActorVars.GetCrimeGoldViolent(akFaction, akActor))
        int latentViolentBounty = RPB_ActorVars.GetLatentCrimeGoldViolent(akFaction, akActor)
        totalBounty += activeViolentBounty + latentViolentBounty
    endif

    return totalBounty
endFunction

; ==========================================================


;/
    Binds an Alias to this Actor.

    ReferenceAlias @apAlias: The alias to bind to the Actor.
/;
function BindAlias(ReferenceAlias apAlias)
    BindAliasTo(apAlias, this)
endFunction

;/
    Unbinds an Alias from this Actor.

    This function does not depend on this Actor, since
    all we're doing is setting the alias to none,
    this is just a helper function and assumes that this Alias
    is bound to this Actor.

    ReferenceAlias  @apAlias: The alias to unbind from the Actor.
/;
function UnbindAlias(ReferenceAlias apAlias)
    BindAliasTo(apAlias, none)
    Debug("["+ this +"] Actor::UnbindAlias", "Unbound " + apAlias + " Alias.")
endFunction

bool function HasAlias(ReferenceAlias apAlias)
    int i = 0
    while (i < this.GetNumReferenceAliases())
        if (this.GetNthReferenceAlias(i) == apAlias)
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

function EnableAI(bool abEnable = true)
    this.EnableAI(abEnable)
    ; if (abEnable)
    ;     Debug("Actor::EnableAI", "AI: " + abEnable)
    ; endif
endFunction

function DisableAI()
    this.EnableAI(false)
endFunction

bool function HasAI()
    return this.IsAIEnabled()
endFunction

function AddSpell(Spell akSpell, bool abVerbose = true)
    this.AddSpell(akSpell, abVerbose)
endFunction

function RemoveSpell(Spell akSpell)
    this.RemoveSpell(akSpell)
endFunction

bool function HasSpell(Spell akSpell)
    return this.HasSpell(akSpell)
endFunction

function EquipItem(Form akItem, bool abPreventRemoval = false, bool abSilent = true, bool abCondition = true)
    if (abCondition)
        this.EquipItem(akItem, abPreventRemoval, abSilent)
    endif
endFunction

;/
    Equips the specified Outfit through its Armor pieces.

    Armor[] @akOutfit: The outfit pieces of this Outfit.
    bool?   @abPreventRemoval: Whether to prevent this Outfit's removal by the Actor.
/;
function EquipOutfit(Armor[] akOutfit, bool abPreventRemoval = false)
    if (akOutfit.Length == 0)
        ; Error
        return none
    endif

    int i = 0
    while (i < akOutfit.Length)
        self.EquipItem(akOutfit[i], abPreventRemoval)
        i += 1
    endWhile
endFunction

function UnequipHands()
    UnequipWeaponForActor(this, false)
    UnequipWeaponForActor(this, false)
    UnequipWeaponForActor(this, true)
    UnequipSpellForActor(this)
    UnequipShieldForActor(this)
endFunction

function UnequipItemSlot(int aiSlot)
    this.UnequipItemSlot(aiSlot)
endFunction

function UnequipAll()
    this.UnequipAll()
endFunction

function RemoveItem(Form akItemToRemove, int aiCount = 1, bool abSilent = true, ObjectReference akOtherContainer = none)
    this.RemoveItem(akItemToRemove, aiCount, abSilent, akOtherContainer)
endFunction

function RemoveAllItems(ObjectReference akTransferTo = none, bool abKeepOwnership = false, bool abRemoveQuestItems = true)
    this.RemoveAllItems(akTransferTo, abKeepOwnership, abRemoveQuestItems)
endFunction

function SheatheWeapon()
    this.SheatheWeapon()
endFunction

function StopCombat(bool abStopCombatAlarm = true)
    this.StopCombat()

    if (abStopCombatAlarm)
        this.StopCombatAlarm()
    endif
endFunction

function SetAttackActorOnSight(bool abAttackOnSight = true)
    this.SetAttackActorOnSight(abAttackOnSight)
endFunction

function MoveTo(ObjectReference akTarget, float afXOffset = 0.0, float afYOffset = 0.0, float afZOffset = 0.0, bool abMatchRotation = true)
    this.MoveTo(akTarget, afXOffset, afYOffset, afZOffset, abMatchRotation)
    Debug("Actor::MoveTo", "Moved " + self.Name + " to " + akTarget)
endFunction

Cell function GetCurrentCell()
    return this.GetParentCell()
endFunction

function PlayAnimation(string asAnimationKey)
    Debug.SendAnimationEvent(this, asAnimationKey)
endFunction

float function GetDistance(ObjectReference akObject)
    return this.GetDistance(akObject)
endFunction

function OrientRelativeTo(ObjectReference akObject, float afRotX = 0.0, float afRotY = 0.0, float afRotZ = 0.0)
    OrientRelative(this, akObject, afRotX, afRotY, afRotZ)
endFunction

bool function IsFarFromPlayer()
    return RPB_Utility.IsActorFarAwayFromPlayer(this)
endFunction

string function GetSex(bool abShortValue = false)
    if (self.IsFemale)
        return string_if (abShortValue, "F", "Female")
    elseif (self.IsMale)
        return string_if (abShortValue, "M", "Male")
    endif
endFunction

; ==========================================================
;                          Clothing
; ==========================================================

; TODO: Check if Actor is in underwear, if so, it's not naked, return false
bool function IsNaked()
    bool hasBodyClothing = this.GetWornForm(0x00000004) == none
    return hasBodyClothing
    ; TOOD: Logic to determine when the actor is naked
endFunction

bool function IsInUnderwear()
    return true
    ; TOOD: Logic to determine when the actor is only wearing underwear
endFunction

;/
    For actions that require the reference of the underwear,
    consider using self.GetUnderwear() and check that value != none instead
/;
bool function HasUnderwear()
    Armor underwearTop      = self.GetUnderwear("Top")
    Armor underwearBottom   = self.GetUnderwear("Bottom")

    return underwearTop || underwearBottom
endFunction

Armor function GetUnderwear(string asUnderwearPart)
    if (asUnderwearPart != "Top" && asUnderwearPart != "Bottom")
        return none
    endif

    int underwearClothingSlot

    if (asUnderwearPart == "Top")
        underwearClothingSlot = Config.UnderwearTopSlot

    elseif (asUnderwearPart == "Bottom")
        underwearClothingSlot = Config.UnderwearBottomSlot
    endif

    if (underwearClothingSlot == 0)
        return none
    endif

    int underwearSlotMask = RPB_Utility.GetSlotMaskValue(underwearClothingSlot)
    Armor underwearPart = this.GetWornForm(underwearSlotMask) as Armor

    return underwearPart
endFunction

bool function IsWearingOutfit(Armor[] akOutfit)
    if (!akOutfit)
        return false
    endif

    int i = 0
    while (i < akOutfit.Length)
        int slotMask = akOutfit[i].GetSlotMask()
        Armor wornPiece = this.GetWornForm(slotMask) as Armor
        if (wornPiece != akOutfit[i])
            return false
        endif
        i += 1
    endWhile

    return true
endFunction

; ==========================================================
;                           Bounty
; ==========================================================
 
function SyncLargestBountyForFaction(Faction akFaction)
    int currentBountyForFaction = self.GetActiveBountyForFaction(akFaction, abNonViolent = true, abViolent = true)
    int currentLargestBounty    = RPB_ActorVars.GetLargestBounty(akFaction, this)
    int newLargestBounty        = int_if (currentLargestBounty < currentBountyForFaction, currentBountyForFaction, currentLargestBounty)

    if (self.IsPlayer())
        int globalLargestBounty = Game.QueryStat("Largest Bounty")
        if (globalLargestBounty < newLargestBounty)
            ; Set the global stat
            SetGameStat("Largest Bounty", newLargestBounty)
        endif
    endif
 
    ; Set the local stat for the Hold
    RPB_ActorVars.SetLargestBounty(akFaction, this, newLargestBounty)

    DebugWithArgs("Actor::SyncLargestBountyForFaction", akFaction.GetName(), "[\n" + \ 
        "\t Current Largest Bounty: " + currentLargestBounty + "\n" + \
        "\t New Largest Bounty: " + newLargestBounty + "\n" + \
        "\t Bounty: " + currentBountyForFaction + "\n" + \
    "]")
endFunction

function SyncTotalBountyForFaction(Faction akFaction)
    int activeBounty = self.GetActiveBountyForFaction(akFaction)
    RPB_ActorVars.ModTotalBounty(akFaction, this, activeBounty)
endFunction


function ModTotalBountyForFaction(Faction akFaction, int aiAmountBy)
    int activeBounty = self.GetActiveBountyForFaction(akFaction)

    if (activeBounty == 0)
        RPB_StorageVars.SetIntOnForm("Previous Active Bounty", this, 0, "Temporary")
    endif

    int previousActiveBounty = RPB_StorageVars.GetIntOnForm("Previous Active Bounty", this, "Temporary")

    if (previousActiveBounty > 0)
        RPB_ActorVars.ModTotalBounty(akFaction, this, (Max(previousActiveBounty, aiAmountBy) - Min(previousActiveBounty, aiAmountBy)) as int)
    else
        RPB_ActorVars.ModTotalBounty(akFaction, this, aiAmountBy)
    endif

    ; Store the previous bounty
    RPB_StorageVars.SetIntOnForm("Previous Active Bounty", this, activeBounty, "Temporary")
endFunction


bool function HasActiveBountyForFaction(Faction akFaction)
    if (self.IsPlayer())
        return akFaction.GetCrimeGold() > 0
    else
        return RPB_ActorVars.GetCrimeGold(akFaction, this) > 0
    endif
endFunction

bool function HasLatentBountyForFaction(Faction akFaction)
    return RPB_ActorVars.GetLatentCrimeGold(akFaction, this) > 0
endFunction

function SetCrimeGoldForFaction(Faction akFaction, int aiGold)
    ; Handling for the Player, done by base Faction
    if (self.IsPlayer())
        akFaction.SetCrimeGold(aiGold)
        self.OnBountyGained()
        return
    endif

    ; Handling for NPC's below
    ; Unset the var if bounty is 0
    if (aiGold == 0)
        RPB_ActorVars.Unset(akFaction.GetName() + "::Bounty Non-Violent", this)
        return
    endif
    
    ; Set the bounty according to the value
    RPB_ActorVars.SetCrimeGold(akFaction, this, aiGold)

    self.OnBountyGained()
endFunction

function SetCrimeGoldViolentForFaction(Faction akFaction, int aiGold)
    ; Handling for the Player, done by base Faction
    if (self.IsPlayer())
        akFaction.SetCrimeGoldViolent(aiGold)
        return
    endif

    ; Handling for NPC's below
    ; Unset the var if bounty is 0
    if (aiGold == 0)
        RPB_ActorVars.Unset(akFaction.GetName() + "::Bounty Violent", this)
        return
    endif
    
    ; Set the bounty according to the value
    RPB_ActorVars.SetCrimeGoldViolent(akFaction, this, aiGold)

    self.OnBountyGained()
endFunction

function ModCrimeGoldForFaction(Faction akFaction, int aiAmount, bool abViolent = false)
    if (self.IsPlayer())
        akFaction.ModCrimeGold(aiAmount, abViolent)
    else
        RPB_ActorVars.ModCrimeGold(akFaction, this, aiAmount, abViolent)
    endif
endFunction

;/
    Gets the active bounty for this Actor, that is, the bounty that is currently set on a Faction when
    the Actor is wanted by that Faction.

    Faction @akFaction: The faction to retrieve the bounty from.
    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetActiveBountyForFaction(Faction akFaction, bool abNonViolent = true, bool abViolent = true)
    int totalBounty = 0
    
    if (abNonViolent)
        totalBounty += int_if (self.IsPlayer(), akFaction.GetCrimeGoldNonViolent(), RPB_ActorVars.GetCrimeGoldNonViolent(akFaction, this))
    endif

    if (abViolent)
        totalBounty += int_if (self.IsPlayer(), akFaction.GetCrimeGoldViolent(), RPB_ActorVars.GetCrimeGoldViolent(akFaction, this))
    endif

    return totalBounty
endFunction

;/
    Gets the latent bounty for this Actor, that is, the bounty that is stored when Arrested/Jailed.

    Faction @akFaction: The faction to retrieve the bounty from.
    bool?   @abNonViolent: Whether to get the non-violent bounty for this Faction.
    bool?   @abViolent: Whether to get the violent bounty for this Faction.
/;
int function GetLatentBountyForFaction(Faction akFaction, bool abNonViolent = true, bool abViolent = true)
    int totalBounty = 0

    if (abNonViolent)
        totalBounty += RPB_ActorVars.GetLatentCrimeGoldNonViolent(akFaction, this)
    endif

    if (abViolent)
        totalBounty += RPB_ActorVars.GetLatentCrimeGoldViolent(akFaction, this)
    endif

    return totalBounty
endFunction

;/
    Transfers the active bounty into the latent bounty.

    Faction @akFaction: The faction to restore the bounty to.
/;
function HideBountyForFaction(Faction akFaction)
    RPB_ActorVars.ModLatentCrimeGold(akFaction, this, self.GetActiveBountyForFaction(akFaction, abViolent = false), abViolent = false)
    RPB_ActorVars.ModLatentCrimeGold(akFaction, this, self.GetActiveBountyForFaction(akFaction, abNonViolent = false), abViolent = true)

    ; if (Defeated && DefeatedBounty > 0)
    ;     Vars_ModInt("Bounty Non-Violent", ArrestVars.DefeatedBounty, "ActorVars")
    ; endif

    self.SyncLargestBountyForFaction(akFaction)
    self.SyncTotalBountyForFaction(akFaction)
    self.ClearActiveBountyForFaction(akFaction)
endFunction

;/
    Restores the active bounty from the latent bounty.

    Faction @akFaction: The faction to restore the bounty to.
/;
function RestoreBountyForFaction(Faction akFaction)
    if (!self.HasLatentBountyForFaction(akFaction))
        return
    endif

    int nonViolent = self.GetLatentBountyForFaction(akFaction, abViolent = false)
    int violent    = self.GetLatentBountyForFaction(akFaction, abNonViolent = false)

    if (self.HasActiveBountyForFaction(akFaction))
        self.ModCrimeGoldForFaction(akFaction, nonViolent)
        self.ModCrimeGoldForFaction(akFaction, violent, true)
    else
        self.SetCrimeGoldForFaction(akFaction, nonViolent)
        self.SetCrimeGoldViolentForFaction(akFaction, violent)
    endif

    if (self.IsPlayer())
        ; Total Bounty has already been processed, don't let the game add it again
        Game.IncrementStat("Total Lifetime Bounty", -(nonViolent + violent))
    endif

    self.ClearLatentBountyForFaction(akFaction)
endFunction

;/
    Clears the Active Bounty for this Actor (The bounty when this Actor is wanted by the Faction).

    Faction @akFaction: The faction to clear the bounty of.
    bool?   @abNonViolent: Whether to clear non-violent bounty.
    bool?   @abViolent: Whether to clear violent bounty.
/;
function ClearActiveBountyForFaction(Faction akFaction, bool abNonViolent = true, bool abViolent = true)
    if (abNonViolent)
        self.SetCrimeGoldForFaction(akFaction, 0)
    endif

    if (abViolent)
        self.SetCrimeGoldViolentForFaction(akFaction, 0)
    endif
endFunction

;/
    Clears the Latent Bounty for this Actor (The bounty used when Arrested/Jailed).

    Faction @akFaction: The faction to clear the bounty of.
    bool?   @abNonViolent: Whether to clear non-violent bounty.
    bool?   @abViolent: Whether to clear violent bounty.
/;
function ClearLatentBountyForFaction(Faction akFaction, bool abNonViolent = true, bool abViolent = true)
    if (abNonViolent)
        RPB_ActorVars.Unset(akFaction.GetName() + "::Latent Bounty Non-Violent", this)
    endif

    if (abViolent)
        RPB_ActorVars.Unset(akFaction.GetName() + "::Latent Bounty Violent", this)
    endif
endFunction

; ==========================================================
;                          Actor Vars
; ==========================================================

int function QueryFactionStat(string asStatName, Faction akFaction)
    return RPB_ActorVars.GetStat(asStatName, akFaction, this)
endFunction

function SetFactionStat(string asStatName, Faction akFaction, int aiValue)
    RPB_ActorVars.SetStat(asStatName, akFaction, this, aiValue)

    if (TrackStats)
        self.OnStatChanged(asStatName, aiValue)
    endif
endFunction

;/
    Queries the given stat for this faction and this Actor.
/;
int function QueryStat(string statName)
    return RPB_ActorVars.GetStat(statName, self.GetFaction(), this)
endFunction

;/
    Sets the given stat for this faction and this Actor.
/;
function SetStat(string statName, int value)
    RPB_ActorVars.SetStat(statName, self.GetFaction(), this, value)

    if (TrackStats)
        self.OnStatChanged(statName, value)
    endif
endFunction

;/
    Increments the given stat by the amount given.
/;
function IncrementStat(string statName, int incrementBy = 1)
    RPB_ActorVars.IncrementStat(statName, self.GetFaction(), this, incrementBy)

    if (TrackStats)
        self.OnStatChanged(statName, self.QueryStat(statName))
    endif
endFunction

;/
    Decrements the given stat by the amount given.
/;
function DecrementStat(string statName, int decrementBy = 1)
    RPB_ActorVars.DecrementStat(statName, self.GetFaction(), this, decrementBy)

    if (TrackStats)
        self.OnStatChanged(statName, self.QueryStat(statName))
    endif
endFunction

function ModifyStat(string statName, float modifyBy)
    RPB_ActorVars.ModifyStat(statName, self.GetFaction(), this, modifyBy)

    if (TrackStats)
        self.OnStatChanged(statName, self.QueryStat(statName))
    endif
endFunction

; ==========================================================
;                         Scene States
; ==========================================================

function SetStateForScene(string asSceneName, string asSceneState)
    self.SetString(asSceneName, asSceneState, "SceneState")
endFunction

bool function HasSceneState(string asSceneName, string asSceneState)
    bool hasState = self.GetString(asSceneName, "SceneState") == asSceneState
    return hasState
endFunction

function DeleteSceneStates()
    self.RemoveAll("SceneState")
endFunction

; ==========================================================
;                     State Storage Vars
; ==========================================================

;/
    Gets the variable category through the script that is currently attached.

    If the underlying script is a child of RPB_ActorBase, and the category passed in
    is the default, it is set as the category for that specific script.

    If on the other hand, the script is RPB_ActorBase, the category will be of that script.

    In the case of @asVarCategory being passed in and not being the default value,
    despite the underlying script, that category will be used instead.

    returns: The variable category of the underlying script attached or @asVarCategory if passed in.
/;
string function GetScriptVarCategory(string asVarCategory = "Actor")
    ; return asVarCategory
    if (self as RPB_Prisoner && asVarCategory == "Actor")
        return "Jail"

    elseif (self as RPB_Arrestee && asVarCategory == "Actor")
        return "Arrest"

    elseif (self as RPB_Captor && asVarCategory == "Actor")
        return "Captor"

    elseif (!(self as RPB_ActorBase) && asVarCategory == "Actor")
        DebugError("Actor::GetScriptVarCategory", "Could not find the underlying attached script, no category defined!")
        return "null"
    endif

    return asVarCategory
endFunction

string function DestroyPropertyOnState(string asStateName)
    return "Temporary::"+ asStateName
endFunction

;                           Getters
bool function GetBool(string asVarName, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    return RPB_StorageVars.GetBoolOnForm(asVarName, this, category)
endFunction

; Alias for GetBool() to check a condition
bool function Is(string asVarName, string asVarCategory = "Actor")
    return GetBool(asVarName, asVarCategory)
endFunction

; Alias for GetBool() to check possession
bool function Has(string asVarName, string asVarCategory = "Actor")
    return GetBool(asVarName, asVarCategory)
endFunction

; Alias for GetBool() to check past events or possession
bool function Was(string asVarName, string asVarCategory = "Actor")
    return GetBool(asVarName, asVarCategory)
endFunction

; Alias for GetBool() to check whether an action should be taken
bool function Should(string asVarName, string asVarCategory = "Actor")
    return GetBool(asVarName, asVarCategory)
endFunction

; Alias for GetBool() to check whether an action should be taken
bool function Must(string asVarName, string asVarCategory = "Actor")
    return GetBool(asVarName, asVarCategory)
endFunction

int function GetInt(string asVarName, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    return RPB_StorageVars.GetIntOnForm(asVarName, this, category)
endFunction

float function GetFloat(string asVarName, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    return RPB_StorageVars.GetFloatOnForm(asVarName, this, category)
endFunction

string function GetString(string asVarName, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    return RPB_StorageVars.GetStringOnForm(asVarName, this, category)
endFunction

Form function GetForm(string asVarName, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    return RPB_StorageVars.GetFormOnForm(asVarName, this, category)
endFunction

ObjectReference function GetReference(string asVarName, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    return RPB_StorageVars.GetFormOnForm(asVarName, this, category) as ObjectReference
endFunction


;                          Setters
function SetBool(string asVarName, bool abValue, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.SetBoolOnForm(asVarName, this, abValue, category)
    ; Debug("Actor::SetBool", "["+ self +"] Setting " + asVarName + " on " + this + " to: " + abValue)
endFunction

function SetInt(string asVarName, int aiValue, string asVarCategory = "Actor", int aiMinValue = 0, int aiMaxValue = 0)
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.SetIntOnForm(asVarName, this, aiValue, category)
endFunction

function ModInt(string asVarName, int aiValue, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.ModIntOnForm(asVarName, this, aiValue, category)
    ; Debug("Actor::ModInt", "["+ self +"] Modifying " + asVarName + " on " + this + " by: " + aiValue)
endFunction

function SetFloat(string asVarName, float afValue, string asVarCategory = "Actor", float afMinValue = 0.0, float afMaxValue = 0.0)
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.SetFloatOnForm(asVarName, this, afValue, category)
    ; Debug("Actor::SetFloat", "["+ self +"] Setting " + asVarName + " on " + this + " to: " + afValue)
endFunction

function ModFloat(string asVarName, float afValue, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.ModFloatOnForm(asVarName, this, afValue, category)
    ; Debug("Actor::ModFloat", "["+ self +"] Modifying " + asVarName + " on " + this + " by: " + afValue)
endFunction

function SetString(string asVarName, string asValue, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.SetStringOnForm(asVarName, this, asValue, category)
    ; Debug("Actor::SetString", "["+ self +"] Setting " + asVarName + " on " + this + " to: " + asValue)
endFunction

function SetForm(string asVarName, Form akValue, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.SetFormOnForm(asVarName, this, akValue, category)
    ; Debug("Actor::SetForm", "["+ self +"] Setting " + asVarName + " on " + this + " to: " + akValue)
endFunction

function SetReference(string asVarName, ObjectReference akValue, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.SetFormOnForm(asVarName, this, akValue, category)
    ; Debug("Actor::SetReference", "["+ self +"] Setting " + asVarName + " on " + this + " to: " + akValue)
endFunction

function Remove(string asVarName, string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.DeleteVariableOnForm(asVarName, this, category)
    ; Debug("Actor::Remove", "["+ self +"] Removing " + asVarName + " from " + this)
endFunction

function RemoveAll(string asVarCategory = "Actor")
    string category = self.GetScriptVarCategory(asVarCategory)
    RPB_StorageVars.DeleteCategoryOnForm(this, category)
    ; Debug("Actor::RemoveAll", "["+ self +"] Removing all variables from " + this)
endFunction

; ==========================================================

; ==========================================================
;                          Management
; ==========================================================

event OnEffectStart(Actor akTarget, Actor akCaster)
    ; Debug("("+ self as string +") RPB_ActorBase::OnEffectStart", this + ": IsInitialized: " + self.IsInitialized)

    if (self.IsInitialized)
        OnRestore()
        return
    endif

    __this = akTarget
    __isEffectActive = true

    ; Assigns the actor for this script, differentiating between Player and NPC to avoid retrieving properties, instead caching it in a local variable to this script
    self.__assignActor()

    ; Initialization to overriden children
    ; TODO: Only initialize this based on a flag perhaps, so Prisoners don't get the effect initialized when they shouldn't (because it happens when the player is nearby)
    self.OnInitialize()

    IsInitialized = true
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
    Debug("RPB_ActorBase::OnEffectFinish", this + " is no longer bound to " + self as string + ", detaching script!")

    __isEffectActive = false
    self.OnDestroy()
endEvent

event OnDetach()
    Debug("Actor::OnDetach", "Detached " + self)
endEvent

event OnTrackedStatsEvent(string asStatFilter, int aiValue)
    if (TrackStats)
        self.OnStatChanged(asStatFilter, aiValue)
    endif
endEvent

; Handles the tracked stats when they are changed.
; Tracks both ActorVars for this particular Actor and all stats handled by OnTrackedStatsEvent() for the Player.
event OnStatChanged(string asStatName, float afValue) ; virtual
endEvent

event OnBountyGained() ; virtual
endEvent

; Handles the initialization of this Actor
event OnInitialize() ; virtual
endEvent

event OnRestore() ; virtual
endEvent

; Handles the destruction of this Actor
event OnDestroy() ; virtual
endEvent

;                     Virtual Functions
; ==========================================================

function Destroy() ; virtual
    ; Debug("("+ Name +") Actor::Destroy", "this " + this + " from script " + self as string)

    ; RPB_StorageVars.DeleteVariableOnForm("Is Initialized", this, "Actor")
    RPB_StorageVars.DeleteCategoryOnForm(this, "Actor")
    RPB_StorageVars.DeleteCategoryOnForm(this, "Temporary")
endFunction

; ==========================================================

; Registers this Actor to receive events when tracked stats are updated.
function RegisterForTrackedStats()
    if (self.IsPlayer())
        RegisterForTrackedStatsEvent() ; Vanilla Stats, Player only

        if (self.RegisterSleepEvents)
            RegisterForSleep()
        endif
    endif

    __trackStats = true
endFunction

function UnregisterForTrackedStats()
    if (self.IsPlayer())
        UnregisterForTrackedStatsEvent() ; Vanilla Stats, Player only
    endif

    __trackStats = false
endFunction

function UnregisterForUpdates()
    self.UnregisterForUpdate()
    self.UnregisterForUpdateGameTime()
endFunction

Actor function GetActor() ; virtual
    Debug("Actor::GetActor", "Actor has not been overridden for " + self.GetExtends() + ", some features may not work properly! [Implement method " + self.GetExtends() + ".GetActor()]")
endFunction

Faction function GetFaction() ; virtual
    Debug("Actor::GetFaction", "Faction has not been overridden for " + self.GetExtends() + ", some features may not work properly! [Implement method " + self.GetExtends() + ".GetFaction()]")
endFunction

string function GetExtends()
    return self.GetBaseObject().GetName()
endFunction

string function GetName()
    return this.GetBaseObject().GetName()
endFunction

string function GetIdentifier()
    return this.GetFormID()
endFunction

int function GetFormID()
    return this.GetFormID()
endFunction


;/
    The Actor that is currently attached to this script.

    The reason this is not a property with the value of GetTargetActor() is due to how the MagicEffect works once removed.
    When removing the magic effect from the Actor, and calling any function/event that requires a reference to said Actor,
    it will return None because the script is not pointing to that reference anymore, this is a workaround that enables the script
    to assign this value to akTarget OnEffectStart(), bypassing the problem entirely.

    The value is set through OnEffectStart().
/;
Actor __this
Actor property this
    Actor function get()
        return __this
    endFunction
endProperty

;/
    Whether to track this Actor's stats.
/;
bool __trackStats
bool property TrackStats
    bool function get()
        return __trackStats
    endFunction
endProperty

bool property RegisterSleepEvents auto

string property CurrentState
    string function get()
        return self.GetState()
    endFunction
endProperty

bool __isEffectActive
bool property IsEffectActive
    bool function get()
        return __isEffectActive
    endFunction
endProperty

bool property IsInitialized
    bool function get()
        return RPB_StorageVars.GetBoolOnForm("Is Initialized", this, "Actor")
        ; return self.GetBool("Is Initialized")
    endFunction

    function set(bool value)
        return RPB_StorageVars.SetBoolOnForm("Is Initialized", this, value, "Actor")
        ; self.SetBool("Is Initialized", value)
    endFunction
endProperty

; State vars to control whether this Actor is the Player or an NPC
bool __isPlayer
bool __wasActorAssigned

; Internal function for RPB_ActorBase, assigns the Actor for this script
function __assignActor()
    if (this.GetFormID() == 0x14) ; Player FormID
        __isPlayer = true
        __wasActorAssigned = true
    else
        __isPlayer = false
        __wasActorAssigned = true
    endif
endFunction

bool function IsPlayer()
    return __wasActorAssigned && __isPlayer
endFunction

bool function IsNPC()
    return __wasActorAssigned && !__isPlayer
endFunction
