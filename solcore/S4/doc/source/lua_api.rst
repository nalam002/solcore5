.. default-domain:: lua

.. _lua-api-label:

Lua API reference
=================

|S4| is built as a set of extensions to the `Lua scripting language <http://www.lua.org>`_.
Usage of |S4| involves writing a Lua script to call into various parts of |S4|.
Here we describe all of the |S4| specific functions that can be called within the Lua environment.

* `S4 library`_

  * :func:`~S4.NewSimulation`
  * :func:`~S4.NewSpectrumSampler`
  * :func:`~S4.NewInterpolator`
  * :func:`~S4.SolveInParallel`
  * :func:`~S4.ConvertUnits`
  * :func:`~S4.Integrate`
  * :data:`~S4.arg`
  * :data:`~S4.MPIRank`
  * :data:`~S4.MPISize`

* `Simulation object`_

  * `Parameter specification`_
  
    * :func:`~S4.Simulation:SetLattice`
    * :func:`~S4.Simulation:SetNumG`
    * :func:`~S4.Simulation:AddMaterial`
    * :func:`~S4.Simulation:SetMaterial`
    * :func:`~S4.Simulation:AddLayer`
    * :func:`~S4.Simulation:SetLayer`
    * :func:`~S4.Simulation:SetLayerThickness`
    * :func:`~S4.Simulation:AddLayerCopy`
    * :func:`~S4.Simulation:SetLayerPatternCircle`
    * :func:`~S4.Simulation:SetLayerPatternEllipse`
    * :func:`~S4.Simulation:SetLayerPatternPolygon`
    * :func:`~S4.Simulation:SetExcitationPlanewave`
    * :func:`~S4.Simulation:SetExcitationExterior`
    * :func:`~S4.Simulation:SetFrequency`
  
  * `Outputs requiring no solutions`_
  
    * :func:`~S4.Simulation:GetReciprocalLattice`
    * :func:`~S4.Simulation:GetEpsilon`
    * :func:`~S4.Simulation:OutputLayerPatternDescription`
    * :func:`~S4.Simulation:OutputLayerPatternRealization`
	
  * `Outputs requiring solutions`_
	
    * :func:`~S4.Simulation:OutputStructurePOVRay`
    * :func:`~S4.Simulation:GetNumG`
    * :func:`~S4.Simulation:GetGList`
    * :func:`~S4.Simulation:GetDiffractionOrder`
    * :func:`~S4.Simulation:GetAmplitudes`
    * :func:`~S4.Simulation:GetPowerFlux`
    * :func:`~S4.Simulation:GetPowerFluxByOrder`
    * :func:`~S4.Simulation:GetStressTensorIntegral`
    * :func:`~S4.Simulation:GetLayerEnergyDensityIntegral`
    * :func:`~S4.Simulation:GetLayerElectricEnergyDensityIntegral`
    * :func:`~S4.Simulation:GetLayerMagneticEnergyDensityIntegral`
    * :func:`~S4.Simulation:GetLayerElectricFieldIntensityIntegral`
    * :func:`~S4.Simulation:GetLayerZIntegral`
    * :func:`~S4.Simulation:GetEField`
    * :func:`~S4.Simulation:GetHField`
    * :func:`~S4.Simulation:GetFields`
    * :func:`~S4.Simulation:GetFieldPlane`
    * :func:`~S4.Simulation:GetSMatrixDeterminant`
	
  * `Options`_
	
    * :func:`~S4.Simulation:UseLanczosSmoothing`
    * :func:`~S4.Simulation:UseDiscretizedEpsilon`
    * :func:`~S4.Simulation:UsePolarizationDecomposition`
    * :func:`~S4.Simulation:UseSubpixelSmoothing`
    * :func:`~S4.Simulation:UseJonesVectorBasis`
    * :func:`~S4.Simulation:UseNormalVectorBasis`
    * :func:`~S4.Simulation:SetResolution`
    * :func:`~S4.Simulation:SetBasisFieldDumpPrefix`
    * :func:`~S4.Simulation:SetLatticeTruncation`
    * :func:`~S4.Simulation:SetVerbosity`
    * :func:`~S4.Simulation:UseLessMemory`
	
  * `Miscellaneous`_
	
    * :func:`~S4.Simulation:Clone`
   
S4 library
----------

.. module:: S4

All top level functions of |S4| are located in the ``S4`` library.
These functions mainly return objects which can be manipulated to obtain desired results.

.. function:: NewSimulation()

   Returns a new blank `Simulation object`_.

   Usage::
   
    S = S4.NewSimulation()

   Arguments:

    None.

   Return values:

    S
        A new `Simulation object`_.

.. function:: NewSpectrumSampler(f_start, f_end, options)

   Returns a new `SpectrumSampler object`_.

   Usage::

    sampler = S4.NewSpectrumSampler(f_start, f_end, options)

   Arguments:

    f_start, f_end
        (number) Starting and ending frequencies of the frequency range in which to sample.
    options
        (table) A table of options controlling the sampling behavior. The keys and expected values are described below. If any option is not specified, the default value is used. Any out-of-range values are clamped to the valid range.
    InitialNumPoints
        (integer) The initial number of (uniformly spaced) sample points to use. If this value is not large enough, fine features may be missed. The default is 33.
    RangeThreshold
        (number) The threshold below which the difference between adjacent result values will not cause an interval to be subdivided. The default is 0.001.
    MaxBend
        (number) The cosine of the maximum bend angle of the normalized angle between adjacent segments.
        For angles larger than the maximum bend angle, one of the adjacent intervals is subdivided.
        The default bend angle is 10 degrees.
    MinimumSpacing
        (number) The relative frequency space (relative to the sampling interval size) below which subdivision will not occur. The default is 1e-6.
    Parallelize
        (boolean) Allows multiple frequency points to be solved in parallel. This option affects which methods can be called for a SpectrumSampler object. The default is false.

   Return values:

    sampler
        A new `SpectrumSampler object`_.

