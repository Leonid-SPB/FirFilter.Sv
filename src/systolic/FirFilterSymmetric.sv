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

// Systolic MAC parallel FIR filter, symmetric
module FirFilterSymmetric
#(
    parameter INPUT_WIDTH        = 16,
    parameter COEFF_WIDTH        = 8,
    parameter OUTPUT_WIDTH       = 26,
    parameter OUTPUT_WIDTH_FULL  = 26,

    parameter SYMMETRY           = 0,  // 0 - Symmetric, 1 - Anti-symmetric
    parameter NUM_TAPS           = 37,
    parameter logic [COEFF_WIDTH - 1: 0] COEFFS [0: NUM_TAPS - 1] = '{8, 6, 0, -7, -11, -8, 0, 10, 16, 12, 0, -16, -26, -22, 0, 38, 80, 114, 127, 114, 80, 38, 0, -22, -26, -16, 0, 12, 16, 10, 0, -8, -11, -7, 0, 6, 8},

    parameter PIPELINE_MUL       = 1, // pipeline register for multiplier
    parameter PIPELINE_PREADD    = 1, // pipeline pre-adder
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

/// Local parameters
localparam SymTapsNum  = (NUM_TAPS + NUM_TAPS % 2) / 2;
localparam AccWidthMin = INPUT_WIDTH + 1 + COEFF_WIDTH;             // minimal bit width of accumulator
localparam AccWidthMax = AccWidthMin - 1 + (1 << $clog2(NUM_TAPS)); // maximal bit width of accumulator

// Signals
logic [INPUT_WIDTH - 1: 0] dlTaps [0: 2 * SymTapsNum - 1];
logic [INPUT_WIDTH: 0]     ssum [SymTapsNum - 1: 0];
logic [AccWidthMin - 1: 0] prod [SymTapsNum - 1: 0];
logic [AccWidthMax - 1: 0] accum [SymTapsNum - 1: 0];
logic [OUTPUT_WIDTH_FULL - 1: 0] dout_full;
logic [OUTPUT_WIDTH - 1: 0]      dout_i;
logic valid_d, valid_pa, valid_m;
logic [$clog2(SymTapsNum): 0] dvCounter;
logic dvCounterOut;
genvar i;
genvar j;


// input stage and delay line
always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < (2 * SymTapsNum); ++i) begin
            dlTaps[i] <= '0;
        end
    end else begin
        if (valid_in) begin
            dlTaps[0] <= din;
            for (int i = 1; i < (2 * SymTapsNum); ++i) begin
                dlTaps[i] <= dlTaps[i - 1];
            end
        end
    end

    valid_d <= (~rst) & valid_in;
end

// preadder: add/sub symmetric coefficients
generate
    localparam SDIndex = (NUM_TAPS % 2) ?  (2 * SymTapsNum - 2) : (2 * SymTapsNum - 1);
    if (PIPELINE_PREADD) begin
        always_ff @(posedge clk) begin : preadd
            for (int i = 0; i < NUM_TAPS / 2; ++i) begin
                if (SYMMETRY == 0) begin // symmetric
                    ssum[i] <= $signed(dlTaps[2 * i]) + $signed(dlTaps[SDIndex]);
                end else begin // anti-symmetric
                    ssum[i] <= $signed(dlTaps[2 * i]) - $signed(dlTaps[SDIndex]);
                end
            end
            if (NUM_TAPS % 2 != 0) begin
                ssum[NUM_TAPS / 2] <= $signed(dlTaps[SDIndex]);
            end
            valid_pa <= (~rst) & valid_d;
        end
    end else begin
        for (i = 0; i < NUM_TAPS / 2; ++i) begin : preadd
            if (SYMMETRY == 0) begin // symmetric
                assign ssum[i] = $signed(dlTaps[2 * i]) + $signed(dlTaps[SDIndex]);
            end else begin // anti-symmetric
                assign ssum[i] = $signed(dlTaps[2 * i]) - $signed(dlTaps[SDIndex]);
            end
        end
        if (NUM_TAPS % 2 != 0) begin
            assign ssum[NUM_TAPS / 2] = $signed(dlTaps[SDIndex]);
        end
        assign valid_pa = valid_d;
    end
endgenerate

// systolic tree
generate
    if (PIPELINE_MUL) begin
        always_ff @(posedge clk) begin
            prod[0] <= $signed(ssum[0]) * $signed(COEFFS[0]);

            valid_m <= (~rst) & valid_pa;
        end
    end else begin
        assign prod[0] = $signed(ssum[0]) * $signed(COEFFS[0]);
        assign valid_m = valid_pa;
    end

    always_ff @(posedge clk) begin
        if (valid_m) begin
            accum[0][AccWidthMin - 1: 0] <= prod[0];
        end
    end

    // data valid counter
    always_ff @(posedge clk) begin
        if (rst) begin
            dvCounter     <= '0;
        end else begin
            if (~dvCounterOut && valid_m) begin
                dvCounter <= dvCounter + 1;
            end
        end
     end
     assign dvCounterOut = (dvCounter == SymTapsNum) ? 1'b1: 1'b0;

    for (i = 1; i < SymTapsNum; ++i) begin : mac_inst
        if (PIPELINE_MUL) begin
            always_ff @(posedge clk) begin
                prod[i] <= $signed(ssum[i]) * $signed(COEFFS[i]);
            end
        end else begin
            assign prod[i] = $signed(ssum[i]) * $signed(COEFFS[i]);
        end

        always_ff @(posedge clk) begin
            if (valid_m) begin
                accum[i][AccWidthMin + $clog2(i + 1) - 1: 0] <= $signed(prod[i]) + $signed(accum[i - 1][AccWidthMin + $clog2(i) - 1: 0]);
            end
        end
    end
endgenerate

// full precision output
assign dout_full = accum[SymTapsNum - 1][OUTPUT_WIDTH_FULL - 1: 0];

//output reg
generate
    if (OUTPUT_WIDTH <= OUTPUT_WIDTH_FULL) begin
        //truncate LSB
        assign dout_i = dout_full[OUTPUT_WIDTH_FULL - 1: OUTPUT_WIDTH_FULL - OUTPUT_WIDTH];
    end else begin
        assign dout_i = $signed(dout_full);
    end

    if (OUTPUT_REG) begin
        always_ff @(posedge clk) begin
            dout      <= (rst) ? '0   : dout_i;
            valid_out <= (rst) ? 1'b0 : dvCounterOut & valid_m;
        end
    end else begin
        assign dout      = dout_i;
        assign valid_out = dvCounterOut & valid_m;
    end
endgenerate

endmodule