// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/console.sol";
import {OperationTest} from "./Operation.t.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Setup} from "./utils/Setup.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IStrategyInterface} from "../interfaces/IStrategyInterface.sol";

contract ARBOperationAUSDCTest is OperationTest {
    function setUp() public override {
        //super.setUp();
        uint256 arbitrumFork = vm.createFork("arbitrum");
        vm.selectFork(arbitrumFork);

        //asset from https://docs.pendle.finance/Developers/Deployments/: Markets --> PT-aUSDC-27JUN24/SY-aUSDC Market --> asset
        asset = ERC20(0x8621c587059357d6C669f72dA3Bfe1398fc0D0B5); //PT-aUSDC-27JUN24/SY-aUSDC Market
        //targetToken from asset --> readTokens --> SY --> getTokensIn --> targetToken
        targetToken = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831; //USDC
        //(0.01% = 100, 0.05% = 500, 0.3% = 3000, 1% = 10000)
        feeBaseToTargetToken = 500;

        //ARB rewards:
        additionalReward1 = 0x912CE59144191C1204E64559FE8253a0e49E6548;
        feeAdditionalReward1toBase = 500;

        //PNP rewards:
        additionalReward2 = 0x2Ac2B254Bc18cD4999f64773a966E4f4869c34Ee;
        feeAdditionalReward2toBase = 10000;
        
        //chain specific:
        base = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
        PENDLE = 0x0c880f6761F1af8d9Aa9C466984b80DAb9a8c9e8;
        feePENDLEtoBase = 3000;

        pendleStaking = 0x6DB96BBEB081d2a85E0954C252f2c1dC108b3f81; //https://docs.penpiexyz.io/smart-contracts --> Arbitrum --> PendleStaking
        GOV = 0x6Ba1734209a53a6E63C39D4e36612cc856A34D56;  
        
        // Set decimals
        decimals = asset.decimals();
        strategyFactory = setUpStrategyFactory();
        // Deploy strategy and set variables
        vm.prank(management);
        strategy = IStrategyInterface(strategyFactory.newPendleLPCompounder(address(asset), feePENDLEtoBase, base, feeBaseToTargetToken, targetToken, "Strategy"));
        setUpStrategy();
        factory = strategy.FACTORY();

        vm.prank(management);
        strategy.setRouterParams(0, type(uint256).max, 256, 1e16);
        
        // reward:
        if (additionalReward1 != address(0)) {
            vm.prank(management);
            strategy.addReward(additionalReward1, feeAdditionalReward1toBase, true);
        }

        // reward:
        if (additionalReward2 != address(0)) {
            vm.prank(management);
            strategy.addReward(additionalReward2, feeAdditionalReward2toBase, true);
        }

        // label all the used addresses for traces
        vm.label(keeper, "keeper");
        vm.label(factory, "factory");
        vm.label(address(asset), "asset");
        vm.label(management, "management");
        vm.label(address(strategy), "strategy");
        vm.label(performanceFeeRecipient, "performanceFeeRecipient");
        vm.label(address(strategyFactory), "strategyFactory");
    }
}