.. function:: NewInterpolator(type, table)

   Returns a new `Interpolator object`_.

   Usage::

    interpolator = S4.NewInterpolator('type', {
      {x1, {y1_1, y1_2, ... }},
      {x2, {y2_1, y2_2, ... }},
      ...
    })

   Arguments:

    type
        (string) Type of interpolation to use.
        
        'linear'
            Performs linear interpolation (and extrapolation) between values.
        'cubic hermite spline'
            Uses a cubic Hermite spline interpolation with Kochanek-Bartels tangents (really just a Catmull-Rom spline).
    
    table
        The second argument should be a table of tables.
        Each subtable should have as its first element the abscissa of a data sample, and the second element should be a table of all the ordinate values.
        The ordinate ordering is clearly important, and only the number of ordinate values for the first abscissa value determines the assumed number of ordinate values for the remaining abscissae.

   Return values:

    interpolator
        A new `Interpolator object`_.

.. function:: SolveInParallel(layername, ...)

   Forces the computation of a layer solution for several simulation objects in parallel.
   When compiled without thread support, the computations are done serially.

   Usage::

    S4.SolveInParallel('layer', Sa, Sb, ...)

   Arguments:

    layer
        (string) The name of the layer for which solutions should be computed. If the simulation objects do not have layer matching the provided name, then no solve is performed for that object.
    Sa, Sb, ...
        (Simulation object) The set of Simulation objects for which solutions are computed. It is useful to use the :func:`Clone` method to make copies.
        
   Return values:

    None.

.. function:: ConvertUnits(value, from_units, to_units)

   Performs unit conversions.

   Usage::

    S4.ConvertUnits(value, from_units, to_units)

   Arguments:

    value=
        (number) The value to convert.
    from_units, to_units
        (string) The units in which `value` is currently expressed, and the desired units.
        Currently supported units:
        
            Lengths: "um", "nm", "m", "cm", "mm"
            Energies: "eV", "J"
            Frequencies: "THz", "GHz", "Hz", "rad/s"
        
   Return values:

    The converted value, or nil if no conversion was possible.

.. function:: Integrate(func, range1, range2, ..., opts)

   Performs adaptive numerical integration in an arbitrary number of dimensions.

   Usage::

    integral,error = S4.Integrate(func, range1, range2, ..., opts)

   Arguments:

    func
        (function) The function to integrate. It should take a number of arguments matching the number of range parameters passed in (the number of independent variables), and return a single number.
    range1, range2, ...
        (table) Each table should contain two elements corresponding to lower and upper limits of integration for the corresponding variable.
    opts
        (table) Options to the integration routine. This table is distinguished from an integration limit range by the presence of string keys. The options are:
        
        MaxEval
            (integer) Default is 1000000. Places an upper limit on the number of function evaluations allowed.
        AbsoluteError
            (number) Default is 0. Sets the termination criterion for the absolute error in the integral.
        RelativeError
            (number) Default is 1e-6. Sets the termination criterion for the relative error in the integral.
        Parallelize
            (boolean) Default is false. If true, the integrand may be evaluated in parallel. In this case, the function must accept an integer as the first argument corresponding to the number of evaluations required, and subsequent parameters are tables containing the set of independent variables for each evaluation. The function should then return a table containg all the results in the same order.
        
   Return values:

    Returns the integrated value and an estimate of the error.

.. data:: arg

   When used with the `-a` switch, the value of ``S4.arg`` is set to the command line switch argument.
   This is a convenient way of passing command line arguments to S4 scripts, or in parallel environments for specifying machine IDs.

   When no command line switch is specified, ``S4.arg`` is nil.

   Multiple variables may be passed in by passing in multiple Lua statements::

    ./S4 -a "a=1;b=2;c=3" input.lua

   Then within the script, the variables may be set with the statement::

    pcall(loadstring(S4.arg))


.. data:: MPIRank

   On a version of S4 with MPI support, gives the MPI machine rank (0-based index of processor node). For versions without MPI support, this is always 0.

.. data:: MPISize

   On a version of S4 with MPI support, gives the MPI size (total number of processor nodes). For versions without MPI support, this is always 1.

Simulation object
-----------------

.. class:: Simulation

   The Simulation object is the primary object which computes solutions to systems.
   When a new Simulation object is requested from :func:`NewSimulation`, all settings are in a blank state, with no materals, layers, or excitation.
   When solutions are requested, only a minimal set of internal computations are performed in order to satisfy the request.


Parameter specification
^^^^^^^^^^^^^^^^^^^^^^^

.. method:: Simulation:SetLattice(L)
            Simulation:SetLattice({x1,y1}, {x2,y2})

   Sets the real-space lattice vectors.

   Usage::

    S:SetLattice(L)
    S:SetLattice({x1,y1}, {x2,y2})

   Arguments:

    This function can take a single numeric argument, which sets the period for a 1D lattice.
    This function can also take two table arguments, each of which must have two numeric elements.
    The first table specifies the x- and y-coordinates of the first lattice basis vector, while the second table specifies the second basis vector. The basis vectors should have positive orientation (the cross product of the first with the second should yield a vector with positive z-coordinate).

   Return values:

    None

.. method:: Simulation:SetNumG(n)

    Sets the maximum number of in-plane (x and y) Fourier expansion orders to use.
    All fields and eigenmodes of the system use the same Fourier basis of the same dimension.

    The computation time is roughly proportional to the cube of this number, and the memory usage is roughly proportional to the square.

   Usage::

    S:SetNumG(n)

   Arguments:

    n
        (integer) The desired maximum number of Fourier orders to use. This number is an upper bound because internally, the Fourier lattice k-vectors (referred to as the G-vectors) are found in a symmetry-preserving manner starting from the origin and retaining those of shortest length. To obtain the actual number of Fourier orders used, use :func:`GetNumG`.

   Return values:

    None

.. method:: Simulation:AddMaterial(name, {eps_r, eps_i})
            Simulation:AddMaterial(name, eps_tensor)

    Adds a new material with a specified dielectric constant.

   Usage::

    S:AddMaterial(name, {eps_r, eps_i})
    S:AddMaterial(name, {
        {xx_r, xx_i}, {xy_r, xy_i}, {xz_r, xz_i},
        {yx_r, yx_i}, {yy_r, yy_i}, {yz_r, yz_i},
        {zx_r, zx_i}, {zy_r, zy_i}, {zz_r, zz_i}
        })

   Arguments:

    name
        (string) The name of the material. Each material must have a unique name.
    eps_r, eps_r
        (number) The real and imaginary parts of the relative permittivity of the material. The imaginary part should be positive.
    xx_r, xx_i, xy_r, ...
        (number) Components of the relative permittivity tensor of the material. Currently the xz, yz, zx, and zy components are ignored and assumed to be zero.

   Return values:

    None

