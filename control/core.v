module core #(
    parameter bw        = 4,    // weight bitwidth
    parameter psum_bw   = 32,   // psum bitwidth
    parameter row       = 8,    // number of MAC rows
    parameter col       = 8     // number of MAC cols
)
(
    input                      clk,
    input                      reset,
    input [7:0]                inst, //inst[6] is final read from mem
    //rchip is inst[7]


    input  wen_act_wgt,
    input  cen_act_wgt,
    input  [31:0] din_act_wgt,
    input  [10:0] addr_act_wgt,

    input  wen_out,
    input  cen_out,
    input  [31:0] din_out,
    input  [10:0] out_addr,

    output [psum_bw*col-1:0] final_psum_vector

);


wire [bw*row-1:0] qread_act;
wire [psum_bw*col-1:0] psum_to_sfu;


reg [psum_bw*col-1:0] psum_to_sfu_q;   // already used but not declared?



// mem1
wire [31:0] psum_stored_mem1_1;
wire [31:0] psum_stored_mem1_2;
wire [31:0] psum_stored_mem1_3;
wire [31:0] psum_stored_mem1_4;
wire [31:0] psum_stored_mem1_5;
wire [31:0] psum_stored_mem1_6;
wire [31:0] psum_stored_mem1_7;
wire [31:0] psum_stored_mem1_8;

// mem2
wire [31:0] psum_stored_mem2_1;
wire [31:0] psum_stored_mem2_2;
wire [31:0] psum_stored_mem2_3;
wire [31:0] psum_stored_mem2_4;
wire [31:0] psum_stored_mem2_5;
wire [31:0] psum_stored_mem2_6;
wire [31:0] psum_stored_mem2_7;
wire [31:0] psum_stored_mem2_8;

sram_32b #(.num(2000)) sram_acts_wgts (
    .CLK(clk),
    .WEN(wen_act_wgt),
    .CEN(cen_act_wgt),     
    .D(din_act_wgt), 
    .A(addr_act_wgt),       
    .Q(qread_act)    //connect
  );

// control for psum memories
reg        cen_out_mem1, cen_out_mem2;
reg        wen_out_mem1, wen_out_mem2;
reg [10:0] out_addr_mem1, out_addr_mem2;
// SFU outputs from corelet
wire [psum_bw*col-1:0] sfu_out_flat;

sram_32b #(.num(1024)) sram_psum_oc1_mem1 (.CLK(clk), .D(sfu_out_flat[31:0]), .Q(psum_stored_mem1_1), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));
sram_32b #(.num(1024)) sram_psum_oc2_mem1 (.CLK(clk), .D(sfu_out_flat[63:32]), .Q(psum_stored_mem1_2), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));
sram_32b #(.num(1024)) sram_psum_oc3_mem1 (.CLK(clk), .D(sfu_out_flat[95:64]), .Q(psum_stored_mem1_3), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));
sram_32b #(.num(1024)) sram_psum_oc4_mem1 (.CLK(clk), .D(sfu_out_flat[127:96]), .Q(psum_stored_mem1_4), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));
sram_32b #(.num(1024)) sram_psum_oc5_mem1 (.CLK(clk), .D(sfu_out_flat[159:128]), .Q(psum_stored_mem1_5), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));
sram_32b #(.num(1024)) sram_psum_oc6_mem1 (.CLK(clk), .D(sfu_out_flat[191:160]), .Q(psum_stored_mem1_6), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));
sram_32b #(.num(1024)) sram_psum_oc7_mem1 (.CLK(clk), .D(sfu_out_flat[223:192]), .Q(psum_stored_mem1_7), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));
sram_32b #(.num(1024)) sram_psum_oc8_mem1 (.CLK(clk), .D(sfu_out_flat[255:224]), .Q(psum_stored_mem1_8), .CEN(cen_out_mem1), .WEN(wen_out_mem1), .A(out_addr_mem1));

sram_32b #(.num(1024)) sram_psum_oc1_mem2 (.CLK(clk), .D(sfu_out_flat[31:0]), .Q(psum_stored_mem2_1), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));
sram_32b #(.num(1024)) sram_psum_oc2_mem2 (.CLK(clk), .D(sfu_out_flat[63:32]), .Q(psum_stored_mem2_2), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));
sram_32b #(.num(1024)) sram_psum_oc3_mem2 (.CLK(clk), .D(sfu_out_flat[95:64]), .Q(psum_stored_mem2_3), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));
sram_32b #(.num(1024)) sram_psum_oc4_mem2 (.CLK(clk), .D(sfu_out_flat[127:96]), .Q(psum_stored_mem2_4), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));
sram_32b #(.num(1024)) sram_psum_oc5_mem2 (.CLK(clk), .D(sfu_out_flat[159:128]), .Q(psum_stored_mem2_5), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));
sram_32b #(.num(1024)) sram_psum_oc6_mem2 (.CLK(clk), .D(sfu_out_flat[191:160]), .Q(psum_stored_mem2_6), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));
sram_32b #(.num(1024)) sram_psum_oc7_mem2 (.CLK(clk), .D(sfu_out_flat[223:192]), .Q(psum_stored_mem2_7), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));
sram_32b #(.num(1024)) sram_psum_oc8_mem2 (.CLK(clk), .D(sfu_out_flat[255:224]), .Q(psum_stored_mem2_8), .CEN(cen_out_mem2), .WEN(wen_out_mem2), .A(out_addr_mem2));

