// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

struct Result {
    bytes32 leaf;
    bytes32[] proof;
}
struct Users {
    address user;
    uint amount;
}

contract Helper is Test {
    using stdJson for string;

    function _getObject(
        string memory index
    ) internal view returns (Users memory _user, Result memory _result) {
        string memory _root = vm.projectRoot();
        string memory merklePath = string.concat(_root, "/merkle_tree.json");
        string memory dataPath = string.concat(_root, "/address_data.json");
        string memory merkleJson = vm.readFile(merklePath);
        string memory dataJson = vm.readFile(dataPath);

        _user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", index, ".address")
        );

        _user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", index, ".amount")
        );

        bytes memory res = merkleJson.parseRaw(
            string.concat(".", vm.toString(_user.user))
        );

        _result = abi.decode(res, (Result));
    }
}