.. method:: Simulation:SetMaterial(name, {eps_r, eps_i})
            Simulation:SetMaterial(name, eps_tensor)

    Updates an existing material with a new dielectric constant or adds a material if none exists.

   Usage::

    S:SetMaterial(name, {eps_r, eps_i})
    S:SetMaterial(name, {
        {xx_r, xx_i}, {xy_r, xy_i}, {xz_r, xz_i},
        {yx_r, yx_i}, {yy_r, yy_i}, {yz_r, yz_i},
        {zx_r, zx_i}, {zy_r, zy_i}, {zz_r, zz_i}
        })

   Arguments:

    name
        (string) The name of the material to update, or the name of a new material if no material by that name exists.
    eps_r, eps_r
        (number) The real and imaginary parts of the relative permittivity of the material. The imaginary part should be positive.
    xx_r, xx_i, xy_r, ...
        (number) Components of the relative permittivity tensor of the material. Currently the xz, yz, zx, and zy components are ignored and assumed to be zero.

   Return values:

    None

.. method:: Simulation:AddLayer(name, thickness, material)

    Adds a new unpatterned layer with a specified thickness and material.

   Usage::

    S:AddLayer(name, thickness, material)

   Arguments:

    name
        (string) The name of the layer. Each layer must have a unique name.
    thickness
        (number) The thickness of the layer.
    material
        (string) The name of the material which comprises the layer. With patterning, this is the default (background) material of the layer.

   Return values:

    None

.. method:: Simulation:SetLayer(name, thickness, material)

    Updates an existing layer with a new thickness and removes all layer patterning.
    If no matching layer is found, adds a new unpatterned layer with a specified thickness and material.
    The behavior is undefined if the new material does not match the old material during an update (currently, the new material is ignored, but this may change in the future).
    If only the thickness needs to be modified, use :func:`SetLayerThickness`.

   Usage::

    S:SetLayer(name, thickness, material)

   Arguments:

    name
        (string) The name of the layer to update. If no layer by that name exists, a new layer is created with this name.
    thickness
        (number) The new thickness of the layer.
    material
        (string) The name of the material which comprises the layer.

   Return values:

    None

.. method:: Simulation:SetLayerThickness(name, thickness)

    Updates an existing layer with a new thickness.
    Previously cached layer eigenmodes are preserved, making this function the preferred way to update a layer's thickness.

   Usage::

    S:SetLayerThickness(name, thickness)

   Arguments:

    name
        (string) The name of the layer to update.
    thickness
        (number) The new thickness of the layer.

   Return values:

    None

.. method:: Simulation:AddLayerCopy(name, thickness, original_name)

    Adds a new layer with a specified thickness, but identical patterning as another existing layer.
    Note that this merely creates a reference to the copied layer; further patterning of the copied layer also affects the new layer. Additionally, a copy of a copy cannot be made.

   Usage::

    S:AddLayerCopy(name, thickness, original_name)

   Arguments:

    name
        (string) The name of the new layer, different from the layer being copied.
    thickness
        (number) The thickness of the new layer.
    original_name
        (string) The name of the layer which whose pattern is to be copied. That layer cannot itself be a copy of a layer.

   Return values:

    None

.. method:: Simulation:SetLayerPatternCircle(layer, material, center, radius)

    Adds a (filled) circle of a specified material to an existing non-copy layer.
    The circle should not intersect any other patterning shapes, but may contain or be contained within other shapes.

   Usage::

    S:SetLayerPatternCircle(layer, material, center, radius)

   Arguments:

    layer
        (string) The name of the layer to pattern. This layer cannot be a copy of another layer.
    material
        (string) The name of the material which fills the interior of the circle.
    center
        (numeric table, length 2) x- and y-coordinates of the center of the circle relative to the center of the unit cell (the origin).
    radius
        (number) Radius of the circle.

   Return values:

    None

.. method:: Simulation:SetLayerPatternEllipse(layer, material, center, angle, halfwidths)

    Adds a (filled) ellipse of a specified material to an existing non-copy layer.
    The ellipse should not intersect any other patterning shapes, but may contain or be contained within other shapes.

   Usage::

    S:SetLayerPatternEllipse(layer, material, center, angle, halfwidths)

   Arguments:

    layer
        (string) The name of the layer to pattern. This layer cannot be a copy of another layer.
    material
        (string) The name of the material which fills the interior of the ellipse.
    center
        (numeric table, length 2) x- and y-coordinates of the center of the ellipse relative to the center of the unit cell (the origin).
    angle
        (number) The angle (in degrees) by which the x-axis of the ellipse should be rotated (CCW).
    halfwidths
        (numeric table, length 2) The lengths of the semi-major axes of the ellipse. For an angle of 0, the first length is the semi-major axis in the x-direction, and the second length is the semi-major axis in the y-direction.

   Return values:

    None

.. method:: Simulation:SetLayerPatternRectangle(layer, material, center, angle, halfwidths)

    Adds a (filled) rectangle of a specified material to an existing non-copy layer.
    The rectangle should not intersect any other patterning shapes, but may contain or be contained within other shapes.

   Usage::

    S:SetLayerPatternRectangle(layer, material, center, angle, halfwidths)

   Arguments:

    layer
        (string) The name of the layer to pattern. This layer cannot be a copy of another layer.
    material
        (string) The name of the material which fills the interior of the rectangle.
    center
        (numeric table, length 2) x- and y-coordinates of the center of the rectangle relative to the center of the unit cell (the origin).
    angle
        (number) The angle (in degrees) by which the x-axis of the rectangle should be rotated (CCW).
    halfwidths
        (numeric table, length 2) The half-widths of the rectangle. For an angle of 0, the first length is half the width of the rectangle in the x-direction, and the second length is half the height in the y-direction.

   Return values:

    None


