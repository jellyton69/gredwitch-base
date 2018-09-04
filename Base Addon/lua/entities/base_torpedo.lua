AddCSLuaFile()
if SERVER then util.AddNetworkString("gred_net_gtorpedoes_explosion_fx") end
if CLIENT then
	net.Receive("gred_net_gtorpedoes_explosion_fx",function()
		ParticleEffect(net.ReadString(),net.ReadVector(),net.ReadAngle(),nil)
		if net.ReadBool() then
			ParticleEffect("doi_ceilingDust_large",net.ReadVector(),Angle(0,0,0),nil)
		end
	end)
end
DEFINE_BASECLASS( "base_anim" )
sound.Add( {
	name = "RP3_Engine",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 120,
	pitch = {100},
	sound = "gunsounds/rpg_rocket_loop.wav"
} )

sound.Add( {
	name = "Hydra_Engine",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 120,
	pitch = {100},
	sound = "wac/rocket_idle.wav"
} )

sound.Add( {
	name = "Nebelwerfer_Fire",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 120,
	pitch = {80,140},
	sound = "gunsounds/nebelwerfer_rocket.wav"
} )
local ExploSnds = {}
ExploSnds[1]                      =  "chappi/imp0.wav"

local damagesound                    =  "weapons/rpg/shotdown.wav"


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "Gredwitch's Torpedo base"
ENT.Author			                 =  "Gredwitch"
ENT.Contact			                 =  "qhamitouche@gmail.com"
ENT.Category                         =  "Explosives"

ENT.Model                            =  ""
ENT.RocketTrail                      =  ""
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""
ENT.EffectWater                      =  ""

ENT.ExplosionSound                   =  ENT.ExplosionSound
ENT.FarExplosionSound				 =  ENT.ExplosionSound
ENT.DistExplosionSound				 =  ENT.ExplosionSound

ENT.WaterExplosionSound				 =	nil
ENT.WaterFarExplosionSound			 =  nil

ENT.StartSound                       =  ""
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound                  =  "buttons/button14.wav"
ENT.EngineSound                      =  "Missile.Ignite"
ENT.NBCEntity                        =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.UseRandomSounds                  =  false
ENT.SmartLaunch                      =  false
ENT.Timed                            =  false
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  0
ENT.ExplosionRadius                  =  0
ENT.PhysForce                        =  0
ENT.SpecialRadius                    =  0
ENT.MaxIgnitionTime                  =  5
ENT.Life                             =  20
ENT.MaxDelay                         =  2
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  500
ENT.Mass                             =  0
ENT.EnginePower                      =  0             
ENT.FuelBurnoutTime                  =  0             
ENT.IgnitionDelay                    =  0          
ENT.ForceOrientation                 =  "NORMAL"
ENT.Timer                            =  0


ENT.LightEmitTime                    =  0
ENT.LightRed                         =  0
ENT.LightBlue						 =  0
ENT.LightGreen						 =  0
ENT.LightBrightness					 =  0
ENT.LightSize   					 =  0
ENT.RSound   						 =  1



ENT.GBOWNER                          =  nil             -- don't you fucking touch this.



function ENT:Initialize()
 if (SERVER) then
	if (GetConVar("gred_sv_spawnable_bombs"):GetInt() == 0 and !self.IsOnPlane)
	or (GetConVar("gred_sv_wac_bombs"):GetInt() == 0 and self.IsOnPlane) then
		self:Remove()
	end
	
		local physEnvironment = physenv.GetPerformanceSettings()
		physEnvironment.MaxVelocity = 3500
		physenv.SetPerformanceSettings(physEnvironment)
     self:SetModel(self.Model)  
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType(MOVETYPE_VPHYSICS)
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Armed    = false
	 self.Exploded = false
	 self.Fired    = false
	 self.Burnt    = false
	 self.Ignition = false
	 self.Arming   = false
	 if !(WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "Arm", "Detonate", "Launch" }) end
	end
