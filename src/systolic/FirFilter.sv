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

// Systolic MAC parallel FIR filter
module FirFilter
#(
    parameter INPUT_WIDTH        = 16,
    parameter COEFF_WIDTH        = 8,
    parameter OUTPUT_WIDTH       = 26, // desired output width (truncate LSB or sign-extend actual result width)
    parameter OUTPUT_WIDTH_FULL  = 26, // full precision output width

    parameter SYMMETRY           = 0,  // 0 - Non-symmetric, 1 - Symmetric, 2 - Anti-symmetric
    parameter NUM_TAPS           = 37,
    parameter logic [COEFF_WIDTH - 1: 0] COEFFS [0: NUM_TAPS - 1] = '{8, 6, 0, -7, -11, -8, 0, 10, 16, 12, 0, -16, -26, -22, 0, 38, 80, 114, 127, 114, 80, 38, 0, -22, -26, -16, 0, 12, 16, 10, 0, -8, -11, -7, 0, 6, 8},

    parameter PIPELINE_MUL       = 1, // pipeline register for multiplier
    parameter PIPELINE_PREADD    = 1, // pipeline pre-adder (for symmetric/anti-symmetric filters)
    parameter PIPELINE_ADD_RATIO = 1, // unused parameter, added for interface compatibility
    parameter OUTPUT_REG         = 1  // filter output register
)
(
    input   logic                       clk,
    input   logic                       rst,

    input   logic                       valid_in,
    output  logic                       valid_out,

    // data in/out
    input   logic [INPUT_WIDTH - 1: 0]  din,
    output  logic [OUTPUT_WIDTH - 1: 0] dout
);

generate
    if ((SYMMETRY == 1) || (SYMMETRY == 2)) begin
        FirFilterSymmetric
        #(
            .INPUT_WIDTH        (INPUT_WIDTH),
            .COEFF_WIDTH        (COEFF_WIDTH),
            .OUTPUT_WIDTH       (OUTPUT_WIDTH),
            .OUTPUT_WIDTH_FULL  (OUTPUT_WIDTH_FULL),
            .SYMMETRY           (SYMMETRY - 1),
            .NUM_TAPS           (NUM_TAPS),
            .COEFFS             (COEFFS),
            .PIPELINE_MUL       (PIPELINE_MUL),
            .PIPELINE_PREADD    (PIPELINE_PREADD),
            .OUTPUT_REG         (OUTPUT_REG)
        )
        i_FirFilterSymmetric
        (
            .*
        );
    end else begin
        FirFilterNonSymmetric
        #(
            .INPUT_WIDTH        (INPUT_WIDTH),
            .COEFF_WIDTH        (COEFF_WIDTH),
            .OUTPUT_WIDTH       (OUTPUT_WIDTH),
            .OUTPUT_WIDTH_FULL  (OUTPUT_WIDTH_FULL),
            .NUM_TAPS           (NUM_TAPS),
            .COEFFS             (COEFFS),
            .PIPELINE_MUL       (PIPELINE_MUL),
            .OUTPUT_REG         (OUTPUT_REG)
        )
        i_FirFilterNonSymmetric
        (
            .*
        );
    end
endgenerate

endmodule