//============================================================================
//  Audio and Video head for Linux on MiSTer
//
//  Copyright (C) 2018 Sorgelig
//
//  Audio part is based on DE1-SoC-Sound by B. Steinsbo <bsteinsbo@gmail.com> 
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//============================================================================

module AVHead
(
	/////////// CLOCK //////////
	input         FPGA_CLK1_50,
	input         FPGA_CLK2_50,
	input         FPGA_CLK3_50,

	//////////// VGA ///////////
	output  [5:0] VGA_R,
	output  [5:0] VGA_G,
	output  [5:0] VGA_B,
	inout         VGA_HS,  // VGA_HS is secondary SD card detect when VGA_EN = 1 (inactive)
	output		  VGA_VS,
	input         VGA_EN,  // active low

	/////////// AUDIO //////////
	output		  AUDIO_L,
	output		  AUDIO_R,
	output		  AUDIO_SPDIF,

	//////////// HDMI //////////
	output        HDMI_I2C_SCL,
	inout         HDMI_I2C_SDA,

	output        HDMI_MCLK,
	output        HDMI_SCLK,
	output        HDMI_LRCLK,
	output        HDMI_I2S,

	output        HDMI_TX_CLK,
	output        HDMI_TX_DE,
	output [23:0] HDMI_TX_D,
	output        HDMI_TX_HS,
	output        HDMI_TX_VS,

	input         HDMI_TX_INT,

	//////////// SDR ///////////
	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE,

	//////////// I/O ///////////
	output        LED_USER,
	output        LED_HDD,
	output        LED_POWER,
	input         BTN_USER,
	input         BTN_OSD,
	input         BTN_RESET,

	//////////// SDIO ///////////
	inout   [3:0] SDIO_DAT,
	inout         SDIO_CMD,
	output        SDIO_CLK,
	input         SDIO_CD,

	////////// MB KEY ///////////
	input   [1:0] KEY,

	////////// MB SWITCH ////////
	input   [3:0] SW,

	////////// MB LED ///////////
	output  [7:0] LED
);

assign {SDIO_DAT[2:1]} = 2'bZZ;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = {39{1'bZ}};

