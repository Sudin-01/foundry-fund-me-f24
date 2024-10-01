// SPDX-License-Identifier: MIT
// If we are in anvil we deploy the mock,
//otherwise we will deploy to the live network
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelpConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_CONSTANT = 2000e8;

    NetworkConfig public activepricefeed;

    struct NetworkConfig {
        address pricefeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activepricefeed = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activepricefeed = getMainnetConfig();
        } else {
            activepricefeed = getOrCreateanvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        //get pricefeed address;
        NetworkConfig memory s_pricefeed = NetworkConfig({pricefeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return s_pricefeed;
    }

    function getOrCreateanvilConfig() public returns (NetworkConfig memory) {
        //get pricefeed address;
        //1.Deploy the mocks;
        //2.Returns the mocks;
        //mock->is a dummy contract or address
        if (activepricefeed.pricefeed != address(0)) {
            return activepricefeed;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_CONSTANT);
        vm.stopBroadcast();
        NetworkConfig memory anvil_pricefeed = NetworkConfig({pricefeed: address(mockPriceFeed)});
        return anvil_pricefeed;
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        //get pricefeed address;
        NetworkConfig memory m_pricefeed = NetworkConfig({pricefeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return m_pricefeed;
    }
}
