# BiSCAT - The Binaural Spectrogram Correlation and Transformation Receiver Model

BiSCAT is an auditory modeling framework that is based on the **Spectrogram Correlation and Transformation (SCAT)** receiver.  SCAT was originally developed by Prestor Saillant and James Simmons [1-4] and has been extended by many [5-12].  Although the model was originally a monaural (i.e., range-only) model, it can be applied to two or more separate channels to produce angular estimates of target location.  

The BiSCAT simulation framework is intended to be modular and expandable to facilitate follow-on research.  It contains a MATLAB GUI to start becoming familiar with the many parameters and options.  The GUI loads configuration data from the _config.mat_ file and acts as an interface to the _runBiscatMain.m_ command line tool.  With a properly defined configuration file, simulations can be run without the GUI (run _help runBiscatMain.m_ in MATLAB).  Numerous functions are found in the subfolders, categorized by function or processing stage.

Many biomimetic auditory system models apply a parallel filter bank to the sound waveform received at each ear, but the processing details following this stage vary.  BiSCAT models the auditory response in a deterministic fashion following the original SCAT model, but it also allows for detailed simulations using probablistic neuronal implementations such as Ray Meddis' inner hair cell model and/or an integrate-and-fire network of neurons immediately following the spiking auditory nerve cells.  Further documentation for each stage can be found in the corresponding subfolders.

## Directory Contents

Files:
+ biscat.m  -  main GUI interface to the modeling framework
+ runBiscatMain.m  -  main function that integrates all submodels; This can be invoked via BiSCAT GUI or the command line without a GUI
+ config.mat  -  The binary configuration data file loaded at startup
+ readme.md  -  This document (formatted using Markdown language)
+ biscat_model_todo_list.txt - Notes on possible extensions and work in progress

Subfolders:
+ config_files  -  Supplementary configuration data files
+ gui_callbacks  -  Supporting functions used by the BiSCAT GUI
+ sig_generate  -  Functions to generate and plot input signals (Panel 1)
+ coch_filters  -  Filterbank functions to model basilar membrane motion (Panel 2)
+ neur_discharge  -  Acoustic-to-neural transduction models by IHCs (Panel 2)
+ neur_temporal  -  Temporal processing models and delay lines (Panel 3)
+ neur_spectral  -  Spectral processing models (Panel 3)
+ testbed_files  -  General data files used in developing model algorithms


## Requirements

BiSCAT is developed and tested on Windows and Mac OS X platforms using modern versions of MATLAB (preferably 2015a or later).  The simulator is not guaranteed to work on every platform or without certain toolboxes available.  Please submit any bugs or issues to the author for tracking.

Some custom MATLAB functions are required to run BiSCAT.  These are available as a separate set of MATLAB libraries named 'matlibs'.


## Contact Information:

### Author:
**Jason E. Gaudette**, Center for Biomedical Engineering, Brown University (jason_gaudette@brown.edu)

### Laboratory:
**Prof. James A. Simmons**, Dept. of Neuroscience, Brown University (james_simmons@brown.edu)


## References

### Original SCAT model
*[1] Saillant, P., Simmons, J., Dear, S., & McMullen, T. (1993). A computational model of echo processing and acoustic imaging in frequency-modulated echolocating bats: The spectrogram correlation and transformation receiver. The Journal of the Acoustical Society of America, 94, 2691–2712.*

*[2] Saillant, P. A. (1995, May 1). Neural Computations for Biosonar Imaging in the Big Brown Bat. (J. A. Simmons, Ed.)PhD Thesis. Brown University, Providence, RI.*

*[3] Simmons, J., Saillant, P., & Dear, S. (1992). Through a bat's ear. IEEE Spectrum, 29(3), 46–48.*

*[4] Simmons, J., Saillant, P., & Boatright, S. (1997). Biologically inspired SCAT sonar receiver for 2-D imaging. The Journal of the Acoustical Society of America, 102, 3153.*

### SCAT extensions
*[5] Gaudette, J. E. (2014, February 25). Bio-Inspired Broadband Sonar: Methods for Acoustical Analysis of Bat Echolocation and Computational Modeling of Biosonar Signal Processing. (J. A. Simmons, Ed.). Brown University, Providence, RI.*

*[6] Matsuo, I. (2013). Localization and tracking of moving objects in two-dimensional space by echolocation. The Journal of the Acoustical Society of America, 133(2), 1151–1157. http://doi.org/10.1121/1.4773254*

*[7] Simmons, J. A., & Gaudette, J. E. (2012). Biosonar echo processing by frequency-modulated bats. IET Radar, Sonar & Navigation, 6(6), 556–565. http://doi.org/10.1049/iet-rsn.2012.0009*

*[8] Sharma, N. S., Buck, J. R., & Simmons, J. A. (2011). Trading detection for resolution in active sonar receivers. The Journal of the Acoustical Society of America, 130, 1272.*

*[9] Park, M., & Allen, R. (2010). Pattern-matching analysis of fine echo delays by the spectrogram correlation and transformation receiver. The Journal of the Acoustical Society of America, 128(3), 1490–1500. http://doi.org/10.1121/1.3466844*

*[10] Neretti, N., Sanderson, M., Intrator, N., & Simmons, J. (2003). Time-frequency model for echo-delay resolution in wideband biosonar. The Journal of the Acoustical Society of America, 113, 2137–2147.*

*[11] Matsuo, I., Tani, J., & Yano, M. (2001). A model of echolocation of multiple targets in 3D space from a single emission. The Journal of the Acoustical Society of America, 110(1), 607–624. http://doi.org/10.1121/1.1377294*

*[12] Peremans, H., & Hallam, J. (1998). The spectrogram correlation and transformation receiver, revisited. The Journal of the Acoustical Society of America, 104, 1101–1110.*

### Alternative models
*[13] Wiegrebe, L. (2008). An autocorrelation model of bat sonar. Biological Cybernetics, 98(6), 587–595. http://doi.org/10.1007/s00422-008-0216-2*

*[14] Schillebeeckx, F., Reijniers, J., & Peremans, H. (2008). Probabilistic spectrum based azimuth estimation with a binaural robotic bat head (pp. 142–147). Presented at the 2008 Fourth International Conference on Autonomic and Autonomous Systems (ICAS), IEEE. http://doi.org/10.1109/ICAS.2008.42*
