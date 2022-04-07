----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.01.2022 10:17:37
-- Design Name: 
-- Module Name: demux - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity demux is
    Port ( 
           clk : in std_logic;
           enable : in std_logic;
           demux_in : in STD_LOGIC_VECTOR (47 downto 0);
           sel : in STD_LOGIC;
           mem_A : out STD_LOGIC_VECTOR (47 downto 0);
           mem_B : out STD_LOGIC_VECTOR (47 downto 0));
end demux;

architecture Behavioral of demux is

signal reg_a : std_logic_vector (47 downto 0);
signal reg_b : std_logic_vector(47 downto 0);

begin

    mem_A <= reg_a;
    mem_B <= reg_b;

process (clk,enable)
begin
    if rising_edge(clk) then
        if enable = '1' then
            if sel = '0' then
                reg_a <= demux_in;
                else
                reg_b <= demux_in;
            end if;
        end if;
    end if;
end process;

end Behavioral;



------------------------

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.01.2022 14:35:01
-- Design Name: 
-- Module Name: not_gate - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity not_gate is                                        
    Port ( 
           clk_100 : in std_logic; 
           a : in STD_LOGIC;
           b : out std_logic);
end not_gate;

architecture Behavioral of not_gate is
begin
process(clk_100)
begin
    if rising_edge(clk_100) then
            b <= not a;
    end if;
end process;
end Behavioral;



------------------------

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.01.2022 10:51:25
-- Design Name: 
-- Module Name: mux - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux is
    Port ( 
           clk : in std_logic;      --100MHZ
           enable : in std_logic;
           mem_a,mem_b : in STD_LOGIC_VECTOR (47 downto 0);
           sel : in STD_LOGIC;
           mux_out : out STD_LOGIC_VECTOR (47 downto 0));
end mux;

architecture Behavioral of mux is

signal reg_out : std_logic_vector(47 downto 0); -- := (others => '0');

begin

    mux_out <= reg_out;

process(clk)
begin
    if rising_edge(clk) then
        if enable = '1' then
            if sel = '0' then             
                reg_out <= mem_a;
         else
                reg_out <= mem_b;
            end if; 
        end if;
    end if;  
end process;

end Behavioral;
