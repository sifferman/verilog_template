
module icebreaker (
    input  wire CLK,
    input  wire BTN_N,
    output wire LEDG_N
);

wire clk_12 = CLK;
wire clk_16;

wire led;
assign LEDG_N = !led;

// icepll -i 12 -o 16
SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'd0),
    .DIVF(7'd84),
    .DIVQ(3'd6),
    .FILTER_RANGE(3'd1)
) pll (
    .LOCK(),
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PACKAGEPIN(clk_12),
    .PLLOUTGLOBAL(clk_16)
);

blinky #(
    .CyclesPerToggle(8_000_000)
) blinky (
    .clk_i(clk_16),
    .rst_ni(BTN_N),
    .led_o(led)
);

endmodule
