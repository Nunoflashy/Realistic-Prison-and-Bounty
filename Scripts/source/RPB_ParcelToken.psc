scriptname RPB_ParcelToken extends ObjectReference

;/
    The token of a parcel (RPB_Parcels): what stands for one owner's things kept together, wherever it is (a guard's
    inventory, a chest). Each one is its own persistent reference, named after its parcel. All I do is say where I went;
    RPB_Parcels decides what that means.

@events:
    event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
/;

event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    RPB_API.GetParcels().OnTokenMoved(self, akNewContainer, akOldContainer)
endEvent
