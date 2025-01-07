
module blinky_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

blinky_runner blinky_runner ();

always begin
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
