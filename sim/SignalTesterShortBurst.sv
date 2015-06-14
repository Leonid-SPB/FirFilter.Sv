// This file is part of FirFilter.Sv (Trivial SystemVerilog implementation
// of FIR filters)
//
// Copyright (C) 2015  Leonid Azarenkov < leonid AT rezonics DOT com >
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Signal processing tester, short burst mode:
//   read input signal, perform filtering,
//   compare result with golden signal and dumb to output file
module SignalTester
#(
    parameter string TesterName,
    parameter string InFileName,
    parameter string RefFileName,
    parameter string OutFileName,

    parameter CLK_CYCLE,
    parameter RESP_TIMEOUT,
    parameter INPUT_WIDTH,
    parameter COEFF_WIDTH,
    parameter OUTPUT_WIDTH,
    parameter OUTPUT_WIDTH_FULL,
    parameter SYMMETRY,
    parameter NUM_TAPS,
    parameter logic [COEFF_WIDTH - 1: 0] COEFFS [0: NUM_TAPS - 1],
    parameter PIPELINE_MUL,
    parameter PIPELINE_PREADD,
    parameter PIPELINE_ADD_RATIO,
    parameter OUTPUT_REG
)
(
);

timeunit 1ns;
localparam Seed = 1231;
localparam BurstGapMax    = 3;
localparam BurstLengthMax = 8;

//-------------------------------------------------------------------------------------------

// DUT i/f signals
// in
logic                       clk      = '0;
logic                       rst      = '1;
logic                       valid_in = '0;
logic [INPUT_WIDTH - 1: 0]  din      = '0;

// out
logic                       valid_out;
logic [OUTPUT_WIDTH - 1: 0] dout;

// files
int inFile, outFile, refFile;

// sync events
event finished;
//-------------------------------------------------------------------------------------------

/// calculate full precision output width
function automatic int calcOutWidthFull();
    longint Acc = 0;

    for (int i = 0; i < NUM_TAPS; ++i) begin
        longint tmp = $signed(COEFFS[i]);
        tmp = (tmp >= 0) ? tmp : -tmp;
        Acc += tmp;
    end

    return $clog2(Acc) + INPUT_WIDTH;
endfunction

// Clock generator
initial
begin
    forever #(CLK_CYCLE/2) clk = ~clk;
end

// default clocking block
default clocking cb @(posedge clk);
    input  valid_out, dout;
    output rst, valid_in, din;
endclocking


// DUT instance
FirFilter
#(
    .INPUT_WIDTH        (INPUT_WIDTH),
    .COEFF_WIDTH        (COEFF_WIDTH),
    .OUTPUT_WIDTH       (OUTPUT_WIDTH),
    .OUTPUT_WIDTH_FULL  (OUTPUT_WIDTH_FULL),
    .SYMMETRY           (SYMMETRY),
    .NUM_TAPS           (NUM_TAPS),
    .COEFFS             (COEFFS),
    .PIPELINE_MUL       (PIPELINE_MUL),
    .PIPELINE_PREADD    (PIPELINE_PREADD),
    .PIPELINE_ADD_RATIO (PIPELINE_ADD_RATIO),
    .OUTPUT_REG         (OUTPUT_REG)
)
DUT
(
    .*
);

// Reset sequence
task automatic reset(int duration);
    @cb;
    cb.rst        <= 1'b1;
    ##duration;
    cb.rst        <= 1'b0;
    ##4;
endtask

// Driver
task automatic driver();
    integer res = 0;
    int step = 0;
    int tmp = $urandom(Seed);

    @cb;
    forever begin
        int burstGap = $urandom() % BurstGapMax;
        int burstLen = $urandom() % BurstLengthMax + 1;

        //wait delay cycles
        cb.din      <= '0;
        cb.valid_in <= 1'b0;
        ##burstGap;

        for (int i = 0; i < burstLen; ++i) begin
            res = $fscanf(inFile, "%x\n", cb.din);
            if (res == 1) begin
                cb.valid_in <= 1'b1;
            end else if (res == -1) begin
                //end of file
                cb.din      <= '0;
                cb.valid_in <= 1'b0;
                return;
            end else begin
                //io error
                $error("%s: Unable to read input data file at step %0d", TesterName, step);
                $display("%s: test FAILED", TesterName);
                $stop(1);
            end
            ##1;
            ++step;
        end
    end
endtask

// Monitor and Checker
task automatic monitorChecker();
    logic [OUTPUT_WIDTH - 1: 0] refDout;
    int step = 0;

    forever begin
        @cb;

        if (cb.valid_out) begin
            //check
            if ($fscanf(refFile, "%x\n", refDout) != 1) begin
                $error("%s: Unable to read reference data file at step %0d", TesterName, step);
                $display("%s: test FAILED", TesterName);
                $stop(1);
            end
            assert($signed(refDout) == $signed(cb.dout))
            else begin
                $error("%s: Filter output (%0d) doesn't match reference (%0d) at step %0d", TesterName, $signed(cb.dout), $signed(refDout), step);
                $display("%s: test FAILED", TesterName);
                $stop(1);
            end

            //dump
            $fwrite(outFile, "%x\n", cb.dout);
            ++step;
        end
    end
endtask

// Test control
initial
begin
    ##1;
    $display("%s: short burst signal test started", TesterName);

    if (OUTPUT_WIDTH_FULL != calcOutWidthFull()) begin
        $error("%s: OUTPUT_WIDTH_FULL parameter doesn't match actual full bit width", TesterName);
        $display("%s: test FAILED", TesterName);
        $stop(1);
    end

    //open files
    inFile = $fopen(InFileName, "r");
    if (!inFile) begin
        $error("%s: Unable to open input data file for reading", TesterName);
        $display("%s: test FAILED", TesterName);
        $stop(1);
    end
    refFile = $fopen(RefFileName, "r");
    if (!refFile) begin
        $error("%s: Unable to open reference data file for reading", TesterName);
        $display("%s: test FAILED", TesterName);
        $stop(1);
    end
    outFile = $fopen(OutFileName, "w");
    if (!outFile) begin
        $error("%s: Unable to open output data file for writing", TesterName);
        $display("%s: test FAILED", TesterName);
        $stop(1);
    end

    // initial reset
    reset(10);

    // start checker and driver
    monChk: fork
        monitorChecker();
    join_none;
    driver();
    ##RESP_TIMEOUT;

    $display("%s: short burst signal test finished SUCCESSFULLY", TesterName);
    disable monitorChecker;
    $fclose(outFile);
    $fclose(inFile);
    $fclose(refFile);
    ->finished;
end

endmodule
