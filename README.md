# CatToken Airdrop – Merkle Tree-Based Token Distribution

## Overview

This repo contains two key contracts:
1. `CatToken.sol` – A custom ERC-20 token contract
2. `MerkleAirdrop.sol` – A secure, gas-efficient Merkle tree-based airdrop distribution contract

Designed for real-world use cases where **mass token distribution** needs to be:
- Tamper-proof
- On-chain verifiable
- Gas optimized
- Resistant to double-claims

---

## Contract Breakdown

### `CatToken.sol`
- A simple ERC-20 token named `CatToken` 🐾
- Built using OpenZeppelin standards
- Used as the token to be distributed via the Merkle airdrop contract

---

### `MerkleAirdrop.sol`
- Accepts a pre-generated **Merkle root** representing claimable address+amount pairs
- Users must provide:
  - Their address
  - The amount they're eligible to claim
  - A valid Merkle proof
- Includes double-claim prevention via a `claimed` mapping
- Uses `keccak256` hashing to validate leaf proofs

---

##  How It Works

1. You generate a Merkle tree off-chain (e.g., using `merkletreejs`)
2. Deploy `CatToken` and mint the airdrop supply to the `MerkleAirdrop` contract
3. Set the Merkle root during deployment (or via admin)
4. Users claim tokens by providing valid Merkle proofs
5. Contract verifies the proof → transfers tokens → marks address as claimed

---

## Why Merkle Trees?

- Saves gas by storing a single hash instead of all eligible addresses
- Scales to **thousands of users** with low on-chain storage
- Secure and industry-proven (used by Uniswap, Optimism, etc.)

---

## Real-World Use Cases

- Community token distributions  
- Retroactive rewards  
- Early supporter drops  
- Partner/investor distributions with cryptographic proof

---

## Tech Stack

- **Solidity**
- **OpenZeppelin Contracts**
- **Merkle Proofs**
- Optional: `merkletreejs` for off-chain tree generation

---

## Sample Claim Process

```solidity
merkleAirdrop.claim(
    userAddress,
    eligibleAmount,
    proofArray
);
