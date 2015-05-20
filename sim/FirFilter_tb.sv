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

module FirFilter_tb
(
);
/// TB params
timeunit 1ns;
localparam CLK_CYCLE    = 10ns;

/// Fir filter params
localparam INPUT_WIDTH  = 16;
localparam COEFF_WIDTH  = 8;
localparam OUTPUT_WIDTH = 26;

localparam SYMMETRY     = 0; // 0 - Non-symmetric, 1 - Symmetric, 2 - Anti-symmetric
localparam NUM_TAPS     = 37;
localparam logic [COEFF_WIDTH - 1: 0] COEFFS [0: NUM_TAPS - 1] = '{8, 6, 0, -7, -11, -8, 0, 10, 16, 12, 0, -16, -26, -22, 0, 38, 80, 114, 127, 114, 80, 38, 0, -22, -26, -16, 0, 12, 16, 10, 0, -8, -11, -7, 0, 6, 8};

localparam PIPELINE_MUL       = 1; // pipeline register for multiplier
localparam PIPELINE_ADD_RATIO = 1; // pipeline ratio for adders (1 - register for each adder, 2 - register for every other adder, 3 - ...)
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


//-------------------------------------------------------------------------------------------

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
    .SYMMETRY           (SYMMETRY),
    .NUM_TAPS           (NUM_TAPS),
    .COEFFS             (COEFFS),
    .PIPELINE_MUL       (PIPELINE_MUL),
    .PIPELINE_ADD_RATIO (PIPELINE_ADD_RATIO),
    .OUTPUT_REG         (OUTPUT_REG)
)
DUT
(
    .*
);


task automatic stepResponse();
    $display("stepResponse test");

    @cb;
    cb.rst        <= 1'b1;
    ##10;
    cb.rst        <= 1'b0;
    ##4;
    
    cb.din[INPUT_WIDTH - 1]    <= '1;
    cb.din[INPUT_WIDTH - 2: 0] <= '0;
    cb.valid_in <= 1'b1;
    ##(NUM_TAPS);
    cb.din <= '0;
    cb.valid_in <= 1'b0;
    
    ##200;
endtask

task automatic pulseResponse();
    $display("pulseResponse test");

    @cb;
    cb.rst        <= 1'b1;
    ##10;
    cb.rst        <= 1'b0;
    ##4;
    
    cb.din[INPUT_WIDTH - 1]    <= '1;
    cb.din[INPUT_WIDTH - 2: 0] <= '0;
    cb.valid_in <= 1'b1;
    ##1
    cb.din <= '0;
    ##(NUM_TAPS - 1);
    
    ##200;
endtask

task automatic resetResponse();
    $display("resetResponse test");

    @cb;
    cb.rst        <= 1'b1;
    ##10;
    cb.rst        <= 1'b0;
    ##4;
    
    ##200;
endtask

// Test control
initial
begin
    $display("*******************************************");
    $display("Fir filter test");
    $display("*******************************************");

    pulseResponse();
    stepResponse();
    resetResponse();
    
    $stop(1);
end

endmodule
