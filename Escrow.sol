// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Escrow is ReentrancyGuard {
    struct EscrowDetails {
        address sender;
        address recipient;
        uint256 amount;
        uint256 deadline;
        address token; // Address(0) for ETH
        bool claimed;
    }

    mapping(uint256 => EscrowDetails) public escrows;
    uint256 public escrowCounter;

    event FundsEscrowed(
        uint256 indexed escrowId,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        address token,
        uint256 deadline
    );
    event FundsClaimed(uint256 indexed escrowId, address indexed recipient);
    event FundsRefunded(uint256 indexed escrowId, address indexed sender);

    /**
     * @notice Create a new escrow
     * @param recipient The recipient address for the escrowed funds
     * @param amount The amount to escrow
     * @param token The address of the token to escrow (address(0) for ETH)
     */
    function createEscrow(address recipient, uint256 amount, address token)
        external
        payable
    {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than zero");

        if (token == address(0)) {
            // ETH escrow
            require(msg.value == amount, "Incorrect ETH sent");
        } else {
            // ERC20 escrow
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }

        uint256 deadline = block.timestamp + 30 days;

        escrows[escrowCounter] = EscrowDetails({
            sender: msg.sender,
            recipient: recipient,
            amount: amount,
            deadline: deadline,
            token: token,
            claimed: false
        });

        emit FundsEscrowed(
            escrowCounter,
            msg.sender,
            recipient,
            amount,
            token,
            deadline
        );

        escrowCounter++;
    }

    /**
     * @notice Claim escrowed funds
     * @param escrowId The ID of the escrow to claim
     */
    function claimFunds(uint256 escrowId) external nonReentrant {
        EscrowDetails storage escrow = escrows[escrowId];
        require(msg.sender == escrow.recipient, "Not the recipient");
        require(block.timestamp <= escrow.deadline, "Deadline passed");
        require(!escrow.claimed, "Already claimed");

        escrow.claimed = true;

        if (escrow.token == address(0)) {
            // Send ETH
            payable(msg.sender).transfer(escrow.amount);
        } else {
            // Send ERC20 tokens
            IERC20(escrow.token).transfer(msg.sender, escrow.amount);
        }

        emit FundsClaimed(escrowId, msg.sender);
    }

    /**
     * @notice Refund escrowed funds back to the sender
     * @param escrowId The ID of the escrow to refund
     */
    function refundFunds(uint256 escrowId) external nonReentrant {
        EscrowDetails storage escrow = escrows[escrowId];
        require(msg.sender == escrow.sender, "Not the sender");
        require(block.timestamp > escrow.deadline, "Deadline not passed");
        require(!escrow.claimed, "Already claimed");

        escrow.claimed = true;

        if (escrow.token == address(0)) {
            // Refund ETH
            payable(msg.sender).transfer(escrow.amount);
        } else {
            // Refund ERC20 tokens
            IERC20(escrow.token).transfer(msg.sender, escrow.amount);
        }

        emit FundsRefunded(escrowId, msg.sender);
    }

    /**
     * @notice Get details of an escrow
     * @param escrowId The ID of the escrow to query
     * @return EscrowDetails The details of the escrow
     */
    function getEscrowDetails(uint256 escrowId)
        external
        view
        returns (EscrowDetails memory)
    {
        return escrows[escrowId];
    }
}
