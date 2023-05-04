Scriptname RealisticPrisonAndBounty_CaptorRef extends ReferenceAlias  

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

event OnInit()
    Debug(self.GetOwningQuest(), "OnInit", "Initialized alias to reference: " + self.GetActorRef().GetActorBase().GetName())
endEvent

event OnDeath(Actor akKiller)
    Debug(self.GetOwningQuest(), "OnDeath", "The captor has died! (Captor: " + self.GetActorRef().GetActorBase().GetName() + ") [Killed by: " + akKiller.GetName() +"]")
endEvent

event OnEquipped(Actor akActor)
    Debug(self.GetOwningQuest(), "OnEquipped", "Equipped item")
endEvent

event OnSit(ObjectReference akFurniture)
    Debug(self.GetOwningQuest(), "OnSit", "Sat on " + akFurniture.GetBaseObject().GetName())
endEvent