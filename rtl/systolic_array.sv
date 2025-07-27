
// module to generate and connect PE's to each other
module systolic_array #(
    parameter DATAWIDTH = 16,
    parameter N_SIZE = 5
) (
    input logic clk,
    input logic rst_n,
    input var logic [(DATAWIDTH) - 1:0] matrix_A [N_SIZE-1:0],   
    input var logic [(DATAWIDTH) - 1:0] matrix_B [N_SIZE-1:0],
    output logic [(DATAWIDTH*2)-1:0] matrix_C [N_SIZE-1:0][N_SIZE-1:0]
);
    // used to pass the elements row wise and column wise
    logic [DATAWIDTH-1:0] row_wire [0:N_SIZE][0:N_SIZE];
    logic [DATAWIDTH-1:0] col_wire [0:N_SIZE][0:N_SIZE];
    
    // feeding the matrices 
    genvar i;
    generate
        for (i = 0; i < N_SIZE; i = i + 1) begin
            always_comb begin
                row_wire[i][0] = matrix_A[i];
                col_wire[0][i] = matrix_B[i];
            end
        end
    endgenerate
    // instantiation of PE's
    genvar ii, jj;
    generate
        for (ii = 0; ii < N_SIZE; ii = ii + 1) begin // row loop
            for (jj = 0; jj < N_SIZE; jj = jj + 1) begin // column loop
                PE #(.DATAWIDTH(DATAWIDTH)) pe_inst(
                    .clk(clk),
                    .rst_n(rst_n),
                    .a(row_wire[ii][jj]),
                    .b(col_wire[ii][jj]),
                    .c(matrix_C[ii][jj]),
                    .a_out(row_wire[ii][jj+1]),
                    .b_out(col_wire[ii+1][jj])
                );
            end
        end
    endgenerate
endmodule