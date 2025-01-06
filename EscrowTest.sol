// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Escrow.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MKT") {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract EscrowTest is Test {
    Escrow public escrow;
    MockERC20 public token;

    address public sender = address(1);
    address public recipient = address(2);

    function setUp() public {
        // Deploy Escrow and MockERC20 contracts
        escrow = new Escrow();
        token = new MockERC20();

        // Allocate ETH to sender
        vm.deal(sender, 100 ether);

        // Allocate tokens to sender
        vm.prank(sender);
        token.transfer(sender, 500 ether);
    }

    function testCreateEscrowETH() public {
        uint256 amount = 10 ether;

        vm.prank(sender);
        escrow.createEscrow{value: amount}(recipient, amount, address(0));

        // Verify escrow details
        (address escrowSender, address escrowRecipient, uint256 escrowAmount, uint256 escrowDeadline, address escrowToken, bool escrowClaimed) = escrow.getEscrowDetails(0);
        assertEq(escrowSender, sender);
        assertEq(escrowRecipient, recipient);
        assertEq(escrowAmount, amount);
        assertEq(escrowToken, address(0));
        assertFalse(escrowClaimed);
    }

    function testClaimEscrowETH() public {
        uint256 amount = 10 ether;

        // Create escrow
        vm.prank(sender);
        escrow.createEscrow{value: amount}(recipient, amount, address(0));

        // Claim funds
        vm.prank(recipient);
        escrow.claimFunds(0);

        // Verify recipient balance
        assertEq(recipient.balance, amount);

        // Verify escrow marked as claimed
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(0);
        assertTrue(escrowClaimed);
    }

    function testRefundEscrowETH() public {
        uint256 amount = 10 ether;

        // Create escrow
        vm.prank(sender);
        escrow.createEscrow{value: amount}(recipient, amount, address(0));

        // Advance time beyond deadline
        vm.warp(block.timestamp + 31 days);

        // Refund funds
        vm.prank(sender);
        escrow.refundFunds(0);

        // Verify sender balance
        assertEq(sender.balance, 100 ether);

        // Verify escrow marked as claimed
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(0);
        assertTrue(escrowClaimed);
    }

    function testCreateEscrowERC20() public {
        uint256 amount = 50 ether;

        // Approve and create escrow
        vm.prank(sender);
        token.approve(address(escrow), amount);

        vm.prank(sender);
        escrow.createEscrow(recipient, amount, address(token));

        // Verify escrow details
        (address escrowSender, address escrowRecipient, uint256 escrowAmount, uint256 escrowDeadline, address escrowToken, bool escrowClaimed) = escrow.getEscrowDetails(0);
        assertEq(escrowSender, sender);
        assertEq(escrowRecipient, recipient);
        assertEq(escrowAmount, amount);
        assertEq(escrowToken, address(token));
        assertFalse(escrowClaimed);
    }

    function testClaimEscrowERC20() public {
        uint256 amount = 50 ether;

        // Approve and create escrow
        vm.prank(sender);
        token.approve(address(escrow), amount);

        vm.prank(sender);
        escrow.createEscrow(recipient, amount, address(token));

        // Claim funds
        vm.prank(recipient);
        escrow.claimFunds(0);

        // Verify recipient token balance
        assertEq(token.balanceOf(recipient), amount);

        // Verify escrow marked as claimed
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(0);
        assertTrue(escrowClaimed);
    }

    function testRefundEscrowERC20() public {
        uint256 amount = 50 ether;

        // Approve and create escrow
        vm.prank(sender);
        token.approve(address(escrow), amount);

        vm.prank(sender);
        escrow.createEscrow(recipient, amount, address(token));

        // Advance time beyond deadline
        vm.warp(block.timestamp + 31 days);

        // Refund funds
        vm.prank(sender);
        escrow.refundFunds(0);

        // Verify sender token balance
        assertEq(token.balanceOf(sender), amount);

        // Verify escrow marked as claimed
        (, , , , , bool escrowClaimed) = escrow.getEscrowDetails(0);
        assertTrue(escrowClaimed);
    }
}