end

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end
	 if (iname == "Detonate") then
         if (value >= 1) then
		     if (!self.Exploded and self.Armed) then
			     timer.Simple(math.Rand(0,self.MaxDelay),function()
				     if !self:IsValid() then return end
	                 self.Exploded = true
					 
			         self:Explode()
				 end)
		     end
		 end
	 end
	 if (iname == "Arm") then
         if (value >= 1) then
             if (!self.Exploded and !self.Armed and !self.Arming) then
			     self:EmitSound(self.ActivationSound)
                 self:Arm()
             end 
         end
     end		 
	 if (iname == "Launch") then 
	     if (value >= 1) then
		     if (!self.Exploded and !self.Burnt and !self.Ignition and !self.Fired) then
			     self:Launch()
		     end
	     end
     end
end          

function ENT:Explode()
     if not self.Exploded then return end
	 local pos = self:LocalToWorld(self:OBBCenter())
	 
	  	 local ent = ents.Create("shockwave_ent")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",self.ExplosionRadius)
	 ent:SetVar("SHOCKWAVEDAMAGE",self.ExplosionDamage)
	 ent:SetVar("SHOCKWAVE_INCREMENT",100)
	 ent:SetVar("DELAY",0.01)
	 ent.trace=self.TraceLength
	 ent.decal=self.Decal
	 
	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius)) do
	     if v:IsValid() then
		     --local phys = v:GetPhysicsObject()
			 local i = 0
		     while i < v:GetPhysicsObjectCount() do
			 phys = v:GetPhysicsObjectNum(i)	  
             if (phys:IsValid()) then		
		 	     local mass = phys:GetMass()
				 local F_ang = self.PhysForce
				 local dist = (pos - v:GetPos()):Length()
				 local relation = math.Clamp((self.SpecialRadius - dist) / self.SpecialRadius, 0, 1)
				 local F_dir = (v:GetPos() - pos):GetNormal() * self.PhysForce
				   
				 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
				 phys:AddVelocity(F_dir)
		     end
			 i = i + 1
			 end
		 end
	 end
	 
	net.Start("gred_net_gtorpedoes_explosion_fx")
	if(self:WaterLevel() >= 1) then
		local trdata   = {}
		local trlength = Vector(0,0,9000)

		trdata.start   = pos
		trdata.endpos  = trdata.start + trlength
		trdata.filter  = self
		local tr = util.TraceLine(trdata) 

		local trdat2   = {}
		trdat2.start   = tr.HitPos
		trdat2.endpos  = trdata.start - trlength
		trdat2.filter  = self
		trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT
			 
		local tr2 = util.TraceLine(trdat2)
		
		if tr2.Hit then
			net.WriteString(self.EffectWater)
			net.WriteVector(tr2.HitPos)
			if self.EffectWater == "ins_water_explosion" then
				net.WriteAngle(Angle(-90,0,0))
			else
				net.WriteAngle(Angle(0,0,0))
			end
		end
		 
		if self.WaterExplosionSound == nil then else 
			self.ExplosionSound = self.WaterExplosionSound 
		end
		if self.WaterFarExplosionSound == nil then else  
			self.FarExplosionSound = self.WaterFarExplosionSound 
		end
		
     else
		 local tracedata    = {}
	     tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		 tracedata.filter   = self.Entity
				
		 local trace = util.TraceLine(tracedata)
	     
		if trace.HitWorld then
			net.WriteString(self.Effect)
			net.WriteVector(pos)
			if self.AngEffect then
				net.WriteAngle(Angle(-90,0,0))
				net.WriteBool(true)
				net.WriteVector(pos-Vector(0,0,100))
			else
				net.WriteAngle(Angle(0,0,0))
			end
		else 
			net.WriteString(self.Effect)
			net.WriteVector(pos)
			if self.AngEffect then
				net.WriteAngle(Angle(-90,0,0))
			else
				net.WriteAngle(Angle(0,0,0))
			end
		end
    end
	net.Broadcast()
	 
	local ent = ents.Create("shockwave_sound_lowsh")
	ent:SetPos( pos ) 
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("MAX_RANGE",self.ExplosionDamage*self.ExplosionRadius)
	if self.RSound == nil then ent:SetVar("NOFARSOUND",1) else
		ent:SetVar("NOFARSOUND",self.RSound) 
	end
	ent:SetVar("SHOCKWAVE_INCREMENT",200)
	
	ent:SetVar("DELAY",0.01)
	ent:SetVar("SOUNDCLOSE", self.ExplosionSound)
	ent:SetVar("SOUND", self.FarExplosionSound)
	ent:SetVar("SOUNDFAR", self.DistExplosionSound)
	ent:SetVar("Shocktime", 0)
	
	 if self.IsNBC then
	     local nbc = ents.Create(self.NBCEntity)
		 nbc:SetVar("GBOWNER",self.GBOWNER)
		 nbc:SetPos(self:GetPos())
		 nbc:Spawn()
		 nbc:Activate()
	 end
	self:StopSound(self.EngineSound)
	self:Remove()
