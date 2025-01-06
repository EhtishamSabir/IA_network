// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Escrow.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MKT") {
        _mint(msg.sender, 1_000_000 ether); // Mint initial tokens
    }
}

contract EscrowTest {
    Escrow public escrow;
    MockERC20 public token;

    address public sender = address(1);
    address public recipient = address(2);
    uint256 public escrowId;

    // Set up the environment
    function setUp() public {
        // Deploy Escrow and MockERC20 contracts
        escrow = new Escrow();
        token = new MockERC20();

        // Allocate ETH to sender (simulate in test environment)
        payable(sender).transfer(100 ether);

        // Allocate tokens to sender
        token.transfer(sender, 500 ether);
    }

    // Test ETH escrow creation
    function testCreateEscrowETH() public {
        uint256 amount = 10 ether;

        // Create escrow (simulate transaction)
        payable(sender).transfer(amount);
        escrow.createEscrow{value: amount}(recipient, amount, address(0));

        // Store the last escrowId created
        escrowId = escrow.escrowCounter() - 1;

        // Fetch the escrow details
        Escrow.EscrowDetails memory escrowDetails = escrow.getEscrowDetails(escrowId);

        // Verify escrow details
        assert(escrowDetails.sender == sender);
        assert(escrowDetails.recipient == recipient);
        assert(escrowDetails.amount == amount);
        assert(escrowDetails.token == address(0));
        assert(escrowDetails.claimed == false);
    }

    // Test claiming ETH escrow funds
    function testClaimEscrowETH() public {
        uint256 amount = 10 ether;

        // Create escrow
        escrow.createEscrow{value: amount}(recipient, amount, address(0));

        // Store the last escrowId created
        escrowId = escrow.escrowCounter() - 1;

        // Claim funds
        escrow.claimFunds(escrowId);

        // Verify recipient balance
        assert(recipient.balance == amount);

        // Verify escrow marked as claimed
        Escrow.EscrowDetails memory escrowDetails = escrow.getEscrowDetails(escrowId);
        assert(escrowDetails.claimed == true);
    }

    // Test ERC20 escrow creation
    function testCreateEscrowERC20() public {
        uint256 amount = 50 ether;

        // Approve and create escrow
        token.approve(address(escrow), amount);
        escrow.createEscrow(recipient, amount, address(token));

        // Store the last escrowId created
        escrowId = escrow.escrowCounter() - 1;

        // Verify escrow details
        Escrow.EscrowDetails memory escrowDetails = escrow.getEscrowDetails(escrowId);
        assert(escrowDetails.sender == sender);
        assert(escrowDetails.recipient == recipient);
        assert(escrowDetails.amount == amount);
        assert(escrowDetails.token == address(token));
        assert(escrowDetails.claimed == false);
    }
}
