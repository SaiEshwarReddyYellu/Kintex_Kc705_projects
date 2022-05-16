
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.03.2022 17:30:55
-- Design Name: 
-- Module Name: top_pl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_misc.ALL;
use work.my_port_ranges.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_pl is
--  Port ( );
     port (
            clk_80M : in std_logic;
            clk_300M : in std_logic;
            SENSOR_LOCK : in std_logic;
            rst_n : in std_logic;
            m00_tready : in std_logic;
            m00_tdata : out std_logic_vector(127 downto 0);
            m00_tvalid : out std_logic
            );
end top_pl;

architecture Behavioral of top_pl is

--creating axi-stream bus
ATTRIBUTE X_INTERFACE_INFO : STRING;

-- ATTRIBUTE X_INTERFACE_INFO OF axi_clk : SIGNAL IS "xilinx.com:signal:clock:1.0 Master_m00_tdata CLK";

-- ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
-- ATTRIBUTE X_INTERFACE_PARAMETER OF axi_clk : signal is "X_INTERFACE_INFO axi_clk, FREQ_HZ 300000000 ";

ATTRIBUTE X_INTERFACE_INFO OF m00_tdata : SIGNAL IS "xilinx.com:interface:axis:1.0 Master_m00_tdata TDATA";
ATTRIBUTE X_INTERFACE_INFO OF m00_tvalid : SIGNAL IS "xilinx.com:interface:axis:1.0 Master_m00_tdata TVALID";
ATTRIBUTE X_INTERFACE_INFO OF m00_tready :  SIGNAL IS "xilinx.com:interface:axis:1.0 Master_m00_tdata TREADY";

    ---clocking wizard signals
         signal clk_80 : std_logic := '0';
         signal clk_300 : std_logic := '0';
         signal locked : std_logic := '0';

