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
// in/out files
localparam string InFileNameRe  = "sigdata_re.dax";
localparam string InFileNameIm  = "sigdata_im.dax";
localparam string RefFileNameRe = "refdata_re.dax";
localparam string RefFileNameIm = "refdata_im.dax";
localparam string OutFileNameRe = "tstdata_re.dax";
localparam string OutFileNameIm = "tstdata_im.dax";

//-------------------------------------------------------------------------------------------
SignalTester
#(
    .TesterName         ("Tester RE:"),
    .InFileName         (InFileNameRe),
    .RefFileName        (RefFileNameRe),
    .OutFileName        (OutFileNameRe),
    .COEFFS             (COEFFS),
    .CLK_CYCLE          (CLK_CYCLE),
    .RESP_TIMEOUT       (RESP_TIMEOUT),
    .INPUT_WIDTH        (INPUT_WIDTH),
    .COEFF_WIDTH        (COEFF_WIDTH),
    .OUTPUT_WIDTH       (OUTPUT_WIDTH),
    .OUTPUT_WIDTH_FULL  (OUTPUT_WIDTH_FULL),
    .SYMMETRY           (SYMMETRY),
    .NUM_TAPS           (NUM_TAPS),
    .PIPELINE_MUL       (PIPELINE_MUL),
    .PIPELINE_PREADD    (PIPELINE_PREADD),
    .PIPELINE_ADD_RATIO (PIPELINE_ADD_RATIO),
    .OUTPUT_REG         (OUTPUT_REG)
)
i_SignalTester_re
(
);

SignalTester
#(
    .TesterName         ("Tester IM:"),
    .InFileName         (InFileNameIm),
    .RefFileName        (RefFileNameIm),
    .OutFileName        (OutFileNameIm),
    .COEFFS             (COEFFS),
    .CLK_CYCLE          (CLK_CYCLE),
    .RESP_TIMEOUT       (RESP_TIMEOUT),
    .INPUT_WIDTH        (INPUT_WIDTH),
    .COEFF_WIDTH        (COEFF_WIDTH),
    .OUTPUT_WIDTH       (OUTPUT_WIDTH),
    .OUTPUT_WIDTH_FULL  (OUTPUT_WIDTH_FULL),
    .SYMMETRY           (SYMMETRY),
    .NUM_TAPS           (NUM_TAPS),
    .PIPELINE_MUL       (PIPELINE_MUL),
    .PIPELINE_PREADD    (PIPELINE_PREADD),
    .PIPELINE_ADD_RATIO (PIPELINE_ADD_RATIO),
    .OUTPUT_REG         (OUTPUT_REG)
)
i_SignalTester_im
(
);

logic [OUTPUT_WIDTH_FULL: 0] doutAbs;
assign doutAbs = $sqrt($pow($signed(i_SignalTester_re.dout), 2) + $pow($signed(i_SignalTester_im.dout), 2));

// Test control
initial
begin
    $display("*******************************************");
    $display("Starting signal tests im/re");
    $display("*******************************************");
    
    fork
        @i_SignalTester_re.finished;
        @i_SignalTester_im.finished;
    join
    $display("*******************************************");
    $display("Signal tests finished SUCCESSFULLY");
    $stop(1);
end
endmodule
