// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

import "./Yearn4626RouterBase.sol";

import {ENSReverseRecord} from "./utils/ENSReverseRecord.sol";
import {IYearn4626Router, IYearnV2} from "./interfaces/IYearn4626Router.sol";

/// @title Yearn4626Router contract
contract Yearn4626Router is IYearn4626Router, Yearn4626RouterBase, ENSReverseRecord {
    using SafeTransferLib for ERC20;

    constructor(string memory name, IWETH9 weth) ENSReverseRecord(name) PeripheryPayments(weth) {}

    // For the below, no approval needed, assumes vault is already max approved

    /// @inheritdoc IYearn4626Router
    function depositToVault(
        IYearn4626 vault,
        uint256 amount,
        address to,
        uint256 minSharesOut
    ) public payable override returns (uint256 sharesOut) {
        pullToken(ERC20(vault.asset()), amount, address(this));
        return deposit(vault, amount, to, minSharesOut);
    }

    //-------- DEPOSIT FUNCTIONS WITH DEFAULT VALUES --------\\

    function depositToVault(
        IYearn4626 vault,
        uint256 amount,
        address to
    ) external payable returns (uint256 sharesOut) {
        return depositToVault(vault, amount, to, 0);
    }

    function depositToVault(
        IYearn4626 vault, 
        uint256 amount
    ) external payable returns (uint256 sharesOut) {
        return depositToVault(vault, amount, msg.sender, 0);
    }

    function depositToVault(
        IYearn4626 vault
    ) external payable returns (uint256 sharesOut) {
        return depositToVault(vault, ERC20(vault.asset()).balanceOf(msg.sender), msg.sender, 0);
    }

    //-------- REDEEM FUNCTIONS WITH DEFAULT VALUES --------\\

    function redeem(
        IYearn4626 vault,
        uint256 shares,
        address to
    ) external payable returns (uint256 amountOut) {
        return redeem(vault, shares, to, 0);
    }

    function redeem(
        IYearn4626 vault, 
        uint256 shares
    ) external payable returns (uint256 amountOut) {
        return redeem(vault, shares, msg.sender, 0);
    }

    function redeem(
        IYearn4626 vault
    ) external payable returns (uint256 amountOut) {
        uint256 shares = vault.balanceOf(msg.sender);
        return redeem(vault, shares, msg.sender, 0);
    }

    /// @inheritdoc IYearn4626Router
    function migrate(
        IYearn4626 fromVault,
        IYearn4626 toVault,
        uint256 shares,
        address to,
        uint256 minSharesOut
    ) public payable override returns (uint256 sharesOut) {
        // amount out passes through so only one slippage check is needed
        uint256 amount = redeem(fromVault, shares, address(this), 0);
        return deposit(toVault, amount, to, minSharesOut);
    }

    //-------- MIGRATE FUNCTIONS WITH DEFAULT VALUES --------\\

    function migrate(
        IYearn4626 fromVault,
        IYearn4626 toVault,
        uint256 shares,
        address to
    ) external payable returns (uint256 sharesOut) {
        return migrate(fromVault, toVault, shares, to, 0);
    }

    function migrate(
        IYearn4626 fromVault,
        IYearn4626 toVault,
        uint256 shares
    ) external payable returns (uint256 sharesOut) {
        return migrate(fromVault, toVault, shares, msg.sender, 0);
    }

    function migrate(
        IYearn4626 fromVault, 
        IYearn4626 toVault
    ) external payable returns (uint256 sharesOut) {
        uint256 shares = fromVault.balanceOf(msg.sender);
        return migrate(fromVault, toVault, shares, msg.sender, 0);
    }

    /// @inheritdoc IYearn4626Router
    function migrateV2(
        IYearnV2 fromVault,
        IYearn4626 toVault,
        uint256 shares,
        address to,
        uint256 minSharesOut
    ) public payable override returns (uint256 sharesOut) {
        // amount out passes through so only one slippage check is needed
        uint256 redeemed = fromVault.withdraw(shares, address(this));
        return deposit(toVault, redeemed, to, minSharesOut);
    }

    //-------- MIGRATEV2 FUNCTIONS WITH DEFAULT VALUES --------\\

    function migrateV2(
        IYearnV2 fromVault,
        IYearn4626 toVault,
        uint256 shares,
        address to
    ) external payable returns (uint256 sharesOut) {
        return migrateV2(fromVault, toVault, shares, to, 0);
    }

    function migrateV2(
        IYearnV2 fromVault,
        IYearn4626 toVault,
        uint256 shares
    ) external payable returns (uint256 sharesOut) {
        return migrateV2(fromVault, toVault, shares, msg.sender, 0);
    }

    function migrateV2(
        IYearnV2 fromVault,
        IYearn4626 toVault
    ) external payable returns (uint256 sharesOut) {
        uint256 shares = fromVault.balanceOf(msg.sender);
        return migrateV2(fromVault, toVault, shares, msg.sender, 0);
    }

    /// @inheritdoc IYearn4626Router
    function withdrawToDeposit(
        IYearn4626 fromVault,
        IYearn4626 toVault,
        uint256 amount,
        address to,
        uint256 maxSharesIn,
        uint256 minSharesOut
    ) external payable override returns (uint256 sharesOut) {
        withdraw(fromVault, amount, address(this), maxSharesIn);
        return deposit(toVault, amount, to, minSharesOut);
    }
}
