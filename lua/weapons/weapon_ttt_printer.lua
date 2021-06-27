---------------------------------------
--           TTT Freezer
--       Made for nsnf-clan.net
---------------------------------------

AddCSLuaFile( )

SWEP.HoldType               = "normal"

if ( CLIENT ) then

   SWEP.PrintName           = "Credit Printer"
   SWEP.Slot                = 6

   SWEP.ViewModelFOV        = 10
   SWEP.DrawCrosshair       = false

   SWEP.EquipMenuData = {

      type = "item_weapon",
      desc = "Break the law"

   };

   SWEP.Icon                = "vgui/ttt/icon_printer.png"

end

SWEP.Base                   = "weapon_tttbase"

SWEP.ViewModel              = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             = "models/props_c17/consolebox01a.mdl"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay          = 1.0

SWEP.Author                 = "Liverus"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 1.0

SWEP.Kind                   = WEAPON_EQUIP
SWEP.CanBuy                 = {ROLE_TRAITOR} 
SWEP.LimitedStock           = true 

SWEP.AllowDrop              = false
SWEP.NoSights               = true

function SWEP:OnDrop( )

   self:Remove( )

end

function SWEP:PrimaryAttack( )

   self:SetNextPrimaryFire( CurTime( ) + self.Primary.Delay )
   self:PrinterDrop( )

end

function SWEP:SecondaryAttack( )

   self:SetNextSecondaryFire( CurTime( ) + self.Secondary.Delay )
   self:PrinterDrop( )

end

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

function SWEP:PrinterDrop( )

   if ( SERVER ) then

      local ply  = self:GetOwner( )

      if not IsValid( ply ) then return end

      local vsrc   = ply:GetShootPos( )
      local vang   = ply:GetAimVector( )
      local vvel   = ply:GetVelocity( )
      local vthrow = vvel + vang * 200

      local printer = ents.Create( "ent_credit_printer" )

      if ( IsValid( printer ) ) then

         printer:SetPos( vsrc + vang * 10 )
         printer:Spawn( )
         printer:PhysWake( )

         local phys = printer:GetPhysicsObject( )

         if ( IsValid( phys ) ) then

            phys:SetVelocity( vthrow )

         end   

         self:Remove( )

      end

   end

   self:EmitSound( throwsound )

end


function SWEP:Reload( )

   return false

end

function SWEP:OnRemove( )

   if ( CLIENT and IsValid( self:GetOwner( ) ) and self:GetOwner( ) == LocalPlayer( ) and self:GetOwner( ):Alive( ) ) then

      RunConsoleCommand("lastinv")

   end

end

if ( CLIENT ) then

   function SWEP:Initialize( )

      return self.BaseClass.Initialize( self )

   end

end

function SWEP:Deploy( )

   if ( SERVER and IsValid( self:GetOwner( ) ) ) then

      self:GetOwner( ):DrawViewModel( false )

   end

   return true

end

function SWEP:DrawWorldModel( )
end

function SWEP:DrawWorldModelTranslucent( )
end

