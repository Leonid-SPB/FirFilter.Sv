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

// Filter delay line model
module FirFilterDelayLine
#(
    parameter DataWidth  = 16, // data ports width
    parameter TapsNum    = 10  // number of delay line taps
)
(
    // clk&rst required if enabled input or output regs
    input   logic                                       clk,
    input   logic                                       rst,

    // data in/out
    input   logic                                       valid,
    input   logic [DataWidth - 1: 0]                    din,
    output  logic [DataWidth - 1: 0] taps [0 : TapsNum - 1]
);

//internal signals
logic [DataWidth - 1: 0]  taps_regs [0: TapsNum - 1];

always_ff @(posedge clk) begin : shifter
    if (rst) begin
        for (int i = 0; i < TapsNum; ++i) begin
            taps_regs[i] <= '0;
        end
    end else begin
        if (valid) begin
            taps_regs[0] <= din;
            for (int i = 1; i < TapsNum; ++i) begin
                taps_regs[i] <= taps_regs[i - 1];
            end
        end
    end
end

always_comb
begin : outAssign
    for (int i = 0; i < TapsNum; ++i) begin
        taps[i] = taps_regs[i];
    end
end

endmodule