---sensor component signals

        signal data_r_bus_i : data_ports(((color_ln * lvds_lines)- 25) downto 0) := (others => x"000");
        signal data_g_bus_i : data_ports(((color_ln * lvds_lines)- 17) downto 8) := (others => x"000");
        signal data_b_bus_i : data_ports(((color_ln * lvds_lines)- 9) downto 16) := (others => x"000");
        signal data_c_bus_i : data_ports(((color_ln * lvds_lines)- 1) downto 24) := (others => x"000");
        signal data_valid_i: std_logic := '0';
        
      --toggle signal
        signal tog_cnt : integer range 0 to 1200 := 0;
        signal toggle_i : std_logic := '0'; 
        
        --memory signals for red pixels
        signal wr_en : std_logic := '0';
        signal wr_en_a : std_logic := '0';
        signal wea_0 : std_logic_vector(0 downto 0) := "0";
        signal addra_i : std_logic_vector(8 downto 0) := (others => '0');        
        signal din_mem_0 : std_logic_vector(95 downto 0) := (others => '0');
        signal addr_cnt : integer range 0 to 193 := 0;
        
        --pipeline registers
        --for red pixels
        signal ram_r_d1_pl : std_logic_vector(95 downto 0) := (others => '0');
        signal ram_r_d2_pl : std_logic_vector(107 downto 0) := (others => '0');
        signal ram_r_d3_pl : std_logic_vector(119 downto 0) := (others => '0');
        signal ram_r_d4_pl : std_logic_vector(131 downto 0) := (others => '0');
        signal ram_r_d5_pl : std_logic_vector(143 downto 0) := (others => '0');
        signal ram_r_d6_pl : std_logic_vector(155 downto 0) := (others => '0');
        signal ram_r_d7_pl : std_logic_vector(167 downto 0) := (others => '0');
        signal ram_r_d8_pl : std_logic_vector(179 downto 0) := (others => '0');
        
        
        --memory for green pixels
        signal wr_en_g : std_logic := '0';
        signal wr_en_a_g : std_logic := '0';
        signal wea_0_g : std_logic_vector(0 downto 0) := "0";
        signal addra_i_g : std_logic_vector(8 downto 0) := o"000";   
        signal ram_g_d1_pl : std_logic_vector(95 downto 0) := (others => '0');
        signal ram_g_d2_pl : std_logic_vector(107 downto 0) := (others => '0');
        signal ram_g_d3_pl : std_logic_vector(119 downto 0) := (others => '0');
        signal ram_g_d4_pl : std_logic_vector(131 downto 0) := (others => '0');
        signal ram_g_d5_pl : std_logic_vector(143 downto 0) := (others => '0');
        signal ram_g_d6_pl : std_logic_vector(155 downto 0) := (others => '0');
        signal ram_g_d7_pl : std_logic_vector(167 downto 0) := (others => '0');
        signal ram_g_d8_pl : std_logic_vector(179 downto 0) := (others => '0');   
        signal din_mem_0_g : std_logic_vector(95 downto 0) := (others => '0');
        signal data_out_g : std_logic_vector(23 downto 0) := (others => '0');
        signal addr_cnt_g : integer range 0 to 49 := 0;
       
            
         --memory for blue pixels
        signal wr_en_b : std_logic := '0';
        signal wr_en_a_b : std_logic := '0';
        signal wea_0_b : std_logic_vector(0 downto 0) := "0";
        signal addra_i_b : std_logic_vector(8 downto 0) := o"000"; 
        signal ram_b_d1_pl : std_logic_vector(95 downto 0) := (others => '0');
        signal ram_b_d2_pl : std_logic_vector(107 downto 0) := (others => '0');
        signal ram_b_d3_pl : std_logic_vector(119 downto 0) := (others => '0');
        signal ram_b_d4_pl : std_logic_vector(131 downto 0) := (others => '0');
        signal ram_b_d5_pl : std_logic_vector(143 downto 0) := (others => '0');
        signal ram_b_d6_pl : std_logic_vector(155 downto 0) := (others => '0');
        signal ram_b_d7_pl : std_logic_vector(167 downto 0) := (others => '0');
        signal ram_b_d8_pl : std_logic_vector(179 downto 0) := (others => '0');   
        signal din_mem_0_b : std_logic_vector(95 downto 0) := (others => '0');
        signal data_out_b : std_logic_vector(23 downto 0) := (others => '0');
        signal addr_cnt_b : integer range 0 to 49 := 0;
        
        
           --memory for clear pixels
        signal wr_en_c : std_logic := '0';
        signal wr_en_a_c : std_logic := '0';
        signal wea_0_c : std_logic_vector(0 downto 0) := "0";
        signal addra_i_c : std_logic_vector(8 downto 0) := o"000"; 
        signal ram_c_d1_pl : std_logic_vector(95 downto 0) := (others => '0');
        signal ram_c_d2_pl : std_logic_vector(107 downto 0) := (others => '0');
        signal ram_c_d3_pl : std_logic_vector(119 downto 0) := (others => '0');
        signal ram_c_d4_pl : std_logic_vector(131 downto 0) := (others => '0');
        signal ram_c_d5_pl : std_logic_vector(143 downto 0) := (others => '0');
        signal ram_c_d6_pl : std_logic_vector(155 downto 0) := (others => '0');
        signal ram_c_d7_pl : std_logic_vector(167 downto 0) := (others => '0');
        signal ram_c_d8_pl : std_logic_vector(179 downto 0) := (others => '0');
        signal din_mem_0_c : std_logic_vector(95 downto 0) := (others => '0');
        signal data_out_c : std_logic_vector(23 downto 0) := (others => '0');
        signal addr_cnt_c : integer range 0 to 49 := 0;
        
        
        
        ----control signals for red pixel memory
            signal wr_en_normal :std_logic := '0';
            signal wea_normal : std_logic_vector(0 downto 0) := "0";
            signal rd_en_normal : std_logic := '0';
            signal addra_i_normal : std_logic_vector(8 downto 0) := o"000";
            signal din_normal :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_normal : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_normal : std_logic_vector(23 downto 0) := (others => '0');
            signal wr_en_pp :std_logic := '0';
            signal wea_pp : std_logic_vector(0 downto 0) := "0";
            signal rd_en_pp : std_logic := '0';
            signal addra_i_pp : std_logic_vector(8 downto 0) := o"000";
            signal din_pp :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_pp : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_pp : std_logic_vector(23 downto 0) := (others => '0');
        
        
        ---control signals for green pixel memory
            signal wr_en_g_normal :std_logic := '0';
            signal wea_g_normal : std_logic_vector(0 downto 0) := "0";
            signal rd_en_g_normal : std_logic := '0';
            signal addra_i_g_normal : std_logic_vector(8 downto 0) := o"000";
            signal din_g_normal :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_g_normal : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_g_normal : std_logic_vector(23 downto 0) := (others => '0');
            signal wr_en_g_pp :std_logic := '0';
            signal wea_g_pp : std_logic_vector(0 downto 0) := "0";
            signal rd_en_g_pp : std_logic := '0';
            signal addra_i_g_pp : std_logic_vector(8 downto 0) := o"000";
            signal din_g_pp :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_g_pp : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_g_pp : std_logic_vector(23 downto 0) := (others => '0');
        
        
        ---control signals for blue pixel memory
            signal wr_en_b_normal :std_logic := '0';
            signal wea_b_normal : std_logic_vector(0 downto 0) := "0";
            signal rd_en_b_normal : std_logic := '0';
            signal addra_i_b_normal : std_logic_vector(8 downto 0) := o"000";
            signal din_b_normal :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_b_normal : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_b_normal : std_logic_vector(23 downto 0) := (others => '0');
            signal wr_en_b_pp :std_logic := '0';
            signal wea_b_pp : std_logic_vector(0 downto 0) := "0";
            signal rd_en_b_pp : std_logic := '0';
            signal addra_i_b_pp : std_logic_vector(8 downto 0) := o"000";
            signal din_b_pp :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_b_pp : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_b_pp : std_logic_vector(23 downto 0) := (others => '0');
        
        
          ---control signals for clear pixel memory
            signal wr_en_c_normal :std_logic := '0';
            signal wea_c_normal : std_logic_vector(0 downto 0) := "0";
            signal rd_en_c_normal : std_logic := '0';
            signal addra_i_c_normal : std_logic_vector(8 downto 0) := o"000";
            signal din_c_normal :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_c_normal : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_c_normal : std_logic_vector(23 downto 0) := (others => '0');
            signal wr_en_c_pp :std_logic := '0';
            signal wea_c_pp : std_logic_vector(0 downto 0) := "0";
            signal rd_en_c_pp : std_logic := '0';
            signal addra_i_c_pp : std_logic_vector(8 downto 0) := o"000";
            signal din_c_pp :std_logic_vector(95 downto 0) := (others => '0');
            signal addrb_c_pp : std_logic_vector(10 downto 0) := (others => '0');
            signal data_out_c_pp : std_logic_vector(23 downto 0) := (others => '0');
            
            
            --pipeline registers for reading block
            signal read_cnt : integer range 0 to 1537 := 0;
            signal read_cnt_pp : integer range 0 to 1537 := 0;
            signal red_pixels : std_logic_vector(23 downto 0) := (others => '0');
            signal green_pixels : std_logic_vector (23 downto 0) := (others => '0');
            signal blue_pixels : std_logic_vector(23 downto 0) := (others => '0');
            signal clear_pixels : std_logic_vector(23 downto 0) := (others => '0');

        --output bus
        signal bv_bus : data_ports(7 downto 0) := (others => (others => '0'));
		
        --read ctrl logic
            signal read_flag : std_logic := '0';
            signal set_cnt : integer range 0 to 450 := 0;
            signal flag_cnt : integer range 0 to 2600 := 0;

                 --PLL with 80 mhz and 300 mhz
