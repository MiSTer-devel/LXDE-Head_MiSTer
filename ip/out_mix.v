// out_mix.v

//
// (c) 2018 Sorgelig
// 

`timescale 1 ps / 1 ps
module out_mix (
		input  wire        clk,               //  Output.clk
		output reg         de,                //       .de
		output reg         h_sync,            //       .h_sync
		output reg         v_sync,            //       .v_sync
		output reg  [23:0] data,              //       .data
		output reg         vid_clk,           //  input.vid_clk
		input  wire [1:0]  vid_datavalid,     //        .vid_datavalid
		input  wire [1:0]  vid_h_sync,        //        .vid_h_sync
		input  wire [1:0]  vid_v_sync,        //        .vid_v_sync
		input  wire [47:0] vid_data,          //        .vid_data
		input  wire        underflow,         //        .underflow
		input  wire        vid_mode_change,   //        .vid_mode_change
		input  wire [1:0]  vid_std,           //        .vid_std
		input  wire [1:0]  vid_f,             //        .vid_f
		input  wire [1:0]  vid_h,             //        .vid_h
		input  wire [1:0]  vid_v,             //        .vid_v
		input  wire        control_address,   // control.address
		input  wire        control_write,     //        .write
		input  wire [31:0] control_writedata, //        .writedata
		input  wire        clock_clk,         //   clock.clk
		input  wire        reset              //   reset.reset
	);

	reg        r_de;
	reg        r_h_sync;
	reg        r_v_sync;
	reg [23:0] r_data;
	
	reg [31:0] fmt;
	always @(posedge clock_clk) if(control_write & !control_address) fmt <= control_writedata;
	
	always @(posedge clk) begin
		vid_clk <= ~vid_clk;
		
		if(~vid_clk) begin
			{r_de,de} <= vid_datavalid;
			{r_h_sync, h_sync} <= vid_h_sync;
			{r_v_sync, v_sync} <= vid_v_sync;
			{r_data, data} <= fmt[0] ? {vid_data[31:24],vid_data[39:32],vid_data[47:40],vid_data[7:0],vid_data[15:8],vid_data[23:16]} : vid_data;
		end else begin
			de <= r_de;
			h_sync <= r_h_sync;
			v_sync <= r_v_sync;
			data <= r_data;
		end
	end

endmodule
