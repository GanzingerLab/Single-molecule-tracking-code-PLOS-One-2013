% NAME:
%               main_tracking
% PURPOSE:
%               Analyses video data of fluorescent spots, connects the iden
%               tified particles to trajectories in subsequne image frames
%               and analyses the motion based on an Mean Square Displacement
%               (MSD) analysis MSD and a Jump Distance (JD) analysis. 
% 
% CATEGORY:
%               Image Processing
% CALLING SEQUENCE:
%               main_tracking
% INPUT DATA:
%               Videos to be analysed need to be TIFF image stacks and
%               saved in the same folder, all need to have the same root 
%               name
% Parameters:
%               The outcome depends on a set of paramters which can be set
%               below
%
% OUTPUTS:
%               setup, results and results_afterreloc; various control and 
%               results plots are created
% NOTES:
% A more detailed description can be found in the paper given below, and 
% the accompanying PDF file. 
% Basic instructions how to run the file in Matlab can be found in the
% accompanying text file.
% 
%               Written by Laura Weimann, The University of Cambridge, 
%               2012-2014
%               some subfunctions were written by other people:
%               tiffread2.m by Francois Nedelec
%               bpass.m, pkfnd.m, cntrd.m by Daniel Blair and Eric Dufresne
%               track.m by John C. Crocker/Daniel Blair
%               NoiseReduc.m by Nigel Reuel
%               Find_change_points.m by Yan Jiang
%
%       It should be considered 'freeware'- and may be
%       distributed freely in its original form when properly attributed.
%       Cite Weimann, Laura, et al. "A Quantitative Comparison of 
%       Single-Dye Tracking Analysis Tools Using Monte Carlo Simulations." 
%       PloS one 8.5 (2013): e64287.
%       when using the code.
%
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

addpath('./main_tracking source code');

%The following parameters need to be adapted in order to read in the data
parameters.exp_name = 'Results SPT Analysis\test data set'; 
                                                 %defines folder in which results are to be saved,change for each run, as
                                                 %this version is not stable against overwriting results
stack_directory = 'C:\Users\TIRF\Desktop\Chapter 4 - Single-Particle Tracking Tool\test data set';
                                                 %defines folder which contains TIFF image stacks to be analysed
parameters.keyword = 'c';                        %Root name common to all TIFF image stacks to be analysed                                                 
parameters.number_stack_input = 'all';               %'How many cells to be analyzed? (put in a number, or "all")'                                              
parameters.startt = 1;                           %defines with which image to begin
parameters.endt = 0;                             %define where to end, if set to 0, the whole image stack in analysed

%Microcope Setup
parameters.time = 33;                            %acquistion rate: time between acquired images in given image stack in ms
parameters.PixelSize = 109;                      %Pixel Size of instrument in nm


%Set the following parameters to identify spots and to form trajectories
parameters.interactive = 0;                      %if set to 1, only the spot detection part is running, and images pop up showing the spot detection results
parameters.initialthreshold = 7;                 %threshold for spot detection, number of std above background (recommended: 3-10)
parameters.SNR = 2;                              %defines SNR threshold, only spots with higher SNR are kept (recommended: 2-5)
parameters.max_spot_size = 10;                   %Maximum Spot Size [radius in pixel]
parameters.minLength = 5;                        %defines minimal length of tracks to be kept [frames]                                                     
parameters.max_step = 4;                         %defines maximal distance at which 2 spots are linked in subsequent frames [pixels]
parameters.memory = 3;                           %this is the number of time steps that a particle can be 'lost' and then recovered again [frames]

%Set the following parameters to perform MSD/JD analysis
%MSD Analysis
parameters.threshold_tracklength = parameters.minLength;            
                                                 %defines minimal length of tracks to be analysed [frames]
parameters.step = 5;                         %Number of points for calculating MSD and for fit the single trajectories
                                                 %small number --> short-term diffusion coefficient
                                                 %high number  --> long-term diffusion coefficient                                                 
parameters.n_fit = 5;                            %Number of points for fitting the ensemble plot, <= parameters.max_step
parameters.bool_D = 0;                           %If set to 1, max_step is set to tracklength/4, with a minimum value of 3, following the advise
                                                 %of Saxton (http://www.annualreviews.org/doi/abs/10.1146/annurev.biophys.26.1.373)
parameters.show_single_MSD_plots = 0;            %If set to 1, linear fits to individual trajectories are shown

%JD Analysis
parameters.number_populations = 3;               %number of populations expected

%if paramters.number_poulations == 1
param_guess1(1) = 0.1;                           %start value for curve fitting: D of population [in mu^2/s]  
%if parameters.number_poulations > 1 --> Set these
param_guess2(1) = 0.1;                           %start value for curve fitting: D of first population [in mu^2/s]
param_guess2(2) = 0.7;                           %start value for curve fitting: fraction of first population
param_guess2(3) = 0.02;                          %start value for curve fitting: D of second population [in mu^2/s]
param_guess2(4) = 1-param_guess2(2);             %fraction of second population (don't change, already determined by the parameters above)
%if parameters.number_poulations > 2 --> Set these
param_guess3(1) = 0.1;                           %start value for curve fitting: D of first population [in mu^2/s]
param_guess3(2) = 0.7;                           %start value for curve fitting: fraction of first population
param_guess3(3) = 0.02;                          %start value for curve fitting: D of second population [in mu^2/s]
param_guess3(4) = 0.2;                           %start value for curve fitting: fraction of second population
param_guess3(5) = 0.002;                         %start value for curve fitting: D of third population [in mu^2/s]
param_guess3(6) = 1-(param_guess3(2)+param_guess3(4)); %fraction of second population (don't change, already determined by the parameters above)
%if set to parameters.number_poulations == 3,for the JD analysis the 
%cumulative plot only is shown

%Set the following parameters to change the output video files
parameters.withvideo = 1;                        %set to 1 will create videos of the tracking Results
parameters.FBS = '10';                           %defines Frames per second for output videos  

%These parameters can be adapted, but are less critical; 

parameters.lobject = 5;                          %defines parameter for bpass function to cancel out the long wavelength noise
parameters.lnoise = 1;                           %defines parameter for bpass function to cancel out the short wavelength noise
parameters.pkfnd_sz = 5;                         %defines diameter of spots in which only brighter one will be selected (recommended: cntrd_sz - 2)
parameters.cntrd_sz = 7;                         %defines diameter of area of spots for centroid/intensity calculation (recommended: 5,7)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Spots are idenitfied in the image files
[setup]=spot_detection(parameters,stack_directory);
%Spot postions are saved as .dat files, in folder 'spot detection Results'
%per spot 6 entries: x,y coordinate, Max Intensity, Max Intensity raw, 
%SNR filtered, SNR raw
%recommended to start in interactive mode (set parameters.interactive to 1)
%to check the threshold setting for the spot detection (parameters.initalthreshold, parameters.SNR, parameters.max_spot_size)
%all spot with an SNR value below parameters.SNR and a size greater than
%parameters.max_spot_size are excluded

if parameters.interactive == 0
%Trajectories are formed and an avi video created showing the results
[results] = get_tracks(parameters,setup);

%MSD and JD analysis of trajectories are performed
[results] = msd_jd_analysis(parameters,param_guess1,param_guess2,param_guess3,results,setup);
end
