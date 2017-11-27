# Introduction

The GUI allows for acquiring full field optical coherent tomography images and fluorescence images on a second camera (optionnal).

## Features:

- Real time parallel OCT and fluorescence imaging.
- Real time dynamic OCT imaging.

# Installation

## Pre-requisites

In order to be able to run the program, you will need to install the following on your Matlab software:
- Zaber toolbox to control the motors.
- Image acquistion toolbox with Bitflow (or you own framegrabber) depedencies.
- PCO SDK if you want to use the fluorescence.

## Configuration

Then you will probably need to change:
- Serial ports for your own motors.
- Initialisation files for your own cameras (`initialisationOCT.m` and `initialisationFluo.m`).

# Work in progress

Remarks:
- ROI for OCT (Adimec) camera is working weirdly. To be corrected in a futur release.
- Linear 5 phases modulation is not implemented yet.
- Saving format is limited to `tiff` for now but it can be easily modified.