library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           AluSrc : in STD_LOGIC;
           Ext_Imm : in STD_LOGIC_VECTOR (15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           AluOp : in STD_LOGIC_Vector(2 downto 0);
           PC_1 : in STD_LOGIC_VECTOR (15 downto 0);
           Zero : out STD_LOGIC;
           AluRes : out STD_LOGIC_VECTOR(15 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0));
end EX;

architecture Behavioral of EX is
signal MUX_OUT: STD_LOGIC_VECTOR(15 downto 0);
signal AluCtrl: STD_LOGIC_VECTOR(2 downto 0);
signal C: STD_LOGIC_VECTOR(15 downto 0);
begin
AluRes <= C;
BranchAddress <= Ext_Imm + PC_1;

process(RD2, Ext_Imm, AluSrc)
begin
    case AluSrc is
        when '0' => MUX_OUT <= RD2;
        when '1' => MUX_OUT <= Ext_Imm;
    end case;
end process;

ALUCONTROL: process(AluOp, func)
begin

case AluOp is
    when "000" =>
        case func is
            when "000" => AluCtrl <= "000";
            when "001" => AluCtrl <= "001";
            when "010" => AluCtrl <= "011";
            when "011" => AluCtrl <= "010";
            when "100" => AluCtrl <= "100";
            when "101" => AluCtrl <= "101";
            when "110" => AluCtrl <= "110";
            when "111" => AluCtrl <= "111";
            when others => AluCtrl <= (others => 'X');
        end case;
    when "001" => AluCtrl <= "000";
    when "010" => AluCtrl <= "001";
    when "011" => AluCtrl <= "010";
    when "100" => AluCtrl <= "011";
    when others => AluCtrl <= (others => 'X');
end case;
end process; 

process(AluCtrl, RD1, MUX_OUT)
begin

case AluCtrl is
    when "000" => C <= RD1 + MUX_OUT;
    when "001" => C <= RD1 - MUX_OUT;
    when "010" => C <= RD1 AND MUX_OUT;
    when "011" => C <= RD1 OR MUX_OUT;
    when "100" => 
    case sa is
        when '0' => C <= RD1;
        when '1' => C <= RD1(14 downto 0)&"0";
        when others => C <= (others => 'X');
    end case;
    when "101" => 
    case sa is
            when '0' => C <= RD1;
            when '1' => C <= RD1(15)&RD1(15 downto 1);
            when others => C <= (others => 'X');
    end case;
    when "110" => C <= RD1 XOR MUX_OUT;
    when "111" => 
        case RD1 is
                when x"0000" => C <= RD1;
                when x"0001" => C <= RD1(14 downto 0)&"0";
                when x"0010" => C <= RD1(13 downto 0)&"00";
                when x"0011" => C <= RD1(12 downto 0)&"000";
                when x"0100" => C <= RD1(11 downto 0)&"0000";
                when x"0101" => C <= RD1(10 downto 0)&"00000";
                when x"0110" => C <= RD1(9 downto 0)&"000000";
                when x"0111" => C <= RD1(8 downto 0)&"0000000";
                when x"1000" => C <= RD1(7 downto 0)&"00000000";
                when x"1001" => C <= RD1(6 downto 0)&"000000000";
                when x"1010" => C <= RD1(5 downto 0)&"0000000000";
                when x"1011" => C <= RD1(4 downto 0)&"00000000000";
                when x"1100" => C <= RD1(3 downto 0)&"000000000000";
                when x"1101" => C <= RD1(2 downto 0)&"0000000000000";
                when x"1110" => C <= RD1(1 downto 0)&"00000000000000";
                when others =>  C <= (others => '0');
        end case;
    when others => C <= (others => 'X');
end case;
end process;
process(C)
    begin
        if C = x"0000" then
            zero <= '1';
        else 
            zero <= '0';
        end if;
    end process;

end Behavioral;
