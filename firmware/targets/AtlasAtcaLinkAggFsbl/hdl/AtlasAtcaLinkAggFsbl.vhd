-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggFsbl.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: First Stage Boot Loader (FSBL)
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS ATCA LINK AGG DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggFsbl is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      BUILD_INFO_G : BuildInfoType);
   port (
      --------------------- 
      --  Application Ports
      --------------------- 
      -- Jitter Cleaner PLL Ports
      fpgaToPllClkP  : out   sl;
      fpgaToPllClkN  : out   sl;
      pllToFpgaClkP  : in    sl;
      pllToFpgaClkN  : in    sl;
      -- Front Panel Clock/LED/TTL Ports
      smaClkP        : in    sl;
      smaClkN        : in    sl;
      ledRedL        : out   slv(1 downto 0) := "11";
      ledBlueL       : out   slv(1 downto 0) := "11";
      ledGreenL      : out   slv(1 downto 0) := "11";
      fpTrigInL      : in    sl;
      fpBusyOut      : out   sl              := '0';
      fpSpareOut     : out   sl              := '0';
      fpSpareInL     : in    sl;
      -- Backplane Clocks Ports
      bpClkIn        : in    slv(5 downto 0);
      bpClkOut       : out   slv(5 downto 0) := (others => '0');
      -- Front Panel QSFP+ Ports
      qsfpEthRefClkP : in    sl;
      qsfpEthRefClkN : in    sl;
      qsfpRef160ClkP : in    sl;
      qsfpRef160ClkN : in    sl;
      qsfpPllClkP    : in    sl;
      qsfpPllClkN    : in    sl;
      qsfpTxP        : out   Slv4Array(1 downto 0);
      qsfpTxN        : out   Slv4Array(1 downto 0);
      qsfpRxP        : in    Slv4Array(1 downto 0);
      qsfpRxN        : in    Slv4Array(1 downto 0);
      -- Front Panel SFP+ Ports
      sfpEthRefClkP  : in    sl;
      sfpEthRefClkN  : in    sl;
      sfpRef160ClkP  : in    sl;
      sfpRef160ClkN  : in    sl;
      sfpPllClkP     : in    sl;
      sfpPllClkN     : in    sl;
      sfpTxP         : out   slv(3 downto 0);
      sfpTxN         : out   slv(3 downto 0);
      sfpRxP         : in    slv(3 downto 0);
      sfpRxN         : in    slv(3 downto 0);
      -- RTM Ports (188 diff. pairs to RTM interface)
      dpmToRtmP      : inout Slv23Array(3 downto 0);
      dpmToRtmN      : inout Slv23Array(3 downto 0);
      rtmToDpmP      : inout Slv24Array(3 downto 0);
      rtmToDpmN      : inout Slv24Array(3 downto 0);
      -------------------   
      --  Top Level Ports
      -------------------   
      -- Jitter Cleaner PLL Ports
      pllSpiCsL      : out   sl;
      pllSpiSclk     : out   sl;
      pllSpiSdi      : out   sl;
      pllSpiSdo      : in    sl;
      pllSpiRstL     : out   sl;
      pllSpiOeL      : out   sl;
      pllIntrL       : in    sl;
      pllLolL        : in    sl;
      pllClkScl      : inout sl;
      pllClkSda      : inout sl;
      -- Front Panel I2C Ports
      fpScl          : inout sl;
      fpSda          : inout sl;
      sfpScl         : inout slv(3 downto 0);
      sfpSda         : inout slv(3 downto 0);
      qsfpScl        : inout slv(1 downto 0);
      qsfpSda        : inout slv(1 downto 0);
      -- ATCA Backplane: BASE ETH[1] and Front Panel LVDS SGMII Ports
      fpEthLed       : out   slv(3 downto 0);
      ethRefClkP     : in    slv(1 downto 0);
      ethRefClkN     : in    slv(1 downto 0);
      ethTxP         : out   slv(1 downto 0);
      ethTxN         : out   slv(1 downto 0);
      ethRxP         : in    slv(1 downto 0);
      ethRxN         : in    slv(1 downto 0);
      ethMdio        : inout slv(1 downto 0);
      ethMdc         : out   slv(1 downto 0);
      ethRstL        : out   slv(1 downto 0);
      ethIrqL        : in    slv(1 downto 0);
      -- ATCA Backplane: FABRIC ETH[1:4]
      fabEthRefClkP  : in    sl;
      fabEthRefClkN  : in    sl;
      fabEthTxP      : out   Slv4Array(4 downto 1);
      fabEthTxN      : out   Slv4Array(4 downto 1);
      fabEthRxP      : in    Slv4Array(4 downto 1);
      fabEthRxN      : in    Slv4Array(4 downto 1);
      -- IMPC Ports
      ipmcScl        : inout sl;
      ipmcSda        : inout sl;
      -- SYSMON Ports
      vPIn           : in    sl;
      vNIn           : in    sl);
