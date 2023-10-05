// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";
import {Airdrop} from "../src/Airdrop.sol";

contract CounterTest is Test {
    Airdrop public airdrop;
    using stdJson for string;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }
    bytes32 root =
        0xc87618c6c49eb4b0825fe2b7323eb2d0a34647d57571acbc0eed60825db81123;

    address user1 = 0x001Daa61Eaa241A8D89607194FC3b1184dcB9B4C;
    uint user1Amt = 45000000000000;

    Result public r;

    function setUp() public {
        airdrop = new Airdrop(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");
        string memory json = vm.readFile(path);

        bytes memory res = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );

        r = abi.decode(res, (Result));
    }

    function testClaim() public {
        bool success = airdrop.claim(r.proof, user1, user1Amt);

        assertEq(airdrop.balanceOf(user1), user1Amt);

        assertTrue(success);
    }
}
