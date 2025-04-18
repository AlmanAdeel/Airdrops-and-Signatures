//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract Interaction is Script {
    address ClaimAddress =  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 AMOUNT_TO_CLAIM =  25 * 1e18;
    bytes32 proof1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proof1,proof2];
    bytes Signature = hex"";// you will have to put a signature in here when you sign the wallet;


    function ClaimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(Signature);
        MerkleAirdrop(airdrop).claim(ClaimAddress,AMOUNT_TO_CLAIM,PROOF,v,r,s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public returns(uint8 v,bytes32 r, bytes32 s){
        require(sig.length == 65,"Invalid signature length");
        assembly{
            r := mload(add(sig,32))
            s := mload(add(sig,64))
            v := byte(0,mload(add(sig,96)))
        }
    }



    function run() external {
        address mostrecentlydeployedcontract = DevOpsTools.get_most_recent_deployment("MerkleAirdrop",block.chainid);
        ClaimAirdrop(mostrecentlydeployedcontract);
    }
}