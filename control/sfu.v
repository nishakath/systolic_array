// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfu (stored_psum_out, psum_ij, stored_psum, Relu_en);

parameter psum_bw = 32;
parameter bw = 4;

output signed [psum_bw-1:0] stored_psum_out;
input signed  [bw-1:0] psum_ij; 
input signed [psum_bw-1:0] stored_psum;
wire signed [psum_bw-1:0] sum;

assign sum = stored_psum + psum_ij;

assign stored_psum_out = (Relu_en && sum[psum_bw-1]) ? 0 : sum;



endmodule