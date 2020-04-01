# Adding new benchmark functions
In addition to the benchmark function data files provided in this release of SHAPES, one can easily add new ones and use
[gensimdata.m](./DATA/gensimdata.m) to generate corresponding data realizations. The steps are explained below in 
the form of Matlab commands (in bold).

Let *V* be the array containing the benchmark function samples.
- Normalize: *unitnormsig* = V/norm(V)*
- Sampling frequency: *fs* (set it to the appropriate value)
- Create benchmark data file: *save(* my_benchmark_file, *'fs', 'unitnormsig')*

Generate *N* data realizations.
*gensimdata(*
