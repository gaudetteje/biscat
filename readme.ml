# BiSCAT - The Binaural Spectrogram Correlation and Transformation Receiver Model

BiSCAT is an auditory modeling framework that is intended to be modular and expandable.  Most auditory system models assume a filterbank separates the sound waveform at each ear, but the level of detail following this stage varies.  BiSCAT models the auditory response in a deterministic fashion following the original SCAT model, but it also allows for detailed simulations using probablistic neuronal implementations such as Ray Meddis' inner hair cell model and/or an integrate-and-fire network of neurons immediately following the spiking auditory nerve cells.

The model can process monaural or binaural time series signals.  Integration between the two signals occurs only at the output stages.

==============================================
Directory Contents
==============================================

Files:
+ biscat.m  -  main GUI interface to the modeling framework
+ config.mat  -  The working configuration data file loaded at startup
+ readme.txt  -  This text document
+ runBiscatMain.m  -  main function that integrates all submodels; This can be invoked via BiSCAT GUI or the command line

Subfolders:
+ config_files  -  Supplementary configuration data files
+ gui_callbacks  -  Supporting functions used by the BiSCAT GUI

+ sig_generate  -  Functions to generate and plot input signals (Panel 1)
+ coch_filters  -  Filterbank functions to model basilar membrane motion (Panel 2)
+ neur_discharge  -  Acoustic-to-neural transduction models by IHCs (Panel 2)
+ neur_temporal  -  Temporal processing models and delay lines (Panel 3)
+ neur_spectral  -  Spectral processing models (Panel 3)
+ testbed_files  -  General data files used in developing model algorithms


==============================================
Requirements
==============================================

BiSCAT is developed and tested on Windows and Mac OS X platforms using modern versions of MATLAB.  The simulator is not guaranteed to work on every platform or without certain toolboxes available.  Please submit any bugs to the author.

Some custom MATLAB functions are required to run BiSCAT.  These are available from the author as a separate set of MATLAB folders named 'matlibs'.


==============================================
Contact Information:
==============================================
Author:
Jason E. Gaudette
Center for Biomedical Engineering
Brown University
jason_gaudette@brown.edu
jason.e.gaudette@navy.mil

Laboratory:
James A. Simmons
Dept. of Neuroscience
Brown University
james_simmons@brown.edu
