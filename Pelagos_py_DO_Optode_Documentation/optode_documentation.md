# Oxygen Processing: Aanderaa Optodes

***

# Overview

Dissolved oxygen in seawater gives us information about ocean ventilation, primary productivity, and remineralisation of organic matter. It is therefore considered a key variable in understanding the marine carbon cycle, the biological carbon pump, and evolution of water masses. Oxygen sensors have been integrated on a range of autonomous platforms, such as floats, gliders, and ALRs. 

Dissolved oxygen is measured by optodes based on the principle of luminescence quenching by oxygen molecules. The optode has a sensing foil that allows oxygen to diffusion and contains luminophores that are excited by short pulses of blue light. When the luminophores relax to their ground state, they release energy in the form of light, i.e., luminescence. When oxygen molecules collide with the luminophores, a part of the released energy is transferred to the oxygen molecule, thereby quenching the luminescence of the luminophores. The amount by which the luminescence is quenched, i.e. the luminescence intensity, can therefore be translated into dissolved oxygen concentration. 

<img src="figures/optode_diagram_Aanderaa2007.png" alt="Schematic illustration of the oxygen optode (Aanderaa, 2007)" width="70%" title="Schematic illustration of the oxygen optode (Aanderaa, 2007)"/>

```figure} figures/optode_diagram_Aanderaa2007.png
:alt: Schematic illustration of the oxygen optode (Aanderaa, 2007)
:width: 70%

**Placeholder.**  
```

However, since light intensity is affected by source intensity, scattering, and other variables, it is prone to biases. Instead, a single-frequency phase shift technique is used which relies on the exponential decay of luminescence with time. Excitation intensity is modulated at a constant frequency, producing an emission that can be described as a phase. When oxygen molecules quench the luminenscence pulses, the resulting phase is shifted. It is this phase shift that is used as the measurement of dissolved oxygen. More detailed information can be found in Bittig et al. (2018). 

<img src="figures/diagram_phase_shift_Bittig2018.png" alt="Schematic illustration of the optode phase shift (Bittig et al., 2018)" width="90%" title="Schematic illustration of the optode phase shift (Bittig et al., 2018)"/>

```figure} figures/diagram_phase_shift_Bittig2018.png
:alt: Schematic illustration of the optode phase shift (Bittig et al., 2018)
:width: 90%

**Placeholder.**  
```

The integration of oxygen sensors onto autonomous platforms has greatly increased the spatial and temporal range on which oxygen variability can be studied and understood. However, the data output of the sensor requires rigorous QC, various corrections, calibrations, and processing by the user. The processing steps may vary depending on the optode type and available calibration data. Differing nomenclature for the same variables by different sensors have been standardised in the OG format, allowing pelagos-py to streamline processing steps as much as possible. Table 1 in the section on <i>Optode Variables</i> summarises how the standardisation of the optode variable names and how they are referred to in pelagos-py. 

The workflow for processing dissolved oxygen measurements consists of the following stages: 

1. **Uncalibrated phase shift** - calculates the uncalibrated phase shift by subtracting the red phase shift from the blue phase shift. If the red phase shift is not included in the dataset or is equal to zero, then the uncalibrated phase shift is simply the blue phase shift.
   
3. **Geometric lag correction** - applies a geometric lag correction that aligns the optode measurements to the CTD measurements as it descends/ascends in the water column. The CTD and optode may be mounted at different locations on the autonomous platform. Consequently, the CTD and optode encounter the same parcel of water at different times, which can lead to offsets in processed oxygen data, especially in strong temperature and salinity gradients. CTD and optode measurements are aligned to correct for this offset.

4. **Pressure correction on phase shift** - applies a pressure correction on the uncalibrated phase shift.

5. **Calibrated phase shift** - converts the uncalibrated phase shift into the calibrated phase shift using calibration coefficients provided by the manufacturer. This convertion includes a temperature compensation.

6. **Molar oxygen concentration** - converts the calibrated phase shift into molar oxygen concentration using one of several given methods. Choice of method depends on sensor type and availability of manufacturer coefficients. The resulting molar oxygen concentration is representative of dissolved oxygen concentration in freshwater, i.e., for salinity = 0.

7. **Salinity correction** - applies a salinity correction to the molar oxygen concentration, resulting in a molar oxygen concentration that is representative of the salinity of the measured water parcel.

8. **Pressure correction on molar oxygen concentration** - applies a pressure correction on the molar oxygen concentration.

9. **Response correction** - applies a correction to account for the optode response time.

10. **Dissolved oxygen content** - converts molar oxygen concentration ($\mu$mol L$^{-1}$) to oxygen content ($\mu$mol kg$^{-1}$)

