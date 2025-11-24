// ===============================================================
// Created by (your name) based on modules from Prof. Mingu Kang
// VVIP Lab - UCSD ECE Department
// Corelet Module: Integrates L0 → MAC Array → SFU → OFIFO
// ===============================================================

module corelet #(
    parameter bw        = 4,    // weight bitwidth
    parameter psum_bw   = 32,   // psum bitwidth
    parameter row       = 8,    // number of MAC rows
    parameter col       = 8     // number of MAC cols
)(
    input                       clk,
    input                       reset,

    // ----------- L0 FIFO interface (weights) -------------
    input                       wr_l0,                 // write to L0
    input  [bw*row-1:0]         weight_vector_in,      // row-wise weights
    output                      l0_full,
    output                      l0_ready,

    // ----------- MAC activation interface --------------
    input  [act_bw*col-1:0]     act_in,                // column activations

    // ----------- OFIFO interface (final output) --------
    input                       rd_ofifo,
    output [psum_bw*col-1:0]    out_vector,
    output                      ofifo_full,
    output                      ofifo_valid
);

    // ============================================================
    // 1. L0 FIFO  → produces input row-by-row
    // ============================================================
    wire [bw*row-1:0] weight_vector_out;

    l0 #(
        .bw(bw),
        .row(row)
    ) L0_inst (
        .clk(clk),
        .in(weight_vector_in),
        .out(weight_vector_out),
        .rd(1'b1),          // always feeding MAC array
        .wr(wr_l0),
        .o_full(l0_full),
        .reset(reset),
        .o_ready(l0_ready)
    );

    // ============================================================
    // 2. MAC ARRAY → computes psum_ij per column
    // ============================================================
    wire [psum_bw*col-1:0] psum_array_out;

    mac_array #(
        .bw(bw),
        .psum_bw(psum_bw),
        .col(col)
    ) MAC_inst (
        .clk(clk),
        .reset(reset),

        .in_w(weight_vector_out),      // from L0
        .in_n(act_in),                 // activations

        .out_e(psum_array_out)         // per-column psum
    );

    // ============================================================
    // 3. SFU (per-column accumulation + ReLU)
    // ============================================================
    wire signed [psum_bw-1:0] psum_in [0:col-1];
    wire signed [psum_bw-1:0] psum_sfu [0:col-1];

    // Flattened final output of SFU → OFIFO
    wire [psum_bw*col-1:0] psum_sfu_flat;

    genvar i;
    generate
        for (i = 0; i < col; i = i + 1) begin : SFU_COL

            assign psum_in[i] = psum_array_out[(i+1)*psum_bw-1 : i*psum_bw];

            // No multi-cycle accumulation → stored_psum = 0
            sfu #(
                .bw(bw),
                .psum_bw(psum_bw)
            ) SFU_inst (
                .stored_psum_out(psum_sfu[i]),
                .psum_ij(psum_in[i][bw-1:0]),
                .stored_psum({psum_bw{1'b0}}),
                .Relu_en(1'b0)           // set to 1 to enable ReLU
            );

            assign psum_sfu_flat[(i+1)*psum_bw-1 : i*psum_bw] = psum_sfu[i];
        end
    endgenerate

    // ============================================================
    // 4. OFIFO (store the psum vectors)
    // ============================================================
    ofifo #(
        .col(col),
        .bw(psum_bw)
    ) OFIFO_inst (
        .clk(clk),
        .in(psum_sfu_flat),
        .out(out_vector),
        .rd(rd_ofifo),
        .wr({col{1'b1}}),     // 1 write per cycle → psums ready every cycle
        .o_full(ofifo_full),
        .reset(reset),
        .o_ready(/*unused*/),
        .o_valid(ofifo_valid)
    );

endmodule
