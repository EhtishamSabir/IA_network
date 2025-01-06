# Escrow Smart Contract

## Overview
This project implements an Ethereum-based escrow contract in Solidity with Foundry for testing. The contract supports both ETH and ERC20 escrow functionality, allowing senders to lock funds for recipients under specific conditions. It ensures security, modularity, and gas efficiency.

## Features

### ETH Escrow
- Funds can be sent in ETH using the `createEscrow` function with `msg.value`.
- Recipients can claim funds within 30 days.
- Unclaimed ETH is automatically refunded to the sender after the deadline.

### ERC20 Escrow
- Supports ERC20 tokens by specifying a token address in the `createEscrow` function.
- Requires senders to approve the contract to transfer tokens beforehand.
- Tokens are returned to the sender if unclaimed after the deadline.

### Security
- **Reentrancy Protection**: Uses OpenZeppelin's `ReentrancyGuard` to prevent reentrancy attacks.
- **Authorized Actions**: Only the designated recipient or sender can interact with the escrow.

### Gas Optimization
- Reduces unnecessary state changes or writes to minimize gas costs.
- Efficient data structures like mappings are used for escrow management.

## Setup Instructions

### Prerequisites
- Install [Foundry](https://book.getfoundry.sh/):  
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
