//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {CatToken} from "src/CatToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MarklerRoot is Test {
    CatToken public cattoken;
    MerkleAirdrop public merkleAirdrop;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    bytes32 public proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proof1, proof2];
    address public user;
    address public demoUser;
    uint256 public privUser;

    function setUp() public {
        cattoken = new CatToken();
        merkleAirdrop = new MerkleAirdrop(ROOT, cattoken);
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (merkleAirdrop, cattoken) = deployer.deploymerkleAirdrop();
        address owner = cattoken.owner();
        vm.startPrank(owner);
        cattoken.mint(owner, AMOUNT_TO_CLAIM * 4);
        cattoken.transfer(address(merkleAirdrop), AMOUNT_TO_CLAIM * 4);
        vm.stopPrank();

        (user, privUser) = makeAddrAndKey("user");
        demoUser = makeAddr("demoUser");
    }

    function testCanClaim() public {
        uint256 startingBalance = cattoken.balanceOf(user);
        bytes32 digest = merkleAirdrop.getMessage(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privUser, digest);

        vm.prank(demoUser);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();
        uint256 expectedBalance = cattoken.balanceOf(user);
        assertEq(expectedBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
