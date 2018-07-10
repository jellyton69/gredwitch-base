AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

local Models = {}
Models[1]                            =  "testmodel"

local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "Name"
ENT.Author			                 =  "natsu"
ENT.Contact			                 =  "natsu"
ENT.Category                         =  ""

ENT.Model                            =  "self.bmodel"
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""
ENT.EffectWater                      =  ""
ENT.ArmSound                         =  ""
ENT.ActivationSound                  =  ""
ENT.NBCEntity                        =  ""
ENT.AngEffect						 =	false

ENT.ExplosionSound                   =  ""
ENT.FarExplosionSound				 =  ""
ENT.DistExplosionSound				 =  ""

ENT.WaterExplosionSound				 =	nil
ENT.WaterFarExplosionSound			 =  nil

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  false
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  0
ENT.PhysForce                        =  0
ENT.ExplosionRadius                  =  0
ENT.SpecialRadius                    =  0
ENT.MaxIgnitionTime                  =  5
ENT.Life                             =  20
ENT.MaxDelay                         =  2
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  500
ENT.Mass                             =  0
ENT.ArmDelay                         =  0.5
ENT.Timer                            =  0
ENT.RSound   						 =  1
ENT.JDAM							 =  false

ENT.DEFAULT_PHYSFORCE                = 500
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 500
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 5000
ENT.GBOWNER                          = nil

function ENT:PhysicsUpdate(ph)
	if not self.JDAM or not self.Armed then return end
	local pos = self:GetPos()
	local vel = self:WorldToLocal(pos+self:GetVelocity())*0.4
	vel.x = 0
	ph:AddAngleVelocity(
		ph:GetAngleVelocity()*-0.4
		+ Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1))*5
		+ Vector(0, -vel.z, vel.y)
	)
	local target = self.target:LocalToWorld(self.targetOffset)
	local dist = self:GetPos():Distance(target)
	
	local v = self:WorldToLocal(target + Vector(
		0, 0, math.Clamp((self:GetPos()*Vector(1,1,0)):Distance(target*Vector(1,1,0))/5 - 50, 0, 1000)
	)):GetNormal()
	v.y = math.Clamp(v.y*10,-1,1)*1000
	v.z = math.Clamp(v.z*10,-1,1)*1000
	ph:AddAngleVelocity(Vector(0,-v.z,v.y))
	ph:AddVelocity(self:GetForward() * 1 - self:LocalToWorld(vel*Vector(0.1, 1, 1))+pos)
end

function ENT:Initialize()
	if (SERVER) then
		self:LoadModel()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( ONOFF_USE )
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
		self.Used     = false
		self.Arming   = false
		
		if self.GBOWNER == nil then self.GBOWNER = self.Owner else self.Owner = self.GBOWNER end
		if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
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
end 

function ENT:LoadModel()
     if self.UseRandomModels then
	     self:SetModel(table.Random(Models))
	 else
	     self:SetModel(self.Model)
	 end
end

function ENT:AddOnExplode()
end

function ENT:Explode()
	if !self.Exploded then return end
	local pos = self:LocalToWorld(self:OBBCenter())
	self:AddOnExplode()
	local ent = ents.Create("shockwave_ent")
	ent:SetPos( pos ) 
	ent:Spawn()
	ent:Activate()
	ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
	ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
	ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("SHOCKWAVEDAMAGE",self.ExplosionDamage)
	ent:SetVar("MAX_RANGE",self.ExplosionRadius)
	ent:SetVar("SHOCKWAVE_INCREMENT",100)
	ent:SetVar("DELAY",0.01)
	ent.trace=self.TraceLength
	ent.decal=self.Decal
	
	
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
			if self.EffectWater == "ins_water_explosion" then
				ParticleEffect(self.EffectWater, tr2.HitPos, Angle(-90,0,0), nil)
			else
				ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)
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
			if self.AngEffect then
				ParticleEffect(self.Effect,pos,Angle(-90,0,0),nil)
				ParticleEffect("doi_ceilingDust_large",pos-Vector(0,0,100),Angle(0,0,0),nil) 
			else
				ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)
			end
		else 
			if self.AngEffect then
				ParticleEffect(self.EffectAir,pos,Angle(-90,0,0),nil) 
			else
				ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil)
			end
		end
    end
	 
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
     self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
	 exploDamage = dmginfo:IsDamageType(64)
	 if exploDamage == true then return end
     self:TakePhysicsDamage(dmginfo)
	 
	 local phys = self:GetPhysicsObject()
	 
     if (self.Life <= 0) then return end
	 if(GetConVar("gred_sv_fragility"):GetInt() >= 1) then
	     if(!self.Armed and !self.Arming) then
	         self:Arm()
	     end
	 end
	 
     if(!self.Armed) then return end

	 if self:IsValid() then
	     self.Life = self.Life - dmginfo:GetDamage()
		 if (self.Life <= self.Life/2) and !self.Exploded and self.Flamable then
		     self:Ignite(self.MaxDelay,0)
		 end
		 if (self.Life <= 0) then 
		     timer.Simple(math.Rand(0,self.MaxDelay),function()
			     if !self:IsValid() then return end 
			     self.Exploded = true
			     self:Explode()
			 end)
	     end
	end
end

function ENT:PhysicsCollide( data, physobj )
	timer.Simple(0,function()
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
		 if(GetConVar("gred_sv_fragility"):GetInt() >= 1) then
			 if(data.Speed > self.ImpactSpeed) then
				 if(!self.Armed and !self.Arming) then
					 self:EmitSound(damagesound)
					 self:Arm()
				 end
			 end
		 end
		 if(!self.Armed) then return end
		 if self.ShouldExplodeOnImpact then
			 if (data.Speed > self.ImpactSpeed ) then
				 self.Exploded = true
				 self:Explode()
			 end
		 end
	end)
end

function ENT:Arm()
    if(!self:IsValid()) then return end
	if(self.Exploded) then return end
	if(self.Armed) then return end
	self.Arming = true
	self.Used = true
	timer.Simple(self.ArmDelay, function()
	    if !self:IsValid() then return end 
	    self.Armed = true
		self.Arming = false
		self:EmitSound(self.ArmSound)
		if(self.Timed) or self.JDAM then
			if self.JDAM then self.Timer = 20 end
	        timer.Simple(self.Timer, function()
	            if !self:IsValid() then return end 
				timer.Simple(math.Rand(0,self.MaxDelay),function()
			        if !self:IsValid() then return end 
			        self.Exploded = true
			        self:Explode()
				end)
	        end)
	    end
	end)
end	 

function ENT:Use( activator, caller )
     if(self.Exploded) then return end
     if(self:IsValid()) then
	     if(GetConVar("gred_sv_easyuse"):GetInt() >= 1) then
	         if(!self.Armed) then
		         if(!self.Exploded) and (!self.Used) then
		             if(activator:IsPlayer()) then
                         self:EmitSound(self.ActivationSound)
                         self:Arm()
		             end
	             end
             end
         end
	 end
end

function ENT:OnRemove()
	 self:StopParticles()
	 --bombAir:Stop()
	-- Wire_Remove(self)
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
         duplicator.StorentityModifier(self,"WireDupeInfo",DupeInfo)
     end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
     if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
         Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
     end
end
