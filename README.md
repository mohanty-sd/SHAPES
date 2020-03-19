# SHAPES
Codes for the SHAPES (Swarm Heuristics based Adaptive and Penalized
 Estimation of Splines) adaptive spline curve fitting method described in:
 
Soumya D. Mohanty and Ethan Fahnestock. "Adaptive spline fitting with particle swarm optimization." arXiv preprint [arXiv:1907.12160](https://arxiv.org/abs/1907.12160) (2019).

This repository is **under construction**. Please contact the first author of the paper if you would like to use the codes before this repository is completed.

# REQUIREMENTS
The codes are in Matlab and have been tested under release 2019b.

# INSTALLATION
- Clone this repository (SHAPES).
- Clone the repository containing Particle Swarm Optimization (PSO) codes: [SDMBIGDAT19](https://github.com/mohanty-sd/SDMBIGDAT19.git)
- Edit the [pathset.m](./pathset.m) file in the SHAPES repository to provide the path to the SDMBIGDAT19 directory in your local directory tree.
- Run pathset.m (required only once at the start of a Matlab session).
- Run the test_*.m codes in SHAPES / DATA folder to generate files containing simulated data.
- Run the test_*.m codes in SHAPES to test your installation. 

For reference, [test_shps.m](./test_shps.m), which tests the main code, takes about 9 sec to complete on a 3 GHz 8-Core Intel Xeon E5 on one data realization with 260 samples and algorithm settings as given in the paper.

# Notes
- The terms **breakpoints** and **knots** are used interchangeably in the codes and the documentation. 
We have tried to alleviate this overlap as much as possible but isolated instances may occur.
- The terms **benchmark function** and **benchmark signal** also appear interchangeably.

# TODOs:

- [ ] Installation instructions
- [ ] Test suite
- [ ] Validate codes
- [x] Add data generation codes
- [x] Add standalone PSO codes
- [x] Add B-spline generation codes
- [x] Add SHAPES codes