end
function ENT:OnTakeDamage(dmginfo)
     if !self:IsValid() then return end
     if self.Exploded then return end
	 exploDamage = dmginfo:IsDamageType(64)
	 if exploDamage == true then return end
	 if (self.Life <= 0) then return end
	 self:TakePhysicsDamage(dmginfo)
     if(GetConVar("gred_sv_fragility"):GetInt() >= 1) then  
	     if(!self.Fired and !self.Burnt and !self.Arming and !self.Armed) then
	         if(math.random(0,9) == 1) then
		         self:Launch()
		     else
			     self:Arm()
			 end
	     end
	 end
	 if(self.Fired and !self.Burnt and self.Armed) then
	     if (dmginfo:GetDamage() >= 2) then
		     local phys = self:GetPhysicsObject()
		     self:EmitSound(damagesound)
	         phys:AddAngleVelocity(dmginfo:GetDamageForce()*0.1)
	     end
	 end
	 if(!self.Armed) then return end
	 self.Life = self.Life - dmginfo:GetDamage()
     if (self.Life <= 0) then 
		 timer.Simple(math.Rand(0,self.MaxDelay),function()
	         if !self:IsValid() then return end 
			 self.Exploded = true
			 self:Explode()
			
	     end)
	 end
end

function ENT:PhysicsCollide( data, physobj )
	 timer.Simple(0,function()
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
		 if(GetConVar("gred_sv_fragility"):GetInt() >= 1) then
			 if(!self.Fired and !self.Burnt and !self.Arming and !self.Armed ) and (data.Speed > self.ImpactSpeed * 5) then --and !self.Arming and !self.Armed
				 if(math.random(0,9) == 1) then
					 self:Launch()
					 self:EmitSound(damagesound)
				 else
					 self:Arm()
					 self:EmitSound(damagesound)
				 end
			 end
		 end

		 if(!self.Armed) then return end
			
		 if (data.Speed > self.ImpactSpeed )then
			 self.Exploded = true
			 self:Explode()
		 end
	end)
end

