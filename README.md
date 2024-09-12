# SHAPES
Codes for the SHAPES (Swarm Heuristics based Adaptive and Penalized
 Estimation of Splines) adaptive spline curve fitting method described in:
 
Soumya D. Mohanty and Ethan Fahnestock. "Adaptive spline fitting with particle swarm optimization." arXiv preprint [arXiv:1907.12160](https://arxiv.org/abs/1907.12160) (2019).

[![View SHAPES on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/75564-shapes)

# REQUIREMENTS
The codes are in Matlab and have been tested under 
- release 2019b+MAC OS (Catalina)
- 2018b+Windows 10.

# INSTALLATION
- Fork this repository (SHAPES).
- Fork the repository containing Particle Swarm Optimization (PSO) codes: [SDMBIGDAT19](https://github.com/mohanty-sd/SDMBIGDAT19.git)
- Clone the above forked repositories to your local machine. The steps below are to be executed on your local machine in the working copy of the repository (the folder called SHAPES).
- Edit the [pathset.m](./pathset.m) file in the SHAPES repository to provide the path to the SDMBIGDAT19 directory in your local directory tree.
- Run pathset.m (required only once at the start of a Matlab session). Alternatively, permanently add the paths to your Matlab search path list using addpath/savepath or through the GUI interface accessible from the "Set Path" button.
- Enter the SHAPES / DATA folder and run the [test_gendataBFsig.m](./DATA/test_gendataBFsig.m) script to generate sample files containing simulated data.
- Return to the SHAPES folder and run the test_*.m scripts in the SHAPES folder to test your installation using the above data files. 

# USAGE
- An example is provided in [test_shps.m](./test_shps.m). It runs SHAPES on data generated by [test_gendataBFsig.m](./DATA/test_gendataBFsig.m). Hence, use the latter to first generate some data.
- For reference, [test_shps.m](./test_shps.m), which tests the main function [shps.m](./shps.m), takes about 9 sec to complete on a 3 GHz 8-Core Intel Xeon E5 on one data realization with 260 samples, one PSO run, and other algorithm settings as given in the paper.
- Each test_*.m script also serves as an example of how to use the respective function.
- In addition, each function has associated usage instructions that can be accessed using Matlab's "help" command.

# VALIDATION
-  The script [validate_Fig10.m](./validate_Fig10.m) reproduces the panel for benchmark function f_2 in Fig. 10 of the paper. Assuming that there are 4 parallel workers available, the runtime of this script is about 2.7 hours on a 3 GHz 8-Core Intel Xeon E5. This is because it generates and analyzes 1000 simulated data files.
- Edit the 'nSig' variable in the above script to reproduce any one of the subpanels of Fig.10 and Fig.11 in the paper. Exact reproduction of the figures requires that resetting Matlab's default random number generator on your machine generates the same random stream as the one used in the paper. Otherwise, expect a statistically similar figure.

# NOTES
- The terms **breakpoints** and **knots** are used interchangeably in the codes and the documentation. 
We have tried to alleviate this overlap as much as possible but isolated instances may occur.
- The terms **benchmark function** and **benchmark signal** also appear interchangeably.
