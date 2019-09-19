// AvalonPix.v

//
// (c) 2018 Sorgelig
// 

`timescale 1 ps / 1 ps
module AvalonPix
(
	input  wire         clk,                  //   clock.clk
	input  wire         reset,                //   reset.reset

	input  wire         control_address,      // control.address
	input  wire         control_write,        //        .write
	input  wire [31:0]  control_writedata,    //        .writedata

	input  wire [31:0]  slave_address,        //   slave.address
	input  wire [6:0]   slave_burstcount,     //        .burstcount
	input  wire         slave_read,           //        .read
	output wire [127:0] slave_readdata,       //        .readdata
	output wire         slave_readdatavalid,  //        .readdatavalid
	output wire         slave_waitrequest,    //        .waitrequest

	output wire [31:0]  master_address,       //  master.address
	output wire [6:0]   master_burstcount,    //        .burstcount
	output wire         master_read,          //        .read
	input  wire  [63:0] master_readdata,      //        .readdata
	input  wire         master_readdatavalid, //        .readdatavalid
	input  wire         master_waitrequest    //        .waitrequest
);

reg [31:0] base;
reg [31:0] fmt;
always @(posedge clk) begin
	if(control_write) begin
		if (control_address) fmt  <= control_writedata;
						else base <= control_writedata;
	end
end

assign master_address = base + slave_address[31:1];
assign master_burstcount = slave_burstcount;
assign master_read = slave_read;

assign slave_readdatavalid = master_readdatavalid;
assign slave_waitrequest = master_waitrequest;

assign slave_readdata = fmt[0] ? 
	{
		//R5 G6 B5
		8'h00,
		master_readdata [ 48 +15 -:5],
		master_readdata [ 48 +15 -:3],
		master_readdata [ 48 +10 -:6],
		master_readdata [ 48 +10 -:2],
		master_readdata [ 48 + 4 -:5],
		master_readdata [ 48 + 4 -:3],

		8'h00,
		master_readdata [ 32 +15 -:5],
		master_readdata [ 32 +15 -:3],
		master_readdata [ 32 +10 -:6],
		master_readdata [ 32 +10 -:2],
		master_readdata [ 32 + 4 -:5],
		master_readdata [ 32 + 4 -:3],

		8'h00,
		master_readdata [ 16 +15 -:5],
		master_readdata [ 16 +15 -:3],
		master_readdata [ 16 +10 -:6],
		master_readdata [ 16 +10 -:2],
		master_readdata [ 16 + 4 -:5],
		master_readdata [ 16 + 4 -:3],

		8'h00,
		master_readdata [  0 +15 -:5],
		master_readdata [  0 +15 -:3],
		master_readdata [  0 +10 -:6],
		master_readdata [  0 +10 -:2],
		master_readdata [  0 + 4 -:5],
		master_readdata [  0 + 4 -:3]
	}
	:
	{
		// X1 R5 G5 B5
		8'h00,
		master_readdata [ 48 +14 -:5],
		master_readdata [ 48 +14 -:3],
		master_readdata [ 48 + 9 -:5],
		master_readdata [ 48 + 9 -:3],
		master_readdata [ 48 + 4 -:5],
		master_readdata [ 48 + 4 -:3],

		8'h00,
		master_readdata [ 32 +14 -:5],
		master_readdata [ 32 +14 -:3],
		master_readdata [ 32 + 9 -:5],
		master_readdata [ 32 + 9 -:3],
		master_readdata [ 32 + 4 -:5],
		master_readdata [ 32 + 4 -:3],

		8'h00,
		master_readdata [ 16 +14 -:5],
		master_readdata [ 16 +14 -:3],
		master_readdata [ 16 + 9 -:5],
		master_readdata [ 16 + 9 -:3],
		master_readdata [ 16 + 4 -:5],
		master_readdata [ 16 + 4 -:3],

		8'h00,
		master_readdata [  0 +14 -:5],
		master_readdata [  0 +14 -:3],
		master_readdata [  0 + 9 -:5],
		master_readdata [  0 + 9 -:3],
		master_readdata [  0 + 4 -:5],
		master_readdata [  0 + 4 -:3]
	};

endmodule
