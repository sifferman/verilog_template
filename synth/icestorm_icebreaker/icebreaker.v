
module icebreaker (
    input  wire CLK,
    input  wire BTN_N,
    output wire LEDG_N
);

wire clk_12 = CLK;
wire clk_50;

wire led;
assign LEDG_N = !led;

// icepll -i 12 -o 50
SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'd0),
    .DIVF(7'd66),
    .DIVQ(3'd4),
    .FILTER_RANGE(3'd1)
) pll (
    .LOCK(),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PACKAGEPIN(clk_12),
    .PLLOUTCORE(clk_50)
);

blinky #(
    .ResetValue(5000000)
) blinky (
    .clk_i(clk_50),
    .rst_ni(BTN_N),
    .led_o(led)
);

endmodule