end AtlasAtcaLinkAggFsbl;

architecture top_level of AtlasAtcaLinkAggFsbl is

   constant ETH_CONFIG_C : EthConfigArray := (
      ETH_FAB1_IDX_C  => ETH_PORT_SRP_ONLY_C,
      ETH_FAB2_IDX_C  => ETH_PORT_SRP_ONLY_C,
      ETH_FAB3_IDX_C  => ETH_PORT_SRP_ONLY_C,
      ETH_FAB4_IDX_C  => ETH_PORT_SRP_ONLY_C,
      ETH_BASE1_IDX_C => ETH_PORT_SRP_ONLY_C,
      ETH_FP_IDX_C    => ETH_PORT_SRP_ONLY_C);

   signal ref156Clk : sl;
   signal ref156Rst : sl;

   signal srvMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal srvSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);
   signal cltMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal cltSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);

begin

   U_fpgaToPllClk : entity work.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => '0',
         clkOutP => fpgaToPllClkP,
         clkOutN => fpgaToPllClkN);

   U_TERM_GTs : entity work.Gthe4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 4)
      port map (
         refClk => ref156Clk,
         gtRxP  => sfpRxP,
         gtRxN  => sfpRxN,
         gtTxP  => sfpTxP,
         gtTxN  => sfpTxN);

   GEN_QSFP :
   for i in 1 downto 0 generate
      U_TERM_GTs : entity work.Gtye4ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 4)
         port map (
            refClk => ref156Clk,
            gtRxP  => qsfpRxP(i),
            gtRxN  => qsfpRxN(i),
            gtTxP  => qsfpTxP(i),
            gtTxN  => qsfpTxN(i));
   end generate GEN_QSFP;

   U_Core : entity work.AtlasAtcaLinkAggCore
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         BUILD_INFO_G => BUILD_INFO_G,
         ETH_CONFIG_G => ETH_CONFIG_C)
      port map (
         -----------------------------
         --  Interfaces to Application
         -----------------------------
         -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
         axilClk         => open,
         axilRst         => open,
         axilReadMaster  => open,
         axilReadSlave   => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C,
         axilWriteMaster => open,
         axilWriteSlave  => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C,
         -- Server Streaming Interface (axilClk domain)
         srvIbMasters    => srvMasters,  -- Loopback
         srvIbSlaves     => srvSlaves,   -- Loopback
         srvObMasters    => srvMasters,  -- Loopback
         srvObSlaves     => srvSlaves,   -- Loopback
         -- Client Streaming Interface (axilClk domain)
         cltIbMasters    => cltMasters,  -- Loopback
         cltIbSlaves     => cltSlaves,   -- Loopback
         cltObMasters    => cltMasters,  -- Loopback
         cltObSlaves     => cltSlaves,   -- Loopback
         -- Misc. Interface 
         ref156Clk       => ref156Clk,
         ref156Rst       => ref156Rst,
         -------------------   
         --  Top Level Ports
         -------------------   
         -- Jitter Cleaner PLL Ports
         pllSpiCsL       => pllSpiCsL,
         pllSpiSclk      => pllSpiSclk,
         pllSpiSdi       => pllSpiSdi,
         pllSpiSdo       => pllSpiSdo,
         pllSpiRstL      => pllSpiRstL,
         pllSpiOeL       => pllSpiOeL,
         pllIntrL        => pllIntrL,
         pllLolL         => pllLolL,
         pllClkScl       => pllClkScl,
         pllClkSda       => pllClkSda,
         -- Front Panel I2C Ports
         fpScl           => fpScl,
         fpSda           => fpSda,
         sfpScl          => sfpScl,
         sfpSda          => sfpSda,
         qsfpScl         => qsfpScl,
         qsfpSda         => qsfpSda,
         -- ATCA Backplane: BASE ETH[1] and Front Panel LVDS SGMII Ports
         fpEthLed        => fpEthLed,
         ethRefClkP      => ethRefClkP,
         ethRefClkN      => ethRefClkN,
         ethTxP          => ethTxP,
         ethTxN          => ethTxN,
         ethRxP          => ethRxP,
         ethRxN          => ethRxN,
         ethMdio         => ethMdio,
         ethMdc          => ethMdc,
         ethRstL         => ethRstL,
         ethIrqL         => ethIrqL,
         -- ATCA Backplane: FABRIC ETH[1:4]
         fabEthRefClkP   => fabEthRefClkP,
         fabEthRefClkN   => fabEthRefClkN,
         fabEthTxP       => fabEthTxP,
         fabEthTxN       => fabEthTxN,
         fabEthRxP       => fabEthRxP,
         fabEthRxN       => fabEthRxN,
         -- IMPC Ports
         ipmcScl         => ipmcScl,
         ipmcSda         => ipmcSda,
         -- SYSMON Ports
         vPIn            => vPIn,
         vNIn            => vNIn);

end top_level;
