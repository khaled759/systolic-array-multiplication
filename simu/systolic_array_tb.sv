`timescale 1ns / 1ps
module systolic_array_tb;
    // Parameters
    parameter DATAWIDTH = 16;
    parameter N_SIZE = 3;
    // Signals
    logic clk;
    logic rst_n;
    logic valid_in;
    logic [(DATAWIDTH - 1):0] matrix_a_in [N_SIZE-1:0];
    logic [(DATAWIDTH - 1):0] matrix_b_in [N_SIZE-1:0];
    logic [(DATAWIDTH*2)-1:0] matrix_c_out [N_SIZE-1:0];
    logic valid_out;
    
    // Arrays to store complete input matrices for display
    logic [(DATAWIDTH - 1):0] matrix_a_display [N_SIZE-1:0][N_SIZE-1:0];
    logic [(DATAWIDTH - 1):0] matrix_b_display [N_SIZE-1:0][N_SIZE-1:0];
    
    // Instantiate DUT
    systolic_array_top #(
        .DATAWIDTH(DATAWIDTH),
        .N_SIZE(N_SIZE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .matrix_a_in(matrix_a_in),
        .matrix_b_in(matrix_b_in),
        .matrix_c_out(matrix_c_out),
        .valid_out(valid_out)
    );
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Task to display matrix A
    task display_matrix_a;
        begin
            $display("Matrix A (fed column-wise):");
            for (int row = 0; row < N_SIZE; row++) begin
                $display("%0d %0d %0d", matrix_a_display[row][0], matrix_a_display[row][1], matrix_a_display[row][2]);
            end
            $display("");
        end
    endtask
    
    // Task to display matrix B
    task display_matrix_b;
        begin
            $display("Matrix B (fed row-wise):");
            for (int row = 0; row < N_SIZE; row++) begin
                $display("%0d %0d %0d", matrix_b_display[row][0], matrix_b_display[row][1], matrix_b_display[row][2]);
            end
            $display("");
        end
    endtask
    
    // A     1  2  3
    //       4  5  6
    //       7  8  9
    // A = B
    // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        valid_in = 0;
        #15;
        rst_n = 1;
        
        $display("=== First Matrix Multiplication ===");
        
        // Feed matrix A column-wise and matrix B row-wise for N cycles
        @(negedge clk);
        matrix_a_in[0] = 1;  // A[0][0] = 1
        matrix_a_in[1] = 4;  // A[1][0] = 4  
        matrix_a_in[2] = 7;  // A[2][0] = 7
        matrix_b_in[0] = 1;  // B[0][0] = 1
        matrix_b_in[1] = 2;  // B[0][1] = 2
        matrix_b_in[2] = 3;  // B[0][2] = 3
        valid_in = 1;
        
        // Store for display - Column 0 of A, Row 0 of B
        matrix_a_display[0][0] = matrix_a_in[0];
        matrix_a_display[1][0] = matrix_a_in[1]; 
        matrix_a_display[2][0] = matrix_a_in[2];
        matrix_b_display[0][0] = matrix_b_in[0];
        matrix_b_display[0][1] = matrix_b_in[1];
        matrix_b_display[0][2] = matrix_b_in[2];
        
        @(negedge clk);
        matrix_a_in[0] = 2;  // A[0][1] = 2
        matrix_a_in[1] = 5;  // A[1][1] = 5
        matrix_a_in[2] = 8;  // A[2][1] = 8
        matrix_b_in[0] = 4;  // B[1][0] = 4
        matrix_b_in[1] = 5;  // B[1][1] = 5
        matrix_b_in[2] = 6;  // B[1][2] = 6
        valid_in = 1;
        
        // Store for display - Column 1 of A, Row 1 of B
        matrix_a_display[0][1] = matrix_a_in[0];
        matrix_a_display[1][1] = matrix_a_in[1];
        matrix_a_display[2][1] = matrix_a_in[2];
        matrix_b_display[1][0] = matrix_b_in[0];
        matrix_b_display[1][1] = matrix_b_in[1];
        matrix_b_display[1][2] = matrix_b_in[2];
        
        @(negedge clk);
        matrix_a_in[0] = 3;  // A[0][2] = 3
        matrix_a_in[1] = 6;  // A[1][2] = 6
        matrix_a_in[2] = 9;  // A[2][2] = 9
        matrix_b_in[0] = 7;  // B[2][0] = 7
        matrix_b_in[1] = 8;  // B[2][1] = 8
        matrix_b_in[2] = 9;  // B[2][2] = 9
        valid_in = 1;
        
        // Store for display - Column 2 of A, Row 2 of B
        matrix_a_display[0][2] = matrix_a_in[0];
        matrix_a_display[1][2] = matrix_a_in[1];
        matrix_a_display[2][2] = matrix_a_in[2];
        matrix_b_display[2][0] = matrix_b_in[0];
        matrix_b_display[2][1] = matrix_b_in[1];
        matrix_b_display[2][2] = matrix_b_in[2];
        
        // Display the input matrices
        display_matrix_a();
        display_matrix_b();
        
        // Disable input after feeding
        @(negedge clk);
        valid_in = 0;
        matrix_a_in = '{default: 0};
        matrix_b_in = '{default: 0};
        
        // Wait for output rows
        $display("Result Matrix C = A × B:");
        wait (valid_out == 1);
        for (int i = 0; i < N_SIZE; i++) begin
            @(posedge clk);
            $display("%0d %0d %0d", matrix_c_out[0], matrix_c_out[1], matrix_c_out[2]);
        end
        $display("");
        
        rst_n = 0;
        valid_in = 0;
        #15;
        rst_n = 1;
        
        $display("=== Second Matrix Multiplication ===");
        
        // Feed different matrices: A = [2 1 3; 0 4 2; 1 3 5], B = [1 0 2; 3 1 4; 2 2 1]
        @(negedge clk);
        matrix_a_in[0] = 2;  // A[0][0] = 2
        matrix_a_in[1] = 0;  // A[1][0] = 0
        matrix_a_in[2] = 1;  // A[2][0] = 1
        matrix_b_in[0] = 1;  // B[0][0] = 1
        matrix_b_in[1] = 0;  // B[0][1] = 0
        matrix_b_in[2] = 2;  // B[0][2] = 2
        valid_in = 1;
        
        // Store for display - Column 0 of A, Row 0 of B
        matrix_a_display[0][0] = matrix_a_in[0];
        matrix_a_display[1][0] = matrix_a_in[1];
        matrix_a_display[2][0] = matrix_a_in[2];
        matrix_b_display[0][0] = matrix_b_in[0];
        matrix_b_display[0][1] = matrix_b_in[1];
        matrix_b_display[0][2] = matrix_b_in[2];
        
        @(negedge clk);
        matrix_a_in[0] = 1;  // A[0][1] = 1
        matrix_a_in[1] = 4;  // A[1][1] = 4
        matrix_a_in[2] = 3;  // A[2][1] = 3
        matrix_b_in[0] = 3;  // B[1][0] = 3
        matrix_b_in[1] = 1;  // B[1][1] = 1
        matrix_b_in[2] = 4;  // B[1][2] = 4
        valid_in = 1;
        
        // Store for display - Column 1 of A, Row 1 of B
        matrix_a_display[0][1] = matrix_a_in[0];
        matrix_a_display[1][1] = matrix_a_in[1];
        matrix_a_display[2][1] = matrix_a_in[2];
        matrix_b_display[1][0] = matrix_b_in[0];
        matrix_b_display[1][1] = matrix_b_in[1];
        matrix_b_display[1][2] = matrix_b_in[2];
        
        @(negedge clk);
        matrix_a_in[0] = 3;  // A[0][2] = 3
        matrix_a_in[1] = 2;  // A[1][2] = 2
        matrix_a_in[2] = 5;  // A[2][2] = 5
        matrix_b_in[0] = 2;  // B[2][0] = 2
        matrix_b_in[1] = 2;  // B[2][1] = 2
        matrix_b_in[2] = 1;  // B[2][2] = 1
        valid_in = 1;
        
        // Store for display - Column 2 of A, Row 2 of B
        matrix_a_display[0][2] = matrix_a_in[0];
        matrix_a_display[1][2] = matrix_a_in[1];
        matrix_a_display[2][2] = matrix_a_in[2];
        matrix_b_display[2][0] = matrix_b_in[0];
        matrix_b_display[2][1] = matrix_b_in[1];
        matrix_b_display[2][2] = matrix_b_in[2];
        
        // Display the input matrices
        display_matrix_a();
        display_matrix_b();
        
        // Disable input after feeding
        @(negedge clk);
        valid_in = 0;
        matrix_a_in = '{default: 0};
        matrix_b_in = '{default: 0};
        
        // Wait for output rows
        $display("Result Matrix C = A × B:");
        wait (valid_out == 1);
        for (int i = 0; i < N_SIZE; i++) begin
            @(posedge clk);
            $display("%0d %0d %0d", matrix_c_out[0], matrix_c_out[1], matrix_c_out[2]);
        end
        
        #20;
        $stop;
    end
endmodule