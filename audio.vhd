LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY audio_sos IS
	PORT (
		bt1, bt2, bt3 : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		audio : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END audio_sos;

ARCHITECTURE Behavioral OF audio_sos IS
	SIGNAL prev_state_bt1 : STD_LOGIC := '1';
	SIGNAL prev_state_bt2 : STD_LOGIC := '1';
	SIGNAL prev_state_bt3 : STD_LOGIC := '1';
	SIGNAL contador : INTEGER RANGE 0 TO 6000000;
	SIGNAL dac_out : std_logic;
	SIGNAL bit_index_increment : STD_LOGIC := '0';
	SIGNAL bit_time : INTEGER := 0;
	SIGNAL bit_index : INTEGER := 0;
	SIGNAL bit_sequence : STD_LOGIC_VECTOR(0 TO 53) := "000000000000000000000000000000000000000000000000000000";
	SIGNAL bit_tone_period : INTEGER RANGE 0 TO 200000;
 
	CONSTANT bit_sequence_length : INTEGER := 54;

BEGIN
	audio <= dac_out & dac_out;

	PROCESS (clk, bit_sequence, bit_index_increment, bit_index_increment)
	BEGIN
		IF rising_edge(clk) THEN

			contador <= contador + 1;
			IF contador = 60000 THEN
				contador <= 0;
				IF (bt1 = '0' AND prev_state_bt1 = '1') THEN
					bit_index_increment <= '1';
					bit_sequence <= "101010100000100000100111010100000100111011101000000000"; -- HELP > .... . .-.. .--.
				END IF;
				prev_state_bt1 <= bt1;
				IF (bt2 = '0' AND prev_state_bt2 = '1') THEN
					bit_index_increment <= '1';
					bit_sequence <= "101010011100111001110010101000000000000000000000000000"; -- SOS > ... --- ...
				END IF;
				prev_state_bt2 <= bt2;
				IF (bt3 = '0' AND prev_state_bt3 = '1') THEN
					bit_index_increment <= '1';
					bit_sequence <= "100111011101110000011101110111000010101000001000000000"; -- JOSE > .--- --- ... .
				END IF;
				prev_state_bt3 <= bt3;
			END IF;
			IF bit_time = 1600000 THEN
				bit_time <= 0;
				bit_tone_period <= 0;
				IF bit_index = bit_sequence_length OR bit_index_increment = '1' THEN
					bit_index <= 0;
					bit_index_increment <= '0';
				ELSE
					bit_index <= bit_index + 1;
				END IF;
			ELSE
				bit_time <= bit_time + 1;
			END IF;

			bit_tone_period <= bit_tone_period + 1;
			IF bit_tone_period = 16666 THEN
				bit_tone_period <= 0;
				IF bit_sequence(bit_index) = '1' THEN
					dac_out <= NOT dac_out;
				ELSE
					dac_out <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
 
END Behavioral;