assign LED       = io_out_port[15] ? io_out_port[7:0] : {3'b000, 1'b1, 4'b0000};
assign LED_POWER = io_out_port[15] & ~io_out_port[8] ? 1'bZ : 1'b0;
assign LED_HDD   = io_out_port[15] & io_out_port[9]  ? 1'b0 : 1'bZ;
assign LED_USER  = io_out_port[15] & io_out_port[10] ? 1'b0 : 1'bZ;

// do not re-program HDMI chip.
// use settings from Menu core.
/*
hdmi_config hdmi_config
(
	.iCLK(FPGA_CLK1_50),
	.iRST_N(1),

	.dvi_mode(0),
	.audio_96k(0),

	.I2C_SCL(HDMI_I2C_SCL),
	.I2C_SDA(HDMI_I2C_SDA)
);
*/

assign HDMI_I2C_SCL = 1'bZ;
assign HDMI_I2C_SDA = 1'bZ;

assign {VGA_R,VGA_G,VGA_B,VGA_HS,VGA_VS} = VGA_EN ? {20{1'bZ}} : 
		{{6{HDMI_TX_DE}} & HDMI_TX_D[23:18], {6{HDMI_TX_DE}} & HDMI_TX_D[15:10], {6{HDMI_TX_DE}} & HDMI_TX_D[7:2], HDMI_TX_HS, HDMI_TX_VS};

/////////////////////////////////////////////////////////////////

wire [15:0] io_out_port;
soc_system soc
(
	.reset_reset_n			( reset_n ),

	.clk100m_clk			( clk100m_clk ),
	.clk44k_clk				( clk44k_clk  ),
	.clk48k_clk				( clk48k_clk  ),

	.dma0_dma_req			( 0),
	.dma0_dma_single		( dma0_dma_single ),
	.dma0_dma_ack			( dma0_dma_ack    ),

	.i2s_fifo_clk			( clk100m_clk    ),
	.i2s_fifo_data			( i2s_fifo_data  ),
	.i2s_fifo_empty		( i2s_fifo_empty ),
	.i2s_fifo_read			( i2s_fifo_ack_synchro[2] & ~i2s_fifo_ack_synchro[1] ),
	.i2s_fifo_full			(),

	.i2s_dma_req			( dma0_dma_single ),
	.i2s_dma_ack			( dma0_dma_ack    ),
	.i2s_dma_enable		( i2s_dma_enable  ),

	.i2s_ext_bclk			( 0 ),
	.i2s_ext_lrclk			( 0 ),

	.i2s_ctrl_mode			(),
	.i2s_ctrl_sel_48_44	( i2s_ctrl_sel_48_44 ),
	.i2s_ctrl_bclk			( i2s_ctrl_bclk      ),
	.i2s_ctrl_lrclk		( i2s_ctrl_lrclk     ),

	.i2s_mclk_clk			(),

	.hdmi_clk            ( HDMI_TX_CLK ),
	.out_clk             ( HDMI_TX_CLK ),
	.out_data            ( HDMI_TX_D   ),
	.out_de              ( HDMI_TX_DE  ),
	.out_v_sync          ( HDMI_TX_VS  ),
	.out_h_sync          ( HDMI_TX_HS  ),

	.cold_reset_n     	( BTN_RESET   ),

	.io_in_port          ( {io_out_port[15], KEY, BTN_USER, BTN_OSD, io_out_port[10:0]} ),
	.io_out_port         ( io_out_port ),

	.mmc_SCLK            ( SDIO_CLK    ),
	.mmc_MOSI            ( SDIO_CMD    ),
	.mmc_MISO            ( SDIO_DAT[0] ),
	.mmc_SS_n            ( SDIO_DAT[3] )
);

/////////////////////////////////////////////////////////////////

wire [63:0]	i2s_fifo_data;

wire reset_n;
wire clk100m_clk;
wire clk48k_clk;
wire clk44k_clk;
wire dma0_dma_single;
wire dma0_dma_ack;
wire i2s_fifo_empty;
wire i2s_dma_enable;
wire i2s_playback_enable;
wire i2s_ctrl_sel_48_44;
wire i2s_ctrl_bclk;
wire i2s_ctrl_lrclk;

wire i2s_fifo_ack48;
wire i2s_data_out48;
wire spdif48_o, sigma48_l, sigma48_r;
audio_out #(4) audio_out48
(
	.reset_n				(reset_n),  
	.clk					(clk48k_clk),

	.fifo_right_data	(i2s_fifo_data[63:32]),
	.fifo_left_data	(i2s_fifo_data[31:0]),
	.fifo_ready			(~i2s_fifo_empty),
	.fifo_ack			(i2s_fifo_ack48),

	.enable				(i2s_playback_enable),
	.bclk					(i2s_ctrl_bclk),
	.lrclk				(i2s_ctrl_lrclk),
	.data_out			(i2s_data_out48),

	.spdif_o				(spdif48_o),
	.sigma_r				(sigma48_r),
	.sigma_l				(sigma48_l)
);

wire i2s_fifo_ack44;
wire i2s_data_out44;
wire spdif44_o, sigma44_l, sigma44_r;
audio_out #(6) audio_out44
(
	.reset_n				(reset_n),
	.clk					(clk44k_clk),

	.fifo_right_data	(i2s_fifo_data[63:32]),
	.fifo_left_data	(i2s_fifo_data[31:0]),
	.fifo_ready			(~i2s_fifo_empty),
	.fifo_ack			(i2s_fifo_ack44),

	.enable				(i2s_playback_enable),
	.bclk					(i2s_ctrl_bclk),
	.lrclk				(i2s_ctrl_lrclk),
	.data_out			(i2s_data_out44),

	.spdif_o				(spdif44_o),
	.sigma_r				(sigma44_r),
	.sigma_l				(sigma44_l)
);

// Combinatorics
assign i2s_playback_enable = i2s_dma_enable & ~i2s_fifo_empty;

// Mux and sync fifo read ack
reg [2:0] i2s_fifo_ack_synchro;
wire      i2s_fifo_ack = i2s_ctrl_sel_48_44 ? i2s_fifo_ack44 : i2s_fifo_ack48;

always @(posedge clk100m_clk or negedge reset_n) begin
	if (~reset_n) i2s_fifo_ack_synchro <= 0;
	else i2s_fifo_ack_synchro <= {i2s_fifo_ack_synchro[1:0], i2s_fifo_ack};
end


// Audio output
assign HDMI_MCLK   = 0;
assign HDMI_SCLK   = i2s_ctrl_bclk;
assign HDMI_LRCLK  = i2s_ctrl_lrclk;
assign HDMI_I2S    = i2s_ctrl_sel_48_44 ? i2s_data_out44 : i2s_data_out48;

assign AUDIO_SPDIF = SW[0] ? HDMI_LRCLK : i2s_ctrl_sel_48_44 ? spdif44_o : spdif48_o;
assign AUDIO_R     = SW[0] ? HDMI_I2S   : i2s_ctrl_sel_48_44 ? sigma44_r : sigma48_r;
assign AUDIO_L     = SW[0] ? HDMI_SCLK  : i2s_ctrl_sel_48_44 ? sigma44_l : sigma48_l;

endmodule
