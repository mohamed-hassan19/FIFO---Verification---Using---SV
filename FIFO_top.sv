module top();

bit clk;

initial begin
	clk = 0;
	forever 
		#5 clk = ~clk;
end

FIFO_if F_if(clk);

FIFO f1(F_if);
FIFO_tb tb1(F_if);
FIFO_monitor m1(F_if);

endmodule 