
module blinky import config_pkg::*; #(
    parameter int CyclesPerToggle = 1_000_000,
    localparam int CountWidth = $clog2(CyclesPerToggle)
) (
    input  logic clk_i,
    input  logic rst_ni,
    output logic led_o
);

if (CyclesPerToggle < 1) $error("CyclesPerToggle cannot be less than 1.");

logic counter_reset;
logic [CountWidth-1:0] count;

logic led_d, led_q;
always_ff @(posedge clk_i) begin
    led_q <= led_d;
end
assign led_o = led_q;

always_comb begin
    counter_reset = !rst_ni;
    led_d = led_q;
    if (count == CountWidth'(CyclesPerToggle-1)) begin
        counter_reset = 1;
        led_d = !led_q;
    end
end

bsg_counter_up_down #(
    .max_val_p(CyclesPerToggle-1),
    .init_val_p(0),
    .max_step_p(1)
) bsg_counter_up_down (
    .clk_i,
    .reset_i(counter_reset),
    .up_i(1),
    .down_i(0),
    .count_o(count)
);

endmodule
