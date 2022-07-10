# Characteristic Modes Via Transition Matrix

<img src="images/magEfourthPeak.png" alt="drawing" height="300"/>
A characteristic electric field magnitude at the fourth resonance of a dielectric cylinder (relative permittivity 38, height 4.6 mm, radius 5.25 mm) as evaluated by FEM solver of Comsol Multiphysics.

# Table of Contents
- [Overview](#overview)
- [Characteristic Modes Using FEM and Comsol Multiphysics](#characteristic-modes-using-FEM-and-comsol-multiphysics)
- [References](#references)

# Overview
References [1, 2] show how characteristic mode data (characteristic values, characteristic fields and or other characteristic quantities) can efficiently be obtained using a transition matrix. An essential property of this framework is that characteristic modes can be obtained using any electromagnetic solver that can resolve a dynamic scattering scenario. As an example and a supplement to references [1, 2], this repository includes wrappers and post-processing routines for calculating characteristic modes using a Finite Element Method of Comsol Multiphysics. These codes are posted as supplemental material to [1, 2], and you can cite these references to reference this repository.

## Contact information
Questions and suggestions related to these codes can be addressed to Lukas Jelinek, Czech Technical University in Prague, lukas.jelinek[at]fel.cvut.cz.

## Disclaimer
Although documented and tested, these codes are only intended to demonstrate the procedures described in [1, 2] and are not written as general-purpose tools. Feel free to experiment and modify these codes, but at your own risk.

# Characteristic Modes Using FEM and Comsol Multiphysics
The electromagnetic model is supposed to be built in the Comsol environment. The evaluation of the transition matrix is then performed in MATLAB using the MATLAB LiveLink feature in Comsol and scattering formulation in the RF module. The scripts assume the use of excitation defined using MATLAB function. To enable this feature, MATLAB functions must be enabled in "Comsol --> Preferences --> Security: Allow external libraries, Allow external Matlab functions". Post-processing steps are performed in MATLAB. The scripts were tested in Comsol 6.0 and MATLAB 2020a. Paths "COMSOL60\Multiphysics\mli", "FEM_Comsol" and their subdirectories must be in Matlab paths.

## Generic Workflow
It is assumed that the electromagnetic model is already built ("*.mph" file is available), including the MATLAB-based excitation in the RF module, and that scattering formulation is used. The transition matrix is obtained using repetitive excitation of the structure via spherical vector waves. Assuming a dielectric body, the excitation is provided by an external current density and Matlab function "JiSW.m" for full 3D simulation or "JiSWaxisym.m" for axisymmetric problems (body of revolution). These functions must be introduced in the Comsol environment under the "Global definitions --> MATLAB", see the examples below for more details. It is important to notice that both these functions use the function "epsrMap.m" that defines the dielectric composition of the scatterer. A simple dielectric sphere (“dielSphereSWMatlabJiAxisym.mph”, “dielSphereSWMatlabJi.mph”) and simple dielectric cylinder (“dielCylinderHuWangSWMatlabJiAxisym.mph”) are prepared in the current state.

Prior to running the main script for 3D problems (“No02_getTmatComsolJiReRe.m”) or the main script for axisymmetric problems (“No02_getTmatComsolJiAxisymCpxCpx.m”), the link between Matlab and Comsol must be opened using “No00_startComsolServer.m, No01_connectComsol.m”. This turns on the Comsol server and initializes the LiveLink connection.

The evaluation of the transition matrix is based on a repetitive call of a loop in which the excitation is chosen by parameter "SWindex", and the scattered electric field "Es" is evaluated. In each loop, the scattered field is sampled and projected on spherical vector waves using the function "projectEsTofAxisym.m" for axisymmetric problems or "projectEsTof.m" for a general 3D problem. Each iteration produces one column of the transition matrix. Subsequent steps are the eigenvalue decomposition and mode tracking, which are performed by script "No03_getCMdata.m". Tracked modal data can be plotted using "No04_plotTrackedResults.m"

## Body of Revolution Example
The examples based on a body of revolution are recommended to begin with since these are computationally less expensive than general 3D setups. Two examples are prepared. The first example "dielSphereSWMatlabJiAxisym.mph" is a simple dielectric sphere of (relative permittivity 3). The second example ("dielCylinderHuWangSWMatlabJiAxisym.mph") is a dielectric cylinder (relative permittivity 38, height 4.6 mm, radius 5.25 mm) which is used as a benchmarking setup for characteristic modes evaluation in the literature.
The evaluation of the transition matrix for these two examples is performed by script "No02_getTmatComsolJiAxisymCpxCpx.m". This file also contains recommended frequency sweeps for each setup. Each iteration (one spherical wave at one frequency) takes 2-3 seconds on a regular desktop computer, depending on a used processor. Memory demands are small. The resulting cell containing the transition matrix at each frequency is saved in the "/results" folder. In the actual version, this folder includes precalculated data for the dielectric cylinder.

In the case of the axisymmetric solver, it is necessary to specify the azimuthal order. This is done using the function "mSWaxisym.m". See the corresponding Comsol example files for its use.

## General 3D Example
When a general 3D treatment of the scattering scenario is demanded, the memory and CPU needs grow significantly. The reason is the need for meshing the scatterer, the surrounding vacuum, and the region occupied by a perfectly matched layer. For comparison purposes, an example of the same dielectric sphere treated by the axisymmetric solver is prepared, see "dielSphereSWMatlabJi.mph". The transition matrix for this example is evaluated by "No02_getTmatComsolJiReRe.m". Each iteration (one spherical wave at one frequency) takes approximately 200 seconds for the used meshing and regular desktop computer.

## Characteristic Quantities
In order to obtain characteristic quantities other than characteristic numbers or characteristic far fields, the solver must be used to produce them. An axisymmetric example is prepared with this functionality, with which the figure at the beginning of this readme document was created. The procedure starts with using a different function for excitation "JiSWaxisymLoad.m", which loads a particular spherical wave composition from file "aInc.mat". In order to excite a characteristic mode, this file should contain eigenvector of the transition matrix divided by the corresponding eigenvalue. This procedure is shown in "No05_getCharacteristicFieldComsolJiAxisymCpxCpx.m", which produces the "aInc.mat" file, and the user can check the validity of the excitation. If passed the check, virtually any characteristic quantity can be depicted by going to the Comsol environment and running "dielCylinderHuWangSWMatlabJiAxisymLoadAinc.mph". This excites the scatterer with proper modal excitation, and the user can then display a characteristic quantity of choice. In the current example, a characteristic magnitude of the electric field is depicted for a case of the above treated dielectric cylinder.

## Converters
The folder "FEM_Comsol" in its namespace "+utilities" also contains several convertor tools transforming scattering dyadic to transition matrix ("getTfromSdyad.m") and vice versa ("getSdyadFromT.m") or transforming far fields into spherical vector wave expansion ("getFSWfromF.m") and vice versa ("getFfromFSW.m"). These provide a direct connection between characteristic modes evaluated using transition matrix as described in [1, 2] and characteristic modes evaluated using scattering dyadic as described in [3].

# References
[1] M. Gustafsson, L. Jelinek, K. Schab, M. Capek,  "Unified Theory of Characteristic Modes: Part I -- Fundamentals", IEEE Transaction on Antennas and Propagation (submitted), Arxiv: [2109.00063](https://arxiv.org/abs/2109.00063)

[2] M. Gustafsson, L. Jelinek, K. Schab, M. Capek, "Unified Theory of Characteristic Modes: Part II -- Tracking, Losses, and FEM Evaluation", IEEE Transaction on Antennas and Propagation (submitted), Arxiv: [2110.02106](https://arxiv.org/abs/2110.02106)

[3] M. Capek, J. Lundgren, M. Gustafsson, K. Schab, and L. Jelinek, "Characteristic Mode Decomposition Using the Scattering Dyadic in Arbitrary Full-Wave Solvers", IEEE Transaction on Antennas and Propagation (submitted), Arxiv: [2206.06783](https://arxiv.org/abs/2206.06783)