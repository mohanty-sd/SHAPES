**Under construction**

The code and data files in this folder can be used to generate data 
realizations containing the benchmark functions used in the [SHAPES paper](https://arxiv.org/abs/1907.12160). Use 'help \<function name\>' in Matlab to see usage instructions for each function.

**Note**: The term 'benchmark function' and 'benchmark signal', or just 'signal', are used interchangeably in both the paper as well as in the code documentation.

Edit the [rungendataBFsig.m](./rungendataBFsig.m) script to generate data realizations containing the benchmark signals with specified signal to noise ratios (SNRs). 

* The benchmark functions are serially numbered in the paper from 1 to 10. 

* Padding the data realizations with a small number of zero mean white Gaussian noise samples at each end is recommended in general to get better function estimates at the data start and end points, especially for functions that do not smoothly go to zero at the boundaries. By default, the number of samples for padding is 2 at each end. 