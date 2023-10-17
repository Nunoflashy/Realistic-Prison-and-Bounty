Scriptname RealisticPrisonAndBounty_CaptorRef extends ReferenceAlias  

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_Arrest property Arrest
    RealisticPrisonAndBounty_Arrest function get()
        return Config.Arrest
    endFunction
endProperty

RealisticPrisonAndBounty_Jail property Jail
    RealisticPrisonAndBounty_Jail function get()
        return Config.Jail
    endFunction
endProperty

Actor property this
    Actor function get()
        return self.GetActorReference()
    endFunction
endProperty

event OnInit()
    Debug(self.GetOwningQuest(), "OnInit", "Initialized alias to reference: " + self.GetActorRef().GetActorBase().GetName())
    ; RegisterForLOS(self.GetActorReference(), jail.Arrestee)
endEvent

event OnAttach()
    
endEvent

event OnDeath(Actor akKiller)
    Debug(self.GetOwningQuest(), "OnDeath", "The captor has died! (Captor: " + self.GetActorRef().GetActorBase().GetName() + ") [Killed by: " + akKiller.GetName() +"]")
    arrest.OnArrestCaptorDeath(this, akKiller)
endEvent

event OnEquipped(Actor akActor)
    Debug(self.GetOwningQuest(), "OnEquipped", "Equipped item")
endEvent

event OnSit(ObjectReference akFurniture)
    ; Debug(self.GetOwningQuest(), "OnSit", this + " sat on " + akFurniture.GetBaseObject().GetName())
    ; RegisterForLOS(this, jail.config.Player)
    ; Debug(self.GetOwningQuest(), "OnSit", this + " registered LOS for " + jail.config.Player)
endEvent

event OnGainLOS(Actor akViewer, ObjectReference akTarget)
    ; Debug(self.GetOwningQuest(), "OnGainLOS", akViewer + " is seeing " + akTarget)
    ; jail.OnGuardSeesPrisoner(this)
endEvent

event OnLostLOS(Actor akViewer, ObjectReference akTarget)
    Debug(self.GetOwningQuest(), "OnLostLOS", akViewer + " is not seeing " + akTarget + " anymore")
endEvent