11. **Global range check** - applies a global range check on the oxygen content.

12. **Regional range check** - applies a regional range check on the oxygen content.

13. **In-air calibration** - *not yet implemented*

14. **Two-point calibration** - *not yet implemented* 



# Input Data

The processing requires measurements from both the oxygen optode, the CTD, and several optional glider variables.



### Optode variables

- `TIME` — measurement time
- `BPHASE_DOXY` - phase shift measurement due to blue light excitation [$^{\circ}$]
- `RPHASE_DOXY` - phase shift measurement due to red light excitation (might not exist in dataset, in which case `RPHASE_DOXY` = 0) [$^{\circ}$]
- `CAL_PHASE_DOXY` — calibrated optode phase measurement [$\mu$s] (not required if `BPHASE_DOXY` is available)
- `MOLAR_DOXY` - dissolved oxygen concentration [$\mu$mol L$^{-1}$] | uncorrected for pressure and salinity if outputted directly by the sensor 
- `TEMP_DOXY` — optode temperature [$^{\circ}$C]
- Optode calibration coefficients from the manufacturer calibration sheet

> Different optodes give output of the same variables using different nomenclature. These have been standardised in OG format. The table below 

| Optode | Blue phase shift| Red phase shift | Uncalibrated phase shift | Calibrated phase shift | Molar oxygen concentration | 
| -------------| :-------------: |:------------:| :-------------:|:-------------:|:-------------:|
| Aanderaa 3930, 3835, 3975, 4130, 4175, 3830      | BPHASE | RPHASE |              | DPHASE | MOLAR_DOXY | 
| Aanderaa 4330, 4831, 48351     | C1PHASE |  C2PHASE| TPHASE | CALPHASE | MOLAR_DOXY
| **OG / pelagos-py** | **BPHASE_DOXY** | **PHASE_DOXY** | **UNCAL_PHASE_DOXY** | **CAL_PHASE_DOXY** | **MOLAR_DOXY** |


NRT datasets might different optode variables available compared to recovered datasets. Depending on which optode variables are available, the user can use a different starting point in the optode pipeline. Note that this sometimes means not all corrections can be applied. 
> If `BPHASE_DOXY` is available, start at step 1 of the workflow.
>> If only `UNCAL_PHASE_DOXY` is available, start at step 2 of the workflow.
>>> If only `CAL_PHASE_DOXY` is available, apply step 2 and continue with step 4 of the workflow.
>>>> If only `MOLAR_DOXY` is available, apply step 3 and continue with step 6 of the workflow. 


### CTD variables

- `TIME` — measurement time
- `TEMP` — CTD temperature [$^{\circ}$C]
- `PSAL` — practical salinity [psu]
- `PRES` — pressure [dbar]

### Glider variables

The geometric lag correction can be done using a default time value, or it can be estimated for each cast using the following variables: 

- `vert_gradient` - vertical velocity of the platform, e.g. of the glider (optional) | determined by pelagos-py 
- `pitch` - pitch of the platform, e.g. of the glider (optional)

--- 

# 1. Uncalibrated phase shift 

The uncalibrated phase measurement (`UNCAL_PHASE_DOXY`) is defined and calculated as teh difference between the phase from the blue light excitation (`BPHASE_DOXY`) and the red light excitation (`RPHASE_DOXY`). 

$$
UNCAL\_PHASE\_DOXY = BPHASE\_DOXY - RPHASE\_DOXY
$$

The red light excitation is often not used, in which it does not appear in the dataset or is set to zero, and `UNCAL_PHASE_DOXY` = `BPHASE_DOXY`. 

***

# 2. Geometric lag correction

The CTD and oxygen optode are physically separated on the glider. The CTD therefore measures a water parcel at a different time than the optode measures the same parcel. 

<img src="figures/diagram_geometric_alignment_WooGourcuff2023.png" alt="Schematic illustration of the geometric lag correction (Woo & Gourcuff, 2023)" width="70%" title="Schematic illustration of the geometric lag correction (Woo & Gourcuff, 2023)"/>

```{figure} figures/diagram_geometric_alignment_WooGourcuff2023.png
:alt: Schematic illustration of the geometric lag correction (Woo & Gourcuff, 2023)
:width: 70%

**Placeholder.** 
```

If the distance between the sensors is $d$ and the glider's along-track velocity is $v$, the geometric time delay is

$$
\tau_{\mathrm{geom}} = \frac{d}{v}
$$

For a glider, the vertical component of velocity can be approximated by

$$
v = r\sin(\theta)
$$

where:

