//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module top_level( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA vertical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
				 //Signals for PS2 Keyboard
				 input logic					PS2_CLK, PS2_DAT,
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk, press; //press = 0 means key has been released, press = 1 means key is pressed
    logic [7:0] keycode1, keycode2;
    logic [9:0] DrawX, DrawY;
	 
	 //menu variables
	 logic [18:0] OCM_address_menu;
	 logic paused, is_menu;
	 logic [2:0] menu_color;
	 
	 //player variables
	 logic [17:0] OCM_address1;
	 logic [17:0] OCM_address2;
	 logic is_sprite1, is_sprite2;
	 logic [3:0] pix_color1, pix_color2;
	 
	 logic [9:0] p1_x, p2_x;
	 logic p1_punch, p2_punch;
	 logic [9:0] p1_health, p2_health;
	 
	 //points variables
	 logic Reset_points;
	 logic [3:0] p1_digit_1, p1_digit_2, p2_digit_1, p2_digit_2;
	 
	 
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
		  Reset_points <= ~(KEY[1]);
    end
	 
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode2),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    //Instantiate On-chip-memory sprites
	 OCMmenu OCM_menu(.clock(Clk), .address(OCM_address_menu), .q(menu_color));
	 OCM1 OCM_1(.clock(Clk), .address(OCM_address1), .q(pix_color1));
	 OCM2 OCM_2(.clock(Clk), .address(OCM_address2), .q(pix_color2));
	 
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    VGA_controller vga_controller_instance(.*, .Reset(Reset_h));
    
    // Game-related instances
	 menu menu_instance(.*, .Reset(Reset_h), .frame_clk(VGA_VS));
    player1 player1_instance(.*, .keycode(keycode1), .Reset(Reset_h), .frame_clk(VGA_VS));
	 player2 player2_instance(.*, .keycode(keycode2), .Reset(Reset_h), .frame_clk(VGA_VS));
	 points player1_points(.Clk(Clk), .Reset(Reset_points), .player_health(p1_health), .player_digit_1(p2_digit_1), .player_digit_2(p2_digit_2));
	 points player2_points(.Clk(Clk), .Reset(Reset_points), .player_health(p2_health), .player_digit_1(p1_digit_1), .player_digit_2(p1_digit_2));

    color_mapper color_instance(.*);
	 
	 keyboard PS2(.Clk, .reset(Reset_h), .psClk(PS2_CLK), .psData(PS2_DAT), .press(press), .keycode(keycode1));
    
    // Display player points on hex display
    HexDriver hex_inst_0 (p2_digit_1, HEX0);
    HexDriver hex_inst_1 (p2_digit_2, HEX1);
	 HexDriver hex_inst_2 (4'b0010, HEX2);
	 assign HEX3 = 7'b0001100;
	 HexDriver hex_ints_4 (p1_digit_1, HEX4);
	 HexDriver hex_inst_5 (p1_digit_2, HEX5);
	 HexDriver hex_inst_6 (4'b0001, HEX6);
	 assign HEX7 = 7'b0001100;
	 
	 // Display PS/2 keycode on hex display
//	 HexDriver hex_inst_0 (keycode1[3:0], HEX0);
//	 HexDriver hex_inst_1 (keycode1[7:4], HEX1);
//	 HexDriver hex_inst_2 ({3'b0, press}, HEX2);
//	 HexDriver hex_ints_4 (keycode2[3:0], HEX4);
//	 HexDriver hex_inst_5 (keycode2[7:4], HEX5);
//	 HexDriver hex_inst_7 ({3'b0, paused}, HEX7);
endmodule
