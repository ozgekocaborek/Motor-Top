library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity speed_meas_test is
	port (
    CLOCK_I                    : in std_logic   ;    
    RESET_N_I                  : in std_logic   ;

    SIGNAL_A_I                 : in std_logic   ;
    SIGNAL_B_I                 : in std_logic   ;
    
    DIRECTION_O                : out std_logic  ;
    PHASE_COUNT_O              : out std_logic );
end speed_meas_test;

architecture rtl of speed_meas_test is

type COUNT_STATE_ENUM is ( WAIT_START, WAIT_B_RIS_EDGE_S, WAIT_A_RIS_EDGE_S );
signal COUNT_STATE : COUNT_STATE_ENUM;

signal signal_a_d0_r       : std_logic                    ;
signal signal_a_d1_r       : std_logic                    ;
signal signal_a_d2_r       : std_logic                    ;
signal signal_a_d3_r       : std_logic                    ;
signal signal_b_d0_r       : std_logic                    ;
signal signal_b_d1_r       : std_logic                    ;
signal signal_b_d2_r       : std_logic                    ;
signal signal_b_d3_r       : std_logic                    ;

signal cnt_a_to_b_r        : std_logic_vector(31 downto 0);
signal cnt_b_to_a_r        : std_logic_vector(31 downto 0);
signal cnt_a_to_b_val_r    : std_logic_vector(31 downto 0);
signal cnt_b_to_a_val_r    : std_logic_vector(31 downto 0);

signal direction_r         : std_logic                    ;
signal phase_count_r       : std_logic_vector(31 downto 0);

begin

  metastability_p : process (CLOCK_I, RESET_N_I)
  begin
    if (RESET_N_I = '0') then
      signal_a_d0_r       <= '0' ;
      signal_a_d1_r       <= '0' ;
      signal_a_d2_r       <= '0' ;
      signal_a_d3_r       <= '0' ;
      signal_b_d0_r       <= '0' ;
      signal_b_d1_r       <= '0' ;
      signal_b_d2_r       <= '0' ;
      signal_b_d3_r       <= '0' ;
  
    elsif rising_edge(CLOCK_I) then
  
      signal_a_d0_r       <= SIGNAL_A_I     ;
      signal_a_d1_r       <= signal_a_d0_r  ;
      signal_a_d2_r       <= signal_a_d1_r  ;
      signal_a_d3_r       <= signal_a_d2_r  ;
      
      signal_b_d0_r       <= SIGNAL_B_I     ;
      signal_b_d1_r       <= signal_b_d0_r  ;
      signal_b_d2_r       <= signal_b_d1_r  ;
      signal_b_d3_r       <= signal_b_d2_r  ;

    end if;
  end process;


  count_p : process (CLOCK_I, RESET_N_I)
  begin
    if (RESET_N_I = '0') then
      COUNT_STATE         <= WAIT_START      ;
      cnt_a_to_b_r        <= (others => '0') ;
      cnt_b_to_a_r        <= (others => '0') ;      
      cnt_a_to_b_val_r    <= (others => '0') ;      
      cnt_b_to_a_val_r    <= (others => '0') ;      
      
    elsif rising_edge(CLOCK_I) then
      
      case COUNT_STATE is 
        
        when WAIT_START        =>          
          if (signal_a_d3_r = '0') and (signal_a_d2_r = '1') then --rising edge condition
            COUNT_STATE        <= WAIT_B_RIS_EDGE_S;
          else
            COUNT_STATE        <= WAIT_START;
          end if;
          
        when WAIT_B_RIS_EDGE_S =>        
          if (signal_b_d3_r = '0') and (signal_b_d2_r = '1') then --rising edge condition
            COUNT_STATE        <= WAIT_A_RIS_EDGE_S;
            cnt_a_to_b_val_r   <= cnt_a_to_b_r;
            cnt_a_to_b_r       <= (others => '0');
          else
            COUNT_STATE        <= WAIT_B_RIS_EDGE_S;
            cnt_a_to_b_r       <= cnt_a_to_b_r + 1;
          end if;
            
        when WAIT_A_RIS_EDGE_S =>
          if (signal_a_d3_r = '0') and (signal_a_d2_r = '1') then --rising edge condition
            COUNT_STATE        <= WAIT_B_RIS_EDGE_S;
            cnt_b_to_a_val_r   <= cnt_b_to_a_r;
            cnt_b_to_a_r       <= (others => '0');
          else
            COUNT_STATE        <= WAIT_A_RIS_EDGE_S;
            cnt_b_to_a_r       <= cnt_b_to_a_r + 1;
          end if;    
  
        when others            =>
          null;
      end case;
    end if;  
  end process;


  direction_p :  process (CLOCK_I, RESET_N_I)
  begin
    if (RESET_N_I = '0') then
      direction_r             <= '0';
      
    elsif rising_edge(CLOCK_I) then
      
      if (cnt_a_to_b_val_r <= cnt_b_to_a_val_r) then
        direction_r        <= '0'; -- counter clockwise
      else  
        direction_r        <= '1'; -- clockwise
      end if;

    end if;
  end process;


  decision_p :  process (CLOCK_I, RESET_N_I)
  begin
    if (RESET_N_I = '0') then
      phase_count_r             <= (others => '0');
      
    elsif rising_edge(CLOCK_I) then
      if (direction_r = '0') then
        phase_count_r           <= cnt_a_to_b_val_r;
      else
        phase_count_r           <= cnt_b_to_a_val_r;
      end if;
    
    end if;
  end process;

  DIRECTION_O   <= direction_r;
  PHASE_COUNT_O <= phase_count_r;

end rtl;