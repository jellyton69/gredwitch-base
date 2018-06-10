AddCSLuaFile()

DEFINE_BASECLASS( "base_rocket" )

ENT.Spawnable		            	 =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "[ROCKETS]V1"
ENT.Author			                 =  ""
ENT.Contact			                 =  ""
ENT.Category                         =  "Gredwitch's Stuff"

ENT.Model                            =  "models/gredwitch/bombs/v1.mdl"
ENT.RocketTrail                      =  "fire_jet_01"
ENT.RocketBurnoutTrail               =  ""
ENT.Effect                           =  "500lb_ground"
ENT.EffectAir                        =  "500lb_ground"
ENT.EffectWater                      =  "water_torpedo"
ENT.ExplosionSound                   =  "explosions/gbomb_4.mp3" 
ENT.StartSound                       =  "gunsounds/v1_launch.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound                  =  "buttons/button14.wav"
ENT.EngineSound                      =  "V1_Engine"

ENT.ShouldUnweld                     =  true          
ENT.ShouldIgnite                     =  false         
ENT.UseRandomSounds                  =  true                  
ENT.SmartLaunch                      =  true  
ENT.Timed                            =  false 

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  500
ENT.ExplosionRadius                  =  1450
ENT.SpecialRadius                    =  1450        
ENT.MaxIgnitionTime                  =  0.5
ENT.Life                             =  1
ENT.MaxDelay                         =  0
ENT.TraceLength                      =  50
ENT.ImpactSpeed                      =  100
ENT.Mass                             =  700
ENT.EnginePower                      =  9999
ENT.FuelBurnoutTime                  =  20
ENT.IgnitionDelay                    =  2
ENT.ArmDelay                         =  0
ENT.RotationalForce                  =  0
ENT.ForceOrientation                 =  "NORMAL"       
ENT.Timer                            =  0


ENT.DEFAULT_PHYSFORCE                = 155
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000
ENT.Shocktime                        = 2

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()


     return ent
end
function ENT:Arm()
    if(!self:IsValid()) then return end
	if(self.Armed) then return end
	self.Arming = true
	 
	timer.Simple(self.ArmDelay, function()
	    if not self:IsValid() then return end 
	    self.Armed = true
		self.Arming = false
		self:EmitSound(self.ArmSound)
		self:Launch()
	 end)
end	 