--      component clk_wiz_0 
--        port (
--       --  Clock out ports
--          clk_out1 : out std_logic;
--          clk_out2 : out std_logic;
--          locked : out std_logic;
--    --    Status and control signals
--         resetn : in std_logic;
--    --    Clock in ports
--          clk_in1 : in std_logic);
--      end component clk_wiz_0;


              --sensor component
    component sensor_comp is
                
        Port ( pix_clk_80 : in STD_LOGIC;          --80MHZ
               rst : in STD_LOGIC;
               clk_locked : in STD_LOGIC;
               data_r : out data_ports(((color_ln * lvds_lines)- 25) downto 0);
               data_g : out data_ports(((color_ln * lvds_lines)- 17) downto 8);
               data_b : out data_ports(((color_ln * lvds_lines)- 9) downto 16);
               data_c : out data_ports(((color_ln * lvds_lines)- 1) downto 24);
               data_valid : out STD_LOGIC);
    
    end component;
	

        --bram component_0
        component blk_mem_gen_0 is
               PORT (
                    clka : IN STD_LOGIC;
                    ena : IN STD_LOGIC;
                    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
                    addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
                    dina : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
                    clkb : IN STD_LOGIC;
                    enb : IN STD_LOGIC;
                    addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
                    doutb : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
                  );
        
        end component blk_mem_gen_0;


    signal ready_reg : std_logic := '0';
    signal t_valid : std_logic := '0';
    signal t_data : std_logic_vector(95 downto 0) := (others => '0');
    
    signal t_valid_e : std_logic := '0';
    signal t_data_e : std_logic_vector(95 downto 0) := (others => '0');
    
	signal t_valid_e1 : std_logic := '0';
	
	
	signal m00_tdata_i :std_logic_vector(95 downto 0) := (others => '0'); 
begin
        m00_tvalid <=  t_valid ;
        m00_tdata_i <=  t_data;
           
		m00_tdata <= m00_tdata_i & x"00000000";
		
		CLK_80 <= clk_80m;
		clk_300 <= clk_300m;
		locked <= sensor_lock;
                    --clock instantiation