- $r$ = glider dive rate
- $\theta$ = glider pitch angle

Thus,

$$
\tau_{\mathrm{geom}}
=
\frac{d}{r\sin(\theta)}
$$

For a known constant geometric delay, the CTD data are interpolated to the time at which the corresponding water parcel reaches the optode.

If the optode measurement occurs $\tau_{\mathrm{geom}}$ seconds after the CTD measurement, the CTD time corresponding to an optode observation at time $t$ is

$$
t_{\mathrm{CTD}} = t_{\mathrm{optode}} - \tau_{\mathrm{geom}}
$$

The CTD variables (e.g. temperature and salinity) are therefore interpolated onto these shifted optode times.


***

# 3. Pressure correction on phase shift
Pressure affects the luminescence lifetime of the luminophores, quenching, and membrane O2 equilibrium level (Bittig et al., 2015a; Bittig et al., 2016). To account for the pressure effect on luminescence lifetime, a hydrostatic pressure correction is applied to the uncalibrated phase shift (following Bittig et al., 2015a; also see Bittig et al., 2018): 

$$UNCAL\_PHASE\_DOXY\_PCORR = UNCAL\_PHASE\_DOXY + Pcoef1 \frac{1}{1000} * PRES$$

`UNCAL\_PHASE\_DOXY\_PCORR` is then the hydrostatic pressure corrected uncalibrated phase shift. 

$Pcoef1$ is a phase offset that depends on the sensing foil and depends on the manufacturer, which are provided in pelagos-py, e.g., 0.1 deg per 1000 dbar for Aanderaa optodes. 

$PRES_{geoshift}$ = Pressure geometrically aligned to optode 

Note that the pressure used in this correction is the one that has been geometrically adjusted for the different locations of the optode and CTD on the glider. 

The pressure effect on quencing and on membrane O2 equilibrium level will be corrected on the oxygen concentration: MOLAR_DOXY, which is done after the salinity correction. 

***

# 4. Calibrated phase shift

For newer Aanderaa optodes, the calibrated phase (`CalPhase`) can be calculated from `TCPhase` using the temperature-dependent phase calibration polynomial.

For example:

$$
\mathrm{CalPhase}
=
c_0
+
c_1\mathrm{TCPhase}
+
c_2\mathrm{TCPhase}^2
+
c_3\mathrm{TCPhase}^3
$$

where $c_0,\ldots,c_3$ are the appropriate phase calibration coefficients.

The exact calibration procedure depends on the optode model and calibration certificate.

***

# 5. Molar oxygen concentration



## Aanderaa 3930, 3835, 3975, 4130, 4175, 3830

### Stern-Volmer / SVU approach

For Aanderaa optodes with the appropriate SVU coefficients, dissolved oxygen concentration can be calculated from calibrated phase and temperature.

The temperature-dependent coefficients are

$$
K_{SV}
=
c_0+c_1T+c_2T^2
$$

and

$$
P_0=c_3+c_4T
$$

while the phase-dependent term is

$$
P_c=c_5+c_6\mathrm{CalPhase}.
$$

The freshwater-equivalent oxygen concentration is then

$$
c_{\mathrm{O_2},S=0}
=
\frac{
P_0/P_c-1
}{
K_{SV}
}.
$$

A two-point concentration adjustment may subsequently be applied:

$$
c_{\mathrm{O_2},adj}
=
c_{\mathrm{O_2},S=0}
\cdot \mathrm{ConcCoef1}
+
\mathrm{ConcCoef0}.
$$


### Two-dimensional polynomial / $p\mathrm{O_2}$ approach

Alternatively, the calibrated phase and temperature can be converted directly to oxygen partial pressure using a two-dimensional polynomial:

$$
p_{\mathrm{O_2}}
=
\sum_{i=0}^{27}
C_i
T^{m_i}
\mathrm{CalPhase}^{n_i}
$$

where:

- $C_i$ = polynomial coefficient
- $m_i$ = temperature exponent
- $n_i$ = phase exponent

The coefficients and exponents are provided on the optode calibration certificate.

This approach directly produces an oxygen partial pressure and therefore avoids the intermediate freshwater-equivalent oxygen concentration.

## Aanderaa 4330, 4831, 4835

*** 

# 6. Salinity correction

The optode responds to the oxygen **partial pressure** rather than directly to oxygen concentration.

When a calibration model produces freshwater-equivalent oxygen concentration, the result must therefore be corrected for the effect of salinity on the relationship between oxygen concentration and oxygen partial pressure.

The corrected oxygen concentration can be written as

