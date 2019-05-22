If you use this software please consider citing it [![DOI](https://zenodo.org/badge/111929339.svg)](https://zenodo.org/badge/latestdoi/111929339)

# Introduction

The GUI allows for acquiring full field optical coherent tomography images and fluorescence images on a second camera (optional) or a Spectral domain OCT (optional).

## Features:

- Configurations for both in-vivo eye imaging with SDOCT and fluorescence measurement.
- Real time parallel FFOCT and fluorescence imaging.
- Real time parallel FFOCT and SDOCT imaging.
- Real time dynamic FFOCT imaging.

# Installation

## Pre-requisites

In order to be able to run the program, you will need to install the following on your Matlab software:
- Matlab 2017b (add-on: Ni-DAQmx, Zaber toolbox, Bitflow frame grabber adaptor).
- Image acquistion toolbox with Bitflow (or you own framegrabber) depedencies.
- PCO SDK for using fluorescence.
- Thorlabs SDK for using SDOCT.

## Configuration

Then you will probably need to change:
- Serial ports for your own motors.
- Initialisation files for your own cameras (`initialisationOCT.m` and `initialisationFluo.m`).

# Work in progress

Remarks:
- ROI for OCT (Adimec) camera is working weirdly. To be corrected in a futur release.
- Linear 5 phases modulation is not implemented yet.
