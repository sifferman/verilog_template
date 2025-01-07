
module blinky_runner;

reg CLK;
reg BTN_N = 0;
wire LEDG_N;

wire led = !LEDG_N;

initial begin
    CLK = 0;
    forever begin
        #41.666ns; // 12MHz
        CLK = !CLK;
    end
end

logic pll_out;
initial begin
    pll_out = 0;
    forever begin
        #50.000ns; // 20MHz
        pll_out = !pll_out;
    end
end
assign icebreaker.pll.PLLOUTCORE = pll_out;

icebreaker icebreaker (.*);

always @(posedge led) $info("Led on");
always @(negedge led) $info("Led off");

task automatic reset;
    BTN_N <= 0;
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
