library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity motor_top is
	port (
    CLOCK_I                    : in  std_logic  ;    

    SIGNAL_A_I                 : in  std_logic  ;
    SIGNAL_B_I                 : in  std_logic  ;
    
    buton1                    : in std_logic   ;    
    buton2                    : in std_logic   ; 
     
    PWM_O                      : out std_logic );
end motor_top;

architecture rtl of motor_top is

component speed_meas_test is
	port (
    CLOCK_I                    : in std_logic   ;    
    RESET_N_I                  : in std_logic   ;

    SIGNAL_A_I                 : in std_logic   ;
    SIGNAL_B_I                 : in std_logic   ;
    
    DIRECTION_O                : out std_logic  ;
    PHASE_COUNT_O              : out std_logic_vector(31 downto 0) );
end component;

component pwm_gen is
	port (
    CLOCK_I                    : in std_logic   ;    
    RESET_N_I                  : in std_logic   ;

    PWM_PERIOD_I               : in std_logic_vector(31 downto 0);
    PWM_DUTY_CYCLE_I           : in std_logic_vector(31 downto 0);
    
    PWM_O                      : out std_logic);
end component;

component buton_controller is
	port (
    clk                       : in std_logic   ;
    reset_n_i                 : in std_logic   ;
    
    buton1                    : in std_logic   ;    
    buton2                    : in std_logic   ;  

    duty_cycle_o                : out std_logic_vector(31 downto 0) );
end component;

component clk_wiz_0
  port (
    clk_out1                   : out std_logic;
    locked                     : out std_logic;
    clk_in1                    : in  std_logic);
end component;

signal clk_100m_r              : std_logic;
signal reset_100m_r            : std_logic;

signal direction_r             : std_logic;
signal phase_count_r           : std_logic_vector(31 downto 0);

signal pwm_period_r            : std_logic_vector(31 downto 0);
signal pwm_duty_cycle_r        : std_logic_vector(31 downto 0);


begin

clk_wiz_0_inst: clk_wiz_0
  port map(
    clk_out1                   => clk_100m_r,
    locked                     => reset_100m_r,
    clk_in1                    => CLOCK_I  );

speed_meas_test_inst: speed_meas_test 
	port map(
    CLOCK_I                    => clk_100m_r,  
    RESET_N_I                  => reset_100m_r,

    SIGNAL_A_I                 => SIGNAL_A_I ,
    SIGNAL_B_I                 => SIGNAL_B_I ,
    
    DIRECTION_O                => direction_r,    -- uart
    PHASE_COUNT_O              => phase_count_r); -- uart

pwm_gen_inst: pwm_gen
	port map(
    CLOCK_I                    => clk_100m_r, 
    RESET_N_I                  => reset_100m_r,

    PWM_PERIOD_I               => pwm_period_r,     -- control with button
    PWM_DUTY_CYCLE_I           => pwm_duty_cycle_r, -- control with button
    
    PWM_O                      => PWM_O);

btn_cntrl: buton_controller
  port map(
    clk                       => clk_100m_r,
    reset_n_i                 => reset_100m_r,     
    
    buton1                    => buton1,
    buton2                    => buton2,

    duty_cycle_o              => pwm_duty_cycle_r );
    

end rtl;