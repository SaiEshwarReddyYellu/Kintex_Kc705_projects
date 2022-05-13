
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2022 13:56:31
// Design Name: 
// Module Name: vip_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////////
import axi4stream_vip_pkg::*;
import design_1_axi4stream_vip_0_0_pkg::*;

module vip_test(
    );
 
    logic aclk_0 = 0;
    logic aresetn_0 = 0;   
    
    always #1.665ns aclk_0 <= ~aclk_0;
        
        design_1_wrapper DUT
        (.aclk_0(aclk_0),
        .aresetn_0(aresetn_0));
      
     initial begin
        #10ns;
        aresetn_0 <= 1'b1;
     end  
       
     initial begin
     // Ready signal created by slave VIP when TREADY is High   
      axi4stream_ready_gen      ready_gen;  
        
    // declare agent
      design_1_axi4stream_vip_0_0_slv_t     slv_agent;  
    
    slv_agent = new("slave vip agent",DUT.design_1_i.axi4stream_vip_0.inst.IF);
    slv_agent.start_slave();
    slv_agent.set_verbosity(400);
//    slv_agent.vif_proxy.set_dummy_drive_type(XIL_AXI_VIF_DRIVE_NONE);
//        fork
            begin
//                slv_gen_tready();

            axi4stream_ready_gen                           ready_gen;
            ready_gen = slv_agent.driver.create_ready("ready_gen");
            ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_OSC);
            ready_gen.set_low_time(2);
            ready_gen.set_high_time(6);
            slv_agent.driver.send_tready(ready_gen);
                
            end
//        join_any
    end
    
//          task slv_gen_tready();
//            axi4stream_ready_gen                           ready_gen;
//            ready_gen = slv_agent.driver.create_ready("ready_gen");
//            ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_OSC);
//            ready_gen.set_low_time(2);
//            ready_gen.set_high_time(6);
//            slv_agent.driver.send_tready(ready_gen);
//          endtask :slv_gen_tready
    
endmodule

