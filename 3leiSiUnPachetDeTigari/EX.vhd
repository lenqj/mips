library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGnED.ALL;

entity EX is
    port ( RD1 : in std_logic_vector(15 downto 0);
           RD2 : in std_logic_vector(15 downto 0);
           extImm: in std_logic_vector(15 downto 0);
           PCinc : in std_logic_vector(15 downto 0);
           ALUOp : in std_logic_vector(2 downto 0);
           func : in std_logic_vector(2 downto 0);
           sa : in std_logic;
           ALUSrc : in std_logic;
           branchAdress : out std_logic_vector(15 downto 0);
           ALURes : out std_logic_vector(15 downto 0);
           zero : out std_logic
         );
end EX;

architecture arh of EX is

signal ALUCtrl : std_logic_vector(2 downto 0);
signal muxOut : std_logic_vector(15 downto 0);
signal SALURes : std_logic_vector(15 downto 0);
 
begin
    branchAdress <= extImm + PCinc;
    ALURes <= SALURes;
    
    MuxALUProcess: process(ALUSrc, RD2, extImm)
    begin
        if ALUSrc = '1' then
            muxOut <= extImm;
        else
            muxOut <= RD2;
        end if;
    end process;
    
    ALUControlProcess: process(ALUOp, func)
    begin
        case ALUOp is
            when "000" => 
                case func is
                    when "000" => ALUCtrl <= "000";
                    when "001" => ALUCtrl <= "001";
                    when "010" => ALUCtrl <= "010";
                    when "011" => ALUCtrl <= "011";
                    when "100" => ALUCtrl <= "100";
                    when "101" => ALUCtrl <= "101";
                    when "110" => ALUCtrl <= "110";
                    when "111" => ALUCtrl <= "111";
                    when others => ALUCtrl <= "XXX";
                end case;
            when "100" => ALUCtrl <= "000";
            when "001" => ALUCtrl <= "001";
            when "101" => ALUCtrl <= "101";
            when "110" => ALUCtrl <= "110";
            when others => ALUCtrl <= "XXX";
        end case;
    end process;
    
    ALUProcess: process(ALUCtrl, RD1, muxOut)
    begin
        case ALUCtrl is
            when "000" => SALURes <= RD1 + muxOut;
            when "001" => SALURes <= RD1 - muxOut;
            when "010" => SALURes <= RD1(14 downto 0) & '0';
            when "011" => SALURes <= '0' & RD1(15 downto 1);
            when "100" => SALURes <= RD1 AND muxOut;
            when "101" => SALURes <= RD1 OR muxOut;
            when "110" =>
                if signed(RD1) < signed(muxOut) then
                    SALURes <= x"0001";
                else
                    SALURes <= x"0000";
                end if;
            when "111" => SALURes <= RD1(15) & RD1(15 downto 1);
            when others => ALURes <= (others => 'X');
        end case;
    end process;
    
    zeroProcess: process(SALURes)
    begin
        if SALURes = x"0000" then
            zero <= '1';
        else 
            zero <= '0';
        end if;
    end process;
    
end arh;