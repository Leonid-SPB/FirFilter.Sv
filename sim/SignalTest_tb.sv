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

// Signal processing test: 
//   read input signal, perform filtering, 
//   compare result with golden signal and dumb to output file
module SignalTest_tb
(
);
/// TB params
timeunit 1ns;
localparam CLK_CYCLE    = 10ns;
localparam RESP_TIMEOUT = 100;

/// Fir filter params
localparam INPUT_WIDTH       = 16;
localparam COEFF_WIDTH       = 16;
localparam OUTPUT_WIDTH      = 33;
localparam OUTPUT_WIDTH_FULL = 33;

localparam SYMMETRY     = 1; // 0 - Non-symmetric, 1 - Symmetric, 2 - Anti-symmetric
localparam NUM_TAPS     = 40;
localparam logic [COEFF_WIDTH - 1: 0] COEFFS [0: NUM_TAPS - 1] = '{-283, -858, -1082, -421, 643, 708, -430, -1101, 43, 1473, 665, -1682, -1741, 1510, 3302, -609, -5762, -2213, 12277, 26313, 26313, 12277, -2213, -5762, -609, 3302, 1510, -1741, -1682, 665, 1473, 43, -1101, -430, 708, 643, -421, -1082, -858, -283};

localparam PIPELINE_MUL       = 1; // pipeline register for multiplier
localparam PIPELINE_PREADD    = 1; // pipeline pre-adder (for symmetric/anti-symmetric filters)
localparam PIPELINE_ADD_RATIO = 1; // pipeline ratio for adders (0 - no registers, 1 - register for each adder, 
                                   //                            2 - register for every other adder, 3 - ...)
localparam OUTPUT_REG         = 1; // filter output register

//-------------------------------------------------------------------------------------------

// DUT i/f signals
// in
logic                       clk      = '0;
logic                       rst      = '0;
logic                       valid_in = '0;
logic [INPUT_WIDTH - 1: 0]  din      = '0;

// out
logic                       valid_out;
logic [OUTPUT_WIDTH - 1: 0] dout;

// in/out files
string InFileNameRe  = "sigdata_re.dax";
string InFileNameIm  = "sigdata_im.dax";
string RefFileNameRe = "refdata_re.dax";
string RefFileNameIm = "refdata_im.dax";
string OutFileNameRe = "tstdata_re.dax";
string OutFileNameIm = "tstdata_im.dax";

int inFileRe, inFileIm, outFileRe, outFileIm;
int refFileRe, refFileIm;
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
    forever begin
        @cb;
        
        if ($fscanf(inFileRe, "%x\n", cb.din) == 1) begin
            cb.valid_in <= 1'b1;
        end else begin
            //end of file or IO error
            cb.din      <= '0;
            cb.valid_in <= 1'b0;
            return;
        end
    end
endtask

// Monitor and Checker
task automatic monitorChecker();
    forever begin
        @cb;
        if (cb.valid_out) begin
            $fwrite(outFileRe, "%x\n", cb.dout);
        end
    end
endtask

// Test control
initial
begin
    $display("*******************************************");
    $display("Fir filter signal test");
    $display("*******************************************");
    
    //open files
    inFileRe = $fopen(InFileNameRe, "r");
    if (!inFileRe) begin
        $error("Unable to open input data file for reading");
    end
    inFileIm = $fopen(InFileNameIm, "r");
    if (!inFileIm) begin
        $error("Unable to open input data file for reading");
    end
    
    refFileRe = $fopen(RefFileNameRe, "r");
    if (!refFileRe) begin
        $error("Unable to open reference data file for reading");
    end
    refFileIm = $fopen(RefFileNameIm, "r");
    if (!refFileIm) begin
        $error("Unable to open reference data file for reading");
    end
    
    outFileRe = $fopen(OutFileNameRe, "w");
    if (!outFileRe) begin
        $error("Unable to open output data file for writing");
    end
    outFileIm = $fopen(OutFileNameIm, "w");
    if (!outFileIm) begin
        $error("Unable to open output data file for writing");
    end
    
    // initial reset
    reset(10);
    
    // start checker and driver
    monChk: fork
        monitorChecker();
    join_none;
    driver();

    $display("Signal test finished SUCCESSFULLY");
    $stop(1);
    disable monitorChecker;
    $fclose(outFileRe);
    $fclose(outFileIm);
    $fclose(inFileRe);
    $fclose(inFileIm);
    $fclose(refFileRe);
    $fclose(refFileIm);
end

endmodule
