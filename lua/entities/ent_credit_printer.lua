---------------------------------------
--           TTT Freezer
--       Made for nsnf-clan.net
---------------------------------------

AddCSLuaFile( )

CreateConVar( "ttt_printer_maxcred",          3,  { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Defines amount of Printed credits." )
CreateConVar( "ttt_printer_printduration",    35, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Defiens Print duration." )

if ( CLIENT ) then

	ENT.Icon      = "vgui/ttt/icon_printer.png"
	ENT.PrintName = "Credit Printer"

end
 

ENT.Type           = "anim"
ENT.Model          = Model( "models/props_c17/consolebox01a.mdl" )
ENT.CanHavePrints  = true
ENT.MaxCredits     = GetConVar("ttt_printer_maxcred"):GetInt( )
ENT.PrintRate      = GetConVar("ttt_printer_printduration"):GetInt( )
ENT.PrintedCredits = 0


local printsound  = "ambient/levels/labs/equipment_printer_loop1.wav"
local pickupsound = "ttt/pickup.mp3"
local readysound  = "Buttons.snd4"


function ENT:SetupDataTables( )

	self:NetworkVar( "String",3,"CID" )
	self:NetworkVar( "Int", 2, "StoredCredits" )

end

function ENT:Initialize( )

	self:SetModel( self.Model )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_BBOX )

	self.sound = CreateSound( self, Sound( printsound ) )
	self.sound:SetSoundLevel( 70 )
	self.sound:PlayEx( 1, 100 )

	local b = 32

	self:SetCollisionBounds( Vector( -b, -b, -b ), Vector( b, b, b ) )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	if ( SERVER ) then

		local phys = self:GetPhysicsObject( )

		if (IsValid( phys ) ) then

			phys:SetMass( 40 )

		end

		self:SetColor( Color( 255, 0, 0, 255 ) )
		self.fingerprints = { self.Owner }
		self:SetHealth( 40 )
		self:SetCID( tostring(self:GetCreationID( ) ) )

	end

	timer.Create("Print" .. self:GetCID( ) , self.PrintRate, self.MaxCredits, function ( )

		if ( self:IsValid( ) and self ) then

			self:SetStoredCredits( self:GetStoredCredits() + 1  )
			self.PrintedCredits = self.PrintedCredits + 1 

			sound.Play( readysound, self:GetPos( ) )

			if( self.PrintedCredits == self.MaxCredits ) then

				self.sound:Stop( )

			end

		end

	end )

end


function ENT:Draw( )

	if ( SERVER ) then return end

	self:DrawModel( )
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	local t1  = "Credit Printer"
	local t2  = "Available Credit(s): " .. tostring( self:GetStoredCredits() )
	local t3  = "Loading: " .. tostring( math.Round( ( 100 - ( ( timer.TimeLeft("Print" .. self:GetCID( )) or 0 )  * 100 ) / self.PrintRate ), 0 ) )  .. "%"

	surface.SetFont( "Trebuchet24" ) 

	Ang:RotateAroundAxis( Ang:Up( ), 90 )
	
	cam.Start3D2D( Pos + Ang:Up( ) * 11.5, Ang, 0.11 )

	draw.WordBox(8, -surface.GetTextSize(t1) *0.5, -120, t1, "Trebuchet24", Color(0, 0, 0, 100), Color(255,255,255,255))
	draw.WordBox(8, -surface.GetTextSize(t2) *0.5,  0,   t2, "Trebuchet24", Color(0, 0, 0, 100), Color(255,255,255,255))
	draw.WordBox(8, -surface.GetTextSize(t3) *0.5,  50,  t3, "Trebuchet24", Color(0, 0, 0, 100), Color(255,255,255,255))

	cam.End3D2D( )

end


function ENT:Use( ply )

	if ( IsValid( ply ) and ply:IsPlayer( ) and ( ply:GetRole( ) == ROLE_TRAITOR or ply:GetRole( ) == ROLE_DETECTIVE ) ) then

		if ( self:GetStoredCredits( ) > 0 ) then
		
  			ply:AddCredits( self:GetStoredCredits( ) )
			sound.Play( pickupsound, self:GetPos( ) )
			self:SetStoredCredits( 0 )

			if( self.PrintedCredits == self.MaxCredits ) then

				self.sound:Stop( )

				timer.Simple(2, function( ) 

					if( self:IsValid( ) ) then

					self:Remove( )
					util.EquipmentDestroyed( self:GetPos( ) )

					end

				end )

			end

		end

	end

end

function ENT:OnTakeDamage( dmginfo )

	if ( dmginfo:GetAttacker( ) == self.Owner ) then return end
   
	self:TakePhysicsDamage( dmginfo )

	self:SetHealth( self:Health( ) - dmginfo:GetDamage( ) )

	if ( self:Health( ) < 0 ) then

			self:Remove( )
			self.sound:Stop( )
			util.EquipmentDestroyed( self:GetPos( ) )

	end

end