.. method:: Simulation:SetLayerPatternPolygon(layer, material, center, angle, vertices)

    Adds a (filled) polygon of a specified material to an existing non-copy layer.
    The polygon should not self-intersect nor intersect any other patterning shapes, but may contain or be contained within other shapes. The polygon must also be specified with positive orientation (the vertices circle CCW about an interior point).

   Usage::

    S:SetLayerPatternPolygon(layer, material, center, angle, vertices)

   Arguments:

    layer
        (string) The name of the layer to pattern. This layer cannot be a copy of another layer.
    material
        (string) The name of the material which fills the interior of the polygon.
    center
        (numeric table, length 2) x- and y-coordinates of the center of the polygon relative to the center of the unit cell (the origin).
    angle
        (number) The angle (in degrees) by which the polygon should be rotated (CCW).
    vertices
        (numeric table, length 2*vertex_count) The x- and y-coordinates of the vertices of the (unrotated) polygon, one after another.
        Thus, ``vertices[1]`` is the x-coordinate of the first vertex and ``vertices[2]`` is its y-coordinate, and ``vertices[3]`` is the x-coordinate of the second vertex, etc.

   Return values:

    None


.. method:: Simulation:SetExcitationPlanewave({phi,theta}, {s_amp, s_phase}, {p_amp, p_phase}, order)

    Sets the excitation to be a planewave incident upon the front (first layer specified) of the structure.
    If both tilt angles are specified to be zero, then the planewave is normally incident with the electric field polarized along the x-axis for the p-polarization.
    The phase of each polarization is defined at the origin (z = 0).

   Usage::

    S:SetExcitationPlanewave({phi,theta}, {s_amp, s_phase}, {p_amp, p_phase}, order)

   Arguments:

    phi, theta
        (number) Angles in degrees. ``phi`` and ``theta`` give the spherical coordinate angles of the planewave k-vector.
        For zero angles, the k-vector is assumed to be (0, 0, kz), while the electric field is assumed to be (0, -E0, 0), and the magnetic field is in (H0, 0, 0).
        The angle ``phi`` specifies first the angle by which the E,H,k frame should be rotated (CW) about the y-axis, and the angle ``theta`` specifies next the angle by which the E,H,k frame should be rotated (CCW) about the z-axis. Note the different directions of rotations for each angle.
    s_amp, p_amp
        (number) The electric field amplitude of the s- and p-polarizations of the planewave.
    s_phase, p_phase
        (number) The phase of the s- and p-polarizations of the planewave, relative to z = 0 (the beginning of the first layer).
    order
        (number) An optional positive integer specifying which order (mode index) to excite. Defaults to 1. This is the same index that GetDiffractionOrder returns.

   Return values:

    None

.. method:: Simulation:SetExcitationExterior(table)

    Low level function to set excitations by a superposition of incident modes of the exterior layers. For unpatterned layers, the incident modes are forward propagating planewaves in the front, and backward propagating planewaves in the back.

   Usage::

    S:SetExcitationExterior{
        { G-index, pol, { amp-re, amp-im } },
        ...
    }

   Arguments:

    G-index
        (number) Index of the mode. This is the same index that GetDiffractionOrder returns.
    pol
        (string) Either 'x' or 'y' for the polarization of the electric field in unpatterned layers. (See :func:`GetAmplitudes` below for what the two polarizations are more precisely.)
    amp-re, amp-im
        (number) Real and imaginary parts of the amplitude coefficient for the mode.

   Return values:

    None

.. method:: Simulation:SetFrequency(freqr, freqi = 0)

    Sets the operating frequency of the system (and excitation).

   Usage::

    S:SetFrequency(freqr, freqi)

   Arguments:

    freqr
        (number) The (real) frequency of the excitation. This is not the angular frequency (the angular frequency is 2pi times of this).
    freqi
        (number) The imaginary frequency of the system. This parameter is typically not specified and assumed to be zero. When specified (typically for mode solving), this parameter should be negative for a physical (decaying in time) system.

   Return values:

    None

Outputs requiring no solutions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. method:: Simulation:GetReciprocalLattice()

    Retrieves the reciprocal lattice basis vectors.
    The vectors lack the scaling by 2pi (multiply them by 2pi to obtain the true reciprocal lattice basis vectors).

   Usage::

    Gu,Gv = S:GetReciprocalLattice()

   Arguments:

    None.

   Return values:

    Gu, Gv
        The first and second reciprocal lattice basis vectors.
        Their relative geometric orientation is the same as the lattice specified with :func:`SetLattice`.
        Each vector is a table of length 2, holding the x- and y-coordinates of the vector.


.. method:: Simulation:GetEpsilon({x, y, z})

    Retrieves the dielectric constant at a particular point in the system by reconstructing the Fourier series using the G-vectors of the system.

    Note that this reconstruction is not representative of the actual dielectric constant profile used in simulations (such a notion is not meaningful). The reconstruction is created using the closed-form Fourier series coefficients of the specified patterning, summed over the terms comprising the G-vector list obtained from lattice truncation. This function exists to provide an intuitive sense for the spatial resolution of a particular G-vector truncation order.

   Usage::

    eps_r, eps_i = S:GetEpsilon({x, y, z})

   Arguments:

    x, y, z
        (number) The coordinates of the point at which to retrieve the dielectric constant.

   Return values:

    eps_r, eps_i
        The real and imaginary parts of the dielectric constant.

.. method:: Simulation:OutputLayerPatternDescription(name, filename)

    Outputs a list of PostScript commands to render the exact layer pattern description from the specified patterning commands. Assumes letter-sized paper.

   Usage::

    S:OutputLayerPatternDescription(name, filename)

   Arguments:

    name
        (string) Name of the layer whose pattern description should be output.
    filename
        (string, optional) Filename to which the description should be output. If this argument is not provided, standard output is used.

   Return values:

    None.

.. method:: Simulation:OutputLayerPatternRealization(name, Nu, Nv, filename)

    Outputs a Gnuplot format dump of the Fourier series reconstruction of the dielectric constant in the unit cell. Note that the output will appear distorted for non-orthogonal unit cells.

    Note that this reconstruction is not representative of the actual dielectric constant profile used in simulations (such a notion is not meaningful). The reconstruction is created using the closed-form Fourier series coefficients of the specified patterning, summed over the terms comprising the G-vector list obtained from lattice truncation. This function exists to provide an intuitive sense for the spatial resolution of a particular G-vector truncation order.

   Usage:

    S:OutputLayerPatternRealization(name, Nu, Nv, filename)

   Arguments:

    name
        The name of the layer whose pattern should be output.
    Nu, Nv
        The number of discretization cells in the first and second lattice basis direction to use. The total number of output points is ``Nu*Nv``.
    filename
        (string, optional) Filename to which the pattern should be output. If this argument is not provided, standard output is used.

   Return values:

    None.

