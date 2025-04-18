//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {CatToken} from "src/CatToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script{
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToClaim = (25 * 1e18) * 4; 


    function run() public {
        deploymerkleAirdrop();
    }

    function deploymerkleAirdrop() public returns(MerkleAirdrop,CatToken){
        vm.startBroadcast();
        CatToken cattoken = new CatToken();
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, cattoken);
        cattoken.mint(cattoken.owner(),s_amountToClaim);
        cattoken.transfer(address(merkleAirdrop),s_amountToClaim);
        vm.stopBroadcast();
        return(merkleAirdrop,cattoken);

}
}