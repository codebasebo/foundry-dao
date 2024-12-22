// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";

contract MyGovernorTest is Test {
    MyGovernor governor;
    TimeLock timelock;
    Box box;
    GovToken token;

    address public USER = makeAddr("user");
    uint256 public constant VALUE = 100 ether;

    uint256 public constant MIN_DELAY = 3600; // 1 hour
    uint256 public constant VOTING_DELAY = 1;
    uint256 public constant VOTING_PERIOD = 50400; // About a week

    address[] public proposers;
    address[] public executors;

    uint256[] values;
    bytes[] calldatas;
    address[] targets;

    function setUp() public {
        // Deploy token and delegate
        token = new GovToken(USER);
        vm.startPrank(USER); // Start prankster here
        token.mint(USER, VALUE);
        token.delegate(USER);
        vm.stopPrank(); // Stop prankster here

        // Deploy governance contracts
        timelock = new TimeLock(MIN_DELAY, proposers, executors);

        governor = new MyGovernor(token, timelock);

        // Setup roles
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        vm.stopPrank();

        // Grant and revoke roles
        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, USER);

        // Deploy box with timelock as owner
        box = new Box(address(timelock));
    }

    function testCantUpdateBoxWithoutGovernor() public {
        vm.expectRevert();
        box.store(100);
    }

    function testGovernanceUpdateBox() public {
        uint256 newValue = 100;
        string memory description = "Update box value";
        bytes memory data = abi.encodeWithSignature("store(uint256)", newValue);

        values.push(0);
        calldatas.push(data);
        targets.push(address(box));

        uint256 proposeId = governor.propose(targets, values, calldatas, description);
        console2.log("Proposal ID:", proposeId);
        console2.log(msg.sender);
        console2.log("Proposal State:", uint256(governor.state(proposeId)));
        // governor.proposalSnapshot(proposalId)
        // governor.proposalDeadline(proposalId)

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console2.log("Proposal State:", uint256(governor.state(proposeId)));

        string memory reason = "Proposal not passed";

        uint8 vote = 1;
        vm.prank(USER);
        governor.castVoteWithReason(proposeId, vote, reason);
        console2.log(USER, "voted", vote);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console2.log("Proposal State:", uint256(governor.state(proposeId)));
    }
}
