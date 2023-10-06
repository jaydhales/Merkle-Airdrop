// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "solmate/src/utils/MerkleProofLib.sol";

// contract Airdrop is ERC20("Airdrop", "AdNft") {

//     struct Drops {
//         string title;
//         bytes32 merkleRoot;
//         bool active;
//         uint timeStarted;
//         uint endTime;
//     }

//     struct WinnerData {
//         address winner;
//         bytes32 hash;
//         bytes32[] winnerProof;
//     }

//     mapping(uint256 => Drops) public drops;
//     mapping(address => mapping(uint256 => bool)) public claimed;

//     uint _dropsCounter;

//     function createAirdrop(string memory _title, uint _duration) public {
//         Drops storage d = drops[_dropsCounter];
//         d.title = _title;
//         d.timeStarted = block.timestamp;
//         d.endTime = block.timestamp + _duration;
//         _dropsCounter++;
//     }

//     function activateAirDrop(uint _id, bytes32 _merkleRoot) public {
//         require(_id < _dropsCounter, "Invalid ID");
//         drops[_id].merkleRoot = _merkleRoot;
//         drops[_id].active = true;
//     }

//     function claim(WinnerData calldata _winner, uint _id, bytes32 leaf ) public {
//         require(_id < _dropsCounter, "Invalid ID");
//         Drops memory d = drops[_dropsCounter];

//         bytes32 node = keccak256(
//             abi.encodePacked(_winner.winner, _winner.hash, _id)
//         );

//         require(MerkleProofLib.verify(_winner.winnerProof, d.merkleRoot, leaf), "Invalid User");
//         claimed[_winner.winner][_id] = true;
//         _mint(_winner.winner, 10 ether);
//     }

// }

contract Airdrop is ERC20 {
    bytes32 merkleRoot;

    constructor(bytes32 _root) ERC20("Merkle", "MKL") {
        merkleRoot = _root;
    }

    mapping(address => bool) hasClaimed;
    event AddressClaim(address account, uint256 amount);

    function claim(
        bytes32[] calldata _merkleProof,
        address claimer,
        uint256 _amount
    ) external returns (bool success) {
        require(!hasClaimed[claimer], "You have already claimed!");
        bytes32 node = keccak256(abi.encodePacked(claimer, _amount));
        success = MerkleProofLib.verify(_merkleProof, merkleRoot, node);
        require(success, "MerkleDistributor: Invalid proof.");
        hasClaimed[claimer] = true;
        _mint(claimer, _amount);
        emit AddressClaim(claimer, _amount);
    }
}
