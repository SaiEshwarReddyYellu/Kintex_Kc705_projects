--top level file

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_misc.ALL;


library std;
use std.textio.all;
use IEEE.std_logic_textio.all;      --writting/reading std_logic


entity task_final is
--  Port ( );
   port(
            clk_final : in std_logic;
            rst_final : in std_logic;
            sim_done_f : out std_logic;
            status_chk_f : out boolean);
end task_final;


architecture Behavioral of task_final is

-- Task interface signals
    signal clk_100_top_i : std_logic := '0';
    signal clk_400_top_i : std_logic := '0';
    signal locked : std_logic;
  
--test pattern generation signals
    signal rst_ext_out : std_logic;
    signal valid_sig_reg : std_logic;
    signal toggle_i : std_logic := '0';
    signal fifo_reg_in : std_logic_vector(11 downto 0) := (others => '0');
    signal infile_a_done :std_logic;
    signal infile_b_done : std_logic;
    
    
 -- fifo generator signals
    signal rd_en_reg : std_logic;
    signal demux_in_reg : std_logic_vector(47 downto 0);
    signal full_i : std_logic;
    signal empty_i : std_logic;
    signal wr_rst_busy_i : std_logic;
    signal rd_rst_busy_i : std_logic;
    signal almost_empty_i : std_logic;
    signal rd_data_count_i : std_logic_vector(3 downto 0);
    signal total_data_cnt : integer := 0;
    
  -- de-mux signals
    signal demux_enable :std_logic;
    signal mem_a_reg : std_logic_vector(47 downto 0) := (others => '0');
    signal mem_b_reg : std_logic_vector(47 downto 0) := (others => '0'); 
    
    
    -- not gate signals
    signal ctrl_reg : std_logic := '0';
    
   --address register
    signal addreg : std_logic_vector(15 downto 0) := (others => '0');
    subtype addreg_type_a is std_logic_vector;
    subtype addreg_type_b is std_logic_vector;
    subtype addreg_type_c is std_logic_vector;
    subtype addreg_type_d is std_logic_vector;
    
-- Block memory generator 0 signals
    signal wea_0 : std_logic_vector(0 downto 0) := (others => '0');
    signal addr_a_reg_0 : addreg_type_a(9 downto 0);   
    signal addr_b_reg_0 : addreg_type_b(9 downto 0);   
    signal blc_mem_reg_0 : std_logic_vector(47 downto 0) := (others => '0');    --bram_output_0
    signal mem_0_ena_reg : std_logic ;
    signal mem_0_enb_reg : std_logic;
    signal bram_0_data_cnt : integer := 0;
    
-- Block memory generator 1 signals
    signal wea_1 : std_logic_vector(0 downto 0) := (others => '0');
    signal addr_a_reg_1 : addreg_type_c(9 downto 0);             
    signal addr_b_reg_1 : addreg_type_d(9 downto 0);    
    signal blc_mem_reg_1 : std_logic_vector(47 downto 0) := (others => '0');    --bram_output_1
    signal mem_1_ena_reg : std_logic ;
    signal mem_1_enb_reg : std_logic;
    
 
--mux signals
    signal mux_enable : std_logic;
    signal mux_output : std_logic_vector(47 downto 0);  -- := (others => '0');
    
    
    
