# Adding new benchmark functions
In addition to the benchmark function data files provided in this release of SHAPES, one can easily add new ones and use
[gensimdata.m](./DATA/gensimdata.m) to generate corresponding data realizations. The steps are explained below in 
the form of Matlab commands (in italics).

Let *V* be the array containing the benchmark function samples and let's say we want to generate data realizations where *V* is present with signal-to-noise ratio (SNR) of 100 in i.i.d. Gaussian noise (mean zero and unit variance).
- Normalize: *unitnormsig = V/norm(V)*
- Sampling frequency: *fs* (set it to the appropriate value)
- Create benchmark data file: *save(* my_benchmark_file, *'fs', 'unitnormsig')*
- Generate *N* data realization: *gensimdata(N,* folder_for_data_files, *struct('snr',100,'sigFile',* my_benchmark_file,*'numPad',2))*

# Notes
- In this release of SHAPES, predictor values are assumed to be spaced uniformly. Hence, a sampling frequency makes sense.
- The *numPad* parameter specifies the number of padded samples. Padding is discussed [here](./README.md).
