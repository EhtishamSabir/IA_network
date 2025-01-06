# Escrow Smart Contract

## Overview

This project implements an Ethereum-based escrow contract in Solidity, designed to support both ETH and ERC20 token escrows. It allows senders to lock funds for recipients under specific conditions, ensuring security, modularity, and gas efficiency.

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
- **Remix IDE**: You will be using [Remix IDE](https://remix.ethereum.org/) for testing and deploying the contract. Remix is a browser-based Solidity IDE that makes it easy to deploy and interact with Ethereum smart contracts.

1. Open [Remix IDE](https://remix.ethereum.org/).
2. Set up a new project or import the files directly into Remix.
3. Ensure you have the required compiler version (0.8.19) in Remix's Solidity compiler settings.

### Deploying the Contracts

1. **Escrow Contract**:
   - Compile the `Escrow.sol` contract in Remix.
   - After compiling, go to the **Deploy & Run Transactions** tab.
   - Choose the environment (e.g., JavaScript VM for testing or Injected Web3 for a test network like Rinkeby).
   - Deploy the contract.

2. **Mock ERC20 Contract**:
   - Compile and deploy the `MockERC20.sol` contract in Remix, similar to the steps above.
   - After deploying, you'll be able to interact with the token contract and allocate tokens to the sender's address.

### Testing the Contracts

You can test the contract functionality directly in Remix. Below are the steps to test various scenarios:

1. **ETH Escrow**:
   - Call the `createEscrow` function, providing the recipient address and amount of ETH to be escrowed.
   - Use the `claimFunds` function from the recipient's address to claim the escrowed ETH.
   - If the recipient does not claim the funds before the deadline, the sender can call `refundFunds`.

2. **ERC20 Escrow**:
   - Call the `createEscrow` function with the recipient address and amount of ERC20 tokens.
   - Make sure the sender has approved the contract to transfer tokens beforehand.
   - The recipient can call `claimFunds` to receive the tokens.
   - If the recipient does not claim the tokens before the deadline, the sender can call `refundFunds`.

### Example Use Case in Remix:

1. **Creating an Escrow (ETH)**:
   - In Remix, under the **Deploy & Run Transactions** tab, you can select the deployed `Escrow` contract.
   - Call the `createEscrow` function, passing in the recipient’s address, the amount of ETH, and using `msg.value` (send ETH).
   
   Example:
   ```solidity
   createEscrow(address(0x123...), 10 ether, address(0)); // Sends 10 ETH to address(0x123...)
