-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
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

library surf;
use surf.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity xlx_ku_mgt_10g24_emu_qpll is
   generic (
      TPD_G             : time            := 1 ns;
      GT_CLK_SEL_G      : boolean         := false;  -- false = gtClkP/N, true = gtClkIn
      SELECT_GT_TYPE_G  : boolean         := false;  -- false = GTH, true = GTY
      QPLL_REFCLK_SEL_G : slv(2 downto 0) := "001");
   port (
      -- MGT Clock Port (320 MHz)
      gtClkP        : in  sl := '0';
      gtClkN        : in  sl := '1';
      gtClkIn       : in  sl := '0';
      gtClkOut      : out sl;
      -- Quad PLL Interface
      qplllock      : out slv(1 downto 0);
      qplloutclk    : out slv(1 downto 0);
      qplloutrefclk : out slv(1 downto 0);
      qpllRst       : in  sl);
end xlx_ku_mgt_10g24_emu_qpll;

architecture mapping of xlx_ku_mgt_10g24_emu_qpll is

   signal refClk : sl;

begin

   gtClkOut <= refClk;

   EXT_REF : if (GT_CLK_SEL_G = false) generate
      IBUFDS_GTE4_Inst : IBUFDS_GTE4
         generic map (
            REFCLK_EN_TX_PATH  => '0',
            REFCLK_HROW_CK_SEL => "00",  -- 2'b00: ODIV2 = O
            REFCLK_ICNTL_RX    => "00")
         port map (
            I     => gtClkP,
            IB    => gtClkN,
            CEB   => '0',
            ODIV2 => open,
            O     => refClk);
   end generate;

   INT_REF : if (GT_CLK_SEL_G = true) generate
      refClk <= gtClkIn;
   end generate;

   -------------
   -- GTH Module
   -------------
   GEN_GTH_QUAD : if (SELECT_GT_TYPE_G = false) generate
      U_QPLL : entity surf.GthUltraScaleQuadPll
         generic map (
            -- Simulation Parameters
            TPD_G              => TPD_G,
            -- QPLL Configuration Parameters
            QPLL_CFG0_G        => (others => "0011001100011100"),
            QPLL_CFG1_G        => (others => "1101000000111000"),
            QPLL_CFG1_G3_G     => (others => "1101000000111000"),
            QPLL_CFG2_G        => (others => "0000111111000001"),
            QPLL_CFG2_G3_G     => (others => "0000111111000001"),
            QPLL_CFG3_G        => (others => "0000000100100000"),
            QPLL_CFG4_G        => (others => "0000000000000011"),  -- Different from GTY (confirmed on GTH IP core example)
            QPLL_CP_G          => (others => "0011111111"),
            QPLL_CP_G3_G       => (others => "0000001111"),
            QPLL_FBDIV_G       => (others => 32),
            QPLL_FBDIV_G3_G    => (others => 160),
            QPLL_INIT_CFG0_G   => (others => "0000001010110010"),
            QPLL_INIT_CFG1_G   => (others => "00000000"),
            QPLL_LOCK_CFG_G    => (others => "0010010111101000"),
            QPLL_LOCK_CFG_G3_G => (others => "0010010111101000"),
            QPLL_LPF_G         => (others => "1101111111"),
            QPLL_LPF_G3_G      => (others => "0111010101"),
            QPLL_REFCLK_DIV_G  => (others => 1),
            QPLL_SDM_CFG0_G    => (others => "0000000010000000"),
            QPLL_SDM_CFG1_G    => (others => "0000000000000000"),
            QPLL_SDM_CFG2_G    => (others => "0000000000000000"),
            -- Clock Selects
            QPLL_REFCLK_SEL_G  => (others => QPLL_REFCLK_SEL_G))
         port map (
            qPllRefClk(0)     => refClk,
            qPllRefClk(1)     => '0',   -- QPLL[1] not used
            qPllOutClk(0)     => qPllOutClk(0),
            qPllOutClk(1)     => qPllOutClk(1),
            qPllOutRefClk(0)  => qPllOutRefClk(0),
            qPllOutRefClk(1)  => qPllOutRefClk(1),
            qPllLock(0)       => qPllLock(0),
            qPllLock(1)       => qPllLock(1),
            qPllLockDetClk(0) => '0',  -- IP Core ties this to GND (see note below)
            qPllLockDetClk(1) => '0',  -- IP Core ties this to GND (see note below)
            qPllPowerDown(0)  => '0',
            qPllPowerDown(1)  => '1',
            qPllReset(0)      => qpllRst,
            qPllReset(1)      => '1');
   end generate;

   -------------
   -- GTY Module
   -------------
   GEN_GTY_QUAD : if (SELECT_GT_TYPE_G = true) generate
      U_QPLL : entity surf.GtyUltraScaleQuadPll
         generic map (
            -- Simulation Parameters
            TPD_G              => TPD_G,
            -- QPLL Configuration Parameters
            QPLL_CFG0_G        => (others => "0011001100011100"),
            QPLL_CFG1_G        => (others => "1101000000111000"),
            QPLL_CFG1_G3_G     => (others => "1101000000111000"),
            QPLL_CFG2_G        => (others => "0000111111000001"),
            QPLL_CFG2_G3_G     => (others => "0000111111000001"),
            QPLL_CFG3_G        => (others => "0000000100100000"),
            QPLL_CFG4_G        => (others => "0000000000000001"),  -- Different from GTH (confirmed on GTY IP core example)
            QPLL_CP_G          => (others => "0011111111"),
            QPLL_CP_G3_G       => (others => "0000001111"),
            QPLL_FBDIV_G       => (others => 32),
            QPLL_FBDIV_G3_G    => (others => 160),
            QPLL_INIT_CFG0_G   => (others => "0000001010110010"),
            QPLL_INIT_CFG1_G   => (others => "00000000"),
            QPLL_LOCK_CFG_G    => (others => "0010010111101000"),
            QPLL_LOCK_CFG_G3_G => (others => "0010010111101000"),
            QPLL_LPF_G         => (others => "1101111111"),
            QPLL_LPF_G3_G      => (others => "0111010101"),
            QPLL_REFCLK_DIV_G  => (others => 1),
            QPLL_SDM_CFG0_G    => (others => "0000000010000000"),
            QPLL_SDM_CFG1_G    => (others => "0000000000000000"),
            QPLL_SDM_CFG2_G    => (others => "0000000000000000"),
            -- Clock Selects
            QPLL_REFCLK_SEL_G  => (others => QPLL_REFCLK_SEL_G))
         port map (
            qPllRefClk(0)     => refClk,
            qPllRefClk(1)     => '0',   -- QPLL[1] not used
            qPllOutClk(0)     => qPllOutClk(0),
            qPllOutClk(1)     => qPllOutClk(1),
            qPllOutRefClk(0)  => qPllOutRefClk(0),
            qPllOutRefClk(1)  => qPllOutRefClk(1),
            qPllLock(0)       => qPllLock(0),
            qPllLock(1)       => qPllLock(1),
            qPllLockDetClk(0) => '0',  -- IP Core ties this to GND (see note below)
            qPllLockDetClk(1) => '0',  -- IP Core ties this to GND (see note below)
            qPllPowerDown(0)  => '0',
            qPllPowerDown(1)  => '1',
            qPllReset(0)      => qpllRst,
            qPllReset(1)      => '1');
   end generate;

   ---------------------------------------------------------------------------------------------
   -- Note: GTXE3_COMMON pin GTHE3_COMMON_Inst.QPLLLOCKDETCLK[1:0] cannot be driven by a clock
   --       derived from the same clock used as the reference clock for the QPLL, including
   --       TXOUTCLK*, RXOUTCLK*, the output from the IBUFDS_GTE3 providing the reference clock,
   --       and any --       buffered or multiplied/divided versions of these clock outputs.
   --       Please see UG576 for more information. Source, through a clock buffer, is the same
   --       as the GT cell reference clock.
   ---------------------------------------------------------------------------------------------

end mapping;
