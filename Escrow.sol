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

        // Verify escrow details
        (address escrowSender, address escrowRecipient, uint256 escrowAmount, uint256 escrowDeadline, address escrowToken, bool escrowClaimed) = escrow.getEscrowDetails(escrowId);
        assert(escrowSender == sender);
        assert(escrowRecipient == recipient);
        assert(escrowAmount == amount);
        assert(escrowToken == address(0));
        assert(escrowClaimed == false);
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
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(escrowId);
        assert(escrowClaimed == true);
    }

    // Test refunding ETH escrow funds after the deadline
    function testRefundEscrowETH() public {
        uint256 amount = 10 ether;

        // Create escrow
        escrow.createEscrow{value: amount}(recipient, amount, address(0));

        // Store the last escrowId created
        escrowId = escrow.escrowCounter() - 1;

        // Advance time beyond the deadline (simulate using `vm.warp()` if using Foundry or Hardhat)
        // block.timestamp = block.timestamp + 31 days; // This won't work directly in Remix

        // Refund funds (You'd need to simulate time in a testing framework like Foundry or Hardhat)
        escrow.refundFunds(escrowId);

        // Verify sender balance (should have received the funds back)
        assert(sender.balance == 100 ether);

        // Verify escrow marked as claimed
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(escrowId);
        assert(escrowClaimed == true);
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
        (address escrowSender, address escrowRecipient, uint256 escrowAmount, uint256 escrowDeadline, address escrowToken, bool escrowClaimed) = escrow.getEscrowDetails(escrowId);
        assert(escrowSender == sender);
        assert(escrowRecipient == recipient);
        assert(escrowAmount == amount);
        assert(escrowToken == address(token));
        assert(escrowClaimed == false);
    }

    // Test claiming ERC20 escrow funds
    function testClaimEscrowERC20() public {
        uint256 amount = 50 ether;

        // Approve and create escrow
        token.approve(address(escrow), amount);
        escrow.createEscrow(recipient, amount, address(token));

        // Store the last escrowId created
        escrowId = escrow.escrowCounter() - 1;

        // Claim funds
        escrow.claimFunds(escrowId);

        // Verify recipient token balance
        assert(token.balanceOf(recipient) == amount);

        // Verify escrow marked as claimed
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(escrowId);
        assert(escrowClaimed == true);
    }

    // Test refunding ERC20 escrow funds after the deadline
    function testRefundEscrowERC20() public {
        uint256 amount = 50 ether;

        // Approve and create escrow
        token.approve(address(escrow), amount);
        escrow.createEscrow(recipient, amount, address(token));

        // Store the last escrowId created
        escrowId = escrow.escrowCounter() - 1;

        // Advance time beyond the deadline (simulate using `vm.warp()` if using Foundry or Hardhat)
        // block.timestamp = block.timestamp + 31 days; // This won't work directly in Remix

        // Refund funds (You'd need to simulate time in a testing framework like Foundry or Hardhat)
        escrow.refundFunds(escrowId);

        // Verify sender token balance (should have received the tokens back)
        assert(token.balanceOf(sender) == amount);

        // Verify escrow marked as claimed
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(escrowId);
        assert(escrowClaimed == true);
    }
}
