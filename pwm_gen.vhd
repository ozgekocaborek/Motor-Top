library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity pwm_gen is
	port (
    CLOCK_I                    : in std_logic   ;    
    RESET_N_I                  : in std_logic   ;

    PWM_PERIOD_I               : in std_logic_vector(31 downto 0);
    PWM_DUTY_CYCLE_I           : in std_logic_vector(31 downto 0);
    
    PWM_O                      : out std_logic);
end pwm_gen;

architecture rtl of pwm_gen is

type PWM_STATE_ENUM is ( START_S, PWM_GEN_S);
signal PWM_STATE : PWM_STATE_ENUM;

signal pwm_period_r        : std_logic_vector(31 downto 0); 
signal pwm_duty_cycle_r    : std_logic_vector(31 downto 0);

signal pwm_count_r         : std_logic_vector(31 downto 0);
signal pwm_r               : std_logic                    ;
 
begin

pwm_gen_p : process(CLOCK_I, RESET_N_I)
begin
  if(RESET_N_I = '0')then
    PWM_STATE              <= START_S;
  
    pwm_period_r           <= (others => '0');
    pwm_duty_cycle_r       <= (others => '0');
    
    pwm_count_r            <= (others => '0');
    pwm_r                  <= '0';
    
  elsif rising_edge(CLOCK_I)then
    case PWM_STATE is
      when START_S         =>  
        pwm_period_r       <= PWM_PERIOD_I    ;
        pwm_duty_cycle_r   <= PWM_DUTY_CYCLE_I;
        pwm_r              <= '1';
        PWM_STATE          <= PWM_GEN_S;        
      
      when PWM_GEN_S       =>
        if(pwm_count_r = pwm_duty_cycle_r - 2)then 
          pwm_r            <= '0';
          pwm_count_r      <= pwm_count_r + '1';
        elsif(pwm_count_r = pwm_period_r - 2)then
          pwm_count_r      <= (others => '0');
          PWM_STATE        <= START_S;
          pwm_r            <= '1';
        else
          pwm_count_r      <= pwm_count_r + '1';
        end if;
        
      when others          =>
        null;
    end case;    
  end if;
end process;

PWM_O <= pwm_r;

end rtl;