Outputs requiring solutions
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. method:: Simulation:OutputStructurePOVRay([filename])

    Outputs a `POV-Ray <http://www.povray.org>`_ script that will render one unit cell of the structure in 3D. Materials named ``air`` or ``vacuum`` (case insensitive) will be completely transparent.

   Usage::

    S:OutputStructurePOVRay(filename)

   Arguments:

    filename
        (string, optional) Filename to which the structure should be output. If this argument is not provided, standard output is used.

   Return values

    None.

.. method:: Simulation:GetNumG()

    Returns the specified number of Fourier series orders to use (number of G-vectors), or, if a solution has been computed, the actual number of G-vectors used.

   Usage::

    n = S:GetNumG()

   Arguments:

    None.

   Return values:

    n
        If no solutions have been computed, the upper bound of G-vectors specified. If a solution has been computed, then ``n`` is the actual number of G-vectors used.

.. method:: Simulation:GetGList()

    Returns a table of reciprocal lattice coordinates of the Fourier series orders used.
    The coordinates are in the reciprocal lattice basis, and so they are integers.

   Usage::

    G = S:GetGList()

   Arguments:

    None.

   Return values:

    G
        A table of tables of length 2 holding the pairs of integer recprical lattice coordinates.


.. method:: Simulation:GetDiffractionOrder(m, n)

    Returns the index (1-based) of a particular diffraction order. 
    The index can be used directly in GetPowerFluxByOrder to obtain the diffracted power of a particular order.
    The coordinate arguments are in the reciprocal lattice basis, and so they are integers.
    A particular diffraction order is only a meaningful concept in a uniform (unpatterned) layer, otherwise the diffraction order corresponds to an arbitrary layer eigenfunction index.

   Usage::

    i = S:GetDiffractionOrder(m, n)

   Arguments:

    m, n
        (integer) The diffracted order. These numbers are in the reciprocal lattice basis.

   Return values:

    i
        The index of the diffraction order.
    
.. method:: Simulation:GetAmplitudes(layer, offset)

    Returns the raw mode amplitudes within a particular layer.
    For uniform (unpatterned) layers, the modes are simply the diffracted orders, and the indexing of the returned amplitudes corresponds to the value obtained from GetDiffractedOrder.
    The first value is guaranteed to be the straight transmitted or specularly reflected diffraction order.
    For patterned layers, there is typically no meaningful information in these amplitudes.

   Usage::

    forw,back = S:GetAmplitudes(layer, offset)

   Arguments:

    layer
        (string) The name of the layer in which to obtain mode amplitudes.
    offset
        (number) The z-offset at which to obtain the mode amplitudes.

   Return values:

    forw,back
        Tables of length 2*NumG containing the complex amplitudes of each forward and backward mode. Each complex amplitude is a table of length 2 containing real and imaginary parts.
        For uniform (unpatterned) layers, the amplitudes have the following interpretation. (Warning: You should double-check this using :func:`GetFields`.)
        If a certain grating order n has k-vector (kx,ky,kz), then the contribution of that order to H is a*(1,0,-kx/kz) + b*(0,1,-ky/kz), where a is the complex number
        forw[n] (or back[n]) and b is the complex number forw[n + NumG] (or back[n + NumG]). The contribution to E is the cross product of the above with (kx,ky,kz)/\|k\|, divided by
        the refractive index. Note that the two polarizations are *not* orthogonal to each other when both kx and ky are nonzero. Note also that the vectors (1,0,-kx/kz) and (0,1,-ky/kz)
        are not normalized, so the amplitude of an order is not numerically equal to the magnitude of the electric field it creates, even with refractive index 1.


.. method:: Simulation:GetPowerFlux(layer, offset=0)

    Returns the integral of the power (Poynting) flux density over a unit cell surface normal to the z-direction.
    In other words, the z-component of the power flux is returned.

   Usage::

    forw_r, back_r, forw_i, back_i = S:GetPowerFlux(layer, offset)

   Arguments:

    layer
        (string) The name of the layer in which the integration surface lies.
    offset
        (number, optional) The z-offset of the integration surface from the beginning of the layer. This only matters for lossy layers.

   Return values:

    forw_r, forw_i
        The real and imaginary parts of the forward component of the complex Poynting vector. Note that the result is not time averaged (no factor of 0.5 multiplied in). The forward component is defined as (E_total^* x H_forw + H_total^* x E_forw) / 2, where E_forw and H_forw are the fields reconstructed from only the forward propagating waveguide modes of the layer.
    back_r, back_i
        The real and imaginary parts of the backward component of the complex Poynting vector. Note that the result is not time averaged (no factor of 0.5 multiplied in). An analogous definition of the backward component of the Poynting vector follows from above.

.. method:: Simulation:GetPowerFluxByOrder(layer, offset)

    Returns the integral of the power (Poynting) flux density over a unit cell surface normal to the z-direction for each Fourier series order.
    In other words, the z-component of the Poynting flux for each order is returned.

   Usage::

    P = S:GetPowerFluxByOrder(layer, offset)

   Arguments:

    layer
        (string) The name of the layer in which the integration surface lies.
    offset
        (number) The z-offset of the integration surface from the beginning of the layer. This only matters for lossy layers.

   Return values:

    P
        A table with length equal to the number of Fourier series orders used.
        Each entry of the table is a table of length 4, whose values are: forw_r, back_r, forw_i, back_i.
        These four quantities are described in the section for :func:`GetPowerFlux`.


.. method:: Simulation:GetStressTensorIntegral(layer, offset)

    Returns the integral of the electromagnetic stress tensor over a unit cell surface normal to the z-direction.

   Usage::

    Txr, Tyr, Tzr, Txi, Tyi, Tzi = S:GetStressTensorIntegral(layer, offset)

   Arguments:

    layer
        (string) The name of the layer in which the integration surface lies.
    offset
        (number) The z-offset of the integration surface from the beginning of the layer.

   Return values:

    Txr, Txi
        The real and imaginary parts of the x-component of the stress tensor integrated over the specified surface, assuming a unit normal vector in the +z direction. Note that the result is not time averaged (no factor of 0.5 multiplied in).
    Tyr, Tyi, Tzr, Tzi
        Analogous to above.


