
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.03.2022 17:27:09
-- Design Name: 
-- Module Name: sensor_comp - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

package my_port_ranges is
    constant color_ln : integer := 4;
    constant lvds_lines : integer := 8;
    constant pixel_per_color_ln : integer := 3 * 1024;
    type data_ports is array (integer range <>) of std_logic_vector(11 downto 0);
    signal data_red : data_ports(7 downto 0);
    signal data_green : data_ports(15 downto 8);
    signal data_blue : data_ports(23 downto 16);
    signal data_clear : data_ports(31 downto 24);

end package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_misc.ALL;
use work.my_port_ranges.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sensor_comp is
--  Port ( );
      Port ( pix_clk_80 : in STD_LOGIC;          --80MHZ
           rst : in STD_LOGIC;
           clk_locked : in std_logic;
           data_r : out data_ports(((color_ln * lvds_lines)- 25) downto 0);
           data_g : out data_ports(((color_ln * lvds_lines)- 17) downto 8);
           data_b : out data_ports(((color_ln * lvds_lines)- 9) downto 16);
           data_c : out data_ports(((color_ln * lvds_lines)- 1) downto 24);
           data_valid : out STD_LOGIC);
end sensor_comp;

architecture Behavioral of sensor_comp is
signal data_r_bus : data_ports(((color_ln * lvds_lines)- 25) downto 0) := (others => x"000");
signal data_g_bus : data_ports(((color_ln * lvds_lines)- 17) downto 8) := (others => x"000");
signal data_b_bus : data_ports(((color_ln * lvds_lines)- 9) downto 16) := (others => x"000");
signal data_c_bus : data_ports(((color_ln * lvds_lines)- 1) downto 24) := (others => x"000");
signal data_valid_i : std_logic := '0';

signal TPgen_reg_r : std_logic_vector(11 downto 0):= x"000";
signal TPgen_reg_g : std_logic_vector(11 downto 0):= x"000";
signal TPgen_reg_b : std_logic_vector(11 downto 0):= x"000";
signal TPgen_reg_c : std_logic_vector(11 downto 0):= x"000";

signal data_cnt : integer range 0 to 1200 := 0;
signal data_cnt_per_line : integer range 0 to (pixel_per_color_ln/lvds_lines) := 0;

type total_pix_cnt is array (integer range <>) of integer;
signal pix_cnt_per_color : total_pix_cnt(0 to 7);

begin

--outputs
    data_r <= data_r_bus; 
    data_g <= data_g_bus;
    data_b <= data_b_bus;
    data_c <= data_c_bus;
    data_valid <= data_valid_i;
    
    
    
  data_r_bus <=  data_red;
  data_red <= (TPgen_reg_r+ x"a80",TPgen_reg_r+ x"900",TPgen_reg_r+ x"780",TPgen_reg_r+ x"600",TPgen_reg_r+ x"480",TPgen_reg_r+ x"300",TPgen_reg_r+x"180",TPgen_reg_r);
  data_g_bus <= data_green;
  data_green <= (TPgen_reg_g + x"a80",TPgen_reg_g + x"900",TPgen_reg_g+ x"780",TPgen_reg_g+ x"600",TPgen_reg_g+ x"480",TPgen_reg_g+ x"300",TPgen_reg_g+ x"180",TPgen_reg_g);
  data_b_bus <= data_blue;
  data_blue <= (TPgen_reg_b + x"a80",TPgen_reg_b + x"900",TPgen_reg_b+ x"780",TPgen_reg_b+ x"600",TPgen_reg_b+ x"480",TPgen_reg_b+ x"300",TPgen_reg_b+ x"180",TPgen_reg_b);  
  data_c_bus <= data_clear;
  data_clear <= (TPgen_reg_c+ x"a80",TPgen_reg_c + x"900",TPgen_reg_c+ x"780",TPgen_reg_c+ x"600",TPgen_reg_c+ x"480",TPgen_reg_c+ x"300",TPgen_reg_c+ x"180",TPgen_reg_c);
  
  
  --counters
  pix_cnt_per_color <= (data_cnt_per_line,(pixel_per_color_ln/lvds_lines)+data_cnt_per_line,2*(pixel_per_color_ln/lvds_lines)+data_cnt_per_line,
                        3*(pixel_per_color_ln/lvds_lines)+data_cnt_per_line,4*(pixel_per_color_ln/lvds_lines)+data_cnt_per_line,5*(pixel_per_color_ln/lvds_lines)+data_cnt_per_line,
                        6*(pixel_per_color_ln/lvds_lines)+data_cnt_per_line,7*(pixel_per_color_ln/lvds_lines)+data_cnt_per_line);
                  
  process(pix_clk_80)
    begin
        if rising_edge(pix_clk_80)then
            if clk_locked = '1' then
                if rst = '1' then
                    if data_cnt < 384 then
                        TPgen_reg_r <= TPgen_reg_r + "1";
                        TPgen_reg_g <= TPgen_reg_g + "1"; 
                        TPgen_reg_b <= TPgen_reg_b + "1";
                        TPgen_reg_c <= TPgen_reg_c + "1";
                        data_valid_i <= '1';
                        data_cnt <= data_cnt + 1;
                        data_cnt_per_line <= data_cnt_per_line + 1;
                     else
                        data_valid_i <= '0';
                        data_cnt_per_line <= 0;
                        data_cnt <= data_cnt + 1;
                            if data_cnt = 1200 then          
                                data_cnt <= 0;
                            end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
