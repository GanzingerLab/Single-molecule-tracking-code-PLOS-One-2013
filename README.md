# Single-molecule-tracking-code-PLOS-One-2013
This is the SPT code published in "Weimann, L., Ganzinger, K. A., McColl, J., Irvine, K. L., Davis, S. J., Gay, N. J., ... &amp; Klenerman, D. (2013). A quantitative comparison of single-dye tracking analysis tools using Monte Carlo simulations. PloS one, 8(5), e64287."

*Please cite the paper if you use it.*

The article can be downloaded (open access) under

https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0064287

Instructions for use of the code:

Put image stacks (in TIFF format) to be analysed in one folder, each image stack needs to contain the same root name, plus an index 
(e.g. video1, video2, video3 etc...), rename image stacks if necessary.

Install Matlab

Double Click on main_tracking.m. Matlab should open now and display the file in the Matlab Editor. 

change parameters.exp_name (l.55) to rename the experiment. Rename before each run, as the current software version
is not stable against overwriting

change stack_directory (l.58), put in path to the folder which contains TIFF video files to be analysed.

Change parameters.keyword (l.60) and put in root name as defined above

Set further paramters (l.61-119), start with the default settings; change parameters.time/paramters.PixelSize according to instrument used

It is recommended to set parameters.interactive to 1, when running the analysis on a new data set, to check the spot detection thresholds

Press F5 to start the program.

In interactive mode: Check spot detection by inspecting the images popping up (red crosses mark identified spots on filtered image data (first figure), 
values for SNR of filtered and unfiltered data are plotted on raw data (second figure)).

change paramters if necessary

Set parameters.interactive to 0

Various spot detection result/control plots are created and saved in the respective folder. Detailed explanation of the Results can be found in the accompanying PDF-file.

An .avi-file showing the tracking results is created and saved

It is recommended to check the tracking quality by looking at the .avi-file, and change tracking parameters if necessary

Various tracking and trajectory analysis result plots are created and saved in the respective folder. Detailed explanation of the Results can be found in the accompanying PDF-file.

It is recommended to check the start values for the JD analysis

Type in setup and results, in Matlab commmand window, detailed explanation of the content of these
Matlab structures can be found in the accompanying PDF-file.
