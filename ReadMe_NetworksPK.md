# PreciseKids

This repository contains MATLAB scripts and data files supporting the following publication:

> **How much is enough? Considerations for functional connectivity data acquisition in pediatric and adult populations**
> Author: Shefali Rai; doi: https://doi.org/10.1162/IMAG.a.117

---

## Overview

Our work examined how much fMRI data is needed to obtain reliable functional connectivity (FC) estimates in children and adults using naturalistic precision fMRI. Scripts in this repository cover the full analysis pipeline: preprocessing, parcellation, network assignment, test-retest reliability estimation, and visualization.

---

## Repository Structure

```
PreciseKids/
├── scripts/        # MATLAB analysis scripts (.m files)
├── data/           # Video database used for naturalistic stimuli
└── ReadMe_NetworksPK.md
```

---

## Requirements

- **MATLAB R2021b** or later
- The following must be downloaded and added to your MATLAB path:
  - `cifti-matlab` (for reading/writing CIFTI files)
  - `gifti-1.6` (for GIFTI surface files)
  - Brain Connectivity Toolbox (BCT) — specifically `threshold_proportional.m`
  - `infomap` (for network community detection)
  - Connectome Workbench (`wb_view`, `wb_command`) for visualization

---

## Pipeline Overview

### 1. Preprocessing
Functional and structural preprocessing is handled by custom Python scripts (not included here). Functional data is censored based on a framewise displacement (FD) threshold of 0.15 mm.

### 2. Parcellation & Timeseries Extraction
- `Meancenter_Parcellate_dtseries.m` — parcellates dense timeseries into ROI timeseries
- `Timeseries_143DWROIs_Child.m` / `Timeseries_143DWROIs_Parent.m` — extracts timeseries for 143 ROIs for children and parents respectively
- `Openandcensor_dtseries.m` — opens and censors timeseries data

### 3. Functional Connectivity
- `Corr_Parcelled_pconn.m` — computes FC matrices from parcellated timeseries
- `AveragedFC_143ROIs_EachNetwork.m` — averages FC across ROIs within each network
- `FC_Connectomes_142DWROIs_MachineLearningMatrices.m` — prepares FC matrices for machine learning
- `FisherTransform.m` — applies Fisher r-to-z transformation

### 4. Network Assignment
- `Create_Consensus_Networks.m` — builds consensus network assignments across participants
- `Createnetwork_connectomes.m` — creates network-level connectomes
- `NetworkConsensus_IndividualParticipant_TemplateMatchingMaps.m` — assigns individual participants to consensus networks via template matching
- `MSCtemplates_GroupAvgSystemsMaps.m` / `MSCtemplates_GroupAvgSystemsMaps_Vertexwise.m` — uses MSC templates for group-average network maps

### 5. Test-Retest Reliability
- `TestretestReliability_FullCurves.m` — computes reliability curves across data amounts
- `GEDev_FCTRCReliability.m` / `GEDev_FCTRCReliability_2runs.m` — reliability for GE scanner data
- `GE_multiecho_reliability.m` / `GE_singleecho_reliability.m` — multi-echo vs single-echo reliability comparison
- `ICC_FCTRC_Plots.m` — ICC and FC-TRC reliability plots
- `Testretest_ICC_Reliability_SurfaceMaps.m` — surface-level ICC maps

### 6. Motion Analysis
- `MeanFD_ChildandParent.m` — computes mean FD for children and parents
- `LowHighMotion_LinearModel.m` — linear model comparing low and high motion groups
- `LowHighMotion_UncensoredVolumesCalculation.m` — calculates usable volumes after censoring
- `PKtotaldata_aftercensoring.m` — summarizes total data retained after censoring

---

## Known Setup Issue (Mac — MATLAB MEX file error)

If you encounter an error like `Invalid MEX-file ... xml_findstr.mexmaci64`, rebuild the MEX file from terminal:

```bash
cd /path/to/gifti/@xmltree/private
/Applications/MATLAB_R2021b.app/bin/mex -compatibleArrayDims xml_findstr.c
```

Then verify with:
```bash
otool -L xml_findstr.mexmaci64
```

---

## Citation

If you use these scripts, please cite:

> Shefali Rai, Kate J. Godfrey, Kirk Graff, Ryann Tansey, Daria Merrikh, Shelly Yin, Matthew Feigelis, Damion V. Demeter, Tamara Vanderwal, Deanna J. Greene, Signe Bray; How much is “enough”? Considerations for functional connectivity reliability in pediatric naturalistic fMRI. Imaging Neuroscience 2025; 3 IMAG.a.117. doi: https://doi.org/10.1162/IMAG.a.117