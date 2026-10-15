scriptname RPB_Parcels extends Quest

import RPB_Memory

;/
    Parcels (2026-10-14): one owner's things kept together, as the exact items (tempering, enchantments, names kept), in a
    container of their own placed out of the world (RPB_ParcelHoldingMarker, in RPB_Markers). A token stands for each
    parcel wherever it is: in someone's inventory, in a chest. Whoever holds the token holds the parcel. A token reaching
    its owner's inventory opens there (Death Alternative's stolen-gear knapsack, made general); anyone else carries it
    closed (a follower's belongings recovered by the player open when handed to the follower).

    Carriers (RPB_ParcelCarrier, an ability): whoever is given a job around a parcel reports his fight's end and his
    unload as mod events; the job's giver decides what they mean.

    Nothing here knows what a parcel is for: the owner and the kind ("Belongings", "Weapons", anything) are the caller's,
    and what a parcel's moves mean (taken back from a prison's chest, stolen) is for the callers to decide through the
    "RPB_ParcelOpened" event. So it doesn't depend on any of RPB's systems, only on RPB_API's form lookup and the Fast*
    wrappers.

    A parcel is its container's reference. Its record, in .rpb_root.parcels by container: "owner", "kind", "token",
    "holder" (where the token is: a container or actor, none while it's in the world), "created" (game days).

@references:
    MiscObject TokenBase
    Container ContainerBase
    ObjectReference HoldingMarker
    Spell CarrierSpell
@functions:
    ObjectReference function Create(Form akOwner, string asKind, string asName)
    function PutRef(ObjectReference akParcel, ObjectReference akItem)
    function PutAll(ObjectReference akParcel, ObjectReference akSource)
    int function PutFrom(ObjectReference akParcel, ObjectReference akSource, Form[] akKeep)
    function GiveTo(ObjectReference akParcel, ObjectReference akHolder)
    function Open(ObjectReference akParcel, ObjectReference akDestination)
    ObjectReference function Find(Form akOwner, string asKind)
    ObjectReference function GetToken(ObjectReference akParcel)
    ObjectReference function GetHolder(ObjectReference akParcel)
    Form function GetOwner(ObjectReference akParcel)
    string function GetKind(ObjectReference akParcel)
    ObjectReference function GetParcelOfToken(ObjectReference akToken)
    function OnTokenMoved(ObjectReference akToken, ObjectReference akNewContainer, ObjectReference akOldContainer)
    function MakeCarrier(Actor akCarrier)
    function UnmakeCarrier(Actor akCarrier)
    int function __Record(ObjectReference akParcel)
    int function __All(string asPath)
/;

; ==========================================================
;                      Script References
; ==========================================================

MiscObject property TokenBase
    MiscObject function get()
        return RPB_API.GetFormFromMod(0x2C06E) as MiscObject
    endFunction
endProperty

Container property ContainerBase
    Container function get()
        return RPB_API.GetFormFromMod(0x2C06F) as Container
    endFunction
endProperty

ObjectReference property HoldingMarker
    ObjectReference function get()
        return RPB_API.GetFormFromMod(0x2C070) as ObjectReference
    endFunction
endProperty

Spell property CarrierSpell
    Spell function get()
        return RPB_API.GetFormFromMod(0x2C072) as Spell
    endFunction
endProperty

; ==========================================================
;                          Parcels
; ==========================================================

;/
    A new, empty parcel of @akOwner's, of @asKind, its token named @asName ("Ralof's Belongings"). The token starts out
    of the world, with the container: GiveTo puts it somewhere. Returns the parcel (its container)
/;
ObjectReference function Create(Form akOwner, string asKind, string asName)
    ObjectReference marker = self.HoldingMarker
    ObjectReference parcel = marker.PlaceAtMe(self.ContainerBase, 1, true, false)
    ObjectReference token = marker.PlaceAtMe(self.TokenBase, 1, true, false)
    if (!parcel || !token)
        RPB_Utility.LogError("Could not create a parcel for " + akOwner + " (" + asKind + "): container " + parcel + ", token " + token, "Parcels::Create")
        return none
    endif
    token.SetDisplayName(asName, true)
    parcel.SetDisplayName(asName, true)
    int record = JMap.object()
    FastMap_SetForm(record, "owner", akOwner)
    FastMap_SetString(record, "kind", asKind)
    FastMap_SetForm(record, "token", token)
    FastMap_SetFloat(record, "created", Utility.GetCurrentGameTime())
    FastFormMap_SetObject(self.__All(".rpb_root.parcels"), parcel, record)
    FastFormMap_SetForm(self.__All(".rpb_root.parcelTokens"), token, parcel)
    RPB_Utility.LogInfo("Created " + parcel + " '" + asName + "' (" + asKind + ") for " + akOwner + ", token " + token, "Parcels::Create")
    return parcel
endFunction

; Puts @akItem, an item lying in the world, into @akParcel: that exact item
function PutRef(ObjectReference akParcel, ObjectReference akItem)
    akParcel.AddItem(akItem, 1, true)
endFunction

; Puts everything @akSource carries into @akParcel in one call (an actor's worn things taken off), the fastest move
function PutAll(ObjectReference akParcel, ObjectReference akSource)
    akSource.RemoveAllItems(akParcel, true, true)
endFunction

;/
    Puts everything @akSource carries into @akParcel, but @akKeep (worn underwear, the cuffs), item by item (a frame each:
    PutAll when nothing is kept). All of each item goes, so every copy keeps its own data (only a part of a stack moved
    would leave the engine to choose which copies). Returns how many kinds of items went in
/;
int function PutFrom(ObjectReference akParcel, ObjectReference akSource, Form[] akKeep)
    Form[] items = PO3_SKSEFunctions.AddAllItemsToArray(akSource, false, false, false)
    int moved = 0
    int i = 0
    while (items && i < items.Length)
        Form item = items[i]
        if (item && !(akKeep && akKeep.Find(item) >= 0))
            int count = akSource.GetItemCount(item)
            if (count > 0)
                akSource.RemoveItem(item, count, true, akParcel)
                moved += 1
            endif
        endif
        i += 1
    endWhile
    return moved
endFunction

;/
    Gives @akParcel's token to @akHolder (an actor or a container): that token, not another parcel's held there too (the
    reference itself moved, as a quest item is)
/;
function GiveTo(ObjectReference akParcel, ObjectReference akHolder)
    int record = self.__Record(akParcel)
    if (!record || !akHolder)
        return
    endif
    ObjectReference token = FastMap_GetForm(record, "token") as ObjectReference
    ObjectReference holder = FastMap_GetForm(record, "holder") as ObjectReference
    FastMap_SetInt(record, "moving", 1) ; my own move: not a take (OnTokenMoved)
    if (holder)
        holder.RemoveItem(token, 1, true, akHolder)
    else
        akHolder.AddItem(token, 1, true)
    endif
endFunction

;/
    Empties @akParcel into @akDestination (the owner at a release, whoever took the token) and destroys it, the token
    included. Sends "RPB_ParcelOpened" (the parcel's owner, the destination, its kind)
/;
function Open(ObjectReference akParcel, ObjectReference akDestination)
    int record = self.__Record(akParcel)
    if (!record)
        return
    endif
    float started = Utility.GetCurrentRealTime()
    Form owner = FastMap_GetForm(record, "owner")
    string kind = FastMap_GetString(record, "kind")
    ObjectReference token = FastMap_GetForm(record, "token") as ObjectReference
    ObjectReference holder = FastMap_GetForm(record, "holder") as ObjectReference
    FastFormMap_RemoveKey(self.__All(".rpb_root.parcels"), akParcel)
    FastFormMap_RemoveKey(self.__All(".rpb_root.parcelTokens"), token)
    int items = akParcel.GetNumItems()
    akParcel.RemoveAllItems(akDestination, true, true)
    if (holder)
        holder.RemoveItem(token, 1, true)
    endif
    token.Delete()
    akParcel.Delete()
    RPB_Utility.LogInfo("Opened " + akParcel + " (" + kind + ", " + owner + "'s) into " + akDestination + ": " + items + " kinds of items in " + (((Utility.GetCurrentRealTime() - started) * 1000.0) as int) + "ms", "Parcels::Open")
    int handle = ModEvent.Create("RPB_ParcelOpened")
    if (handle)
        ModEvent.PushForm(handle, owner)
        ModEvent.PushForm(handle, akDestination)
        ModEvent.PushString(handle, kind)
        ModEvent.Send(handle)
    endif
endFunction

; @akOwner's parcel of @asKind, none without one (the first found)
ObjectReference function Find(Form akOwner, string asKind)
    int all = self.__All(".rpb_root.parcels")
    Form parcel = JFormMap.nextKey(all)
    while (parcel)
        int record = FastFormMap_GetObject(all, parcel)
        if (FastMap_GetForm(record, "owner") == akOwner && FastMap_GetString(record, "kind") == asKind)
            return parcel as ObjectReference
        endif
        parcel = JFormMap.nextKey(all, parcel)
    endWhile
    return none
endFunction

ObjectReference function GetToken(ObjectReference akParcel)
    return FastMap_GetForm(self.__Record(akParcel), "token") as ObjectReference
endFunction

; Where @akParcel's token is (a container or an actor), none while it's in the world
ObjectReference function GetHolder(ObjectReference akParcel)
    return FastMap_GetForm(self.__Record(akParcel), "holder") as ObjectReference
endFunction

Form function GetOwner(ObjectReference akParcel)
    return FastMap_GetForm(self.__Record(akParcel), "owner")
endFunction

string function GetKind(ObjectReference akParcel)
    return FastMap_GetString(self.__Record(akParcel), "kind")
endFunction

ObjectReference function GetParcelOfToken(ObjectReference akToken)
    return FastFormMap_GetForm(self.__All(".rpb_root.parcelTokens"), akToken) as ObjectReference
endFunction

;/
    A token moved (RPB_ParcelToken.OnContainerChanged): where it is now is recorded. Taken by its owner (not my own
    GiveTo), the parcel opens into their inventory; anyone else holds it closed
/;
function OnTokenMoved(ObjectReference akToken, ObjectReference akNewContainer, ObjectReference akOldContainer)
    ObjectReference parcel = self.GetParcelOfToken(akToken)
    int record = self.__Record(parcel)
    if (!record)
        return ; opened already (its own removal at the open)
    endif
    FastMap_SetForm(record, "holder", akNewContainer)
    bool ownMove = FastMap_GetInt(record, "moving") != 0
    FastMap_SetInt(record, "moving", 0)
    RPB_Utility.LogInfo("Token " + akToken + " of " + parcel + " moved from " + akOldContainer + " to " + akNewContainer + RPB_Utility.string_if(ownMove, " (given)", ""), "Parcels::OnTokenMoved")
    if (!ownMove && akNewContainer && akNewContainer == (FastMap_GetForm(record, "owner") as ObjectReference))
        self.Open(parcel, akNewContainer)
    endif
endFunction

; @akCarrier reports his fight's end and his unload from now on (RPB_ParcelCarrier)
function MakeCarrier(Actor akCarrier)
    if (akCarrier && !akCarrier.HasSpell(self.CarrierSpell))
        akCarrier.AddSpell(self.CarrierSpell, false)
    endif
endFunction

function UnmakeCarrier(Actor akCarrier)
    if (akCarrier && akCarrier.HasSpell(self.CarrierSpell))
        akCarrier.RemoveSpell(self.CarrierSpell)
    endif
endFunction

int function __Record(ObjectReference akParcel)
    if (!akParcel)
        return 0
    endif
    return FastFormMap_GetObject(self.__All(".rpb_root.parcels"), akParcel)
endFunction

; The JFormMap at @asPath, made the first time
int function __All(string asPath)
    int all = JDB.solveObj(asPath)
    if (!all)
        all = JFormMap.object()
        JDB.solveObjSetter(asPath, all, true)
    endif
    return all
endFunction