$$
c_{\mathrm{O_2},S}
=
\frac{
1013.25-p_{\mathrm{H_2O}}(T,S=0)
}{
1013.25-p_{\mathrm{H_2O}}(T,S)
}
\,
S_{\mathrm{Corr}}
\,
c_{\mathrm{O_2},S=0}
$$

where:

- $S$ = practical salinity
- $p_{\mathrm{H_2O}}$ = water-vapour partial pressure
- $S_{\mathrm{Corr}}$ = salinity-dependent oxygen-solubility correction

The salinity correction is required when using a calibration model that produces freshwater-equivalent oxygen concentration.

If the calibration model produces $p_{\mathrm{O_2}}$ directly, this salinity correction is not required at this stage.


**Salinity correction factor**

The salinity correction factor is calculated as

$$
S_{\mathrm{Corr}}
=
\exp
\left[
(S-S_{\mathrm{preset}})
(B_0+B_1T_s+B_2T_s^2+B_3T_s^3)
+
C_0(S^2-S_{\mathrm{preset}}^2)
\right]
$$

where

$$
T_s
=
\ln
\left(
\frac{298.15-T}{273.15+T}
\right)
$$

and $B_0,\ldots,B_3$ and $C_0$ are the coefficients from the Garcia and Gordon formulation using the Benson and Krause refit.





***

# 7. Pressure correction on molar oxygen concentration

Hydrostatic pressure affects the oxygen quenching response of the optode.

The pressure correction can be applied to the salinity-corrected oxygen quantity:

$$
\mathrm{MOLAR\_DOXY}_{\mathrm{PSAL,PCORR}}
=
\mathrm{MOLAR\_DOXY}_{\mathrm{PSAL}}
\left[
1+
\left(
P_{\mathrm{coef2}}T+
P_{\mathrm{coef3}}
\right)
\frac{PRES}{1000}
\right]
$$

where:

- $T$ = CTD temperature ($^\circ$C)
- $PRES$ = pressure (dbar)
- $P_{\mathrm{coef2}}$ and $P_{\mathrm{coef3}}$ = pressure-response coefficients

The correction should use the **CTD temperature**.

For optodes where phase has already been corrected for pressure:

$$
P_{\mathrm{coef2}}=0.00022
$$

$$
P_{\mathrm{coef3}}=0.0419
$$

For optodes where phase has not been corrected for pressure:

$$
P_{\mathrm{coef2}}=0.00025
$$

$$
P_{\mathrm{coef3}}=0.0328
$$


***

# 8. Response correction

***

# 9. Dissolved oxygen content
Oxygen concentration may initially be expressed as

$$
c_{\mathrm{O_2}}
\quad
[\mu\mathrm{mol\,L^{-1}}].
$$

For comparison with standard oceanographic oxygen data products, this can be converted to

$$
c_{\mathrm{O_2}}
\quad
[\mu\mathrm{mol\,kg^{-1}}]
$$

using seawater density:

$$
c_{\mathrm{O_2},kg}
=
\frac{
c_{\mathrm{O_2},L}
}{
\rho
}
$$

where $\rho$ is the seawater density in kg L$^{-1}$.

The density should be calculated using practical salinity and referenced to 0 dbar.

***

# 10. Global range check

Values outside physically plausible global ranges should be flagged as bad data.

**Dissolved oxygen**

$$
-5
\leq
DOXY
\leq
600
\quad
[\mu\mathrm{mol\,kg^{-1}}]
$$

Values outside this range are assigned QC flag `4` ("bad data").

### Oxygen temperature

$$
-2.5 \leq TEMP\_DOXY \leq 40.0 \quad [^\circ\mathrm{C}]
$$

Values outside this range are assigned the appropriate bad-data QC flag.

***

# 11. Regional range check

Values outside physically plausible regional ranges should be flagged as bad data.

***

# 12. In-air calibration

***

# 13. Two-point calibration


*** 

# References

- Aanderaa (2007). TD 218 Operating Manual Oxygen Optodes.
- Bittig, H. C. et al. (2015). *Pressure Response of Aanderaa and Sea-Bird Oxygen Optodes*. Journal of Atmospheric and Oceanic Technology.
- Bittig, H. C. et al. (2016). SCOR Working Group 142 recommendations for oxygen quantity conversions.
- Bittig, H. C. et al. (2017). *Oxygen Optode Sensors: Principle, Characterization, Calibration, and Application in the Ocean*. Frontiers in Marine Science.
- Garcia, H. E. & Gordon, L. I. (1992). Oxygen solubility in seawater: better fitting equations.
- Hahn, J. et al. — response-time characterization and correction of oxygen optodes.
- Uchida, H. et al. (2008). Oxygen optode calibration and temperature compensation.