function ENT:Launch()
    if(self.Exploded) then return end
	if(self.Burned) then return end
	if(self.Fired) then return end
	if(!self.Armed) then return end
	if self:WaterLevel() < 1 then return end
	 
	 local phys = self:GetPhysicsObject()
	 if !phys:IsValid() then return end
	 
	 if(self.SmartLaunch) then
		 constraint.RemoveAll(self)
	 end
	 timer.Simple(0.05,function()
	     if not self:IsValid() then return end
	     if(phys:IsValid()) then
             phys:Wake()
		     phys:EnableMotion(true)
	     end
	 end)
	 timer.Simple(0.6,function()
	     if not self:IsValid() then return end  -- Make a short ignition delay!
		 self:SetNetworkedBool("Exploded",true)
		 self:SetNetworkedInt("LightRed", self.LightRed)
		 self:SetNetworkedInt("LightBlue", self.LightBlue)
		 self:SetNetworkedInt("LightGreen", self.LightGreen)
		 self:SetNetworkedBool("EmitLight",true)
		 self:SetNetworkedInt("LightEmitTime", self.LightEmitTime)
		 self:SetNetworkedInt("LightBrightness", self.LightBrightness)
		 self:SetNetworkedInt("LightSize", self.LightSize)
		 local phys = self:GetPhysicsObject()
		 self.Ignition = true
		 self:Arm()
		 local pos = self:GetPos()
		 sound.Play(self.StartSound, pos, 160, 130,1)
	     self:EmitSound(self.EngineSound)
		 self:SetNetworkedBool("EmitLight",true)
		 self:SetNetworkedBool("self.Ignition",true)
		 if(self.FuelBurnoutTime != 0) then
	         timer.Simple(self.FuelBurnoutTime,function()
		         if not self:IsValid() then return end
		         self.Burnt = true
		         self:StopParticles()
		         self:StopSound(self.EngineSound)
             end)
		 end
     end)
	 self.Fired = true
	-- phys:SetAngles(Angle(0,self:GetAngles().r,self:GetAngles().y))
end

function ENT:Think()
    if(self.Burnt) then return end
	if(self.Exploded) then return end -- if we exploded then what the fuck are we doing here
	if(!self:IsValid()) then return end -- if we aren't good then something fucked up
	local phys = self:GetPhysicsObject()  
	local thrustpos = self:GetPos()
	self:Launch()
	ParticleEffectAttach("weapon_tracers_smoke",PATTACH_ABSORIGIN_FOLLOW,self,1)
	if self.Fired and self:WaterLevel() > 2 then
		self:SetAngles(Angle(0,self:GetAngles().y,0))
	    --[[local effectdata=EffectData()
		effectdata:SetAngles(self:GetAngles())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetEntity(self)
		util.Effect("WaterSurfaceExplosion", effectdata)]]
		phys:AddVelocity(self:GetForward() * self.EnginePower)
	elseif self.Fired and self:WaterLevel() <= 1 then
		self:SetPos(self:GetPos()-Vector(0,0,50))
		self:SetAngles(Angle(0,self:GetAngles().y,0))
		phys:AddVelocity(self:GetForward() * self.EnginePower)
	end
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
		 if(self.Timed) then
	         timer.Simple(self.Timer, function()
	             if !self:IsValid() then return end 
			     self.Exploded = true
			     self:Explode()
				 self.EmitLight = true
	         end)
		 end
	 end)
end	 

function ENT:Use( activator, caller )
     if(self.Exploded) then return end
	 if(self.Dumb) then return end
	 if(GetConVar("gred_sv_easyuse"):GetInt() >= 1) then
         if(self:IsValid()) then
             if (!self.Exploded) and (!self.Burnt) and (!self.Fired) then
	             if (activator:IsPlayer()) then
                    self:EmitSound(self.ActivationSound)
                    self:Arm()
                    self:Launch()
		         end
	         end
         end
	 end
end

function ENT:OnRemove()
     self:StopSound(self.EngineSound)
	 self:StopParticles()
end

if ( CLIENT ) then
     function ENT:Draw()
         self:DrawModel()
		 if !(WireAddon == nil) then Wire_Render(self.Entity) end
     end
end

function ENT:OnRestore()
     Wire_Restored(self.Entity)
end

function ENT:BuildDupeInfo()
     return WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
     WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PrentityCopy()
     local DupeInfo = self:BuildDupeInfo()
     if(DupeInfo) then
         duplicator.StorentityModifier(self.Entity,"WireDupeInfo",DupeInfo)
     end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
     if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
         Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
     end
end