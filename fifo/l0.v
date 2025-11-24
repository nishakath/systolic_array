// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;

  assign o_ready = ~(||full);
  assign o_full  = ||full;


  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	   .rd_clk(clk),
	   .wr_clk(clk),
	   .rd(rd_en[i]),
	   .wr(wr),
      .o_empty(empty[i]),
      .o_full(full[i]),
	   .in(in[(i+1)*bw-1 : i*bw]),
	   .out(out[(i+1)*bw-1 : i*bw]),
      .reset(reset));
  end


  reg [3:0] row_cnt;
  integer k;

  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
      row_cnt <= 0;
   end

   /*
  // VERSION 1: read all rows at the same time
  always @ (posedge clk) begin
    if (reset) begin
      rd_en <= {row{1'b0}};
    end else begin
      if (rd && ~(|empty)) begin
        // all FIFOs have data, so read a full vector
        rd_en <= {row{1'b1}};
      end else begin
        rd_en <= {row{1'b0}};
      end
    end
  end

   */
    else if (rd) begin
        // 1) Expand row_cnt until it reaches the final row
        if (row_cnt < row-1)
            row_cnt <= row_cnt + 1;

        // 2) Enable rows 0 to row_cnt
        for (i = 0; i < row; i = i + 1)
            rd_en[i] <= (i <= row_cnt) && !empty[i];
    end
    else begin
        rd_en <= 0;
    end
end