--          clk_ins : clk_wiz_0
--           port map (
--                   clk_in1 => axi_clk,
--                   resetn => rst_n,
--                   locked => locked,
--                   clk_out1 => clk_80,
--                   clk_out2 => clk_300);
                    
          
                  sensor_comp_ins: sensor_comp
        
            port map(
                        pix_clk_80 => clk_80,
                        rst => rst_n,
                        clk_locked => locked,
                        data_r => data_r_bus_i,
                        data_g => data_g_bus_i,
                        data_b => data_b_bus_i,
                        data_c => data_c_bus_i,
                        data_valid => data_valid_i
                        );          

              --bram instantiation for red pixels
            bram_red_ins : blk_mem_gen_0
                port map (
                            clka => clk_80,
                            ena => wr_en_normal,
                            wea => wea_normal,
                            addra => addra_i_normal,
                            dina =>  din_normal,
                            clkb => clk_300,
                            enb => rd_en_normal,
                            addrb => addrb_normal,
                            doutb => data_out_normal
                        );
       
             bram_green_ins :   blk_mem_gen_0   
                   port map (
                            clka => clk_80,
                            ena => wr_en_g_normal,
                            wea => wea_g_normal,
                            addra => addra_i_g_normal,
                            dina =>  din_g_normal,
                            clkb => clk_300,
                            enb => rd_en_g_normal,
                            addrb => addrb_g_normal,
                            doutb => data_out_g_normal
                        );
              
              bram_blue_ins :  blk_mem_gen_0         
                      port map (
                            clka => clk_80,
                            ena => wr_en_b_normal,
                            wea => wea_b_normal,
                            addra => addra_i_b_normal,
                            dina =>  din_b_normal,
                            clkb => clk_300,
                            enb => rd_en_b_normal,
                            addrb => addrb_b_normal,
                            doutb => data_out_b_normal
                        );    
                      
              bram_clear_ins: blk_mem_gen_0        
                      port map (
                            clka => clk_80,
                            ena => wr_en_c_normal,
                            wea => wea_c_normal,
                            addra => addra_i_c_normal,
                            dina =>  din_c_normal,
                            clkb => clk_300,
                            enb => rd_en_c_normal,
                            addrb => addrb_c_normal,
                            doutb => data_out_c_normal
                        ); 
               
             bram_red_ping_pong_ins: blk_mem_gen_0
                      port map (
                            clka => clk_80,
                            ena => wr_en_pp,
                            wea => wea_pp,
                            addra => addra_i_pp,
                            dina =>  din_pp,
                            clkb => clk_300,
                            enb => rd_en_pp,
                            addrb => addrb_pp,
                            doutb => data_out_pp
                        );
                        
              bram_green_ping_pong_ins : blk_mem_gen_0
                      port map (
                            clka => clk_80,
                            ena => wr_en_g_pp,
                            wea => wea_g_pp,
                            addra => addra_i_g_pp,
                            dina =>  din_g_pp,
                            clkb => clk_300,
                            enb => rd_en_g_pp,
                            addrb => addrb_g_pp,
                            doutb => data_out_g_pp
                        );
                        
              bram_blue_ping_pong_ins : blk_mem_gen_0
                     port map (
                            clka => clk_80,
                            ena => wr_en_b_pp,
                            wea => wea_b_pp,
                            addra => addra_i_b_pp,
                            dina =>  din_b_pp,
                            clkb => clk_300,
                            enb => rd_en_b_pp,
                            addrb => addrb_b_pp,
                            doutb => data_out_b_pp
                        );  
                        
            bram_clear_ping_pong_ins : blk_mem_gen_0
                     port map (
                            clka => clk_80,
                            ena => wr_en_c_pp,
                            wea => wea_c_pp,
                            addra => addra_i_c_pp,
                            dina =>  din_c_pp,
                            clkb => clk_300,
                            enb => rd_en_c_pp,
                            addrb => addrb_c_pp,
                            doutb => data_out_c_pp
                        ); 

         bram_red: block 
        type state_type is(s0,s1,s2,s3,s4,s5,s6,s7, finished);
        signal state: state_type := s0;
        signal pl_cnt : integer range 0 to 7 := 0;
        
            begin
                process(clk_80)
                    begin
                        if rising_edge(clk_80) then
                            if data_valid_i = '1' then
                               
                                 ram_r_d1_pl(95 downto 0) <= data_r_bus_i(0) & ram_r_d1_pl(95 downto 12);
                                 ram_r_d2_pl(107 downto 0) <= data_r_bus_i(1) & ram_r_d2_pl(107 downto 12);
                                 ram_r_d3_pl(119 downto 0) <= data_r_bus_i(2) & ram_r_d3_pl(119 downto 12);
                                 ram_r_d4_pl(131 downto 0) <= data_r_bus_i(3) & ram_r_d4_pl(131 downto 12);
                                 ram_r_d5_pl(143 downto 0) <= data_r_bus_i(4) & ram_r_d5_pl(143 downto 12);
                                 ram_r_d6_pl(155 downto 0) <= data_r_bus_i(5) & ram_r_d6_pl(155 downto 12);
                                 ram_r_d7_pl(167 downto 0) <= data_r_bus_i(6) & ram_r_d7_pl(167 downto 12);
                                 ram_r_d8_pl(179 downto 0) <= data_r_bus_i(7) & ram_r_d8_pl(179 downto 12);
                                        pl_cnt <= pl_cnt + 1;       
                                            
                                            if pl_cnt = 7 then
                                                 wr_en <= '1'; 
                                                 addr_cnt <= 0;
                                                 state <= s0;
                                            end if; 
                               else
                                   pl_cnt <= 0;
                                                 
                                   ram_r_d1_pl(95 downto 0) <= "------------" & ram_r_d1_pl(95 downto 12) ;
                                   ram_r_d2_pl(107 downto 0) <= "------------" & ram_r_d2_pl(107 downto 12) ;
                                   ram_r_d3_pl(119 downto 0) <= "------------" & ram_r_d3_pl(119 downto 12) ;
                                   ram_r_d4_pl(131 downto 0) <= "------------" & ram_r_d4_pl(131 downto 12) ;
                                   ram_r_d5_pl(143 downto 0) <= "------------" & ram_r_d5_pl(143 downto 12) ;
                                   ram_r_d6_pl (155 downto 0) <= "------------" & ram_r_d6_pl(155 downto 12) ;
                                   ram_r_d7_pl (167 downto 0) <= "------------" & ram_r_d7_pl(167 downto 12) ;
                                   ram_r_d8_pl (179 downto 0) <= "------------" & ram_r_d8_pl(179 downto 12) ;                                                                    
                            end if;

                            if wr_en = '1' then
                                case state is
                                       when s0 =>
                                           din_mem_0 <= ram_r_d1_pl;
                                           addr_cnt <= addr_cnt + 1;
                                           addra_i <= std_logic_vector(to_unsigned(addr_cnt,addra_i'length));
                                           wr_en_a <= '1';
                                           wea_0 <= (others => '1');
                                           state <= s1;
                                       when s1 => 
                                           din_mem_0 <= ram_r_d2_pl(95 downto 0);
                                           addra_i <= std_logic_vector(to_unsigned((addr_cnt+47), addra_i'length));
                                           state <= s2;
                                       when s2 => 
                                           din_mem_0 <=  ram_r_d3_pl(95 downto 0);
                                            addra_i <= std_logic_vector(to_unsigned((addr_cnt+95), addra_i'length));
                                            state <= s3;
                                       when s3 => 
                                            din_mem_0 <= ram_r_d4_pl(95 downto 0);
                                            addra_i <= std_logic_vector(to_unsigned((addr_cnt+143), addra_i'length));
                                            state <= s4;
                                       when s4 => 
                                            din_mem_0 <= ram_r_d5_pl(95 downto 0);
                                            addra_i <= std_logic_vector(to_unsigned((addr_cnt+191), addra_i'length));
                                            state <= s5;
                                       when s5 => 
                                            din_mem_0 <= ram_r_d6_pl(95 downto 0);
                                            addra_i <= std_logic_vector(to_unsigned((addr_cnt+239), addra_i'length));
                                            state <= s6;
                                       when s6 => 
                                            din_mem_0 <= ram_r_d7_pl(95 downto 0);
                                            addra_i <= std_logic_vector(to_unsigned((addr_cnt+287), addra_i'length));
                                            state <= s7;
                                       when s7 => 
                                            din_mem_0 <= ram_r_d8_pl(95 downto 0);
                                            addra_i <= std_logic_vector(to_unsigned((addr_cnt+335), addra_i'length));
                                            
                                            if addr_cnt = 48 then
                                                state <= finished;
                                            else
                                                state <= s0;
                                            end if;
                                            
                                       when finished =>
                                                wr_en_a <= '0';
                                                wea_0 <= (others => '0');
                                                wr_en <= '0';                           
                                       when others => 
                                                    null;        
                                end case; 
                                              
                             end if;
                             
                            if toggle_i = '0' then
                                wr_en_normal <= wr_en;              --wr_en_a
                                wea_normal <= wea_0;
                                addra_i_normal <= addra_i;
                                din_normal <= din_mem_0;
                              else
                                wr_en_pp <= wr_en;                  --wr_en_a
                                wea_pp <= wea_0;
                                addra_i_pp <= addra_i;
                                din_pp <= din_mem_0;
                            end if;
                        end if; 
                end process;   

            end block bram_red;
            
            
          bram_green : block
            type state_type is(s0,s1,s2,s3,s4,s5,s6,s7, finished);
            signal state_g: state_type := s0;
            signal pl_cnt_g : integer range 0 to 7 := 0;
                begin
                     process(clk_80)
                    begin
                        if rising_edge(clk_80) then
                            if data_valid_i = '1' then

                                 ram_g_d1_pl(95 downto 0) <= data_g_bus_i(8) & ram_g_d1_pl(95 downto 12);
                                 ram_g_d2_pl(107 downto 0) <= data_g_bus_i(9) & ram_g_d2_pl(107 downto 12);
                                 ram_g_d3_pl(119 downto 0) <= data_g_bus_i(10) & ram_g_d3_pl(119 downto 12);
                                 ram_g_d4_pl(131 downto 0) <= data_g_bus_i(11) & ram_g_d4_pl(131 downto 12);
                                 ram_g_d5_pl(143 downto 0) <= data_g_bus_i(12) & ram_g_d5_pl(143 downto 12);
                                 ram_g_d6_pl(155 downto 0) <= data_g_bus_i(13) & ram_g_d6_pl(155 downto 12);
                                 ram_g_d7_pl(167 downto 0) <= data_g_bus_i(14) & ram_g_d7_pl(167 downto 12);
                                 ram_g_d8_pl(179 downto 0) <= data_g_bus_i(15) & ram_g_d8_pl(179 downto 12);
                                        pl_cnt_g <= pl_cnt_g + 1;
                                       
                                            
                                            if pl_cnt_g = 7 then
                                                 wr_en_g <= '1'; 
                                                 addr_cnt_g <= 0;
                                                 state_g <= s0;
                                            end if; 
                               else
                                   pl_cnt_g <= 0;
                                   ram_g_d1_pl(95 downto 0) <= "------------" & ram_g_d1_pl(95 downto 12) ;
                                   ram_g_d2_pl(107 downto 0) <= "------------" & ram_g_d2_pl(107 downto 12) ;
                                   ram_g_d3_pl(119 downto 0) <= "------------" & ram_g_d3_pl(119 downto 12) ;
                                   ram_g_d4_pl(131 downto 0) <= "------------" & ram_g_d4_pl(131 downto 12) ;
                                   ram_g_d5_pl(143 downto 0) <= "------------" & ram_g_d5_pl(143 downto 12) ;
                                   ram_g_d6_pl (155 downto 0) <= "------------" & ram_g_d6_pl(155 downto 12) ;
                                   ram_g_d7_pl (167 downto 0) <= "------------" & ram_g_d7_pl(167 downto 12) ;
                                   ram_g_d8_pl (179 downto 0) <= "------------" & ram_g_d8_pl(179 downto 12) ;                                                                    
                            end if;
                        
                            if wr_en_g = '1' then
                                case state_g is
                                       when s0 =>
                                           din_mem_0_g <= ram_g_d1_pl;
                                           addr_cnt_g <= addr_cnt_g + 1;
                                           addra_i_g <= std_logic_vector(to_unsigned(addr_cnt_g,addra_i_g'length));
                                           wr_en_a_g <= '1';
                                           wea_0_g <= (others => '1');
                                           state_g <= s1;
                                       when s1 => 
                                           din_mem_0_g <= ram_g_d2_pl(95 downto 0);
                                           addra_i_g <= std_logic_vector(to_unsigned((addr_cnt_g+47),addra_i_g'length));
                                           state_g <= s2;
                                       when s2 => 
                                           din_mem_0_g <=  ram_g_d3_pl(95 downto 0);
                                            addra_i_g <= std_logic_vector(to_unsigned((addr_cnt_g+95),addra_i_g'length));
                                            state_g <= s3;
                                       when s3 => 
                                            din_mem_0_g <= ram_g_d4_pl(95 downto 0);
                                            addra_i_g <= std_logic_vector(to_unsigned((addr_cnt_g + 143),addra_i_g'length));
                                            state_g <= s4;
                                       when s4 => 
                                            din_mem_0_g <= ram_g_d5_pl(95 downto 0);
                                            addra_i_g <= std_logic_vector(to_unsigned((addr_cnt_g + 191),addra_i_g'length));
                                            state_g <= s5;
                                       when s5 => 
                                            din_mem_0_g <= ram_g_d6_pl(95 downto 0);
                                            addra_i_g <= std_logic_vector(to_unsigned((addr_cnt_g+239),addra_i_g'length));
                                            state_g <= s6;
                                       when s6 => 
                                            din_mem_0_g <= ram_g_d7_pl(95 downto 0);
                                            addra_i_g <= std_logic_vector(to_unsigned((addr_cnt_g+287),addra_i_g'length));
                                            state_g <= s7;
                                       when s7 => 
                                            din_mem_0_g <= ram_g_d8_pl(95 downto 0);
                                            addra_i_g <= std_logic_vector(to_unsigned((addr_cnt_g+335),addra_i_g'length));
                                               
                                            if addr_cnt_g = 48 then
                                                state_g <= finished;
                                            else
                                                state_g <= s0;
                                            end if;
                                       when finished =>
                                                wr_en_a_g <= '0';
                                                wea_0_g <= (others => '0');
                                                wr_en_g <= '0';                           
                                       when others => 
                                                    null;        
                                end case; 
                                              
                             end if;
                             
                            if toggle_i = '0' then
                                wr_en_g_normal <= wr_en_a_g;
                                wea_g_normal <= wea_0_g;  
                                addra_i_g_normal <= addra_i_g;
                                din_g_normal <= din_mem_0_g;
                              else
                                wr_en_g_pp <= wr_en_a_g;
                                wea_g_pp <= wea_0_g;
                                addra_i_g_pp <= addra_i_g;
                                din_g_pp <= din_mem_0_g;
                            end if;
                            
        
                            
                        end if; 
                end process;    
                            
                end block bram_green; 

     bram_blue : block
            type state_type is(s0,s1,s2,s3,s4,s5,s6,s7, finished);
            signal state_b: state_type := s0;
            signal pl_cnt_b : integer range 0 to 7 := 0;
        begin
             process(clk_80)
                    begin
                        if rising_edge(clk_80) then
                            if data_valid_i = '1' then

                                 ram_b_d1_pl(95 downto 0) <= data_b_bus_i(16) & ram_b_d1_pl(95 downto 12);
                                 ram_b_d2_pl(107 downto 0) <= data_b_bus_i(17) & ram_b_d2_pl(107 downto 12);
                                 ram_b_d3_pl(119 downto 0) <= data_b_bus_i(18) & ram_b_d3_pl(119 downto 12);
                                 ram_b_d4_pl(131 downto 0) <= data_b_bus_i(19) & ram_b_d4_pl(131 downto 12);
                                 ram_b_d5_pl(143 downto 0) <= data_b_bus_i(20) & ram_b_d5_pl(143 downto 12);
                                 ram_b_d6_pl(155 downto 0) <= data_b_bus_i(21) & ram_b_d6_pl(155 downto 12);
                                 ram_b_d7_pl(167 downto 0) <= data_b_bus_i(22) & ram_b_d7_pl(167 downto 12);
                                 ram_b_d8_pl(179 downto 0) <= data_b_bus_i(23) & ram_b_d8_pl(179 downto 12);
                                        pl_cnt_b <= pl_cnt_b + 1;
                                       
                                            
                                            if pl_cnt_b = 7 then
                                                 wr_en_b <= '1'; 
                                                 addr_cnt_b <= 0;
                                                 state_b <= s0;
                                            end if; 
                               else
                                   pl_cnt_b <= 0;
                                   ram_b_d1_pl(95 downto 0) <= "------------" & ram_b_d1_pl(95 downto 12) ;
                                   ram_b_d2_pl(107 downto 0) <= "------------" & ram_b_d2_pl(107 downto 12) ;
                                   ram_b_d3_pl(119 downto 0) <= "------------" & ram_b_d3_pl(119 downto 12) ;
                                   ram_b_d4_pl(131 downto 0) <= "------------" & ram_b_d4_pl(131 downto 12) ;
                                   ram_b_d5_pl(143 downto 0) <= "------------" & ram_b_d5_pl(143 downto 12) ;
                                   ram_b_d6_pl (155 downto 0) <= "------------" & ram_b_d6_pl(155 downto 12) ;
                                   ram_b_d7_pl (167 downto 0) <= "------------" & ram_b_d7_pl(167 downto 12) ;
                                   ram_b_d8_pl (179 downto 0) <= "------------" & ram_b_d8_pl(179 downto 12) ;                                                                    
                            end if;
                    
                            if wr_en_b = '1' then
                                case state_b is
                                       when s0 =>
                                           din_mem_0_b <= ram_b_d1_pl;
                                           addr_cnt_b <= addr_cnt_b + 1;
                                           addra_i_b <= std_logic_vector(to_unsigned(addr_cnt_b,addra_i_b'length));
                                           wr_en_a_b <= '1';
                                           wea_0_b <= (others => '1');
                                           state_b <= s1;
                                       when s1 => 
                                           din_mem_0_b <= ram_b_d2_pl(95 downto 0);
                                           addra_i_b <= std_logic_vector(to_unsigned((addr_cnt_b+47),addra_i_b'length));
                                           state_b <= s2;
                                       when s2 => 
                                           din_mem_0_b <=  ram_b_d3_pl(95 downto 0);
                                            addra_i_b <= std_logic_vector(to_unsigned((addr_cnt_b+95),addra_i_b'length));
                                            state_b <= s3;
                                       when s3 => 
                                            din_mem_0_b <= ram_b_d4_pl(95 downto 0);
                                            addra_i_b <= std_logic_vector(to_unsigned((addr_cnt_b + 143),addra_i_b'length));
                                            state_b <= s4;
                                       when s4 => 
                                            din_mem_0_b <= ram_b_d5_pl(95 downto 0);
                                            addra_i_b <= std_logic_vector(to_unsigned((addr_cnt_b + 191),addra_i_b'length));
                                            state_b <= s5;
                                       when s5 => 
                                            din_mem_0_b <= ram_b_d6_pl(95 downto 0);
                                            addra_i_b <= std_logic_vector(to_unsigned((addr_cnt_b+239),addra_i_b'length));
                                            state_b <= s6;
                                       when s6 => 
                                            din_mem_0_b <= ram_b_d7_pl(95 downto 0);
                                            addra_i_b <= std_logic_vector(to_unsigned((addr_cnt_b+287),addra_i_b'length));
                                            state_b <= s7;
                                       when s7 => 
                                            din_mem_0_b <= ram_b_d8_pl(95 downto 0);
                                            addra_i_b <= std_logic_vector(to_unsigned((addr_cnt_b+335),addra_i_b'length));
                                               
                                            if addr_cnt_b = 48 then
                                                state_b <= finished;
                                            else
                                                state_b <= s0;
                                            end if;
                                       when finished =>
                                                wr_en_a_b <= '0';
                                                wea_0_b <= (others => '0');
                                                wr_en_b <= '0';                           
                                       when others => 
                                                    null;        
                                end case; 
                                              
                             end if;
                             
                            if toggle_i = '0' then
                                wr_en_b_normal <= wr_en_a_b;
                                wea_b_normal <= wea_0_b;
                                addra_i_b_normal <= addra_i_b;
                                din_b_normal <= din_mem_0_b;
                              else
                                wr_en_b_pp <= wr_en_a_b;
                                wea_b_pp <= wea_0_b;
                                din_b_pp <= din_mem_0_b;
                                addra_i_b_pp <= addra_i_b;
                            end if;    
                       end if;
                 end process;                
                    
        end block bram_blue;          
        
        bram_clear:block
            type state_type is(s0,s1,s2,s3,s4,s5,s6,s7, finished);
            signal state_c: state_type := s0;
            signal pl_cnt_c : integer range 0 to 7 := 0;
        begin
            process(clk_80)
                    begin
                        if rising_edge(clk_80) then
                            if data_valid_i = '1' then

                                 ram_c_d1_pl(95 downto 0) <= data_c_bus_i(24) & ram_c_d1_pl(95 downto 12);
                                 ram_c_d2_pl(107 downto 0) <= data_c_bus_i(25) & ram_c_d2_pl(107 downto 12);
                                 ram_c_d3_pl(119 downto 0) <= data_c_bus_i(26) & ram_c_d3_pl(119 downto 12);
                                 ram_c_d4_pl(131 downto 0) <= data_c_bus_i(27) & ram_c_d4_pl(131 downto 12);
                                 ram_c_d5_pl(143 downto 0) <= data_c_bus_i(28) & ram_c_d5_pl(143 downto 12);
                                 ram_c_d6_pl(155 downto 0) <= data_c_bus_i(29) & ram_c_d6_pl(155 downto 12);
                                 ram_c_d7_pl(167 downto 0) <= data_c_bus_i(30) & ram_c_d7_pl(167 downto 12);
                                 ram_c_d8_pl(179 downto 0) <= data_c_bus_i(31) & ram_c_d8_pl(179 downto 12);
                                        pl_cnt_c <= pl_cnt_c + 1;
                                       
                                            
                                            if pl_cnt_c = 7 then
                                                 wr_en_c <= '1'; 
                                                 addr_cnt_c <= 0;
                                                 state_c <= s0;
                                            end if; 
                               else
                                   pl_cnt_c <= 0;
                                   ram_c_d1_pl(95 downto 0) <= "------------" & ram_c_d1_pl(95 downto 12) ;
                                   ram_c_d2_pl(107 downto 0) <= "------------" & ram_c_d2_pl(107 downto 12) ;
                                   ram_c_d3_pl(119 downto 0) <= "------------" & ram_c_d3_pl(119 downto 12) ;
                                   ram_c_d4_pl(131 downto 0) <= "------------" & ram_c_d4_pl(131 downto 12) ;
                                   ram_c_d5_pl(143 downto 0) <= "------------" & ram_c_d5_pl(143 downto 12) ;
                                   ram_c_d6_pl (155 downto 0) <= "------------" & ram_c_d6_pl(155 downto 12) ;
                                   ram_c_d7_pl (167 downto 0) <= "------------" & ram_c_d7_pl(167 downto 12) ;
                                   ram_c_d8_pl (179 downto 0) <= "------------" & ram_c_d8_pl(179 downto 12) ;                                                                    
                            end if;
                            
                            if wr_en_c = '1' then
                                case state_c is
                                       when s0 =>
                                           din_mem_0_c <= ram_c_d1_pl;
                                           addr_cnt_c <= addr_cnt_c + 1;
                                           addra_i_c <= std_logic_vector(to_unsigned(addr_cnt_c,addra_i_c'length));
                                           wr_en_a_c <= '1';
                                           wea_0_c <= (others => '1');
                                           state_c <= s1;
                                       when s1 => 
                                           din_mem_0_c <= ram_c_d2_pl(95 downto 0);
                                           addra_i_c <= std_logic_vector(to_unsigned((addr_cnt_c+47),addra_i_c'length));
                                           state_c <= s2;
                                       when s2 => 
                                           din_mem_0_c <=  ram_c_d3_pl(95 downto 0);
                                            addra_i_c <= std_logic_vector(to_unsigned((addr_cnt_c+95),addra_i_c'length));
                                            state_c <= s3;
                                       when s3 => 
                                            din_mem_0_c <= ram_c_d4_pl(95 downto 0);
                                            addra_i_c <= std_logic_vector(to_unsigned((addr_cnt_c + 143),addra_i_c'length));
                                            state_c <= s4;
                                       when s4 => 
                                            din_mem_0_c <= ram_c_d5_pl(95 downto 0);
                                            addra_i_c <= std_logic_vector(to_unsigned((addr_cnt_c + 191),addra_i_c'length));
                                            state_c <= s5;
                                       when s5 => 
                                            din_mem_0_c <= ram_c_d6_pl(95 downto 0);
                                            addra_i_c <= std_logic_vector(to_unsigned((addr_cnt_c+239),addra_i_c'length));
                                            state_c <= s6;
                                       when s6 => 
                                            din_mem_0_c <= ram_c_d7_pl(95 downto 0);
                                            addra_i_c <= std_logic_vector(to_unsigned((addr_cnt_c+287),addra_i_c'length));
                                            state_c <= s7;
                                       when s7 => 
                                            din_mem_0_c <= ram_c_d8_pl(95 downto 0);
                                            addra_i_c <= std_logic_vector(to_unsigned((addr_cnt_c+335),addra_i_c'length));
                                               
                                            if addr_cnt_c = 48 then
                                                state_c <= finished;
                                            else
                                                state_c <= s0;
                                            end if;
                                       when finished =>
                                                wr_en_a_c <= '0';
                                                wea_0_c <= (others => '0');
                                                wr_en_c <= '0';                           
                                       when others => 
                                                    null;        
                                end case; 
                                              
                             end if;
                             
                             if toggle_i = '0' then
                                wr_en_c_normal <= wr_en_a_c;
                                wea_c_normal <= wea_0_c;
                                
                                addra_i_c_normal <= addra_i_c;
                                din_c_normal <= din_mem_0_c;
                              else
                                wr_en_c_pp <= wr_en_a_c;
                                wea_c_pp <= wea_0_c;
                                
                                addra_i_c_pp <= addra_i_c;
                                din_c_pp <= din_mem_0_c;
                            end if;
                            
                            
                        end if; 
                end process;    
                
        end block bram_clear; 
    
 --based on toggle_i  data is written into pingpong set       
         toggle_signal: process(clk_80)
            begin
                if rst_n = '1' then
                    if rising_edge(clk_80) then
                        if locked = '1' then
                                if tog_cnt = 1200 then
                                    tog_cnt <= 0;
                                    toggle_i <= not toggle_i;
                                    else
                        --                read_flag <= '0';
                                        tog_cnt <= tog_cnt + 1;
                                end if;
                        end if;  
                    end if;
                end if;
                
                    if rising_edge(clk_80) then
                        if locked='1' then
                            if (set_cnt >= 399) then
                                if (flag_cnt <= 1300) then
                                    read_flag <= '1';
                                elsif (flag_cnt > 1300) and (flag_cnt < 2600) then
                                    read_flag <= '0'; 
                                end if;
                            end if;
                        end if;
                    end if;
                    
                    if rising_edge(clk_80) then
                        if locked = '1' then
                            if set_cnt = 400 then
                                    set_cnt <= set_cnt;
                                    flag_cnt <= flag_cnt + 1;
                                   if flag_cnt = 2600 then
                                      flag_cnt <= 0;
                                   end if;
                             else
                                set_cnt <= set_cnt + 1;
                            end if;
                        end if;
                    end if;
            end process toggle_signal;

            
       read_block: block
       type state_type is(idle,start, read_en,read_addr, read_data,set_valid, transmit);
       signal state, next_state: state_type := idle;
       begin
      seq_p: process(clk_300)
           begin
               if rising_edge(clk_300) then   
                    state <= next_state;
                    if rst_n = '0' then
                        state <= idle;
                        elsif (set_cnt = 400) then
                            if next_state = set_valid then
                                    t_data <= data_out_c_normal (23 downto 12) & data_out_b_normal (23 downto 12) & data_out_g_normal (23 downto 12) & data_out_normal (23 downto 12) &
                                               data_out_c_normal (11 downto 0) & data_out_b_normal (11 downto 0) & data_out_g_normal (11 downto 0) & data_out_normal (11 downto 0);
											   
                            elsif next_state = transmit then                   
                                    read_cnt <= read_cnt + 1;
                                
                            end if;
                    end if;
              end if;
       end process seq_p;
       
       comb_p: process(state,next_state,set_cnt,m00_tready,t_data)
       begin
            next_state <= state;
       --     t_data <=  (others => '0');
            
            case state is 
                when idle =>
                    if set_cnt = 400 then 
                        next_state <= start;
                        else
                        next_state <= idle;
                    end if;  
                         
                when start => 
                    next_state <= read_en;
                    t_valid <= '0';
                    
                when read_en =>               
                      rd_en_normal <= '1';
                      rd_en_g_normal <= '1'; 
                      rd_en_b_normal <= '1';
                      rd_en_c_normal <= '1';  
                      
                      t_valid <= '0';
                      next_state <= read_addr; 
                                           
                when read_addr =>
                    addrb_normal <=  std_logic_vector(to_unsigned((read_cnt),addrb_normal'length));
                    addrb_g_normal <=  std_logic_vector(to_unsigned((read_cnt),addrb_g_normal'length));
                    addrb_b_normal <=  std_logic_vector(to_unsigned((read_cnt),addrb_b_normal'length));
                    addrb_c_normal <=  std_logic_vector(to_unsigned((read_cnt),addrb_c_normal'length));
                    
                    t_valid <= '0';
                    next_state <= read_data;
                    
                when read_data =>
                    rd_en_normal <= '0';
                    rd_en_g_normal <= '0'; 
                    rd_en_b_normal <= '0';
                    rd_en_c_normal <= '0';
                
                    next_state <= set_valid;

                when set_valid =>         
                    t_valid <= '1';
                    if m00_tready = '1' then
                        next_state <= transmit;
                        else
                        next_state <= set_valid;
                    end if;
                when transmit =>
                   t_valid <= '0';
                   next_state <= read_en;
                when others => 
                
            end case;
       end process comb_p;
         
       end block read_block;
            
    end Behavioral;

