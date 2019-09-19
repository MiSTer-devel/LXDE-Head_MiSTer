
module audio_out #(parameter SPDIF_DIV = 1)
(
	input			 clk,
	input			 reset_n,
	input	[31:0] fifo_right_data,
	input	[31:0] fifo_left_data,
	input			 fifo_ready,
	output 		 fifo_ack,

	input			 enable,

	// I2S
	input			 bclk,
	input			 lrclk,
	output		 data_out,

	// SPDIF
	output       spdif_o,
	
	// analog/pwm
	output       sigma_l,
	output       sigma_r
);

i2s_shift_out i2s
(
	.reset_n(reset_n),
	.clk(clk),
	
	.fifo_right_data(fifo_right_data),
	.fifo_left_data(fifo_left_data),
	.fifo_ready(fifo_ready),
	.fifo_ack(fifo_ack),

	.enable(enable),
	.bclk(bclk),
	.lrclk(lrclk),
	.data_out(data_out)
);

reg [15:0] audio_r, audio_l;
always @(posedge clk) begin
	if(fifo_ack) {audio_r, audio_l} <= {fifo_right_data[31:16], fifo_left_data[31:16]};
	if(~(reset_n & enable)) {audio_r, audio_l} <= 0;
end

spdif #(SPDIF_DIV) spdif
(
	.clk_i(clk),
	.rst_i(~reset_n),

	.audio_r(audio_r),
	.audio_l(audio_l),

	.spdif_o(spdif_o)
);

sigma_delta_dac #(15) dac_l
(
	.CLK(clk),
	.RESET(~reset_n),
	.DACin({~audio_l[15], audio_l[14:0]}),
	.DACout(sigma_l)
);

sigma_delta_dac #(15) dac_r
(
	.CLK(clk),
	.RESET(~reset_n),
	.DACin({~audio_r[15], audio_r[14:0]}),
	.DACout(sigma_r)
);

endmodule
