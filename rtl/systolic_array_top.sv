module systolic_array_top #(
    parameter DATAWIDTH = 16,
    parameter N_SIZE = 5
) (
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input var logic [(DATAWIDTH) - 1:0] matrix_a_in [N_SIZE-1:0],   // entered by column
    input var logic [(DATAWIDTH) - 1:0] matrix_b_in [N_SIZE-1:0],   // entered by row 
    output logic valid_out,  
    output logic [(DATAWIDTH*2) - 1:0] matrix_c_out [N_SIZE-1:0]
);
    // the cycles needed to finish the multiplication operation is 2N-1 cycles and N cycles for output

    localparam int COUNT_WIDTH = $clog2(2 * N_SIZE + 2);
    localparam int COUNT_WIDTH_out = $clog2(N_SIZE + 1);
    logic [COUNT_WIDTH-1:0] count_cycle = 0;   // clock counter  
    logic [COUNT_WIDTH-1:0] input_count = 0;   // counter for inputing the data
    logic [COUNT_WIDTH_out-1:0] count_out = 0; // counter for the output counts cycles 

    logic computation_started = 0; // to triger the start  and start count cycles
    logic computation_done = 0;    // to triger the end  and start outputing

    // data registers
    logic [(DATAWIDTH) - 1:0] full_matrix_a [N_SIZE-1:0][(N_SIZE*2)-2:0] = '{default: '{default: '0}}; // full skewd matrix
    logic [(DATAWIDTH) - 1:0] full_matrix_b [(N_SIZE*2)-2:0][N_SIZE-1:0] = '{default: '{default: '0}};
    logic [(DATAWIDTH*2)-1:0] output_full_matrix [N_SIZE-1:0][N_SIZE-1:0];

    logic [(DATAWIDTH) - 1:0] a_feed_col [N_SIZE-1:0]; // array fed to the PE
    logic [(DATAWIDTH) - 1:0] b_feed_row [N_SIZE-1:0];

    // Input data storage block
    integer i;
    always_ff @(posedge clk, negedge rst_n) begin : INPUT_BLOCK
        if (!rst_n) begin
            full_matrix_a <= '{default: '{default: '0}};
            full_matrix_b <= '{default: '{default: '0}};
            input_count <= 0;
        end
        else if (valid_in && input_count < N_SIZE) begin
            for (i = 0; i < N_SIZE; i++) begin
                // Matrix A: Store column-wise input with proper skewing for rows
                full_matrix_a[i][input_count + i] <= matrix_a_in[i];
                // Matrix B: Store row-wise input with proper skewing for columns  
                full_matrix_b[input_count + i][i] <= matrix_b_in[i];
            end
            input_count <= input_count + 1;
        end
    end: INPUT_BLOCK
    
    // Control logic to set control signals and count clk cycles
    always_ff @(posedge clk, negedge rst_n) begin :CONTROL_UNIT_BLOCK
        if (!rst_n) begin
            computation_started <= 0;
            count_cycle <= 0;
            computation_done <= 0;
        end
        else begin
            // Start computation once valid input is high
            if (valid_in && !computation_started) begin
                computation_started <= 1;
                count_cycle <= 0;  // Start counting from 0
            end
            // Continue counting once started
            else if (computation_started) begin
                if (count_cycle < (2*N_SIZE)-1) begin
                    count_cycle <= count_cycle + 1;
                end
                else if (!computation_done) begin
                    computation_done <= 1;
                end
            end
        end
    end :CONTROL_UNIT_BLOCK
    
    // Feed data to systolic array block
    // this block takes column of full_matrix_a and raw from full_matrix_b to feed it to the PE
    integer j;
    always_ff @(posedge clk, negedge rst_n) begin :FEED_to_PE_BLOCK
        if (!rst_n) begin
            a_feed_col <= '{default: '0};
            b_feed_row <= '{default: '0};
        end
        else if (computation_started && count_cycle < (2*N_SIZE)-1) begin
            for (int j = 0; j < N_SIZE; j++) begin
                a_feed_col[j] <= full_matrix_a[j][count_cycle];
                b_feed_row[j] <= full_matrix_b[count_cycle][j];
            end
        end
        else begin
            a_feed_col <= '{default: '0};
            b_feed_row <= '{default: '0};
        end
    end :FEED_to_PE_BLOCK
    // instentation
    systolic_array #(
        .DATAWIDTH(DATAWIDTH),
        .N_SIZE(N_SIZE)
    ) STR_ins (
        .clk(clk),
        .rst_n(rst_n),
        .matrix_A(a_feed_col),
        .matrix_B(b_feed_row),
        .matrix_C(output_full_matrix)
    );

    // Output block outputs data raw by raw over N-cycles
    integer k;
    always_ff @(posedge clk, negedge rst_n) begin : OUTPUT_BLOCK
        if (!rst_n) begin
            valid_out <= 0;
            matrix_c_out <= '{default: '0};
            count_out <= 0;
        end 
        else begin
            if (computation_done && count_out < N_SIZE) begin
                valid_out <= 1;
                for (k = 0; k < N_SIZE; k++) begin
                    matrix_c_out[k] <= output_full_matrix[count_out][k];
                end
                count_out <= count_out + 1;
            end
            else if (count_out >= N_SIZE) begin
                valid_out <= 0;
            end
        end
    end : OUTPUT_BLOCK
endmodule
