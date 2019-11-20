-------------------------------------------------------------------------------
-- File       : LpGbt2EmuLpGbt_LinkingWithGthTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the GTH Linking Up
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;

entity LpGbt2EmuLpGbt_LinkingWithGthTb is
end LpGbt2EmuLpGbt_LinkingWithGthTb;

architecture testbed of LpGbt2EmuLpGbt_LinkingWithGthTb is

   signal downlinkRaw : slv(35 downto 0)  := (others => '0');
   signal uplinkRaw   : slv(233 downto 0) := (others => '0');

   signal downlinkCnt : Slv36Array(1 downto 0)  := (others => (others => '0'));
   signal uplinkCnt   : Slv234Array(1 downto 0) := (others => (others => '0'));

   signal downlinkClk   : slv(1 downto 0) := (others => '0');
   signal downlinkClkEn : slv(1 downto 0) := (others => '0');
   signal downlinkReady : slv(1 downto 0) := (others => '0');

   signal uplinkClk   : slv(1 downto 0) := (others => '0');
   signal uplinkClkEn : slv(1 downto 0) := (others => '0');
   signal uplinkReady : slv(1 downto 0) := (others => '0');

   signal refClk320 : sl := '0';
   signal axilClk   : sl := '0';
   signal usrRst    : sl := '1';

   signal gtEmuToLpP : sl := '0';
   signal gtEmuToLpN : sl := '1';

   signal gtLpToEmuP : sl := '0';
   signal gtLpToEmuN : sl := '1';

begin

   process(downlinkClk)
   begin
      if rising_edge(downlinkClk(0)) then
         if downlinkClkEn(0) = '1' then
            if (downlinkReady = "11") then
               downlinkCnt(0) <= downlinkCnt(0) + 1 after 1 ns;
            end if;
         end if;
      end if;
      if rising_edge(downlinkClk(1)) then
         if downlinkClkEn(1) = '1' then
            if (downlinkReady = "11") then
               downlinkCnt(1) <= downlinkRaw after 1 ns;
            end if;
         end if;
      end if;
   end process;

   process(uplinkClk)
   begin
      if rising_edge(uplinkClk(1)) then
         if uplinkClkEn(1) = '1' then
            if (uplinkReady = "11") then
               uplinkCnt(1) <= uplinkCnt(1) + 1 after 1 ns;
            end if;
         end if;
      end if;
      if rising_edge(uplinkClk(0)) then
         if uplinkClkEn(0) = '1' then
            if (uplinkReady = "11") then
               uplinkCnt(0) <= uplinkRaw after 1 ns;
            end if;
         end if;
      end if;
   end process;

   ---------------------------
   -- Generate clock and reset
   ---------------------------
   U_refClk320 : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => 3.125 ns,  -- 320 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 10 us)
      port map (
         clkP => refClk320,
         rst  => usrRst);

   U_axilClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G => 6.4 ns)        -- 156.25 MHz
      port map (
         clkP => axilClk);

   -------------
   -- LpGBT FPGA
   -------------
   U_LpGbtFpga10g24 : entity work.LpGbtFpga10g24
      port map (
         -- Down link
         donwlinkClk_o       => downlinkClk(0),
         downlinkClkEn_o     => downlinkClkEn(0),
         downlinkRst_i       => usrRst,
         downlinkUserData_i  => downlinkCnt(0)(31 downto 0),
         downlinkEcData_i    => downlinkCnt(0)(33 downto 32),
         downlinkIcData_i    => downlinkCnt(0)(35 downto 34),
         downlinkReady_o     => downlinkReady(0),
         -- Up link
         uplinkClk_o         => uplinkClk(0),
         uplinkClkEn_o       => uplinkClkEn(0),
         uplinkRst_i         => usrRst,
         uplinkUserData_o    => uplinkRaw(229 downto 0),
         uplinkEcData_o      => uplinkRaw(231 downto 230),
         uplinkIcData_o      => uplinkRaw(233 downto 232),
         uplinkReady_o       => uplinkReady(0),
         -- MGT
         clk_refclk_i        => refClk320,
         clk_mgtfreedrpclk_i => axilClk,
         mgt_rxn_i           => gtEmuToLpN,
         mgt_rxp_i           => gtEmuToLpP,
         mgt_txn_o           => gtLpToEmuN,
         mgt_txp_o           => gtLpToEmuP);

   -----------------------
   -- Emulation LpGBT FPGA
   -----------------------
   U_EmuLpGbtFpga10g24 : entity work.EmuLpGbtFpga10g24
      port map (
         -- Up link
         uplinkClk_o         => uplinkClk(1),
         uplinkClkEn_o       => uplinkClkEn(1),
         uplinkRst_i         => usrRst,
         uplinkUserData_i    => uplinkCnt(1)(229 downto 0),
         uplinkEcData_i      => uplinkCnt(1)(231 downto 230),
         uplinkIcData_i      => uplinkCnt(1)(233 downto 232),
         uplinkReady_o       => uplinkReady(1),
         -- Down link
         donwlinkClk_o       => downlinkClk(1),
         downlinkClkEn_o     => downlinkClkEn(1),
         downlinkRst_i       => usrRst,
         downlinkUserData_o  => downlinkRaw(31 downto 0),
         downlinkEcData_o    => downlinkRaw(33 downto 32),
         downlinkIcData_o    => downlinkRaw(35 downto 34),
         downlinkReady_o     => downlinkReady(1),
         -- MGT
         clk_refclk_i        => refClk320,
         clk_mgtfreedrpclk_i => axilClk,
         mgt_rxn_i           => gtLpToEmuN,
         mgt_rxp_i           => gtLpToEmuP,
         mgt_txn_o           => gtEmuToLpN,
         mgt_txp_o           => gtEmuToLpP);

end testbed;
