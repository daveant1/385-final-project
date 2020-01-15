//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper (  input		is_sprite1, is_sprite2,  //condition of sprite vs background
						input		[3:0] pix_color1, pix_color2,  //color of sprite pixel using color palette
						input		[9:0] p1_health, p2_health,	//health bars of players
						
						input	   paused, is_menu,
						input		[2:0] menu_color,

						input   	[9:0] DrawX, DrawY,       // Current pixel coordinates
                        output	logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    // Assign color based on is_ball signal
    always_comb
    begin
			if (paused == 1'b1 && is_menu == 1'b1)
				begin
				case(menu_color)
				3'b0001:
					begin
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'h00;
					end
				3'b0010:
					begin
					Red = 8'hff;
					Green = 8'h60;
					Blue = 8'h00;
					end
				3'b0011:
					begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'hFF;
					end
				3'b0100:
					begin
					Red = 8'h00;
					Green = 8'h90;
					Blue = 8'h0E;
					end
				3'b0101:
					begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
					end
				default:
					begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
					end
				endcase
				end
			
			else if (is_sprite1 == 1'b1 || is_sprite2 == 1'b1) 
				begin
				if (pix_color1 == 4'b0000)
					case(pix_color2)
					3'b0001:
						begin
						Red = 8'hff;
						Green = 8'h00;
						Blue = 8'h00;
						end
					3'b0010:
						begin
						Red = 8'hff;
						Green = 8'h60;
						Blue = 8'h00;
						end
					3'b0011:
						begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'hFF;
						end
					3'b0100:
						begin
						Red = 8'h00;
						Green = 8'h90;
						Blue = 8'h0E;
						end
					default:
						begin
						Red = 8'h00;
						Green = 8'hF4;
						Blue = 8'hFF;
						end
					endcase
				else
					case(pix_color1)
					3'b0001:
						begin
						Red = 8'hff;
						Green = 8'h00;
						Blue = 8'h00;
						end
					3'b0010:
						begin
						Red = 8'hff;
						Green = 8'h60;
						Blue = 8'h00;
						end
					3'b0011:
						begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'hFF;
						end
					3'b0100:
						begin
						Red = 8'h00;
						Green = 8'h90;
						Blue = 8'h0E;
						end
					default:
						begin
						Red = 8'h00;
						Green = 8'hF4;
						Blue = 8'hFF;
						end
					endcase
				end
		
			else
				begin
				if (DrawY >= 10'd400)
					begin
					Red = 8'h96;
					Green = 8'h4B;
					Blue = 8'h00;
					end
				else if (DrawY <= 10'd100 && DrawY >= 10'd50)
					begin
						if (DrawX > 10'd50 && DrawX <= 10'd290)
							if (10'd290 - DrawX < p1_health*10'd15)
								begin
								Red = 8'h00;
								Green = 8'hAF;
								Blue = 8'h00;
								end
							else
								begin
								Red = 8'hAF;
								Green = 8'h00;
								Blue = 8'h00;
								end
						else if (DrawX >= 10'd350 && DrawX < 10'd590)
							if (DrawX < p2_health*10'd15 + 10'd350)
								begin
								Red = 8'h00;
								Green = 8'hAF;
								Blue = 8'h00;
								end
							else
								begin
								Red = 8'hAF;
								Green = 8'h00;
								Blue = 8'h00;
								end
						else
							begin
							Red = 8'h00;
							Green = 8'hF4;
							Blue = 8'hFF;	
							end
					end
				else
					begin
					Red = 8'h00;
					Green = 8'hF4;
					Blue = 8'hFF;	
					end
				end
    end 
    
endmodule
