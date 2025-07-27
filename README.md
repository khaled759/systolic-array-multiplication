# systolic-array-multiplication
N*N systolic array multiplication using multiply and accumulate processing element


# you can find how  the input is being handeld, PE structure and the methodolgy inside the report pdf.


# input format 
matrix a is fed column wise to a vector of N size--> (matrix_a_in).

matrix b is fed row wise to a vector of N size--> (matrix_b_in).

active low rst_n.

valid_in input indecate the the input port hava a valid data to sample.

# code Structure 
  -->rtl

      |--> systolic_array_top  : top module to handle and process the input to feed it to systolic array with the right sequence and at the right timing.
      |
      |--> systolic_array : the module where the stucture of the PE's is implemented
      |
      |--> PE :  multiply and accumulate processing element.

# code performance
  for an N*N matrix it takes 2N - 1 clock cycles to calculate the results and an N clock cycle for outputing the data as its outputed raw by raw.
