The codes and data files in this folder are used to generate data realizations containing the benchmark functions used in the [SHAPES paper](https://arxiv.org/abs/1907.12160). Each data realization consists of the specified benchmark function added with the given signal to noise ratio to i.i.d. Gaussian noise (mean zero and unit variance).

Edit the [test_gendataBFsig.m](./test_gendataBFsig.m) script to generate data realizations containing benchmark signals with specified signal to noise ratios (SNRs). 

* The benchmark functions are serially numbered in the paper from 1 to 10. 

New benchmarks can be added, and associated data generated, following the instructions [here](./newbnchmrk.md). 

# Notes
- The term 'benchmark function' and 'benchmark signal', or just 'signal', are used interchangeably in both the paper as well as in the code documentation.
