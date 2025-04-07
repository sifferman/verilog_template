
module blinky_runner;

reg CLK;
reg BTN_N;
wire LEDG_N;

wire led = !LEDG_N;

localparam realtime InputClockFrequency = 12_000_000;
localparam realtime InputClockPeriod = (1s / InputClockFrequency);
initial begin
    CLK = 0;
    forever begin
        #(InputClockPeriod/2);
        CLK = !CLK;
    end
end

localparam realtime PllClockFrequency = 16_000_000;
localparam realtime PllClockPeriod = (1s / PllClockFrequency);
logic pll_out;
initial begin
    pll_out = 0;
    forever begin
        #(PllClockPeriod/2);
        pll_out = !pll_out;
    end
end
assign icebreaker.pll.PLLOUTGLOBAL = pll_out;

icebreaker icebreaker (.*);

always @(posedge led) $info("Led on");
always @(negedge led) $info("Led off");

task automatic reset;
    BTN_N <= 0;
    @(posedge CLK);
    @(posedge CLK);
    BTN_N <= 1;
endtask

task automatic wait_for_on;
    while (!led) @(posedge led);
endtask

task automatic wait_for_off;
    while (led) @(negedge led);
endtask

endmodule