// Concatenate read psums from each chip
wire [psum_bw*col-1:0] psum_to_sfu_mem1;
wire [psum_bw*col-1:0] psum_to_sfu_mem2;

assign psum_to_sfu_mem1 = {
    psum_stored_mem1_8,
    psum_stored_mem1_7,
    psum_stored_mem1_6,
    psum_stored_mem1_5,
    psum_stored_mem1_4,
    psum_stored_mem1_3,
    psum_stored_mem1_2,
    psum_stored_mem1_1
};

assign psum_to_sfu_mem2 = {
    psum_stored_mem2_8,
    psum_stored_mem2_7,
    psum_stored_mem2_6,
    psum_stored_mem2_5,
    psum_stored_mem2_4,
    psum_stored_mem2_3,
    psum_stored_mem2_2,
    psum_stored_mem2_1
};

// mem select
wire  rchip;  // 0 -> read mem1 / write mem2, 1 -> read mem2 / write mem1
assign rchip = inst[7];

wire [psum_bw*col-1:0] psum_to_sfu;
assign psum_to_sfu = rchip ? psum_to_sfu_mem2 : psum_to_sfu_mem1;

wire o_ready_l0;
wire wr_mem;       // from corelet: write-enable for psum SRAM phase
wire rd_ofifo;     // from corelet: OFIFO read → psum read phase


corelet #(
    .bw(bw),
    .psum_bw(psum_bw),
    .row(row),
    .col(col)
) CORELET_inst (
    .clk           (clk),
    .reset         (reset),
    .inst          (inst[5:0]),
    .D_xmem        (qread_act),
    .mem_read_psum (psum_to_sfu_q),
    .sfu_out_flat  (sfu_out_flat),
    .o_ready_l0    (o_ready_l0),
    .wr_mem        (wr_mem),
    .rd_ofifo      (rd_ofifo)
);



reg [10:0] rd_ptr, wr_ptr;
wire [10:0] max_rptr;
wire [10:0] max_wptr;
wire rd_mem;

assign rd_mem = (inst[6] == 1'b1) ? (rd_ptr < max_rptr) : rd_ofifo;



always @* begin
    if (!rchip) begin
        // read mem1, write mem2
        out_addr_mem1 = rd_ptr;
        out_addr_mem2 = wr_ptr;
    end else begin
         // read mem2, write mem1
        out_addr_mem1 = wr_ptr;
        out_addr_mem2 = rd_ptr;
    end
 end

// CEN/WEN control for psum SRAMs
always @* begin
    // defaults: disabled
    cen_out_mem1 = 1'b1;
    wen_out_mem1 = 1'b1;
    cen_out_mem2 = 1'b1;
    wen_out_mem2 = 1'b1;

    if (!rchip) begin
        // rchip = 0: read mem1, write mem2
        if (rd_mem) begin
            cen_out_mem1 = 1'b0; // active
            wen_out_mem1 = 1'b1; // read
        end
        if (wr_mem) begin
            cen_out_mem2 = 1'b0; // active
            wen_out_mem2 = 1'b0; // write
        end
        end else begin
            // rchip = 1: read mem2, write mem1
            if (rd_mem) begin
                cen_out_mem2 = 1'b0;
                wen_out_mem2 = 1'b1; // read
            end
            if (wr_mem) begin
                cen_out_mem1 = 1'b0;
                wen_out_mem1 = 1'b0; // write
            end
        end
end

assign max_rptr = 1023;
assign max_wptr = 1023;


always @(posedge clk) begin
    if (reset) begin
        rd_ptr <= 0;
        wr_ptr <= 0;
        psum_to_sfu_q <= {psum_bw*col{1'b0}};
    end

    else begin

        // ---------------------------
        // NORMAL ACCUMULATION MODE inst[6] = 0
        // ---------------------------
        if (!inst[6]) begin      
            if (rd_mem && (rd_ptr < max_rptr)) begin
                psum_to_sfu_q <= psum_to_sfu;
                rd_ptr <= rd_ptr + 1;
            end
        end
        else begin      //output dump mode           
            if (rd_mem && (rd_ptr < max_rptr)) begin
                rd_ptr <= rd_ptr + 1;           
            end
        end

        if (wr_mem && (wr_ptr < max_wptr)) begin
            wr_ptr <= wr_ptr + 1;
        end
    end
end




assign final_psum_vector = rchip ? psum_to_sfu_mem1 : psum_to_sfu_mem2;

endmodule
