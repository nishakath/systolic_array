// =====================
// Instantiate CORE
// =====================

`timescale 1ns/1ps

module core_tb;

parameter bw      = 4;
parameter psum_bw = 32;
parameter row     = 8;
parameter col     = 8;

reg clk = 0;
reg reset = 1;

// --------------- CONTROL SIGNALS ----------------
reg [7:0] inst;

// act/wgt SRAM interface
reg        wen_act_wgt;
reg        cen_act_wgt;
reg [31:0] din_act_wgt;
reg [10:0] addr_act_wgt;

// output SRAM interface
reg        wen_out;
reg        cen_out;
reg [31:0] din_out;
reg [10:0] out_addr;

// PSUM double-buffer pointers
reg [10:0] out_rptr;
reg [10:0] out_wptr;

// final collected result
wire [psum_bw*col-1:0] final_psum_vector;




core #(
    .bw(bw),
    .psum_bw(psum_bw),
    .row(row),
    .col(col)) 
    core_inst (
    .clk        (clk),
    .reset      (reset),
    .inst       (inst_q),
    .D_xmem     (D_xmem_q),
    .relu_enable(relu_enable),

    .wen_act    (wen_act),
    .cen_act    (cen_act),
    .din_act    (din_act),
    .addr_act   (addr_act),


    .wen_wgt    (wen_wgt),
    .cen_wgt    (cen_wgt),
    .din_wgt    (din_wgt),
    .addr_wgt   (addr_wgt),


    .wen_out    (wen_out),
    .cen_out    (cen_out),
    .din_out    (din_out),
    .addr_out   (addr_out)

)

initial begin 

$dumpfile("core_tb.vcd");
$dumpvars(0,core_tb);

end

endmodule