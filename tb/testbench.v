`timescale 1ns/1ps

module tb_mac_q17;

	reg clk = 0;
	reg rst_n = 0;
	reg valid_in = 0;
	reg [7:0] A = 0, B = 0, C = 0;

	wire valid_out;
	wire [7:0] Y;
	
	integer logfile;
	integer pass = 0;
	integer fail = 0;

	mac_q17 dut (
		.clk(clk),
		.rst_n(rst_n),
		.valid_in(valid_in),
		.A(A), .B(B), .C(C),
		.valid_out(valid_out),
		.Y(Y)
	);

	always #5 clk = ~clk;

	reg [7:0] corners [0:6];
	integer ai, bi, ci, k;

	initial begin
		corners[0] = 8'h00;
		corners[1] = 8'h01;
		corners[2] = 8'h7F;
		corners[3] = 8'h80;
		corners[4] = 8'hFF;
		corners[5] = 8'h40;
		corners[6] = 8'hC0;

		repeat(5) @(posedge clk);
		rst_n = 1;

		for (ai = 0; ai < 7; ai = ai + 1)
		for (bi = 0; bi < 7; bi = bi + 1)
		for (ci = 0; ci < 7; ci = ci + 1)
		apply(corners[ai], corners[bi], corners[ci]);

		for (k = 0; k < 657; k = k + 1)
		apply($random, $random, $random);

		repeat(10) @(posedge clk);

		$display("\n \n");
		$display("VERIFICATION COMPLETED");
		$display("%0d / %0d PASSED",pass,(pass+fail));
		$display("Detailed Report saved as mac_q17_tb_log.txt");
		$display("\n \n");

		$fclose(logfile);
		$finish;
	end
	
	task apply;
		input [7:0] a, b, c;
		begin
			@(negedge clk);
			A = a; B = b; C = c;
			valid_in = 1;
			@(negedge clk);
			valid_in = 0;
		end
	endtask
	
	// Golden model
	
	function [7:0] golden;
		input [7:0] a, b, c;
		reg signed [31:0] prod, sum, trunc, rounded;
		reg guard, sticky;
		begin
			prod = $signed(a) * $signed(b);
			sum  = prod + ($signed(c) <<< 7);

			trunc  = sum >>> 7;
			guard  = sum[6];
			sticky = |sum[5:0];

			if (guard & (sticky | trunc[0]))
				rounded = trunc + 1;
			else
				rounded = trunc;

			if (rounded > 127)
				golden = 8'h7F;
			else if (rounded < -128)
				golden = 8'h80;
			else
				golden = rounded[7:0];
		end
	endfunction
	
	// Pipeline tracking
	
	reg [7:0] exp_pipe [0:2];
	reg [7:0] A_pipe [0:2];
	reg [7:0] B_pipe [0:2];
	reg [7:0] C_pipe [0:2];

	integer i;

	always @(posedge clk) begin
		if (!rst_n) begin
			for (i = 0; i < 3; i = i + 1) begin
				exp_pipe[i] <= 0;
				A_pipe[i]   <= 0;
				B_pipe[i]   <= 0;
				C_pipe[i]   <= 0;
			end
		end else begin
			exp_pipe[2] <= exp_pipe[1];
			exp_pipe[1] <= exp_pipe[0];

			A_pipe[2] <= A_pipe[1];
			A_pipe[1] <= A_pipe[0];
			B_pipe[2] <= B_pipe[1];
			B_pipe[1] <= B_pipe[0];
			C_pipe[2] <= C_pipe[1];
			C_pipe[1] <= C_pipe[0];

			if (valid_in) begin
				exp_pipe[0] <= golden(A,B,C);
				A_pipe[0]   <= A;
				B_pipe[0]   <= B;
				C_pipe[0]   <= C;
			end
		end
	end

	always @(posedge clk) begin
		if (valid_out) begin
			if (Y !== exp_pipe[2]) begin
				$display("FAIL: A=0x%02X B=0x%02X C=0x%02X | Exp=0x%02X Got=0x%02X",
					A_pipe[2], B_pipe[2], C_pipe[2], exp_pipe[2], Y);

				$fwrite(logfile, "%02X\t%02X\t%02X\t%02X\t%02X\tFAIL\n",
					A_pipe[2], B_pipe[2], C_pipe[2], exp_pipe[2], Y);

				fail = fail + 1;
			end else begin
				$fwrite(logfile, "%02X\t%02X\t%02X\t%02X\t%02X\tPASS\n",
					A_pipe[2], B_pipe[2], C_pipe[2], exp_pipe[2], Y);

				pass = pass + 1;
			end
		end
	end
	
	initial begin
		logfile = $fopen("mac_q17_tb_log.txt", "w");
		$fwrite(logfile, "A\tB\tC\tEXP\tACT\tSTATUS\n");
		$fwrite(logfile, "\n");
	end

endmodule