--files and its signals
    file mem_file_A : text;
    file mem_file_B : text;
    file expec_output : text;
    file expec_output_2 : text;
    signal linenumber : integer range 1 to 1025 := 1;
    signal linenumber_2 : integer range 1 to 1025 := 1;
    signal lin_no : integer := 0;
    
    signal expec_fil_a_done : std_logic;
    signal expec_fil_b_done : std_logic;
    
    --read mode signals
    signal TPG_file : integer := 0;
    signal mux_file : integer := 0;
    signal status_i :boolean ; 
    signal error : integer := 1;
    signal verify : std_logic := '0';
    
      component clk_wiz_0 
        port (
          -- Clock out ports
          clk_out1 : out std_logic;
          clk_out2 : out std_logic;
          locked : out std_logic;
         -- Status and control signals
         reset : in std_logic;
         -- Clock in ports
          clk_in1 : in std_logic);
      end component clk_wiz_0;
    
      component TP_gen_final is
        port(
            clk_400 : in std_logic;
            rst : in std_logic;
            rst_ext_out : out std_logic;
            valid : out std_logic;
            toggle : out std_logic;
            file_a_done : out std_logic;
            file_b_done : out std_logic;
            data_fifo : out std_logic_vector(11 downto 0));
      end component TP_gen_final;
      
      component fifo_generator_0 is
         PORT (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            almost_empty : OUT STD_LOGIC;
            rd_data_count : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC
          );
        end component fifo_generator_0;
        
        component demux is
        Port ( 
            clk : in std_logic;
           enable : in std_logic;
           demux_in : in STD_LOGIC_VECTOR (47 downto 0);
           sel : in STD_LOGIC;
           mem_A : out STD_LOGIC_VECTOR (47 downto 0);
           mem_B : out STD_LOGIC_VECTOR (47 downto 0));

        end component demux;
        
        component not_gate is
        Port ( 
               clk_100 : in std_logic; 
               a : in STD_LOGIC;
               b : out std_logic);
        
        end component not_gate;
    
        
        component blk_mem_gen_0 is
            PORT (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
                addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
                dina : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
                clkb : IN STD_LOGIC;
                enb : IN STD_LOGIC;
                addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
                doutb : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
              );
        end component blk_mem_gen_0;
        
        component blk_mem_gen_1 is
            PORT (
                clka : IN STD_LOGIC;
                ena : IN STD_LOGIC;
                wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
                addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
                dina : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
                clkb : IN STD_LOGIC;
                enb : IN STD_LOGIC;
                addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
                doutb : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
              );
        end component blk_mem_gen_1;
        
        component mux is
                Port ( 
           clk : in std_logic;      --100MHZ
           enable : in std_logic;
           mem_a,mem_b : in STD_LOGIC_VECTOR (47 downto 0);
           sel : in STD_LOGIC;
           mux_out : out STD_LOGIC_VECTOR (47 downto 0));
        
        end component mux;
    
