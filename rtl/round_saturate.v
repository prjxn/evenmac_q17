module round_saturate (
	input			 clk, rst_n,
	input			 valid_in,
	input	[17:0]	 csa_s, csa_c,
	output reg		 valid_out,
	output reg [7:0] Y
);

	wire [17:0] sum;

	adder_n #(.WIDTH(18)) cpa (
		.a	(csa_s),
		.b	(csa_c),
		.cin	(1'b0),
		.sum	(sum),
		.cout	()
	);

	wire [7:0] trunc  = sum[14:7];
	wire		 guard  = sum[6];
	wire		 sticky = |sum[5:0];
	wire		 rne    = guard & (sticky | trunc[0]);

	wire [7:0] y_rounded;
	wire		 rnd_cout;

	adder_n #(.WIDTH(8)) rnd_add (
		.a	(trunc),
		.b	(8'b0),
		.cin	(rne),
		.sum	(y_rounded),
		.cout	(rnd_cout)
	);

	wire [1:0] ov_bits   = sum[15:14];
	wire		 true_sign = sum[15];

	wire pos_ov     = ~true_sign & (ov_bits != 2'b00);
	wire neg_ov     =  true_sign & (ov_bits != 2'b11);
	wire rnd_pos_ov = ~true_sign & ~pos_ov & (rnd_cout | (~trunc[7] & y_rounded[7]));

	wire [7:0] y_sat = (pos_ov | rnd_pos_ov) ? 8'h7F :
					   neg_ov				 ? 8'h80 :
											 y_rounded;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			valid_out <= 1'b0;
			Y <= 8'b0;
		end else begin
			valid_out <= valid_in;
			Y <= y_sat;
		end
	end
endmodule