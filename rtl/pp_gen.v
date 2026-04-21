module pp_gen (
	input			 clk, rst_n,
	input			 valid_in,
	input	[7:0]	 A, B, C,
	output reg		 valid_out,
	output reg [17:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7,
	output reg [17:0] c_ext
);

	wire [17:0] A_sx = {{10{A[7]}}, A};
	wire [17:0] A_neg;
	adder_n #(.WIDTH(18)) neg_inst (
		.a	(~A_sx),
		.b	(18'b0),
		.cin	(1'b1),
		.sum	(A_neg),
		.cout()
	);

	wire [17:0] pp_comb0, pp_comb1, pp_comb2, pp_comb3;
	wire [17:0] pp_comb4, pp_comb5, pp_comb6, pp_comb7;

	assign pp_comb0 = B[0] ? A_sx : 18'b0;
	assign pp_comb1 = B[1] ? {A_sx[16:0], 1'b0} : 18'b0;
	assign pp_comb2 = B[2] ? {A_sx[15:0], 2'b0} : 18'b0;
	assign pp_comb3 = B[3] ? {A_sx[14:0], 3'b0} : 18'b0;
	assign pp_comb4 = B[4] ? {A_sx[13:0], 4'b0} : 18'b0;
	assign pp_comb5 = B[5] ? {A_sx[12:0], 5'b0} : 18'b0;
	assign pp_comb6 = B[6] ? {A_sx[11:0], 6'b0} : 18'b0;
	assign pp_comb7 = B[7] ? {A_neg[10:0], 7'b0} : 18'b0;

	wire signed [17:0] C_sx = {{10{C[7]}}, C};
	wire        [17:0] c_comb = {C_sx[10:0], 7'b0};

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			valid_out <= 1'b0;
			pp0 <= 18'b0; pp1 <= 18'b0; pp2 <= 18'b0; pp3 <= 18'b0;
			pp4 <= 18'b0; pp5 <= 18'b0; pp6 <= 18'b0; pp7 <= 18'b0;
			c_ext <= 18'b0;
		end else begin
			valid_out <= valid_in;
			pp0 <= pp_comb0; pp1 <= pp_comb1;
			pp2 <= pp_comb2; pp3 <= pp_comb3;
			pp4 <= pp_comb4; pp5 <= pp_comb5;
			pp6 <= pp_comb6; pp7 <= pp_comb7;
			c_ext <= c_comb;
		end
	end
endmodule