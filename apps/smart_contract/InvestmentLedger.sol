// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * VentureLink Investment Ledger
 * Student project - Sepolia Testnet
 *
 * HOW TO DEPLOY (Free, 5 minutes):
 * 1. Go to https://remix.ethereum.org
 * 2. Create new file, paste this code
 * 3. Compile with Solidity 0.8.19
 * 4. Deploy to Sepolia testnet using MetaMask
 * 5. Get free Sepolia ETH from https://sepoliafaucet.com
 * 6. Copy the deployed contract address into blockchain_service.dart
 */
contract InvestmentLedger {

    struct Investment {
        string investorId;
        string startupId;
        string roundId;
        uint256 amountUsd;   // stored in cents (multiply by 100)
        uint256 timestamp;
        bool exists;
    }

    // investmentId => Investment record
    mapping(string => Investment) private investments;

    // Platform admin address (set on deploy)
    address public admin;

    // Total platform stats
    uint256 public totalInvestments;
    uint256 public totalAmountUsd;

    event InvestmentRecorded(
        string indexed investmentId,
        string investorId,
        string startupId,
        uint256 amountUsd,
        uint256 timestamp
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can record investments");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * Record an investment on-chain
     * Called by the platform wallet (admin) when an investment is confirmed
     */
    function recordInvestment(
        string memory investmentId,
        string memory investorId,
        string memory startupId,
        string memory roundId,
        uint256 amountUsd
    ) external onlyAdmin {
        require(!investments[investmentId].exists, "Investment already recorded");
        require(amountUsd > 0, "Amount must be greater than 0");
        require(bytes(investmentId).length > 0, "Investment ID required");

        investments[investmentId] = Investment({
            investorId: investorId,
            startupId: startupId,
            roundId: roundId,
            amountUsd: amountUsd,
            timestamp: block.timestamp,
            exists: true
        });

        totalInvestments++;
        totalAmountUsd += amountUsd;

        emit InvestmentRecorded(
            investmentId,
            investorId,
            startupId,
            amountUsd,
            block.timestamp
        );
    }

    /**
     * Get investment details by ID (public read)
     */
    function getInvestment(string memory investmentId)
        external
        view
        returns (
            string memory investorId,
            string memory startupId,
            string memory roundId,
            uint256 amountUsd,
            uint256 timestamp,
            bool exists
        )
    {
        Investment memory inv = investments[investmentId];
        return (
            inv.investorId,
            inv.startupId,
            inv.roundId,
            inv.amountUsd,
            inv.timestamp,
            inv.exists
        );
    }

    /**
     * Get platform-level stats
     */
    function getPlatformStats()
        external
        view
        returns (uint256 _totalInvestments, uint256 _totalAmountUsd)
    {
        return (totalInvestments, totalAmountUsd);
    }

    /**
     * Transfer admin role to new address
     */
    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }
}