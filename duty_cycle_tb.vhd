library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity duty_cycle_tb is
--  Port ( );
end duty_cycle_tb;

architecture Behavioral of duty_cycle_tb is

component buton_controller is
	port (
    clk                       : in std_logic   ;
    reset_n_i                 : in std_logic   ;
    
    buton1                    : in std_logic   ;    
    buton2                    : in std_logic   ;  

    duty_cycle_o                : out std_logic_vector(31 downto 0) );
end component;


constant clk_period : time := 10 ns;

signal clock         : std_logic ;
signal reset         : std_logic := '0';
signal buton1        : std_logic := '0';
signal buton2        : std_logic := '0';
signal duty_cycle    : std_logic_vector (31 downto 0);

begin 

reset_process :process
   begin
      wait for clk_period/2;  
      reset <= '1'; 
   end process;


clk_process :process
   begin
      clock <= '0';
      wait for clk_period/2;  
      clock <= '1';
      wait for clk_period/2;  
   end process;
   
btn_process :process
   begin
      wait for 10 ms ;  
      buton1 <= '1';
      wait for 10 ms ;  
   end process;

btn_cnt: buton_controller
port map(
    clk => clock,
    reset_n_i => reset,
    
    buton1 => buton1,
    buton2 => buton2,

    duty_cycle_o => duty_cycle);
    
end Behavioral;