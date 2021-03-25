-- Fig. 4e of
-- Victor Liu, Michelle Povinelli, and Shanhui Fan,
-- "Resonance-enhanced optical forces between coupled photonic crystal slabs",
-- Optics Express, Vol. 17, No. 24, 2009
-- The high-Q resonances are not fully resolved with the provided sampling.

S = S4.NewSimulation()
S:SetLattice({1,0}, {0,0}) -- 1D lattice
S:SetNumG(27)

-- Material definition
S:AddMaterial("Silicon", {12,0}) -- real and imag parts
S:AddMaterial("Vacuum", {1,0})

S:AddLayer(
	'AirAbove', --name
	0,          --thickness
	'Vacuum')   --background material
S:AddLayer('Slab', 0.5, 'Vacuum')
S:SetLayerPatternRectangle('Slab',        -- which layer to alter
                           'Silicon',     -- material in rectangle
	                       {0,0},         -- center
	                       0,             -- tilt angle (degrees)
	                       {0.25, 0.5}) -- half-widths
S:AddLayerCopy('Spacer', 0.5, 'AirAbove')
S:AddLayer('Slab2', 0.5, 'Vacuum')
S:SetLayerPatternRectangle('Slab2',       -- which layer to alter
                           'Silicon',     -- material in rectangle
	                       {0.15,0},      -- center
	                       0,             -- tilt angle (degrees)
	                       {0.25, 0.5}) -- half-widths
S:AddLayerCopy('AirBelow', 0, 'AirAbove')

-- E polarized along the grating "rods"
S:SetExcitationPlanewave(
	{0,0},  -- incidence angles (spherical coordinates: phi in [0,180], theta in [0,360])
	{0,0},  -- s-polarization amplitude and phase (in degrees)
	{1,0})  -- p-polarization amplitude and phase

for freq=0.25,0.7,0.001 do
	S:SetFrequency(freq)
	
	-- backward should be zero
	forward,backward = S:GetPoyntingFlux('AirBelow', -- layer in which to get
		                                 0)          -- z-offset

	print(freq .. '\t' .. forward);
end