.. method:: Simulation:GetLayerEnergyDensityIntegral(layer)

    Returns the volume integral of the electromagnetic energy density (epsilon*\|E\|^2 + \|H\|^2) over a unit cell throughout the entire thickness of a layer.

   Usage::

    Ur,Ui = S:GetLayerEnergyDensityIntegral(layer)

   Arguments:

    layer
        (string) The name of the layer in which to integrate over.

   Return values:

    Ur,Ui
        The real and imaginary parts of the integral of the energy density throughout the volume of the layer's unit cell. Note that the result is not time averaged (no factor of 0.5 multiplied in).


.. method:: Simulation:GetLayerElectricEnergyDensityIntegral(layer)

    Returns the volume integral of the electric energy density (epsilon*\|E\|^2) over a unit cell throughout the entire thickness of a layer.

   Usage::

    Ur,Ui = S:GetLayerElectricEnergyDensityIntegral(layer)

   Arguments:

    layer
        (string) The name of the layer in which to integrate over.

   Return values:

    U
        The real and imaginary parts of the integral of the electric energy density throughout the volume of the layer's unit cell. Note that the result is not time averaged (no factor of 0.5 multiplied in).


.. method:: Simulation:GetLayerMagneticEnergyDensityIntegral(layer)

    Returns the volume integral of the magnetic energy density (\|H\|^2) over a unit cell throughout the entire thickness of a layer.

   Usage::

    Ur,Ui = S:GetLayerMagneticEnergyDensityIntegral(layer)

   Arguments:

    layer
        (string) The name of the layer in which to integrate over.

   Return values:

    Ur,Ui
        The real and imaginary parts of the integral of the magnetic energy density throughout the volume of the layer's unit cell. Note that the result is not time averaged (no factor of 0.5 multiplied in).


.. method:: Simulation:GetLayerElectricFieldIntensityIntegral(layer)

    Returns the volume integral of the squared electric field intensity (\|E\|^2) over a unit cell throughout the entire thickness of a layer.

   Usage::

    Ur,Ui = S:GetLayerElectricFieldIntensityIntegral(layer)

   Arguments:

    layer
        (string) The name of the layer in which to integrate over.

   Return values:

    Ur,Ui
        The real and imaginary parts of the integral of the square electric field intensity throughout the volume of the layer's unit cell. Note that the result is not time averaged (no factor of 0.5 multiplied in).

.. method:: Simulation:GetLayerZIntegral(layer, {x, y})

	Returns the line integral along z (depth direction) of the squared magnitudes of electric and magnetic field components (\|Ex\|^2, \|Ey\|^2, etc.) throughout the entire thickness of a layer.

   Usage::

    IEx, IEy, IEz, IHx, IHy, IHz = S:GetLayerZIntegral(layer, {x, y})

   Arguments:

    layer
        (string) The name of the layer in which to integrate through.
    x,y
        (number) The in-plane coordinates at which to integrate.

   Return values:

    IEx,IEy,IEz,IHx,IHy,IHz
        The integral of the squared magnitudes of electric and magnetic field components throughout the thickness of the layer. Note that the result is not time averaged (no factor of 0.5 multiplied in).


.. method:: Simulation:GetEField({x, y, z})

    Returns the electric field at a particular point within the structure.

   Usage::

    Exr, Eyr, Ezr, Exi, Eyi, Ezi = S:GetEField({x, y, z})

   Arguments:

    x, y, z
        (number) The coordinates of the point at which to obtain the field.

   Return values:

    Exr, Exi
        The real and imaginary parts of the complex electric field at the specified point. Note that the result is not time averaged (no factor of 0.5 multiplied in).
    Eyr, Eyi, Ezr, Ezi
        Analogous to above.

.. method:: Simulation:GetHField({x, y, z})

    Returns the magnetic field at a particular point within the structure.

   Usage::

    Hxr, Hyr, Hzr, Hxi, Hyi, Hzi = S:GetHField({x, y, z})

   Arguments:

    x, y, z
        (number) The coordinates of the point at which to obtain the field.

   Return values:

    Hxr, Hxi
        The real and imaginary parts of the complex magnetic field at the specified point. Note that the result is not time averaged (no factor of 0.5 multiplied in).
    Hyr, Hyi, Hzr, Hzi
        Analogous to above.

.. method:: Simulation:GetFields({x, y, z})

    Returns the electric and magnetic field at a particular point within the structure.
    Note that it is more efficient to call this function when both fields are needed.

   Usage::

    Exr, Eyr, Ezr, Hxr, Hyr, Hzr, Exi, Eyi, Ezi, Hxi, Hyi, Hzi = S:GetFields({x, y, z})

   Arguments:

    x, y, z
        (number) The coordinates of the point at which to obtain the field.

   Return values:

    Exr, Exi
        The real and imaginary parts of the complex electric field at the specified point. Note that the result is not time averaged (no factor of 0.5 multiplied in).
    Eyr, Eyi, Ezr, Ezi, Hxr, Hxi, Hyr, Hyi, Hzr, Hzi
        Analogous to above.

.. method:: Simulation:GetFieldPlane(z, {nu, nv}, format, basefilename)

    Returns the electric and magnetic fields on a regular grid over the unit cell (fundamental parallelogram) at a particular z coordinate.
    It is more efficient to use this function than :func:`GetFields`.

   Usage::

    E,H = S:GetFieldPlane(z, {nu, nv}, 'Array')
    S:GetFieldPlane(z, {nu, nv}, 'FileWrite', basename)
    S:GetFieldPlane(z, {nu, nv}, 'FileAppend', basename)

   Arguments:

    z
        (number) The z-coordinate of the plane on which to obtain the field.
    nu,nv
        (integer) The number of sample points to use in each lattice vector direction.
    format
        (string) Specifies the format of the output. Current choices are:
        
        Array
            Returns a pair of arrays of dimension `nu` by `nv`, each element is a table of length 3, containing tables of length 2 with the real and imaginary parts of the E or H field components.
        FileWrite
            Outputs the field data to files, overwriting the files.
        FileAppend
            Outputs the field data to files, appending to the files. This is useful of volume fields are needed.
        
    basefilename
        (string) The base filename for file output. The outputs are named ``basefilename .. '.E'`` and ``basefilename .. '.H'``.

   Return values:

    E,H
        Only returned if format is 'Array'.
        Arrays of dimension `nu` by `nv`, each element is a table of length 3, containing tables of length 2 with the real and imaginary parts of the E or H field.


