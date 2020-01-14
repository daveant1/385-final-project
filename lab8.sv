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


module lab8( input               CLOCK_50,
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
//             // CY7C67200 Interface
//             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
//             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
//             output logic        OTG_CS_N,     //CY7C67200 Chip Select
//                                 OTG_RD_N,     //CY7C67200 Write
//                                 OTG_WR_N,     //CY7C67200 Read
//                                 OTG_RST_N,    //CY7C67200 Reset
//             input               OTG_INT,      //CY7C67200 Interrupt
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
    logic [7:0] keycode;
    logic [9:0] DrawX, DrawY;
	 
	 logic [17:0] OCM_address;
	 logic [17:0] OCM_address1;
	 logic [17:0] OCM_address2;
	 logic is_sprite1, is_sprite2;
	 logic [3:0] pix_color1, pix_color2;
	 
	 logic [9:0] p1_x, p2_x;
	 logic p1_punch, p2_punch;

	 
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end

    
//    logic [1:0] hpi_addr;
//    logic [15:0] hpi_data_in, hpi_data_out;
//    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
//    // Interface between NIOS II and EZ-OTG chip
//    hpi_io_intf hpi_io_inst(
//                            .Clk(Clk),
//                            .Reset(Reset_h),
//                            // signals connected to NIOS II
//                            .from_sw_address(hpi_addr),
//                            .from_sw_data_in(hpi_data_in),
//                            .from_sw_data_out(hpi_data_out),
//                            .from_sw_r(hpi_r),
//                            .from_sw_w(hpi_w),
//                            .from_sw_cs(hpi_cs),
//                            .from_sw_reset(hpi_reset),
//                            // signals connected to EZ-OTG chip
//                            .OTG_DATA(OTG_DATA),    
//                            .OTG_ADDR(OTG_ADDR),    
//                            .OTG_RD_N(OTG_RD_N),    
//                            .OTG_WR_N(OTG_WR_N),    
//                            .OTG_CS_N(OTG_CS_N),
//                            .OTG_RST_N(OTG_RST_N)
//    );

	      // You need to make sure that the port names here match the ports in Qsys-generated codes.
//     lab8_soc nios_system(
//                             .clk_clk(Clk),         
//                             .reset_reset_n(1'b1),    // Never reset NIOS
//                             .sdram_wire_addr(DRAM_ADDR), 
//                             .sdram_wire_ba(DRAM_BA),   
//                             .sdram_wire_cas_n(DRAM_CAS_N),
//                             .sdram_wire_cke(DRAM_CKE),  
//                             .sdram_wire_cs_n(DRAM_CS_N), 
//                             .sdram_wire_dq(DRAM_DQ),   
//                             .sdram_wire_dqm(DRAM_DQM),  
//                             .sdram_wire_ras_n(DRAM_RAS_N),
//                             .sdram_wire_we_n(DRAM_WE_N), 
//                             .sdram_clk_clk(DRAM_CLK),
//    );


    //Instantiate On-chip-memory sprites
	 OCM1 OCM_1(.clock(Clk), .address(OCM_address1), .q(pix_color1));
	 OCM2 OCM_2(.clock(Clk), .address(OCM_address2), .q(pix_color2));
//	 always_comb
//	 begin
//		if (is_sprite1 == 1)
//			OCM_address = OCM_address1;
//		else
//			OCM_address = OCM_address2;
//	 end
	 
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(.*, .Reset(Reset_h));
    
    // Which signal should be frame_clk?
    player1 player1_instance(.*, .Reset(Reset_h), .frame_clk(VGA_VS));
	 player2 player2_instance(.*, .Reset(Reset_h), .frame_clk(VGA_VS));

    color_mapper color_instance(.*);
	 
	 keyboard PS2(.Clk, .reset(Reset_h), .psClk(PS2_CLK), .psData(PS2_DAT), .press(press), .keycode);
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (keycode[3:0], HEX0);
    HexDriver hex_inst_1 (keycode[7:4], HEX1);
//	 HexDriver hex_ints_2 (keycode[11:8], HEX2);
//	 HexDriver hex_inst_3 (keycode[15:12], HEX3);
//	 HexDriver hex_inst_6 ({3'b0, press2}, HEX4);
	 HexDriver hex_inst_3 ({3'b0, press}, HEX3);
endmodule