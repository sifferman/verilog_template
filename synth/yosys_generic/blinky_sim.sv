
module blinky_sim (
    input  logic clk_i,
    input  logic rst_ni,
    output logic led_o
);

blinky #(
    .ResetValue(100)
) blinky (.*);

endmodule
