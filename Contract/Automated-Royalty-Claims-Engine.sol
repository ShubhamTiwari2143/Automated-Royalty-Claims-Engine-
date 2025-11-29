// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Automated Royalty Claims Engine
 * @dev A smart contract allowing creators to register works, record earnings, 
 *      and automatically claim royalty payouts.
 */
contract AutomatedRoyaltyClaimsEngine {
    
    struct Work {
        address creator;
        uint256 totalEarnings;
        uint256 claimedAmount;
        bool exists;
    }

    mapping(uint256 => Work) public works;

    event WorkRegistered(uint256 indexed workId, address indexed creator);
    event EarningsRecorded(uint256 indexed workId, uint256 amount);
    event RoyaltyClaimed(uint256 indexed workId, address indexed creator, uint256 amount);

    /**
     * @dev Register a new creative work.
     * @param workId Unique ID for the work.
     */
    function registerWork(uint256 workId) external {
        require(!works[workId].exists, "Work already registered");

        works[workId] = Work({
            creator: msg.sender,
            totalEarnings: 0,
            claimedAmount: 0,
            exists: true
        });

        emit WorkRegistered(workId, msg.sender);
    }

    /**
     * @dev Record new earnings for a registered work.
     * @param workId ID of the work.
     */
    function recordEarnings(uint256 workId) external payable {
        require(works[workId].exists, "Work not registered");
        require(msg.value > 0, "No funds sent");

        works[workId].totalEarnings += msg.value;
        
        emit EarningsRecorded(workId, msg.value);
    }

    /**
     * @dev Allows the creator to claim unclaimed royalties.
     * @param workId ID of the work.
     */
    function claimRoyalties(uint256 workId) external {
        Work storage work = works[workId];
        require(work.exists, "Work not registered");
        require(work.creator == msg.sender, "Unauthorized");

        uint256 claimable = work.totalEarnings - work.claimedAmount;
        require(claimable > 0, "Nothing to claim");

        work.claimedAmount += claimable;
        payable(msg.sender).transfer(claimable);

        emit RoyaltyClaimed(workId, msg.sender, claimable);
    }
}