.. method:: Simulation:GetSMatrixDeterminant()

    Returns the determinant of the S-matrix (scattering matrix) of the entire structure.
    The determinant is an analytic function in the complex frequency plane and has poles at the complex modal frequencies of the system.

   Usage::

    mantr, manti, base, expo = S:GetSMatrixDeterminant()

   Arguments:

    None.

   Return values:

    mantr, manti
        The determinant typically causes overflow or underflow, so it is returned as a mantissa multiplying a base raised to an exponent. These values are the real and imaginary parts of the mantissa. The value of the determinant is (mantr+i*manti)*base^expo.
    base
        The base of the determinant representation (see above).
    expo
        The exponent of the determinant representation (see above).



Options
^^^^^^^

.. method:: Simulation:UseLanczosSmoothing(use)

    Enables or disables smoothing of the Fourier series representations of the layer dielectric constants using the Lanczos sigma factor (box filtering). This reduces the Gibbs phenomenon ringing in the real space reconstruction.

   Usage::

    S:UseLanczosSmoothing(use)

   Arguments:

    use
        (boolean, optional) Indicates whether to enable smoothing. If this argument is not provided, smoothing is enabled.

   Return values:

    None.


.. method:: Simulation:UseDiscretizedEpsilon(use)

    Enables or disables the use of discretization in generating the Fourier coefficients of the in-plane epsilon profiles, instead of using values from closed-form equations. When enabled, the coefficients are obtained by FFT.

    See the :ref:`fmm-formulations-label` for details.

   Usage::

    S:UseDiscretizedEpsilon(use)

   Arguments:

    use
        (boolean, optional) Indicates whether to use a discretized epsilon. If this argument is not provided, use of a discretized epsilon is enabled.

   Return values:

    None.


.. method:: Simulation:UsePolarizationDecomposition(use)

    Enables or disables the use of proper in-plane Fourier factorization rules by decomposing fields into a polarization basis which conforms to the material boundaries.
    The polarization basis field is generated automatically by computing a quasi-harmonic vector field everywhere tangent to the layer pattern boundaries.
    This option is not guaranteed to work in the presence of tensor dielectric constants.

    Enabling this feature typically improves convergence with respect to the number of G-vectors.
    See the :ref:`fmm-formulations-label` for details.

   Usage::

    S:UsePolarizationDecomposition(use)

   Arguments:

    use
        (boolean, optional) Indicates whether to enable polarization decomposition. If this argument is not provided, polarization decomposition is enabled.

   Return values:

    None.

.. method:: Simulation:UseSubpixelSmoothing(use)

    Enables or disables the use of second-order accurate epsilon averaging rules within a pixel.
    The average epsilon within a pixel is computed using the fill factor of each material and the interface direction.

    Enabling this feature may improve convergence with respect to the number of G-vectors.
    See the :ref:`fmm-formulations-label` for details.

   Usage::

    S:UseSubpixelSmoothing(use)

   Arguments:

    use
        (boolean, optional) Indicates whether to enable subpixel smoothing. If this argument is not provided, subpixel smoothing is enabled.

   Return values:

    None.

.. method:: Simulation:UseJonesVectorBasis(use)

    This option only has an effect with :func:`UsePolarizationDecomposition`.
    When enabled, a Jones vector basis field is used instead of a conformal harmonic field.

    Enabling this feature may improve convergence with respect to the number of G-vectors.
    See the :ref:`fmm-formulations-label` for details.

   Usage::

    S:UseJonesVectorBasis(use)

   Arguments:

    use
        (boolean, optional) Indicates whether to use a Jones vector basis. If this argument is not provided, use of a Jones vector basis is enabled.

   Return values:

    None.

.. method:: Simulation:UseNormalVectorBasis(use)

    This option only has an effect with :func:`UsePolarizationDecomposition`.
    When enabled, the resulting vector field is normalized. Where the vector field is zero, the unit vector in the x-direction is used.

    Enabling this feature may improve convergence with respect to the number of G-vectors.
    See the :ref:`fmm-formulations-label` for details.

   Usage::

    S:UseNormalVectorBasis(use)

   Arguments:

    use
        (boolean, optional) Indicates whether to use a normalized vector basis. If this argument is not provided, use of a normalized vector basis is enabled.

   Return values:

    None.

.. method:: Simulation:SetResolution(use)

    This option only has an effect with :func:`UseDiscretizedEpsilon` or :func:`UseSubpixelSmoothing`.
    This function sets the resolution of the FFT grid and vector field generated by :func:`EnablePolarizationDecomposition`.
    The resolution is multiplied by the largest G-vector extent (integer lattice coordinate), and should be at least 2 to satisfy the Nyquist limit. It is best to use a number with small integer factors in order for the FFT to be computed efficiently. The size of each dimension of the FFT is obviously proportional to this value. The default is 8.

    See the :ref:`fmm-formulations-label` for details.

   Usage::

    S:SetResolution(n)

   Arguments:

    n
        The oversampling factor. Must be at least 2.

   Return values:

    None.

.. method:: Simulation:SetBasisFieldDumpPrefix(prefix)

    Setting this option to a filename prefix causes the vector field used by the polarization decomposition to be dumped to files (one for each layer) in Gnuplot format.
    The files are named by concatenating the provided prefix string with each layer's name.

   Usage::

    S:SetBasisFieldDumpPrefix(prefix)

   Arguments:

    prefix
        (string, optional) When provided, the filename prefix is set to the given string. This can be an empty string. If this argument is not provided, the basis field dump is disabled.

   Return values:

    None.

