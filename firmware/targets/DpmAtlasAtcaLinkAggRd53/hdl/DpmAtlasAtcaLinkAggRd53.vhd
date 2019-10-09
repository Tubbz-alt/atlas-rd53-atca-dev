-------------------------------------------------------------------------------
-- File       : DpmAtlasAtcaLinkAggRd53.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'RCE Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'RCE Development Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.RceG3Pkg.all;
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DpmAtlasAtcaLinkAggRd53 is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- Debug
      led         : out   slv(1 downto 0) := "00";
      -- I2C
      i2cSda      : inout sl;
      i2cScl      : inout sl;
      -- Ethernet
      ethRxP      : in    slv(3 downto 0);
      ethRxM      : in    slv(3 downto 0);
      ethTxP      : out   slv(3 downto 0);
      ethTxM      : out   slv(3 downto 0);
      ethRefClkP  : in    sl;
      ethRefClkM  : in    sl;
      -- RTM High Speed
      dpmToRtmHsP : out   slv(11 downto 0);
      dpmToRtmHsM : out   slv(11 downto 0);
      rtmToDpmHsP : in    slv(11 downto 0);
      rtmToDpmHsM : in    slv(11 downto 0);
      -- Reference Clocks
      locRefClkP  : in    sl;
      locRefClkM  : in    sl;
      dtmRefClkP  : in    sl;
      dtmRefClkM  : in    sl;
      -- DTM Signals
      dtmClkP     : in    slv(1 downto 0);
      dtmClkM     : in    slv(1 downto 0);
      dtmFbP      : out   sl;
      dtmFbM      : out   sl;
      -- Clock Select
      clkSelA     : out   slv(1 downto 0);
      clkSelB     : out   slv(1 downto 0));
end DpmAtlasAtcaLinkAggRd53;

architecture TOP_LEVEL of DpmAtlasAtcaLinkAggRd53 is

   constant SERVER_SIZE_C : positive := 1;
   constant SERVER_PORTS_C : PositiveArray(SERVER_SIZE_C-1 downto 0) := (
      0 => 2542);                       -- Xilinx XVC 

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal axilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal axilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal axilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal dmaClk      : slv(2 downto 0);
   signal dmaRst      : slv(2 downto 0);
   signal dmaIbMaster : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlave  : AxiStreamSlaveArray(2 downto 0);
   signal dmaObMaster : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlave  : AxiStreamSlaveArray(2 downto 0);

   signal gtRefClock0 : sl;
   signal gtRefClock1 : sl;
   signal sysClk      : sl;
   signal sysClkBufg  : sl;
   signal gtRefClk0   : slv(2 downto 0) := (others=>'0');
   signal gtRefClk1   : slv(2 downto 0) := (others=>'0');

   signal ethClk   : sl;
   signal ethRst   : sl;
   signal localMac : slv(47 downto 0);
   signal localIp  : slv(31 downto 0);

   signal ibMacMaster : AxiStreamMasterType;
   signal ibMacSlave  : AxiStreamSlaveType;
   signal obMacMaster : AxiStreamMasterType;
   signal obMacSlave  : AxiStreamSlaveType;

   signal obServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0);
   signal ibServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0);

begin

   --------------------------------------------------
   -- PS + DMA + ETH MAC
   --------------------------------------------------
   U_DpmCore : entity work.DpmCore
      generic map (
         TPD_G              => TPD_G,
         RCE_DMA_MODE_G     => RCE_DMA_AXIS_C,
         BUILD_INFO_G       => BUILD_INFO_G,
         ETH_TYPE_G         => "1000BASE-KX",
         UDP_SERVER_EN_G    => true,
         UDP_SERVER_SIZE_G  => SERVER_SIZE_C,
         UDP_SERVER_PORTS_G => SERVER_PORTS_C)
      port map (
         -- IPMI I2C Ports
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         -- Clock Select
         clkSelA            => clkSelA,
         clkSelB            => clkSelB,
         -- Ethernet Ports
         ethRxP             => ethRxP,
         ethRxM             => ethRxM,
         ethTxP             => ethTxP,
         ethTxM             => ethTxM,
         ethRefClkP         => ethRefClkP,
         ethRefClkM         => ethRefClkM,
         -- AXI-Lite Register Interface [0xA0000000:0xAFFFFFFF]
         axiClk             => axilClk,
         axiClkRst          => axilRst,
         extAxilReadMaster  => axilReadMaster,
         extAxilReadSlave   => axilReadSlave,
         extAxilWriteMaster => axilWriteMaster,
         extAxilWriteSlave  => axilWriteSlave,
         -- AXI Stream DMA Interfaces
         dmaClk             => dmaClk,
         dmaClkRst          => dmaRst,
         dmaObMaster        => dmaObMaster,
         dmaObSlave         => dmaObSlave,
         dmaIbMaster        => dmaIbMaster,
         dmaIbSlave         => dmaIbSlave,
         -- User ETH interface (userEthClk domain)
         userEthClk         => ethClk,
         userEthClkRst      => ethRst,
         userEthIpAddr      => localIp,
         userEthMacAddr     => localMac,
         userEthUdpIbMaster => ibMacMaster,
         userEthUdpIbSlave  => ibMacSlave,
         userEthUdpObMaster => obMacMaster,
         userEthUdpObSlave  => obMacSlave);

   -----------
   -- IPv4/UDP
   -----------
   U_UDP : entity work.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => SERVER_SIZE_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Client Generics
         CLIENT_EN_G    => false)
      port map (
         -- Local Configurations
         localMac        => localMac,
         localIp         => localIp,
         -- Interface to Ethernet Media Access Controller (MAC)
         obMacMaster     => obMacMaster,
         obMacSlave      => obMacSlave,
         ibMacMaster     => ibMacMaster,
         ibMacSlave      => ibMacSlave,
         -- Interface to UDP Server engine(s)
         obServerMasters => obServerMasters,
         obServerSlaves  => obServerSlaves,
         ibServerMasters => ibServerMasters,
         ibServerSlaves  => ibServerSlaves,
         -- Clock and Reset
         clk             => ethClk,
         rst             => ethRst);

   -----------------------
   -- XVC UDP Debug Bridge
   -----------------------
   U_XVC_UDP_DEBUG_BRIDGE : entity work.UdpDebugBridgeWrapper
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Clock and Reset
         clk            => ethClk,
         rst            => ethRst,
         -- UDP XVC Interface
         obServerMaster => obServerMasters(0),
         obServerSlave  => obServerSlaves(0),
         ibServerMaster => ibServerMasters(0),
         ibServerSlave  => ibServerSlaves(0));

end TOP_LEVEL;
