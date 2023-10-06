// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Airdrop} from "../src/Airdrop.sol";
import {Helper, Result, Users} from "./Helper.sol";

contract AirdropTest is Helper {
    Airdrop public airdrop;
    event AddressClaim(address account, uint256 amount);

    bytes32 root =
        0xc87618c6c49eb4b0825fe2b7323eb2d0a34647d57571acbc0eed60825db81123;

    Result result;
    Users user1;

    function setUp() public {
        airdrop = new Airdrop(root);
        (user1, result) = _getObject("0");
    }

    function testUserCantClaimTwice() public {
        _claim(result.proof, user1.user, user1.amount);
        vm.expectRevert("You have already claimed!");
        _claim(result.proof, user1.user, user1.amount);
    }

    function testIncorrectProof() public {
        (, Result memory _r) = _getObject("2");
        vm.expectRevert("Invalid Verification");
        _claim(_r.proof, user1.user, user1.amount);
    }

    function testIncorrectAccount() public {
        vm.expectRevert("Invalid Verification");
        _claim(result.proof, vm.addr(12), user1.amount);
    }

    function testIncorrectAmount() public {
        vm.expectRevert("Invalid Verification");
        _claim(result.proof, user1.user, 450);
    }

    function testClaimSuccessful() public {
        _claim(result.proof, user1.user, user1.amount);
        assertTrue(airdrop.hasClaimed(user1.user));
    }

    function testMintExpectedAmmount() public {
        uint balanceBefore = airdrop.balanceOf(user1.user);
        _claim(result.proof, user1.user, user1.amount);
        uint balanceAfter = airdrop.balanceOf(user1.user);
        assertEq(balanceAfter - balanceBefore, user1.amount);
    }

    function testEventEmittedAfterClaim() public {
        vm.expectEmit(true, true, false, false);
        emit AddressClaim(user1.user, user1.amount);
        _claim(result.proof, user1.user, user1.amount);
    }

    function _claim(
        bytes32[] memory _proof,
        address _user,
        uint _amount
    ) internal returns (bool success) {
        success = airdrop.claim(_proof, _user, _amount);
    }
}
