module mac_q17 (
	input		 clk, rst_n,
	input		 valid_in,
	input	[7:0] A, B, C,
	output		 valid_out,
	output	[7:0] Y
);

	wire		v1, v2;
	wire [17:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, c_ext;
	wire [17:0] csa_s, csa_c;

	pp_gen s1 (
		.clk		(clk),
		.rst_n		(rst_n),
		.valid_in	(valid_in),
		.A			(A),
		.B			(B),
		.C			(C),
		.valid_out	(v1),
		.pp0		(pp0), .pp1(pp1), .pp2(pp2), .pp3(pp3),
		.pp4		(pp4), .pp5(pp5), .pp6(pp6), .pp7(pp7),
		.c_ext		(c_ext)
	);

	csa_tree s2 (
		.clk		(clk),
		.rst_n		(rst_n),
		.valid_in	(v1),
		.pp0		(pp0), .pp1(pp1), .pp2(pp2), .pp3(pp3),
		.pp4		(pp4), .pp5(pp5), .pp6(pp6), .pp7(pp7),
		.c_ext		(c_ext),
		.valid_out	(v2),
		.csa_s		(csa_s),
		.csa_c		(csa_c)
	);

	round_saturate s3 (
		.clk		(clk),
		.rst_n		(rst_n),
		.valid_in	(v2),
		.csa_s		(csa_s),
		.csa_c		(csa_c),
		.valid_out	(valid_out),
		.Y			(Y)
	);
endmodule