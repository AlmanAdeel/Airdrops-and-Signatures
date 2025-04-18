//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712{
    using SafeERC20 for IERC20; 
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();
    mapping(address => bool) private s_claimed;
    string constant private MESSAGE_TYPEHASH = "AirDrop(address account,uint256 amount)";
    bytes32 private immutable s_merkleRoot;
    IERC20 private immutable s_AirdropToken;

    struct AirDrop{
        address account;
        uint256 amount;
    }

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        s_merkleRoot = merkleRoot;
        s_AirdropToken = airdropToken;
    }

    function claim(address account,uint256 amount,bytes32[] calldata merkleProof,uint8 v,bytes32 r,bytes32 s) external {
        bytes32 leaf = keccak256(abi.encode(keccak256(abi.encode(account, amount))));
        if(s_claimed[account] == true){
            revert MerkleAirdrop__AlreadyClaimed();
        }
        if(!_isValidSignature(account,getMessage(account,amount),v,r,s)){
            revert MerkleAirdrop__InvalidSignature();
        }
        s_claimed[account] = true;
        if(!MerkleProof.verify(merkleProof, s_merkleRoot, leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        s_AirdropToken.safeTransfer(account, amount);
    }

    function getMessage(address account,uint256 amount) public view returns (bytes32){
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH,account,amount)));
    }

    function getMerkleRoot() external view returns (bytes32) {
        return s_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return s_AirdropToken;
    }

    function _isValidSignature(address account,bytes32 digest,uint8 v,bytes32 r,bytes32 s) internal pure returns (bool){
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return account == actualSigner;
    }

}