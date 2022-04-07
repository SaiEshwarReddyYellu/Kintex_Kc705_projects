----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.01.2022 10:34:08
-- Design Name: 
-- Module Name: TP_gen - Behavioral
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
use std.textio.all;
use IEEE.std_logic_textio.all;      --writting/reading std_logic

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TP_gen_final is
    generic(
            constant line_length : integer := 4096;
            constant line_gap : integer := 50);
    
--  Port ( );
    port(
    clk_400 : in std_logic;
    rst : in std_logic;
    rst_ext_out : out std_logic;
    valid : out std_logic;
    toggle : out std_logic;
    data_fifo : out std_logic_vector(11 downto 0));
end TP_gen_final;

architecture Behavioral of TP_gen_final is

constant stop : integer := line_length + line_gap;

signal ran_no : integer := 0;
signal int : std_logic_vector(1 downto 0) := "01";  
signal data_fifo_reg : std_logic_vector(11 downto 0) := x"123"; 
signal cnt : integer range 0 to (line_length-1) := 0;
signal valid_sig : std_logic := '0';
signal write_en_reg : std_logic := '0';
signal write_en_reg_delay : std_logic := '0';   
signal toggle_bit : std_logic := '0';
signal tog_cnt : integer range 0 to stop := 0;

--external reset
    signal rst_ext : std_logic ;    -- := '1';
    signal rst_ext_cnt : integer range 0 to 50 := 0;


file mem_file_A : text;
file mem_file_B : text;

----------------------------------------------------
--RANDOM NUMBER RANGING = 0 TO 2 
      function num ( x :  std_logic_vector(1 downto 0)) return std_logic_vector is
        begin
            return (x(0) and (x(1) xor x(0))) & (x(1) xnor x(0)) ;
      end function num ;

----------------------------
--LENEAR FEEDBACK SHIFT REGISTER
      function lfsr12 ( y : std_logic_vector(11 downto 0)) return std_logic_vector is
      begin
            return y(10 downto 0) & ((y(2) xor y(3)) xnor y(5) xnor y(7) xnor (y(9) xnor y(11)));
      end function lfsr12;
      

begin

  
  data_fifo <= data_fifo_reg;
  valid <= valid_sig;
  toggle <= toggle_bit;
  rst_ext_out <= rst_ext;
  
   -------------external reset
   ext_reset: process(clk_400)
                begin
                    if rising_edge(clk_400) then
                        if rst = '1' then
                            rst_ext <= '1';
                        else
                            if  rst_ext_cnt = 50 then
                                rst_ext_cnt <= rst_ext_cnt;
                                rst_ext <= '0';
                            else
                                rst_ext <= '1';
                                rst_ext_cnt <= rst_ext_cnt + 1;
                            end if;
                        end if;
                    end if;
                end process ext_reset;
  
  
    num_conv: process(clk_400,rst_ext)
            begin
            if rising_edge(clk_400) then
                 if rst_ext = '1' then
                      null;
                      else
                      int <= num(int);
                 end if;
            end if;
            
            end process num_conv;
            
      random_number:  process (clk_400,rst_ext)
                    begin
                      if rising_edge(clk_400) then
                        if rst_ext = '1' then
                            null;
                            else
                            ran_no <= to_integer(unsigned(int));     
                        end if;
                      end if;                        
                    end process random_number;
    
           random_data: process(clk_400,rst_ext)
                begin
                    if rising_edge(clk_400) then
                        if rst_ext = '1' then
                            cnt <= 0;
                            tog_cnt <= 0;
                            data_fifo_reg <= x"123"; --(others => '0');
                          else
                            if ran_no <= 0 then
                                data_fifo_reg <= data_fifo_reg;
                                valid_sig <= '0';
                                cnt <= cnt;
                                elsif ran_no <= 1 then
                                    tog_cnt <= tog_cnt + 1;
                                    valid_sig <= '1';
                                    cnt <= cnt + 1;
                                    data_fifo_reg <= lfsr12(data_fifo_reg);
                                elsif ran_no <= 2 then
                                    tog_cnt <= tog_cnt + 1;
                                    valid_sig <= '1';
                                    cnt <= cnt + 1;
                                    data_fifo_reg <= lfsr12(data_fifo_reg);
                            end if;
                        end if;
                    end if;
                       
                       if rising_edge(clk_400) then
                            if rst_ext = '0' then
                                if  cnt > 4095 then         
                                    write_en_reg <= '0';
                                    valid_sig <= '0';
                                        if(tog_cnt = 0) then
                                             cnt <= 0;
                                           write_en_reg <= '1'; 
                                        end if;
                                    else
                                    write_en_reg <= '1';
                                end if;

                            end if;
                       end if;
                      
                      if rising_edge(clk_400) then          --for files
                           if tog_cnt = stop then
                                tog_cnt <= 0;
                                toggle_bit <= not toggle_bit;
                           end if;
                      end if;
            end process random_data;
    
            
    files :  process(clk_400,rst_ext)
                variable fstatus : file_open_status;
                variable value_A : line;
                variable value_B : line;
                    begin
                                if rising_edge(clk_400) then
                                    write_en_reg_delay <= write_en_reg;
                                     if rst_ext = '0' then
                                    if toggle_bit = '0' then                -- to file A
                                        if write_en_reg = '1' and write_en_reg_delay = '0'then 
                                            file_open(fstatus, mem_file_A, "C:/Users/mem_file_A.txt", write_mode);
                                            if valid_sig = '1' then 
                                                hwrite(value_A,data_fifo_reg);        
                                                writeline(mem_file_A,value_A);          --writting first 12-bit data 
                                            end if;
                                        elsif ( write_en_reg = '0' and write_en_reg_delay = '1') then 
                                                    write(value_A, string'("end of file A"));
                                                    writeline(mem_file_A,value_A);  
                                                    file_close(mem_file_A);
                                        elsif   ( write_en_reg = '1' and write_en_reg_delay = '1') then
                                                 if valid_sig = '1' then
                                                       hwrite(value_A,data_fifo_reg);
                                                       writeline(mem_file_A,value_A);          --writting first 12-bit data 
                                                 end if;                                         
                                        end if;
                                      else        -- to file B
                                          if write_en_reg = '1' and write_en_reg_delay = '0' then 
                                            file_open(fstatus, mem_file_B, "C:/Users/mem_file_B.txt", write_mode);
                                                if valid_sig = '1' then  
                                                      hwrite(value_B,data_fifo_reg);        
                                                      writeline(mem_file_B,value_B);          --writting first data
                                                end if;
                                            elsif  (write_en_reg = '0' and write_en_reg_delay = '1') then  
                                                        write(value_B, string'("end of file B"));
                                                        writeline(mem_file_B,value_B); 
                                                        file_close(mem_file_B);
                                            elsif   ( write_en_reg = '1' and write_en_reg_delay = '1') then
                                                        if valid_sig = '1' then
                                                            hwrite(value_B,data_fifo_reg);           
                                                            writeline(mem_file_B,value_B);          --writting first data
                                                        end if;
                                          end if;
                                    end if;
                                        end if;
                                end if;  
                    end process  files;
end Behavioral;
