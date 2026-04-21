module full_adder (
	input	a, b, cin,
	output	sum, cout
);
	assign sum  = a ^ b ^ cin;
	assign cout = (a & b) | (a & cin) | (b & cin);
endmodule


module csa3_n #(parameter WIDTH = 19) (
	input	[WIDTH-1:0] a, b, c,
	output	[WIDTH-1:0] sum,
	output	[WIDTH:0]   cout
);
	wire	[WIDTH-1:0] raw_carry;
	genvar	i;

	generate
		for (i = 0; i < WIDTH; i = i + 1) begin : csa_bits
			full_adder csa (
				.a	(a[i]),
				.b	(b[i]),
				.cin	(c[i]),
				.sum	(sum[i]),
				.cout	(raw_carry[i])
			);
		end
	endgenerate

	assign cout = {raw_carry, 1'b0};
endmodule


module adder_n #(parameter WIDTH = 8) (
	input	[WIDTH-1:0] a, b,
	input		 cin,
	output	[WIDTH-1:0] sum,
	output		 cout
);
	wire	[WIDTH:0] c;
	assign c[0] = cin;

	genvar	i;

	generate
		for (i = 0; i < WIDTH; i = i + 1) begin : fa_chain
			full_adder rca (
				.a	(a[i]),
				.b	(b[i]),
				.cin	(c[i]),
				.sum	(sum[i]),
				.cout	(c[i+1])
			);
		end
	endgenerate

	assign cout = c[WIDTH];
endmodule