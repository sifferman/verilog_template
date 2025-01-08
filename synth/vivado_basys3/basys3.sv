
module basys3 (
    input  logic       sys_clk,
    output logic [0:0] led,
    input  logic       btnC
);

wire logic rst_n = !btnC;

logic clk_50;
mmcm_100_to_50 pll (
    .clk_100(sys_clk),
    .clk_50(clk_50)
);

blinky #(
    .ResetValue(5000000)
) blinky (
    .clk_i(clk_50),
    .rst_ni(rst_n),
    .led_o(led[0])
);

endmodule
