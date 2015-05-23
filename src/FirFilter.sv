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


module FirFilter
#(
    parameter INPUT_WIDTH        = 16,
    parameter COEFF_WIDTH        = 8,
    parameter OUTPUT_WIDTH       = 16, // desired output width (truncate LSB or sign-extend actual result width)
    parameter OUTPUT_WIDTH_FULL  = 26, // full precision output width

    parameter SYMMETRY           = 1, // 0 - Non-symmetric, 1 - Symmetric, 2 - Anti-symmetric
    parameter NUM_TAPS           = 37,
    parameter logic [COEFF_WIDTH - 1: 0] COEFFS [0: NUM_TAPS - 1] = '{8, 6, 0, -7, -11, -8, 0, 10, 16, 12, 0, -16, -26, -22, 0, 38, 80, 114, 127, 114, 80, 38, 0, -22, -26, -16, 0, 12, 16, 10, 0, -8, -11, -7, 0, 6, 8},

    parameter PIPELINE_MUL       = 1, // pipeline register for multiplier
    parameter PIPELINE_PREADD    = 1, // pipeline pre-adder (for symmetric/anti-symmetric filters)
    parameter PIPELINE_ADD_RATIO = 1, // pipeline ratio for adders (0 - no registers, 1 - register for each adder,
                                      //                            2 - register for every other adder, 3 - ...)
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

// signals
logic valid_dl, valid_to;
logic [INPUT_WIDTH - 1: 0] dlTaps [0: NUM_TAPS - 1];
logic [COEFF_WIDTH - 1: 0] coeffs [0: NUM_TAPS - 1];
logic [OUTPUT_WIDTH_FULL - 1: 0] dout_full;
logic [OUTPUT_WIDTH - 1: 0] dout_i;
genvar i;

// delay line
always_ff @(posedge clk) begin
    valid_dl <= (~rst) & valid_in;
end

FirFilterDelayLine
#(
    .DataWidth (INPUT_WIDTH),
    .TapsNum   (NUM_TAPS)
)
i_DelayLine
(
    .clk       (clk),
    .rst       (rst),
    .valid     (valid_in),
    .din       (din),
    .taps      (dlTaps)
);

generate
    for (i = 0; i < NUM_TAPS; ++i) begin : coeff_assign
        assign coeffs[i] = $signed(COEFFS[i]);
    end

    if ((SYMMETRY == 1) || (SYMMETRY == 2)) begin
        localparam NUM_TAPS_S = (NUM_TAPS + NUM_TAPS % 2) / 2; //number of taps after symmetry reduction
        logic [INPUT_WIDTH: 0] paTaps [0: NUM_TAPS_S - 1];
        logic valid_pa;

        // preadder: add/sub symmetric coefficients
        if (PIPELINE_PREADD) begin
            always_ff @(posedge clk) begin : preadd
                for (int i = 0; i < NUM_TAPS / 2; ++i) begin
                    if (SYMMETRY == 1) begin // symmetric
                        paTaps[i] <= $signed(dlTaps[i]) + $signed(dlTaps[NUM_TAPS - 1 - i]);
                    end else begin // anti-symmetric
                        paTaps[i] <= $signed(dlTaps[i]) - $signed(dlTaps[NUM_TAPS - 1 - i]);
                    end
                end
                if (NUM_TAPS % 2 != 0) begin
                    paTaps[NUM_TAPS / 2] <= $signed(dlTaps[NUM_TAPS / 2]);
                end

                valid_pa <= (~rst) & valid_dl;
            end
        end else begin
            for (i = 0; i < NUM_TAPS / 2; ++i) begin : preadd
                if (SYMMETRY == 1) begin // symmetric
                    assign paTaps[i] = $signed(dlTaps[i]) + $signed(dlTaps[NUM_TAPS - 1 - i]);
                end else begin // anti-symmetric
                    assign paTaps[i] = $signed(dlTaps[i]) - $signed(dlTaps[NUM_TAPS - 1 - i]);
                end
            end
            if (NUM_TAPS % 2 != 0) begin
                assign paTaps[NUM_TAPS / 2] = $signed(dlTaps[NUM_TAPS / 2]);
            end
            assign valid_pa = valid_dl;
        end

        FirFilterBTree
        #(
            .SAMPLE_WIDTH       (INPUT_WIDTH + 1),
            .COEFF_WIDTH        (COEFF_WIDTH),
            .NUM_TAPS           (NUM_TAPS_S),
            .OUTPUT_WIDTH       (OUTPUT_WIDTH_FULL),
            .PIPELINE_MUL       (PIPELINE_MUL),
            .PIPELINE_ADD_RATIO (PIPELINE_ADD_RATIO),
            .OUTPUT_REG         (0)
        )
        i_FirFilterBTree
        (
            .clk      (clk),
            .rst      (rst),
            .valid_in (valid_pa),
            .valid_out(valid_to),
            .samples  (paTaps),
            .coeffs   (coeffs[0: NUM_TAPS_S - 1]),
            .dout     (dout_full)
        );
    end else begin //non-symmetric
        FirFilterBTree
        #(
            .SAMPLE_WIDTH       (INPUT_WIDTH),
            .COEFF_WIDTH        (COEFF_WIDTH),
            .NUM_TAPS           (NUM_TAPS),
            .OUTPUT_WIDTH       (OUTPUT_WIDTH_FULL),
            .PIPELINE_MUL       (PIPELINE_MUL),
            .PIPELINE_ADD_RATIO (PIPELINE_ADD_RATIO),
            .OUTPUT_REG         (0)
        )
        i_FirFilterBTree
        (
            .clk      (clk),
            .rst      (rst),
            .valid_in (valid_dl),
            .valid_out(valid_to),
            .samples  (dlTaps),
            .coeffs   (coeffs),
            .dout     (dout_full)
        );
    end

    //output
    if (OUTPUT_WIDTH <= OUTPUT_WIDTH_FULL) begin
        //truncate LSB
        assign dout_i = dout_full[OUTPUT_WIDTH_FULL - 1: OUTPUT_WIDTH_FULL - OUTPUT_WIDTH];
    end else begin
        assign dout_i = $signed(dout_full);
    end

    if (OUTPUT_REG) begin
        always_ff @(posedge clk) begin
            dout      <= (rst) ? '0   : dout_i;
            valid_out <= (rst) ? 1'b0 : valid_to;
        end
    end else begin
        assign dout      = dout_i;
        assign valid_out = valid_to;
    end
endgenerate

endmodule