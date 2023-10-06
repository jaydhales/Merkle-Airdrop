// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "solmate/src/utils/MerkleProofLib.sol";

contract Airdrop is ERC20("Merkle", "MKL") {
    bytes32 merkleRoot;

    constructor(bytes32 _root) {
        merkleRoot = _root;
    }

    mapping(address => bool) public hasClaimed;
    event AddressClaim(address account, uint256 amount);

    function claim(
        bytes32[] calldata _merkleProof,
        address claimer,
        uint256 _amount
    ) external returns (bool success) {
        require(!hasClaimed[claimer], "You have already claimed!");

        bytes32 node = keccak256(abi.encodePacked(claimer, _amount));

        success = MerkleProofLib.verify(_merkleProof, merkleRoot, node);
        require(success, "Invalid Verification");
        hasClaimed[claimer] = true;
        _mint(claimer, _amount);
        emit AddressClaim(claimer, _amount);
    }
}
