module csa_tree (
	input			 clk, rst_n,
	input			 valid_in,
	input	[17:0]	 pp0, pp1, pp2, pp3,
					 pp4, pp5, pp6, pp7,
	input	[17:0]	 c_ext,
	output reg		 valid_out,
	output reg [17:0] csa_s,
	output reg [17:0] csa_c
);

	wire [18:0] p0 = {{1{pp0[17]}}, pp0};
	wire [18:0] p1 = {{1{pp1[17]}}, pp1};
	wire [18:0] p2 = {{1{pp2[17]}}, pp2};
	wire [18:0] p3 = {{1{pp3[17]}}, pp3};
	wire [18:0] p4 = {{1{pp4[17]}}, pp4};
	wire [18:0] p5 = {{1{pp5[17]}}, pp5};
	wire [18:0] p6 = {{1{pp6[17]}}, pp6};
	wire [18:0] p7 = {{1{pp7[17]}}, pp7};
	wire [18:0] p8 = {{1{c_ext[17]}}, c_ext};

	wire [18:0] L1_s0, L1_s1, L1_s2;
	wire [19:0] L1_c0_w, L1_c1_w, L1_c2_w;

	csa3_n #(19) L1_csa0 (.a(p0), .b(p1), .c(p2), .sum(L1_s0), .cout(L1_c0_w));
	csa3_n #(19) L1_csa1 (.a(p3), .b(p4), .c(p5), .sum(L1_s1), .cout(L1_c1_w));
	csa3_n #(19) L1_csa2 (.a(p6), .b(p7), .c(p8), .sum(L1_s2), .cout(L1_c2_w));

	wire [18:0] L1_c0 = L1_c0_w[18:0];
	wire [18:0] L1_c1 = L1_c1_w[18:0];
	wire [18:0] L1_c2 = L1_c2_w[18:0];

	wire [18:0] L2_s0, L2_s1;
	wire [19:0] L2_c0_w, L2_c1_w;

	csa3_n #(19) L2_csa0 (.a(L1_s0), .b(L1_c0), .c(L1_s1), .sum(L2_s0), .cout(L2_c0_w));
	csa3_n #(19) L2_csa1 (.a(L1_c1), .b(L1_s2), .c(L1_c2), .sum(L2_s1), .cout(L2_c1_w));

	wire [18:0] L2_c0 = L2_c0_w[18:0];
	wire [18:0] L2_c1 = L2_c1_w[18:0];

	wire [18:0] L3_s;
	wire [19:0] L3_c_w;

	csa3_n #(19) L3_csa0 (.a(L2_s0), .b(L2_c0), .c(L2_s1), .sum(L3_s), .cout(L3_c_w));
	wire [18:0] L3_c = L3_c_w[18:0];

	wire [18:0] L4_s;
	wire [19:0] L4_c_w;

	csa3_n #(19) L4_csa0 (.a(L3_s), .b(L3_c), .c(L2_c1), .sum(L4_s), .cout(L4_c_w));
	wire [18:0] L4_c = L4_c_w[18:0];

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			valid_out <= 1'b0;
			csa_s <= 19'b0;
			csa_c <= 19'b0;
		end else begin
			valid_out <= valid_in;
			csa_s <= L4_s;
			csa_c <= L4_c;
		end
	end
endmodule