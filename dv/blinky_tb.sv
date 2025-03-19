
module blinky_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

import "DPI-C" function void example_dpi();
blinky_runner blinky_runner ();

initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);
    $timeformat( -3, 3, "ms", 0);

    blinky_runner.reset();

    repeat(4) begin
        blinky_runner.wait_for_on();
        blinky_runner.wait_for_off();
    end

    $display( "End simulation." );
    $finish;
end

endmodule
