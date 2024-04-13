// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {MerkleDistro} from "../src/MerkleDistro.sol";

contract MerkleDistroTest is Test {
    using stdJson for string;
    MerkleDistro public merkle;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint amount;
        uint id;
    }
    Result public result;
    User public user;
    bytes32 root =
        0xf4c1f741983e21d1845b375881245f4aef7dfd433357776232ce54f1a175052a;
    address user1 = 0x39c580605BE2d7554BCF0C1D3278a70fD04e8550;

    function setUp() public {
        merkle = new MerkleDistro(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree2.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data2.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".address")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".amount")
        );

        user.id = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".id")
        );
        
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = merkle.claim(user.user, user.id, user.amount, result.proof);
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        merkle.claim(user.user, user.id, user.amount, result.proof);
        vm.expectRevert("already claimed");
        merkle.claim(user.user, user.id, user.amount, result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        merkle.claim(user.user, user.id, user.amount, fakeProofleaveitleaveit);
    }
}
