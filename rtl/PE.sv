module PE #(
    parameter DATAWIDTH = 16
) (
    input logic clk,
    input logic rst_n,
    input logic [DATAWIDTH - 1:0] a, b,
    output logic [(DATAWIDTH*2) - 1:0] c,
    output logic [DATAWIDTH - 1:0] a_out, // to pass data to next PE
    output logic [DATAWIDTH - 1:0] b_out  // to pass data to next PE
);
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 0;
            b_out <= 0;
            c <= 0;
        end
        else begin
            c <= c + (a * b); // multiply and accumulate
            a_out <= a;       // pass data to next PE
            b_out <= b;       // pass data to next PE
        end
    end
endmodule
