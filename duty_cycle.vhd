library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity buton_controller is
	port (
    clk                       : in std_logic   ;
    reset_n_i                 : in std_logic   ;
    
    buton1                    : in std_logic   ;    
    buton2                    : in std_logic   ;  

    duty_cycle_o                : out std_logic_vector(31 downto 0) );
end buton_controller;

architecture rtl of buton_controller is

component clk_wiz_0
  port (
    clk_out1                   : out std_logic;
    locked                     : out std_logic;
    clk_in1                    : in  std_logic);
end component clk_wiz_0;


component Debounce_Switch
port(
     i_clk   : in     std_logic;
     i_switch : in     std_logic;
     o_switch : out    std_logic
 );
 
 end component Debounce_Switch;
 

signal w_buton1 : std_logic;
signal w_buton2 : std_logic;

signal signal_w_buton1_d0_r      : std_logic                    ;
signal signal_w_buton2_d0_r       : std_logic                    ;

signal clk_out1 : std_logic;
signal locked   : std_logic;

signal duty_cycle_r : std_logic_vector(31 downto 0) ;

begin

clock_inst: clk_wiz_0
   port map (   
   clk_out1 => clk_out1,              
   locked => locked,
   clk_in1 => clk
 );

debounce_s_0: Debounce_Switch
    port map(
     i_clk    => clk_out1,
     i_switch => buton1,
     o_switch => w_buton1
 );
 
 debounce_s_1: Debounce_Switch
    port map(
     i_clk    => clk_out1,
     i_switch => buton2,
     o_switch => w_buton2
 );
  
  delay : process(clk_out1, reset_n_i) is 
    begin 
    if (reset_n_i = '0') then
      signal_w_buton1_d0_r <= '0';
      signal_w_buton2_d0_r <= '0';
       
    elsif rising_edge(clk_out1) then
      signal_w_buton1_d0_r <= w_buton1;
      signal_w_buton2_d0_r <= w_buton2;
    end if;
  end process;
  
 
  p_register: process(clk_out1, reset_n_i) is
    begin
    if (reset_n_i = '0')then
      duty_cycle_r <= x"000c350";
      
    elsif rising_edge(clk_out1) then
         
        
        if w_buton1 = '1' and signal_w_buton1_d0_r = '0' then 
            
            if duty_cycle_r >= x"186a0" then
              duty_cycle_r <= x"186a0";
              
            else
              duty_cycle_r <= duty_cycle_r +x"000003e8";
              
            end if;
            
        elsif signal_w_buton2_d0_r = '0' and w_buton2 = '1' then 
            
            if duty_cycle_r <= x"00000000" then
              duty_cycle_r <= x"00000000";
            
            else
              duty_cycle_r <= duty_cycle_r -x"000003e8";
            end if;
        
        end if; 
    
    end if;
  end process;

duty_cycle_o <= duty_cycle_r;

end rtl;