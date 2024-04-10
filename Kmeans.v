//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab08: Low-Power Syntheis                           //
//------------------------------------------------------//
`timescale 1ns/10ps

//cadence translate_off
`include "/usr/chipware/CW_minmax.v"
`include "/usr/chipware/CW_mult_n_stage.v"
`include "/usr/chipware/CW_mult.v"
`include "/usr/chipware/CW_pipe_reg.v"
//cadence translate_on
      
module Kmeans
( 
    RESET,     //input
    CLK,       //input
    IN_VALID,  //input
    IN_DATA,   //input
    OUT_VALID, //output
    OUT_DATA,  //output
    busy       //output
);

  input RESET;
  input CLK;
  input IN_VALID;
  input [31:0] IN_DATA;
  output reg OUT_VALID;
  output reg busy;
  output reg [1:0] OUT_DATA;

//Write Your Design Here
	reg  [9:0]   selfcounter;
	reg  [9:0]   allcounter;
	reg  [3:0]	 bcounter;
	reg  [31:0]	 cx1,cx2,cx3;
	reg  [31:0]	 cy1,cy2,cy3;
	reg  [31:0]  x,y;
	reg 	     xclk,yclk;
	reg  [31:0]  d_cx1,d_cx2,d_cx3;
	reg  [31:0]  d_cy1,d_cy2,d_cy3;
	wire [63:0]	 squd_cx1,squd_cx2,squd_cx3;
	wire [63:0]	 squd_cy1,squd_cy2,squd_cy3;
	reg  [64:0]  dis1,dis2,dis3;
	reg 	     disrclk;
	wire [9:0]	 value;
	wire [1:0]	 cluster;

	

CW_mult_n_stage #(7'd32, 7'd32, 2'd3) u1 ( .A(d_cx1), .B(d_cx1), .TC(1'd0), .CLK (CLK), .Z(squd_cx1));
CW_mult_n_stage #(7'd32, 7'd32, 2'd3) u2 ( .A(d_cx2), .B(d_cx2), .TC(1'd0), .CLK (CLK), .Z(squd_cx2));
CW_mult_n_stage #(7'd32, 7'd32, 2'd3) u3 ( .A(d_cx3), .B(d_cx3), .TC(1'd0), .CLK (CLK), .Z(squd_cx3));
CW_mult_n_stage #(7'd32, 7'd32, 2'd3) u4 ( .A(d_cy1), .B(d_cy1), .TC(1'd0), .CLK (CLK), .Z(squd_cy1));
CW_mult_n_stage #(7'd32, 7'd32, 2'd3) u5 ( .A(d_cy2), .B(d_cy2), .TC(1'd0), .CLK (CLK), .Z(squd_cy2));
CW_mult_n_stage #(7'd32, 7'd32, 2'd3) u6 ( .A(d_cy3), .B(d_cy3), .TC(1'd0), .CLK (CLK), .Z(squd_cy3));
CW_minmax 		#(4'd10, 2'd3)		  u7 (.a({dis3[64:55],dis2[64:55],dis1[64:55]}),.tc(1'd0),.min_max(1'd0),.value(value),.index(cluster));

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		selfcounter <= 10'd0;
	else
		selfcounter <= selfcounter + 10'd1;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		allcounter <= 10'd0;
	else if(IN_VALID == 1'd0)
		allcounter <= 10'd0;
	else
		allcounter <= allcounter + 10'd1;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		bcounter <= 4'd0;
	else if(selfcounter < 10'd6)
		bcounter <= 4'd0;
	else if(selfcounter == 10'd6)
		bcounter <= 4'd1;
	else if(bcounter < 4'd7)
		bcounter <= bcounter + 4'd1;
	else
		bcounter <= 4'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		busy <= 1'd0;
	else if((bcounter > 4'd0) && (bcounter < 4'd7))
		busy <= 1'd1;
	else
		busy <= 1'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
	begin
		cx1 <= 32'd0;
		cx2 <= 32'd0;
		cx3 <= 32'd0;
		cy1 <= 32'd0;
		cy2 <= 32'd0;
		cy3 <= 32'd0;
	end
	else if(IN_VALID == 1'd0)
	begin
		cx1 <= 32'd0;
		cx2 <= 32'd0;
		cx3 <= 32'd0;
		cy1 <= 32'd0;
		cy2 <= 32'd0;
		cy3 <= 32'd0;
	end
	else if(allcounter == 10'd0)
		cx1 <= IN_DATA;
	else if(allcounter == 10'd1)
		cy1 <= IN_DATA;
	else if(allcounter == 10'd2)
		cx2 <= IN_DATA;
	else if(allcounter == 10'd3)
		cy2 <= IN_DATA;
	else if(allcounter == 10'd4)
		cx3 <= IN_DATA;
	else if(allcounter == 10'd5)
		cy3 <= IN_DATA;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
	begin
		xclk <= 1'd0;
		yclk <= 1'd0;
	end
	else if(allcounter < 10'd6)
	begin
		xclk <= 1'd0;
		yclk <= 1'd0;
	end
	else if(allcounter == 10'd6)
	begin
		xclk <= 1'd0;
		yclk <= 1'd1;
	end
	else if(allcounter == 10'd7)
	begin
		xclk <= 1'd1;
		yclk <= 1'd0;
	end
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
	begin
		x <= 32'd0;
		y <= 32'd0;
	end
	else if(allcounter < 10'd6)
	begin
		x <= 32'd0;
		y <= 32'd0;
	end
	else if(allcounter == 10'd6)
		x <= IN_DATA;
	else if(allcounter == 10'd7)
		y <= IN_DATA;
	else if(xclk == 1'd1)
	begin
		x <= IN_DATA;
		y <= y ;
	end
	else if(yclk == 1'd1)
	begin
		x <= x;
		y <= IN_DATA;
	end
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		d_cx1 <= 32'd0;
	else if(x == 0)
		d_cx1 <= 32'd0;
	else if(allcounter < 10'd7)
		d_cx1 <= 32'd0;
	else if(x[31:28] > cx1[31:28])
		d_cx1 <= x - cx1;
	else if(x[31:28] < cx1[31:28])
		d_cx1 <= cx1 - x;
	else 
		d_cx1 <= 32'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		d_cx2 <= 32'd0;
	else if(x == 0)
		d_cx2 <= 32'd0;
	else if(allcounter < 10'd7)
		d_cx2 <= 32'd0;
	else if(x[31:28] > cx2[31:28])
		d_cx2 <= x - cx2;
	else if(x[31:28] < cx2[31:28])
		d_cx2 <= cx2 - x;
	else 
		d_cx2 <= 32'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		d_cx3 <= 32'd0;
	else if(x == 0)
		d_cx3 <= 32'd0;
	else if(allcounter < 10'd7)
		d_cx3 <= 32'd0;
	else if(x[31:28] > cx3[31:28])
		d_cx3 <= x - cx3;
	else if(x[31:28] < cx3[31:28])
		d_cx3 <= cx3 - x;
	else 
		d_cx3 <= 32'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		d_cy1 <= 32'd0;
	else if(y == 0)
		d_cy1 <= 32'd0;
	else if(allcounter < 10'd8)
		d_cy1 <= 32'd0;
	else if(y[31:28] > cy1[31:28])
		d_cy1 <= y - cy1;
	else if(y[31:28] < cy1[31:28])
		d_cy1 <= cy1 - y;
	else 
		d_cy1 <= 32'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		d_cy2 <= 32'd0;
	else if(y == 0)
		d_cy2 <= 32'd0;
	else if(allcounter < 10'd8)
		d_cy2 <= 32'd0;
	else if(y[31:28] > cy2[31:28])
		d_cy2 <= y - cy2;
	else if(y[31:28] < cy2[31:28])
		d_cy2 <= cy2 - y;
	else 
		d_cy2 <= 32'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		d_cy3 <= 32'd0;
	else if(y == 0)
		d_cy3 <= 32'd0;
	else if(allcounter < 10'd8)
		d_cy3 <= 32'd0;
	else if(y[31:28] > cy3[31:28])
		d_cy3 <= y - cy3;
	else if(y[31:28] < cy3[31:28])
		d_cy3 <= cy3 - y;
	else 
		d_cy3 <= 32'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		disrclk <= 1'd0;
	else 
		disrclk <= ~disrclk;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		dis1 <= 65'd0;
	else if(disrclk == 1'd1)
		dis1 <= squd_cx1[63:0] + squd_cy1[63:0];
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		dis2 <= 65'd0;
	else if(disrclk == 1'd1)
		dis2 <= squd_cx2[63:0] + squd_cy2[63:0];
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		dis3 <= 65'd0;
	else if(disrclk == 1'd1)
		dis3 <= squd_cx3[63:0] + squd_cy3[63:0];
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		OUT_VALID <= 1'd0;
	else if(bcounter == 4'd6)
		OUT_VALID <= 1'd1;
	else
		OUT_VALID <= 1'd0;
end

always@(posedge CLK or posedge RESET)
begin
	if(RESET)
		OUT_DATA  <= 2'd0;
	else if(bcounter == 4'd6)
		OUT_DATA  <= cluster;
	else
		OUT_DATA  <= 2'd0;
end
endmodule