.. method:: Simulation:SetLatticeTruncation(trunc)

    Sets the type of lattice truncation to use when selecting G-vectors.

   Usage::

    S:SetLatticeTruncation(trunc)

   Arguments:

    trunc
        (string) Can be one of the following values:

        Circular
            This is the default. The G-vectors are selected to have shortest length (by l2 norm).
        Parallelogramic
            Chooses the G-vectors within a parallelogram aligned with the reciprocal lattice basis. The number chosen will always be a perfect square of an odd number.

   Return values:

    None.

.. method:: Simulation:SetVerbosity(level)

    Sets the level of diagnostic output generated by the program.

   Usage::

    S:SetVerbosity(level)

   Arguments:

    level
        (integer, optional) The larger this value, the more status output is generated. Valid values are in the range of 0-9, inclusive. A value of 0 disables all status output.

   Return values:

    None.

.. method:: Simulation:UseLessMemory(use)

    Setting this option will prevent storage of certain intermediate results. This will save approximately 30% memory for non-trivial layers.
    The drawback is slower computation of any output quantities that require solutions.

   Usage:

    S:UseLessMemory(use)

   Arguments:

    use
        (boolean, optional) Indicates whether to use less memory. If this argument is not provided, lower memory usage is enabled.

   Return values:

    None.


Miscellaneous
^^^^^^^^^^^^^

.. method:: Simulation:Clone()

    Duplicates an existing Simulation object, copying all materials, layers, and excitation information.
    No partial solution information is copied.

   Usage::

    S2 = S:Clone()

   Arguments:

    None.

   Return values:

    A copy of the `Simulation object`_.

SpectrumSampler object
----------------------

.. class:: SpectrumSampler

    The SpectrumSampler object provides a convenient way to sample spectral information of a system.
    For example, it is used to resolve sharp peaks in transmission spectra.
    Interaction with a SpectrumSampler object is by contract; a new frequency is retrieved from it by which simulation results at that frequency are computed, and then the results are submitted.

    The frequencies given out by a SpectrumSampler object aim to produce a visually pleasing plot of the resulting spectrum by limiting the maximum normalized bend angles between adjacent line segments of the plot.

    A typical usage is shown below::

        function f(x) -- example function
            return math.sin(x)
        end
        sampler = S4.NewSpectrumSampler(0.1, 0.9, -- start and end frequencies
            { -- table of options
            InitialNumPoints = 33,
            RangeThreshold = 0.001,
            MaxBend = math.cos(math.rad(10)),
            MinimumSpacing = 1e-6
            })
        while not sampler:IsDone() do
            x = sampler:GetFrequency()
            y = f(x) -- compute the desired result
            sampler:SubmitResult(y)
        end

        spectrum = sampler:GetSpectrum()
        for i,xy in ipairs(spectrum) do
            print(xy[1],xy[2])
        end

.. method:: SpectrumSampler:IsDone()

    Queries whether the SpectrumSampler has completed sampling.
    When sampling has been completed, no further frequencies should be requested from the SpectrumSampler object, and no further results should be submitted.

   Usage::

    done = sampler:IsDone()

   Arguments:

    None.

   Return values:

    A boolean value indicating whether sampling has completed.


.. method:: SpectrumSampler:GetFrequency()

    Retrieves the next frequency at which to sample the spectrum. This function should only be used if the SpectrumSampler object was created with `Parallize` set to false (the default).

   Usage::

    freq = sampler:GetFrequency()

   Arguments:

    None.

   Return values:

    The (numeric) frequency at which the next result should be computed and submitted.


.. method:: SpectrumSampler:GetFrequencies()

    Retrieves the next set of frequencies at which to sample the spectrum. This function should only be used if the SpectrumSampler object was created with `Parallize` set to true.

   Usage::

    freqlist = sampler:GetFrequency()

   Arguments:

    None.

   Return values:

    A list of (numeric) frequencies at which the next results should be computed and submitted.

.. method:: SpectrumSampler:SubmitResult(result)

    Submits a result to the SpectrumSampler object. The result is assumed to be at the frequency of the last requested frequency.  This function should only be used if the SpectrumSampler object was created with `Parallize` set to false (the default).

   Usage::

    done = sampler:SubmitResult(result)

   Arguments:

    result
        (number) The result to submit. The result may be any value (for example, the transmission through a structure).

   Return values:

    A boolean value indicating whether sampling has completed.

.. method:: SpectrumSampler:SubmitResults(result_list)

    Submits a set of results to the SpectrumSampler object. The results are assumed to be at the frequencies of the last requested frequencies. This function should only be used if the SpectrumSampler object was created with `Parallize` set to true.

   Usage::

    done = sampler:SubmitResults(result_list)

   Arguments:

    result_list
        (table) The list of results to submit. The length of this table must match the number of frequencies obtained from the previous call to `GetFrequencies`.

   Return values:

    A boolean value indicating whether sampling has completed.

.. method:: SpectrumSampler:GetSpectrum()

    Retrieves a list of all sampled frequencies and submitted results.
    This function should only be used when the SpectrumSampler object indicates that sampling is complete.

   Usage::

    valarray = sampler:GetSpectrum()

   Arguments:

    None.

   Return values:

    An array (with length equal to the number of samples) of pairs (arrays of length 2) containing the sampled frequency and corresponding submitted result.


Interpolator object
-------------------

.. class:: Interpolator

    The Interpolator object provides a tool to perform various types of interpolation on data.
    The most common use is to interpolate between experimentally determined values for dieletric constants.
    A typical usage is shown below::

        interpolator = S4.NewInterpolator('linear', {
            {3.0, {14.2, 32}}, -- x, and list of y values
            {5.4, {4.6, 10}},
            {5.7, {42.7, 20}},
            {8.0, {35.2, 40}}
            })

        for x = 0, 10, 0.1 do
            y1, y2 = interpolator:Get(x)
            print(x, y1, y2)
        end

    At each x (abscissa) value, any number of y (ordinate) values can be specified for interpolation.

.. method:: Interpolator:Get(x)

    Retrieves the interpolated ordinates for a given abscissa value.

   Usage::

    y1, y2, ... = interpolator:Get(x)

   Arguments:

    x
        (number) The abscissa value at which to interpolate.

   Return values:

    A list of interpolated ordinate values.


.. |S4| replace:: S\ :sup:`4`

