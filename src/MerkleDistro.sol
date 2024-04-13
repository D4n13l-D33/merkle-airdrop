// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MerkleDistro is ERC1155 {
    bytes32 root;

    constructor(bytes32 _root) ERC1155("") {
        root = _root;
    }

    mapping(address => bool) hasClaimed;

    event ClaimedAirdrop(address indexed claimer, uint256 indexed id, uint256 indexed amount);

    function claim(
        address account,
        uint256 id,
        uint256 amount,
        bytes32[] calldata _proof
    ) public returns (bool success_) {
        bytes memory data = abi.encode("");
        require(!hasClaimed[account]);
        bytes32 leaf = keccak256(abi.encodePacked(account, id, amount));
        bool verify = MerkleProof.verify(_proof, root, leaf);
        require(verify, "Not recognized!");
        hasClaimed[account] = true;
        _mint(account, id, amount, data);
        success_ = true;

        emit ClaimedAirdrop(account, id, amount);
    }
}