begin
    
    status_chk_f <= status_i;
    
    -- clock instantiation
    clk_ins : clk_wiz_0
    port map (
                clk_in1 => clk_final,
                reset => rst_final,
                locked => locked,
                clk_out1 => clk_400_top_i,
                clk_out2 => clk_100_top_i);
                
    -- TP_gen istantiation
    TP_gen_ins : TP_gen_final
    port map (
                clk_400 => clk_400_top_i,
                rst => rst_final,
                rst_ext_out => rst_ext_out,
                valid => valid_sig_reg,
                toggle => toggle_i,
                file_a_done => infile_a_done,
                file_b_done => infile_b_done,
                data_fifo => fifo_reg_in
                );
                
    -- fifo_generator_0 instantiation
 fifo_generator_0_ins : fifo_generator_0
        port map (
                    rst => rst_final,
                    wr_clk => clk_400_top_i,
                    rd_clk => clk_100_top_i,
                    din => fifo_reg_in,
                    wr_en => valid_sig_reg,
                    rd_en => rd_en_reg,
                    dout => demux_in_reg,
                    full => full_i,
                    empty => empty_i,
                    almost_empty => almost_empty_i,
                    rd_data_count => rd_data_count_i,
                    wr_rst_busy => wr_rst_busy_i,
                    rd_rst_busy => rd_rst_busy_i); 
                    
     
     fifo_ctrl_logic: process(clk_100_top_i,rst_final)
        begin

            if rising_edge(clk_100_top_i) then
                if rst_final = '0' then
                    if almost_empty_i = '1' then
                        rd_en_reg <= '0';
                        else
                        rd_en_reg <= '1';
                        total_data_cnt <= total_data_cnt + 1;               --1024 data verification
                    end if;
                
                end if;    
            end if;
            end process fifo_ctrl_logic;
            
        -- Demux instantiation
        demux_ins : demux
            port map (
                    clk => clk_100_top_i,
                    enable => demux_enable,
                    demux_in => demux_in_reg,
                    sel => toggle_i,
                    mem_A => mem_a_reg,
                    mem_B => mem_b_reg
                    ); 
                    
       demux_logic: process (clk_100_top_i,rd_en_reg)
       begin
       if rising_edge(clk_100_top_i) then
           if rd_en_reg = '1' then
                    demux_enable <= '1';
                    else
                    demux_enable <= '0';
                end if;
            end if;
       end process demux_logic;
       
       
        -- not-gate instation
        not_gate_ins : not_gate
            port map (
                        clk_100 => clk_100_top_i,
                        a => toggle_i,
                        b => ctrl_reg);
        
              
                        
          --block memory generator 0 instance 
     blk_mem_gen_0_ins : blk_mem_gen_0
        port map (
                 clka => clk_100_top_i,
                 ena => mem_0_ena_reg,
                 wea => wea_0,
                 addra => addr_a_reg_0,
                 dina =>  mem_a_reg,
                 clkb => clk_100_top_i,
                 enb => mem_0_enb_reg,
                 addrb => addr_b_reg_0,
                 doutb => blc_mem_reg_0
                    ); 
                    
                    
           --block memory generator 1 instance  
        blk_mem_gen_1_ins: blk_mem_gen_1
            port map(
                clka => clk_100_top_i,
                ena => mem_1_ena_reg,
                wea =>  wea_1,
                addra => addr_a_reg_1,
                dina => mem_b_reg,
                clkb => clk_100_top_i,
                enb =>  mem_1_enb_reg,
                addrb => addr_b_reg_1,
                doutb => blc_mem_reg_1
                        );
         
        address_logic : process(clk_100_top_i)
        begin
        if rising_edge(clk_100_top_i) then
           if toggle_i = '0' then
                if demux_enable = '1' then
                    bram_0_data_cnt <= bram_0_data_cnt + 1;
                    wea_0 <=  "1";
                    wea_1 <= "0";
                    addr_a_reg_0 <= (others => '0');
                    addr_b_reg_1 <= (others => '0');
                    mem_0_ena_reg <= '1';
                    mem_1_enb_reg <= '1';
                    mem_0_enb_reg <= '0';
                    mem_1_ena_reg <= '0';

                             if wea_0 = 1 then       
                                addr_a_reg_0 <= addr_a_reg_0 + '1';                                     
                                    if  addr_a_reg_0 = x"3ff" then            --address for mem-0 write at port A
                                          addr_a_reg_0 <= (others => '0');  
                                    end if;
                                    
                                 addr_b_reg_1 <= addr_b_reg_1 + 1;            --address for mem-1 read at port B
                                    if addr_b_reg_1 = x"3ff" then 
                                        addr_b_reg_1 <= (others => '0');
                                    end if; 
                                    
                              end if;
                else

                    mem_0_ena_reg <= '0';
                    mem_1_enb_reg <= '0';
                end if;
                
                else
                    wea_0 <=  "0";
                    if demux_enable = '1' then
                    wea_1 <= "1";
                    addr_a_reg_1 <= (others => '0');
                    addr_b_reg_0 <= (others => '0');
                    mem_0_ena_reg <= '0';
                    mem_1_enb_reg <= '0';
                    mem_0_enb_reg <= '1';
                    mem_1_ena_reg <= '1';
                            
                            if wea_1 = 1 then 
                                addr_a_reg_1 <= addr_a_reg_1 + '1';         --address for mem-1 write at port A
                                    if addr_a_reg_1 = x"3ff" then
                                        addr_a_reg_1 <= (others => '0');
                                    end if;
                                    
                                addr_b_reg_0 <= addr_b_reg_0 + 1;           --address for mem-0 read at port B
                                        if addr_b_reg_0 = x"3ff" then
                                            addr_b_reg_0 <= (others => '0');
                                        end if; 
                             end if;

                            
                    else
                    mem_0_enb_reg <= '0';
                    mem_1_ena_reg <= '0';
                    end if;         
           end if;
        end if;
        
        end process address_logic;
           
           
            --mux instance                
     mux_ins: mux
        port map(
                clk => clk_100_top_i,
                enable => mux_enable,
                sel => ctrl_reg,
                mem_a => blc_mem_reg_0,
                mem_b => blc_mem_reg_1,
                mux_out => mux_output
                );     
      mux_logic : process(clk_100_top_i) 
      begin
        if rising_edge(clk_100_top_i) then
            if mem_0_enb_reg = '1' or mem_1_enb_reg = '1' then
                mux_enable <= '1';
            else
                mux_enable <= '0';
            end if;
        end if;
      end process mux_logic;
      
   final_output: process(clk_100_top_i)
                 variable fstatus : file_open_status;
                 variable value_A : line;
                 variable value_B : line;
                 
                   begin
                    if rising_edge(clk_100_top_i) then
                        if ctrl_reg = '0' then
                            if mux_enable = '1' then
                                  if linenumber = 1 then
                                        file_open(fstatus, expec_output, "C:/Users/expec_output.txt", write_mode);
                                        expec_fil_a_done <= '0';
                                        linenumber <= linenumber + 1;
                                        elsif linenumber = 1024 then
                                            hwrite(value_A,mux_output);
                                            writeline(expec_output, value_A);                                        
                                            linenumber <= linenumber + 1;                                            
                                        else
                                            hwrite(value_A,mux_output);
                                            writeline(expec_output, value_A);
                                            linenumber <= linenumber + 1;
                                    end if;
                             else     
                               if linenumber = 1025 then                           
                                   hwrite(value_A,mux_output);                     
                                   writeline(expec_output, value_A);               
                                   write(value_A,string'("end of file A"));          
                                   writeline(expec_output, value_A);               
                                   linenumber <= 1;                                
                                   file_close(expec_output);
                                   expec_fil_a_done <= '1';                       
                                end if;                                    
                               end if;  
                               
                             else
                             
                             if mux_enable = '1' then
                                  if linenumber_2 = 1 then
                                        file_open(fstatus, expec_output_2, "C:/Users/expec_output_2.txt", write_mode);
                                        expec_fil_b_done <= '0';
                                        linenumber_2 <= linenumber_2 + 1;
                                        elsif linenumber_2 = 1024 then
                                            hwrite(value_B,mux_output);
                                            writeline(expec_output_2, value_B);                                        
                                            linenumber_2 <= linenumber_2 + 1;                                            
                                        else
                                            hwrite(value_B,mux_output);
                                            writeline(expec_output_2, value_B);
                                            linenumber_2 <= linenumber_2 + 1;
                                    end if;
                             else     
                               if linenumber_2 = 1025 then                           
                                   hwrite(value_B,mux_output);                     
                                   writeline(expec_output_2, value_B);               
                                   write(value_B,string'("end of file B"));          
                                   writeline(expec_output_2, value_B);               
                                   linenumber_2 <= 1;                                
                                   file_close(expec_output_2);
                                   expec_fil_b_done <= '1';                       
                                end if;                                    
                               end if;   
                               
                               
                              
                            end if;
                        end if;
                   end process final_output;
          
       process(clk_400_top_i)
       begin
        if rising_edge(clk_400_top_i) then
            if infile_a_done = '1' and expec_fil_a_done = '1' then
                verify <= '1';
                else
                verify <= '0';
            end if;
        end if;
       end process;            
                   
      file_comparision: process
      variable fstatus : file_open_status;
      variable temp : std_logic_vector(47 downto 0):= (others => '0');
      variable temp1 : std_logic_vector(11 downto 0):= (others => '0');         --generated output file-a
      variable temp2 : std_logic_vector(47 downto 0):= (others => '0');         --expected output file-a
      variable loop_run : integer range 1 to 4 := 1;
      variable inline_1 : line;
      variable inline_2 : line;
      
      begin

            
            wait until verify = '1';-- and verify'event;
        
             file_open(fstatus, mem_file_A, "C:/Users/mem_file_A.txt", read_mode);
             file_open(fstatus, expec_output, "C:/Users/expec_output.txt", read_mode);
                       

                     while (not endfile(mem_file_A)) loop
                        if loop_run <= 4 then
                            readline(mem_file_A, inline_1);
                            hread(inline_1,temp1);
                            temp := temp(35 downto 0) & temp1;
                        else
                            loop_run := 1;
                            end if;
                    end loop;
                    
                    while not endfile(expec_output) loop
                            readline(expec_output,inline_2);   
                            hread(inline_2,temp2);
                     end loop;
                    
                    if temp /= temp2 then
                        report(" test failed");
                        status_i <= false;
                        error <= error + 1;
                        else
                        status_i <= true;
                        report("test passed");
                    end if;
                    
                    
                    if endfile(mem_file_A) then
                        report("test passed successfully");
                    end if;
                    
                 
                    
            file_close(mem_file_A);
            file_close(expec_output);
--           wait;
      end process file_comparision;
       
end Behavioral;
